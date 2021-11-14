dragonjournal_sources = [
  ## Main App
  'Application.vala',
  'Util.vala',
  'Settings.vala',

  ## Data Models
  'models/CharacterSheet.vala',
  'models/CharacterFeat.vala',
  'models/CharacterAttack.vala',
  'models/CharacterItem.vala',

  ## Main Window
  'ui/ApplicationWindow.vala',
  'ui/StartupWindow.vala',  

  ## Main Components 
  'ui/components/CharacterRowInterface.vala',
  'ui/components/RecentsCharacterRow.vala',
  'ui/components/SeparatorRow.vala',
  'ui/components/SpinButtonRow.vala',
  'ui/components/SpinButtonCheckboxRow.vala',

  ## Character Info Page
  'ui/pages/character-info/CharacterInfoPage.vala',
  'ui/pages/character-info/components/CharacterAttackRow.vala',
  'ui/pages/character-info/components/CharacterFeatRow.vala',
  'ui/pages/character-info/components/ComboBoxRow.vala',
  'ui/pages/character-info/components/EntryRow.vala',

  ## Character Inventory Page
  'ui/pages/character-inventory/CharacterInventoryPage.vala',
  'ui/pages/character-inventory/components/CharacterItemRow.vala',

  ## Character Skills Page
  'ui/pages/character-skills/CharacterSkillsPage.vala',
  
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
