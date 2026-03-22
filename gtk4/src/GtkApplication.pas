{ Pascal-GObject - GTK4 GtkApplication wrapper
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GtkApplication - TGtkApplication, the Pascal wrapper for GtkApplication.

  GtkApplication is a GApplication subclass (not a GtkWidget).  Its constructor
  returns a transfer:full plain reference (not floating), so CreateFromHandle is
  called with ASink=False.

  Typical usage:
    App := TGtkApplication.Create('org.example.App');
    SignalConnectMethod(App, 'activate', @Self.OnActivate, nil);
    App.Run;
    App.Free; }
unit GtkApplication;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes, GLib, GObjectType, GObject, GtkTypes;

type
  TGtkApplication = class(TGObject)
  public
    { TypeID returns the GType for GtkApplication (from the GTK library). }
    class function TypeID: GType; override;

    { Create registers a new GTK application with the given application ID.
      AFlags defaults to G_APPLICATION_DEFAULT_FLAGS (0).
      The returned object has refcount=1 (transfer:full). }
    constructor Create(const AAppID: string;
      AFlags: Cardinal = G_APPLICATION_DEFAULT_FLAGS); reintroduce;

    { Run enters the GLib main loop and processes events until Quit is called
      or all windows are closed.  Returns the exit status. }
    function Run: Integer;

    { Quit terminates the main loop on the next iteration. }
    procedure Quit;

    { Hold / Release prevent the application from exiting while background
      work is in progress. }
    procedure Hold;
    procedure Release;
  end;

implementation

uses Gtk4FFI, Math;

class function TGtkApplication.TypeID: GType;
begin
  Result := Gtk4FFI.gtk_application_get_type();
end;

constructor TGtkApplication.Create(const AAppID: string; AFlags: Cardinal);
begin
  inherited CreateFromHandle(
    gtk_application_new(GLibStr(AAppID), guint32(AFlags)),
    False);
end;

function TGtkApplication.Run: Integer;
begin
  if Handle = nil then
    Exit(1);
  { GTK4's Cairo/Pango/GL stack performs floating-point operations that may
    produce division-by-zero or denormals, which are silently ignored in C
    but raise exceptions under Free Pascal's default FPU mask.  Mask them
    before entering the main loop, as every GTK application must. }
  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide,
                    exOverflow, exUnderflow, exPrecision]);
  Result := Integer(g_application_run(Handle, 0, nil));
end;

procedure TGtkApplication.Quit;
begin
  if Handle <> nil then
    g_application_quit(Handle);
end;

procedure TGtkApplication.Hold;
begin
  if Handle <> nil then
    g_application_hold(Handle);
end;

procedure TGtkApplication.Release;
begin
  if Handle <> nil then
    g_application_release(Handle);
end;

end.
