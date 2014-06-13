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

public class Radio.MainWindow : Gtk.Window {

    // Window widgets
    private Gtk.Box         main_box;
    private Gtk.Box         view_box;
    private Gtk.Toolbar     toolbar;
    private Gtk.ToolButton  tlb_play_button;
    private Gtk.ToolButton  tlb_prev_button;
    private Gtk.ToolButton  tlb_next_button;
    private Gtk.ToolItem    tlb_space_left;
    private Gtk.ToolItem    tlb_volume_item;
    private Gtk.ToolItem    tlb_station_item;
    private Gtk.Label       tlb_station_label;
    private Gtk.Scale       volume_scale;
    private Gtk.MenuItem    menu_item_add;
    private Granite.Widgets.AppMenu app_menu;
    private Radio.StationDialog     dialog_add;
    private Radio.StationDialog     dialog_edit;

    // Views
    private Radio.StationList       list_view;
    private Granite.Widgets.Welcome welcome_view;

    private int view_index = 0; // Change between welcome view (0) & list view (1)

    public MainWindow () {

        var application = (Radio.App) GLib.Application.get_default();
        this.set_title (application.program_name);
        this.set_size_request (500, 250);
        this.set_application (application);
        this.set_position (Gtk.WindowPosition.CENTER);
        this.icon_name = "eradio";
        this.resizable = false;

        toolbar = new Gtk.Toolbar ();

        // Toolbar buttons
        tlb_play_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name("media-playback-start",Gtk.IconSize.LARGE_TOOLBAR),"");
        tlb_prev_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name("media-skip-backward",Gtk.IconSize.LARGE_TOOLBAR),"");
        tlb_next_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name("media-skip-forward",Gtk.IconSize.LARGE_TOOLBAR),"");


        // ToolItem to give some space
        tlb_space_left = new Gtk.ToolItem ();
        tlb_space_left.width_request = 20;

        tlb_volume_item = new Gtk.ToolItem ();
        volume_scale =  new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 1, 0.01);
        volume_scale.width_request = 100;
        volume_scale.set_value(1);
        volume_scale.draw_value = false;
        tlb_volume_item.add (volume_scale);

        tlb_station_item = new Gtk.ToolItem ();
        tlb_station_label = new Gtk.Label(null);
        tlb_station_label.set_markup("<b>No Station</b>");
        tlb_station_label.ellipsize = Pango.EllipsizeMode.END;
        tlb_station_item.set_expand (true);
        tlb_station_item.add (tlb_station_label);


        var menu = new Gtk.Menu ();
        menu_item_add = new Gtk.MenuItem.with_label ("Add New Station");
        menu.append(menu_item_add);
        // Commented out until online search feature is implemented
        //menu.append(new Gtk.MenuItem.with_label ("Search Online Stations"));
        app_menu = application.create_appmenu (menu);

        toolbar.add (tlb_prev_button);
        toolbar.add (tlb_play_button);
        toolbar.add (tlb_next_button);
        toolbar.add (tlb_space_left);
        toolbar.add (tlb_volume_item);
        toolbar.add (tlb_station_item);
        toolbar.add (app_menu);
        toolbar.get_style_context ().add_class ("primary-toolbar");


        welcome_view = new Granite.Widgets.Welcome ("Radio","Add a station to begin listening");
        var wl_add_image = new Gtk.Image.from_icon_name("document-new",Gtk.IconSize.DND);
        // Commented out until online search feature is implemented
        //var wl_search_image = new Gtk.Image.from_icon_name("system-search",Gtk.IconSize.DND);

        wl_add_image.set_pixel_size(128);
        // Commented out until online search feature is implemented
        //wl_search_image.set_pixel_size(128);

        welcome_view.append_with_image (wl_add_image,"Add","Add a new station.");
        // Commented out until online search feature is implemented
        //welcome_view.append_with_image (wl_search_image,"Search","Search stations online.");

        // Note : With StationList creation we initialize the local db
        try {
            list_view = new Radio.StationList ();
            list_view.activated.connect(this.change_station);
        } catch (Radio.Error e) {
            stderr.printf(e.message);
            application.quit();
        }

        // In case db has stations show list else welcome view
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


        // Dialogs
        dialog_add = new Radio.StationDialog (this,"Add");
        dialog_edit = new Radio.StationDialog (this,"Change");


        this.connect_ui_signals ();
    }

    private void connect_ui_signals () {

        tlb_play_button.clicked.connect(this.play_pause_clicked);
        tlb_next_button.clicked.connect(this.next_clicked);
        tlb_prev_button.clicked.connect(this.prev_clicked);

        menu_item_add.activate.connect( () => {
            dialog_add.show();
        });

        dialog_add.button_clicked.connect ( () => {
            list_view.add (dialog_add.entry_name.text,
                           dialog_add.entry_url.text,
                           dialog_add.entry_genre.text);
        });

        dialog_edit.button_clicked.connect ( () => {

            var station = new Radio.Station (list_view.context_menu_row_id,
                                            dialog_edit.entry_name.text,
                                            dialog_edit.entry_url.text,
                                            dialog_edit.entry_genre.text);

            list_view.update(station);
        });

        volume_scale.value_changed.connect( (slider) => {
            var volume_value = slider.get_value();
            Radio.App.player.set_volume(volume_value);
        });

        list_view.edit_station.connect( (station_id) => {
            try {
                var station = list_view.get_station(station_id);
                dialog_edit.entry_name.set_text(station.name);
                dialog_edit.entry_genre.text = station.genre;
                dialog_edit.entry_url.text = station.url;
                dialog_edit.show(false);

            } catch (Radio.Error error) {
                stderr.printf(error.message);
                var application = (Radio.App) GLib.Application.get_default();
                application.quit();
            }
        });
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

    public void prev_clicked (Gtk.ToolButton button) {

        Gtk.TreeIter iter;
        Gtk.TreeModel model;

        // Get Selection object
        var tree_selection = list_view.get_selection ();

        if (tree_selection == null) {
            stderr.printf ("Could not get TreeSelection");

        } else {
            if (tree_selection.get_selected (out model,out iter)) {
                bool previous_iter_exists = model.iter_previous (ref iter);

                // If we reach last entry go to first
                //if(!next_iter_exists)
                //  model.get_iter_first(out iter);

                if (previous_iter_exists) {
                    // Select next
                    tree_selection.select_iter (iter);
                    list_view.row_double_clicked();
                }
            }
        }
    }

    public void next_clicked(Gtk.ToolButton button) {

        Gtk.TreeIter iter;
        Gtk.TreeModel model;

        // Get Selection object
        var tree_selection = list_view.get_selection();

        if (tree_selection == null) {
            stderr.printf ("Could not get TreeSelection");

        } else {
            if (tree_selection.get_selected (out model,out iter)) {
                bool next_iter_exists = model.iter_next (ref iter);

                // If we reach last entry go to first
                // Commented Out Until Implement iter_last for previous clicked - TODO
                /*if(!next_iter_exists)
                    model.get_iter_first(out iter);*/

                if (next_iter_exists) {
                    tree_selection.select_iter (iter);
                    list_view.row_double_clicked ();
                }
            }

        }
    }


}