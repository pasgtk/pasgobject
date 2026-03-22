{ Pascal-GObject - GTK4 umbrella unit
  Copyright (C) 2026 AnmiTaliDev <anmitalidev@nuros.org>

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version. }

{ PasGTK - Convenience unit that pulls in the entire GTK4 binding.

  Add this unit to your program's uses clause to get access to all GTK4
  types and the underlying GObject layer in one import. }
unit PasGTK;

interface

uses
  GTypes, GLib, GObjectType, GValue, GParam, GObject, GSignal, PasGObject,
  GtkTypes, GtkClasses;

implementation

end.
