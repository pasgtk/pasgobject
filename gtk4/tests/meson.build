t = custom_target(
  'gtk4/tests/TestGtk',
  input         : 'TestGtk.pas',
  output        : 'TestGtk',
  command       : [
    fpc,
    '-Fu' + gobject_src_dir,
    '-Fu' + gobject_internal_dir,
    '-Fu' + gtk4_src_dir,
    '-Fu' + gtk4_internal_dir,
    '-FE' + meson.current_build_dir(),
    '-FU' + meson.current_build_dir(),
    meson.current_source_dir() / 'TestGtk.pas',
  ],
  build_by_default : true,
  console          : false,
)
test('gtk4/TestGtk', t)
