# GObjectType

**Unit:** `GObjectType`
**File:** `gobject/src/GObjectType.pas`
**Depends on:** `GTypes`, `GObjectFFI`

GType runtime type system constants and Pascal query helpers.

## Fundamental type constants

These are the well-known GType values for primitive C types. They match the
values defined in `<glib-object.h>`.

| Constant | GType value | Description |
|---|---|---|
| `G_TYPE_INVALID` | 0 | Sentinel for uninitialized type |
| `G_TYPE_NONE` | 4 | void (no value) |
| `G_TYPE_INTERFACE` | 8 | GTypeInterface |
| `G_TYPE_CHAR` | 12 | gchar |
| `G_TYPE_UCHAR` | 16 | guchar |
| `G_TYPE_BOOLEAN` | 20 | gboolean |
| `G_TYPE_INT` | 24 | gint |
| `G_TYPE_UINT` | 28 | guint |
| `G_TYPE_LONG` | 32 | glong |
| `G_TYPE_ULONG` | 36 | gulong |
| `G_TYPE_INT64` | 40 | gint64 |
| `G_TYPE_UINT64` | 44 | guint64 |
| `G_TYPE_ENUM` | 48 | enum (integer) |
| `G_TYPE_FLAGS` | 52 | flags (unsigned integer) |
| `G_TYPE_FLOAT` | 56 | gfloat |
| `G_TYPE_DOUBLE` | 60 | gdouble |
| `G_TYPE_STRING` | 64 | gchar* (owned) |
| `G_TYPE_POINTER` | 68 | gpointer |
| `G_TYPE_BOXED` | 72 | boxed type |
| `G_TYPE_PARAM` | 76 | GParamSpec |
| `G_TYPE_OBJECT` | 80 | GObject |
| `G_TYPE_VARIANT` | 84 | GVariant |

## Type flag constants

Used in `GTypeFlags` when registering new types:

| Constant | Description |
|---|---|
| `G_TYPE_FLAG_NONE` | No flags |
| `G_TYPE_FLAG_ABSTRACT` | Cannot be instantiated directly |
| `G_TYPE_FLAG_VALUE_ABSTRACT` | Cannot be used with GValue |
| `G_TYPE_FLAG_FINAL` | Cannot be derived from |
| `G_TYPE_FLAG_CLASSED` | Has a class struct |
| `G_TYPE_FLAG_INSTANTIATABLE` | Can create instances |
| `G_TYPE_FLAG_DERIVABLE` | Other types can inherit |
| `G_TYPE_FLAG_DEEP_DERIVABLE` | Multi-level derivation allowed |

## Functions

### g_type_init

```pascal
procedure g_type_init;
```

Must be called once before any other GType operation. In modern GLib (≥ 2.36)
this is a no-op, but calling it remains correct for compatibility.

### GTypeName

```pascal
function GTypeName(AType: GType): string;
```

Returns the human-readable name of a GType (e.g. `'GObject'`, `'GtkButton'`).
Returns `''` for `G_TYPE_INVALID`.

### GTypeFromName

```pascal
function GTypeFromName(const AName: string): GType;
```

Looks up a GType by name. Returns `G_TYPE_INVALID` if not found. The type must
have been registered already.

### GTypeIsA

```pascal
function GTypeIsA(AType, ABaseType: GType): Boolean;
```

Returns `True` if `AType` is `ABaseType` or a descendant of it. Equivalent to
`g_type_is_a`.

```pascal
Assert(GTypeIsA(gtk_button_get_type(), G_TYPE_OBJECT));
```

### GTypeIsObject / GTypeIsInterface

```pascal
function GTypeIsObject(AType: GType): Boolean;
function GTypeIsInterface(AType: GType): Boolean;
```

Convenience checks.

### GTypeParent

```pascal
function GTypeParent(AType: GType): GType;
```

Returns the parent GType, or `G_TYPE_INVALID` for root types.

### GTypeDepth

```pascal
function GTypeDepth(AType: GType): guint;
```

Returns the depth in the type hierarchy. `G_TYPE_OBJECT` has depth 1.
