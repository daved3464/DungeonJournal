using Gtk;
using Gdk;
using Gee;
using Adw;

namespace DungeonJournal {
    [GtkTemplate(ui = "/io/github/daved3464/DungeonJournal/ui/pages/character-info/CharacterInfoPage.ui")]
    public class CharacterInfoPage : Box {
        // Window
        protected Adw.ApplicationWindow window;

        // Avatar
        [GtkChild] protected unowned Avatar character_avatar;

        // Data Rows
        [GtkChild] protected unowned ListBox info_listbox;
        [GtkChild] protected unowned ListBox stats_listbox;
        [GtkChild] protected unowned ListBox feats_listbox;
        [GtkChild] protected unowned ListBoxRow feats_row_button;

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

        // Info
        protected EntryRow info_name;
        protected EntryRow info_class;
        protected EntryRow info_race;
        protected ComboRow info_alignment;
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
        protected ComboRow stats_hit_dice;

        // Feats
        protected ArrayList<CharacterFeat> feats { get; set; }

        public CharacterInfoPage(Adw.ApplicationWindow window, CharacterSheet? character) {
            Object();

            this.window = window;

            if (character != null) {
                this.character = character;
            }

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

            this.info_alignment = new Adw.ComboRow();
            this.info_alignment.set_title(_("Alignment"));
            this.info_alignment.set_model(new StringList(alignments));

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

        private void setup_feats() {
            this.feats = new ArrayList<CharacterFeat>();
        }

        public void bind_character(CharacterSheet character) {

            this.character = character;

            if (this.character.character_avatar != "") {
                try {
                    this.decode_character_avatar();
                } catch (Error e) {
                    error(e.message);
                }
            }

            // Avatar initials
            this.character.bind("name", this.character_avatar, "text");

            // Info
            this.character.bind("name", this.info_name, "text");
            this.character.bind("class", this.info_class, "text");
            this.character.bind("race", this.info_race, "text");
            this.character.bind("alignment", this.info_alignment, "selected");
            this.character.bind("level", this.info_level, "value");
            this.character.bind("xp", this.info_xp, "value");

            // Stats
            this.character.bind("proficiency_bonus", this.stats_proficiency_bonus, "value");
            this.character.bind("armor_class", this.stats_armor_class, "value");
            this.character.bind("initiative", this.stats_initiative, "value");
            this.character.bind("speed", this.stats_speed, "value");
            this.character.bind("hp_max", this.stats_hp_max, "value");
            this.character.bind("hp_current", this.stats_hp_current, "value");
            this.character.bind("hp_temp", this.stats_hp_temp, "value");
            this.character.bind("hit_dice", this.stats_hit_dice, "selected");

            // Feats
            this.character.bind("feats", this, "feats");

            foreach (var feat in this.feats) {
                this.add_feat_row(ref feat, true);
            }
        }

        private void decode_character_avatar() throws Error {
            uchar[] character_avatar_decoded = Base64.decode(this.character.character_avatar);

            Texture texture = null;

            size_t bytes_written;

            FileIOStream tmp_image_stream = null;
            File tmp_image = File.new_tmp("character_image-XXXXXX", out tmp_image_stream);

            tmp_image_stream.output_stream.write_all(character_avatar_decoded, out bytes_written);

            texture = Texture.from_file(tmp_image);

            /*  if (Gtk.MINOR_VERSION >= 6) {
                texture = Texture.from_bytes(new Bytes(character_avatar_decoded));
               }  */


            this.character_avatar.set_custom_image(texture);
        }

        private void add_feat_row(ref CharacterFeat feat, bool collapse = false) {
            var row = new CharacterFeatRow(ref feat);

            row.set_expanded(!collapse);

            this.feats_listbox.append(row);
        }

        [GtkCallback]
        public void change_avatar_trigger() {
            var filter = new FileFilter();

            filter.add_pixbuf_formats();

            var chooser = new FileChooserNative(
                _("_Pick an Avatar"),
                this.window,
                FileChooserAction.OPEN,
                _("_Open"),
                _("_Cancel")
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
                            throw new Error(Quark.from_string("imaget_size_too_big"), 1, _("_The size of the picture is bigger than the 5MB allowed size"));
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
