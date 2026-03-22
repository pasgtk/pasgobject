{ Pascal-GObject - Pascal bindings for the GObject type system
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GTypes - Fundamental GLib/GObject type aliases and record definitions.

  Every other unit in the binding uses GTypes as its lowest-level
  dependency.  This unit has no external library dependencies of its own. }
unit GTypes;

{$mode objfpc}{$H+}{$PackRecords C}

interface

type
  gboolean  = LongBool;
  gchar     = Char;
  guchar    = Byte;
  gshort    = SmallInt;
  gushort   = Word;
  gint      = LongInt;
  guint     = LongWord;
  glong     = {$IF SizeOf(Pointer) = 8}Int64{$ELSE}LongInt{$ENDIF};
  gulong    = {$IF SizeOf(Pointer) = 8}QWord{$ELSE}LongWord{$ENDIF};
  gint8     = ShortInt;
  guint8    = Byte;
  gint16    = SmallInt;
  guint16   = Word;
  gint32    = LongInt;
  guint32   = LongWord;
  gint64    = Int64;
  guint64   = QWord;
  gfloat    = Single;
  gdouble   = Double;
  gsize     = PtrUInt;
  gssize    = PtrInt;
  goffset   = Int64;
  gpointer  = Pointer;
  gconstpointer = Pointer;
  gintptr   = PtrInt;
  guintptr  = PtrUInt;

  pgboolean = ^gboolean;
  pgchar    = ^gchar;
  pguchar   = ^guchar;
  pgshort   = ^gshort;
  pgushort  = ^gushort;
  pgint     = ^gint;
  pguint    = ^guint;
  pglong    = ^glong;
  pgulong   = ^gulong;
  pgint8    = ^gint8;
  pguint8   = ^guint8;
  pgint16   = ^gint16;
  pguint16  = ^guint16;
  pgint32   = ^gint32;
  pguint32  = ^guint32;
  pgint64   = ^gint64;
  pguint64  = ^guint64;
  pgfloat   = ^gfloat;
  pgdouble  = ^gdouble;
  pgsize    = ^gsize;
  pgssize   = ^gssize;
  pgpointer = ^gpointer;
  ppgchar   = ^pgchar;

  GType  = gsize;
  PGType = ^GType;

  GQuark = guint32;

  GError = record
    domain  : GQuark;
    code    : gint;
    message : pgchar;
  end;
  PGError  = ^GError;
  PPGError = ^PGError;

  GDestroyNotify   = procedure(data: gpointer); cdecl;
  GToggleNotify    = procedure(data: gpointer; object_: gpointer; is_last_ref: gboolean); cdecl;
  GFunc            = procedure(data: gpointer; user_data: gpointer); cdecl;
  GCompareFunc     = function(a: gconstpointer; b: gconstpointer): gint; cdecl;
  GCompareDataFunc = function(a: gconstpointer; b: gconstpointer; user_data: gpointer): gint; cdecl;
  GHashFunc        = function(key: gconstpointer): guint; cdecl;
  GEqualFunc       = function(a: gconstpointer; b: gconstpointer): gboolean; cdecl;
  GFreeFunc        = procedure(data: gpointer); cdecl;
  GCopyFunc        = function(src: gconstpointer; data: gpointer): gpointer; cdecl;
  GSourceFunc      = function(data: gpointer): gboolean; cdecl;

  GClosure  = record end;
  PGClosure = ^GClosure;

  GClosureNotify  = procedure(data: gpointer; closure: PGClosure); cdecl;
  GClosureMarshal = procedure(closure: PGClosure; return_value: gpointer;
                              n_param_values: guint; param_values: gpointer;
                              invocation_hint: gpointer; marshal_data: gpointer); cdecl;

  GList = record
    data : gpointer;
    next : Pointer;
    prev : Pointer;
  end;
  PGList = ^GList;

  GSList = record
    data : gpointer;
    next : Pointer;
  end;
  PGSList = ^GSList;

  GHashTable  = record end;
  PGHashTable = ^GHashTable;

  GString = record
    str           : pgchar;
    len           : gsize;
    allocated_len : gsize;
  end;
  PGString = ^GString;

  GVariant  = record end;
  PGVariant = ^GVariant;

  GMainLoop     = record end;
  PGMainLoop    = ^GMainLoop;
  GMainContext  = record end;
  PGMainContext = ^GMainContext;
  GSource       = record end;
  PGSource      = ^GSource;

  GTypeClass = record
    g_type : GType;
  end;
  PGTypeClass = ^GTypeClass;

  GTypeInstance = record
    g_class : PGTypeClass;
  end;
  PGTypeInstance = ^GTypeInstance;

  GTypeInterface = record
    g_type          : GType;
    g_instance_type : GType;
  end;
  PGTypeInterface = ^GTypeInterface;

  GTypeFlags            = guint;
  GTypeFundamentalFlags = guint;

  GBaseInitFunc          = procedure(g_class: gpointer); cdecl;
  GBaseFinalizeFunc      = procedure(g_class: gpointer); cdecl;
  GClassInitFunc         = procedure(g_class: gpointer; class_data: gpointer); cdecl;
  GClassFinalizeFunc     = procedure(g_class: gpointer; class_data: gpointer); cdecl;
  GInstanceInitFunc      = procedure(instance: PGTypeInstance; g_class: gpointer); cdecl;
  GInterfaceInitFunc     = procedure(g_iface: gpointer; iface_data: gpointer); cdecl;
  GInterfaceFinalizeFunc = procedure(g_iface: gpointer; iface_data: gpointer); cdecl;

  GTypeInfo = record
    class_size     : guint16;
    base_init      : GBaseInitFunc;
    base_finalize  : GBaseFinalizeFunc;
    class_init     : GClassInitFunc;
    class_finalize : GClassFinalizeFunc;
    class_data     : gconstpointer;
    instance_size  : guint16;
    n_preallocs    : guint16;
    instance_init  : GInstanceInitFunc;
    value_table    : gpointer;
  end;
  PGTypeInfo = ^GTypeInfo;

  GTypeFundamentalInfo = record
    type_flags : GTypeFundamentalFlags;
  end;
  PGTypeFundamentalInfo = ^GTypeFundamentalInfo;

  GInterfaceInfo = record
    interface_init     : GInterfaceInitFunc;
    interface_finalize : GInterfaceFinalizeFunc;
    interface_data     : gpointer;
  end;
  PGInterfaceInfo = ^GInterfaceInfo;

  GValueData = record
    case Integer of
      0: (v_int     : gint);
      1: (v_uint    : guint);
      2: (v_long    : glong);
      3: (v_ulong   : gulong);
      4: (v_int64   : gint64);
      5: (v_uint64  : guint64);
      6: (v_float   : gfloat);
      7: (v_double  : gdouble);
      8: (v_pointer : gpointer);
  end;

  GValue = record
    g_type : GType;
    data   : array[0..1] of GValueData;
  end;
  PGValue  = ^GValue;
  PPGValue = ^PGValue;

  GValueTransform = procedure(const src_value: PGValue; dest_value: PGValue); cdecl;

  GParamFlags = guint;

  GParamSpec = record
    g_type_instance : GTypeInstance;
    name            : pgchar;
    flags           : GParamFlags;
    value_type      : GType;
    owner_type      : GType;
    _nick           : pgchar;
    _blurb          : pgchar;
    _qdata          : gpointer;
    _ref_count      : guint;
    _param_id       : guint;
  end;
  PGParamSpec  = ^GParamSpec;
  PPGParamSpec = ^PGParamSpec;

  GObjectSetPropertyFunc  = procedure(obj: Pointer; prop_id: guint; const value: Pointer; pspec: Pointer); cdecl;
  GObjectGetPropertyFunc  = procedure(obj: Pointer; prop_id: guint; value: Pointer; pspec: Pointer); cdecl;
  GObjectFinalizeFunc     = procedure(obj: Pointer); cdecl;
  GObjectDisposeFunc      = procedure(obj: Pointer); cdecl;
  GObjectConstructedFunc  = procedure(obj: Pointer); cdecl;

  GObjectC = record
    g_type_instance : GTypeInstance;
    ref_count       : guint;
    qdata           : gpointer;
  end;
  PGObjectC = ^GObjectC;

  GObjectClass = record
    g_type_class                : GTypeClass;
    construct_properties        : PGSList;
    constructor_                : gpointer;
    set_property                : GObjectSetPropertyFunc;
    get_property                : GObjectGetPropertyFunc;
    dispose                     : GObjectDisposeFunc;
    finalize                    : GObjectFinalizeFunc;
    dispatch_properties_changed : gpointer;
    notify                      : gpointer;
    constructed                 : GObjectConstructedFunc;
    flags                       : guint64;
    n_construct_properties      : gsize;
    pspecs                      : gpointer;
    n_pspecs                    : gsize;
    pdummy                      : array[0..2] of gpointer;
  end;
  PGObjectClass = ^GObjectClass;

  GNotifyFunc = procedure(pspec: PGParamSpec; gobject: PGObjectC); cdecl;

  GSignalFlags       = guint;
  GSignalMatchType   = guint;
  GConnectFlags      = guint;
  GSignalCMarshaller = GClosureMarshal;

  GSignalAccumulator = function(ihint: gpointer; return_accu: PGValue;
    handler_return: PGValue; data: gpointer): gboolean; cdecl;

  GSignalQuery = record
    signal_id    : guint;
    signal_name  : pgchar;
    itype        : GType;
    signal_flags : GSignalFlags;
    return_type  : GType;
    n_params     : guint;
    param_types  : PGType;
  end;
  PGSignalQuery = ^GSignalQuery;

implementation

end.
