# gir2pas

**File:** `tools/gir2pas/gir2pas.pas`
**Binary:** `build/tools/gir2pas/gir2pas`

Generates Pascal binding units from a GObject Introspection (GIR) XML file.

## Usage

```
gir2pas <input.gir> <output-dir> [--lib-name <soname>]
```

| Argument | Description |
|---|---|
| `<input.gir>` | Path to the GIR file (e.g. `/usr/share/gir-1.0/Gtk-4.0.gir`) |
| `<output-dir>` | Directory where the output units are written |
| `--lib-name <soname>` | Override the shared library name (e.g. `libgtk-4.so.1`) |

## Output files

For a namespace `Foo` at version `1.0`:

| File | Content |
|---|---|
| `<output-dir>/Internal/FooFFI.pas` | Raw `external` C function declarations |
| `<output-dir>/FooTypes.pas` | Enumerations and bitfields |
| `<output-dir>/FooClasses.pas` | Pascal wrapper classes |

## What gets generated

### FooFFI.pas

- One `function` or `procedure` declaration per method/constructor across all
  classes
- All parameters typed as raw FFI types (`gpointer` for objects, `gint` for
  enums, `pgchar` for strings, etc.)
- One `function xxx_get_type(): GType` per enum/class that has a `get_type`
  function in the GIR

### FooTypes.pas

- Pascal enumerations for GIR `enumeration` elements
- `Cardinal` type aliases with `const` values for GIR `bitfield` elements
  (bitfields cannot be represented as Pascal enums because members may overlap)

### FooClasses.pas

- One `TFooXxx = class(TParent)` per GIR `class` element
- Forward declarations for all classes at the top of the `type` section
- Each class has:
  - `class function TypeID: GType; override;` — calls `foo_xxx_get_type()`
  - Constructors calling `inherited CreateFromHandle(foo_xxx_new(...))`
  - Methods forwarding to the FFI layer with type conversions
- A private `ObjH(O: TGObject): gpointer` helper for passing object params

## Filtering rules

`gir2pas` skips the following elements:

| Rule | Reason |
|---|---|
| `introspectable="0"` | Not available to language bindings |
| `deprecated="1"` | Avoids generating deprecated API |
| Methods with `moved-to` attribute | Renamed or merged methods |
| Methods with `throws="1"` | Error-throwing functions not yet supported |
| Methods with array parameters | Array handling not yet supported |
| Methods with empty `c:identifier` | Cannot bind without a C symbol |
| GTypeStruct classes | Internal class structs, not user-facing |
| Constructors on abstract classes | Cannot instantiate directly |

## Type mapping

| GIR type | FFI Pascal type | Public Pascal type |
|---|---|---|
| `utf8`, `filename` | `pgchar` | `string` |
| `gboolean` | `gboolean` | `Boolean` |
| `gint`, `gint32` | `gint` | `gint` |
| `guint`, `guint32` | `guint` | `guint` |
| `gint8`…`gint64` | exact type | exact type |
| `gfloat` | `gfloat` | `gfloat` |
| `gdouble` | `gdouble` | `gdouble` |
| `gsize` / `gssize` | `gsize` / `gssize` | `gsize` / `gssize` |
| `gpointer` | `gpointer` | `gpointer` |
| `GType` | `GType` | `GType` |
| `none` (void) | — (procedure) | — (procedure) |
| known enum type | `gint` | enum Pascal type |
| known class type | `gpointer` | `TFooClassName` |
| anything else | `gpointer` | `gpointer` |

## Return value handling

| Return type | Generated code |
|---|---|
| `void` | `procedure` |
| `string` | Calls `PasStr()` on result; returns `''` if handle is nil |
| `Boolean` | Casts result to `Boolean` |
| Object (`transfer:full`) | `TFooXxx.Take(ptr)` |
| Object (`transfer:none`) | `TFooXxx.Borrow(ptr)` |
| Enum / primitive | Direct cast to Pascal type |

## Topological sort

Classes are emitted in dependency order: if class B inherits from class A, A
appears before B in `FooClasses.pas`. This ensures forward-reference-free
compilation. The sort uses depth-first traversal on the parent chain.

## Regenerating GTK4 bindings

```bash
ninja -C build tools/gir2pas/gir2pas
./build/tools/gir2pas/gir2pas /usr/share/gir-1.0/Gtk-4.0.gir gtk4/src
```

## Generating bindings for other libraries

```bash
{ Libadwaita }
./build/tools/gir2pas/gir2pas /usr/share/gir-1.0/Adw-1.gir adw/src

{ GStreamer }
./build/tools/gir2pas/gir2pas /usr/share/gir-1.0/Gst-1.0.gir gst/src

{ Pango }
./build/tools/gir2pas/gir2pas /usr/share/gir-1.0/Pango-1.0.gir pango/src \
  --lib-name libpango-1.0.so.0
```

The output directory must exist (or will be created). The umbrella `PasFoo.pas`
must be written by hand since it needs to list the correct `uses` clause.

## Known limitations

- Array parameters and return types are skipped
- Functions that throw `GError` are skipped
- Callbacks and signal parameter types are mapped to `gpointer`
- Interface types are not generated (mapped to `gpointer`)
- Boxed types are not wrapped (mapped to `gpointer`)
- No support for out-parameters that are not the return value
- Only classes within the target namespace are wrapped; cross-namespace
  object types are mapped to `gpointer`
