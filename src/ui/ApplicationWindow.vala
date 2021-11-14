using Gtk;
using Gee;

namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/ApplicationWindow.ui")]
    public class ApplicationWindow : Adw.ApplicationWindow {

        private Adw.ViewStack stack;

        private CharacterInfoPage page_info;
        private CharacterSkillsPage page_skills;
        private CharacterInventoryPage page_inventory;

        private CharacterSheet character;
        private string character_path;

        public bool startup_finished;

        private StartupWindow startup_window;

        public ApplicationWindow(Adw.Application app) {
            Object(application: app);

            this.stack = new Adw.ViewStack();

            this.character = new CharacterSheet();
            this.character_path = null;

            setup_style();
            setup_view();
            bind_character();

            startup_window = new StartupWindow(this);
            startup_window.show_all();
        }

        private void setup_style() {}

        private void setup_view() {
            this.page_info = new CharacterInfoPage();
            this.page_skills = new CharacterSkillsPage();
            this.page_inventory = new CharacterInventoryPage();

            this.stack.add_titled(this.page_info, "info", _("Info"));
            this.stack.add_titled(this.page_skills, "skills", _("Skills"));
            this.stack.add_titled(this.page_inventory, "inventory", _("Inventory"));
        }

        private void bind_character() {
            this.page_info.bind_character(this.character);
            this.page_skills.bind_character(this.character);
            this.page_inventory.bind_character(this.character);
        }

        public void on_open(Gtk.Window? parent = this) {
            var filter = new FileFilter();
            filter.add_mime_type("application/json");

            var dialog = new FileChooserDialog(
                _("_Open Character"),
                parent,
                FileChooserAction.OPEN,
                _("_Open"),
                _("_Cancel")
            );

            dialog.set_modal(true);

            dialog.set_filter(filter);

            dialog.show();

            dialog.response.connect((res) => {
                stdout.printf("Response %d", res);
                if (res == ResponseType.ACCEPT) {
                    string path = dialog.get_file().get_path();
                    this.open_character(path);
                    this.startup_finished = true;
                } else {
                    this.startup_finished = false;
                }
            });
        }

        public void on_save() {
            if (this.character_path == null) {
                this.on_save_as();
            } else {
                this.save_character(this.character_path);
            }
        }

        public void on_save_as() {
            var dialog = new FileChooserNative(
                _("_Save Character"),
                this,
                FileChooserAction.SAVE,
                _("_Save"),
                _("_Cancel")
            );

            dialog.set_current_name(this.character.name + ".json");
            // dialog.set_do_overwrite_confirmation(true);

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

        public void open_character(string file_path) {
            try {
                var parser = new Json.Parser();
                parser.load_from_file(file_path);
                Json.Node node = parser.get_root();
                this.character = Json.gobject_deserialize(typeof (CharacterSheet), node) as CharacterSheet;
                this.bind_character();
                this.add_recent_file(file_path);
                this.character_path = file_path;
            } catch (Error e) {
                log(null, LogLevelFlags.LEVEL_ERROR, "Error Opening Character: %s\n", file_path);
            }
        }

        private void save_character(string path) {
            string json = Json.gobject_to_data(this.character, null);
            var file = File.new_for_path(path);

            try {
                if (file.query_exists()) {
                    file.delete ();
                }

                FileOutputStream stream = file.create(FileCreateFlags.NONE);
                stream.write(json.data);
            } catch (Error e) {
                log(null, LogLevelFlags.LEVEL_ERROR, "Error Saving Character: %s\n", path);
            }
        }

        private void add_recent_file(string file_path) {
            var recents = new ArrayList<string>.wrap(App.settings.recent_files);

            if (!recents.contains(file_path)) {
                recents.add(file_path);
                App.settings.recent_files = recents.to_array();
            }
        }

        public void remove_recent_file(string file_path) {
            var recents = new ArrayList<string>.wrap(App.settings.recent_files);

            recents.remove(file_path);
            App.settings.recent_files = recents.to_array();
        }
    }
}
