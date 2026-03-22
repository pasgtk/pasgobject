{ Pascal-GObject - Pascal bindings for the GObject type system
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ PasGObject - Umbrella unit.

  Add this single unit to your uses clause to pull in the entire
  Pascal-GObject binding:

    uses PasGObject;

  It re-exports all public symbols from:
    GTypes       - fundamental C type aliases and record definitions
    GLib         - GLib memory, strings, lists, main loop helpers
    GObjectType  - GType runtime type system constants and helpers
    GValue       - TGValue generic value container
    GParam       - GParamSpec builders for object properties
    GObject      - TGObject Pascal class with GI ownership semantics
    GSignal      - Signal system with method callback support }
unit PasGObject;

{$mode objfpc}{$H+}

interface

uses
  GTypes,
  GLib,
  GObjectType,
  GValue,
  GParam,
  GObject,
  GSignal;

implementation

end.
