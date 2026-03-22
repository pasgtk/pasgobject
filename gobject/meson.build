check = run_command(pkg_config, '--exists', 'glib-2.0', 'gobject-2.0', check : false)
if check.returncode() != 0
  error('GLib 2.0 and GObject 2.0 are required.')
endif

if get_option('build_tests')
  subdir('tests')
endif

if get_option('build_examples')
  subdir('examples')
endif
