using Gtk;

namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/widgets/RecentsCharacterRow.ui")]
    public class RecentsCharacterRow : Adw.ActionRow {
        public string file_path;

        [GtkChild] protected unowned Button delete_button;

        public RecentsCharacterRow(string file_path) {
            Object();
            this.file_path = file_path;
            this.title = Path.get_basename(file_path).replace(".json", "");
            this.subtitle = file_path;
        }

        [GtkCallback]
        private void on_delete_button_clicked() {
            var list_box = (ListBox) this.parent;

            list_box.row_selected(this);
        }
    }
}
