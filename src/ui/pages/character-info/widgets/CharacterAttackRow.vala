using Gtk;
using Adw;

namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/pages/character-info/widgets/CharacterAttackRow.ui")]
    public class CharacterAttackRow : ExpanderRow {

        [GtkChild] protected unowned Button delete_button { get; }

        [GtkChild] protected unowned Entry weapon_entry;
        [GtkChild] protected unowned Entry range_entry;
        [GtkChild] protected unowned Entry atkbonus_entry;
        [GtkChild] protected unowned Entry damage_entry;

        public CharacterAttack attack { get; set; }

        public CharacterAttackRow(ref CharacterAttack attack) {
            Object();

            this.attack = attack;

            setup_attack();
            setup_details();
            set_attack_details();
        }

        private void setup_attack() {
            this.attack.bind_property("weapon", this.weapon_entry, "text", Util.BINDING_FLAGS);
            this.attack.bind_property("range", this.range_entry, "text", Util.BINDING_FLAGS);
            this.attack.bind_property("atkbonus", this.atkbonus_entry, "text", Util.BINDING_FLAGS);
            this.attack.bind_property("damage", this.damage_entry, "text", Util.BINDING_FLAGS);
        }

        private void setup_details() {
            this.weapon_entry.bind_property("text", this, "title", BindingFlags.SYNC_CREATE);

            this.atkbonus_entry.buffer.deleted_text.connect_after((position, n_chars) => {
                set_attack_details();
            });

            this.atkbonus_entry.buffer.inserted_text.connect_after((position, n_chars) => {
                set_attack_details();
            });

            this.damage_entry.buffer.deleted_text.connect_after((position, n_chars) => {
                set_attack_details();
            });

            this.damage_entry.buffer.inserted_text.connect_after((position, n_chars) => {
                set_attack_details();
            });
        }

        private void set_attack_details() {
            this.set_subtitle(@"ATK Bonus: $(this.atkbonus_entry.text) - DMG: $(this.damage_entry.text)");
        }

        [GtkCallback]
        private void on_delete_button_clicked() {
            var parent = (ListBox) this.parent;
            parent.row_activated(this);
        }
    }
}
