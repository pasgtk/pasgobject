{ Pascal-GObject test: GObject and GValue
  Exercises TGObject creation/destruction, reference counting,
  Take/Borrow ownership semantics, data attachment (string-keyed and
  quark-keyed), property access, and the TGValue wrapper. }
program TestGObject;

{$mode objfpc}{$H+}

uses
  GTypes, GLib, GObjectType, GValue, GParam, GObject, GSignal, PasGObject, SysUtils;

var
  Passed : Integer = 0;
  Failed : Integer = 0;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if ACondition then
  begin
    WriteLn('  PASS  ', AMessage);
    Inc(Passed);
  end
  else
  begin
    WriteLn('  FAIL  ', AMessage);
    Inc(Failed);
  end;
end;

procedure TestGTypeSystem;
begin
  WriteLn('GType system');
  Check(G_TYPE_OBJECT <> G_TYPE_INVALID,          'G_TYPE_OBJECT is valid');
  Check(GTypeName(G_TYPE_OBJECT) = 'GObject',     'G_TYPE_OBJECT name = GObject');
  Check(GTypeFromName('GObject') = G_TYPE_OBJECT,  'GTypeFromName round-trip');
  Check(GTypeIsA(G_TYPE_OBJECT, G_TYPE_OBJECT),   'GObject is-a GObject');
  Check(not GTypeIsA(G_TYPE_STRING, G_TYPE_OBJECT),'string is not-a GObject');
  Check(GTypeIsObject(G_TYPE_OBJECT),              'GTypeIsObject(G_TYPE_OBJECT)');
  Check(not GTypeIsObject(G_TYPE_INT),             'GTypeIsObject(G_TYPE_INT) = false');
  Check(GTypeDepth(G_TYPE_OBJECT) >= 1,            'G_TYPE_OBJECT depth >= 1');
end;

procedure TestTGObjectCreate;
var
  Obj : TGObject;
begin
  WriteLn('TGObject.Create / Destroy');
  Obj := TGObject.Create;
  try
    Check(Obj <> nil,                      'TGObject created');
    Check(Obj.Handle <> nil,               'Handle is not nil');
    Check(Obj.TypeID_ = G_TYPE_OBJECT,     'TypeID_ = G_TYPE_OBJECT');
    Check(Obj.RefCount >= 1,               'RefCount >= 1');
    Check(Obj.Owned,                       'Owned = true by default');
  finally
    Obj.Free;
  end;
end;

procedure TestTake;
var
  RawHandle : PGObjectC;
  Obj       : TGObject;
  RC        : guint;
begin
  WriteLn('TGObject.Take (transfer:full)');
  RawHandle := PGObjectC(g_object_new(G_TYPE_OBJECT, nil));
  RC := RawHandle^.ref_count;
  Obj := TGObject.Take(RawHandle);
  try
    Check(Obj.Handle = RawHandle,          'Take: Handle matches');
    Check(Obj.RefCount = RC,               'Take: no extra ref added');
    Check(Obj.Owned,                       'Take: Owned = true');
  finally
    Obj.Free;
  end;
end;

procedure TestBorrow;
var
  RawHandle : PGObjectC;
  Obj       : TGObject;
  RC        : guint;
begin
  WriteLn('TGObject.Borrow (transfer:none)');
  RawHandle := PGObjectC(g_object_new(G_TYPE_OBJECT, nil));
  RC := RawHandle^.ref_count;
  Obj := TGObject.Borrow(RawHandle);
  try
    Check(Obj.Handle = RawHandle,          'Borrow: Handle matches');
    Check(Obj.RefCount = RC + 1,           'Borrow: ref count incremented');
  finally
    Obj.Free;
    g_object_unref(RawHandle);
  end;
end;

procedure TestRefCounting;
var
  Obj          : TGObject;
  InitRefCount : guint;
begin
  WriteLn('Reference counting');
  Obj := TGObject.Create;
  try
    InitRefCount := Obj.RefCount;
    Obj.Ref;
    Check(Obj.RefCount = InitRefCount + 1, 'Ref increments count');
    Obj.Unref;
    Check(Obj.RefCount = InitRefCount,     'Unref decrements count');
  finally
    Obj.Free;
  end;
end;

procedure TestDataAttachment;
var
  Obj : TGObject;
begin
  WriteLn('String-keyed data attachment');
  Obj := TGObject.Create;
  try
    Obj.SetData('key-42', Pointer(42));
    Check(PtrUInt(Obj.GetData('key-42')) = 42, 'SetData/GetData round-trip');
    Check(Obj.GetData('missing') = nil,         'Missing key returns nil');
    Check(Obj.StealData('key-42') = Pointer(42),'StealData returns value');
    Check(Obj.GetData('key-42') = nil,          'Stolen key is gone');
  finally
    Obj.Free;
  end;
end;

procedure TestQDataAttachment;
var
  Obj : TGObject;
  Q   : GQuark;
begin
  WriteLn('Quark-keyed data attachment');
  Obj := TGObject.Create;
  Q   := g_quark_from_string('test-quark');
  try
    Obj.SetQData(Q, Pointer(77));
    Check(PtrUInt(Obj.GetQData(Q)) = 77, 'SetQData/GetQData round-trip');
    Check(PtrUInt(Obj.StealQData(Q)) = 77, 'StealQData returns value');
    Check(Obj.GetQData(Q) = nil,           'Stolen quark key is gone');
  finally
    Obj.Free;
  end;
end;

procedure TestFreezeThaw;
var
  Obj : TGObject;
begin
  WriteLn('Freeze/thaw notify');
  Obj := TGObject.Create;
  try
    Obj.FreezeNotify;
    Obj.ThawNotify;
    Check(True, 'FreezeNotify / ThawNotify do not crash');
  finally
    Obj.Free;
  end;
end;

procedure TestTGValue;
var
  V : TGValue;
begin
  WriteLn('TGValue');

  V := TGValue.Create;
  try
    Check(not V.IsInitialized, 'Freshly created value is not initialized');
    V.InitInt(99);
    Check(V.IsInitialized,        'InitInt marks as initialized');
    Check(V.TypeID = G_TYPE_INT,  'TypeID = G_TYPE_INT after InitInt');
    Check(V.AsInt  = 99,          'AsInt = 99');
    Check(V.TypeName = 'gint',    'TypeName = gint');
  finally
    V.Free;
  end;

  V := TGValue.Create;
  try
    V.InitBoolean(True);
    Check(V.TypeID    = G_TYPE_BOOLEAN, 'TypeID = G_TYPE_BOOLEAN');
    Check(V.AsBoolean = True,           'AsBoolean = True');
    V.InitBoolean(False);
    Check(V.AsBoolean = False,          'Re-init to False works');
  finally
    V.Free;
  end;

  V := TGValue.Create;
  try
    V.InitString('hello world');
    Check(V.TypeID   = G_TYPE_STRING,  'TypeID = G_TYPE_STRING');
    Check(V.AsString = 'hello world',  'AsString round-trip');
  finally
    V.Free;
  end;

  V := TGValue.Create;
  try
    V.InitDouble(3.14159);
    Check(V.TypeID = G_TYPE_DOUBLE,            'TypeID = G_TYPE_DOUBLE');
    Check(Abs(V.AsDouble - 3.14159) < 1e-10,   'AsDouble preserves precision');
  finally
    V.Free;
  end;

  V := TGValue.Create;
  try
    V.InitInt64(High(Int64));
    Check(V.TypeID  = G_TYPE_INT64, 'TypeID = G_TYPE_INT64');
    Check(V.AsInt64 = High(Int64),  'AsInt64 = High(Int64)');
  finally
    V.Free;
  end;

  V := TGValue.Create;
  try
    V.InitPointer(Pointer($DEADBEEF));
    Check(V.AsPointer = Pointer($DEADBEEF), 'Pointer round-trip');
  finally
    V.Free;
  end;

  V := TGValue.Create;
  try
    V.InitUInt(High(Cardinal));
    Check(V.TypeID = G_TYPE_UINT,          'TypeID = G_TYPE_UINT');
    Check(V.AsUInt = High(Cardinal),       'AsUInt = High(Cardinal)');
  finally
    V.Free;
  end;

  V := TGValue.Create;
  try
    V.InitFloat(1.5);
    Check(V.TypeID = G_TYPE_FLOAT,         'TypeID = G_TYPE_FLOAT');
    Check(Abs(V.AsFloat - 1.5) < 1e-6,    'AsFloat round-trip');
  finally
    V.Free;
  end;
end;

procedure TestTGValueCopy;
var
  Src, Dst : TGValue;
begin
  WriteLn('TGValue.CopyFrom');
  Src := TGValue.Create;
  Dst := TGValue.Create;
  try
    Src.InitInt(1234);
    Dst.CopyFrom(Src);
    Check(Dst.TypeID = G_TYPE_INT, 'CopyFrom copies type');
    Check(Dst.AsInt  = 1234,       'CopyFrom copies value');
  finally
    Src.Free;
    Dst.Free;
  end;
end;

procedure TestWrapperQuark;
begin
  WriteLn('WrapperQuark');
  Check(WrapperQuark <> 0,           'WrapperQuark is non-zero');
  Check(WrapperQuark = WrapperQuark, 'WrapperQuark is stable across calls');
end;

begin
  WriteLn('=== TestGObject ===');
  WriteLn('');
  g_type_init;
  TestGTypeSystem;
  WriteLn('');
  TestTGObjectCreate;
  WriteLn('');
  TestTake;
  WriteLn('');
  TestBorrow;
  WriteLn('');
  TestRefCounting;
  WriteLn('');
  TestDataAttachment;
  WriteLn('');
  TestQDataAttachment;
  WriteLn('');
  TestFreezeThaw;
  WriteLn('');
  TestTGValue;
  WriteLn('');
  TestTGValueCopy;
  WriteLn('');
  TestWrapperQuark;
  WriteLn('');
  WriteLn('Results: ', Passed, ' passed, ', Failed, ' failed');
  if Failed > 0 then
    Halt(1);
end.
