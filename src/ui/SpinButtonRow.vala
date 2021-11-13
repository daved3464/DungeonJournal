using Gtk;
using Adw;

namespace DungeonJournal
{
    [GtkTemplate (ui = "/io/github/daved3464/DungeonJournal/ui/SpinButtonRow.ui")]
    public class SpinButtonRow: ListBoxRow
    {
        [GtkChild] protected unowned Label label;
        [GtkChild] protected unowned SpinButton spinbutton;
        [GtkChild] protected unowned Adjustment adjustment;

        public double value
        {
            get { return this.adjustment.value; }
            set { this.adjustment.value = value; }
        }

        public SpinButtonRow(string label)
        {
            Object();
            this.connect_signals();

            this.label.label = label;
        }

        public SpinButtonRow.with_ability_score_label()
        {
            Object();
            this.connect_signals();

            this.set_label_to_ability_modifier();

            this.adjustment.value_changed.connect(
                this.set_label_to_ability_modifier
            );
        }

        private void connect_signals()
        {            
            this.adjustment.value_changed.connect(() => {
                this.notify_property("value");
            });
        }

        private void set_label_to_ability_modifier()
        {
            var modifier = Util.calculate_ability_modifier(this.adjustment.value);
            this.label.label = modifier;
        }
    }
}