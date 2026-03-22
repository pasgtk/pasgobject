# GObject

**Unit:** `GObject`
**File:** `gobject/src/GObject.pas`
**Depends on:** `GTypes`, `GLib`, `GObjectType`, `GValue`, `GParam`, `GLibFFI`, `GObjectFFI`

`TGObject` is the base Pascal class for all GObject wrappers. Every GTK widget
and most GLib/GIO types ultimately inherit from it.

## Ownership semantics

Three class functions control how a Pascal wrapper is created around an existing
GObject C pointer:

| Method | GI transfer | Description |
|---|---|---|
| `TGObject.Create` | — | Calls `g_object_new`, the Pascal object owns the result |
| `TGObject.Take(ptr)` | `transfer:full` | Wraps an existing pointer; takes the reference that was passed |
| `TGObject.Borrow(ptr)` | `transfer:none` | Wraps an existing pointer; adds a toggle ref without consuming the caller's ref |

Floating references (`GInitiallyUnowned`, i.e. all GTK widgets) are sunk
automatically in both `Create` and `CreateFromHandle` via `g_object_ref_sink`
when `g_object_is_floating` returns true.

### Take

```pascal
class function TGObject.Take(AHandle: Pointer): TGObject;
```

Use when a C function returns an object with `transfer:full` — you own the
reference.

```pascal
Obj := TGObject.Take(some_c_function_returning_full());
```

### Borrow

```pascal
class function TGObject.Borrow(AHandle: Pointer): TGObject;
```

Use when a C function returns an object with `transfer:none` — the caller
keeps their reference; your wrapper adds a toggle ref on top.

```pascal
Obj := TGObject.Borrow(some_c_function_returning_none());
```

### Create

```pascal
constructor TGObject.Create;
```

Calls `g_object_new(TypeID, nil)`. Use for the root `TGObject` type or
custom Pascal subclasses registered with the GType system.

## Class-level methods (override in subclasses)

### TypeName

```pascal
class function TypeName: string; virtual;
```

Returns the GType name string used when registering this Pascal class with
`g_type_register_static`. Override in subclasses:

```pascal
class function TMyWidget.TypeName: string;
begin
  Result := 'PasMyWidget';
end;
```

### TypeID

```pascal
class function TypeID: GType; virtual;
```

Returns the `GType` for this class. For `TGObject` itself returns
`G_TYPE_OBJECT`. Generated GTK wrapper classes override this to call
`gtk_xxx_get_type()`. Pascal subclasses register lazily on the first call.

### ClassSetup

```pascal
class procedure ClassSetup(AClass: PGObjectClass); virtual;
```

Called once during GType class initialization. Override to install properties:

```pascal
class procedure TMyObj.ClassSetup(AClass: PGObjectClass);
begin
  inherited ClassSetup(AClass);
  g_object_class_install_property(AClass, PROP_FOO,
    ParamSpecString('foo', 'Foo', 'Description',
      '', G_PARAM_READWRITE or G_PARAM_STATIC_STRINGS));
end;
```

### ParentGType

```pascal
class function ParentGType: GType; virtual;
```

Returns the GType of the parent Pascal class. Used during lazy GType
registration to determine the parent type. Defaults to `G_TYPE_OBJECT`.

## Instance virtual methods

### InstanceSetup

```pascal
procedure InstanceSetup; virtual;
```

Called once after the C GObject instance is created and the toggle ref is in
place. Override for per-instance initialization that needs the handle.

### DoDispose / DoFinalize

```pascal
procedure DoDispose; virtual;
procedure DoFinalize; virtual;
```

Called from the GObject dispose/finalize chain. Override when the object holds
GLib resources that must be released on the GObject side (not the Pascal side).

### DoGetProp / DoSetProp

```pascal
procedure DoGetProp(id: guint; val: TGValue; spec: PGParamSpec); virtual;
procedure DoSetProp(id: guint; const val: TGValue; spec: PGParamSpec); virtual;
```

Override to implement readable/writable properties. `val` in `DoGetProp` is
already in external mode (pointing at the `GValue` GLib owns), so writing to
it via the `Init*` and `As*` methods writes to GLib's struct directly.

```pascal
const
  PROP_NAME = 1;

procedure TMyObj.DoGetProp(id: guint; val: TGValue; spec: PGParamSpec);
begin
  case id of
    PROP_NAME: val.InitString(FName);
  end;
end;

procedure TMyObj.DoSetProp(id: guint; const val: TGValue; spec: PGParamSpec);
begin
  case id of
    PROP_NAME: FName := val.AsString;
  end;
end;
```

## Instance methods

### Reference counting

```pascal
function  Ref: TGObject;    { g_object_ref — increments refcount, returns Self }
procedure Unref;             { g_object_unref }
procedure RefSink;           { g_object_ref_sink — sinks floating ref }
```

The Pascal `Free` / `Destroy` removes the toggle ref, which decrements the
GObject's refcount. If no other references exist the GObject is finalized.

### Notifications

```pascal
procedure FreezeNotify;
procedure ThawNotify;
procedure Notify(const APropName: string);
```

Batch property change notifications. Between `FreezeNotify` and `ThawNotify`,
`::notify` signals are queued rather than emitted immediately.

### Properties (GObject property system)

```pascal
procedure GetProperty(const AName: string; AValue: TGValue);
procedure SetProperty(const AName: string; AValue: TGValue);
```

Access properties by name through the GObject property system. For compiled
code, calling `DoGetProp`/`DoSetProp` indirectly via GLib is slow — prefer
direct Pascal field access in the same class.

### Data attachment (string-keyed)

```pascal
function  GetData(const AKey: string): gpointer;
procedure SetData(const AKey: string; AData: gpointer);
procedure SetDataFull(const AKey: string; AData: gpointer; ADestroy: GDestroyNotify);
function  StealData(const AKey: string): gpointer;
```

Arbitrary data attached to a GObject instance by string key. Slow (hash
lookup on every call). For hot paths, prefer quark-keyed variants.

### Data attachment (quark-keyed)

```pascal
function  GetQData(AQuark: GQuark): gpointer;
procedure SetQData(AQuark: GQuark; AData: gpointer);
procedure SetQDataFull(AQuark: GQuark; AData: gpointer; ADestroy: GDestroyNotify);
function  StealQData(AQuark: GQuark): gpointer;
```

Same as string-keyed but uses a pre-looked-up `GQuark` — faster. Get a quark
once with `g_quark_from_static_string('my-key')` and reuse it.

## Properties

```pascal
property Handle:     PGObjectC;  { raw C pointer — do not store long-term }
property TypeID_:    GType;      { instance GType }
property RefCount:   guint;      { current GObject reference count }
property IsFloating: Boolean;    { whether the object still has a floating ref }
property Owned:      Boolean;    { whether this Pascal wrapper owns the object }
```

## Subclassing example

```pascal
type
  TCounter = class(TGObject)
  private
    FValue: Integer;
  protected
    class procedure ClassSetup(AClass: PGObjectClass); override;
    procedure DoGetProp(id: guint; val: TGValue; spec: PGParamSpec); override;
    procedure DoSetProp(id: guint; const val: TGValue; spec: PGParamSpec); override;
  public
    class function TypeName: string; override;
  end;

const
  PROP_VALUE = 1;

class function TCounter.TypeName: string;
begin
  Result := 'PasCounter';
end;

class procedure TCounter.ClassSetup(AClass: PGObjectClass);
begin
  g_object_class_install_property(AClass, PROP_VALUE,
    ParamSpecInt('value', 'Value', 'Counter value',
      0, MaxInt, 0, G_PARAM_READWRITE or G_PARAM_STATIC_STRINGS));
end;

procedure TCounter.DoGetProp(id: guint; val: TGValue; spec: PGParamSpec);
begin
  if id = PROP_VALUE then val.InitInt(FValue);
end;

procedure TCounter.DoSetProp(id: guint; const val: TGValue; spec: PGParamSpec);
begin
  if id = PROP_VALUE then FValue := val.AsInt;
end;
```
