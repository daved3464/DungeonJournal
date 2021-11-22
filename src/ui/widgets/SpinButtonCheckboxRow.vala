using Gtk;
using Adw;
namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/widgets/SpinButtonCheckboxRow.ui")]
    public class SpinButtonCheckboxRow : ActionRow {

        [GtkChild] protected unowned SpinButton spinbutton;
        [GtkChild] protected unowned Adjustment adjustment;
        [GtkChild] protected unowned CheckButton checkbox;

        public double value
        {
            get {
                return this.adjustment.value;
            }
            set {
                this.adjustment.value = value;
            }
        }

        public bool active
        {
            get {
                return this.checkbox.active;
            }
            set {
                this.checkbox.active = value;
            }
        }

        public SpinButtonCheckboxRow(string title) {
            Object();
            this.connect_signals();

            this.adjustment.lower = -5;

            this.title = title;
        }

        private void connect_signals() {

            this.adjustment.value_changed.connect(() => {
                this.notify_property("value");
            });

            this.checkbox.toggled.connect(() => {
                this.notify_property("active");
            });
        }
    }
}
