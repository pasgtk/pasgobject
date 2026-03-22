{ gir2pas — Generate Pascal bindings from a GIR XML file.

  Usage:
    gir2pas <input.gir> <output-dir> [--lib-name libname]

  Outputs:
    <output-dir>/Internal/<NS>FFI.pas   – raw external C declarations
    <output-dir>/<NS>Types.pas          – enums and bitfields
    <output-dir>/<NS>Classes.pas        – Pascal wrapper classes
}
program gir2pas;

{$mode objfpc}{$H+}

uses
  SysUtils, Classes, DOM, XMLRead;

{ Helper types }

type
  TGirMember = record
    Name  : string;   { C identifier, e.g. GTK_ALIGN_FILL }
    Value : string;   { numeric string }
  end;
  TGirMemberArray = array of TGirMember;

  TGirParam = record
    Name       : string;
    GirType    : string;   { GIR type name }
    IsArray    : Boolean;
    Transfer   : string;   { none / full / container }
    Nullable   : Boolean;
  end;
  TGirParamArray = array of TGirParam;

  TGirMethod = record
    Name          : string;   { snake_case GIR name }
    CIdent        : string;   { C symbol }
    ReturnType    : string;
    ReturnTransfer: string;
    Params        : TGirParamArray;
    IsConstructor : Boolean;
    Throws        : Boolean;
    MovedTo       : string;
    Deprecated    : Boolean;
  end;
  TGirMethodArray = array of TGirMethod;

  TGirEnum = record
    Name       : string;   { C/Pascal type name, e.g. GtkAlign }
    GirName    : string;   { GIR short name, e.g. Align }
    IsBitfield : Boolean;
    Members    : TGirMemberArray;
    GetTypeFn  : string;   { C get_type function }
  end;
  TGirEnumArray = array of TGirEnum;

  TGirClass = record
    Name          : string;   { GIR name, e.g. Button }
    CType         : string;   { C type, e.g. GtkButton }
    Parent        : string;   { GIR parent name, e.g. Widget }
    GetTypeFn     : string;   { C get_type, e.g. gtk_button_get_type }
    Methods       : TGirMethodArray;
    IsAbstract    : Boolean;
    IsGTypeStruct : Boolean;
    Deprecated    : Boolean;
  end;
  TGirClassArray = array of TGirClass;

{ Globals }

var
  GNamespace  : string = '';
  GVersion    : string = '';
  GSharedLib  : string = '';
  GLibNameOvr : string = '';   { --lib-name override }
  GInputFile  : string = '';
  GOutputDir  : string = '';

  GEnums      : TGirEnumArray;
  GEnumCount  : Integer = 0;
  GClasses    : TGirClassArray;
  GClassCount : Integer = 0;

{ Utility }

{ Returns the C/Pascal type name for a GIR short enum name, or '' if not found }
function LookupEnumByGirName(const GirName: string): string;
var I: Integer;
begin
  for I := 0 to GEnumCount - 1 do
    if GEnums[I].GirName = GirName then Exit(GEnums[I].Name);
  Result := '';
end;

{ Returns true if a GIR short name (e.g. Button) is a known class }
function IsKnownClassName(const GirShortName: string): Boolean;
var I: Integer;
begin
  for I := 0 to GClassCount - 1 do
    if GClasses[I].Name = GirShortName then Exit(True);
  Result := False;
end;

function SnakeToPascal(const S: string): string;
var
  Parts : TStringList;
  I     : Integer;
  Part  : string;
begin
  Parts := TStringList.Create;
  try
    Parts.Delimiter     := '_';
    Parts.DelimitedText := S;
    Result := '';
    for I := 0 to Parts.Count - 1 do
    begin
      Part := Parts[I];
      if Part = '' then Continue;
      Part[1] := UpCase(Part[1]);
      Result  := Result + Part;
    end;
  finally
    Parts.Free;
  end;
end;

const
  PascalKeywords : array[0..29] of string = (
    'type', 'label', 'object', 'file', 'string', 'array',
    'begin', 'end', 'procedure', 'function', 'var',
    'unit', 'interface', 'implementation', 'record', 'set',
    'program', 'uses', 'const', 'result', 'self', 'nil', 'in',
    'property', 'class', 'inherited', 'constructor', 'destructor',
    'raise', 'except'
  );

function EscapeParamName(const S: string): string;
var I: Integer;
begin
  Result := S;
  for I := Low(PascalKeywords) to High(PascalKeywords) do
    if LowerCase(S) = PascalKeywords[I] then
    begin
      Result := S + '_';
      Exit;
    end;
end;

{ Escape a PascalCase method name that might be a reserved word }
function EscapeMethodName(const S: string): string;
var I: Integer;
begin
  Result := S;
  for I := Low(PascalKeywords) to High(PascalKeywords) do
    if LowerCase(S) = PascalKeywords[I] then
    begin
      Result := S + '_';
      Exit;
    end;
end;

{ Convert GIR param name to Pascal param name (AXxx) }
function ParamToPas(const RawName: string): string;
var
  Safe : string;
  PC   : string;
begin
  Safe := EscapeParamName(RawName);
  PC   := SnakeToPascal(Safe);
  { Remove trailing underscore added for keyword escaping }
  if (Length(PC) > 0) and (PC[Length(PC)] = '_') then
    Delete(PC, Length(PC), 1);
  Result := 'A' + PC;
end;

{ Map GIR type → FFI Pascal type }
function GirTypeToFFI(const T: string): string;
var Base: string;
begin
  if Pos('.', T) > 0 then
    Base := Copy(T, Pos('.', T) + 1, MaxInt)
  else
    Base := T;

  if (Base = 'utf8') or (Base = 'filename') then Result := 'pgchar'
  else if Base = 'gboolean'                  then Result := 'gboolean'
  else if (Base = 'gint') or (Base = 'gint32')  then Result := 'gint'
  else if (Base = 'guint') or (Base = 'guint32') then Result := 'guint'
  else if Base = 'gint8'   then Result := 'gint8'
  else if Base = 'guint8'  then Result := 'guint8'
  else if Base = 'gint16'  then Result := 'gint16'
  else if Base = 'guint16' then Result := 'guint16'
  else if Base = 'gint64'  then Result := 'gint64'
  else if Base = 'guint64' then Result := 'guint64'
  else if Base = 'gfloat'  then Result := 'gfloat'
  else if Base = 'gdouble' then Result := 'gdouble'
  else if Base = 'gsize'   then Result := 'gsize'
  else if Base = 'gssize'  then Result := 'gssize'
  else if (Base = 'gpointer') or (Base = 'gconstpointer') then Result := 'gpointer'
  else if Base = 'GType'   then Result := 'GType'
  else if Base = 'none'    then Result := ''
  else
  begin
    { Check if it's a known enum (use gint in FFI) or class (gpointer) }
    if LookupEnumByGirName(Base) <> '' then
      Result := 'gint'
    else
      Result := 'gpointer';
  end;
end;

{ Map GIR type → public Pascal type }
function GirTypeToPas(const T: string; const NS: string): string;
var
  NSPart   : string;
  NamePart : string;
  DotPos   : Integer;
begin
  DotPos := Pos('.', T);
  if DotPos > 0 then
  begin
    NSPart   := Copy(T, 1, DotPos - 1);
    NamePart := Copy(T, DotPos + 1, MaxInt);
  end
  else
  begin
    NSPart   := '';
    NamePart := T;
  end;

  if (NamePart = 'utf8') or (NamePart = 'filename') then Result := 'string'
  else if NamePart = 'gboolean'                       then Result := 'Boolean'
  else if (NamePart = 'gint') or (NamePart = 'gint32')  then Result := 'gint'
  else if (NamePart = 'guint') or (NamePart = 'guint32') then Result := 'guint'
  else if NamePart = 'gint8'   then Result := 'gint8'
  else if NamePart = 'guint8'  then Result := 'guint8'
  else if NamePart = 'gint16'  then Result := 'gint16'
  else if NamePart = 'guint16' then Result := 'guint16'
  else if NamePart = 'gint64'  then Result := 'gint64'
  else if NamePart = 'guint64' then Result := 'guint64'
  else if NamePart = 'gfloat'  then Result := 'gfloat'
  else if NamePart = 'gdouble' then Result := 'gdouble'
  else if NamePart = 'gsize'   then Result := 'gsize'
  else if NamePart = 'gssize'  then Result := 'gssize'
  else if (NamePart = 'gpointer') or (NamePart = 'gconstpointer') then Result := 'gpointer'
  else if NamePart = 'GType'   then Result := 'GType'
  else if NamePart = 'none'    then Result := ''
  else
  begin
    if (NSPart = '') or (LowerCase(NSPart) = LowerCase(NS)) then
    begin
      { Check if it is a known enum type (no T prefix) }
      Result := LookupEnumByGirName(NamePart);
      if Result <> '' then Exit;
      { Check if it is a known class type }
      if IsKnownClassName(NamePart) then
        Result := 'T' + NS + NamePart
      else
        Result := 'gpointer';  { interface, callback, record, etc. }
    end
    else
      Result := 'gpointer';
  end;
end;

function IsObjectType(const T: string; const NS: string): Boolean;
var
  Mapped   : string;
  NamePart : string;
  DotPos   : Integer;
begin
  Mapped := GirTypeToPas(T, NS);
  if Mapped = 'gpointer' then begin Result := False; Exit; end;
  { Check that it starts with T+NS and the short name is a known class }
  DotPos := Pos('.', T);
  if DotPos > 0 then NamePart := Copy(T, DotPos + 1, MaxInt)
  else               NamePart := T;
  Result := IsKnownClassName(NamePart);
end;

function ParentToPasClass(const Parent: string; const NS: string): string;
var
  DotPos   : Integer;
  NSPart   : string;
  NamePart : string;
begin
  if Parent = '' then begin Result := 'TGObject'; Exit; end;

  DotPos := Pos('.', Parent);
  if DotPos > 0 then
  begin
    NSPart   := Copy(Parent, 1, DotPos - 1);
    NamePart := Copy(Parent, DotPos + 1, MaxInt);
  end
  else
  begin
    NSPart   := NS;
    NamePart := Parent;
  end;

  if (LowerCase(NSPart) = 'gobject') and
     ((NamePart = 'Object') or (NamePart = 'InitiallyUnowned')) then
  begin
    Result := 'TGObject';
    Exit;
  end;

  if LowerCase(NSPart) = LowerCase(NS) then
  begin
    { Only generate T+NS+Name if the class is actually in our list }
    if IsKnownClassName(NamePart) then
      Result := 'T' + NS + NamePart
    else
      Result := 'TGObject';  { deprecated or interface parent }
  end
  else
    Result := 'TGObject';
end;

{ XML helpers — FPC DOM uses DOMString (UnicodeString); convert explicitly }

function GetAttr(E: TDOMElement; const Name: string): string;
begin
  Result := UTF8Encode(E.GetAttribute(DOMString(Name)));
end;

function HasAttrNonEmpty(E: TDOMElement; const Name: string): Boolean;
begin
  Result := E.GetAttribute(DOMString(Name)) <> '';
end;

function NodeNm(N: TDOMNode): string;
begin
  Result := UTF8Encode(N.NodeName);
end;

function FirstChildByName(Parent: TDOMNode; const NName: string): TDOMElement;
var N: TDOMNode;
begin
  Result := nil;
  N      := Parent.FirstChild;
  while N <> nil do
  begin
    if (N.NodeType = ELEMENT_NODE) and (NodeNm(N) = NName) then
    begin
      Result := TDOMElement(N);
      Exit;
    end;
    N := N.NextSibling;
  end;
end;

{ GIR parsing }

function ParseTypeNode(Parent: TDOMNode): string;
var N: TDOMNode;
begin
  Result := '';
  N := Parent.FirstChild;
  while N <> nil do
  begin
    if N.NodeType = ELEMENT_NODE then
    begin
      if NodeNm(N) = 'type'  then begin Result := GetAttr(TDOMElement(N), 'name'); Exit; end;
      if NodeNm(N) = 'array' then begin Result := '__array__'; Exit; end;
    end;
    N := N.NextSibling;
  end;
end;

function ParseIsArray(Parent: TDOMNode): Boolean;
var N: TDOMNode;
begin
  Result := False;
  N := Parent.FirstChild;
  while N <> nil do
  begin
    if (N.NodeType = ELEMENT_NODE) and (NodeNm(N) = 'array') then begin Result := True; Exit; end;
    N := N.NextSibling;
  end;
end;

function ParseParams(MethodElem: TDOMElement): TGirParamArray;
var
  ParamsElem : TDOMElement;
  N          : TDOMNode;
  E          : TDOMElement;
  P          : TGirParam;
  Count      : Integer;
begin
  Result     := nil;
  Count      := 0;
  ParamsElem := FirstChildByName(MethodElem, 'parameters');
  if ParamsElem = nil then Exit;

  N := ParamsElem.FirstChild;
  while N <> nil do
  begin
    if (N.NodeType = ELEMENT_NODE) and (NodeNm(N) = 'parameter') then
    begin
      E          := TDOMElement(N);
      P.Name     := GetAttr(E, 'name');
      P.Transfer := GetAttr(E, 'transfer-ownership');
      P.Nullable := GetAttr(E, 'nullable') = '1';
      P.IsArray  := ParseIsArray(E);
      P.GirType  := ParseTypeNode(E);
      if P.Name = '' then P.Name := 'param' + IntToStr(Count);
      SetLength(Result, Count + 1);
      Result[Count] := P;
      Inc(Count);
    end;
    N := N.NextSibling;
  end;
end;

function ParseReturnType(MethodElem: TDOMElement; out Transfer: string): string;
var RetElem: TDOMElement;
begin
  Result   := 'none';
  Transfer := 'none';
  RetElem  := FirstChildByName(MethodElem, 'return-value');
  if RetElem = nil then Exit;
  Transfer := GetAttr(RetElem, 'transfer-ownership');
  if Transfer = '' then Transfer := 'none';
  if ParseIsArray(RetElem) then begin Result := '__array__'; Exit; end;
  Result := ParseTypeNode(RetElem);
  if Result = '' then Result := 'none';
end;

function ParseMethod(E: TDOMElement; IsConstructor: Boolean): TGirMethod;
var Transfer: string;
begin
  Result               := Default(TGirMethod);
  Result.Name          := GetAttr(E, 'name');
  Result.CIdent        := GetAttr(E, 'c:identifier');
  Result.IsConstructor := IsConstructor;
  Result.Throws        := GetAttr(E, 'throws') = '1';
  Result.MovedTo       := GetAttr(E, 'moved-to');
  Result.Deprecated    := GetAttr(E, 'deprecated') = '1';
  Result.ReturnType    := ParseReturnType(E, Transfer);
  Result.ReturnTransfer:= Transfer;
  Result.Params        := ParseParams(E);
end;

{ Parse the whole GIR document }

procedure ParseGIR(const FileName: string);
var
  Doc     : TXMLDocument;
  Root    : TDOMElement;
  N       : TDOMNode;
  NSNode  : TDOMNode;
  Child   : TDOMNode;
  E       : TDOMElement;
  En      : TGirEnum;
  Cls     : TGirClass;
  Mth     : TGirMethod;
  MemN    : TDOMNode;
  Mem     : TGirMember;
  MemCnt  : Integer;
  MthN    : TDOMNode;
  MthCnt  : Integer;
begin
  ReadXMLFile(Doc, FileName);
  try
    Root   := Doc.DocumentElement;
    NSNode := nil;
    N      := Root.FirstChild;
    while N <> nil do
    begin
      if (N.NodeType = ELEMENT_NODE) and (NodeNm(N) = 'namespace') then
      begin NSNode := N; Break; end;
      N := N.NextSibling;
    end;
    if NSNode = nil then
    begin
      WriteLn(StdErr, 'Error: no <namespace> element found in GIR');
      Halt(1);
    end;

    GNamespace := GetAttr(TDOMElement(NSNode), 'name');
    GVersion   := GetAttr(TDOMElement(NSNode), 'version');
    GSharedLib := GetAttr(TDOMElement(NSNode), 'shared-library');
    if Pos(',', GSharedLib) > 0 then
      GSharedLib := Copy(GSharedLib, 1, Pos(',', GSharedLib) - 1);

    Child := NSNode.FirstChild;
    while Child <> nil do
    begin
      if Child.NodeType <> ELEMENT_NODE then
      begin Child := Child.NextSibling; Continue; end;
      E := TDOMElement(Child);

      if GetAttr(E, 'introspectable') = '0' then
      begin Child := Child.NextSibling; Continue; end;
      if GetAttr(E, 'deprecated') = '1' then
      begin Child := Child.NextSibling; Continue; end;

      { Enumerations and bitfields }
      if (NodeNm(E) = 'enumeration') or (NodeNm(E) = 'bitfield') then
      begin
        En           := Default(TGirEnum);
        En.GirName   := GetAttr(E, 'name');
        En.Name      := GetAttr(E, 'glib:type-name');
        if En.Name = '' then En.Name := GetAttr(E, 'c:type');
        En.IsBitfield:= NodeNm(E) = 'bitfield';
        En.GetTypeFn := GetAttr(E, 'glib:get-type');
        MemCnt       := 0;
        SetLength(En.Members, 0);
        MemN := E.FirstChild;
        while MemN <> nil do
        begin
          if (MemN.NodeType = ELEMENT_NODE) and (NodeNm(MemN) = 'member') then
          begin
            { Skip deprecated members to avoid duplicate values }
            if GetAttr(TDOMElement(MemN), 'deprecated') = '1' then
            begin
              MemN := MemN.NextSibling;
              Continue;
            end;
            Mem.Name  := GetAttr(TDOMElement(MemN), 'c:identifier');
            Mem.Value := GetAttr(TDOMElement(MemN), 'value');
            SetLength(En.Members, MemCnt + 1);
            En.Members[MemCnt] := Mem;
            Inc(MemCnt);
          end;
          MemN := MemN.NextSibling;
        end;
        if En.Name <> '' then
        begin
          SetLength(GEnums, GEnumCount + 1);
          GEnums[GEnumCount] := En;
          Inc(GEnumCount);
        end;
      end

      { Classes }
      else if NodeNm(E) = 'class' then
      begin
        Cls           := Default(TGirClass);
        Cls.Name      := GetAttr(E, 'name');
        Cls.CType     := GetAttr(E, 'c:type');
        Cls.Parent    := GetAttr(E, 'parent');
        Cls.GetTypeFn := GetAttr(E, 'glib:get-type');
        Cls.IsAbstract:= GetAttr(E, 'abstract') = '1';
        Cls.IsGTypeStruct := HasAttrNonEmpty(E, 'glib:is-gtype-struct-for');

        if Cls.IsGTypeStruct then
        begin Child := Child.NextSibling; Continue; end;

        MthCnt   := 0;
        SetLength(Cls.Methods, 0);
        MthN := E.FirstChild;
        while MthN <> nil do
        begin
          if MthN.NodeType = ELEMENT_NODE then
          begin
            if GetAttr(TDOMElement(MthN), 'introspectable') = '0' then
            begin MthN := MthN.NextSibling; Continue; end;
            if GetAttr(TDOMElement(MthN), 'deprecated') = '1' then
            begin MthN := MthN.NextSibling; Continue; end;

            if (NodeNm(MthN) = 'constructor') or (NodeNm(MthN) = 'method') then
            begin
              Mth := ParseMethod(TDOMElement(MthN), NodeNm(MthN) = 'constructor');
              SetLength(Cls.Methods, MthCnt + 1);
              Cls.Methods[MthCnt] := Mth;
              Inc(MthCnt);
            end;
          end;
          MthN := MthN.NextSibling;
        end;

        SetLength(GClasses, GClassCount + 1);
        GClasses[GClassCount] := Cls;
        Inc(GClassCount);
      end;

      Child := Child.NextSibling;
    end;
  finally
    Doc.Free;
  end;
end;

{ Topological sort }

function ClassIndexByName(const Name: string): Integer;
var I: Integer;
begin
  for I := 0 to GClassCount - 1 do
    if GClasses[I].Name = Name then Exit(I);
  Result := -1;
end;

procedure TopoSort;
var
  Sorted    : TGirClassArray;
  Visited   : array of Boolean;
  SortCount : Integer;

  procedure Visit(Idx: Integer);
  var
    ParentIdx  : Integer;
    ParentName : string;
    DotPos     : Integer;
  begin
    if Visited[Idx] then Exit;
    Visited[Idx] := True;
    ParentName   := GClasses[Idx].Parent;
    DotPos       := Pos('.', ParentName);
    if DotPos > 0 then ParentName := Copy(ParentName, DotPos + 1, MaxInt);
    ParentIdx := ClassIndexByName(ParentName);
    if ParentIdx >= 0 then Visit(ParentIdx);
    Sorted[SortCount] := GClasses[Idx];
    Inc(SortCount);
  end;

var I: Integer;
begin
  SetLength(Sorted,  GClassCount);
  SetLength(Visited, GClassCount);
  for I := 0 to GClassCount - 1 do Visited[I] := False;
  SortCount := 0;
  for I := 0 to GClassCount - 1 do Visit(I);
  GClasses := Sorted;
end;

{ Shared library constant name }

function LibConst: string;
begin
  Result := 'lib' + GNamespace;
end;

function LibValue: string;
begin
  if GLibNameOvr <> '' then Result := GLibNameOvr
  else                       Result := GSharedLib;
end;

{ Method filtering }

function ShouldSkip(const M: TGirMethod): Boolean;
var I: Integer;
begin
  Result := True;
  if M.MovedTo   <> '' then Exit;
  if M.Throws          then Exit;
  if M.Deprecated      then Exit;
  if M.CIdent    = ''  then Exit;
  if M.ReturnType = '__array__' then Exit;
  for I := 0 to High(M.Params) do
    if M.Params[I].IsArray then Exit;
  Result := False;
end;

{ Generate Internal/NsFFI.pas }

function BuildFFIParams(const M: TGirMethod; IncludeSelf: Boolean): string;
var
  I    : Integer;
  Sep  : string;
  PNam : string;
  PTyp : string;
begin
  Result := '';
  Sep    := '';
  if IncludeSelf then begin Result := 'self_: gpointer'; Sep := '; '; end;
  for I := 0 to High(M.Params) do
  begin
    PNam := EscapeParamName(M.Params[I].Name);
    PTyp := GirTypeToFFI(M.Params[I].GirType);
    if PTyp = '' then PTyp := 'gpointer';
    Result := Result + Sep + PNam + ': ' + PTyp;
    Sep    := '; ';
  end;
end;

procedure GenerateFFI(const OutDir: string);
var
  SL      : TStringList;
  I, J    : Integer;
  M       : TGirMethod;
  Params  : string;
  RetFFI  : string;
  IDir    : string;
begin
  IDir := OutDir + PathDelim + 'Internal';
  ForceDirectories(IDir);
  SL := TStringList.Create;
  try
    SL.Add('{ Auto-generated by gir2pas from ' + GNamespace + '-' + GVersion + '.gir. DO NOT EDIT MANUALLY. }');
    SL.Add('unit ' + GNamespace + 'FFI;');
    SL.Add('');
    SL.Add('{$mode objfpc}{$H+}{$PackRecords C}');
    SL.Add('');
    SL.Add('interface');
    SL.Add('');
    SL.Add('uses GTypes;');
    SL.Add('');
    SL.Add('const');
    SL.Add('  ' + LibConst + ' = ''' + LibValue + ''';');
    SL.Add('');

    SL.Add('{ Enumeration GType queries }');
    for I := 0 to GEnumCount - 1 do
      if GEnums[I].GetTypeFn <> '' then
        SL.Add('function ' + GEnums[I].GetTypeFn + ': GType; external ' + LibConst + ';');
    SL.Add('');

    SL.Add('{ Class GType queries }');
    for I := 0 to GClassCount - 1 do
      if GClasses[I].GetTypeFn <> '' then
        SL.Add('function ' + GClasses[I].GetTypeFn + ': GType; external ' + LibConst + ';');
    SL.Add('');

    for I := 0 to GClassCount - 1 do
    begin
      if Length(GClasses[I].Methods) = 0 then Continue;
      SL.Add('{ ' + GClasses[I].CType + ' }');
      for J := 0 to High(GClasses[I].Methods) do
      begin
        M := GClasses[I].Methods[J];
        if ShouldSkip(M) then Continue;
        RetFFI := GirTypeToFFI(M.ReturnType);
        if M.IsConstructor then
        begin
          Params := BuildFFIParams(M, False);
          if Params <> '' then
            SL.Add('function  ' + M.CIdent + '(' + Params + '): gpointer; external ' + LibConst + ';')
          else
            SL.Add('function  ' + M.CIdent + ': gpointer; external ' + LibConst + ';');
        end
        else
        begin
          Params := BuildFFIParams(M, True);
          if RetFFI = '' then
            SL.Add('procedure ' + M.CIdent + '(' + Params + '); external ' + LibConst + ';')
          else
            SL.Add('function  ' + M.CIdent + '(' + Params + '): ' + RetFFI + '; external ' + LibConst + ';');
        end;
      end;
      SL.Add('');
    end;

    SL.Add('implementation');
    SL.Add('end.');

    SL.SaveToFile(IDir + PathDelim + GNamespace + 'FFI.pas');
    WriteLn('Written: ', IDir + PathDelim + GNamespace + 'FFI.pas');
  finally
    SL.Free;
  end;
end;

{ Generate NsTypes.pas }

procedure GenerateTypes(const OutDir: string);
var
  SL    : TStringList;
  I, J  : Integer;
  En    : TGirEnum;
  HasConst : Boolean;
begin
  SL := TStringList.Create;
  try
    SL.Add('{ Auto-generated by gir2pas from ' + GNamespace + '-' + GVersion + '.gir. DO NOT EDIT MANUALLY. }');
    SL.Add('unit ' + GNamespace + 'Types;');
    SL.Add('');
    SL.Add('{$mode objfpc}{$H+}');
    SL.Add('');
    SL.Add('interface');
    SL.Add('');
    SL.Add('type');

    for I := 0 to GEnumCount - 1 do
    begin
      En := GEnums[I];
      if Length(En.Members) = 0 then Continue;
      if En.IsBitfield then
      begin
        SL.Add('  { Bitfield — exposed as Cardinal constants }');
        SL.Add('  ' + En.Name + ' = Cardinal;');
        SL.Add('');
      end
      else
      begin
        SL.Add('  ' + En.Name + ' = (');
        for J := 0 to High(En.Members) do
        begin
          if J < High(En.Members) then
            SL.Add('    ' + En.Members[J].Name + ' = ' + En.Members[J].Value + ',')
          else
            SL.Add('    ' + En.Members[J].Name + ' = ' + En.Members[J].Value);
        end;
        SL.Add('  );');
        SL.Add('');
      end;
    end;

    HasConst := False;
    for I := 0 to GEnumCount - 1 do
      if GEnums[I].IsBitfield and (Length(GEnums[I].Members) > 0) then begin HasConst := True; Break; end;

    if HasConst then
    begin
      SL.Add('const');
      for I := 0 to GEnumCount - 1 do
      begin
        En := GEnums[I];
        if not En.IsBitfield then Continue;
        if Length(En.Members) = 0 then Continue;
        for J := 0 to High(En.Members) do
          SL.Add('  ' + En.Members[J].Name + ' = ' + En.Name + '(' + En.Members[J].Value + ');');
        SL.Add('');
      end;
    end;

    SL.Add('implementation');
    SL.Add('end.');

    SL.SaveToFile(OutDir + PathDelim + GNamespace + 'Types.pas');
    WriteLn('Written: ', OutDir + PathDelim + GNamespace + 'Types.pas');
  finally
    SL.Free;
  end;
end;

{ Generate NsClasses.pas }

function PasParamDecl(const P: TGirParam): string;
var
  PTyp : string;
  PNam : string;
begin
  PTyp := GirTypeToPas(P.GirType, GNamespace);
  if PTyp = '' then PTyp := 'gpointer';
  PNam := ParamToPas(P.Name);
  Result := 'const ' + PNam + ': ' + PTyp;
end;

function PasParamConvert(const P: TGirParam): string;
var
  PTyp    : string;
  PNam    : string;
  IsEnum  : Boolean;
begin
  PTyp   := GirTypeToPas(P.GirType, GNamespace);
  PNam   := ParamToPas(P.Name);
  if PTyp = '' then PTyp := 'gpointer';
  { Check if this is an enum type (no T prefix, starts with NS prefix like Gtk) }
  IsEnum := (LookupEnumByGirName(P.GirType) <> '') or
            (Pos('.', P.GirType) > 0) and (LookupEnumByGirName(Copy(P.GirType, Pos('.', P.GirType) + 1, MaxInt)) <> '');

  if PTyp = 'string'      then Result := 'GLibStr(' + PNam + ')'
  else if PTyp = 'Boolean'     then Result := 'gboolean(' + PNam + ')'
  else if PTyp = 'gint'        then Result := 'gint(' + PNam + ')'
  else if PTyp = 'guint'       then Result := 'guint(' + PNam + ')'
  else if IsEnum               then Result := 'gint(' + PNam + ')'
  else if (Length(PTyp) > 1) and (PTyp[1] = 'T') and (UpCase(PTyp[2]) = PTyp[2]) then
  begin
    { Object param — use gir2pas helper ObjH }
    Result := 'ObjH(' + PNam + ')';
  end
  else
    Result := PNam;
end;

function RetDefault(const PTyp: string): string;
begin
  if PTyp = 'string'       then Result := ''''''
  else if PTyp = 'Boolean'      then Result := 'False'
  else if PTyp = 'gpointer'     then Result := 'nil'
  else if PTyp = 'GType'        then Result := '0'
  else if (Length(PTyp) > 1) and (PTyp[1] = 'T') and (UpCase(PTyp[2]) = PTyp[2]) then
    Result := 'nil'
  else
    { Enum types and primitive types: cast 0 to the type }
    Result := PTyp + '(0)';
end;

procedure GenerateClasses(const OutDir: string);
var
  SL       : TStringList;
  Iface    : TStringList;
  Impl     : TStringList;
  Fwd      : TStringList;
  I, J, K  : Integer;
  Cls      : TGirClass;
  M        : TGirMethod;
  PasClass : string;
  PasPar   : string;
  PasMeth  : string;
  RetPas   : string;
  PDecls   : string;
  PCalls   : string;
  VarName  : string;

  function BuildSig(const M2: TGirMethod): string;
  var PD, Sep2: string; K2: Integer;
  begin
    PasMeth := EscapeMethodName(SnakeToPascal(M2.Name));
    RetPas  := GirTypeToPas(M2.ReturnType, GNamespace);
    PD  := '';
    Sep2 := '';
    for K2 := 0 to High(M2.Params) do
    begin
      PD   := PD + Sep2 + PasParamDecl(M2.Params[K2]);
      Sep2 := '; ';
    end;
    if M2.IsConstructor then
    begin
      if PD <> '' then Result := 'constructor ' + PasMeth + '(' + PD + '); reintroduce;'
      else             Result := 'constructor ' + PasMeth + '; reintroduce;';
    end
    else if RetPas = '' then
    begin
      if PD <> '' then Result := 'procedure ' + PasMeth + '(' + PD + ');'
      else             Result := 'procedure ' + PasMeth + ';';
    end
    else
    begin
      if PD <> '' then Result := 'function  ' + PasMeth + '(' + PD + '): ' + RetPas + ';'
      else             Result := 'function  ' + PasMeth + ': ' + RetPas + ';';
    end;
  end;

begin
  Fwd   := TStringList.Create;
  Iface := TStringList.Create;
  Impl  := TStringList.Create;
  SL    := TStringList.Create;
  try
    Fwd.Add('  { Forward declarations }');
    for I := 0 to GClassCount - 1 do
      Fwd.Add('  T' + GNamespace + GClasses[I].Name + ' = class;');
    Fwd.Add('');

    for I := 0 to GClassCount - 1 do
    begin
      Cls      := GClasses[I];
      PasClass := 'T' + GNamespace + Cls.Name;
      PasPar   := ParentToPasClass(Cls.Parent, GNamespace);

      Iface.Add('  ' + PasClass + ' = class(' + PasPar + ')');
      Iface.Add('  public');
      Iface.Add('    class function TypeID: GType; override;');
      for J := 0 to High(Cls.Methods) do
      begin
        M := Cls.Methods[J];
        if ShouldSkip(M) then Continue;
        if M.IsConstructor and Cls.IsAbstract then Continue;
        Iface.Add('    ' + BuildSig(M));
      end;
      Iface.Add('  end;');
      Iface.Add('');
    end;

    for I := 0 to GClassCount - 1 do
    begin
      Cls      := GClasses[I];
      PasClass := 'T' + GNamespace + Cls.Name;

      Impl.Add('class function ' + PasClass + '.TypeID: GType;');
      Impl.Add('begin');
      if Cls.GetTypeFn <> '' then
        Impl.Add('  Result := ' + GNamespace + 'FFI.' + Cls.GetTypeFn + '();')
      else
        Impl.Add('  Result := inherited TypeID;');
      Impl.Add('end;');
      Impl.Add('');

      for J := 0 to High(Cls.Methods) do
      begin
        M := Cls.Methods[J];
        if ShouldSkip(M) then Continue;
        if M.IsConstructor and Cls.IsAbstract then Continue;

        PasMeth := EscapeMethodName(SnakeToPascal(M.Name));
        RetPas  := GirTypeToPas(M.ReturnType, GNamespace);

        PDecls := ''; PCalls := '';
        for K := 0 to High(M.Params) do
        begin
          if K > 0 then PDecls := PDecls + '; ';
          if K > 0 then PCalls := PCalls + ', ';
          PDecls := PDecls + PasParamDecl(M.Params[K]);
          PCalls := PCalls + PasParamConvert(M.Params[K]);
        end;

        if M.IsConstructor then
        begin
          if PDecls <> '' then
            Impl.Add('constructor ' + PasClass + '.' + PasMeth + '(' + PDecls + ');')
          else
            Impl.Add('constructor ' + PasClass + '.' + PasMeth + ';');
          Impl.Add('begin');
          if PCalls <> '' then
            Impl.Add('  inherited CreateFromHandle(' + GNamespace + 'FFI.' + M.CIdent + '(' + PCalls + '));')
          else
            Impl.Add('  inherited CreateFromHandle(' + GNamespace + 'FFI.' + M.CIdent + ');');
          Impl.Add('end;');
        end
        else if RetPas = '' then
        begin
          if PDecls <> '' then
            Impl.Add('procedure ' + PasClass + '.' + PasMeth + '(' + PDecls + ');')
          else
            Impl.Add('procedure ' + PasClass + '.' + PasMeth + ';');
          Impl.Add('begin');
          Impl.Add('  if Handle = nil then Exit;');
          if PCalls <> '' then
            Impl.Add('  ' + GNamespace + 'FFI.' + M.CIdent + '(Handle, ' + PCalls + ');')
          else
            Impl.Add('  ' + GNamespace + 'FFI.' + M.CIdent + '(Handle);');
          Impl.Add('end;');
        end
        else if RetPas = 'string' then
        begin
          if PDecls <> '' then
            Impl.Add('function ' + PasClass + '.' + PasMeth + '(' + PDecls + '): ' + RetPas + ';')
          else
            Impl.Add('function ' + PasClass + '.' + PasMeth + ': ' + RetPas + ';');
          Impl.Add('begin');
          if PCalls <> '' then
            Impl.Add('  if Handle <> nil then Result := PasStr(' + GNamespace + 'FFI.' + M.CIdent + '(Handle, ' + PCalls + ')) else Result := '''';')
          else
            Impl.Add('  if Handle <> nil then Result := PasStr(' + GNamespace + 'FFI.' + M.CIdent + '(Handle)) else Result := '''';');
          Impl.Add('end;');
        end
        else if RetPas = 'Boolean' then
        begin
          if PDecls <> '' then
            Impl.Add('function ' + PasClass + '.' + PasMeth + '(' + PDecls + '): ' + RetPas + ';')
          else
            Impl.Add('function ' + PasClass + '.' + PasMeth + ': ' + RetPas + ';');
          Impl.Add('begin');
          if PCalls <> '' then
            Impl.Add('  Result := (Handle <> nil) and Boolean(' + GNamespace + 'FFI.' + M.CIdent + '(Handle, ' + PCalls + '));')
          else
            Impl.Add('  Result := (Handle <> nil) and Boolean(' + GNamespace + 'FFI.' + M.CIdent + '(Handle));');
          Impl.Add('end;');
        end
        else if IsObjectType(M.ReturnType, GNamespace) and (RetPas <> 'gpointer') then
        begin
          VarName := 'P_';
          if PDecls <> '' then
            Impl.Add('function ' + PasClass + '.' + PasMeth + '(' + PDecls + '): ' + RetPas + ';')
          else
            Impl.Add('function ' + PasClass + '.' + PasMeth + ': ' + RetPas + ';');
          Impl.Add('var ' + VarName + ': gpointer;');
          Impl.Add('begin');
          Impl.Add('  Result := nil;');
          Impl.Add('  if Handle = nil then Exit;');
          if PCalls <> '' then
            Impl.Add('  ' + VarName + ' := ' + GNamespace + 'FFI.' + M.CIdent + '(Handle, ' + PCalls + ');')
          else
            Impl.Add('  ' + VarName + ' := ' + GNamespace + 'FFI.' + M.CIdent + '(Handle);');
          Impl.Add('  if ' + VarName + ' <> nil then');
          if M.ReturnTransfer = 'full' then
            Impl.Add('    Result := ' + RetPas + '(' + RetPas + '.Take(' + VarName + '));')
          else
            Impl.Add('    Result := ' + RetPas + '(' + RetPas + '.Borrow(' + VarName + '));');
          Impl.Add('end;');
        end
        else
        begin
          if PDecls <> '' then
            Impl.Add('function ' + PasClass + '.' + PasMeth + '(' + PDecls + '): ' + RetPas + ';')
          else
            Impl.Add('function ' + PasClass + '.' + PasMeth + ': ' + RetPas + ';');
          Impl.Add('begin');
          Impl.Add('  if Handle = nil then begin Result := ' + RetDefault(RetPas) + '; Exit; end;');
          if PCalls <> '' then
            Impl.Add('  Result := ' + RetPas + '(' + GNamespace + 'FFI.' + M.CIdent + '(Handle, ' + PCalls + '));')
          else
            Impl.Add('  Result := ' + RetPas + '(' + GNamespace + 'FFI.' + M.CIdent + '(Handle));');
          Impl.Add('end;');
        end;
        Impl.Add('');
      end;
    end;

    SL.Add('{ Auto-generated by gir2pas from ' + GNamespace + '-' + GVersion + '.gir. DO NOT EDIT MANUALLY. }');
    SL.Add('unit ' + GNamespace + 'Classes;');
    SL.Add('');
    SL.Add('{$mode objfpc}{$H+}{$PackRecords C}');
    SL.Add('');
    SL.Add('interface');
    SL.Add('');
    SL.Add('uses GTypes, GLib, GObjectType, GObject, ' + GNamespace + 'Types, ' + GNamespace + 'FFI;');
    SL.Add('');
    SL.Add('type');
    SL.AddStrings(Fwd);
    SL.AddStrings(Iface);
    SL.Add('implementation');
    SL.Add('');
    SL.Add('{ Helper: return Handle of a TGObject wrapper, or nil if wrapper is nil }');
    SL.Add('function ObjH(O: TGObject): gpointer; inline;');
    SL.Add('begin');
    SL.Add('  if O = nil then Result := nil else Result := O.Handle;');
    SL.Add('end;');
    SL.Add('');
    SL.AddStrings(Impl);
    SL.Add('end.');

    SL.SaveToFile(OutDir + PathDelim + GNamespace + 'Classes.pas');
    WriteLn('Written: ', OutDir + PathDelim + GNamespace + 'Classes.pas');
  finally
    SL.Free; Iface.Free; Impl.Free; Fwd.Free;
  end;
end;

{ Main }

procedure ParseArgs;
var I: Integer;
begin
  if ParamCount < 2 then
  begin
    WriteLn(StdErr, 'Usage: gir2pas <input.gir> <output-dir> [--lib-name libname]');
    Halt(1);
  end;
  GInputFile := ParamStr(1);
  GOutputDir := ParamStr(2);
  I := 3;
  while I <= ParamCount do
  begin
    if ParamStr(I) = '--lib-name' then
    begin
      Inc(I);
      if I <= ParamCount then GLibNameOvr := ParamStr(I);
    end;
    Inc(I);
  end;
end;

begin
  ParseArgs;
  if not FileExists(GInputFile) then
  begin
    WriteLn(StdErr, 'Error: input file not found: ', GInputFile);
    Halt(1);
  end;
  ForceDirectories(GOutputDir);
  WriteLn('Parsing ', GInputFile, ' ...');
  ParseGIR(GInputFile);
  WriteLn('Namespace : ', GNamespace, ' v', GVersion);
  WriteLn('Library   : ', LibValue);
  WriteLn('Classes   : ', GClassCount);
  WriteLn('Enums     : ', GEnumCount);
  TopoSort;
  WriteLn('Generating files in ', GOutputDir, ' ...');
  GenerateFFI(GOutputDir);
  GenerateTypes(GOutputDir);
  GenerateClasses(GOutputDir);
  WriteLn('Done.');
end.
