# GSignal

**Unit:** `GSignal`
**File:** `gobject/src/GSignal.pas`
**Depends on:** `GTypes`, `GObjectType`, `GValue`, `GObject`, `GObjectFFI`

Signal connection and management with Pascal `of object` method callbacks.

## Callback type

```pascal
TGSignalCallback = procedure(ASender: TGObject; AUserData: Pointer) of object;
```

`ASender` is the Pascal `TGObject` wrapper retrieved from the GObject's qdata
(set at construction time by `SetQData`). `AUserData` is the `AData` pointer
supplied at connect time.

> `TGSignalCallback` is an `of object` type. You cannot pass a standalone
> procedure — you must use a method of a class instance with
> `SignalConnectMethod`.

## SignalConnectMethod

```pascal
function SignalConnectMethod(AObject: TGObject; const ASignal: string;
  ACallback: TGSignalCallback; AData: Pointer = nil): gulong;
```

The primary way to connect Pascal callbacks to signals. Uses a `GClosure` with
a heap-allocated `TGSignalMethodData` record that stores the method pointer and
`AData`. The record is freed automatically by `GClosureNotify` when the signal
is disconnected or the object is destroyed.

```pascal
type
  TApp = class
    procedure OnClicked(ASender: TGObject; AUserData: Pointer);
  end;

var
  App: TApp;
  CB:  TGSignalCallback;
  ID:  gulong;
begin
  App := TApp.Create;
  CB  := @App.OnClicked;
  ID  := SignalConnectMethod(Button, 'clicked', CB, nil);
```

### Important: transfer:full on the closure

`g_signal_connect_closure` takes `transfer:full` ownership of the closure.
**Do not call `g_closure_unref` after `SignalConnectMethod`** — the signal
system frees the closure on disconnect.

## Other connect functions

```pascal
function SignalConnect(AObject: TGObject; const ASignal: string;
  AHandler: gpointer; AData: gpointer = nil): gulong;

function SignalConnectAfter(AObject: TGObject; const ASignal: string;
  ACallback: TGSignalCallback; AData: Pointer = nil): gulong;
```

`SignalConnect` uses a raw C function pointer (for FFI-level callbacks).
`SignalConnectAfter` connects with `G_CONNECT_AFTER` — the handler runs after
the object's default handler.

## Disconnect / block / unblock

```pascal
procedure SignalDisconnect(AObject: TGObject; AHandlerID: gulong);
procedure SignalBlock(AObject: TGObject; AHandlerID: gulong);
procedure SignalUnblock(AObject: TGObject; AHandlerID: gulong);
function  SignalIsConnected(AObject: TGObject; AHandlerID: gulong): Boolean;
```

All functions are nil-safe: passing a nil `AObject` or a zero `AHandlerID` is
a no-op.

## Emit

```pascal
procedure SignalEmit(AObject: TGObject; const ASignal: string);
```

Emits a signal with no parameters. For signals with parameters use
`g_signal_emit_by_name` from `GObjectFFI` directly.

## Low-level re-exports

```pascal
function g_signal_connect(instance: gpointer; const detailed_signal: pgchar;
  c_handler: gpointer; data: gpointer): gulong;

function g_signal_lookup(name: pgchar; itype: GType): guint;
function g_signal_name(signal_id: guint): pgchar;
procedure g_signal_query(signal_id: guint; query: PGSignalQuery);
```

Re-exported from `GObjectFFI` for callers that don't want to import `GObjectFFI`
directly.

## How method callbacks work internally

1. `SignalConnectMethod` allocates a `TGSignalMethodData` record on the heap
   containing the `TGSignalCallback` method pointer and `AData`.
2. It creates a `GClosure` via `g_closure_new_simple` with the record as
   user data.
3. Sets the closure marshal to `MethodCallbackMarshal`.
4. Sets a `GClosureNotify` (`MethodCallbackCleanup`) to free the record when
   the closure is finalized.
5. Passes the closure to `g_signal_connect_closure` (which takes ownership).

When the signal fires, GLib calls `MethodCallbackMarshal` which:
- Retrieves the Pascal wrapper for the sender via `g_object_get_qdata(WrapperQuark)`
- Calls the stored `TGSignalCallback` method with the wrapper and `AData`
