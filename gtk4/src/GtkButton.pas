{ Pascal-GObject - GTK4 GtkButton wrapper
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GtkButton - TGtkButton, the Pascal wrapper for GtkButton.

  TGtkButton extends TGtkWidget.  Constructors create a GTK button using the
  appropriate gtk_button_new_* function and wrap the floating reference via
  CreateFromHandle with ASink=True.

  The primary signal is 'clicked', emitted when the button is activated. }
unit GtkButton;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes, GLib, GObjectType, GObject, GtkTypes, GtkWidget;

type
  TGtkButton = class(TGtkWidget)
  public
    class function TypeID: GType; override;

    { Create a button with optional label text.
      If ALabel is empty, the button has no label child. }
    constructor Create(const ALabel: string = ''); reintroduce;

    { Create a button whose label may contain underline mnemonics. }
    constructor CreateWithMnemonic(const ALabel: string);

    { Label text (not markup). }
    procedure SetLabel(const ALabel: string);
    function  GetLabel: string;

    { Replace the button's child widget (overrides the label). }
    procedure SetChild(AChild: TGtkWidget);
    function  GetChild: TGtkWidget;
  end;

implementation

uses Gtk4FFI;

class function TGtkButton.TypeID: GType;
begin
  Result := Gtk4FFI.gtk_button_get_type();
end;

constructor TGtkButton.Create(const ALabel: string);
var
  H: gpointer;
begin
  if ALabel = '' then
    H := gtk_button_new
  else
    H := gtk_button_new_with_label(GLibStr(ALabel));
  inherited CreateFromHandle(H, True);
end;

constructor TGtkButton.CreateWithMnemonic(const ALabel: string);
begin
  inherited CreateFromHandle(gtk_button_new_with_mnemonic(GLibStr(ALabel)), True);
end;

procedure TGtkButton.SetLabel(const ALabel: string);
begin
  if Handle <> nil then
    gtk_button_set_label(Handle, GLibStr(ALabel));
end;

function TGtkButton.GetLabel: string;
begin
  if Handle <> nil then
    Result := PasStr(gtk_button_get_label(Handle))
  else
    Result := '';
end;

procedure TGtkButton.SetChild(AChild: TGtkWidget);
var
  ChildHandle: gpointer;
begin
  if Handle = nil then
    Exit;
  if AChild <> nil then
    ChildHandle := AChild.Handle
  else
    ChildHandle := nil;
  gtk_button_set_child(Handle, ChildHandle);
end;

function TGtkButton.GetChild: TGtkWidget;
var
  P: gpointer;
begin
  Result := nil;
  if Handle = nil then
    Exit;
  P := gtk_button_get_child(Handle);
  if P <> nil then
    Result := TGtkWidget(TGtkWidget.Borrow(P));
end;

end.
