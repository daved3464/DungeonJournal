using Adw;
using Gtk;

namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/pages/character-select/CharacterSelectPage.ui")]
    public class CharacterSelectPage : Box {
        private DungeonJournal.ApplicationWindow window;

        [GtkChild] private unowned Box recents_box;
        [GtkChild] private unowned ListBox recents_listbox;

        private bool done_startup { get; set; default = false; }

        public CharacterSelectPage(DungeonJournal.ApplicationWindow window) {
            Object();

            this.window = window;

            this.setup_recents();
        }

        public void show_all() {
            this.hide_listbox_if_empty();
        }

        private void hide_listbox_if_empty() {
            if (this.recents_listbox.observe_children().get_n_items() == 0) {
                this.recents_box.hide();
            }
        }

        private void setup_recents() {
            var recents = App.settings.recent_files;

            foreach (var file_path in recents) {
                var row = new RecentsCharacterRow(file_path);
                this.recents_listbox.append(row);
            }
        }

        [GtkCallback]
        private void on_open() {
            this.window.on_open();
        }

        [GtkCallback]
        private void on_new() {
            this.window.new_character();
        }

        [GtkCallback]
        private void on_recents_row_clicked(ListBoxRow row) {
            var char_row = (RecentsCharacterRow) row;
            var found = this.window.open_character(char_row.file_path);

            if (found) {
                this.window.show_character_data();
            }
        }

        [GtkCallback]
        private void on_recents_row_delete(ListBox listbox, ListBoxRow? row) {
            var char_row = (RecentsCharacterRow) row;
            this.window.remove_recent_file(char_row.file_path);

            this.recents_listbox.remove(row);
            this.hide_listbox_if_empty();
        }
    }
}
