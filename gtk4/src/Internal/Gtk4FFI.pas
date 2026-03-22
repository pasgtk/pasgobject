{ Pascal-GObject - GTK4 FFI declarations
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ Gtk4FFI - Raw external declarations for libgtk-4.
  All symbols in this unit are direct C bindings.  Do not use this unit
  from application code; use the public GTK4 wrapper units instead. }
unit Gtk4FFI;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes;

const
  libgtk4 = 'libgtk-4.so.1';
  libgio   = 'libgio-2.0.so.0';

{ GType queries }
function gtk_widget_get_type: GType; external libgtk4;
function gtk_window_get_type: GType; external libgtk4;
function gtk_application_get_type: GType; external libgtk4;
function gtk_application_window_get_type: GType; external libgtk4;
function gtk_button_get_type: GType; external libgtk4;
function gtk_label_get_type: GType; external libgtk4;
function gtk_box_get_type: GType; external libgtk4;

{ GtkApplication (GApplication subclass, not a widget) }
function  gtk_application_new(application_id: pgchar; flags: guint32): gpointer; external libgtk4;
{ GApplication methods live in libgio }
function  g_application_run(application: gpointer; argc: gint; argv: gpointer): gint; external libgio;
procedure g_application_quit(application: gpointer); external libgio;
procedure g_application_hold(application: gpointer); external libgio;
procedure g_application_release(application: gpointer); external libgio;

{ GtkApplicationWindow }
function gtk_application_window_new(application: gpointer): gpointer; external libgtk4;

{ GtkWindow }
procedure gtk_window_set_title(window: gpointer; title: pgchar); external libgtk4;
procedure gtk_window_set_default_size(window: gpointer; width: gint; height: gint); external libgtk4;
procedure gtk_window_present(window: gpointer); external libgtk4;
procedure gtk_window_close(window: gpointer); external libgtk4;
procedure gtk_window_set_child(window: gpointer; child: gpointer); external libgtk4;
function  gtk_window_get_child(window: gpointer): gpointer; external libgtk4;
procedure gtk_window_set_modal(window: gpointer; modal: gboolean); external libgtk4;
procedure gtk_window_set_resizable(window: gpointer; resizable: gboolean); external libgtk4;
procedure gtk_window_set_decorated(window: gpointer; setting: gboolean); external libgtk4;
function  gtk_window_is_active(window: gpointer): gboolean; external libgtk4;

{ GtkWidget }
procedure gtk_widget_set_visible(widget: gpointer; visible: gboolean); external libgtk4;
function  gtk_widget_is_visible(widget: gpointer): gboolean; external libgtk4;
procedure gtk_widget_set_sensitive(widget: gpointer; sensitive: gboolean); external libgtk4;
function  gtk_widget_is_sensitive(widget: gpointer): gboolean; external libgtk4;
procedure gtk_widget_set_hexpand(widget: gpointer; expand: gboolean); external libgtk4;
function  gtk_widget_get_hexpand(widget: gpointer): gboolean; external libgtk4;
procedure gtk_widget_set_vexpand(widget: gpointer; expand: gboolean); external libgtk4;
function  gtk_widget_get_vexpand(widget: gpointer): gboolean; external libgtk4;
procedure gtk_widget_set_halign(widget: gpointer; align: gint); external libgtk4;
function  gtk_widget_get_halign(widget: gpointer): gint; external libgtk4;
procedure gtk_widget_set_valign(widget: gpointer; align: gint); external libgtk4;
function  gtk_widget_get_valign(widget: gpointer): gint; external libgtk4;
procedure gtk_widget_set_size_request(widget: gpointer; width: gint; height: gint); external libgtk4;
procedure gtk_widget_get_size_request(widget: gpointer; out width: gint; out height: gint); external libgtk4;
procedure gtk_widget_set_margin_top(widget: gpointer; margin: gint); external libgtk4;
function  gtk_widget_get_margin_top(widget: gpointer): gint; external libgtk4;
procedure gtk_widget_set_margin_bottom(widget: gpointer; margin: gint); external libgtk4;
function  gtk_widget_get_margin_bottom(widget: gpointer): gint; external libgtk4;
procedure gtk_widget_set_margin_start(widget: gpointer; margin: gint); external libgtk4;
function  gtk_widget_get_margin_start(widget: gpointer): gint; external libgtk4;
procedure gtk_widget_set_margin_end(widget: gpointer; margin: gint); external libgtk4;
function  gtk_widget_get_margin_end(widget: gpointer): gint; external libgtk4;
procedure gtk_widget_add_css_class(widget: gpointer; css_class: pgchar); external libgtk4;
procedure gtk_widget_remove_css_class(widget: gpointer; css_class: pgchar); external libgtk4;
function  gtk_widget_has_css_class(widget: gpointer; css_class: pgchar): gboolean; external libgtk4;
function  gtk_widget_get_parent(widget: gpointer): gpointer; external libgtk4;
function  gtk_widget_grab_focus(widget: gpointer): gboolean; external libgtk4;
procedure gtk_widget_queue_draw(widget: gpointer); external libgtk4;

{ GtkButton }
function  gtk_button_new: gpointer; external libgtk4;
function  gtk_button_new_with_label(label_: pgchar): gpointer; external libgtk4;
function  gtk_button_new_with_mnemonic(label_: pgchar): gpointer; external libgtk4;
procedure gtk_button_set_label(button: gpointer; label_: pgchar); external libgtk4;
function  gtk_button_get_label(button: gpointer): pgchar; external libgtk4;
procedure gtk_button_set_child(button: gpointer; child: gpointer); external libgtk4;
function  gtk_button_get_child(button: gpointer): gpointer; external libgtk4;

{ GtkLabel }
function  gtk_label_new(str: pgchar): gpointer; external libgtk4;
procedure gtk_label_set_text(label_: gpointer; str: pgchar); external libgtk4;
function  gtk_label_get_text(label_: gpointer): pgchar; external libgtk4;
procedure gtk_label_set_markup(label_: gpointer; str: pgchar); external libgtk4;
procedure gtk_label_set_use_markup(label_: gpointer; setting: gboolean); external libgtk4;
procedure gtk_label_set_wrap(label_: gpointer; wrap: gboolean); external libgtk4;
procedure gtk_label_set_justify(label_: gpointer; jtype: gint); external libgtk4;
procedure gtk_label_set_xalign(label_: gpointer; xalign: gfloat); external libgtk4;
procedure gtk_label_set_yalign(label_: gpointer; yalign: gfloat); external libgtk4;
procedure gtk_label_set_selectable(label_: gpointer; setting: gboolean); external libgtk4;

{ GtkBox }
function  gtk_box_new(orientation: gint; spacing: gint): gpointer; external libgtk4;
procedure gtk_box_append(box: gpointer; child: gpointer); external libgtk4;
procedure gtk_box_prepend(box: gpointer; child: gpointer); external libgtk4;
procedure gtk_box_remove(box: gpointer; child: gpointer); external libgtk4;
procedure gtk_box_set_spacing(box: gpointer; spacing: gint); external libgtk4;
function  gtk_box_get_spacing(box: gpointer): gint; external libgtk4;
procedure gtk_box_set_homogeneous(box: gpointer; homogeneous: gboolean); external libgtk4;
function  gtk_box_get_homogeneous(box: gpointer): gboolean; external libgtk4;

implementation

end.
