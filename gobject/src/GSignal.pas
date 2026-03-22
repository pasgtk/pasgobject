{ Pascal-GObject - Pascal bindings for the GObject type system
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GSignal - Signal system with Pascal method callback support.

  Pascal-level helpers accept TGObject and handle nil-safety.
  SignalConnectMethod supports "of object" callbacks via a heap-allocated
  TGSignalMethodData record that is freed automatically by GClosureNotify. }
unit GSignal;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes, GObjectType, GValue, GObject;

const
  G_SIGNAL_RUN_FIRST    = guint(1 shl 0);
  G_SIGNAL_RUN_LAST     = guint(1 shl 1);
  G_SIGNAL_RUN_CLEANUP  = guint(1 shl 2);
  G_SIGNAL_NO_RECURSE   = guint(1 shl 3);
  G_SIGNAL_DETAILED     = guint(1 shl 4);
  G_SIGNAL_ACTION       = guint(1 shl 5);
  G_SIGNAL_NO_HOOKS     = guint(1 shl 6);
  G_SIGNAL_MUST_COLLECT = guint(1 shl 7);
  G_SIGNAL_DEPRECATED   = guint(1 shl 8);

  G_CONNECT_DEFAULT = GConnectFlags(0);
  G_CONNECT_AFTER   = GConnectFlags(1 shl 0);
  G_CONNECT_SWAPPED = GConnectFlags(1 shl 1);

type
  { TGSignalCallback is the "of object" method signature for SignalConnectMethod.
    ASender is the TGObject wrapper retrieved from qdata;
    AUserData is the extra pointer supplied at connect time. }
  TGSignalCallback = procedure(ASender: TGObject; AUserData: Pointer) of object;

  TGSignalMethodData = record
    Callback : TGSignalCallback;
    UserData : Pointer;
  end;
  PGSignalMethodData = ^TGSignalMethodData;

{ g_signal_connect is the standard convenience wrapper around
  g_signal_connect_data with no after/swapped flags. }
function g_signal_connect(instance: gpointer; const detailed_signal: pgchar;
  c_handler: gpointer; data: gpointer): gulong;

{ g_signal_lookup, g_signal_name, g_signal_query re-exported for callers
  that prefer not to depend on GObjectFFI directly. }
function g_signal_lookup(name: pgchar; itype: GType): guint;
function g_signal_name(signal_id: guint): pgchar;
procedure g_signal_query(signal_id: guint; query: PGSignalQuery);

{ SignalConnect connects ACallback to ASignal on AObject (runs before default). }
function SignalConnect(AObject: TGObject; const ASignal: string;
  ACallback: gpointer; AData: gpointer = nil): gulong;

{ SignalConnectAfter connects ACallback to run after the default handler. }
function SignalConnectAfter(AObject: TGObject; const ASignal: string;
  ACallback: gpointer; AData: gpointer = nil): gulong;

{ SignalDisconnect removes the handler identified by AHandlerID. }
procedure SignalDisconnect(AObject: TGObject; AHandlerID: gulong);

{ SignalBlock temporarily suppresses delivery of AHandlerID. }
procedure SignalBlock(AObject: TGObject; AHandlerID: gulong);

{ SignalUnblock re-enables a previously blocked handler. }
procedure SignalUnblock(AObject: TGObject; AHandlerID: gulong);

{ SignalIsConnected returns True when AHandlerID is still connected. }
function SignalIsConnected(AObject: TGObject; AHandlerID: gulong): Boolean;

{ SignalEmit emits ASignal on AObject with no extra parameters. }
procedure SignalEmit(AObject: TGObject; const ASignal: string);

{ SignalConnectMethod connects an "of object" method callback.
  The closure data is heap-allocated and freed automatically when the
  signal handler is disconnected. }
function SignalConnectMethod(AObject: TGObject; const ASignal: string;
  ACallback: TGSignalCallback; AData: Pointer = nil): gulong;

implementation

uses GObjectFFI, GLib;

function g_signal_connect(instance: gpointer; const detailed_signal: pgchar;
  c_handler: gpointer; data: gpointer): gulong;
begin
  Result := GObjectFFI.g_signal_connect_data(instance, detailed_signal, c_handler,
    data, nil, G_CONNECT_DEFAULT);
end;

function g_signal_lookup(name: pgchar; itype: GType): guint;
begin
  Result := GObjectFFI.g_signal_lookup(name, itype);
end;

function g_signal_name(signal_id: guint): pgchar;
begin
  Result := GObjectFFI.g_signal_name(signal_id);
end;

procedure g_signal_query(signal_id: guint; query: PGSignalQuery);
begin
  GObjectFFI.g_signal_query(signal_id, query);
end;

function SignalConnect(AObject: TGObject; const ASignal: string;
  ACallback: gpointer; AData: gpointer): gulong;
begin
  if (AObject = nil) or (AObject.Handle = nil) then
    Exit(0);
  Result := GObjectFFI.g_signal_connect_data(AObject.Handle, GLibStr(ASignal),
    ACallback, AData, nil, G_CONNECT_DEFAULT);
end;

function SignalConnectAfter(AObject: TGObject; const ASignal: string;
  ACallback: gpointer; AData: gpointer): gulong;
begin
  if (AObject = nil) or (AObject.Handle = nil) then
    Exit(0);
  Result := GObjectFFI.g_signal_connect_data(AObject.Handle, GLibStr(ASignal),
    ACallback, AData, nil, G_CONNECT_AFTER);
end;

procedure SignalDisconnect(AObject: TGObject; AHandlerID: gulong);
begin
  if (AObject = nil) or (AObject.Handle = nil) or (AHandlerID = 0) then
    Exit;
  GObjectFFI.g_signal_handler_disconnect(AObject.Handle, AHandlerID);
end;

procedure SignalBlock(AObject: TGObject; AHandlerID: gulong);
begin
  if (AObject = nil) or (AObject.Handle = nil) or (AHandlerID = 0) then
    Exit;
  GObjectFFI.g_signal_handler_block(AObject.Handle, AHandlerID);
end;

procedure SignalUnblock(AObject: TGObject; AHandlerID: gulong);
begin
  if (AObject = nil) or (AObject.Handle = nil) or (AHandlerID = 0) then
    Exit;
  GObjectFFI.g_signal_handler_unblock(AObject.Handle, AHandlerID);
end;

function SignalIsConnected(AObject: TGObject; AHandlerID: gulong): Boolean;
begin
  if (AObject = nil) or (AObject.Handle = nil) or (AHandlerID = 0) then
    Exit(False);
  Result := Boolean(GObjectFFI.g_signal_handler_is_connected(AObject.Handle, AHandlerID));
end;

procedure SignalEmit(AObject: TGObject; const ASignal: string);
var
  SID : guint;
begin
  if (AObject = nil) or (AObject.Handle = nil) then
    Exit;
  SID := GObjectFFI.g_signal_lookup(GLibStr(ASignal), AObject.TypeID_);
  if SID > 0 then
    GObjectFFI.g_signal_emit(AObject.Handle, SID, 0);
end;

{ MethodClosureMarshal is the GClosureMarshal used by SignalConnectMethod.
  It is called by GLib for every emission regardless of signal parameters.
  param_values[0] is always the instance; the MD pointer is stored in
  closure->data which is accessible at a fixed offset in the GClosure struct
  (on all platforms: after the bitfield word, the marshal pointer, comes data).
  We access it safely by reading from the raw closure bytes. }

type
  PGClosureInternal = ^TGClosureInternal;
  TGClosureInternal = record
    Flags    : guint;    { all bitfields packed into one 32-bit word }
    Marshal  : gpointer; { GClosureMarshal; compiler inserts natural alignment
                           padding before this field: 4 bytes on 64-bit,
                           0 bytes on 32-bit, matching sizeof(GClosure) }
    Data     : gpointer; { user_data from g_closure_new_simple }
    Notifiers: gpointer; { GClosureNotifyData* }
  end;

procedure MethodClosureMarshal(closure: PGClosure; return_value: gpointer;
  n_param_values: guint; param_values: gpointer; invocation_hint: gpointer;
  marshal_data: gpointer); cdecl;
var
  IC      : PGClosureInternal;
  RawInst : gpointer;
  Wrapper : TGObject;
  MD      : PGSignalMethodData;
  PVals   : PGValue;
begin
  if n_param_values < 1 then
    Exit;
  IC      := PGClosureInternal(closure);
  MD      := PGSignalMethodData(IC^.Data);
  if (MD = nil) or not Assigned(MD^.Callback) then
    Exit;
  PVals   := PGValue(param_values);
  RawInst := PVals^.data[0].v_pointer;
  Wrapper := TGObject(GObjectFFI.g_object_get_qdata(PGObjectC(RawInst), WrapperQuark));
  MD^.Callback(Wrapper, MD^.UserData);
end;

procedure MethodCallbackCleanup(data: gpointer; closure: PGClosure); cdecl;
begin
  if data <> nil then
    Dispose(PGSignalMethodData(data));
end;

function SignalConnectMethod(AObject: TGObject; const ASignal: string;
  ACallback: TGSignalCallback; AData: Pointer): gulong;
var
  MD      : PGSignalMethodData;
  Closure : PGClosure;
begin
  if (AObject = nil) or (AObject.Handle = nil) then
    Exit(0);
  New(MD);
  MD^.Callback := ACallback;
  MD^.UserData := AData;
  { g_closure_new_simple stores MD as closure->data.  A finalize notifier
    calls MethodCallbackCleanup when the closure is collected.
    MethodClosureMarshal reads MD back from the same closure->data field. }
  Closure := GObjectFFI.g_closure_new_simple(SizeOf(TGClosureInternal), MD);
  GObjectFFI.g_closure_add_finalize_notifier(Closure, MD, @MethodCallbackCleanup);
  GObjectFFI.g_closure_set_marshal(Closure, @MethodClosureMarshal);
  { g_signal_connect_closure is transfer:full — it takes ownership of the
    closure reference (refcount=1 from g_closure_new_simple).  When the
    signal handler is disconnected the signal system calls g_closure_unref,
    refcount reaches 0, and MethodCallbackCleanup frees MD. }
  Result := GObjectFFI.g_signal_connect_closure(AObject.Handle, GLibStr(ASignal),
    Closure, False);
end;

end.
