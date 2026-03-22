# GLib

**Unit:** `GLib`
**File:** `gobject/src/GLib.pas`
**Depends on:** `GTypes`, `GLibFFI`

Pascal-friendly wrappers around common GLib functions. Use these instead of the
raw FFI functions — they handle string encoding and nil-safety.

## String helpers

### GLibStr

```pascal
function GLibStr(const S: string): pgchar;
```

Converts a Pascal `string` to a `pgchar` pointer suitable for passing to C
functions. The returned pointer is valid for the lifetime of the Pascal string
expression — do **not** store it beyond the call.

```pascal
g_object_notify(Handle, GLibStr('my-property'));
```

### PasStr

```pascal
function PasStr(P: pgchar): string;
```

Converts a `pgchar` returned by a C function to a Pascal `string`. Handles
`nil` (returns `''`). Does **not** free the C string; if the C function
transfers ownership, you must call `g_free` separately.

### GLibStrDup

```pascal
function GLibStrDup(const S: string): pgchar;
```

Like `GLibStr` but allocates a `g_malloc` copy. The caller is responsible for
calling `g_free` on the result. Use this when the C function takes ownership
of the string (transfer:full parameters that are strings).

## Memory

```pascal
function  GLibAlloc(Size: gsize): gpointer;
function  GLibAlloc0(Size: gsize): gpointer;
procedure GLibFree(P: gpointer);
```

Thin wrappers around `g_malloc`, `g_malloc0`, and `g_free`. Prefer these over
calling FFI functions directly so the call site stays readable.

## List helpers

```pascal
procedure GLibStringListFree(List: PGList);
```

Frees a `GList` whose data pointers are GLib-allocated strings. Equivalent to
`g_list_free_full(list, g_free)`.

## Main loop

```pascal
function  GLibMainLoopNew(IsRunning: Boolean = False): PGMainLoop;
procedure GLibMainLoopRun(Loop: PGMainLoop);
procedure GLibMainLoopQuit(Loop: PGMainLoop);
procedure GLibMainLoopFree(Loop: PGMainLoop);
```

Wrappers for `g_main_loop_new`, `g_main_loop_run`, `g_main_loop_quit`, and
`g_main_loop_unref`. Typical usage:

```pascal
var Loop: PGMainLoop;
begin
  Loop := GLibMainLoopNew;
  { ... set up sources ... }
  GLibMainLoopRun(Loop);
  GLibMainLoopFree(Loop);
end;
```

## Timers and idle callbacks

```pascal
function GLibTimeoutAdd(Interval: guint; Func: GSourceFunc;
                        Data: gpointer = nil): guint;
function GLibTimeoutAddSeconds(Interval: guint; Func: GSourceFunc;
                               Data: gpointer = nil): guint;
function GLibIdleAdd(Func: GSourceFunc; Data: gpointer = nil): guint;
function GLibSourceRemove(Tag: guint): Boolean;
```

Wrappers for the GLib source system. Return the source tag ID. Pass the tag
to `GLibSourceRemove` to cancel before it fires.
