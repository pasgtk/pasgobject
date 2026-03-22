{ Pascal-GObject - Pascal bindings for the GObject type system
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GValue - TGValue class wrapping the GValue generic value container.

  The interface section exposes no extern declarations.  All raw
  C symbols are imported through GObjectFFI in the implementation. }
unit GValue;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes, GObjectType;

const
  G_VALUE_NOCOPY_CONTENTS = guint(1 shl 27);

{ TGValue wraps a GValue record and manages its lifetime.

  Call one of the Init* methods to set the type before reading or
  writing a value.  The destructor calls g_value_unset automatically.
  InitFromRaw wraps an existing GValue record without taking ownership
  of the memory (for use by C callbacks). }
type
  TGValue = class
  private
    FValue       : GTypes.GValue;
    FExternalRaw : PGValue;
    FInitialized : Boolean;
    FExternal    : Boolean;
    function GetRawPtr: PGValue;
  public
    constructor Create;
    destructor Destroy; override;

    { InitFromRaw points this wrapper at an existing GValue record.
      The wrapper does not own the record and will not call g_value_unset. }
    procedure InitFromRaw(var ARaw: GTypes.GValue);

    { InitType initialises the value for the given GType.
      Any previous owned value is unset first. }
    procedure InitType(AType: GType);

    procedure InitBoolean(AValue: Boolean);
    procedure InitInt(AValue: Integer);
    procedure InitUInt(AValue: Cardinal);
    procedure InitInt64(AValue: Int64);
    procedure InitUInt64(AValue: QWord);
    procedure InitFloat(AValue: Single);
    procedure InitDouble(AValue: Double);
    procedure InitString(const AValue: string);
    procedure InitObject(AObject: gpointer);
    procedure InitPointer(APointer: gpointer);
    procedure InitEnum(AValue: Integer; AType: GType);
    procedure InitFlags(AValue: Cardinal; AType: GType);

    function AsBoolean: Boolean;
    function AsInt: Integer;
    function AsUInt: Cardinal;
    function AsInt64: Int64;
    function AsUInt64: QWord;
    function AsFloat: Single;
    function AsDouble: Double;
    function AsString: string;
    function AsObject: gpointer;
    function AsPointer: gpointer;
    function AsEnum: Integer;
    function AsFlags: Cardinal;

    { CopyFrom copies the type and value from ASource into this instance. }
    procedure CopyFrom(ASource: TGValue);

    { Transform converts this value into ADest.  Returns True on success. }
    function Transform(ADest: TGValue): Boolean;

    function TypeID: GType;
    function TypeName: string;
    function IsInitialized: Boolean;

    property Raw    : GTypes.GValue  read FValue;
    property RawPtr : PGValue        read GetRawPtr;
  end;

implementation

uses GObjectFFI, GLib;

function TGValue.GetRawPtr: PGValue;
begin
  if FExternal and (FExternalRaw <> nil) then
    Result := FExternalRaw
  else
    Result := @FValue;
end;

constructor TGValue.Create;
begin
  inherited;
  FillChar(FValue, SizeOf(GTypes.GValue), 0);
  FExternalRaw := nil;
  FInitialized := False;
  FExternal    := False;
end;

destructor TGValue.Destroy;
begin
  if FInitialized and not FExternal then
    g_value_unset(@FValue);
  inherited;
end;

procedure TGValue.InitFromRaw(var ARaw: GTypes.GValue);
begin
  if FInitialized and not FExternal then
    g_value_unset(@FValue);
  FExternalRaw := @ARaw;
  FInitialized := True;
  FExternal    := True;
end;

procedure TGValue.InitType(AType: GType);
begin
  if FInitialized and not FExternal then
    g_value_unset(@FValue);
  FExternal := False;
  g_value_init(@FValue, AType);
  FInitialized := True;
end;

procedure TGValue.InitBoolean(AValue: Boolean);
begin
  InitType(G_TYPE_BOOLEAN);
  g_value_set_boolean(@FValue, gboolean(AValue));
end;

procedure TGValue.InitInt(AValue: Integer);
begin
  InitType(G_TYPE_INT);
  g_value_set_int(@FValue, gint(AValue));
end;

procedure TGValue.InitUInt(AValue: Cardinal);
begin
  InitType(G_TYPE_UINT);
  g_value_set_uint(@FValue, guint(AValue));
end;

procedure TGValue.InitInt64(AValue: Int64);
begin
  InitType(G_TYPE_INT64);
  g_value_set_int64(@FValue, gint64(AValue));
end;

procedure TGValue.InitUInt64(AValue: QWord);
begin
  InitType(G_TYPE_UINT64);
  g_value_set_uint64(@FValue, guint64(AValue));
end;

procedure TGValue.InitFloat(AValue: Single);
begin
  InitType(G_TYPE_FLOAT);
  g_value_set_float(@FValue, gfloat(AValue));
end;

procedure TGValue.InitDouble(AValue: Double);
begin
  InitType(G_TYPE_DOUBLE);
  g_value_set_double(@FValue, gdouble(AValue));
end;

procedure TGValue.InitString(const AValue: string);
begin
  InitType(G_TYPE_STRING);
  g_value_set_string(@FValue, GLibStr(AValue));
end;

procedure TGValue.InitObject(AObject: gpointer);
begin
  InitType(G_TYPE_OBJECT);
  g_value_set_object(@FValue, AObject);
end;

procedure TGValue.InitPointer(APointer: gpointer);
begin
  InitType(G_TYPE_POINTER);
  g_value_set_pointer(@FValue, APointer);
end;

procedure TGValue.InitEnum(AValue: Integer; AType: GType);
begin
  InitType(AType);
  g_value_set_enum(@FValue, gint(AValue));
end;

procedure TGValue.InitFlags(AValue: Cardinal; AType: GType);
begin
  InitType(AType);
  g_value_set_flags(@FValue, guint(AValue));
end;

function TGValue.AsBoolean: Boolean;
begin
  Result := Boolean(g_value_get_boolean(RawPtr));
end;

function TGValue.AsInt: Integer;
begin
  Result := Integer(g_value_get_int(RawPtr));
end;

function TGValue.AsUInt: Cardinal;
begin
  Result := Cardinal(g_value_get_uint(RawPtr));
end;

function TGValue.AsInt64: Int64;
begin
  Result := Int64(g_value_get_int64(RawPtr));
end;

function TGValue.AsUInt64: QWord;
begin
  Result := QWord(g_value_get_uint64(RawPtr));
end;

function TGValue.AsFloat: Single;
begin
  Result := Single(g_value_get_float(RawPtr));
end;

function TGValue.AsDouble: Double;
begin
  Result := Double(g_value_get_double(RawPtr));
end;

function TGValue.AsString: string;
begin
  Result := PasStr(g_value_get_string(RawPtr));
end;

function TGValue.AsObject: gpointer;
begin
  Result := g_value_get_object(RawPtr);
end;

function TGValue.AsPointer: gpointer;
begin
  Result := g_value_get_pointer(RawPtr);
end;

function TGValue.AsEnum: Integer;
begin
  Result := Integer(g_value_get_enum(RawPtr));
end;

function TGValue.AsFlags: Cardinal;
begin
  Result := Cardinal(g_value_get_flags(RawPtr));
end;

procedure TGValue.CopyFrom(ASource: TGValue);
begin
  if FInitialized and not FExternal then
    g_value_unset(@FValue);
  FExternal := False;
  g_value_init(@FValue, ASource.TypeID);
  g_value_copy(ASource.RawPtr, @FValue);
  FInitialized := True;
end;

function TGValue.Transform(ADest: TGValue): Boolean;
begin
  Result := Boolean(g_value_transform(RawPtr, ADest.RawPtr));
end;

function TGValue.TypeID: GType;
begin
  Result := RawPtr^.g_type;
end;

function TGValue.TypeName: string;
begin
  Result := GObjectType.GTypeName(TypeID);
end;

function TGValue.IsInitialized: Boolean;
begin
  Result := FInitialized;
end;

end.
