{ Pascal-GObject - GTK4 GtkBox wrapper
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GtkBox - TGtkBox, the Pascal wrapper for GtkBox.

  GtkBox is a single-direction layout container.  Children are arranged
  either horizontally (GTK_ORIENTATION_HORIZONTAL) or vertically
  (GTK_ORIENTATION_VERTICAL) in the order they are appended. }
unit GtkBox;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes, GLib, GObjectType, GObject, GtkTypes, GtkWidget;

type
  TGtkBox = class(TGtkWidget)
  public
    class function TypeID: GType; override;

    { Create a box with the given orientation and pixel spacing between children. }
    constructor Create(AOrientation: GtkOrientation; ASpacing: Integer = 0); reintroduce;

    { Append a child at the end of the box. }
    procedure Append(AChild: TGtkWidget);

    { Prepend a child at the start of the box. }
    procedure Prepend(AChild: TGtkWidget);

    { Remove a child from the box.  The child is not destroyed. }
    procedure Remove(AChild: TGtkWidget);

    { Pixel spacing inserted between children. }
    procedure SetSpacing(ASpacing: Integer);
    function  GetSpacing: Integer;

    { When True, all children are given an equal share of the available space. }
    procedure SetHomogeneous(AHomogeneous: Boolean);
    function  GetHomogeneous: Boolean;
  end;

implementation

uses Gtk4FFI;

class function TGtkBox.TypeID: GType;
begin
  Result := Gtk4FFI.gtk_box_get_type();
end;

constructor TGtkBox.Create(AOrientation: GtkOrientation; ASpacing: Integer);
begin
  inherited CreateFromHandle(
    gtk_box_new(gint(AOrientation), gint(ASpacing)),
    True);
end;

procedure TGtkBox.Append(AChild: TGtkWidget);
begin
  if (Handle <> nil) and (AChild <> nil) and (AChild.Handle <> nil) then
    gtk_box_append(Handle, AChild.Handle);
end;

procedure TGtkBox.Prepend(AChild: TGtkWidget);
begin
  if (Handle <> nil) and (AChild <> nil) and (AChild.Handle <> nil) then
    gtk_box_prepend(Handle, AChild.Handle);
end;

procedure TGtkBox.Remove(AChild: TGtkWidget);
begin
  if (Handle <> nil) and (AChild <> nil) and (AChild.Handle <> nil) then
    gtk_box_remove(Handle, AChild.Handle);
end;

procedure TGtkBox.SetSpacing(ASpacing: Integer);
begin
  if Handle <> nil then
    gtk_box_set_spacing(Handle, gint(ASpacing));
end;

function TGtkBox.GetSpacing: Integer;
begin
  if Handle <> nil then
    Result := Integer(gtk_box_get_spacing(Handle))
  else
    Result := 0;
end;

procedure TGtkBox.SetHomogeneous(AHomogeneous: Boolean);
begin
  if Handle <> nil then
    gtk_box_set_homogeneous(Handle, gboolean(AHomogeneous));
end;

function TGtkBox.GetHomogeneous: Boolean;
begin
  Result := (Handle <> nil) and Boolean(gtk_box_get_homogeneous(Handle));
end;

end.
