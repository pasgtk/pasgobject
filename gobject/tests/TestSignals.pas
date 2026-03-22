{ Pascal-GObject test: Signal system
  Exercises signal lookup, connect/disconnect, block/unblock,
  nil-safety of Pascal helpers, GSignalQuery, and SignalConnectMethod
  with an "of object" method callback. }
program TestSignals;

{$mode objfpc}{$H+}

uses
  GTypes, GLib, GObjectType, GValue, GParam, GObject, GSignal, PasGObject;

var
  Passed          : Integer = 0;
  Failed          : Integer = 0;
  NotifyCallCount : Integer = 0;
  MethodCallCount : Integer = 0;

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

procedure OnNotify(gobject: PGObjectC; pspec: PGParamSpec; data: gpointer); cdecl;
begin
  Inc(NotifyCallCount);
end;

procedure TestSignalLookup;
var
  SID : guint;
  Obj : TGObject;
begin
  WriteLn('Signal lookup');
  { Creating and freeing one instance forces GObject class initialisation,
    which registers the built-in signals (notify, etc.) before we look them up. }
  Obj := TGObject.Create;
  Obj.Free;
  SID := g_signal_lookup('notify', G_TYPE_OBJECT);
  Check(SID > 0,                              'notify signal exists on G_TYPE_OBJECT');
  Check(PasStr(g_signal_name(SID)) = 'notify','g_signal_name round-trip');
  Check(g_signal_lookup('no-such-signal-xyz', G_TYPE_OBJECT) = 0,
    'unknown signal returns 0');
end;

procedure TestSignalConnect;
var
  Obj : TGObject;
  HID : gulong;
begin
  WriteLn('SignalConnect / SignalDisconnect');
  Obj := TGObject.Create;
  try
    NotifyCallCount := 0;
    HID := SignalConnect(Obj, 'notify', @OnNotify, nil);
    Check(HID > 0,                         'SignalConnect returns valid ID');
    Check(SignalIsConnected(Obj, HID),     'Handler is connected after connect');
    SignalDisconnect(Obj, HID);
    Check(not SignalIsConnected(Obj, HID), 'Handler is disconnected after disconnect');
  finally
    Obj.Free;
  end;
end;

procedure TestSignalConnectAfter;
var
  Obj       : TGObject;
  HID1, HID2: gulong;
begin
  WriteLn('SignalConnectAfter');
  Obj := TGObject.Create;
  try
    HID1 := SignalConnect(Obj, 'notify', @OnNotify, nil);
    HID2 := SignalConnectAfter(Obj, 'notify', @OnNotify, nil);
    Check(HID1 > 0,                        'First handler ID valid');
    Check(HID2 > 0,                        'After handler ID valid');
    Check(HID1 <> HID2,                    'IDs are distinct');
    Check(SignalIsConnected(Obj, HID1),    'First handler connected');
    Check(SignalIsConnected(Obj, HID2),    'After handler connected');
    SignalDisconnect(Obj, HID1);
    SignalDisconnect(Obj, HID2);
  finally
    Obj.Free;
  end;
end;

procedure TestSignalBlock;
var
  Obj : TGObject;
  HID : gulong;
begin
  WriteLn('SignalBlock / SignalUnblock');
  Obj := TGObject.Create;
  try
    HID := SignalConnect(Obj, 'notify', @OnNotify, nil);
    SignalBlock(Obj, HID);
    Check(SignalIsConnected(Obj, HID), 'Still connected after block');
    SignalUnblock(Obj, HID);
    Check(SignalIsConnected(Obj, HID), 'Still connected after unblock');
    SignalDisconnect(Obj, HID);
  finally
    Obj.Free;
  end;
end;

procedure TestNilSafety;
var
  Obj : TGObject;
  HID : gulong;
begin
  WriteLn('Nil-safety of Pascal helpers');
  Obj := TGObject.Create;
  try
    HID := SignalConnect(Obj, 'notify', @OnNotify, nil);
    SignalDisconnect(Obj, 0);
    Check(True, 'SignalDisconnect(0) does not crash');
    SignalBlock(Obj, 0);
    Check(True, 'SignalBlock(0) does not crash');
    SignalUnblock(Obj, 0);
    Check(True, 'SignalUnblock(0) does not crash');
    Check(not SignalIsConnected(Obj, 0), 'SignalIsConnected(0) = false');
    Check(SignalConnect(nil, 'notify', @OnNotify) = 0,
      'SignalConnect(nil object) = 0');
    SignalDisconnect(Obj, HID);
  finally
    Obj.Free;
  end;
end;

procedure TestSignalQuery;
var
  SID   : guint;
  Query : GSignalQuery;
begin
  WriteLn('g_signal_query');
  SID := g_signal_lookup('notify', G_TYPE_OBJECT);
  g_signal_query(SID, @Query);
  Check(Query.signal_id = SID,                 'Query signal_id matches');
  Check(PasStr(Query.signal_name) = 'notify',  'Query signal_name = notify');
  Check(Query.itype = G_TYPE_OBJECT,           'Query itype = G_TYPE_OBJECT');
end;

type
  TMethodReceiver = class
    CallCount : Integer;
    LastData  : Pointer;
    procedure OnSignal(ASender: TGObject; AUserData: Pointer);
  end;

procedure TMethodReceiver.OnSignal(ASender: TGObject; AUserData: Pointer);
begin
  Inc(CallCount);
  LastData := AUserData;
  Inc(MethodCallCount);
end;

procedure TestSignalConnectMethod;
var
  Obj      : TGObject;
  Receiver : TMethodReceiver;
  HID      : gulong;
  CB       : TGSignalCallback;
begin
  WriteLn('SignalConnectMethod');
  Obj      := TGObject.Create;
  Receiver := TMethodReceiver.Create;
  try
    Receiver.CallCount := 0;
    CB  := @Receiver.OnSignal;
    HID := SignalConnectMethod(Obj, 'notify', CB, Pointer(55));
    Check(HID > 0,                        'SignalConnectMethod returns valid ID');
    Check(SignalIsConnected(Obj, HID),    'Method handler is connected');
    SignalDisconnect(Obj, HID);
    Check(not SignalIsConnected(Obj, HID),'Method handler disconnected');
  finally
    Receiver.Free;
    Obj.Free;
  end;
end;

begin
  WriteLn('=== TestSignals ===');
  WriteLn('');
  g_type_init;
  TestSignalLookup;
  WriteLn('');
  TestSignalConnect;
  WriteLn('');
  TestSignalConnectAfter;
  WriteLn('');
  TestSignalBlock;
  WriteLn('');
  TestNilSafety;
  WriteLn('');
  TestSignalQuery;
  WriteLn('');
  TestSignalConnectMethod;
  WriteLn('');
  WriteLn('Results: ', Passed, ' passed, ', Failed, ' failed');
  if Failed > 0 then
    Halt(1);
end.
