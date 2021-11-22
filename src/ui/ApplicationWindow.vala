using Gtk;
using Gee;
using Adw;

namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/ApplicationWindow.ui")]
    public class ApplicationWindow : Adw.ApplicationWindow {

        [GtkChild]
        private unowned Button back_button;

        [GtkChild]
        private unowned Button save_button;

        [GtkChild]
        private unowned MenuButton menu_button;

        [GtkChild]
        private unowned Adw.ToastOverlay toast_overlay;

        [GtkChild]
        private unowned Adw.ViewStack content_container;

        [GtkChild]
        private unowned Box character_data;

        [GtkChild]
        private unowned Adw.HeaderBar character_data_headerbar;

        [GtkChild]
        private unowned Adw.ViewStack stack;

        // Welcome Screen
        private CharacterSelectPage welcome_screen;

        // Pages
        private CharacterInfoPage page_info;
        private CharacterSkillsPage page_skills;
        private CharacterInventoryPage page_inventory;

        private CharacterSheet character;
        private string character_path;

        public ApplicationWindow(Adw.Application app) {
            Object(application: app);

            this.character = new CharacterSheet();
            this.character_path = null;

            setup_style();
            setup_view();
            setup_stack();
            bind_character();
        }

        private void setup_style() {
            // TODO Implement any custom styling
        }

        private void setup_view() {

            this.welcome_screen = new CharacterSelectPage(this);

            this.content_container.add_named(this.welcome_screen, "welcome_screen");
            this.content_container.add_named(this.character_data, "character_data");
        }

        private void setup_stack() {

            this.character_data_headerbar.pack_start(this.back_button);
            this.character_data_headerbar.pack_end(this.menu_button);
            this.character_data_headerbar.pack_end(this.save_button);


            // Add pages to stack

            this.page_info = new CharacterInfoPage(this, this.character);
            this.page_inventory = new CharacterInventoryPage(this);
            this.page_skills = new CharacterSkillsPage(this);

            this.stack.add_titled(this.page_info, "info", _("Info"));
            this.stack.add_titled(this.page_inventory, "inventory", _("Inventory"));
            this.stack.add_titled(this.page_skills, "skills", _("Skills"));

            this.stack.get_page(this.page_info).set_icon_name("character-symbolic");
            this.stack.get_page(this.page_inventory).set_icon_name("basic-bag-symbolic");
            this.stack.get_page(this.page_skills).set_icon_name("skill-vision-symbolic");
        }

        private void bind_character() {
            this.page_info.bind_character(this.character);
            this.page_skills.bind_character(this.character);
            this.page_inventory.bind_character(this.character);
        }

        public void show_welcome_screen() {
            this.content_container.set_visible_child_name("welcome_screen");
        }

        public void show_character_data() {
            this.content_container.set_visible_child_name("character_data");
        }

        public void new_character() {
            this.character = new CharacterSheet();
            this.character_path = null;
            this.bind_character();

            this.show_character_data();
        }

        [GtkCallback]
        public void trigger_back_button() {
            this.show_welcome_screen();
        }

        public void on_open() {
            var filter = new FileFilter();
            filter.add_mime_type("application/json");

            var chooser = new FileChooserNative(
                _("Open Character"),
                this,
                FileChooserAction.OPEN,
                _("Open"),
                _("Cancel")
            );

            chooser.set_modal(true);
            chooser.set_filter(filter);
            chooser.show();

            chooser.response.connect_after((res) => {
                if (res == ResponseType.ACCEPT) {
                    string path = chooser.get_file().get_path();
                    this.open_character(path);
                }
            });
        }

        [GtkCallback]
        public void trigger_on_save() {


            this.on_save();
        }

        public void on_save() {
            if (this.character_path == null) {
                this.on_save_as();
            } else {

                var dialog_flags = Gtk.DialogFlags.DESTROY_WITH_PARENT | Gtk.DialogFlags.MODAL;

                var confirm_dialog = new Gtk.MessageDialog(
                    this,
                    dialog_flags,
                    Gtk.MessageType.WARNING,
                    Gtk.ButtonsType.OK_CANCEL,
                    null,
                    null
                );

                var primary_text = (Label) confirm_dialog.get_message_area().get_first_child();
                var secondary_text = (Label) confirm_dialog.get_message_area().get_last_child();

                primary_text.set_text(_("Save Changes?"));
                primary_text.set_css_classes({ "title-3" });

                secondary_text.set_text(_("This action will overwrite your character"));
                secondary_text.set_visible(true);

                confirm_dialog.response.connect((res) => {

                    if (res == ResponseType.OK || res == ResponseType.ACCEPT) {
                        this.save_character(this.character_path);
                    }

                    confirm_dialog.destroy();
                });

                confirm_dialog.present();
            }
        }

        public void on_save_as() {
            var chooser = new FileChooserNative(
                _("Save Character"),
                this,
                FileChooserAction.SAVE,
                _("Save"),
                _("Cancel")
            );
            chooser.set_modal(true);

            chooser.show();

            chooser.response.connect_after((res) => {
                if (res == ResponseType.ACCEPT) {
                    string path = chooser.get_file().get_path();

                    this.save_character(path);
                    this.character_path = path;
                }
            });
        }

        public bool open_character(string file_path) {
            try {
                var parser = new Json.Parser();

                parser.load_from_file(file_path);

                Json.Node node = parser.get_root();

                this.character_path = file_path;
                this.add_recent_file(file_path);

                this.character = Json.gobject_deserialize(typeof (CharacterSheet), node) as CharacterSheet;

                this.bind_character();

                this.show_character_data();

                return true;
            } catch (Error e) {
                this.toast_overlay.add_toast(new Toast(_("Error opening character")));
                log(null, LogLevelFlags.LEVEL_WARNING, @"Error Opening character: $file_path \n");
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
