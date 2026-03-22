{ Pascal-GObject example: Custom GObject subclass via TGObject
  Defines TCounter as a Pascal class that derives from TGObject.
  Demonstrates lazy GType registration, property installation through
  ClassSetup, DoGetProp/DoSetProp, and "of object" signal callbacks via
  SignalConnectMethod. }
program custom_object;

{$mode objfpc}{$H+}

uses
  GTypes, GLib, GObjectType, GValue, GParam, GObject, GSignal, PasGObject;

const
  PROP_VALUE = 1;

type
  TCounter = class(TGObject)
  private
    FValue : Integer;
  protected
    class procedure ClassSetup(AClass: PGObjectClass); override;
    procedure DoGetProp(id: guint; val: TGValue; spec: PGParamSpec); override;
    procedure DoSetProp(id: guint; const val: TGValue; spec: PGParamSpec); override;
    procedure InstanceSetup; override;
  public
    class function TypeName: string; override;
    constructor Create; override;
    property Value: Integer read FValue write FValue;
  end;

  TApp = class
    procedure OnValueNotify(ASender: TGObject; AUserData: Pointer);
  end;

class function TCounter.TypeName: string;
begin
  Result := 'PasCounter';
end;

class procedure TCounter.ClassSetup(AClass: PGObjectClass);
begin
  g_object_class_install_property(AClass, PROP_VALUE,
    ParamSpecInt('value', 'Value', 'The counter value',
      Low(Integer), High(Integer), 0,
      G_PARAM_READWRITE or G_PARAM_STATIC_STRINGS));
end;

procedure TCounter.DoGetProp(id: guint; val: TGValue; spec: PGParamSpec);
begin
  if id = PROP_VALUE then
    g_value_set_int(val.RawPtr, gint(FValue));
end;

procedure TCounter.DoSetProp(id: guint; const val: TGValue; spec: PGParamSpec);
begin
  if id = PROP_VALUE then
  begin
    FValue := Integer(g_value_get_int(val.RawPtr));
    Notify('value');
  end;
end;

procedure TCounter.InstanceSetup;
begin
  FValue := 0;
end;

constructor TCounter.Create;
begin
  inherited Create;
end;

procedure TApp.OnValueNotify(ASender: TGObject; AUserData: Pointer);
var
  C : TCounter;
begin
  if ASender is TCounter then
  begin
    C := TCounter(ASender);
    WriteLn('  [notify via method] value = ', C.Value,
      ', user data = ', PtrUInt(AUserData));
  end;
end;

var
  Counter : TCounter;
  App     : TApp;
  HID     : gulong;
  V       : TGValue;
  CB      : TGSignalCallback;
begin
  WriteLn('Pascal-GObject - Custom Object example');
  WriteLn('');

  g_type_init;

  WriteLn('--- Type registration ---');
  WriteLn('  TCounter TypeID   : ', TCounter.TypeID);
  WriteLn('  TCounter TypeName : ', GTypeName(TCounter.TypeID));
  WriteLn('  Is GObject subtype: ', GTypeIsA(TCounter.TypeID, G_TYPE_OBJECT));
  WriteLn('  Name matches      : ', GTypeName(TCounter.TypeID) = 'PasCounter');

  WriteLn('');
  WriteLn('--- Object creation and property access ---');
  Counter := TCounter.Create;
  App     := TApp.Create;
  try
    WriteLn('  Initial value: ', Counter.Value);

    CB  := @App.OnValueNotify;
    HID := SignalConnectMethod(Counter, 'notify::value', CB, Pointer(99));

    V := TGValue.Create;
    try
      V.InitInt(42);
      Counter.SetProperty('value', V);
    finally
      V.Free;
    end;
    WriteLn('  After SetProperty: ', Counter.Value);

    V := Counter.GetProperty('value');
    try
      WriteLn('  GetProperty returns: ', V.AsInt);
    finally
      V.Free;
    end;

    Counter.Value := 7;
    Counter.Notify('value');
    WriteLn('  After direct assignment + Notify: ', Counter.Value);

    SignalDisconnect(Counter, HID);
  finally
    App.Free;
    Counter.Free;
  end;

  WriteLn('');
  WriteLn('Done.');
end.
