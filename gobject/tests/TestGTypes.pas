{ Pascal-GObject test: GTypes
  Verifies that all fundamental type aliases have the correct sizes,
  that the fundamental GType constant values match the GLib specification,
  and that core record layouts (GError, GObjectC, GValue) are correct. }
program TestGTypes;

{$mode objfpc}{$H+}

uses
  GTypes, GLib, GObjectType, GValue, GParam, GObject, GSignal, PasGObject;

var
  Passed : Integer = 0;
  Failed : Integer = 0;

procedure Check(ACondition: Boolean; const AMessage: string);
begin
  if ACondition then
  begin
    WriteLn('  PASS  ', AMessage);
    Inc(Passed);
  end
  else
  begin
    WriteLn('  FAIL  ', AMessage);
    Inc(Failed);
  end;
end;

procedure TestTypeSizes;
begin
  WriteLn('Type sizes');
  Check(SizeOf(gboolean) = 4,               'gboolean = 4 bytes');
  Check(SizeOf(gchar)    = 1,               'gchar = 1 byte');
  Check(SizeOf(gint)     = 4,               'gint = 4 bytes');
  Check(SizeOf(guint)    = 4,               'guint = 4 bytes');
  Check(SizeOf(gint8)    = 1,               'gint8 = 1 byte');
  Check(SizeOf(gint16)   = 2,               'gint16 = 2 bytes');
  Check(SizeOf(gint32)   = 4,               'gint32 = 4 bytes');
  Check(SizeOf(gint64)   = 8,               'gint64 = 8 bytes');
  Check(SizeOf(guint64)  = 8,               'guint64 = 8 bytes');
  Check(SizeOf(gfloat)   = 4,               'gfloat = 4 bytes');
  Check(SizeOf(gdouble)  = 8,               'gdouble = 8 bytes');
  Check(SizeOf(gsize)    = SizeOf(Pointer), 'gsize = pointer size');
  Check(SizeOf(GType)    = SizeOf(Pointer), 'GType = pointer size');
  Check(SizeOf(GQuark)   = 4,               'GQuark = 4 bytes');
end;

procedure TestFundamentalTypes;
begin
  WriteLn('Fundamental GType constants');
  Check(G_TYPE_INVALID   = GType(0),         'G_TYPE_INVALID = 0');
  Check(G_TYPE_NONE      = GType(1  shl 2),  'G_TYPE_NONE = 4');
  Check(G_TYPE_INTERFACE = GType(2  shl 2),  'G_TYPE_INTERFACE = 8');
  Check(G_TYPE_BOOLEAN   = GType(5  shl 2),  'G_TYPE_BOOLEAN = 20');
  Check(G_TYPE_INT       = GType(6  shl 2),  'G_TYPE_INT = 24');
  Check(G_TYPE_UINT      = GType(7  shl 2),  'G_TYPE_UINT = 28');
  Check(G_TYPE_INT64     = GType(10 shl 2),  'G_TYPE_INT64 = 40');
  Check(G_TYPE_FLOAT     = GType(14 shl 2),  'G_TYPE_FLOAT = 56');
  Check(G_TYPE_DOUBLE    = GType(15 shl 2),  'G_TYPE_DOUBLE = 60');
  Check(G_TYPE_STRING    = GType(16 shl 2),  'G_TYPE_STRING = 64');
  Check(G_TYPE_OBJECT    = GType(20 shl 2),  'G_TYPE_OBJECT = 80');
  Check(G_TYPE_VARIANT   = GType(21 shl 2),  'G_TYPE_VARIANT = 84');
end;

procedure TestStringHelpers;
begin
  WriteLn('String helpers');
  Check(PasStr(nil) = '',                           'PasStr(nil) = empty string');
  Check(PasStr(pgchar('hello')) = 'hello',          'PasStr round-trips a literal');
  Check(string(PChar(GLibStr('world'))) = 'world',  'GLibStr round-trips');
  Check(GLibStrDup('test') <> nil,                  'GLibStrDup returns non-nil');
end;

procedure TestGErrorLayout;
var
  E : GError;
begin
  WriteLn('GError record layout');
  Check(SizeOf(GError) >= SizeOf(GQuark) + SizeOf(gint) + SizeOf(pgchar),
    'GError has at least domain + code + message');
  E.domain  := 42;
  E.code    := -7;
  E.message := nil;
  Check(E.domain = 42,  'GError.domain assignment');
  Check(E.code   = -7,  'GError.code assignment');
  Check(E.message = nil,'GError.message nil');
end;

procedure TestGObjectCLayout;
var
  C : GObjectC;
begin
  WriteLn('GObjectC record layout');
  Check(SizeOf(GObjectC) >= SizeOf(GTypeInstance) + SizeOf(guint) + SizeOf(gpointer),
    'GObjectC has at least g_type_instance + ref_count + qdata');
  FillChar(C, SizeOf(C), 0);
  C.ref_count := 1;
  Check(C.ref_count = 1, 'GObjectC.ref_count assignment');
end;

procedure TestGValueLayout;
var
  V : GTypes.GValue;
begin
  WriteLn('GValue record layout');
  Check(SizeOf(GTypes.GValue) >= SizeOf(GType) + 2 * SizeOf(GValueData),
    'GValue has at least g_type + two GValueData slots');
  FillChar(V, SizeOf(V), 0);
  V.g_type := G_TYPE_INT;
  Check(V.g_type = G_TYPE_INT, 'GValue.g_type assignment');
  V.data[0].v_int := 99;
  Check(V.data[0].v_int = 99,  'GValue.data[0].v_int assignment');
end;

begin
  WriteLn('=== TestGTypes ===');
  WriteLn('');
  TestTypeSizes;
  WriteLn('');
  TestFundamentalTypes;
  WriteLn('');
  TestStringHelpers;
  WriteLn('');
  TestGErrorLayout;
  WriteLn('');
  TestGObjectCLayout;
  WriteLn('');
  TestGValueLayout;
  WriteLn('');
  WriteLn('Results: ', Passed, ' passed, ', Failed, ' failed');
  if Failed > 0 then
    Halt(1);
end.
