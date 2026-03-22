program hello_window;

{$mode objfpc}{$H+}

uses
  Math,
  GTypes, GLib, GObject, GSignal,
  GLibFFI,
  GtkClasses, PasGTK;

type
  TApp = class
  private
    FApp: TGtkApplication;
  public
    procedure OnActivate(ASender: TGObject; AUserData: Pointer);
    function  Run: Integer;
  end;

procedure TApp.OnActivate(ASender: TGObject; AUserData: Pointer);
var
  Win: TGtkApplicationWindow;
  Lbl: TGtkLabel;
begin
  Win := TGtkApplicationWindow.New(TGtkApplication(ASender));
  Win.SetTitle('Hello');
  Win.SetDefaultSize(320, 120);
  Lbl := TGtkLabel.New('Hello, World!');
  Win.SetChild(Lbl);
  Win.Present;
end;

function TApp.Run: Integer;
var
  CB: TGSignalCallback;
begin
  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide,
                    exOverflow, exUnderflow, exPrecision]);
  FApp := TGtkApplication.New('org.pasgobject.Hello', gpointer(0));
  CB   := @Self.OnActivate;
  SignalConnectMethod(FApp, 'activate', CB, nil);
  Result := Integer(g_application_run(FApp.Handle, 0, nil));
  FApp.Free;
end;

var
  App: TApp;
begin
  App := TApp.Create;
  App.Run;
  App.Free;
end.
