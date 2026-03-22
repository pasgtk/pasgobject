{ Pascal-GObject - Pascal bindings for the GObject type system
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GObject - TGObject Pascal class with GI ownership semantics and subclassing.

  TGObject wraps a C GObject handle.  Ownership transfer follows the
  GObject Introspection convention:
    Take   — transfer:full, the caller already owns the reference
    Borrow — transfer:none, an extra ref is taken

  Subclassing: derive from TGObject in Pascal and the first call to
  TypeID will lazily register a new GType with the GType system.
  The Pascal wrapper instance is stored in qdata keyed by WrapperQuark
  so C callbacks can retrieve it. }
unit GObject;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes, GLib, GObjectType, GValue, GParam;

type
  TGObject      = class;
  TGObjectClass = class of TGObject;

  TGObject = class
  private
    FHandle : PGObjectC;
    FOwned  : Boolean;
    function GetRefCount: guint;
    function GetIsFloating: Boolean;
    function GetHandleTypeID: GType;
  protected
    { CreateFromHandle initialises this wrapper around an existing C handle.
      Floating references (GInitiallyUnowned, e.g. GtkWidget) are sunk
      automatically via g_object_is_floating + g_object_ref_sink.
      Used by generated GTK constructors instead of Create. }
    constructor CreateFromHandle(AHandle: Pointer);

    { InstanceSetup is called once after the C GObject is created.
      Override to perform per-instance initialisation. }
    procedure InstanceSetup; virtual;

    { DoDispose is called from the C dispose vfunc before the parent chain. }
    procedure DoDispose; virtual;

    { DoFinalize is called from the C finalize vfunc.  At this point
      FHandle is about to be set to nil.  Do not call GObject methods here. }
    procedure DoFinalize; virtual;

    { DoGetProp is called when the GObject property system reads a property. }
    procedure DoGetProp(id: guint; val: TGValue; spec: PGParamSpec); virtual;

    { DoSetProp is called when the GObject property system writes a property. }
    procedure DoSetProp(id: guint; const val: TGValue; spec: PGParamSpec); virtual;

  public
    { TypeName returns the GType name to register.
      By default uses ClassName. }
    class function TypeName: string; virtual;

    { ParentGType returns the GType of the Pascal parent class.
      By default walks ClassParent to find its TypeID. }
    class function ParentGType: GType; virtual;

    { ClassSetup is called during class_init so the subclass can install
      properties and signals.  Override and call g_object_class_install_property
      directly or use the GParam helpers. }
    class procedure ClassSetup(AClass: PGObjectClass); virtual;

    { TypeID returns (and lazily registers) the GType for this Pascal class. }
    class function TypeID: GType; virtual;

    { Take wraps AHandle without adding a reference (transfer:full). }
    class function Take(AHandle: Pointer): TGObject;

    { Borrow wraps AHandle and adds a reference (transfer:none). }
    class function Borrow(AHandle: Pointer): TGObject;

    { Create allocates a new GObject of this class's TypeID. }
    constructor Create; virtual;

    destructor Destroy; override;

    { Reference counting helpers }
    procedure Ref;
    procedure Unref;
    procedure RefSink;

    { Property change notifications }
    procedure FreezeNotify;
    procedure ThawNotify;
    procedure Notify(const APropertyName: string);

    { GetProperty reads a typed property by name.  Caller owns the result. }
    function GetProperty(const AName: string): TGValue;

    { SetProperty writes a typed property by name. }
    procedure SetProperty(const AName: string; AValue: TGValue);

    { Arbitrary string-keyed data attached to the C instance. }
    function GetData(const AKey: string): gpointer;
    procedure SetData(const AKey: string; AData: gpointer);
    procedure SetDataFull(const AKey: string; AData: gpointer;
      ADestroyFunc: GDestroyNotify);
    function StealData(const AKey: string): gpointer;

    { QData — quark-keyed data attached to the C instance. }
    function GetQData(AQuark: GQuark): gpointer;
    procedure SetQData(AQuark: GQuark; AData: gpointer);
    procedure SetQDataFull(AQuark: GQuark; AData: gpointer;
      ADestroy: GDestroyNotify);
    function StealQData(AQuark: GQuark): gpointer;

    property Handle    : PGObjectC read FHandle;
    property TypeID_   : GType     read GetHandleTypeID;
    property RefCount  : guint     read GetRefCount;
    property IsFloating: Boolean   read GetIsFloating;
    property Owned     : Boolean   read FOwned write FOwned;
  end;

{ WrapperQuark returns the GQuark used to store Pascal wrapper pointers
  in the C GObject qdata table.  Created on first call. }
function WrapperQuark: GQuark;

{ These C-callable callbacks are used by PasGObjectGetOrRegister.
  They are declared here so GSignal.pas can use WrapperQuark without
  creating a circular dependency. }
procedure PasClassInit(klass: Pointer; class_data: Pointer); cdecl;
procedure PasInstanceInit(instance: PGTypeInstance; klass: Pointer); cdecl;
procedure PasDispose(obj: Pointer); cdecl;
procedure PasFinalize(obj: Pointer); cdecl;
procedure PasGetProperty(obj: Pointer; id: guint; val: Pointer; spec: Pointer); cdecl;
procedure PasSetProperty(obj: Pointer; id: guint; const val: Pointer; spec: Pointer); cdecl;

{ g_object_class_install_property and related helpers exposed for ClassSetup
  implementations that do not want to use GObjectFFI directly. }
procedure g_object_class_install_property(oclass: PGObjectClass; property_id: guint;
  pspec: PGParamSpec);
function g_object_class_find_property(oclass: PGObjectClass;
  property_name: pgchar): PGParamSpec;

{ g_object_new exposed for code that creates bare C instances (transfer:full).
  Only the no-properties form (nil terminator) is wrapped here. }
function g_object_new(object_type: GType; first_property_name: pgchar): PGObjectC;

{ g_object_unref/g_object_ref exposed for code that holds raw handles. }
function g_object_ref(obj: gpointer): gpointer;
procedure g_object_unref(obj: gpointer);

{ g_value_set_int / g_value_get_int exposed for DoGetProp / DoSetProp
  implementations that write directly into a raw PGValue. }
procedure g_value_set_int(value: PGValue; v_int: gint);
function g_value_get_int(const value: PGValue): gint;
procedure g_value_set_string(value: PGValue; v_string: pgchar);
function g_value_get_string(const value: PGValue): pgchar;

{ g_quark_from_string exposed for test code. }
function g_quark_from_string(str: pgchar): GQuark;

implementation

uses GObjectFFI, GLibFFI;

{ ToggleNotify is the GToggleNotify callback registered with every owned wrapper.
  GLib calls it when the toggle ref transitions between being the sole reference
  (is_last_ref = TRUE) and one of several (is_last_ref = FALSE).  Pascal has no
  garbage collector, so the callback itself is intentionally empty: the Pascal
  wrapper is the authoritative owner and its lifetime is managed explicitly.
  The callback must still exist so g_object_remove_toggle_ref can identify it. }
procedure ToggleNotify(data: gpointer; obj: gpointer; is_last_ref: gboolean); cdecl;
begin
end;

var
  FWrapperQuark: GQuark = 0;

type
  TPasTypeEntry = record
    PasClass : TClass;
    GTypeVal : GType;
  end;

var
  PasTypeReg      : array of TPasTypeEntry;
  PasTypeRegCount : Integer = 0;

function WrapperQuark: GQuark;
begin
  if FWrapperQuark = 0 then
    FWrapperQuark := GLibFFI.g_quark_from_static_string('pascal-gobject-wrapper');
  Result := FWrapperQuark;
end;

procedure PasClassInit(klass: Pointer; class_data: Pointer); cdecl;
var
  ObjClass    : PGObjectClass;
  PasClass    : TGObjectClass;
begin
  ObjClass := PGObjectClass(klass);
  ObjClass^.set_property := @PasSetProperty;
  ObjClass^.get_property := @PasGetProperty;
  ObjClass^.dispose      := @PasDispose;
  ObjClass^.finalize     := @PasFinalize;
  if class_data <> nil then
  begin
    PasClass := TGObjectClass(class_data);
    PasClass.ClassSetup(ObjClass);
  end;
end;

procedure PasInstanceInit(instance: PGTypeInstance; klass: Pointer); cdecl;
begin
end;

procedure PasDispose(obj: Pointer); cdecl;
var
  Wrapper     : TGObject;
  ParentClass : PGObjectClass;
begin
  Wrapper := TGObject(GObjectFFI.g_object_get_qdata(PGObjectC(obj), WrapperQuark));
  if Wrapper <> nil then
    Wrapper.DoDispose;
  ParentClass := PGObjectClass(GObjectFFI.g_type_class_peek_parent(
    PGObjectC(obj)^.g_type_instance.g_class));
  if Assigned(ParentClass) and Assigned(ParentClass^.dispose) then
    ParentClass^.dispose(obj);
end;

procedure PasFinalize(obj: Pointer); cdecl;
var
  Wrapper     : TGObject;
  ParentClass : PGObjectClass;
begin
  Wrapper := TGObject(GObjectFFI.g_object_get_qdata(PGObjectC(obj), WrapperQuark));
  if Wrapper <> nil then
  begin
    Wrapper.FHandle := nil;
    Wrapper.FOwned  := False;
    GObjectFFI.g_object_set_qdata(PGObjectC(obj), WrapperQuark, nil);
    Wrapper.DoFinalize;
    Wrapper.Free;
  end;
  ParentClass := PGObjectClass(GObjectFFI.g_type_class_peek_parent(
    PGObjectC(obj)^.g_type_instance.g_class));
  if Assigned(ParentClass) and Assigned(ParentClass^.finalize) then
    ParentClass^.finalize(obj);
end;

procedure PasGetProperty(obj: Pointer; id: guint; val: Pointer; spec: Pointer); cdecl;
var
  Wrapper : TGObject;
  V       : TGValue;
begin
  Wrapper := TGObject(GObjectFFI.g_object_get_qdata(PGObjectC(obj), WrapperQuark));
  if Wrapper = nil then
    Exit;
  V := TGValue.Create;
  try
    V.InitFromRaw(PGValue(val)^);
    Wrapper.DoGetProp(id, V, PGParamSpec(spec));
  finally
    V.Free;
  end;
end;

procedure PasSetProperty(obj: Pointer; id: guint; const val: Pointer; spec: Pointer); cdecl;
var
  Wrapper : TGObject;
  V       : TGValue;
begin
  Wrapper := TGObject(GObjectFFI.g_object_get_qdata(PGObjectC(obj), WrapperQuark));
  if Wrapper = nil then
    Exit;
  V := TGValue.Create;
  try
    V.InitFromRaw(PGValue(val)^);
    Wrapper.DoSetProp(id, V, PGParamSpec(spec));
  finally
    V.Free;
  end;
end;

function PasGObjectGetOrRegister(APasClass: TGObjectClass): GType;
var
  I    : Integer;
  Info : GTypeInfo;
  TN   : string;
begin
  for I := 0 to PasTypeRegCount - 1 do
    if PasTypeReg[I].PasClass = TClass(APasClass) then
      Exit(PasTypeReg[I].GTypeVal);

  FillChar(Info, SizeOf(GTypeInfo), 0);
  Info.class_size    := SizeOf(GObjectClass);
  Info.class_init    := @PasClassInit;
  Info.class_data    := Pointer(APasClass);
  Info.instance_size := SizeOf(GObjectC);
  Info.instance_init := @PasInstanceInit;

  TN     := APasClass.TypeName;
  Result := GObjectFFI.g_type_register_static(APasClass.ParentGType,
    GLibStr(TN), @Info, GTypeFlags(0));

  if Length(PasTypeReg) <= PasTypeRegCount then
    SetLength(PasTypeReg, PasTypeRegCount + 16);
  PasTypeReg[PasTypeRegCount].PasClass := TClass(APasClass);
  PasTypeReg[PasTypeRegCount].GTypeVal := Result;
  Inc(PasTypeRegCount);
end;

procedure g_object_class_install_property(oclass: PGObjectClass; property_id: guint;
  pspec: PGParamSpec);
begin
  GObjectFFI.g_object_class_install_property(oclass, property_id, pspec);
end;

function g_object_class_find_property(oclass: PGObjectClass;
  property_name: pgchar): PGParamSpec;
begin
  Result := GObjectFFI.g_object_class_find_property(oclass, property_name);
end;

function g_object_new(object_type: GType; first_property_name: pgchar): PGObjectC;
begin
  Result := GObjectFFI.g_object_new(object_type, first_property_name);
end;

function g_object_ref(obj: gpointer): gpointer;
begin
  Result := GObjectFFI.g_object_ref(obj);
end;

procedure g_object_unref(obj: gpointer);
begin
  GObjectFFI.g_object_unref(obj);
end;

procedure g_value_set_int(value: PGValue; v_int: gint);
begin
  GObjectFFI.g_value_set_int(value, v_int);
end;

function g_value_get_int(const value: PGValue): gint;
begin
  Result := GObjectFFI.g_value_get_int(value);
end;

procedure g_value_set_string(value: PGValue; v_string: pgchar);
begin
  GObjectFFI.g_value_set_string(value, v_string);
end;

function g_value_get_string(const value: PGValue): pgchar;
begin
  Result := GObjectFFI.g_value_get_string(value);
end;

function g_quark_from_string(str: pgchar): GQuark;
begin
  Result := GLibFFI.g_quark_from_string(str);
end;

class function TGObject.TypeName: string;
begin
  Result := ClassName;
end;

class function TGObject.ParentGType: GType;
var
  ParentPas : TClass;
begin
  ParentPas := ClassParent;
  if (ParentPas = nil) or (ParentPas = TObject) then
    Exit(G_TYPE_OBJECT);
  Result := TGObjectClass(ParentPas).TypeID;
end;

class procedure TGObject.ClassSetup(AClass: PGObjectClass);
begin
end;

class function TGObject.TypeID: GType;
begin
  if Self = TGObject then
    Exit(G_TYPE_OBJECT);
  Result := PasGObjectGetOrRegister(TGObjectClass(Self));
end;

class function TGObject.Take(AHandle: Pointer): TGObject;
var
  Existing: TGObject;
begin
  if AHandle = nil then
  begin
    Result := Self.NewInstance as TGObject;
    TGObject(Result).FHandle := nil;
    TGObject(Result).FOwned  := False;
    Exit;
  end;
  { GI requires at most one wrapper per native object.  If a wrapper already
    exists in qdata, return it and release the transfer:full reference we
    received — the existing wrapper's toggle ref covers ownership. }
  Existing := TGObject(GObjectFFI.g_object_get_qdata(PGObjectC(AHandle), WrapperQuark));
  if Existing <> nil then
  begin
    GObjectFFI.g_object_unref(AHandle);
    Exit(Existing);
  end;
  Result := Self.NewInstance as TGObject;
  TGObject(Result).FHandle := PGObjectC(AHandle);
  TGObject(Result).FOwned  := True;
  { Exchange the transfer:full plain ref for a toggle ref. }
  GObjectFFI.g_object_add_toggle_ref(AHandle, @ToggleNotify, Result);
  GObjectFFI.g_object_unref(AHandle);
  GObjectFFI.g_object_set_qdata(PGObjectC(AHandle), WrapperQuark, Result);
  Result.InstanceSetup;
end;

class function TGObject.Borrow(AHandle: Pointer): TGObject;
var
  Existing: TGObject;
begin
  if AHandle = nil then
  begin
    Result := Self.NewInstance as TGObject;
    TGObject(Result).FHandle := nil;
    TGObject(Result).FOwned  := False;
    Exit;
  end;
  { Return the existing wrapper when one is already registered. }
  Existing := TGObject(GObjectFFI.g_object_get_qdata(PGObjectC(AHandle), WrapperQuark));
  if Existing <> nil then
    Exit(Existing);
  Result := Self.NewInstance as TGObject;
  TGObject(Result).FHandle := PGObjectC(AHandle);
  TGObject(Result).FOwned  := True;
  { transfer:none: the caller retains their ref; add_toggle_ref acquires our own. }
  GObjectFFI.g_object_add_toggle_ref(AHandle, @ToggleNotify, Result);
  GObjectFFI.g_object_set_qdata(PGObjectC(AHandle), WrapperQuark, Result);
  Result.InstanceSetup;
end;

constructor TGObject.CreateFromHandle(AHandle: Pointer);
begin
  inherited Create;
  FOwned  := True;
  FHandle := PGObjectC(AHandle);
  if FHandle <> nil then
  begin
    { Check at runtime whether the handle is a floating reference
      (GInitiallyUnowned subclasses such as GtkWidget start floating).
      g_object_ref_sink sinks the float and keeps refcount at 1. }
    if Boolean(GObjectFFI.g_object_is_floating(AHandle)) then
      GObjectFFI.g_object_ref_sink(AHandle);
    GObjectFFI.g_object_add_toggle_ref(AHandle, @ToggleNotify, Self);
    GObjectFFI.g_object_unref(AHandle);
    GObjectFFI.g_object_set_qdata(PGObjectC(AHandle), WrapperQuark, Self);
    InstanceSetup;
  end;
end;

constructor TGObject.Create;
begin
  inherited Create;
  FOwned  := True;
  FHandle := GObjectFFI.g_object_new(TGObjectClass(Self.ClassType).TypeID, nil);
  if FHandle <> nil then
  begin
    { Sink floating reference if the type is GInitiallyUnowned (e.g. GtkWidget). }
    if Boolean(GObjectFFI.g_object_is_floating(FHandle)) then
      GObjectFFI.g_object_ref_sink(FHandle);
    GObjectFFI.g_object_add_toggle_ref(FHandle, @ToggleNotify, Self);
    GObjectFFI.g_object_unref(FHandle);
    GObjectFFI.g_object_set_qdata(FHandle, WrapperQuark, Self);
    InstanceSetup;
  end;
end;

destructor TGObject.Destroy;
begin
  if FOwned and (FHandle <> nil) then
  begin
    { Nil qdata first so that PasDispose/PasFinalize, which may be invoked
      synchronously inside remove_toggle_ref when refcount drops to zero,
      see no wrapper and skip the Pascal-level callbacks (avoiding double-free). }
    GObjectFFI.g_object_set_qdata(FHandle, WrapperQuark, nil);
    GObjectFFI.g_object_remove_toggle_ref(FHandle, @ToggleNotify, Self);
  end;
  FHandle := nil;
  inherited;
end;

procedure TGObject.InstanceSetup;
begin
end;

procedure TGObject.DoDispose;
begin
end;

procedure TGObject.DoFinalize;
begin
end;

procedure TGObject.DoGetProp(id: guint; val: TGValue; spec: PGParamSpec);
begin
end;

procedure TGObject.DoSetProp(id: guint; const val: TGValue; spec: PGParamSpec);
begin
end;

function TGObject.GetHandleTypeID: GType;
begin
  if (FHandle <> nil) and (FHandle^.g_type_instance.g_class <> nil) then
    Result := FHandle^.g_type_instance.g_class^.g_type
  else
    Result := G_TYPE_INVALID;
end;

function TGObject.GetRefCount: guint;
begin
  if FHandle <> nil then
    Result := FHandle^.ref_count
  else
    Result := 0;
end;

function TGObject.GetIsFloating: Boolean;
begin
  Result := (FHandle <> nil) and Boolean(GObjectFFI.g_object_is_floating(FHandle));
end;

procedure TGObject.Ref;
begin
  if FHandle <> nil then
    GObjectFFI.g_object_ref(FHandle);
end;

procedure TGObject.Unref;
begin
  if FHandle <> nil then
    GObjectFFI.g_object_unref(FHandle);
end;

procedure TGObject.RefSink;
begin
  if FHandle <> nil then
    GObjectFFI.g_object_ref_sink(FHandle);
end;

procedure TGObject.FreezeNotify;
begin
  if FHandle <> nil then
    GObjectFFI.g_object_freeze_notify(FHandle);
end;

procedure TGObject.ThawNotify;
begin
  if FHandle <> nil then
    GObjectFFI.g_object_thaw_notify(FHandle);
end;

procedure TGObject.Notify(const APropertyName: string);
begin
  if FHandle <> nil then
    GObjectFFI.g_object_notify(FHandle, GLibStr(APropertyName));
end;

function TGObject.GetProperty(const AName: string): TGValue;
var
  ObjClass : PGObjectClass;
  Spec     : PGParamSpec;
begin
  Result := TGValue.Create;
  if FHandle = nil then
    Exit;
  ObjClass := PGObjectClass(FHandle^.g_type_instance.g_class);
  Spec     := GObjectFFI.g_object_class_find_property(ObjClass, GLibStr(AName));
  if Spec = nil then
    Exit;
  Result.InitType(Spec^.value_type);
  GObjectFFI.g_object_get_property(FHandle, GLibStr(AName), Result.RawPtr);
end;

procedure TGObject.SetProperty(const AName: string; AValue: TGValue);
begin
  if FHandle <> nil then
    GObjectFFI.g_object_set_property(FHandle, GLibStr(AName), AValue.RawPtr);
end;

function TGObject.GetData(const AKey: string): gpointer;
begin
  if FHandle <> nil then
    Result := GObjectFFI.g_object_get_data(FHandle, GLibStr(AKey))
  else
    Result := nil;
end;

procedure TGObject.SetData(const AKey: string; AData: gpointer);
begin
  if FHandle <> nil then
    GObjectFFI.g_object_set_data(FHandle, GLibStr(AKey), AData);
end;

procedure TGObject.SetDataFull(const AKey: string; AData: gpointer;
  ADestroyFunc: GDestroyNotify);
begin
  if FHandle <> nil then
    GObjectFFI.g_object_set_data_full(FHandle, GLibStr(AKey), AData, ADestroyFunc);
end;

function TGObject.StealData(const AKey: string): gpointer;
begin
  if FHandle <> nil then
    Result := GObjectFFI.g_object_steal_data(FHandle, GLibStr(AKey))
  else
    Result := nil;
end;

function TGObject.GetQData(AQuark: GQuark): gpointer;
begin
  if FHandle <> nil then
    Result := GObjectFFI.g_object_get_qdata(FHandle, AQuark)
  else
    Result := nil;
end;

procedure TGObject.SetQData(AQuark: GQuark; AData: gpointer);
begin
  if FHandle <> nil then
    GObjectFFI.g_object_set_qdata(FHandle, AQuark, AData);
end;

procedure TGObject.SetQDataFull(AQuark: GQuark; AData: gpointer;
  ADestroy: GDestroyNotify);
begin
  if FHandle <> nil then
    GObjectFFI.g_object_set_qdata_full(FHandle, AQuark, AData, ADestroy);
end;

function TGObject.StealQData(AQuark: GQuark): gpointer;
begin
  if FHandle <> nil then
    Result := GObjectFFI.g_object_steal_qdata(FHandle, AQuark)
  else
    Result := nil;
end;

end.
