using Adw;
using Gtk;

namespace DungeonJournal
{
    [GtkTemplate (ui = "/io/github/daved3464/DungeonJournal/ui/StartupWindow.ui")]
    public class StartupWindow : Adw.Window
    {
        private DungeonJournal.ApplicationWindow window;
        
        [GtkChild] private unowned Box recents_box;
        [GtkChild] private unowned ListBox recents_listbox;

        private bool done_startup { get; set; default=false; }

        public StartupWindow(DungeonJournal.ApplicationWindow window)
        {
            Object();
            this.window = window;
            
            this.setup_recents();
            
        }

        public void show_all()
        {
            base.present();
            this.hide_listbox_if_empty();
        }

        private void hide_listbox_if_empty()
        {
            if (this.recents_listbox.observe_children().get_n_items() == 0)
            {
                this.recents_box.hide();
            }
        }

        private void setup_recents()
        {
            var recents = App.settings.recent_files;

            foreach (var file_path in recents)
            {
                var row = new RecentsCharacterRow(file_path);
                this.recents_listbox.append(row);
            }
        }

        private void finish_startup()
        {
            this.done_startup = true;
            this.window.present();
            this.destroy();
        }

        [GtkCallback]
        private void on_open()
        { 
            this.window.on_open(this);

            var res = this.window.startup_finished;

            if (res)
            {
                this.finish_startup();
            }
        }

        [GtkCallback]
        private void on_new()
        {
            this.finish_startup();
        }

        [GtkCallback]
        private void on_recents_row_clicked(ListBoxRow row)
        {
            var recent_row = (RecentsCharacterRow) row;

            this.window.open_character(recent_row.file_path);
            this.finish_startup();
        }

        [GtkCallback]
        private void on_recents_row_delete(ListBox listbox, ListBoxRow? row)
        {
            var recent_row = (RecentsCharacterRow) row;

            this.window.remove_recent_file(recent_row.file_path);

            this.recents_listbox.remove(row);
            this.hide_listbox_if_empty();
        }

        [GtkCallback]
        private void on_destroy()
        {
            if (!this.done_startup)
            {
                this.window.destroy();
            }
        }
    }
}