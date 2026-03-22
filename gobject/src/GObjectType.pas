{ Pascal-GObject - Pascal bindings for the GObject type system
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GObjectType - GType runtime type system constants and helpers.

  Fundamental GType constants and GTypeFlags are defined here together
  with Pascal wrappers that accept plain strings.  No extern declarations
  appear in this unit's interface; all C calls go through GObjectFFI. }
unit GObjectType;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes;

const
  G_TYPE_INVALID   = GType(0  shl 2);
  G_TYPE_NONE      = GType(1  shl 2);
  G_TYPE_INTERFACE = GType(2  shl 2);
  G_TYPE_CHAR      = GType(3  shl 2);
  G_TYPE_UCHAR     = GType(4  shl 2);
  G_TYPE_BOOLEAN   = GType(5  shl 2);
  G_TYPE_INT       = GType(6  shl 2);
  G_TYPE_UINT      = GType(7  shl 2);
  G_TYPE_LONG      = GType(8  shl 2);
  G_TYPE_ULONG     = GType(9  shl 2);
  G_TYPE_INT64     = GType(10 shl 2);
  G_TYPE_UINT64    = GType(11 shl 2);
  G_TYPE_ENUM      = GType(12 shl 2);
  G_TYPE_FLAGS     = GType(13 shl 2);
  G_TYPE_FLOAT     = GType(14 shl 2);
  G_TYPE_DOUBLE    = GType(15 shl 2);
  G_TYPE_STRING    = GType(16 shl 2);
  G_TYPE_POINTER   = GType(17 shl 2);
  G_TYPE_BOXED     = GType(18 shl 2);
  G_TYPE_PARAM     = GType(19 shl 2);
  G_TYPE_OBJECT    = GType(20 shl 2);
  G_TYPE_VARIANT   = GType(21 shl 2);

  G_TYPE_FLAG_NONE           = GTypeFlags(0);
  G_TYPE_FLAG_ABSTRACT       = GTypeFlags(1 shl 4);
  G_TYPE_FLAG_VALUE_ABSTRACT = GTypeFlags(1 shl 5);
  G_TYPE_FLAG_FINAL          = GTypeFlags(1 shl 6);

  G_TYPE_FLAG_CLASSED        = GTypeFundamentalFlags(1 shl 0);
  G_TYPE_FLAG_INSTANTIATABLE = GTypeFundamentalFlags(1 shl 1);
  G_TYPE_FLAG_DERIVABLE      = GTypeFundamentalFlags(1 shl 2);
  G_TYPE_FLAG_DEEP_DERIVABLE = GTypeFundamentalFlags(1 shl 3);

{ g_type_init must be called before any other GType function.
  Wraps the underlying C call so callers do not need GObjectFFI. }
procedure g_type_init;

{ GTypeName returns the human-readable name of a GType. }
function GTypeName(T: GType): string;

{ GTypeFromName looks up a GType by its registered name. }
function GTypeFromName(const Name: string): GType;

{ GTypeIsA returns True when T is equal to or a subtype of IsA. }
function GTypeIsA(T, IsA: GType): Boolean;

{ GTypeIsObject returns True when T is GObject or a subtype of it. }
function GTypeIsObject(T: GType): Boolean;

{ GTypeIsInterface returns True when T is a GInterface. }
function GTypeIsInterface(T: GType): Boolean;

{ GTypeParent returns the parent GType of T. }
function GTypeParent(T: GType): GType;

{ GTypeDepth returns the depth of T in the type hierarchy. }
function GTypeDepth(T: GType): guint;

implementation

uses GObjectFFI, GLib;

procedure g_type_init;
begin
  GObjectFFI.g_type_init;
end;

function GTypeName(T: GType): string;
begin
  Result := PasStr(GObjectFFI.g_type_name(T));
end;

function GTypeFromName(const Name: string): GType;
begin
  Result := GObjectFFI.g_type_from_name(GLibStr(Name));
end;

function GTypeIsA(T, IsA: GType): Boolean;
begin
  Result := Boolean(GObjectFFI.g_type_is_a(T, IsA));
end;

function GTypeIsObject(T: GType): Boolean;
begin
  Result := Boolean(GObjectFFI.g_type_is_a(T, G_TYPE_OBJECT));
end;

function GTypeIsInterface(T: GType): Boolean;
begin
  Result := Boolean(GObjectFFI.g_type_is_a(T, G_TYPE_INTERFACE));
end;

function GTypeParent(T: GType): GType;
begin
  Result := GObjectFFI.g_type_parent(T);
end;

function GTypeDepth(T: GType): guint;
begin
  Result := GObjectFFI.g_type_depth(T);
end;

end.
