public class Radio.MainWindow : Gtk.Window {

	// Window widgets
	private Gtk.Box 		main_box;
	private Gtk.Box 		view_box;
	private Gtk.Toolbar 	toolbar;
	private Gtk.ToolButton 	tlb_play_button;
	private Gtk.ToolButton 	tlb_prev_button;
	private Gtk.ToolButton 	tlb_next_button;
	private Gtk.ToolItem 	tlb_space_left;
	private Gtk.ToolItem 	tlb_volume_item;
	private Gtk.ToolItem 	tlb_station_item;
	private Gtk.Label 	    tlb_station_label;
	private Gtk.Scale 		volume_scale;
	private Granite.Widgets.AppMenu app_menu;

	// Views
	private Radio.StationList		list_view;
	private Granite.Widgets.Welcome welcome_view;

	private int view_index = 0;

	public MainWindow () {

		var application = (Radio.App) GLib.Application.get_default();
		this.set_title (application.program_name);
		this.set_size_request (500, 250);
		this.set_application (application);
		this.set_position (Gtk.WindowPosition.CENTER);
		this.icon_name = "radio";
		this.resizable = false;

		toolbar = new Gtk.Toolbar ();

		// Toolbar buttons
		// TODO Change Stock to icon name - Reason : stock is deprecated since Gtk 3.10
		tlb_play_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name("media-playback-start",Gtk.IconSize.LARGE_TOOLBAR),"");
		tlb_prev_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name("media-skip-backward",Gtk.IconSize.LARGE_TOOLBAR),"");
		tlb_next_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name("media-skip-forward",Gtk.IconSize.LARGE_TOOLBAR),"");


		// ToolItem to give some space
		tlb_space_left = new Gtk.ToolItem ();
		tlb_space_left.width_request = 20;

		tlb_volume_item = new Gtk.ToolItem ();
		volume_scale =  new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 100, 1);
		volume_scale.width_request = 100;
		volume_scale.draw_value = false;
		tlb_volume_item.add (volume_scale);

		tlb_station_item = new Gtk.ToolItem ();
		tlb_station_label = new Gtk.Label(null);
		tlb_station_label.set_markup("<b>No Station</b>");
		tlb_station_label.ellipsize = Pango.EllipsizeMode.END;
		tlb_station_item.set_expand (true);
		tlb_station_item.add (tlb_station_label);

		var menu = new Gtk.Menu ();
		menu.append(new Gtk.MenuItem.with_label ("Add New Station"));
		menu.append(new Gtk.MenuItem.with_label ("Search Online Stations"));
		app_menu = application.create_appmenu (menu);

		toolbar.add (tlb_prev_button);
		toolbar.add (tlb_play_button);
		toolbar.add (tlb_next_button);
		toolbar.add (tlb_space_left);
		toolbar.add (tlb_volume_item);
		toolbar.add (tlb_station_item);
		toolbar.add (app_menu);
		toolbar.get_style_context ().add_class ("primary-toolbar");


		// Create Welcome View
		welcome_view = new Granite.Widgets.Welcome ("Radio","Add a station to begin listening");
		var wl_add_image = new Gtk.Image.from_icon_name("document-new",Gtk.IconSize.DND);
		var wl_search_image = new Gtk.Image.from_icon_name("system-search",Gtk.IconSize.DND);

		wl_add_image.set_pixel_size(128);
		wl_search_image.set_pixel_size(128);

		welcome_view.append_with_image (wl_add_image,"Add","Add a new station.");
		welcome_view.append_with_image (wl_search_image,"Search","Search stations online.");

		// Create List Tree
		try {
			list_view = new Radio.StationList ();
			list_view.activated.connect(this.change_station);
		} catch (Radio.Error e) {
			stderr.printf(e.message);
			application.quit();
		}

		if(list_view.count () > 0 )
			this.view_index = 1;

        // Main containers
        main_box = new Gtk.Box (Gtk.Orientation.VERTICAL,0);
        view_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,0);

        main_box.pack_start (toolbar,false);
        main_box.pack_start (view_box);

        /*  Note:
        *   Using Box for view change instead of Gtk.Stack which is not available in Elementary OS Luna
        *   This will change in a future OS release | TODO
        */
        view_box.pack_start (welcome_view);
        view_box.pack_start (list_view);

        this.add(main_box);
        this.show_all();

        // Set Default view
        this.change_view(this.view_index);

        this.connect_ui_signals ();
	}

	private void connect_ui_signals () {

		tlb_play_button.clicked.connect(this.play_pause_clicked);
		tlb_next_button.clicked.connect(this.next_clicked);
	}
	/*

		view-0 : welcome-view
		view-1 : list-view
	*/
	public void change_view (int view_index) {

		if (view_index == 0) {
			list_view.hide ();
			welcome_view.show ();

		} else {
			welcome_view.hide ();
			list_view.show ();

		}

		this.view_index = view_index;
	}

	public void change_station (Radio.Station station) {

		tlb_station_label.set_markup(@"<b>$(station.name)</b>");
		var icon = new Gtk.Image.from_icon_name("media-playback-pause",Gtk.IconSize.LARGE_TOOLBAR);
		icon.show();

		var player = Radio.App.player;
		tlb_play_button.set_icon_widget( icon );
		player.add(station.url);
		player.play();
	}


	/* ---------------- Widgets Events ---------------- */


	public void play_pause_clicked () {

		var player = Radio.App.player;
		var icon_name = "";

		if (player.initialized) {

			if (player.playing) {
				player.pause ();
				icon_name = "media-playback-start";
			} else {
				player.play ();
				icon_name = "media-playback-pause";
			}

			// Update icon
			var icon = new Gtk.Image.from_icon_name(icon_name,Gtk.IconSize.LARGE_TOOLBAR);
			icon.show();
			tlb_play_button.set_icon_widget( icon );
		}
	}

	public void next_clicked () {

	}

	public void prev_clicked () {

	}


}