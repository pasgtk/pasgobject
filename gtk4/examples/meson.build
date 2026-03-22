gtk4_examples = [
  'hello_window',
]

foreach prog_name : gtk4_examples
  custom_target(
    'gtk4/examples/' + prog_name,
    input         : prog_name + '.pas',
    output        : prog_name,
    command       : [
      fpc,
      '-Fu' + gobject_src_dir,
      '-Fu' + gobject_internal_dir,
      '-Fu' + gtk4_src_dir,
      '-Fu' + gtk4_internal_dir,
      '-FE' + meson.current_build_dir(),
      '-FU' + meson.current_build_dir(),
      meson.current_source_dir() / prog_name + '.pas',
    ],
    build_by_default : true,
    console          : false,
  )
endforeach
