# GTK4 binding overview

**Units:** `GtkFFI` (Internal), `GtkTypes`, `GtkClasses`, `PasGTK`
**Files:** `gtk4/src/`
**Generated from:** `/usr/share/gir-1.0/Gtk-4.0.gir`

## Units

### PasGTK

Umbrella unit. Add `PasGTK` to your `uses` clause to get the entire GTK4
binding plus the GObject layer in one import:

```pascal
uses PasGTK;
```

Pulls in: `GTypes`, `GLib`, `GObjectType`, `GValue`, `GParam`, `GObject`,
`GSignal`, `PasGObject`, `GtkTypes`, `GtkClasses`.

### GtkTypes

Auto-generated enumerations and bitfields from the GIR. 110 types covering
all GTK4 enum and bitfield types (e.g. `GtkOrientation`, `GtkAlign`,
`GtkJustification`, `GtkWindowType`, …).

Bitfields are exposed as `Cardinal` type aliases with `const` members:

```pascal
GtkAlign = (
  GTK_ALIGN_FILL  = 0,
  GTK_ALIGN_START = 1,
  GTK_ALIGN_END   = 2,
  GTK_ALIGN_CENTER = 3,
  GTK_ALIGN_BASELINE_FILL = 4,
  GTK_ALIGN_BASELINE_CENTER = 5
);
```

### GtkClasses

Auto-generated Pascal wrapper classes. 265 classes, 3300+ methods.

Every class:
- Inherits from the correct GTK parent (or `TGObject` if the parent is outside GTK)
- Overrides `TypeID` to return the GTK GType via the generated `get_type` call
- Exposes constructors that call `CreateFromHandle`
- Exposes methods with Pascal-friendly parameter types (`string` instead of
  `pgchar`, `Boolean` instead of `gboolean`, object params as `TGtkXxx`)

### GtkFFI (Internal)

Raw `external` C declarations for every GTK4 function. Used only by
`GtkClasses`. Application code should never need to import this unit directly.

## Floating references

All GTK widgets inherit from `GInitiallyUnowned` and start with a floating
reference. `TGObject.CreateFromHandle` (called by all GTK constructors) checks
`g_object_is_floating` and calls `g_object_ref_sink` automatically.

## Running a GTK4 application

Every GTK4 program must mask FPU exceptions before entering the GTK main loop:

```pascal
uses Math;

SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide,
                  exOverflow, exUnderflow, exPrecision]);
g_application_run(App.Handle, 0, nil);
```

`g_application_run` is declared in `GLibFFI` (from `libgio-2.0.so.0`).

## Minimal application

```pascal
program MyApp;
{$mode objfpc}{$H+}
uses Math, GTypes, GLib, GObject, GSignal, GLibFFI, GtkClasses, PasGTK;

type
  TApp = class
  private
    FApp: TGtkApplication;
  public
    procedure OnActivate(ASender: TGObject; AUserData: Pointer);
    function  Run: Integer;
  end;

procedure TApp.OnActivate(ASender: TGObject; AUserData: Pointer);
var Win: TGtkApplicationWindow; Lbl: TGtkLabel;
begin
  Win := TGtkApplicationWindow.New(TGtkApplication(ASender));
  Win.SetTitle('Hello');
  Win.SetDefaultSize(400, 200);
  Lbl := TGtkLabel.New('Hello, World!');
  Win.SetChild(Lbl);
  Win.Present;
end;

function TApp.Run: Integer;
var CB: TGSignalCallback;
begin
  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide,
                    exOverflow, exUnderflow, exPrecision]);
  FApp := TGtkApplication.New('org.example.App', gpointer(0));
  CB   := @Self.OnActivate;
  SignalConnectMethod(FApp, 'activate', CB, nil);
  Result := Integer(g_application_run(FApp.Handle, 0, nil));
  FApp.Free;
end;

var App: TApp;
begin
  App := TApp.Create;
  App.Run;
  App.Free;
end.
```

## Notable classes

| Class | GTK C type | Notes |
|---|---|---|
| `TGtkWidget` | `GtkWidget` | Base for all visual widgets |
| `TGtkWindow` | `GtkWindow` | Top-level window |
| `TGtkApplicationWindow` | `GtkApplicationWindow` | Window tied to a `TGtkApplication` |
| `TGtkApplication` | `GtkApplication` | Application lifecycle |
| `TGtkLabel` | `GtkLabel` | Static text |
| `TGtkButton` | `GtkButton` | Clickable button; emits `clicked` signal |
| `TGtkBox` | `GtkBox` | Linear container (horizontal or vertical) |
| `TGtkEntry` | `GtkEntry` | Single-line text input |
| `TGtkGrid` | `GtkGrid` | Grid layout container |
| `TGtkStack` | `GtkStack` | Stacked pages (one visible at a time) |
| `TGtkListBox` | `GtkListBox` | Vertical list with selectable rows |
| `TGtkScrolledWindow` | `GtkScrolledWindow` | Scrollable container |
| `TGtkHeaderBar` | `GtkHeaderBar` | Title bar with optional widgets |
| `TGtkDialog` | `GtkDialog` | Modal or non-modal dialog window |
| `TGtkImage` | `GtkImage` | Image display |
| `TGtkSpinner` | `GtkSpinner` | Animated loading indicator |
| `TGtkSwitch` | `GtkSwitch` | On/off toggle |
| `TGtkScale` | `GtkScale` | Slider with adjustable value |
| `TGtkProgressBar` | `GtkProgressBar` | Progress indicator |
| `TGtkTextView` | `GtkTextView` | Multi-line text editor |
| `TGtkTreeView` | `GtkTreeView` | Column-based data view |
| `TGtkDrawingArea` | `GtkDrawingArea` | Custom rendering surface |
| `TGtkGLArea` | `GtkGLArea` | OpenGL rendering surface |

## Widget layout

GTK4 uses a single-child containment model. Every container widget has a
`SetChild` method that replaces its child. For multiple children use layout
containers:

```pascal
var Box: TGtkBox;
begin
  Box := TGtkBox.New(GTK_ORIENTATION_VERTICAL, 8);
  Box.Append(Label1);
  Box.Append(Label2);
  Box.Append(Button);
  Window.SetChild(Box);
end;
```
