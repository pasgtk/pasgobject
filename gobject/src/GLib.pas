{ Pascal-GObject - Pascal bindings for the GObject type system
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ GLib - Pascal-friendly GLib helpers.

  The interface section exposes no extern declarations.  All raw
  C symbols are imported through GLibFFI in the implementation.
  Callers get clean Pascal wrappers without touching pgchar directly. }
unit GLib;

{$mode objfpc}{$H+}{$PackRecords C}

interface

uses GTypes;

{ GLibStr converts a Pascal string to a pgchar for a single GLib call.
  The pointer is valid only for the lifetime of the Pascal string. }
function GLibStr(const S: string): pgchar;

{ PasStr converts a GLib null-terminated string to a Pascal string.
  Returns an empty string when S is nil. }
function PasStr(S: pgchar): string;

{ GLibAlloc allocates n bytes via g_malloc. }
function GLibAlloc(n: gsize): gpointer;

{ GLibAlloc0 allocates n zero-initialised bytes via g_malloc0. }
function GLibAlloc0(n: gsize): gpointer;

{ GLibFree releases memory allocated by GLib. }
procedure GLibFree(p: gpointer);

{ GLibStrDup duplicates a Pascal string using g_strdup.
  The caller must free the result with GLibFree. }
function GLibStrDup(const s: string): pgchar;

{ GLibStringListFree frees a NULL-terminated pgchar** array via g_strfreev. }
procedure GLibStringListFree(p: ppgchar);

{ GLibMainLoopNew creates a new GMainLoop on the default context. }
function GLibMainLoopNew: PGMainLoop;

{ GLibMainLoopRun runs the main loop until GLibMainLoopQuit is called. }
procedure GLibMainLoopRun(ALoop: PGMainLoop);

{ GLibMainLoopQuit quits a running main loop. }
procedure GLibMainLoopQuit(ALoop: PGMainLoop);

{ GLibMainLoopFree unrefs and potentially frees the main loop. }
procedure GLibMainLoopFree(ALoop: PGMainLoop);

{ GLibTimeoutAdd adds a timeout source that fires every AIntervalMs milliseconds. }
function GLibTimeoutAdd(AIntervalMs: guint; AFunc: GSourceFunc; AData: gpointer): guint;

{ GLibIdleAdd adds an idle source. }
function GLibIdleAdd(AFunc: GSourceFunc; AData: gpointer): guint;

{ GLibSourceRemove removes a source by its tag. }
function GLibSourceRemove(ATag: guint): Boolean;

implementation

uses GLibFFI;

function GLibStr(const S: string): pgchar;
begin
  Result := pgchar(PChar(S));
end;

function PasStr(S: pgchar): string;
begin
  if S = nil then
    Result := ''
  else
    Result := string(PChar(S));
end;

function GLibAlloc(n: gsize): gpointer;
begin
  Result := g_malloc(n);
end;

function GLibAlloc0(n: gsize): gpointer;
begin
  Result := g_malloc0(n);
end;

procedure GLibFree(p: gpointer);
begin
  g_free(p);
end;

function GLibStrDup(const s: string): pgchar;
begin
  Result := g_strdup(GLibStr(s));
end;

procedure GLibStringListFree(p: ppgchar);
begin
  g_strfreev(p);
end;

function GLibMainLoopNew: PGMainLoop;
begin
  Result := g_main_loop_new(nil, False);
end;

procedure GLibMainLoopRun(ALoop: PGMainLoop);
begin
  g_main_loop_run(ALoop);
end;

procedure GLibMainLoopQuit(ALoop: PGMainLoop);
begin
  g_main_loop_quit(ALoop);
end;

procedure GLibMainLoopFree(ALoop: PGMainLoop);
begin
  g_main_loop_unref(ALoop);
end;

function GLibTimeoutAdd(AIntervalMs: guint; AFunc: GSourceFunc; AData: gpointer): guint;
begin
  Result := g_timeout_add(AIntervalMs, AFunc, AData);
end;

function GLibIdleAdd(AFunc: GSourceFunc; AData: gpointer): guint;
begin
  Result := g_idle_add(AFunc, AData);
end;

function GLibSourceRemove(ATag: guint): Boolean;
begin
  Result := Boolean(g_source_remove(ATag));
end;

end.
