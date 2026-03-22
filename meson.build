project('pasgobject',
  version       : '1.0.0',
  license       : 'LGPL-3.0-or-later',
  meson_version : '>= 1.0.0')

fpc = find_program('fpc', required : true)

pkg_config = find_program('pkg-config', required : true)

gobject_src_dir      = meson.project_source_root() / 'gobject' / 'src'
gobject_internal_dir = meson.project_source_root() / 'gobject' / 'src' / 'Internal'

subdir('gobject')
subdir('gtk4')
subdir('tools')

message('pasgobject ' + meson.project_version())
message('  GObject source  : ' + gobject_src_dir)
