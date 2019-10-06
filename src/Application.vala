namespace DungeonJournal
{ 
    public class App : Gtk.Application
    {
        public Window window;

        public App()
        {
            Object(
                application_id: "io.github.trytonvanmeer.DungeonJournal",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }

        protected override void startup()
        {
            base.startup();
            setup_actions();
        }

        protected override void activate()
        {
            window = new DungeonJournal.Window(this);
            window.show_all();
        }

        private void setup_actions()
        {
            var about_action = new GLib.SimpleAction("about", null);
            about_action.activate.connect(() =>
            {
                show_about_dialog();
            });

            var shortcuts_action = new GLib.SimpleAction("shortcuts", null);
            shortcuts_action.activate.connect(() =>
            {
                show_shortcuts_dialog();
            });

            var open_action = new GLib.SimpleAction("open", null);
            open_action.activate.connect(()=>
            {
                this.window.on_open();
            });

            var save_action = new GLib.SimpleAction("save", null);
            save_action.activate.connect(() =>
            {
                this.window.on_save();
            });

            var save_as_action = new GLib.SimpleAction("save_as", null);
            save_as_action.activate.connect(() =>
            {
                this.window.on_save_as();
            });

            this.add_action(open_action);
            this.add_action(save_action);
            this.add_action(shortcuts_action);
            this.add_action(about_action);
            this.add_action(save_as_action);

            // Setup Accelerators
            set_accels_for_action("app.open", {"<Primary>o"});
            set_accels_for_action("app.save", {"<Primary>s"});
            set_accels_for_action("app.save_as", {"<Primary><Shift>S"});
        }

        private void show_about_dialog()
        {
            string[] authors =
            {
                "Tryton Van Meer <trytonvanmeer@gmail.com>",
            };

            Gtk.show_about_dialog
            (
                window,
                logo_icon_name: "io.github.trytonvanmeer.DungeonJournal",
                program_name: "Dungeon Journal",
                comments: _("Create Characters"),
                copyright: "© 2019 Tryton Van Meer",
                authors: authors,
                website: "https://github.com/tryton-vanmeer/DungeonJournal",
                website_label: _("GitHub Homepage"),
                version: Config.VERSION,
                license_type: Gtk.License.GPL_3_0
            );
        }

        private void show_shortcuts_dialog()
        {

        }
    }

    public static int main(string[] args)
    {
        // Setup gettext
        Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
        Intl.setlocale(LocaleCategory.ALL, "");
        Intl.textdomain(Config.GETTEXT_PACKAGE);
        Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "utf-8");

        Gtk.init(ref args);
        Hdy.init (ref args);

        var app = new App();

        return app.run(args);
    }
}
