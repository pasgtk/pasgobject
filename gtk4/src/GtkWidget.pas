{ Pascal-GObject - GTK4 GtkWidget wrapper
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GtkWidget - TGtkWidget, the Pascal wrapper for GtkWidget.

  TGtkWidget wraps the GtkWidget C type and all GtkWidget vfuncs.  It is the
  common base class for every concrete GTK widget (TGtkButton, TGtkLabel, …).

  Instantiation: do not construct TGtkWidget directly; use a concrete subclass
  such as TGtkButton.  Concrete GTK widget constructors call CreateFromHandle
  with ASink=True because GtkWidget constructors return a floating reference. }
unit GtkWidget;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes, GLib, GObjectType, GObject, GtkTypes;

type
  TGtkWidget = class(TGObject)
  public
    { TypeID returns the GType registered by the GTK library for GtkWidget.
      It does NOT register a new Pascal GType. }
    class function TypeID: GType; override;

    { Visibility }
    procedure SetVisible(AVisible: Boolean);
    function  IsVisible: Boolean;

    { Sensitivity (enabled/disabled state) }
    procedure SetSensitive(ASensitive: Boolean);
    function  IsSensitive: Boolean;

    { Horizontal and vertical expand hints }
    procedure SetHExpand(AExpand: Boolean);
    function  GetHExpand: Boolean;
    procedure SetVExpand(AExpand: Boolean);
    function  GetVExpand: Boolean;

    { Alignment within the allocated area }
    procedure SetHAlign(AAlign: GtkAlign);
    function  GetHAlign: GtkAlign;
    procedure SetVAlign(AAlign: GtkAlign);
    function  GetVAlign: GtkAlign;

    { Minimum size request }
    procedure SetSizeRequest(AWidth, AHeight: Integer);
    procedure GetSizeRequest(out AWidth, AHeight: Integer);

    { Outer margin in CSS pixels }
    procedure SetMarginTop(AMargin: Integer);
    function  GetMarginTop: Integer;
    procedure SetMarginBottom(AMargin: Integer);
    function  GetMarginBottom: Integer;
    procedure SetMarginStart(AMargin: Integer);
    function  GetMarginStart: Integer;
    procedure SetMarginEnd(AMargin: Integer);
    function  GetMarginEnd: Integer;

    { CSS style classes }
    procedure AddCssClass(const AClass: string);
    procedure RemoveCssClass(const AClass: string);
    function  HasCssClass(const AClass: string): Boolean;

    { Parent widget in the widget tree (transfer:none).
      Returns nil if the widget has no parent. }
    function GetParent: TGtkWidget;

    { Request keyboard focus.  Returns True if focus was successfully claimed. }
    function GrabFocus: Boolean;

    { Schedule a redraw of this widget's area. }
    procedure QueueDraw;
  end;

implementation

uses Gtk4FFI;

class function TGtkWidget.TypeID: GType;
begin
  Result := Gtk4FFI.gtk_widget_get_type();
end;

procedure TGtkWidget.SetVisible(AVisible: Boolean);
begin
  if Handle <> nil then
    gtk_widget_set_visible(Handle, gboolean(AVisible));
end;

function TGtkWidget.IsVisible: Boolean;
begin
  Result := (Handle <> nil) and Boolean(gtk_widget_is_visible(Handle));
end;

procedure TGtkWidget.SetSensitive(ASensitive: Boolean);
begin
  if Handle <> nil then
    gtk_widget_set_sensitive(Handle, gboolean(ASensitive));
end;

function TGtkWidget.IsSensitive: Boolean;
begin
  Result := (Handle <> nil) and Boolean(gtk_widget_is_sensitive(Handle));
end;

procedure TGtkWidget.SetHExpand(AExpand: Boolean);
begin
  if Handle <> nil then
    gtk_widget_set_hexpand(Handle, gboolean(AExpand));
end;

function TGtkWidget.GetHExpand: Boolean;
begin
  Result := (Handle <> nil) and Boolean(gtk_widget_get_hexpand(Handle));
end;

procedure TGtkWidget.SetVExpand(AExpand: Boolean);
begin
  if Handle <> nil then
    gtk_widget_set_vexpand(Handle, gboolean(AExpand));
end;

function TGtkWidget.GetVExpand: Boolean;
begin
  Result := (Handle <> nil) and Boolean(gtk_widget_get_vexpand(Handle));
end;

procedure TGtkWidget.SetHAlign(AAlign: GtkAlign);
begin
  if Handle <> nil then
    gtk_widget_set_halign(Handle, gint(AAlign));
end;

function TGtkWidget.GetHAlign: GtkAlign;
begin
  if Handle <> nil then
    Result := GtkAlign(gtk_widget_get_halign(Handle))
  else
    Result := GTK_ALIGN_FILL;
end;

procedure TGtkWidget.SetVAlign(AAlign: GtkAlign);
begin
  if Handle <> nil then
    gtk_widget_set_valign(Handle, gint(AAlign));
end;

function TGtkWidget.GetVAlign: GtkAlign;
begin
  if Handle <> nil then
    Result := GtkAlign(gtk_widget_get_valign(Handle))
  else
    Result := GTK_ALIGN_FILL;
end;

procedure TGtkWidget.SetSizeRequest(AWidth, AHeight: Integer);
begin
  if Handle <> nil then
    gtk_widget_set_size_request(Handle, gint(AWidth), gint(AHeight));
end;

procedure TGtkWidget.GetSizeRequest(out AWidth, AHeight: Integer);
var
  W, H: gint;
begin
  if Handle <> nil then
  begin
    gtk_widget_get_size_request(Handle, W, H);
    AWidth  := Integer(W);
    AHeight := Integer(H);
  end
  else
  begin
    AWidth  := -1;
    AHeight := -1;
  end;
end;

procedure TGtkWidget.SetMarginTop(AMargin: Integer);
begin
  if Handle <> nil then
    gtk_widget_set_margin_top(Handle, gint(AMargin));
end;

function TGtkWidget.GetMarginTop: Integer;
begin
  if Handle <> nil then
    Result := Integer(gtk_widget_get_margin_top(Handle))
  else
    Result := 0;
end;

procedure TGtkWidget.SetMarginBottom(AMargin: Integer);
begin
  if Handle <> nil then
    gtk_widget_set_margin_bottom(Handle, gint(AMargin));
end;

function TGtkWidget.GetMarginBottom: Integer;
begin
  if Handle <> nil then
    Result := Integer(gtk_widget_get_margin_bottom(Handle))
  else
    Result := 0;
end;

procedure TGtkWidget.SetMarginStart(AMargin: Integer);
begin
  if Handle <> nil then
    gtk_widget_set_margin_start(Handle, gint(AMargin));
end;

function TGtkWidget.GetMarginStart: Integer;
begin
  if Handle <> nil then
    Result := Integer(gtk_widget_get_margin_start(Handle))
  else
    Result := 0;
end;

procedure TGtkWidget.SetMarginEnd(AMargin: Integer);
begin
  if Handle <> nil then
    gtk_widget_set_margin_end(Handle, gint(AMargin));
end;

function TGtkWidget.GetMarginEnd: Integer;
begin
  if Handle <> nil then
    Result := Integer(gtk_widget_get_margin_end(Handle))
  else
    Result := 0;
end;

procedure TGtkWidget.AddCssClass(const AClass: string);
begin
  if Handle <> nil then
    gtk_widget_add_css_class(Handle, GLibStr(AClass));
end;

procedure TGtkWidget.RemoveCssClass(const AClass: string);
begin
  if Handle <> nil then
    gtk_widget_remove_css_class(Handle, GLibStr(AClass));
end;

function TGtkWidget.HasCssClass(const AClass: string): Boolean;
begin
  Result := (Handle <> nil) and Boolean(gtk_widget_has_css_class(Handle, GLibStr(AClass)));
end;

function TGtkWidget.GetParent: TGtkWidget;
var
  P: gpointer;
begin
  Result := nil;
  if Handle = nil then
    Exit;
  P := gtk_widget_get_parent(Handle);
  if P = nil then
    Exit;
  Result := TGtkWidget(TGtkWidget.Borrow(P));
end;

function TGtkWidget.GrabFocus: Boolean;
begin
  Result := (Handle <> nil) and Boolean(gtk_widget_grab_focus(Handle));
end;

procedure TGtkWidget.QueueDraw;
begin
  if Handle <> nil then
    gtk_widget_queue_draw(Handle);
end;

end.
