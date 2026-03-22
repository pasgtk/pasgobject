# GTypes

**Unit:** `GTypes`
**File:** `gobject/src/GTypes.pas`
**Depends on:** nothing (lowest-level unit)

Fundamental GLib/GObject type aliases and record definitions. Every other unit
in the binding depends on this unit directly or transitively.

## C type aliases

| Pascal type | C equivalent | Size |
|---|---|---|
| `gboolean` | `gboolean` | 4 bytes |
| `gchar` / `guchar` | `gchar` / `guchar` | 1 byte |
| `gshort` / `gushort` | `gshort` / `gushort` | 2 bytes |
| `gint` / `guint` | `gint` / `guint` | 4 bytes |
| `glong` / `gulong` | `glong` / `gulong` | platform word |
| `gint8`…`gint64` | `gint8`…`gint64` | exact width |
| `guint8`…`guint64` | `guint8`…`guint64` | exact width |
| `gfloat` | `gfloat` | 4 bytes |
| `gdouble` | `gdouble` | 8 bytes |
| `gsize` / `gssize` | `gsize` / `gssize` | platform pointer size |
| `goffset` | `goffset` | 8 bytes |
| `gpointer` | `gpointer` | pointer |
| `gconstpointer` | `gconstpointer` | pointer |
| `pgchar` | `gchar *` | pointer |
| `ppgchar` | `gchar **` | pointer |
| `GType` | `GType` | platform word |
| `GQuark` | `GQuark` | 4 bytes |

All pointer variants (prefixed `p`) and double-pointer variants (prefixed `pp`)
are also declared for all types where needed.

## Callback types

```pascal
GDestroyNotify    = procedure(data: gpointer); cdecl;
GToggleNotify     = procedure(data, obj: gpointer; last_ref: gboolean); cdecl;
GFunc             = procedure(data, user_data: gpointer); cdecl;
GCompareFunc      = function(a, b: gconstpointer): gint; cdecl;
GHashFunc         = function(key: gconstpointer): guint; cdecl;
GEqualFunc        = function(a, b: gconstpointer): gboolean; cdecl;
GSourceFunc       = function(user_data: gpointer): gboolean; cdecl;
GClosureNotify    = procedure(data, closure: gpointer); cdecl;
GClosureMarshal   = procedure(...); cdecl;
```

## Key records

### GValue

The generic value container used by the GObject property system and signals.

```pascal
GValueData = packed record
  case Integer of
    0: (v_int:    gint);
    1: (v_uint:   guint);
    2: (v_long:   glong);
    3: (v_ulong:  gulong);
    4: (v_int64:  gint64);
    5: (v_uint64: guint64);
    6: (v_float:  gfloat);
    7: (v_double: gdouble);
    8: (v_pointer: gpointer);
end;

GValue = packed record
  g_type : GType;
  data   : array[0..1] of GValueData;
end;
```

`{$PackRecords C}` is in effect; the layout matches the C struct exactly.

### GObjectC / GObjectClass

Raw C-level GObject instance and class structs. Used only in `GObjectFFI` and
`GObject.pas`. Pascal code should always use `TGObject`, not these.

### GSignalQuery

Returned by `g_signal_query`. Fields: `signal_id`, `signal_name`, `itype`,
`signal_flags`, `return_type`, `n_params`, `param_types`.
