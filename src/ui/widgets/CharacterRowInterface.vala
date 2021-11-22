using Gtk;

namespace DungeonJournal {
    public interface CharacterRowInterface : ListBoxRow {
        abstract Button delete_button { get; }

        protected void delete_button_clicked() {
            var list_box = (ListBox) this.parent;
            list_box.row_activated(this);
        }
    }
}