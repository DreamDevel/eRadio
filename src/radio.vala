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
 */

class Radio.App : Granite.Application {

    /**
     * Translatable launcher (.desktop) strings to be added to template (.pot) file.
     * These strings should reflect any changes in these launcher keys in .desktop file
     */
    public const string COMMENT = N_("Listen to radio stations");
    public const string GENERIC = N_("Radio");
    public const string KEYWORDS = N_("Radio;Audio;Player;Media;Songs;");

    public static Radio.MainWindow main_window {get;private set;default = null;}
    public static Radio.StreamPlayer player;
    public static Radio.Settings settings;
    public static Radio.App instance;

    public static Radio.Station? playing_station;

    private Radio.MPRIS mpris;

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
        //help_url = "";
        about_artists = {"George Sofianos <georgesofianosgr@gmail.com>", null};
        about_documenters = { "George Sofianos <georgesofianosgr@gmail.com>",
                                      null };

        about_license_type = Gtk.License.GPL_3_0;
        player = new Radio.StreamPlayer ();
        settings = new Radio.Settings ();
        playing_station = null;
    }

    public App () {
        this.set_flags (ApplicationFlags.FLAGS_NONE);
        instance = this;

    }

    public override void activate () {
        if (main_window == null) {
            main_window = new Radio.MainWindow ();
            mpris = new Radio.MPRIS ();
            mpris.initialize ();
        }
    }
}