{ Pascal-GObject example: Hello GObject
  Demonstrates basic object creation, Take/Borrow ownership semantics,
  signal connection with a function pointer callback, data attachment
  via qdata, and reference counting. }
program hello_gobject;

{$mode objfpc}{$H+}

uses
  GTypes, GLib, GObjectType, GValue, GParam, GObject, GSignal, PasGObject;

procedure OnNotify(gobject: PGObjectC; pspec: PGParamSpec; data: gpointer); cdecl;
begin
  WriteLn('  [notify] property changed: ', PasStr(pspec^.name));
end;

var
  Obj       : TGObject;
  HandlerID : gulong;
  Q         : GQuark;
  Raw       : PGObjectC;
begin
  WriteLn('Pascal-GObject - Hello GObject example');
  WriteLn('');

  g_type_init;

  WriteLn('--- Creating with TGObject.Create ---');
  Obj := TGObject.Create;
  WriteLn('  type name  : ', GTypeName(Obj.TypeID_));
  WriteLn('  ref count  : ', Obj.RefCount);
  WriteLn('  is floating: ', Obj.IsFloating);
  Obj.Free;

  WriteLn('');
  WriteLn('--- Take (transfer:full) semantics ---');
  Obj := TGObject.Take(g_object_new(G_TYPE_OBJECT, nil));
  WriteLn('  ref count after Take: ', Obj.RefCount);
  Obj.Free;

  WriteLn('');
  WriteLn('--- Borrow (transfer:none) semantics ---');
  Raw := PGObjectC(g_object_new(G_TYPE_OBJECT, nil));
  WriteLn('  ref count before Borrow: ', Raw^.ref_count);
  Obj := TGObject.Borrow(Raw);
  WriteLn('  ref count after Borrow : ', Obj.RefCount);
  Obj.Free;
  g_object_unref(Raw);

  WriteLn('');
  WriteLn('--- Signal connection ---');
  Obj := TGObject.Create;
  HandlerID := SignalConnect(Obj, 'notify', @OnNotify, nil);
  WriteLn('  connected notify (handler id ', HandlerID, ')');
  WriteLn('  is connected: ', SignalIsConnected(Obj, HandlerID));
  SignalDisconnect(Obj, HandlerID);
  WriteLn('  after disconnect: ', SignalIsConnected(Obj, HandlerID));
  Obj.Free;

  WriteLn('');
  WriteLn('--- QData attachment ---');
  Obj := TGObject.Create;
  Q   := g_quark_from_string('answer');
  Obj.SetQData(Q, Pointer(42));
  WriteLn('  qdata[answer] = ', PtrUInt(Obj.GetQData(Q)));
  WriteLn('  steal: ', PtrUInt(Obj.StealQData(Q)));
  WriteLn('  after steal: ', PtrUInt(Obj.GetQData(Q)));
  Obj.Free;

  WriteLn('');
  WriteLn('--- Reference counting ---');
  Obj := TGObject.Create;
  WriteLn('  initial ref count: ', Obj.RefCount);
  Obj.Ref;
  WriteLn('  after Ref: ', Obj.RefCount);
  Obj.Unref;
  WriteLn('  after Unref: ', Obj.RefCount);
  Obj.Free;

  WriteLn('');
  WriteLn('Done.');
end.
