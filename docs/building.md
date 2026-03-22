# Building pasgobject

## Requirements

| Dependency | Version | Arch Linux | Debian/Ubuntu | Fedora |
|---|---|---|---|---|
| Free Pascal | ≥ 3.2 | `fpc` | `fpc` | `fpc` |
| GLib / GObject | ≥ 2.0 | `glib2` | `libglib2.0-dev` | `glib2-devel` |
| GTK4 | ≥ 4.0 | `gtk4` | `libgtk-4-dev` | `gtk4-devel` |
| Meson | ≥ 1.0 | `meson` | `meson` | `meson` |

```bash
# Arch Linux
sudo pacman -S fpc glib2 gtk4 meson

# Debian / Ubuntu
sudo apt install fpc libglib2.0-dev libgtk-4-dev meson

# Fedora
sudo dnf install fpc glib2-devel gtk4-devel meson
```

## Build

```bash
meson setup build
ninja -C build
```

## Test

```bash
ninja -C build test
```

All four tests should pass:

```
4/4 tests pass
  gobject/TestGTypes
  gobject/TestGObject
  gobject/TestSignals
  gtk4/TestGtk
```

## Build options

| Option | Default | Description |
|---|---|---|
| `build_tests` | `true` | Build and register the test programs |
| `build_examples` | `true` | Build the example programs |
| `build_gtk4` | `true` | Build the GTK4 layer (auto-skipped if GTK4 not found) |

```bash
# GObject only, no GTK4
meson setup build -Dbuild_gtk4=false

# Skip examples
meson setup build -Dbuild_examples=false

# Minimal: library only, no tests, no examples
meson setup build -Dbuild_tests=false -Dbuild_examples=false
```

## Build outputs

After `ninja -C build`:

```
build/
  gobject/
    tests/
      TestGTypes      { test binary }
      TestGObject     { test binary }
      TestSignals     { test binary }
    examples/
      hello_gobject   { example binary }
      custom_object   { example binary }
  gtk4/
    tests/
      TestGtk         { test binary }
    examples/
      hello_window    { example binary }
  tools/
    gir2pas/
      gir2pas         { binding generator }
```

## Compiling without Meson

Add the source paths with `-Fu`:

```bash
# GObject only
fpc -Fugobject/src -Fugobject/src/Internal yourprogram.pas

# GTK4
fpc -Fugobject/src -Fugobject/src/Internal \
    -Fugtk4/src   -Fugtk4/src/Internal     \
    yourprogram.pas
```

## Regenerating GTK4 bindings

After a GTK version upgrade:

```bash
ninja -C build tools/gir2pas/gir2pas
./build/tools/gir2pas/gir2pas /usr/share/gir-1.0/Gtk-4.0.gir gtk4/src
ninja -C build
```
