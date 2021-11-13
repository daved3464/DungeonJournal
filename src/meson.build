dragonjournal_sources = [
  'Application.vala',
  'Util.vala',
  'Settings.vala',
  'CharacterSheet.vala',
  'CharacterFeat.vala',
  'CharacterAttack.vala',
  'CharacterItem.vala',
  'ui/ApplicationWindow.vala',
  'ui/StartupWindow.vala',
  'ui/ShortcutsWindow.vala',
  'ui/CharacterInfoPage.vala',
  'ui/CharacterSkillsPage.vala',
  'ui/CharacterInventoryPage.vala',
  'ui/EntryRow.vala',
  'ui/ComboBoxRow.vala',
  'ui/SpinButtonRow.vala',
  'ui/SpinButtonCheckboxRow.vala',
  'ui/SeparatorRow.vala',
  'ui/RecentsCharacterRow.vala',
  'ui/CharacterRowInterface.vala',
  'ui/CharacterFeatRow.vala',
  'ui/CharacterAttackRow.vala',
  'ui/CharacterItemRow.vala',
]


dragonjournal_deps = [
  meson.get_compiler('c').find_library('m'),
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('glib-2.0'),
  dependency('json-glib-1.0'),
  dependency('gtk4', version: '>= 4.2.0'),
  dependency('gee-0.8'),
  dependency('libadwaita-1'),
]

c_args = [
  '-include', 'config.h',
  '-DLOCALEDIR="@0@"'.format(locale_dir),
]

dragonjournal_sources += gnome.compile_resources('dungeonjournal-resources',
    'dungeonjournal.gresource.xml',
    c_name: 'dungeonjournal'
)

executable(
    meson.project_name(),
    dragonjournal_sources,
    include_directories: config_h_dir,
    dependencies: dragonjournal_deps,
    c_args: c_args,
    install: true,
)
