using Gtk;
using Gee;
using Adw;

namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/ApplicationWindow.ui")]
    public class ApplicationWindow : Adw.ApplicationWindow {

        [GtkChild]
        private unowned Adw.HeaderBar headerbar;

        [GtkChild]
        private unowned Adw.ViewStack stack;

        private CharacterInfoPage page_info { get; set; }
        private CharacterSkillsPage page_skills;
        private CharacterInventoryPage page_inventory;

        private CharacterSheet character;
        private string character_path;

        private StartupWindow startup_window;

        public ApplicationWindow(Adw.Application app) {
            Object(application: app);

            this.character = new CharacterSheet();
            this.character_path = null;

            setup_style();
            setup_view();
            bind_character();

            startup_window = new StartupWindow(this);
            startup_window.show_all();
        }

        private void setup_style() {
            // TODO Implement any custom styling
        }

        private void setup_view() {

            string[] button_class = { "destructive-action" };

            var button = new Button();

            button.clicked.connect(() => {
                this.on_save();
            });

            button.set_child(new Label(_("_Save")));
            button.set_css_classes(button_class);

            this.headerbar.pack_end(button);

            /** Add Pages to Stack */
            this.page_info = new CharacterInfoPage(this, this.character);
            this.page_inventory = new CharacterInventoryPage();
            this.page_skills = new CharacterSkillsPage();


            this.stack.add_titled(this.page_info, "info", _("_Info"));
            this.stack.add_titled(this.page_inventory, "inventory", _("_Inventory"));
            this.stack.add_titled(this.page_skills, "skills", _("_Skills"));

            this.stack.get_page(this.page_info).set_icon_name("book-symbolic");
            this.stack.get_page(this.page_inventory).set_icon_name("basic-bag-symbolic");
            this.stack.get_page(this.page_skills).set_icon_name("skill-vision-symbolic");
        }

        private void bind_character() {
            this.page_info.bind_character(this.character);
            this.page_skills.bind_character(this.character);
            this.page_inventory.bind_character(this.character);
        }

        public void on_open(Gtk.Window? parent = this) {
            var filter = new FileFilter();
            filter.add_mime_type("application/json");

            var chooser = new FileChooserNative(
                _("_Open Character"),
                parent,
                FileChooserAction.OPEN,
                _("_Open"),
                _("_Cancel")
            );

            chooser.set_modal(true);
            chooser.set_filter(filter);
            chooser.show();

            chooser.response.connect_after((res) => {
                if (res == ResponseType.ACCEPT) {
                    string path = chooser.get_file().get_path();
                    this.open_character(path);

                    if (parent == this.startup_window) {
                        this.startup_window.finish_startup();
                    }
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
            var chooser = new FileChooserNative(
                _("_Save Character"),
                this,
                FileChooserAction.SAVE,
                _("_Save"),
                _("_Cancel")
            );

            chooser.set_current_name(this.character.name + ".json");
            chooser.show();

            chooser.response.connect_after((res) => {
                if (res == ResponseType.ACCEPT) {
                    string path = chooser.get_file().get_path();

                    this.save_character(path);
                    this.character_path = path;
                }
            });

            chooser.destroy();
        }

        public bool open_character(string file_path) {
            try {
                var parser = new Json.Parser();
                parser.load_from_file(file_path);

                Json.Node node = parser.get_root();

                this.character = Json.gobject_deserialize(typeof (CharacterSheet), node) as CharacterSheet;

                this.bind_character();
                this.add_recent_file(file_path);
                this.character_path = file_path;
                return true;
            } catch (Error e) {
                log(null, LogLevelFlags.LEVEL_ERROR, "Error Opening Character: %s\n", file_path);
                return false;
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
