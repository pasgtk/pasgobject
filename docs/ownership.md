# Ownership semantics

pasgobject follows the
[GObject Introspection transfer annotation](https://gi.readthedocs.io/en/latest/annotations/giannotations.html)
spec exactly.

## The three constructors

| Constructor | GI transfer | When to use |
|---|---|---|
| `TGObject.Create` | — | You want a new object |
| `TGObject.Take(ptr)` | `transfer:full` | C function gave you a reference |
| `TGObject.Borrow(ptr)` | `transfer:none` | C function did not give you a reference |

## How toggle refs work

The Pascal wrapper holds one **toggle ref** (via `g_object_add_toggle_ref`).
The toggle ref keeps the GObject alive as long as the Pascal object exists, and
notifies the Pascal side when the GObject's ref count would otherwise reach
zero.

Lifecycle:

1. `Create` / `Take` / `Borrow` → `g_object_add_toggle_ref(handle, toggle_cb, self)` + `g_object_unref` to hand off the regular ref
2. Other code holds additional refs: GObject refcount > 1 → Pascal object stays alive
3. All other refs released: GObject refcount = 1 (only the toggle ref) → toggle callback fires, Pascal object must stay alive or be freed
4. `Free` → `g_object_remove_toggle_ref` → GObject refcount = 0 → GObject finalized

## Floating references (GTK widgets)

`GInitiallyUnowned` objects (all GTK widgets) are created with a floating ref.
A floating ref is not a real reference — it means "the object has no real
owner yet". The rule: whoever takes ownership must call `g_object_ref_sink`
to convert the floating ref to a regular one.

pasgobject does this transparently in both `Create` and `CreateFromHandle`:

```pascal
if Boolean(g_object_is_floating(Handle)) then
  g_object_ref_sink(Handle);
```

This means:

```pascal
{ OK — widget's floating ref is sunk automatically }
Button := TGtkButton.NewWithLabel('Click');
Box.Append(Button);  { GTK also sinks it; Button still has a toggle ref }
```

## Return value ownership

Generated GTK methods respect the `transfer` annotation from the GIR:

```pascal
{ transfer:none — Borrow }
function TGtkWindow.GetChild: TGtkWidget;
begin
  P_ := GtkFFI.gtk_window_get_child(Handle);
  if P_ <> nil then
    Result := TGtkWidget(TGtkWidget.Borrow(P_));
end;

{ transfer:full — Take }
function TGtkBuilder.GetObject(const AName: string): TGObject;
begin
  P_ := GtkFFI.gtk_builder_get_object(Handle, GLibStr(AName));
  if P_ <> nil then
    Result := TGObject(TGObject.Take(P_));
end;
```

## Freeing objects

Call `Free` (Pascal destructor). This removes the toggle ref, decrementing
the GObject refcount. If nothing else holds the object, it is finalized.

```pascal
Button := TGtkButton.NewWithLabel('OK');
{ ... use button ... }
Button.Free;  { removes toggle ref; GObject freed if no other refs }
```

Never call `g_object_unref` on a handle owned by a Pascal `TGObject`. The
refcount accounting would be broken.

## Sharing objects between Pascal wrappers

If two Pascal objects wrap the same GObject, use `Borrow` for the second one:

```pascal
A := TGtkWidget.Take(some_widget_ptr);    { owns it }
B := TGtkWidget.Borrow(some_widget_ptr);  { borrows it }
{ Both A and B are valid. A.Free removes A's toggle ref; B.Free removes B's. }
```

## Signal sender in callbacks

The `ASender` parameter in `TGSignalCallback` is the Pascal wrapper retrieved
via `g_object_get_qdata`. It is the **same Pascal object** that was created
originally — not a newly allocated wrapper. Never free it inside the callback.
