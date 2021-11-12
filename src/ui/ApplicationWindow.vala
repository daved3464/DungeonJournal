using Gtk;
using Gee;
using Adw;

namespace DungeonJournal
{
    [GtkTemplate (ui = "/io/github/trytonvanmeer/DungeonJournal/ui/ApplicationWindow.ui")]
    public class ApplicationWindow : Adw.ApplicationWindow
    {
        [GtkChild] private unowned Stack stack;
        [GtkChild] private unowned Squeezer squeezer;
        [GtkChild] private unowned ViewSwitcher headerbar_switcher;
        [GtkChild] private unowned ViewSwitcherBar bottom_switcher;

        private CharacterInfoPage page_info;
        private CharacterSkillsPage page_skills;
        private CharacterInventoryPage page_inventory;

        private StartupWindow startup_window;

        private CharacterSheet character;
        private string character_path;

        public bool startup_finished;

        public ApplicationWindow(Adw.Application app)
        {
            Object(application: app);

            this.character = new CharacterSheet();
            this.character_path = null;

            set_help_overlay(new ShortcutsWindow());

            setup_style();
            setup_view();
            bind_character();

            startup_window = new StartupWindow(this);
            startup_window.show_all();
        }

        private void setup_style()
        {
            /*  var provider = new Gtk.CssProvider();
            provider.load_from_resource("/io/github/trytonvanmeer/DungeonJournal/dungeonjournal.css");

            Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);  */
        }

        private void setup_view()
        {
            this.page_info = new CharacterInfoPage();
            this.page_skills = new CharacterSkillsPage();
            this.page_inventory = new CharacterInventoryPage();

            this.stack.add_titled(this.page_info, "info", _("Info"));
            this.stack.add_titled(this.page_skills, "skills", _("Skills"));
            this.stack.add_titled(this.page_inventory, "inventory", _("Inventory"));
        }

        private void bind_character()
        {
            this.page_info.bind_character(this.character);
            this.page_skills.bind_character(this.character);
            this.page_inventory.bind_character(this.character);
        }

        [GtkCallback]
        public void on_headerbar_squeezer_notify()
        {
            this.bottom_switcher.reveal = this.squeezer.visible_child != this.headerbar_switcher;
        }

        public void on_open(Gtk.Window? parent=this)
        {
            var dialog = new FileChooserNative(
                _("Open Character"),
                parent,
                FileChooserAction.OPEN,
                _("_Open"),
                _("_Cancel")
            );

            var filter = new FileFilter();
            filter.add_mime_type("application/json");
            dialog.set_filter(filter);

            dialog.response.connect_after((res) => {
                if (res == ResponseType.ACCEPT){
                    string path = dialog.get_file().get_path();
                    this.open_character(path);                
                    this.startup_finished = true;
                } else {
                    this.startup_finished = false;
                }
            });
        }

        public void on_save()
        {
            if (this.character_path == null)
            {
                this.on_save_as();
            }
            else
            {
                this.save_character(this.character_path);
            }
        }

        public void on_save_as()
        {
            var dialog = new FileChooserNative(
                _("Save Character"),
                this,
                FileChooserAction.SAVE,
                _("_Save"),
                _("_Cancel")
            );

            dialog.set_current_name(this.character.name + ".json");
            //dialog.set_do_overwrite_confirmation(true);

            dialog.show();

            string path = dialog.get_file().get_path();

            this.save_character(path);
            this.character_path = path;

            /*  if (dialog.show() == ResponseType.ACCEPT)
            {
                string path = dialog.get_file().get_path();

                this.save_character(path);
                this.character_path = path;
            }  */

            dialog.destroy();
        }

        public void open_character(string file_path)
        {
            try
            {
                var parser = new Json.Parser();
                parser.load_from_file(file_path);
                Json.Node node = parser.get_root();
                this.character = Json.gobject_deserialize(typeof (CharacterSheet), node) as CharacterSheet;
                this.bind_character();
                this.add_recent_file(file_path);
                this.character_path = file_path;
            }
            catch (Error e)
            {
                log(null, LogLevelFlags.LEVEL_ERROR, "Error Opening Character: %s\n", file_path);
            }
        }

        private void save_character(string path)
        {
            string json = Json.gobject_to_data(this.character, null);
            var file = File.new_for_path(path);

            try
            {
                if (file.query_exists())
                {
                    file.delete();
                }

                FileOutputStream stream = file.create(FileCreateFlags.NONE);
                stream.write(json.data);
            }
            catch (Error e)
            {
                log(null, LogLevelFlags.LEVEL_ERROR, "Error Saving Character: %s\n", path);
            }
        }

        private void add_recent_file(string file_path)
        {
            var recents = new ArrayList<string>.wrap(App.settings.recent_files);

            if (!recents.contains(file_path))
            {
                recents.add(file_path);
                App.settings.recent_files = recents.to_array();
            }
        }

        public void remove_recent_file(string file_path)
        {
            var recents = new ArrayList<string>.wrap(App.settings.recent_files);

            recents.remove(file_path);
            App.settings.recent_files = recents.to_array();
        }
    }
}
