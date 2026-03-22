# GParam

**Unit:** `GParam`
**File:** `gobject/src/GParam.pas`
**Depends on:** `GTypes`, `GLib`, `GObjectFFI`

Pascal builders for `GParamSpec` objects. Use these when implementing
`ClassSetup` in a `TGObject` subclass to install properties.

## Parameter flags

| Constant | Description |
|---|---|
| `G_PARAM_READABLE` | Property can be read |
| `G_PARAM_WRITABLE` | Property can be written |
| `G_PARAM_READWRITE` | Shorthand for READABLE \| WRITABLE |
| `G_PARAM_CONSTRUCT` | Set during construction even if not explicitly passed |
| `G_PARAM_CONSTRUCT_ONLY` | Can only be set during construction |
| `G_PARAM_LAX_VALIDATION` | Values outside bounds are silently clamped |
| `G_PARAM_STATIC_NAME` | Name string is static (no copy) |
| `G_PARAM_STATIC_NICK` | Nick string is static |
| `G_PARAM_STATIC_BLURB` | Blurb string is static |
| `G_PARAM_EXPLICIT_NOTIFY` | Notify only when `g_object_notify` is called explicitly |
| `G_PARAM_DEPRECATED` | Deprecated, emit warning on use |
| `G_PARAM_STATIC_STRINGS` | All three strings are static (recommended default) |

## Builder functions

All functions accept Pascal `string` parameters for name, nick, and blurb.
They return a `PGParamSpec` ready for `g_object_class_install_property`.

### ParamSpecBoolean

```pascal
function ParamSpecBoolean(const AName, ANick, ABlurb: string;
  ADefault: Boolean; AFlags: GParamFlags): PGParamSpec;
```

### ParamSpecInt / ParamSpecUInt

```pascal
function ParamSpecInt(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: gint; AFlags: GParamFlags): PGParamSpec;

function ParamSpecUInt(const AName, ANick, ABlurb: string;
  AMin, AMax: guint; ADefault: guint; AFlags: GParamFlags): PGParamSpec;
```

### ParamSpecInt64

```pascal
function ParamSpecInt64(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: gint64; AFlags: GParamFlags): PGParamSpec;
```

### ParamSpecFloat / ParamSpecDouble

```pascal
function ParamSpecFloat(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: gfloat; AFlags: GParamFlags): PGParamSpec;

function ParamSpecDouble(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: gdouble; AFlags: GParamFlags): PGParamSpec;
```

### ParamSpecString

```pascal
function ParamSpecString(const AName, ANick, ABlurb: string;
  const ADefault: string; AFlags: GParamFlags): PGParamSpec;
```

### ParamSpecEnum / ParamSpecFlags

```pascal
function ParamSpecEnum(const AName, ANick, ABlurb: string;
  AEnumType: GType; ADefault: gint; AFlags: GParamFlags): PGParamSpec;

function ParamSpecFlags(const AName, ANick, ABlurb: string;
  AFlagsType: GType; ADefault: guint; AFlags: GParamFlags): PGParamSpec;
```

### ParamSpecObject

```pascal
function ParamSpecObject(const AName, ANick, ABlurb: string;
  AObjectType: GType; AFlags: GParamFlags): PGParamSpec;
```

### ParamSpecPointer / ParamSpecBoxed

```pascal
function ParamSpecPointer(const AName, ANick, ABlurb: string;
  AFlags: GParamFlags): PGParamSpec;

function ParamSpecBoxed(const AName, ANick, ABlurb: string;
  ABoxedType: GType; AFlags: GParamFlags): PGParamSpec;
```

## Query functions

```pascal
function ParamSpecName(ASpec: PGParamSpec): string;
function ParamSpecNick(ASpec: PGParamSpec): string;
function ParamSpecBlurb(ASpec: PGParamSpec): string;
```

## Example

```pascal
class procedure TCounter.ClassSetup(AClass: PGObjectClass);
begin
  g_object_class_install_property(AClass, PROP_VALUE,
    ParamSpecInt('value', 'Value', 'Counter value',
      0, MaxInt, 0,
      G_PARAM_READWRITE or G_PARAM_STATIC_STRINGS));
end;
```
