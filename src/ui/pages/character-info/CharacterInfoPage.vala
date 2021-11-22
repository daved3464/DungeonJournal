using Gtk;
using Gdk;
using Gee;
using Adw;

namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/pages/character-info/CharacterInfoPage.ui")]
    public class CharacterInfoPage : Box {
        // Window
        protected Adw.ApplicationWindow window;

        // Character Sheet
        protected CharacterSheet _character;

        public CharacterSheet character {
            get {
                return _character;
            }
            set {
                _character = value;
            }
        }

        // Avatar
        [GtkChild] protected unowned Avatar character_avatar;

        // Info
        [GtkChild] protected unowned ListBox info_listbox;
        protected EntryRow info_name;
        protected EntryRow info_class;
        protected EntryRow info_race;
        protected ComboRow info_alignment;
        protected SpinButtonRow info_level;
        protected SpinButtonRow info_xp;

        // Stats
        [GtkChild] protected unowned ListBox stats_listbox;
        protected SpinButtonRow stats_proficiency_bonus;
        protected SpinButtonRow stats_armor_class;
        protected SpinButtonRow stats_initiative;
        protected SpinButtonRow stats_speed;
        protected SpinButtonRow stats_hp_max;
        protected SpinButtonRow stats_hp_current;
        protected SpinButtonRow stats_hp_temp;
        protected ComboRow stats_hit_dice;

        // Attacks
        [GtkChild] protected unowned PreferencesGroup attacks_group;
        protected ListBox attacks_listbox;
        protected ArrayList<CharacterAttack> attacks { get; set; }

        // Feats
        [GtkChild] protected unowned PreferencesGroup feats_group;
        protected ListBox feats_listbox;
        protected ArrayList<CharacterFeat> feats { get; set; }

        public CharacterInfoPage(Adw.ApplicationWindow window, CharacterSheet? character) {
            Object();

            this.window = window;

            if (character != null) {
                this.character = character;
            }

            this.setup_info();
            this.setup_stats();
        }

        // Initialization

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

            // Setup alignment row
            this.info_alignment = new Adw.ComboRow();
            this.info_alignment.set_title(_("Alignment"));
            this.info_alignment.set_model(new StringList(alignments));

            // Setup Level rows
            this.info_level = new SpinButtonRow(_("Level"));
            this.info_xp = new SpinButtonRow(_("Experience Points"));

            this.info_listbox.append(this.info_name);
            this.info_listbox.append(this.info_class);
            this.info_listbox.append(this.info_race);
            this.info_listbox.append(this.info_alignment);
            this.info_listbox.append(this.info_level);
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

            this.stats_hit_dice = new ComboRow();
            this.stats_hit_dice.set_title(_("Hit Dice"));
            this.stats_hit_dice.set_model(new StringList(Util.ARRAY_DICE));

            this.stats_listbox.append(this.stats_proficiency_bonus);
            this.stats_listbox.append(this.stats_armor_class);
            this.stats_listbox.append(this.stats_initiative);
            this.stats_listbox.append(this.stats_speed);
            this.stats_listbox.append(this.stats_hp_max);
            this.stats_listbox.append(this.stats_hp_current);
            this.stats_listbox.append(this.stats_hp_temp);
            this.stats_listbox.append(this.stats_hit_dice);
        }

        private void setup_attacks() {
            /** Might make memory leaks (?) */
            if (this.attacks_listbox != null) {
                this.attacks_group.remove(this.attacks_listbox);
            }

            // Setup new list of attacks
            this.attacks = new ArrayList<CharacterAttack>();

            // Setup new listbox
            this.attacks_listbox = new ListBox();
            this.attacks_listbox.set_css_classes({ "content" });
            this.attacks_listbox.set_selection_mode(SelectionMode.NONE);

            // Connect listbox to row_handler
            this.attacks_listbox.row_activated.connect((listbox, row) => {
                on_attacks_row_clicked((CharacterAttackRow) row);
            });
        }

        private void setup_feats() {
            this.feats = new ArrayList<CharacterFeat>();

            // Setup new listbox
            this.feats_listbox = new ListBox();
            this.feats_listbox.set_css_classes({ "content" });
            this.feats_listbox.set_selection_mode(SelectionMode.NONE);

            // Connect listbox to row_handler
            this.feats_listbox.row_activated.connect((listbox, row) => {
                on_feats_row_clicked((CharacterFeatRow) row);
            });

            // Append add button
            /*  this.feats_listbox.append(this.add_row());  */
        }

        // Bindings

        public void bind_character(CharacterSheet character) {

            this.character = character;

            // Avatar
            this.bind_avatar();

            // Info
            this.bind_info();

            // Stats
            this.bind_stats();

            // Attacks
            this.bind_attacks();

            // Feats
            this.bind_feats();
        }

        private void bind_avatar() {
            this.character_avatar.set_custom_image(null);

            if (this.character.character_avatar != "") {
                try {
                    this.decode_character_avatar();
                } catch (Error e) {
                    error(e.message);
                }
            }

            // Avatar initials
            this.character.bind("name", this.character_avatar, "text");
        }

        private void bind_info() {
            this.character.bind("name", this.info_name, "text");
            this.character.bind("class", this.info_class, "text");
            this.character.bind("race", this.info_race, "text");
            this.character.bind("alignment", this.info_alignment, "selected");
            this.character.bind("level", this.info_level, "value");
            this.character.bind("xp", this.info_xp, "value");
        }

        private void bind_stats() {
            this.character.bind("proficiency_bonus", this.stats_proficiency_bonus, "value");
            this.character.bind("armor_class", this.stats_armor_class, "value");
            this.character.bind("initiative", this.stats_initiative, "value");
            this.character.bind("speed", this.stats_speed, "value");
            this.character.bind("hp_max", this.stats_hp_max, "value");
            this.character.bind("hp_current", this.stats_hp_current, "value");
            this.character.bind("hp_temp", this.stats_hp_temp, "value");
            this.character.bind("hit_dice", this.stats_hit_dice, "selected");
        }

        private void bind_attacks() {
            // Clear any attacks
            this.setup_attacks();

            // Bind attacks
            character.bind("attacks", this, "attacks");

            // Add existing attacks to view if any
            foreach (var attack in this.attacks) {
                add_attack_row(ref attack, false);
            }

            this.attacks_group.add(this.attacks_listbox);
        }

        private void bind_feats() {
            // Clear any feats
            this.setup_feats();

            // Bind feats
            this.character.bind("feats", this, "feats");

            // Add existing feats to view if any
            foreach (var feat in this.feats) {
                this.add_feat_row(ref feat, true);
            }

            this.feats_group.add(this.feats_listbox);
        }

        private void decode_character_avatar() throws Error {
            uchar[] character_avatar_decoded = Base64.decode(this.character.character_avatar);

            Texture texture = null;

            size_t bytes_written;

            FileIOStream tmp_image_stream = null;
            File tmp_image = File.new_tmp("character_image-XXXXXX", out tmp_image_stream);

            tmp_image_stream.output_stream.write_all(character_avatar_decoded, out bytes_written);

            texture = Texture.from_file(tmp_image);

            // Will use on gtk 4.6
            /*  if (Gtk.MINOR_VERSION >= 6) {
                texture = Texture.from_bytes(new Bytes(character_avatar_decoded));
               }  */

            // Texture might still be null
            if (texture != null) {
                this.character_avatar.set_custom_image(texture);
            }
        }

        [GtkCallback]
        public void change_avatar_trigger() {
            var filter = new FileFilter();

            filter.add_pixbuf_formats();

            var chooser = new FileChooserNative(
                _("Pick an Avatar"),
                this.window,
                FileChooserAction.OPEN,
                _("Open"),
                _("Cancel")
            );

            chooser.add_filter(filter);
            chooser.show();

            chooser.response.connect_after((res) => {
                if (res == ResponseType.ACCEPT) {
                    try {
                        uint64 file_size_bytes;
                        var image = chooser.get_file();
                        image.measure_disk_usage(FileMeasureFlags.NONE, null, null, out file_size_bytes, null, null);

                        if (file_size_bytes > Util.MAX_IMAGE_BYTES) {
                            throw new Error(Quark.from_string("imaget_size_too_big"), 1, _("The size of the picture is bigger than the 5MB allowed size"));
                        }

                        var texture = Texture.from_file(image);

                        this.character_avatar.set_custom_image(texture);
                        var base64_string = Base64.encode(image.load_bytes().get_data());
                        this.character.character_avatar = base64_string;
                    } catch (Error e) {
                        error(e.message);
                    }
                }
            });
        }

        // Configure Attacks

        /** This function handles the creation of new attack rows */
        private void add_attack_row(ref CharacterAttack attack, bool expanded = true) {
            var row = new CharacterAttackRow(ref attack);

            if (!expanded) {
                row.expanded = expanded;
            }

            this.attacks_listbox.append(row);
        }

        [GtkCallback]
        private void trigger_add_attack_row() {
            var attack = new CharacterAttack();
            this.attacks.add(attack);
            this.add_attack_row(ref attack);
        }

        /** This function adds the creation of new attacks */
        public void on_attacks_row_clicked(CharacterAttackRow row) {
            // Delete Attack
            this.attacks.remove(row.attack);
            this.attacks_listbox.remove(row);
        }

        // Configure Feats

        private void add_feat_row(ref CharacterFeat feat, bool collapse = false) {
            var row = new CharacterFeatRow(ref feat);

            row.set_expanded(!collapse);

            this.feats_listbox.append(row);
        }

        [GtkCallback]
        private void trigger_add_feat_row() {
            var feat = new CharacterFeat();
            this.feats.add(feat);
            this.add_feat_row(ref feat);
        }

        public void on_feats_row_clicked(CharacterFeatRow row) {
            // Delete Feat
            this.feats.remove(row.feat);
            this.feats_listbox.remove(row);
        }
    }
}
