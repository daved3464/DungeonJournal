project('dungeonjournal', ['c', 'vala'],
        version: '0.6.0',
  meson_version: '>= 0.49.0',
)

gnome = import('gnome')
i18n = import('i18n')

app_id = 'io.github.daved3464.DungeonJournal'

# Add custom VAPI dir
add_project_arguments(
  ['--vapidir', meson.source_root() / 'vapi'],  
  language: 'vala'
)

# Application ID
if get_option('profile') == 'development'  
  add_project_arguments(
 '--debug',
  language: 'vala'
)
  
endif


add_project_arguments(
  '--target-glib=2.70',
  language: 'vala'
)


# Configuration
config_h_dir = include_directories('.')
locale_dir = get_option('prefix') / get_option('localedir')

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('PROFILE', get_option('profile'))
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('LOCALEDIR', locale_dir)
configure_file(output: 'config.h', configuration: conf)

add_project_arguments(
  ['--pkg', 'config'],
  language: 'vala'
)

valac = meson.get_compiler('vala')
cc = meson.get_compiler('c')

# Post-install scripts
meson.add_install_script('build-aux/meson_post_install.py')

# Subfolders
subdir('data')
subdir('po')
subdir('src')
