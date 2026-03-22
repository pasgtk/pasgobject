{ Pascal-GObject - Pascal bindings for the GObject type system
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GParam - Pascal-friendly GParamSpec builder functions.

  All factory functions accept Pascal strings rather than pgchar.
  The interface section exposes no extern declarations; raw C calls
  go through GObjectFFI in the implementation. }
unit GParam;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes, GObjectType;

const
  G_PARAM_READABLE        = guint(1 shl 0);
  G_PARAM_WRITABLE        = guint(1 shl 1);
  G_PARAM_READWRITE       = G_PARAM_READABLE or G_PARAM_WRITABLE;
  G_PARAM_CONSTRUCT       = guint(1 shl 2);
  G_PARAM_CONSTRUCT_ONLY  = guint(1 shl 3);
  G_PARAM_LAX_VALIDATION  = guint(1 shl 4);
  G_PARAM_STATIC_NAME     = guint(1 shl 5);
  G_PARAM_STATIC_NICK     = guint(1 shl 6);
  G_PARAM_STATIC_BLURB    = guint(1 shl 7);
  G_PARAM_EXPLICIT_NOTIFY = guint(1 shl 30);
  G_PARAM_DEPRECATED      = guint(1 shl 31);
  G_PARAM_STATIC_STRINGS  = G_PARAM_STATIC_NAME or G_PARAM_STATIC_NICK or G_PARAM_STATIC_BLURB;

function ParamSpecBoolean(const AName, ANick, ABlurb: string;
  ADefault: Boolean; AFlags: guint): PGParamSpec;

function ParamSpecInt(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: Integer; AFlags: guint): PGParamSpec;

function ParamSpecUInt(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: Cardinal; AFlags: guint): PGParamSpec;

function ParamSpecInt64(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: Int64; AFlags: guint): PGParamSpec;

function ParamSpecFloat(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: Single; AFlags: guint): PGParamSpec;

function ParamSpecDouble(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: Double; AFlags: guint): PGParamSpec;

function ParamSpecString(const AName, ANick, ABlurb, ADefault: string;
  AFlags: guint): PGParamSpec;

function ParamSpecEnum(const AName, ANick, ABlurb: string;
  AEnumType: GType; ADefault: Integer; AFlags: guint): PGParamSpec;

function ParamSpecFlags(const AName, ANick, ABlurb: string;
  AFlagsType: GType; ADefault: Cardinal; AFlags: guint): PGParamSpec;

function ParamSpecObject(const AName, ANick, ABlurb: string;
  AObjectType: GType; AFlags: guint): PGParamSpec;

function ParamSpecPointer(const AName, ANick, ABlurb: string;
  AFlags: guint): PGParamSpec;

function ParamSpecBoxed(const AName, ANick, ABlurb: string;
  ABoxedType: GType; AFlags: guint): PGParamSpec;

{ ParamSpecName returns the canonical name of a GParamSpec. }
function ParamSpecName(ASpec: PGParamSpec): string;

{ ParamSpecNick returns the nick (short description) of a GParamSpec. }
function ParamSpecNick(ASpec: PGParamSpec): string;

{ ParamSpecBlurb returns the blurb (long description) of a GParamSpec. }
function ParamSpecBlurb(ASpec: PGParamSpec): string;

implementation

uses GObjectFFI, GLib;

function ParamSpecBoolean(const AName, ANick, ABlurb: string;
  ADefault: Boolean; AFlags: guint): PGParamSpec;
begin
  Result := g_param_spec_boolean(GLibStr(AName), GLibStr(ANick), GLibStr(ABlurb),
    gboolean(ADefault), GParamFlags(AFlags));
end;

function ParamSpecInt(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: Integer; AFlags: guint): PGParamSpec;
begin
  Result := g_param_spec_int(GLibStr(AName), GLibStr(ANick), GLibStr(ABlurb),
    gint(AMin), gint(AMax), gint(ADefault), GParamFlags(AFlags));
end;

function ParamSpecUInt(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: Cardinal; AFlags: guint): PGParamSpec;
begin
  Result := g_param_spec_uint(GLibStr(AName), GLibStr(ANick), GLibStr(ABlurb),
    guint(AMin), guint(AMax), guint(ADefault), GParamFlags(AFlags));
end;

function ParamSpecInt64(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: Int64; AFlags: guint): PGParamSpec;
begin
  Result := g_param_spec_int64(GLibStr(AName), GLibStr(ANick), GLibStr(ABlurb),
    gint64(AMin), gint64(AMax), gint64(ADefault), GParamFlags(AFlags));
end;

function ParamSpecFloat(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: Single; AFlags: guint): PGParamSpec;
begin
  Result := g_param_spec_float(GLibStr(AName), GLibStr(ANick), GLibStr(ABlurb),
    gfloat(AMin), gfloat(AMax), gfloat(ADefault), GParamFlags(AFlags));
end;

function ParamSpecDouble(const AName, ANick, ABlurb: string;
  AMin, AMax, ADefault: Double; AFlags: guint): PGParamSpec;
begin
  Result := g_param_spec_double(GLibStr(AName), GLibStr(ANick), GLibStr(ABlurb),
    gdouble(AMin), gdouble(AMax), gdouble(ADefault), GParamFlags(AFlags));
end;

function ParamSpecString(const AName, ANick, ABlurb, ADefault: string;
  AFlags: guint): PGParamSpec;
begin
  Result := g_param_spec_string(GLibStr(AName), GLibStr(ANick), GLibStr(ABlurb),
    GLibStr(ADefault), GParamFlags(AFlags));
end;

function ParamSpecEnum(const AName, ANick, ABlurb: string;
  AEnumType: GType; ADefault: Integer; AFlags: guint): PGParamSpec;
begin
  Result := g_param_spec_enum(GLibStr(AName), GLibStr(ANick), GLibStr(ABlurb),
    AEnumType, gint(ADefault), GParamFlags(AFlags));
end;

function ParamSpecFlags(const AName, ANick, ABlurb: string;
  AFlagsType: GType; ADefault: Cardinal; AFlags: guint): PGParamSpec;
begin
  Result := g_param_spec_flags(GLibStr(AName), GLibStr(ANick), GLibStr(ABlurb),
    AFlagsType, guint(ADefault), GParamFlags(AFlags));
end;

function ParamSpecObject(const AName, ANick, ABlurb: string;
  AObjectType: GType; AFlags: guint): PGParamSpec;
begin
  Result := g_param_spec_object(GLibStr(AName), GLibStr(ANick), GLibStr(ABlurb),
    AObjectType, GParamFlags(AFlags));
end;

function ParamSpecPointer(const AName, ANick, ABlurb: string;
  AFlags: guint): PGParamSpec;
begin
  Result := g_param_spec_pointer(GLibStr(AName), GLibStr(ANick), GLibStr(ABlurb),
    GParamFlags(AFlags));
end;

function ParamSpecBoxed(const AName, ANick, ABlurb: string;
  ABoxedType: GType; AFlags: guint): PGParamSpec;
begin
  Result := g_param_spec_boxed(GLibStr(AName), GLibStr(ANick), GLibStr(ABlurb),
    ABoxedType, GParamFlags(AFlags));
end;

function ParamSpecName(ASpec: PGParamSpec): string;
begin
  if ASpec = nil then
    Result := ''
  else
    Result := PasStr(g_param_spec_get_name(ASpec));
end;

function ParamSpecNick(ASpec: PGParamSpec): string;
begin
  if ASpec = nil then
    Result := ''
  else
    Result := PasStr(g_param_spec_get_nick(ASpec));
end;

function ParamSpecBlurb(ASpec: PGParamSpec): string;
begin
  if ASpec = nil then
    Result := ''
  else
    Result := PasStr(g_param_spec_get_blurb(ASpec));
end;

end.
