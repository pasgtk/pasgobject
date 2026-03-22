{ Pascal-GObject - GTK4 GtkLabel wrapper
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GtkLabel - TGtkLabel, the Pascal wrapper for GtkLabel. }
unit GtkLabel;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes, GLib, GObjectType, GObject, GtkTypes, GtkWidget;

type
  TGtkLabel = class(TGtkWidget)
  public
    class function TypeID: GType; override;

    { Create a label with plain text.  Pass an empty string for no initial text. }
    constructor Create(const AText: string = ''); reintroduce;

    { Plain-text content. }
    procedure SetText(const AText: string);
    function  GetText: string;

    { Pango markup content (implies use_markup). }
    procedure SetMarkup(const AMarkup: string);

    { Control whether the label interprets Pango markup. }
    procedure SetUseMarkup(AUse: Boolean);

    { Wrap long lines at word boundaries. }
    procedure SetWrap(AWrap: Boolean);

    { Text justification (left, right, center, fill). }
    procedure SetJustify(AJustify: GtkJustification);

    { Horizontal and vertical alignment within the label's allocation. }
    procedure SetXAlign(AXAlign: Single);
    procedure SetYAlign(AYAlign: Single);

    { Allow the user to select and copy label text. }
    procedure SetSelectable(ASelectable: Boolean);
  end;

implementation

uses Gtk4FFI;

class function TGtkLabel.TypeID: GType;
begin
  Result := Gtk4FFI.gtk_label_get_type();
end;

constructor TGtkLabel.Create(const AText: string);
begin
  if AText = '' then
    inherited CreateFromHandle(gtk_label_new(nil), True)
  else
    inherited CreateFromHandle(gtk_label_new(GLibStr(AText)), True);
end;

procedure TGtkLabel.SetText(const AText: string);
begin
  if Handle <> nil then
    gtk_label_set_text(Handle, GLibStr(AText));
end;

function TGtkLabel.GetText: string;
begin
  if Handle <> nil then
    Result := PasStr(gtk_label_get_text(Handle))
  else
    Result := '';
end;

procedure TGtkLabel.SetMarkup(const AMarkup: string);
begin
  if Handle <> nil then
    gtk_label_set_markup(Handle, GLibStr(AMarkup));
end;

procedure TGtkLabel.SetUseMarkup(AUse: Boolean);
begin
  if Handle <> nil then
    gtk_label_set_use_markup(Handle, gboolean(AUse));
end;

procedure TGtkLabel.SetWrap(AWrap: Boolean);
begin
  if Handle <> nil then
    gtk_label_set_wrap(Handle, gboolean(AWrap));
end;

procedure TGtkLabel.SetJustify(AJustify: GtkJustification);
begin
  if Handle <> nil then
    gtk_label_set_justify(Handle, gint(AJustify));
end;

procedure TGtkLabel.SetXAlign(AXAlign: Single);
begin
  if Handle <> nil then
    gtk_label_set_xalign(Handle, gfloat(AXAlign));
end;

procedure TGtkLabel.SetYAlign(AYAlign: Single);
begin
  if Handle <> nil then
    gtk_label_set_yalign(Handle, gfloat(AYAlign));
end;

procedure TGtkLabel.SetSelectable(ASelectable: Boolean);
begin
  if Handle <> nil then
    gtk_label_set_selectable(Handle, gboolean(ASelectable));
end;

end.
