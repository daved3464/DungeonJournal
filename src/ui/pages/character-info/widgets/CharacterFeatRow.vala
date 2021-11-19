using Gtk;
using Adw;

namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/pages/character-info/widgets/CharacterFeatRow.ui")]
    public class CharacterFeatRow : ExpanderRow {

        [GtkChild] protected unowned Entry name_entry;
        [GtkChild] protected unowned TextView description_entry;

        public CharacterFeat feat { get; set; }

        public CharacterFeatRow(ref CharacterFeat feat) {
            Object();

            /** Inject a reference to the feat */
            this.feat = feat;

            /** Title Bindings */

            /* Bind entry text to feat name */
            this.feat.bind_property("name", this.name_entry, "text", Util.BINDING_FLAGS);
            /* Bind entry text to row title */
            this.name_entry.bind_property("text", this, "title", Util.BINDING_FLAGS);


            /** Description Bindings */

            /** Bind entry description text to feat description */
            this.feat.bind_property("description", this.description_entry.buffer, "text", Util.BINDING_FLAGS);
            /** Bind entry description text to row subtitle */
            this.description_entry.buffer.bind_property("text", this, "subtitle", Util.BINDING_FLAGS);
        }

        [GtkCallback]
        private void on_delete_button_clicked() {
            var parent = (ListBox) this.parent;
            parent.row_activated(this);
        }
    }
}
