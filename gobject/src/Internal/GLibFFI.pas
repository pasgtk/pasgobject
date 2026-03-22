{ Pascal-GObject - Pascal bindings for the GObject type system
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GLibFFI - Raw extern declarations for libglib-2.0.

  This unit contains every external symbol imported from libglib-2.0.
  All other units must use this unit when they need a GLib C function;
  none of them should declare their own external bindings. }
unit GLibFFI;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes;

const
  GLibLibrary = 'libglib-2.0.so.0';
  GioLibrary  = 'libgio-2.0.so.0';

function g_malloc(n_bytes: gsize): gpointer; cdecl; external GLibLibrary;
function g_malloc0(n_bytes: gsize): gpointer; cdecl; external GLibLibrary;
function g_realloc(mem: gpointer; n_bytes: gsize): gpointer; cdecl; external GLibLibrary;
procedure g_free(mem: gpointer); cdecl; external GLibLibrary;
function g_try_malloc(n_bytes: gsize): gpointer; cdecl; external GLibLibrary;
function g_memdup2(mem: gconstpointer; byte_size: gsize): gpointer; cdecl; external GLibLibrary;

function g_strdup(str: pgchar): pgchar; cdecl; external GLibLibrary;
function g_strndup(str: pgchar; n: gsize): pgchar; cdecl; external GLibLibrary;
function g_strdup_printf(format: pgchar): pgchar; cdecl; varargs; external GLibLibrary;
function g_strcmp0(str1: pgchar; str2: pgchar): gint; cdecl; external GLibLibrary;
function g_ascii_strcasecmp(s1: pgchar; s2: pgchar): gint; cdecl; external GLibLibrary;
procedure g_strfreev(str_array: ppgchar); cdecl; external GLibLibrary;
function g_strsplit(str: pgchar; delimiter: pgchar; max_tokens: gint): ppgchar; cdecl; external GLibLibrary;
function g_strjoinv(separator: pgchar; str_array: ppgchar): pgchar; cdecl; external GLibLibrary;
function g_utf8_strlen(p: pgchar; max: gssize): glong; cdecl; external GLibLibrary;
function g_utf8_validate(str: pgchar; max_len: gssize; _end: ppgchar): gboolean; cdecl; external GLibLibrary;

function g_list_append(list: PGList; data: gpointer): PGList; cdecl; external GLibLibrary;
function g_list_prepend(list: PGList; data: gpointer): PGList; cdecl; external GLibLibrary;
function g_list_insert(list: PGList; data: gpointer; position: gint): PGList; cdecl; external GLibLibrary;
function g_list_remove(list: PGList; data: gconstpointer): PGList; cdecl; external GLibLibrary;
function g_list_remove_all(list: PGList; data: gconstpointer): PGList; cdecl; external GLibLibrary;
procedure g_list_free(list: PGList); cdecl; external GLibLibrary;
procedure g_list_free_full(list: PGList; free_func: GDestroyNotify); cdecl; external GLibLibrary;
function g_list_length(list: PGList): guint; cdecl; external GLibLibrary;
function g_list_nth(list: PGList; n: guint): PGList; cdecl; external GLibLibrary;
function g_list_nth_data(list: PGList; n: guint): gpointer; cdecl; external GLibLibrary;
function g_list_find(list: PGList; data: gconstpointer): PGList; cdecl; external GLibLibrary;
function g_list_index(list: PGList; data: gconstpointer): gint; cdecl; external GLibLibrary;
function g_list_last(list: PGList): PGList; cdecl; external GLibLibrary;
function g_list_first(list: PGList): PGList; cdecl; external GLibLibrary;
function g_list_reverse(list: PGList): PGList; cdecl; external GLibLibrary;
function g_list_sort(list: PGList; compare_func: GCompareFunc): PGList; cdecl; external GLibLibrary;
procedure g_list_foreach(list: PGList; func: GFunc; user_data: gpointer); cdecl; external GLibLibrary;
function g_list_copy(list: PGList): PGList; cdecl; external GLibLibrary;
function g_list_concat(list1: PGList; list2: PGList): PGList; cdecl; external GLibLibrary;

function g_slist_append(list: PGSList; data: gpointer): PGSList; cdecl; external GLibLibrary;
function g_slist_prepend(list: PGSList; data: gpointer): PGSList; cdecl; external GLibLibrary;
function g_slist_remove(list: PGSList; data: gconstpointer): PGSList; cdecl; external GLibLibrary;
procedure g_slist_free(list: PGSList); cdecl; external GLibLibrary;
procedure g_slist_free_full(list: PGSList; free_func: GDestroyNotify); cdecl; external GLibLibrary;
function g_slist_length(list: PGSList): guint; cdecl; external GLibLibrary;
function g_slist_nth(list: PGSList; n: guint): PGSList; cdecl; external GLibLibrary;
function g_slist_nth_data(list: PGSList; n: guint): gpointer; cdecl; external GLibLibrary;
function g_slist_last(list: PGSList): PGSList; cdecl; external GLibLibrary;
function g_slist_reverse(list: PGSList): PGSList; cdecl; external GLibLibrary;
procedure g_slist_foreach(list: PGSList; func: GFunc; user_data: gpointer); cdecl; external GLibLibrary;
function g_slist_sort(list: PGSList; compare_func: GCompareFunc): PGSList; cdecl; external GLibLibrary;

function g_hash_table_new(hash_func: GHashFunc; key_equal_func: GEqualFunc): PGHashTable; cdecl; external GLibLibrary;
function g_hash_table_new_full(hash_func: GHashFunc; key_equal_func: GEqualFunc;
  key_destroy_func: GDestroyNotify; value_destroy_func: GDestroyNotify): PGHashTable; cdecl; external GLibLibrary;
procedure g_hash_table_destroy(hash_table: PGHashTable); cdecl; external GLibLibrary;
function g_hash_table_insert(hash_table: PGHashTable; key: gpointer; value: gpointer): gboolean; cdecl; external GLibLibrary;
function g_hash_table_replace(hash_table: PGHashTable; key: gpointer; value: gpointer): gboolean; cdecl; external GLibLibrary;
function g_hash_table_lookup(hash_table: PGHashTable; key: gconstpointer): gpointer; cdecl; external GLibLibrary;
function g_hash_table_contains(hash_table: PGHashTable; key: gconstpointer): gboolean; cdecl; external GLibLibrary;
function g_hash_table_remove(hash_table: PGHashTable; key: gconstpointer): gboolean; cdecl; external GLibLibrary;
function g_hash_table_size(hash_table: PGHashTable): guint; cdecl; external GLibLibrary;
function g_str_hash(key: gconstpointer): guint; cdecl; external GLibLibrary;
function g_str_equal(a: gconstpointer; b: gconstpointer): gboolean; cdecl; external GLibLibrary;
function g_int_hash(key: gconstpointer): guint; cdecl; external GLibLibrary;
function g_int_equal(a: gconstpointer; b: gconstpointer): gboolean; cdecl; external GLibLibrary;
function g_direct_hash(key: gconstpointer): guint; cdecl; external GLibLibrary;
function g_direct_equal(a: gconstpointer; b: gconstpointer): gboolean; cdecl; external GLibLibrary;

function g_string_new(init: pgchar): PGString; cdecl; external GLibLibrary;
function g_string_new_len(init: pgchar; len: gssize): PGString; cdecl; external GLibLibrary;
function g_string_sized_new(dfl_size: gsize): PGString; cdecl; external GLibLibrary;
function g_string_free(str: PGString; free_segment: gboolean): pgchar; cdecl; external GLibLibrary;
function g_string_append(str: PGString; val: pgchar): PGString; cdecl; external GLibLibrary;
function g_string_append_len(str: PGString; val: pgchar; len: gssize): PGString; cdecl; external GLibLibrary;
function g_string_prepend(str: PGString; val: pgchar): PGString; cdecl; external GLibLibrary;
function g_string_insert(str: PGString; pos: gssize; val: pgchar): PGString; cdecl; external GLibLibrary;
procedure g_string_truncate(str: PGString; len: gsize); cdecl; external GLibLibrary;
procedure g_string_set_size(str: PGString; len: gsize); cdecl; external GLibLibrary;

procedure g_error_free(error: PGError); cdecl; external GLibLibrary;
function g_error_copy(error: PGError): PGError; cdecl; external GLibLibrary;
function g_error_matches(error: PGError; domain: GQuark; code: gint): gboolean; cdecl; external GLibLibrary;
procedure g_clear_error(err: PPGError); cdecl; external GLibLibrary;

function g_quark_from_string(str: pgchar): GQuark; cdecl; external GLibLibrary;
function g_quark_from_static_string(str: pgchar): GQuark; cdecl; external GLibLibrary;
function g_quark_to_string(quark: GQuark): pgchar; cdecl; external GLibLibrary;
function g_quark_try_string(str: pgchar): GQuark; cdecl; external GLibLibrary;

function g_main_loop_new(context: PGMainContext; is_running: gboolean): PGMainLoop; cdecl; external GLibLibrary;
procedure g_main_loop_run(loop: PGMainLoop); cdecl; external GLibLibrary;
procedure g_main_loop_quit(loop: PGMainLoop); cdecl; external GLibLibrary;
function g_main_loop_ref(loop: PGMainLoop): PGMainLoop; cdecl; external GLibLibrary;
procedure g_main_loop_unref(loop: PGMainLoop); cdecl; external GLibLibrary;
function g_main_loop_is_running(loop: PGMainLoop): gboolean; cdecl; external GLibLibrary;
function g_main_loop_get_context(loop: PGMainLoop): PGMainContext; cdecl; external GLibLibrary;
function g_main_context_default: PGMainContext; cdecl; external GLibLibrary;
function g_timeout_add(interval: guint; func: GSourceFunc; data: gpointer): guint; cdecl; external GLibLibrary;
function g_timeout_add_seconds(interval: guint; func: GSourceFunc; data: gpointer): guint; cdecl; external GLibLibrary;
function g_idle_add(func: GSourceFunc; data: gpointer): guint; cdecl; external GLibLibrary;
function g_source_remove(tag: guint): gboolean; cdecl; external GLibLibrary;

function g_application_run(application: gpointer; argc: gint; argv: gpointer): gint; cdecl; external GioLibrary;

procedure g_log(log_domain: pgchar; log_level: guint; format: pgchar); cdecl; varargs; external GLibLibrary;
procedure g_warning(format: pgchar); cdecl; varargs; external GLibLibrary;
procedure g_critical(format: pgchar); cdecl; varargs; external GLibLibrary;
procedure g_debug(format: pgchar); cdecl; varargs; external GLibLibrary;
procedure g_info(format: pgchar); cdecl; varargs; external GLibLibrary;

implementation

end.
