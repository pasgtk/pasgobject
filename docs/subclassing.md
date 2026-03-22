# Subclassing GObject from Pascal

You can create new GObject-derived types entirely in Pascal. The GType is
registered lazily on the first call to `TypeID`.

## Step-by-step

### 1. Declare the class

```pascal
type
  TCounter = class(TGObject)
  private
    FValue: Integer;
  protected
    class procedure ClassSetup(AClass: PGObjectClass); override;
    procedure DoGetProp(id: guint; val: TGValue; spec: PGParamSpec); override;
    procedure DoSetProp(id: guint; const val: TGValue; spec: PGParamSpec); override;
    procedure InstanceSetup; override;
  public
    class function TypeName: string; override;
    property Value: Integer read FValue;
  end;
```

### 2. Provide a unique type name

```pascal
class function TCounter.TypeName: string;
begin
  Result := 'PasCounter';   { must be unique across the process }
end;
```

### 3. Install properties in ClassSetup

```pascal
const
  PROP_VALUE = 1;

class procedure TCounter.ClassSetup(AClass: PGObjectClass);
begin
  inherited ClassSetup(AClass);
  g_object_class_install_property(AClass, PROP_VALUE,
    ParamSpecInt('value', 'Value', 'The counter value',
      0, MaxInt, 0, G_PARAM_READWRITE or G_PARAM_STATIC_STRINGS));
end;
```

`ClassSetup` is called once per type, during GType class initialization. It
runs before any instance is created.

### 4. Implement DoGetProp / DoSetProp

```pascal
procedure TCounter.DoGetProp(id: guint; val: TGValue; spec: PGParamSpec);
begin
  case id of
    PROP_VALUE: val.InitInt(FValue);
  end;
end;

procedure TCounter.DoSetProp(id: guint; const val: TGValue; spec: PGParamSpec);
begin
  case id of
    PROP_VALUE:
    begin
      FValue := val.AsInt;
      Notify('value');   { emit ::notify::value }
    end;
  end;
end;
```

`val` in `DoGetProp` is already in **external mode** — it points to the
`GValue` struct that GLib owns. Calling `val.InitInt(FValue)` writes the
integer into GLib's struct; the value is read by whoever called
`g_object_get_property`.

### 5. Optional: InstanceSetup

```pascal
procedure TCounter.InstanceSetup;
begin
  inherited InstanceSetup;
  FValue := 0;   { redundant here; Pascal initializes fields to zero }
end;
```

`InstanceSetup` runs after `g_object_new` returns and the toggle ref is in
place. Use it when initialization requires the `Handle` (e.g. connecting to
self-signals).

### 6. Use the class

```pascal
var
  C: TCounter;
  V: TGValue;
begin
  g_type_init;

  C := TCounter.Create;
  WriteLn(C.TypeID_);         { the registered GType }
  WriteLn(GTypeName(C.TypeID_));  { 'PasCounter' }

  V := TGValue.Create;
  V.InitInt(7);
  C.SetProperty('value', V);
  V.Free;

  WriteLn(C.Value);           { 7 }
  C.Free;
end;
```

## Inheriting from a GTK class

The same pattern works with any GTK class as the parent. Override `ParentGType`
to return the correct GType:

```pascal
type
  TMyButton = class(TGtkButton)
  protected
    class procedure ClassSetup(AClass: PGObjectClass); override;
  public
    class function TypeName: string; override;
    class function ParentGType: GType; override;
  end;

class function TMyButton.TypeName: string;
begin
  Result := 'PasMyButton';
end;

class function TMyButton.ParentGType: GType;
begin
  Result := TGtkButton.TypeID;
end;
```

## How lazy registration works internally

On the first call to `TCounter.TypeID`:

1. Checks whether `GTypeFromName('PasCounter')` already returns a valid type
2. If not, calls `g_type_register_static` with:
   - parent: `ParentGType` (defaults to `G_TYPE_OBJECT`)
   - name: `TypeName`
   - class size: `SizeOf(GObjectClass)`
   - class init: `PasClassInit` (calls `ClassSetup`)
   - instance size: `SizeOf(GObjectC)`
   - instance init: `PasInstanceInit`
3. Installs GObject vfuncs: `dispose → PasDispose`, `finalize → PasFinalize`,
   `get_property → PasGetProperty`, `set_property → PasSetProperty`
4. Caches the GType in a class variable

Subsequent calls return the cached value immediately.
