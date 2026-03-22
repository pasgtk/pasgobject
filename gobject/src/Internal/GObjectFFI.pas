{ Pascal-GObject - Pascal bindings for the GObject type system
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GObjectFFI - Raw extern declarations for libgobject-2.0.

  This unit contains every external symbol imported from libgobject-2.0.
  All higher-level units use this unit; they must not declare their own
  external bindings for GObject library symbols. }
unit GObjectFFI;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes, GLibFFI;

const
  GObjectLibrary = 'libgobject-2.0.so.0';

procedure g_type_init; cdecl; external GObjectLibrary;
function g_type_name(type_id: GType): pgchar; cdecl; external GObjectLibrary;
function g_type_from_name(name: pgchar): GType; cdecl; external GObjectLibrary;
function g_type_parent(type_id: GType): GType; cdecl; external GObjectLibrary;
function g_type_depth(type_id: GType): guint; cdecl; external GObjectLibrary;
function g_type_next_base(leaf_type: GType; root_type: GType): GType; cdecl; external GObjectLibrary;
function g_type_is_a(type_id: GType; is_a_type: GType): gboolean; cdecl; external GObjectLibrary;
function g_type_class_ref(type_id: GType): PGTypeClass; cdecl; external GObjectLibrary;
function g_type_class_peek(type_id: GType): PGTypeClass; cdecl; external GObjectLibrary;
function g_type_class_peek_static(type_id: GType): PGTypeClass; cdecl; external GObjectLibrary;
procedure g_type_class_unref(g_class: PGTypeClass); cdecl; external GObjectLibrary;
function g_type_class_peek_parent(g_class: PGTypeClass): PGTypeClass; cdecl; external GObjectLibrary;
function g_type_interface_peek(instance_class: gpointer; iface_type: GType): gpointer; cdecl; external GObjectLibrary;
function g_type_register_static(parent_type: GType; type_name: pgchar;
  const info: PGTypeInfo; flags: GTypeFlags): GType; cdecl; external GObjectLibrary;
function g_type_register_static_simple(parent_type: GType; type_name: pgchar;
  class_size: guint; class_init: GClassInitFunc;
  instance_size: guint; instance_init: GInstanceInitFunc;
  flags: GTypeFlags): GType; cdecl; external GObjectLibrary;
procedure g_type_add_interface_static(instance_type: GType; interface_type: GType;
  const info: PGInterfaceInfo); cdecl; external GObjectLibrary;
function g_type_check_instance_is_a(instance: PGTypeInstance; iface_type: GType): gboolean; cdecl; external GObjectLibrary;
function g_type_check_class_is_a(g_class: PGTypeClass; is_a_type: GType): gboolean; cdecl; external GObjectLibrary;
function g_type_check_is_value_type(type_id: GType): gboolean; cdecl; external GObjectLibrary;
function g_type_children(type_id: GType; n_children: pguint): PGType; cdecl; external GObjectLibrary;
function g_type_interfaces(type_id: GType; n_interfaces: pguint): PGType; cdecl; external GObjectLibrary;

function g_value_init(value: PGValue; g_type: GType): PGValue; cdecl; external GObjectLibrary;
procedure g_value_copy(const src_value: PGValue; dest_value: PGValue); cdecl; external GObjectLibrary;
function g_value_reset(value: PGValue): PGValue; cdecl; external GObjectLibrary;
procedure g_value_unset(value: PGValue); cdecl; external GObjectLibrary;

procedure g_value_set_boolean(value: PGValue; v_boolean: gboolean); cdecl; external GObjectLibrary;
function g_value_get_boolean(const value: PGValue): gboolean; cdecl; external GObjectLibrary;
procedure g_value_set_char(value: PGValue; v_char: gchar); cdecl; external GObjectLibrary;
function g_value_get_char(const value: PGValue): gchar; cdecl; external GObjectLibrary;
procedure g_value_set_uchar(value: PGValue; v_uchar: guchar); cdecl; external GObjectLibrary;
function g_value_get_uchar(const value: PGValue): guchar; cdecl; external GObjectLibrary;
procedure g_value_set_int(value: PGValue; v_int: gint); cdecl; external GObjectLibrary;
function g_value_get_int(const value: PGValue): gint; cdecl; external GObjectLibrary;
procedure g_value_set_uint(value: PGValue; v_uint: guint); cdecl; external GObjectLibrary;
function g_value_get_uint(const value: PGValue): guint; cdecl; external GObjectLibrary;
procedure g_value_set_long(value: PGValue; v_long: glong); cdecl; external GObjectLibrary;
function g_value_get_long(const value: PGValue): glong; cdecl; external GObjectLibrary;
procedure g_value_set_ulong(value: PGValue; v_ulong: gulong); cdecl; external GObjectLibrary;
function g_value_get_ulong(const value: PGValue): gulong; cdecl; external GObjectLibrary;
procedure g_value_set_int64(value: PGValue; v_int64: gint64); cdecl; external GObjectLibrary;
function g_value_get_int64(const value: PGValue): gint64; cdecl; external GObjectLibrary;
procedure g_value_set_uint64(value: PGValue; v_uint64: guint64); cdecl; external GObjectLibrary;
function g_value_get_uint64(const value: PGValue): guint64; cdecl; external GObjectLibrary;
procedure g_value_set_float(value: PGValue; v_float: gfloat); cdecl; external GObjectLibrary;
function g_value_get_float(const value: PGValue): gfloat; cdecl; external GObjectLibrary;
procedure g_value_set_double(value: PGValue; v_double: gdouble); cdecl; external GObjectLibrary;
function g_value_get_double(const value: PGValue): gdouble; cdecl; external GObjectLibrary;
procedure g_value_set_string(value: PGValue; v_string: pgchar); cdecl; external GObjectLibrary;
procedure g_value_set_static_string(value: PGValue; v_string: pgchar); cdecl; external GObjectLibrary;
function g_value_get_string(const value: PGValue): pgchar; cdecl; external GObjectLibrary;
function g_value_dup_string(const value: PGValue): pgchar; cdecl; external GObjectLibrary;
procedure g_value_set_pointer(value: PGValue; v_pointer: gpointer); cdecl; external GObjectLibrary;
function g_value_get_pointer(const value: PGValue): gpointer; cdecl; external GObjectLibrary;
procedure g_value_set_object(value: PGValue; v_object: gpointer); cdecl; external GObjectLibrary;
function g_value_get_object(const value: PGValue): gpointer; cdecl; external GObjectLibrary;
function g_value_dup_object(const value: PGValue): gpointer; cdecl; external GObjectLibrary;
procedure g_value_set_boxed(value: PGValue; v_boxed: gconstpointer); cdecl; external GObjectLibrary;
procedure g_value_set_static_boxed(value: PGValue; v_boxed: gconstpointer); cdecl; external GObjectLibrary;
function g_value_get_boxed(const value: PGValue): gpointer; cdecl; external GObjectLibrary;
function g_value_dup_boxed(const value: PGValue): gpointer; cdecl; external GObjectLibrary;
procedure g_value_set_param(value: PGValue; param: gpointer); cdecl; external GObjectLibrary;
function g_value_get_param(const value: PGValue): gpointer; cdecl; external GObjectLibrary;
function g_value_dup_param(const value: PGValue): gpointer; cdecl; external GObjectLibrary;
procedure g_value_set_variant(value: PGValue; variant: PGVariant); cdecl; external GObjectLibrary;
function g_value_get_variant(const value: PGValue): PGVariant; cdecl; external GObjectLibrary;
function g_value_dup_variant(const value: PGValue): PGVariant; cdecl; external GObjectLibrary;
procedure g_value_set_enum(value: PGValue; v_enum: gint); cdecl; external GObjectLibrary;
function g_value_get_enum(const value: PGValue): gint; cdecl; external GObjectLibrary;
procedure g_value_set_flags(value: PGValue; v_flags: guint); cdecl; external GObjectLibrary;
function g_value_get_flags(const value: PGValue): guint; cdecl; external GObjectLibrary;
function g_value_type_compatible(src_type: GType; dest_type: GType): gboolean; cdecl; external GObjectLibrary;
function g_value_type_transformable(src_type: GType; dest_type: GType): gboolean; cdecl; external GObjectLibrary;
function g_value_transform(const src_value: PGValue; dest_value: PGValue): gboolean; cdecl; external GObjectLibrary;

function g_param_spec_boolean(name: pgchar; nick: pgchar; blurb: pgchar;
  default_value: gboolean; flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_char(name: pgchar; nick: pgchar; blurb: pgchar;
  minimum: gchar; maximum: gchar; default_value: gchar;
  flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_uchar(name: pgchar; nick: pgchar; blurb: pgchar;
  minimum: guchar; maximum: guchar; default_value: guchar;
  flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_int(name: pgchar; nick: pgchar; blurb: pgchar;
  minimum: gint; maximum: gint; default_value: gint;
  flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_uint(name: pgchar; nick: pgchar; blurb: pgchar;
  minimum: guint; maximum: guint; default_value: guint;
  flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_long(name: pgchar; nick: pgchar; blurb: pgchar;
  minimum: glong; maximum: glong; default_value: glong;
  flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_ulong(name: pgchar; nick: pgchar; blurb: pgchar;
  minimum: gulong; maximum: gulong; default_value: gulong;
  flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_int64(name: pgchar; nick: pgchar; blurb: pgchar;
  minimum: gint64; maximum: gint64; default_value: gint64;
  flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_uint64(name: pgchar; nick: pgchar; blurb: pgchar;
  minimum: guint64; maximum: guint64; default_value: guint64;
  flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_float(name: pgchar; nick: pgchar; blurb: pgchar;
  minimum: gfloat; maximum: gfloat; default_value: gfloat;
  flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_double(name: pgchar; nick: pgchar; blurb: pgchar;
  minimum: gdouble; maximum: gdouble; default_value: gdouble;
  flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_string(name: pgchar; nick: pgchar; blurb: pgchar;
  default_value: pgchar; flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_pointer(name: pgchar; nick: pgchar; blurb: pgchar;
  flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_boxed(name: pgchar; nick: pgchar; blurb: pgchar;
  boxed_type: GType; flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_object(name: pgchar; nick: pgchar; blurb: pgchar;
  object_type: GType; flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_enum(name: pgchar; nick: pgchar; blurb: pgchar;
  enum_type: GType; default_value: gint;
  flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_flags(name: pgchar; nick: pgchar; blurb: pgchar;
  flags_type: GType; default_value: guint;
  flags: GParamFlags): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_ref(pspec: PGParamSpec): PGParamSpec; cdecl; external GObjectLibrary;
procedure g_param_spec_unref(pspec: PGParamSpec); cdecl; external GObjectLibrary;
function g_param_spec_ref_sink(pspec: PGParamSpec): PGParamSpec; cdecl; external GObjectLibrary;
function g_param_spec_get_name(pspec: PGParamSpec): pgchar; cdecl; external GObjectLibrary;
function g_param_spec_get_nick(pspec: PGParamSpec): pgchar; cdecl; external GObjectLibrary;
function g_param_spec_get_blurb(pspec: PGParamSpec): pgchar; cdecl; external GObjectLibrary;
function g_param_spec_get_default_value(pspec: PGParamSpec): PGValue; cdecl; external GObjectLibrary;
function g_param_value_validate(pspec: PGParamSpec; value: PGValue): gboolean; cdecl; external GObjectLibrary;
function g_param_value_defaults(pspec: PGParamSpec; value: PGValue): gboolean; cdecl; external GObjectLibrary;
procedure g_param_value_set_default(pspec: PGParamSpec; value: PGValue); cdecl; external GObjectLibrary;

function g_object_new(object_type: GType; first_property_name: pgchar): PGObjectC;
  cdecl; varargs; external GObjectLibrary;
function g_object_newv(object_type: GType; n_parameters: guint;
  parameters: PGValue): PGObjectC; cdecl; external GObjectLibrary;
function g_object_ref(obj: gpointer): gpointer; cdecl; external GObjectLibrary;
procedure g_object_unref(obj: gpointer); cdecl; external GObjectLibrary;
function g_object_ref_sink(obj: gpointer): gpointer; cdecl; external GObjectLibrary;
procedure g_object_add_toggle_ref(obj: gpointer; notify: GToggleNotify;
  data: gpointer); cdecl; external GObjectLibrary;
procedure g_object_remove_toggle_ref(obj: gpointer; notify: GToggleNotify;
  data: gpointer); cdecl; external GObjectLibrary;
function g_object_is_floating(obj: gpointer): gboolean; cdecl; external GObjectLibrary;
procedure g_object_force_floating(obj: PGObjectC); cdecl; external GObjectLibrary;
procedure g_object_weak_ref(obj: PGObjectC; notify: GNotifyFunc;
  data: gpointer); cdecl; external GObjectLibrary;
procedure g_object_weak_unref(obj: PGObjectC; notify: GNotifyFunc;
  data: gpointer); cdecl; external GObjectLibrary;
procedure g_object_get(obj: gpointer; first_property_name: pgchar);
  cdecl; varargs; external GObjectLibrary;
procedure g_object_set(obj: gpointer; first_property_name: pgchar);
  cdecl; varargs; external GObjectLibrary;
procedure g_object_get_property(obj: PGObjectC; property_name: pgchar;
  value: PGValue); cdecl; external GObjectLibrary;
procedure g_object_set_property(obj: PGObjectC; property_name: pgchar;
  const value: PGValue); cdecl; external GObjectLibrary;
function g_object_get_data(obj: PGObjectC; key: pgchar): gpointer;
  cdecl; external GObjectLibrary;
procedure g_object_set_data(obj: PGObjectC; key: pgchar;
  data: gpointer); cdecl; external GObjectLibrary;
procedure g_object_set_data_full(obj: PGObjectC; key: pgchar; data: gpointer;
  destroy_func: GDestroyNotify); cdecl; external GObjectLibrary;
function g_object_steal_data(obj: PGObjectC; key: pgchar): gpointer;
  cdecl; external GObjectLibrary;
function g_object_get_qdata(obj: PGObjectC; quark: GQuark): gpointer;
  cdecl; external GObjectLibrary;
procedure g_object_set_qdata(obj: PGObjectC; quark: GQuark; data: gpointer);
  cdecl; external GObjectLibrary;
procedure g_object_set_qdata_full(obj: PGObjectC; quark: GQuark; data: gpointer;
  destroy: GDestroyNotify); cdecl; external GObjectLibrary;
function g_object_steal_qdata(obj: PGObjectC; quark: GQuark): gpointer;
  cdecl; external GObjectLibrary;
procedure g_object_freeze_notify(obj: PGObjectC); cdecl; external GObjectLibrary;
procedure g_object_thaw_notify(obj: PGObjectC); cdecl; external GObjectLibrary;
procedure g_object_notify(obj: PGObjectC; property_name: pgchar);
  cdecl; external GObjectLibrary;
procedure g_object_notify_by_pspec(obj: PGObjectC; pspec: PGParamSpec);
  cdecl; external GObjectLibrary;
procedure g_object_class_install_property(oclass: PGObjectClass; property_id: guint;
  pspec: PGParamSpec); cdecl; external GObjectLibrary;
procedure g_object_class_install_properties(oclass: PGObjectClass; n_pspecs: guint;
  pspecs: PPGParamSpec); cdecl; external GObjectLibrary;
function g_object_class_find_property(oclass: PGObjectClass;
  property_name: pgchar): PGParamSpec; cdecl; external GObjectLibrary;
function g_object_class_list_properties(oclass: PGObjectClass;
  n_properties: pguint): PPGParamSpec; cdecl; external GObjectLibrary;

function g_signal_new(signal_name: pgchar; itype: GType;
  signal_flags: GSignalFlags; class_offset: guint;
  accumulator: GSignalAccumulator; accu_data: gpointer;
  c_marshaller: GSignalCMarshaller; return_type: GType;
  n_params: guint): guint; cdecl; varargs; external GObjectLibrary;
function g_signal_newv(signal_name: pgchar; itype: GType;
  signal_flags: GSignalFlags; class_closure: PGClosure;
  accumulator: GSignalAccumulator; accu_data: gpointer;
  c_marshaller: GSignalCMarshaller; return_type: GType;
  n_params: guint; param_types: PGType): guint; cdecl; external GObjectLibrary;
function g_signal_lookup(name: pgchar; itype: GType): guint;
  cdecl; external GObjectLibrary;
function g_signal_name(signal_id: guint): pgchar; cdecl; external GObjectLibrary;
procedure g_signal_query(signal_id: guint; query: PGSignalQuery);
  cdecl; external GObjectLibrary;
function g_signal_list_ids(itype: GType; n_ids: pguint): pguint;
  cdecl; external GObjectLibrary;
function g_signal_connect_closure_by_id(instance: gpointer; signal_id: guint;
  detail: GQuark; closure: PGClosure; after: gboolean): gulong;
  cdecl; external GObjectLibrary;
function g_signal_connect_closure(instance: gpointer; detailed_signal: pgchar;
  closure: PGClosure; after: gboolean): gulong; cdecl; external GObjectLibrary;
function g_signal_connect_data(instance: gpointer; detailed_signal: pgchar;
  c_handler: gpointer; data: gpointer; destroy_data: GClosureNotify;
  connect_flags: GConnectFlags): gulong; cdecl; external GObjectLibrary;
procedure g_signal_emit(instance: gpointer; signal_id: guint; detail: GQuark);
  cdecl; varargs; external GObjectLibrary;
procedure g_signal_emit_by_name(instance: gpointer; detailed_signal: pgchar);
  cdecl; varargs; external GObjectLibrary;
procedure g_signal_emitv(instance_and_params: PGValue; signal_id: guint;
  detail: GQuark; return_value: PGValue); cdecl; external GObjectLibrary;
function g_signal_handler_block(instance: gpointer; handler_id: gulong): gulong;
  cdecl; external GObjectLibrary;
procedure g_signal_handler_unblock(instance: gpointer; handler_id: gulong);
  cdecl; external GObjectLibrary;
procedure g_signal_handler_disconnect(instance: gpointer; handler_id: gulong);
  cdecl; external GObjectLibrary;
function g_signal_handler_is_connected(instance: gpointer; handler_id: gulong): gboolean;
  cdecl; external GObjectLibrary;
function g_signal_handlers_disconnect_by_func(instance: gpointer;
  func: gpointer; data: gpointer): guint; cdecl; external GObjectLibrary;
function g_signal_handlers_block_by_func(instance: gpointer;
  func: gpointer; data: gpointer): guint; cdecl; external GObjectLibrary;
function g_signal_handlers_unblock_by_func(instance: gpointer;
  func: gpointer; data: gpointer): guint; cdecl; external GObjectLibrary;
function g_signal_stop_emission(instance: gpointer; signal_id: guint;
  detail: GQuark): gboolean; cdecl; external GObjectLibrary;
function g_signal_stop_emission_by_name(instance: gpointer;
  detailed_signal: pgchar): gboolean; cdecl; external GObjectLibrary;
function g_signal_has_handler_pending(instance: gpointer; signal_id: guint;
  detail: GQuark; may_be_blocked: gboolean): gboolean; cdecl; external GObjectLibrary;

function g_cclosure_new(callback_func: gpointer; user_data: gpointer;
  destroy_data: GClosureNotify): PGClosure; cdecl; external GObjectLibrary;
function g_cclosure_new_swap(callback_func: gpointer; user_data: gpointer;
  destroy_data: GClosureNotify): PGClosure; cdecl; external GObjectLibrary;
function g_closure_new_simple(sizeof_closure: guint;
  data: gpointer): PGClosure; cdecl; external GObjectLibrary;
function g_closure_ref(closure: PGClosure): PGClosure; cdecl; external GObjectLibrary;
procedure g_closure_unref(closure: PGClosure); cdecl; external GObjectLibrary;
procedure g_closure_sink(closure: PGClosure); cdecl; external GObjectLibrary;
procedure g_closure_invoke(closure: PGClosure; return_value: PGValue;
  n_param_values: guint; param_values: PGValue;
  invocation_hint: gpointer); cdecl; external GObjectLibrary;
procedure g_closure_set_marshal(closure: PGClosure;
  marshal: GClosureMarshal); cdecl; external GObjectLibrary;
procedure g_closure_add_finalize_notifier(closure: PGClosure;
  notify_data: gpointer; notify_func: GClosureNotify); cdecl; external GObjectLibrary;

procedure g_cclosure_marshal_VOID__VOID(closure: PGClosure; return_value: PGValue;
  n_param_values: guint; param_values: PGValue; invocation_hint: gpointer;
  marshal_data: gpointer); cdecl; external GObjectLibrary;
procedure g_cclosure_marshal_VOID__BOOLEAN(closure: PGClosure; return_value: PGValue;
  n_param_values: guint; param_values: PGValue; invocation_hint: gpointer;
  marshal_data: gpointer); cdecl; external GObjectLibrary;
procedure g_cclosure_marshal_VOID__INT(closure: PGClosure; return_value: PGValue;
  n_param_values: guint; param_values: PGValue; invocation_hint: gpointer;
  marshal_data: gpointer); cdecl; external GObjectLibrary;
procedure g_cclosure_marshal_VOID__UINT(closure: PGClosure; return_value: PGValue;
  n_param_values: guint; param_values: PGValue; invocation_hint: gpointer;
  marshal_data: gpointer); cdecl; external GObjectLibrary;
procedure g_cclosure_marshal_VOID__LONG(closure: PGClosure; return_value: PGValue;
  n_param_values: guint; param_values: PGValue; invocation_hint: gpointer;
  marshal_data: gpointer); cdecl; external GObjectLibrary;
procedure g_cclosure_marshal_VOID__STRING(closure: PGClosure; return_value: PGValue;
  n_param_values: guint; param_values: PGValue; invocation_hint: gpointer;
  marshal_data: gpointer); cdecl; external GObjectLibrary;
procedure g_cclosure_marshal_VOID__OBJECT(closure: PGClosure; return_value: PGValue;
  n_param_values: guint; param_values: PGValue; invocation_hint: gpointer;
  marshal_data: gpointer); cdecl; external GObjectLibrary;
procedure g_cclosure_marshal_BOOLEAN__FLAGS(closure: PGClosure; return_value: PGValue;
  n_param_values: guint; param_values: PGValue; invocation_hint: gpointer;
  marshal_data: gpointer); cdecl; external GObjectLibrary;

implementation

end.
