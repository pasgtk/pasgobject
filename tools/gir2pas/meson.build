gir2pas = custom_target('gir2pas',
  input         : 'gir2pas.pas',
  output        : 'gir2pas',
  command       : [
    fpc,
    '-Fu' + gobject_src_dir,
    '-Fu' + gobject_internal_dir,
    '-FE' + meson.current_build_dir(),
    '-FU' + meson.current_build_dir(),
    meson.current_source_dir() / 'gir2pas.pas',
  ],
  build_by_default : true,
)
