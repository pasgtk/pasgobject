# GValue

**Unit:** `GValue`
**File:** `gobject/src/GValue.pas`
**Depends on:** `GTypes`, `GObjectType`, `GObjectFFI`

`TGValue` is a Pascal wrapper around the generic `GValue` container used by the
GObject property system and signal marshalling.

## Overview

`GValue` can hold any GType-registered value. `TGValue` manages the lifecycle
(init/unset) automatically and provides typed read/write accessors.

There are two modes:

- **Owned mode**: `TGValue.Create` or `TGValue.InitType`. The wrapper owns the
  `GValue` struct, and `Destroy` calls `g_value_unset`.
- **External mode**: `TGValue.InitFromRaw`. The wrapper holds a pointer to an
  existing `GValue` struct owned by GLib (e.g. the struct passed into
  `DoGetProp` / `DoSetProp`). Writes go directly to that struct; `Destroy` does
  not unset it.

## Constructor

```pascal
constructor TGValue.Create;
```

Creates an uninitialized value. Call one of the `Init*` methods before reading
or writing.

## Initialization methods

All `Init*` methods set the GType and prepare the value for read/write.
Calling a second `Init*` on an already-initialized owned value calls
`g_value_unset` first.

```pascal
procedure InitType(AType: GType);      { generic, for any GType }
procedure InitBoolean(AValue: Boolean = False);
procedure InitInt(AValue: gint = 0);
procedure InitUInt(AValue: guint = 0);
procedure InitInt64(AValue: gint64 = 0);
procedure InitUInt64(AValue: guint64 = 0);
procedure InitFloat(AValue: gfloat = 0);
procedure InitDouble(AValue: gdouble = 0);
procedure InitString(const AValue: string = '');
procedure InitObject(AObject: TObject = nil);
procedure InitPointer(APtr: gpointer = nil);
procedure InitEnum(AType: GType; AValue: gint = 0);
procedure InitFlags(AType: GType; AValue: guint = 0);
```

### InitFromRaw

```pascal
procedure InitFromRaw(var ARaw: GTypes.GValue);
```

Switches the wrapper to external mode, pointing at `ARaw`. Used inside
`DoGetProp` and `DoSetProp` to write/read the `GValue` that GLib provides:

```pascal
procedure TMyObj.DoGetProp(id: guint; val: TGValue; spec: PGParamSpec);
begin
  case id of
    PROP_NAME: val.InitString(FName);   { writes into GLib's GValue }
  end;
end;
```

## Read accessors

```pascal
function AsBoolean: Boolean;
function AsInt:     gint;
function AsUInt:    guint;
function AsInt64:   gint64;
function AsUInt64:  guint64;
function AsFloat:   gfloat;
function AsDouble:  gdouble;
function AsString:  string;
function AsObject:  gpointer;
function AsPointer: gpointer;
function AsEnum:    gint;
function AsFlags:   guint;
```

## Utilities

### CopyFrom

```pascal
procedure CopyFrom(ASrc: TGValue);
```

Copies value and type from `ASrc` via `g_value_copy`. Both values must be
initialized with compatible types.

### Transform

```pascal
function Transform(ADest: TGValue): Boolean;
```

Attempts a type conversion via `g_value_transform`. Returns `True` on success.

### TypeID / TypeName / IsInitialized

```pascal
function TypeID: GType;
function TypeName: string;
function IsInitialized: Boolean;
```

### RawPtr

```pascal
property RawPtr: PGValue;
```

Returns a pointer to the underlying `GValue` struct. Used internally; prefer
the typed accessors in application code.

## Example

```pascal
var V: TGValue;
begin
  V := TGValue.Create;
  V.InitInt(42);
  WriteLn(V.AsInt);   { 42 }
  V.Free;
end;
```
