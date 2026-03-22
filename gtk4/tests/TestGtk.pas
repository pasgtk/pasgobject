{ Pascal-GObject - GTK4 binding smoke tests
  Checks that GTK4 GType queries and wrapper TypeID overrides work correctly.
  All tests are headless (no display required). }
program TestGtk;

{$mode objfpc}{$H+}

uses
  GTypes, GLib, GObjectType,
  GtkTypes, GtkClasses, GtkFFI;

var
  Pass, Fail: Integer;

procedure Check(const AName: string; AResult: Boolean);
begin
  if AResult then
  begin
    WriteLn('  PASS  ', AName);
    Inc(Pass);
  end
  else
  begin
    WriteLn('  FAIL  ', AName);
    Inc(Fail);
  end;
end;

begin
  g_type_init;

  WriteLn('=== TestGtk ===');
  WriteLn('');
  WriteLn('--- GTK4 GType availability ---');
  Check('gtk_widget_get_type non-zero',      gtk_widget_get_type() <> 0);
  Check('gtk_window_get_type non-zero',      gtk_window_get_type() <> 0);
  Check('gtk_application_get_type non-zero', gtk_application_get_type() <> 0);
  Check('gtk_application_window_get_type',   gtk_application_window_get_type() <> 0);
  Check('gtk_button_get_type non-zero',      gtk_button_get_type() <> 0);
  Check('gtk_label_get_type non-zero',       gtk_label_get_type() <> 0);
  Check('gtk_box_get_type non-zero',         gtk_box_get_type() <> 0);

  WriteLn('');
  WriteLn('--- Type hierarchy (GTypeIsA) ---');
  Check('button is-a widget',  GTypeIsA(gtk_button_get_type(), gtk_widget_get_type()));
  Check('label is-a widget',   GTypeIsA(gtk_label_get_type(), gtk_widget_get_type()));
  Check('box is-a widget',     GTypeIsA(gtk_box_get_type(), gtk_widget_get_type()));
  Check('window is-a widget',  GTypeIsA(gtk_window_get_type(), gtk_widget_get_type()));
  Check('appwindow is-a window', GTypeIsA(gtk_application_window_get_type(), gtk_window_get_type()));
  Check('button is-a GObject', GTypeIsA(gtk_button_get_type(), G_TYPE_OBJECT));

  WriteLn('');
  WriteLn('--- TypeID overrides ---');
  Check('TGtkWidget.TypeID = gtk_widget_get_type',   TGtkWidget.TypeID = gtk_widget_get_type());
  Check('TGtkWindow.TypeID = gtk_window_get_type',   TGtkWindow.TypeID = gtk_window_get_type());
  Check('TGtkButton.TypeID = gtk_button_get_type',   TGtkButton.TypeID = gtk_button_get_type());
  Check('TGtkLabel.TypeID = gtk_label_get_type',     TGtkLabel.TypeID = gtk_label_get_type());
  Check('TGtkBox.TypeID = gtk_box_get_type',         TGtkBox.TypeID = gtk_box_get_type());
  Check('TGtkApplication.TypeID',                    TGtkApplication.TypeID = gtk_application_get_type());
  Check('TGtkApplicationWindow.TypeID',              TGtkApplicationWindow.TypeID = gtk_application_window_get_type());

  WriteLn('');
  WriteLn('--- GtkTypes enum values ---');
  Check('GTK_ALIGN_FILL = 0',          Ord(GTK_ALIGN_FILL) = 0);
  Check('GTK_ALIGN_START = 1',         Ord(GTK_ALIGN_START) = 1);
  Check('GTK_ALIGN_CENTER = 3',        Ord(GTK_ALIGN_CENTER) = 3);
  Check('GTK_ORIENTATION_HORIZONTAL',  Ord(GTK_ORIENTATION_HORIZONTAL) = 0);
  Check('GTK_ORIENTATION_VERTICAL',    Ord(GTK_ORIENTATION_VERTICAL) = 1);
  Check('GTK_JUSTIFY_LEFT = 0',        Ord(GTK_JUSTIFY_LEFT) = 0);
  Check('GTK_JUSTIFY_CENTER = 2',      Ord(GTK_JUSTIFY_CENTER) = 2);

  WriteLn('');
  WriteLn('Results: ', Pass, ' passed, ', Fail, ' failed.');
  if Fail > 0 then
    Halt(1);
end.
