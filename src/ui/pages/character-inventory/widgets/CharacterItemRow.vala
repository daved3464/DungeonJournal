using Gtk;
using Adw;

namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/pages/character-inventory/widgets/CharacterItemRow.ui")]
    public class CharacterItemRow : ExpanderRow {

        [GtkChild] protected unowned Button delete_button { get; }

        [GtkChild] protected unowned Entry name_entry;

        [GtkChild] protected unowned SpinButton quantity_spinbutton;
        [GtkChild] protected unowned Adjustment quantity_adjustment;

        [GtkChild] protected unowned Entry cost_entry;

        [GtkChild] protected unowned SpinButton weight_spinbutton;
        [GtkChild] protected unowned Adjustment weight_adjustment;

        [GtkChild] protected unowned TextView description_entry;

        public CharacterItem item { get; set; }

        public CharacterItemRow(ref CharacterItem item) {
            Object();

            this.item = item;

            this.item.bind_property("item_name", this.name_entry, "text", Util.BINDING_FLAGS);
            this.item.bind_property("quantity", this.quantity_adjustment, "value", Util.BINDING_FLAGS);
            this.item.bind_property("cost", this.cost_entry, "text", Util.BINDING_FLAGS);
            this.item.bind_property("weight", this.weight_adjustment, "value", Util.BINDING_FLAGS);
            this.item.bind_property("description", this.description_entry.buffer, "text", Util.BINDING_FLAGS);

            this.name_entry.bind_property("text", this, "title", BindingFlags.SYNC_CREATE);

            this.quantity_adjustment.bind_property(
                "value", this, "subtitle", BindingFlags.SYNC_CREATE,
                (binding, srcval, ref targetval) => {
                double src = (double) srcval;
                targetval.set_string(@"x$((int) src)");
                return true;
            });
        }

        [GtkCallback]
        private void on_delete_button_clicked() {
            var parent = (ListBox) this.parent;
            parent.row_activated(this);
        }
    }
}
