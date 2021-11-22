using Gtk;
using Gee;
using Adw;

namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/pages/character-inventory/CharacterInventoryPage.ui")]
    public class CharacterInventoryPage : Box {

        // Currency
        [GtkChild] protected unowned ListBox currency_listbox;
        protected SpinButtonRow currency_copper;
        protected SpinButtonRow currency_silver;
        protected SpinButtonRow currency_gold;

        // Items
        [GtkChild] protected unowned PreferencesGroup items_group;
        protected ListBox items_listbox;
        protected ArrayList<CharacterItem> items { get; set; }

        protected DungeonJournal.ApplicationWindow window;

        protected CharacterSheet character;

        public CharacterInventoryPage(DungeonJournal.ApplicationWindow window) {
            Object();

            this.window = window;

            this.setup_currency();
        }

        private void setup_currency() {

            this.currency_copper = new SpinButtonRow(_("Copper"));
            this.currency_silver = new SpinButtonRow(_("Silver"));
            this.currency_gold = new SpinButtonRow(_("Gold"));

            this.currency_listbox.append(this.currency_copper);
            this.currency_listbox.append(this.currency_silver);
            this.currency_listbox.append(this.currency_gold);
        }

        private void setup_items() {
            if (this.items_listbox != null) {
                this.items_group.remove(this.items_listbox);
            }
            this.items = new ArrayList<CharacterItem>();

            // Setup new listbox
            this.items_listbox = new ListBox();
            this.items_listbox.set_css_classes({ "content" });
            this.items_listbox.set_selection_mode(SelectionMode.NONE);

            // Connect listbox to row_handler
            this.items_listbox.row_activated.connect((listbox, row) => {
                on_items_row_clicked((CharacterItemRow) row);
            });
        }

        public void bind_character(CharacterSheet character) {

            this.character = character;
            // Currency
            this.bind_currency();

            // Items
            this.bind_items();
        }

        protected void bind_currency() {

            this.character.bind("currency-copper", this.currency_copper, "value");
            this.character.bind("currency-silver", this.currency_silver, "value");
            this.character.bind("currency-gold", this.currency_gold, "value");
        }

        protected void bind_items() {
            this.setup_items();

            this.character.bind("items", this, "items");

            foreach (var item in this.items) {
                add_item_row(ref item, false);
            }

            this.items_group.add(this.items_listbox);
        }

        private void add_item_row(ref CharacterItem item, bool expanded = true) {
            var row = new CharacterItemRow(ref item);

            if (!expanded) {
                row.expanded = expanded;
            }

            this.items_listbox.append(row);
        }

        [GtkCallback]
        public void trigger_add_item_row() {
            var item = new CharacterItem();
            this.items.add(item);
            this.add_item_row(ref item);
        }

        public void on_items_row_clicked(CharacterItemRow row) {
            this.items.remove(row.item);
            this.items_listbox.remove(row);
        }
    }
}
