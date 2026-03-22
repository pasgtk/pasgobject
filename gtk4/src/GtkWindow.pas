{ Pascal-GObject - GTK4 GtkWindow wrapper
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GtkWindow - TGtkWindow and TGtkApplicationWindow Pascal wrappers.

  Both types extend TGtkWidget.  TGtkWindow wraps a standalone top-level
  window; TGtkApplicationWindow associates a window with a TGtkApplication
  and adds application-level actions and menus.

  GTK window constructors return floating references, so CreateFromHandle
  is called with ASink=True. }
unit GtkWindow;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes, GLib, GObjectType, GObject, GtkTypes, GtkWidget, GtkApplication;

type
  TGtkWindow = class(TGtkWidget)
  public
    class function TypeID: GType; override;

    { Set the window title shown in the title bar. }
    procedure SetTitle(const ATitle: string);

    { Set the initial size in pixels.  Use -1 for either dimension to leave
      it unset. }
    procedure SetDefaultSize(AWidth, AHeight: Integer);

    { Present (raise and show) the window. }
    procedure Present;

    { Request that the window be closed.  The 'close-request' signal is
      emitted; if no handler returns TRUE the window is hidden. }
    procedure Close;

    { Set / get the single child widget displayed inside the window. }
    procedure SetChild(AChild: TGtkWidget);
    function  GetChild: TGtkWidget;

    { Modality and decoration }
    procedure SetModal(AModal: Boolean);
    procedure SetResizable(AResizable: Boolean);
    procedure SetDecorated(ADecorated: Boolean);

    { Returns True when this window is the active (focused) top-level. }
    function IsActive: Boolean;
  end;

  TGtkApplicationWindow = class(TGtkWindow)
  public
    class function TypeID: GType; override;

    { Create a new application window associated with AApp.
      The window is automatically registered with the application. }
    constructor CreateFor(AApp: TGtkApplication); reintroduce;
  end;

implementation

uses Gtk4FFI;

class function TGtkWindow.TypeID: GType;
begin
  Result := Gtk4FFI.gtk_window_get_type();
end;

procedure TGtkWindow.SetTitle(const ATitle: string);
begin
  if Handle <> nil then
    gtk_window_set_title(Handle, GLibStr(ATitle));
end;

procedure TGtkWindow.SetDefaultSize(AWidth, AHeight: Integer);
begin
  if Handle <> nil then
    gtk_window_set_default_size(Handle, gint(AWidth), gint(AHeight));
end;

procedure TGtkWindow.Present;
begin
  if Handle <> nil then
    gtk_window_present(Handle);
end;

procedure TGtkWindow.Close;
begin
  if Handle <> nil then
    gtk_window_close(Handle);
end;

procedure TGtkWindow.SetChild(AChild: TGtkWidget);
var
  ChildHandle: gpointer;
begin
  if Handle = nil then
    Exit;
  if AChild <> nil then
    ChildHandle := AChild.Handle
  else
    ChildHandle := nil;
  gtk_window_set_child(Handle, ChildHandle);
end;

function TGtkWindow.GetChild: TGtkWidget;
var
  P: gpointer;
begin
  Result := nil;
  if Handle = nil then
    Exit;
  P := gtk_window_get_child(Handle);
  if P <> nil then
    Result := TGtkWidget(TGtkWidget.Borrow(P));
end;

procedure TGtkWindow.SetModal(AModal: Boolean);
begin
  if Handle <> nil then
    gtk_window_set_modal(Handle, gboolean(AModal));
end;

procedure TGtkWindow.SetResizable(AResizable: Boolean);
begin
  if Handle <> nil then
    gtk_window_set_resizable(Handle, gboolean(AResizable));
end;

procedure TGtkWindow.SetDecorated(ADecorated: Boolean);
begin
  if Handle <> nil then
    gtk_window_set_decorated(Handle, gboolean(ADecorated));
end;

function TGtkWindow.IsActive: Boolean;
begin
  Result := (Handle <> nil) and Boolean(gtk_window_is_active(Handle));
end;

class function TGtkApplicationWindow.TypeID: GType;
begin
  Result := Gtk4FFI.gtk_application_window_get_type();
end;

constructor TGtkApplicationWindow.CreateFor(AApp: TGtkApplication);
var
  H: gpointer;
begin
  H := nil;
  if AApp <> nil then
    H := gtk_application_window_new(AApp.Handle);
  inherited CreateFromHandle(H, True);
end;

end.
