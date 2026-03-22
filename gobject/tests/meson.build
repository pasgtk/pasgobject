test_programs = [
  'TestGTypes',
  'TestGObject',
  'TestSignals',
]

foreach prog_name : test_programs
  t = custom_target(
    'gobject/tests/' + prog_name,
    input         : prog_name + '.pas',
    output        : prog_name,
    command       : [
      fpc,
      '-Fu' + gobject_src_dir,
      '-Fu' + gobject_internal_dir,
      '-FE' + meson.current_build_dir(),
      '-FU' + meson.current_build_dir(),
      meson.current_source_dir() / prog_name + '.pas',
    ],
    build_by_default : true,
    console          : false,
  )
  test('gobject/' + prog_name, t)
endforeach
