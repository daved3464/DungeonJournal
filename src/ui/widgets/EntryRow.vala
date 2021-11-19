using Gtk;
using Adw;

namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/widgets/EntryRow.ui")]
    public class EntryRow : ActionRow {
        [GtkChild]
        protected unowned Entry entry;

        public string text
        {
            get {
                return this.entry.text;
            }

            set {
                this.entry.text = value;
            }
        }

        public EntryRow(string label) {
            Object();
            this.title = label;
            this.connect_signals();
        }

        private void connect_signals() {
            this.entry.changed.connect(() => {
                this.notify_property("text");
            });
        }
    }
}
