/*-
 *  Copyright (c) 2014 George Sofianos
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Authored by: George Sofianos <georgesofianosgr@gmail.com>
 *               Fotini Skoti <fotini.skoti@gmail.com>
 */

class Radio.App : Granite.Application {

    // TODO remove these, never used it
    /**
     * Translatable launcher (.desktop) strings to be added to template (.pot) file.
     * These strings should reflect any changes in these launcher keys in .desktop file
     */
    public const string COMMENT = N_("Listen to radio stations");
    public const string GENERIC = N_("Radio");
    public const string KEYWORDS = N_("Radio;Audio;Player;Media;Songs;");

    public static Radio.Windows.MainWindow main_window {get;private set;default = null;}
    public static Radio.Settings settings;
    public static Radio.App instance;
    public static Radio.Core.Database database;
    public static Radio.Core.Player player;

    public static Radio.Dialogs.AddStationDialog add_dialog;
    public static Radio.Dialogs.EditStationDialog edit_dialog;
    public static Radio.Dialogs.ErrorDialog error_dialog;
    public static Radio.ProgressDialog progress_dialog;

    public static Radio.PlaybackStatus playback_status {get;set;default=Radio.PlaybackStatus.STOPPED;}
    public static Radio.Models.Station? playing_station;

    private Radio.MPRIS mpris;

    public signal void ui_build_finished ();

    construct {
        // Application info
        build_data_dir = Build.DATADIR;
        build_pkg_data_dir = Build.PKG_DATADIR;
        build_release_name = Build.RELEASE_NAME;
        build_version = Build.VERSION;
        build_version_info = Build.VERSION_INFO;

        program_name = "eRadio";
        exec_name = "eradio";

        app_copyright = "2014";
        application_id = "org.dreamdev.eradio";
        app_icon = "eradio";
        app_launcher = "eradio.desktop";
        app_years = "2014";

        main_url = "https://launchpad.net/eradio";
        bug_url = "https://bugs.launchpad.net/eradio/+filebug";
        translate_url = "https://translations.launchpad.net/eradio";
        about_authors = {"George Sofianos <georgesofianosgr@gmail.com>",null};
        help_url = "https://answers.launchpad.net/eradio";
        about_artists = {"George Sofianos <georgesofianosgr@gmail.com>", null};
        about_documenters = { "George Sofianos <georgesofianosgr@gmail.com>",
                                      null };
        about_license_type = Gtk.License.GPL_3_0;

        this.set_flags (ApplicationFlags.FLAGS_NONE);

        playing_station = null; // TODO remove

    }

    public App () {
        instance = this;
    }

    public override void activate () {
        initialize ();

    }

    public void initialize () {
        create_core_objects ();
        create_user_interface ();

    }

    private void create_core_objects () {
        player = new Radio.Core.Player ();
        settings = new Radio.Settings ();
        mpris = new Radio.MPRIS ();

        initialize_database ();
        Radio.MediaKeyListener.instance.init ();
        mpris.initialize ();
        Notify.init (this.program_name);
    }

    private void create_user_interface () {
        create_window ();
        create_dialogs ();
        ui_build_finished ();
    }

    private void create_window () {
        main_window = new  Radio.Windows.MainWindow ();
    }

    private void create_dialogs () {
        add_dialog = new Radio.Dialogs.AddStationDialog.with_parent (main_window);
        edit_dialog = new Radio.Dialogs.EditStationDialog.with_parent (main_window);
        error_dialog = new Radio.Dialogs.ErrorDialog.with_parent (main_window);
    }

    private void initialize_database () {

        var home_dir = File.new_for_path (Environment.get_home_dir ());
        var radio_dir = home_dir.get_child(".local").get_child("share").get_child("eradio");
        var db_file = radio_dir.get_child("stationsv2.db");

        // Create ~/.local/share/eradio path
        if (! radio_dir.query_exists ()) {
            try {
                radio_dir.make_directory_with_parents();
            } catch (GLib.Error error) {
                stderr.printf(error.message);
            }

        }

        try {
            database = new Radio.Core.Database ();
            database.connect_to_database_file (db_file.get_path());
        } catch (Radio.Error e) {
            stderr.printf(e.message);
        }
    }
}