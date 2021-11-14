using Gtk;
using Gee;

namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/pages/character-info/CharacterInfoPage.ui")]
    public class CharacterInfoPage : Box {
        [GtkChild] protected unowned ListBox info_listbox;
        [GtkChild] protected unowned ListBox stats_listbox;
        [GtkChild] protected unowned ListBox feats_listbox;
        [GtkChild] protected unowned ListBoxRow feats_row_button;
        // Info
        protected EntryRow info_name;
        protected EntryRow info_class;
        protected EntryRow info_race;
        protected ComboBoxRow info_alignment;
        protected SpinButtonRow info_level;
        protected SpinButtonRow info_xp;

        // Stats
        protected SpinButtonRow stats_proficiency_bonus;
        protected SpinButtonRow stats_armor_class;
        protected SpinButtonRow stats_initiative;
        protected SpinButtonRow stats_speed;
        protected SpinButtonRow stats_hp_max;
        protected SpinButtonRow stats_hp_current;
        protected SpinButtonRow stats_hp_temp;
        protected ComboBoxRow stats_hit_dice;

        // Feats
        protected ArrayList<CharacterFeat> feats { get; set; }

        public CharacterInfoPage() {
            Object();

            this.setup_info();
            this.setup_stats();
            this.setup_feats();
        }

        private void setup_info() {
            this.info_name = new EntryRow(_("Character Name"));
            this.info_class = new EntryRow(_("Class"));
            this.info_race = new EntryRow(_("Race"));

            string[] alignments = {
                _("Lawful Good"),
                _("Neutral Good"),
                _("Chaotic Good"),
                _("Neutral"),
                _("Lawful Evil"),
                _("Neutral Evil"),
                _("Chaotic Evil")
            };
            this.info_alignment = new ComboBoxRow(_("Alignment"), alignments);

            this.info_level = new SpinButtonRow(_("Level"));
            this.info_xp = new SpinButtonRow(_("Experience Points"));

            this.info_listbox.append(this.info_name);
            this.info_listbox.append(new SeparatorRow());
            this.info_listbox.append(this.info_class);
            this.info_listbox.append(new SeparatorRow());
            this.info_listbox.append(this.info_race);
            this.info_listbox.append(new SeparatorRow());
            this.info_listbox.append(this.info_alignment);
            this.info_listbox.append(new SeparatorRow());
            this.info_listbox.append(this.info_level);
            this.info_listbox.append(new SeparatorRow());
            this.info_listbox.append(this.info_xp);
        }

        public void setup_stats() {
            this.stats_proficiency_bonus = new SpinButtonRow(_("Proficiency Bonus"));
            this.stats_armor_class = new SpinButtonRow(_("Armor Class"));
            this.stats_initiative = new SpinButtonRow(_("Initiative"));
            this.stats_speed = new SpinButtonRow(_("Speed"));
            this.stats_hp_max = new SpinButtonRow(_("Hit Point Maximum"));
            this.stats_hp_current = new SpinButtonRow(_("Current Hit Points"));
            this.stats_hp_temp = new SpinButtonRow(_("Temporary Hit Points"));
            this.stats_hit_dice = new ComboBoxRow(_("Hit Dice"), Util.ARRAY_DICE);

            this.stats_listbox.append(this.stats_proficiency_bonus);
            this.stats_listbox.append(new SeparatorRow());
            this.stats_listbox.append(this.stats_armor_class);
            this.stats_listbox.append(new SeparatorRow());
            this.stats_listbox.append(this.stats_initiative);
            this.stats_listbox.append(new SeparatorRow());
            this.stats_listbox.append(this.stats_speed);
            this.stats_listbox.append(new SeparatorRow());
            this.stats_listbox.append(this.stats_hp_max);
            this.stats_listbox.append(new SeparatorRow());
            this.stats_listbox.append(this.stats_hp_current);
            this.stats_listbox.append(new SeparatorRow());
            this.stats_listbox.append(this.stats_hp_temp);
            this.stats_listbox.append(new SeparatorRow());
            this.stats_listbox.append(this.stats_hit_dice);
        }

        private void setup_feats() {
            this.feats = new ArrayList<CharacterFeat>();
        }

        public void bind_character(CharacterSheet character) {
            // Info
            character.bind("name", this.info_name, "text");
            character.bind("class", this.info_class, "text");
            character.bind("race", this.info_race, "text");
            character.bind("alignment", this.info_alignment, "active");
            character.bind("level", this.info_level, "value");
            character.bind("xp", this.info_xp, "value");

            // Stats
            character.bind("proficiency_bonus", this.stats_proficiency_bonus, "value");
            character.bind("armor_class", this.stats_armor_class, "value");
            character.bind("initiative", this.stats_initiative, "value");
            character.bind("speed", this.stats_speed, "value");
            character.bind("hp_max", this.stats_hp_max, "value");
            character.bind("hp_current", this.stats_hp_current, "value");
            character.bind("hp_temp", this.stats_hp_temp, "value");
            character.bind("hit_dice", this.stats_hit_dice, "active");

            // Feats
            character.bind("feats", this, "feats");

            foreach (var feat in this.feats) {
                this.add_feat_row(ref feat, true);
            }
        }

        private void add_feat_row(ref CharacterFeat feat, bool collapse = false) {
            var row = new CharacterFeatRow(ref feat);

            if (collapse) {
                row.collapse_row();
            }

            this.feats_listbox.append(row);
        }

        [GtkCallback]
        public void on_feats_row_clicked(ListBoxRow row) {
            if (row == this.feats_row_button) {
                var feat = new CharacterFeat();
                this.feats.add(feat);

                this.add_feat_row(ref feat);
            } else if (row.get_type() == typeof (CharacterFeatRow)) {
                // Delete Feat
                var feat_row = (CharacterFeatRow) row;
                this.feats.remove(feat_row.feat);
                this.feats_listbox.remove(feat_row);
            }
        }
    }
}
