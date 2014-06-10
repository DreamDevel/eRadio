public class Radio.MainWindow : Gtk.Window {

	// Window widgets
	private Gtk.Toolbar 	toolbar;
	private Gtk.ToolButton 	tlb_add_button;
	private Gtk.ToolButton 	tlb_del_button;
	private Gtk.ToolButton 	tlb_play_button;
	private Gtk.ToolButton 	tlb_prev_button;
	private Gtk.ToolButton 	tlb_next_button;
	private Gtk.ToolItem 	space_left;
	private Gtk.ToolItem 	space_right;
	private Gtk.Box 		main_box;
	private Gtk.Box 		view_box;
	private Granite.Widgets.AppMenu app_menu;

	// Views
	private Gtk.TreeView			list_view;
	private Granite.Widgets.Welcome welcome_view;

	private int view_index = 0;

	public MainWindow () {
		var application = (Radio.App) GLib.Application.get_default();
		this.set_title (application.program_name);
		this.set_default_size (600,400);
		this.set_application (application);
		this.set_position (Gtk.WindowPosition.CENTER);

		toolbar = new Gtk.Toolbar ();

		// Toolbar buttons
		// TODO Change Stock to icon name - Reason : stock is deprecated since Gtk 3.10
		tlb_add_button = new Gtk.ToolButton ( new Gtk.Image.from_stock(Gtk.Stock.NEW,Gtk.IconSize.LARGE_TOOLBAR), "");
		tlb_del_button = new Gtk.ToolButton ( new Gtk.Image.from_stock(Gtk.Stock.REMOVE,Gtk.IconSize.LARGE_TOOLBAR), "");
		tlb_play_button = new Gtk.ToolButton (new Gtk.Image.from_stock(Gtk.Stock.MEDIA_PLAY,Gtk.IconSize.LARGE_TOOLBAR),"");
		tlb_prev_button = new Gtk.ToolButton (new Gtk.Image.from_stock(Gtk.Stock.MEDIA_PREVIOUS,Gtk.IconSize.LARGE_TOOLBAR),"");
		tlb_next_button = new Gtk.ToolButton (new Gtk.Image.from_stock(Gtk.Stock.MEDIA_NEXT,Gtk.IconSize.LARGE_TOOLBAR),"");

		// Some Toolitem that expand to add space
		space_left = new Gtk.ToolItem ();
		space_right = new Gtk.ToolItem ();
		space_left.set_expand (true);
		space_right.set_expand (true);

		// Default elementary os button at the right side
		app_menu = application.create_appmenu (new Gtk.Menu ());

		toolbar.add (tlb_add_button);
		toolbar.add (tlb_del_button);
		toolbar.add (space_left);
		toolbar.add (tlb_prev_button);
		toolbar.add (tlb_play_button);
		toolbar.add (tlb_next_button);
		toolbar.add (space_right);
		toolbar.add (app_menu);
		toolbar.get_style_context ().add_class ("primary-toolbar");


		// Create Welcome Page
		welcome_view = new Granite.Widgets.Welcome ("Radio","Add a station to begin listening");

		var wl_add_image = new Gtk.Image.from_icon_name("document-new",Gtk.IconSize.DND);
		var wl_search_image = new Gtk.Image.from_icon_name("system-search",Gtk.IconSize.DND);

		wl_add_image.set_pixel_size(128);
		wl_search_image.set_pixel_size(128);

		welcome_view.append_with_image (wl_add_image,"Add","Add a new station.");
		welcome_view.append_with_image (wl_search_image,"Search","Search stations online.");

		// Create List Tree
		list_view = new Gtk.TreeView ();

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
			list_view.hide ();

		}

		this.view_index = view_index;
	}
}