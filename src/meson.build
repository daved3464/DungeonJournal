dungeonjournal_sources = [
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

  'ui/pages/character-select/CharacterSelectPage.vala',  

  ## Main Components 
  'ui/widgets/CharacterRowInterface.vala',
  'ui/widgets/RecentsCharacterRow.vala',  
  'ui/widgets/SpinButtonRow.vala',
  'ui/widgets/SpinButtonCheckboxRow.vala',
  'ui/widgets/EntryRow.vala',


  ## Character Info Page
  'ui/pages/character-info/CharacterInfoPage.vala',  
  'ui/pages/character-info/widgets/CharacterAttackRow.vala',
  'ui/pages/character-info/widgets/CharacterFeatRow.vala',

  ## Character Inventory Page
  'ui/pages/character-inventory/CharacterInventoryPage.vala',  
  'ui/pages/character-inventory/widgets/CharacterItemRow.vala',

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

dungeonjournal_sources += gnome.compile_resources('dungeonjournal-resources',
    'dungeonjournal.gresource.xml',
    c_name: 'dungeonjournal'
)

dungeonjournal_sources += icons_resources

executable(
    meson.project_name(),
    dungeonjournal_sources,
    include_directories: config_h_dir,
    dependencies: dragonjournal_deps,
    c_args: c_args,
    install: true,
)
