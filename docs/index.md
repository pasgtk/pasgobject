# pasgobject documentation

Pascal bindings for GLib/GObject and GTK4, generated from GObject Introspection
(GIR) data.

**Repository:** https://github.com/pasgtk/pasgobject
**License:** LGPL 3.0 or later

## Contents

### Getting started

- [Building](building.md) — requirements, build instructions, options
- [Architecture](ARCHITECTURE.md) — layer structure and design decisions

### GObject layer (`gobject/`)

| Unit | Documentation |
|---|---|
| `GTypes` | [gobject/GTypes.md](gobject/GTypes.md) — C type aliases, record definitions |
| `GLib` | [gobject/GLib.md](gobject/GLib.md) — string helpers, memory, main loop |
| `GObjectType` | [gobject/GObjectType.md](gobject/GObjectType.md) — GType constants and queries |
| `GValue` | [gobject/GValue.md](gobject/GValue.md) — generic value container |
| `GParam` | [gobject/GParam.md](gobject/GParam.md) — parameter spec builders |
| `GObject` | [gobject/GObject.md](gobject/GObject.md) — base wrapper class, ownership |
| `GSignal` | [gobject/GSignal.md](gobject/GSignal.md) — signal connection, method callbacks |

`PasGObject` is the umbrella unit that pulls in all of the above.

### GTK4 layer (`gtk4/`)

- [gtk4/overview.md](gtk4/overview.md) — units, notable classes, minimal app

`PasGTK` is the umbrella unit.

### Tools

- [tools/gir2pas.md](tools/gir2pas.md) — binding generator from GIR XML

### Guides

- [Ownership semantics](ownership.md) — Take/Borrow/floating refs
- [Subclassing GObject](subclassing.md) — custom types with properties

## Quick reference

### GObject

```pascal
uses PasGObject;

{ Create }
Obj := TGObject.Create;

{ Wrap existing pointer }
Obj := TGObject.Take(ptr);    { transfer:full }
Obj := TGObject.Borrow(ptr);  { transfer:none }

{ Signals }
CB := @Self.OnSomething;
ID := SignalConnectMethod(Obj, 'notify', CB, nil);
SignalDisconnect(Obj, ID);

{ Free }
Obj.Free;
```

### GTK4

```pascal
uses Math, GTypes, GLib, GObject, GSignal, GLibFFI, GtkClasses, PasGTK;

{ FPU mask — required before any GTK call }
SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide,
                  exOverflow, exUnderflow, exPrecision]);

{ Application }
App := TGtkApplication.New('org.example.App', gpointer(0));
CB  := @Self.OnActivate;
SignalConnectMethod(App, 'activate', CB, nil);
g_application_run(App.Handle, 0, nil);
App.Free;

{ Widgets (inside activate callback) }
Win := TGtkApplicationWindow.New(TGtkApplication(ASender));
Win.SetTitle('My App');
Win.SetDefaultSize(800, 600);

Box := TGtkBox.New(GTK_ORIENTATION_VERTICAL, 8);
Lbl := TGtkLabel.New('Hello, World!');
Btn := TGtkButton.NewWithLabel('OK');

Box.Append(Lbl);
Box.Append(Btn);
Win.SetChild(Box);
Win.Present;
```

### Subclass

```pascal
type
  TMyObj = class(TGObject)
  protected
    class procedure ClassSetup(AClass: PGObjectClass); override;
    procedure DoGetProp(id: guint; val: TGValue; spec: PGParamSpec); override;
    procedure DoSetProp(id: guint; const val: TGValue; spec: PGParamSpec); override;
  public
    class function TypeName: string; override;
  end;
```

See [Subclassing GObject](subclassing.md) for the complete example.
