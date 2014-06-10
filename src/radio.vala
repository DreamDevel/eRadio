
class Radio.App : Granite.Application {

	/**
	 * Translatable launcher (.desktop) strings to be added to template (.pot) file.
	 * These strings should reflect any changes in these launcher keys in .desktop file
	 */
	public const string COMMENT = N_("Listen to radio stations");
	public const string GENERIC = N_("Radio");
	public const string KEYWORDS = N_("Radio;Audio;Player;Media;Songs;");

	public static Gtk.Window main_window {get;private set;default = null;}

	construct {
		// Application info
		build_data_dir = Build.DATADIR;
		build_pkg_data_dir = Build.PKG_DATADIR;
		build_release_name = Build.RELEASE_NAME;
		build_version = Build.VERSION;
		build_version_info = Build.VERSION_INFO;

		program_name = "Radio";
		exec_name = "radio";

		app_copyright = "2014";
		application_id = "org.dreamdev.radio";
		app_icon = "radio";
		app_launcher = "radio.desktop";
		app_years = "2014";

		main_url = "https://launchpad.net/radio";
		bug_url = "https://bugs.launchpad.net/radio/+filebug";
		translate_url = "https://translations.launchpad.net/radio";
		about_authors = {"George Sofianos <georgesofianosgr@gmail.com>",null};
		//help_url = "http://elementaryos.org/answers/+/noise/all/newest"; No help url available yet
		//about_artists = {"Daniel Foré <daniel@elementaryos.org>", null};
	}

	public App () {
		this.set_flags (ApplicationFlags.FLAGS_NONE);

	}

	public override void activate () {
		if (main_window == null) {
			main_window = new Radio.MainWindow ();
		}
	}

}