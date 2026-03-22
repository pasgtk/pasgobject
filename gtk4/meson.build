check_gtk4 = run_command(pkg_config, '--exists', 'gtk4', check : false)
if check_gtk4.returncode() != 0
  if get_option('build_gtk4')
    warning('GTK4 not found; skipping gtk4 bindings.')
  endif
  subdir_done()
endif

gtk4_src_dir      = meson.current_source_dir() / 'src'
gtk4_internal_dir = meson.current_source_dir() / 'src' / 'Internal'

message('GTK4 found, building gtk4 bindings.')
message('  GTK4 source     : ' + gtk4_src_dir)

if get_option('build_tests')
  subdir('tests')
endif

if get_option('build_examples')
  subdir('examples')
endif
