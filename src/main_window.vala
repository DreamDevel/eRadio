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
    private Gtk.MenuItem    menu_item_import;
    private Gtk.MenuItem    menu_item_export;
    private Granite.Widgets.AppMenu app_menu;
    private Gtk.ScrolledWindow      scroll_view;
    private Radio.StationDialog     dialog_add;
    private Radio.StationDialog     dialog_edit;
    private Radio.ExtractDialog     dialog_extract;
    public static Radio.ErrorDialog dialog_error;

    // Views
    private Radio.StationList       list_view;
    private Granite.Widgets.Welcome welcome_view;

    private int view_index = 0;
    private Notify.Notification? notification;
    private Gdk.Pixbuf notify_icon;

    public MainWindow () {

        var settings = Radio.App.settings;
        try {
            notify_icon = new Gdk.Pixbuf.from_file(Radio.App.instance.build_pkg_data_dir + "/notify.png");
        } catch (GLib.Error error) {
            stderr.printf(error.message);
        }

        this.set_title (Radio.App.instance.program_name);
        this.set_size_request (500, 250);
        this.set_default_size(settings.window_width,settings.window_height);
        this.set_application (Radio.App.instance);
        this.set_position (Gtk.WindowPosition.CENTER);
        this.icon_name = "eradio";
        this.resizable = true;

        this.build_toolbar ();
        this.build_views ();
        this.build_dialogs ();
        this.connect_ui_signals ();

        this.show_all();

        // Set Default view
        this.change_view(this.view_index);
        this.stop ();
    }

    /* --------------- Build UI ---------------- */

    private void build_toolbar () {

        toolbar = new Gtk.Toolbar ();

        // Toolbar buttons
        tlb_play_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name("media-playback-start",Gtk.IconSize.LARGE_TOOLBAR),"");
        tlb_prev_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name("media-skip-backward",Gtk.IconSize.LARGE_TOOLBAR),"");
        tlb_next_button = new Gtk.ToolButton (new Gtk.Image.from_icon_name("media-skip-forward",Gtk.IconSize.LARGE_TOOLBAR),"");


        tlb_prev_button.set_sensitive (false);
        tlb_play_button.set_sensitive (false);
        tlb_next_button.set_sensitive (false);

        // ToolItem to give some space
        tlb_space_left = new Gtk.ToolItem ();
        tlb_space_left.width_request = 20;

        tlb_volume_item = new Gtk.ToolItem ();
        volume_scale =  new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 1, 0.01);
        volume_scale.width_request = 100;
        volume_scale.set_value(Radio.App.settings.volume);
        volume_scale.draw_value = false;
        tlb_volume_item.add (volume_scale);

        tlb_station_item = new Gtk.ToolItem ();
        tlb_station_label = new Gtk.Label(null);
        tlb_station_label.ellipsize = Pango.EllipsizeMode.END;
        tlb_station_item.set_expand (true);
        tlb_station_item.add (tlb_station_label);


        var menu = new Gtk.Menu ();
        menu_item_add = new Gtk.MenuItem.with_label (_("Add New Station"));
        menu_item_import = new Gtk.MenuItem.with_label (_("Import Stations"));
        menu_item_export = new Gtk.MenuItem.with_label (_("Export Stations"));
        menu.append(menu_item_add);
        menu.append(menu_item_import);
        menu.append(menu_item_export);
        app_menu = Radio.App.instance.create_appmenu (menu);

        toolbar.add (tlb_prev_button);
        toolbar.add (tlb_play_button);
        toolbar.add (tlb_next_button);
        toolbar.add (tlb_space_left);
        toolbar.add (tlb_volume_item);
        toolbar.add (tlb_station_item);
        toolbar.add (app_menu);
        toolbar.get_style_context ().add_class ("primary-toolbar");
    }

    private void build_views () {

        var wl_add_image = new Gtk.Image.from_icon_name("document-new",Gtk.IconSize.DND);
        wl_add_image.set_pixel_size(128);

        var wl_import_image = new Gtk.Image.from_icon_name("document-import",Gtk.IconSize.DND);
        wl_import_image.set_pixel_size(128);

        welcome_view = new Granite.Widgets.Welcome ("eRadio",_("Add a station to begin listening"));
        welcome_view.append_with_image (wl_add_image,_("Add"),_("Add a new station."));
        welcome_view.append_with_image (wl_import_image,_("Import"),_("Import stations from eradio package."));

        // Note : With StationList creation we initialize the local db
        try {
            list_view = new Radio.StationList ();
        } catch (Radio.Error e) {
            stderr.printf(e.message);
            application.quit();
        }

        // In case db has stations show list else welcome view
        if(Radio.App.database.count_stations () > 0 )
            this.view_index = 1;

        scroll_view = new Gtk.ScrolledWindow (null, null);
        scroll_view.add(list_view);

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
        view_box.pack_start (scroll_view);
        this.add(main_box);
    }

    private void build_dialogs () {

        dialog_add = new Radio.StationDialog (this,_("Add"));
        dialog_edit = new Radio.StationDialog (this,_("Change"));
        dialog_error = new Radio.ErrorDialog (this);
        dialog_extract = new Radio.ExtractDialog (this);
        Radio.App.progress_dialog = new Radio.ProgressDialog (this);
    }

    private void connect_ui_signals () {

        tlb_play_button.clicked.connect (this.play_pause_clicked);
        tlb_next_button.clicked.connect (this.next_clicked);
        tlb_prev_button.clicked.connect (this.prev_clicked);
        dialog_add.button_clicked.connect (this.dialog_add_success);
        dialog_edit.button_clicked.connect (this.dialog_edit_success);
        list_view.edit_station.connect (this.dialog_edit_open);
        list_view.activated.connect(this.change_station);
        list_view.delete_station.connect (this.station_deleted);
        menu_item_add.activate.connect( () => {dialog_add.show();});
        menu_item_import.activate.connect (this.import_package);
        menu_item_export.activate.connect ( ()=>{dialog_extract.show();} );

        volume_scale.value_changed.connect( (slider) => {
            var volume_value = slider.get_value();
            this.set_volume (volume_value);
        });

        welcome_view.activated.connect ( (index) => {
            if (index == 0) {
                dialog_add.show();
            } else if (index == 1) {
                this.import_package ();
            }
        });

        Radio.App.player.playback_error.connect ( (error) => {
            this.stop ();
            dialog_error.show (error.message);
        });

        list_view.database_error.connect( (e) => {
            stderr.printf (e.message);
            Radio.App.instance.quit ();
        });
    }

    /* Change between welcome view (0) & list view (1) */
    public void change_view (int view_index) {

        if (view_index == 0) {
            scroll_view.hide ();
            welcome_view.show ();

        } else {
            welcome_view.hide ();
            scroll_view.show ();

        }

        this.view_index = view_index;
    }

    /* --------------- Playback Actions ------------- */

    public void change_station (Radio.Station station) {

        Radio.App.playing_station = station;
        try {
            Radio.App.player.add (station.url);
            this.play ();
            this.new_notification (station.name,_("Radio Station Changed"));
        } catch (Radio.Error error) {
            stderr.printf(error.message + "\n");
            dialog_error.show (error.message);
        }
    }

    public void play () {

        Radio.App.playback_status = Radio.PlaybackStatus.PLAYING;
        Radio.App.player.play ();
        this.update_ui ();
    }

    public void pause () {

        Radio.App.playback_status = Radio.PlaybackStatus.PAUSED;
        Radio.App.player.pause ();
        this.update_ui ();
    }

    public void stop () {

        Radio.App.playback_status = Radio.PlaybackStatus.STOPPED;
        Radio.App.playing_station = null;
        Radio.App.player.stop ();
        this.update_ui ();
    }

    public void next () {

        if(Radio.App.playback_status != Radio.PlaybackStatus.STOPPED) {
            if (this.list_view.select_next (Radio.App.playing_station.id))
                this.list_view.row_double_clicked ();
        }
    }

    public void previous () {

        if(Radio.App.playback_status != Radio.PlaybackStatus.STOPPED) {
            if (this.list_view.select_previous (Radio.App.playing_station.id))
                this.list_view.row_double_clicked ();
        }
    }

    public void set_volume (double volume_value,bool update_slider=false) {
        Radio.App.player.set_volume(volume_value);
        Radio.App.settings.volume = volume_value;
    }

    public void new_notification (string title, string subtitle, Gdk.Pixbuf? icon=null) {

        if (notification == null) {
            notification = new Notify.Notification (title,subtitle,null);
            if (icon != null)
                notification.set_image_from_pixbuf (icon);
            else
                notification.set_image_from_pixbuf (notify_icon);
        } else {
            notification.update (title,subtitle,null);
        }

        try {
            if (!this.is_active)
                notification.show ();
        } catch (GLib.Error e) {
            stderr.printf("Could not show notification : %s",e.message);
        }
    }

    public void update_ui () {

        var play_icon_name = "media-playback-start";
        var pause_icon_name = "media-playback-pause";
        var no_station_label = _("No Station Selected");
        var controls_enabled = true;
        Gtk.Image play_pause_icon;


        if (Radio.App.playback_status == Radio.PlaybackStatus.PLAYING) {
            // Change Toolbar Label
            tlb_station_label.set_markup(@"<b>$(Radio.App.playing_station.name)</b>");

            // Update Play/Pause Button Icon
            play_pause_icon = new Gtk.Image.from_icon_name(pause_icon_name,Gtk.IconSize.LARGE_TOOLBAR);

            // Update playing icon
            list_view.set_play_icon (Radio.App.playing_station.id);

        } else if (Radio.App.playback_status == Radio.PlaybackStatus.PAUSED) {
            // Change Toolbar Label
            var paused_str = _("Paused");
            tlb_station_label.set_markup(@"<b>$(Radio.App.playing_station.name)</b> ($paused_str)");

            // Update Play/Pause Button Icon
            play_pause_icon = new Gtk.Image.from_icon_name(play_icon_name,Gtk.IconSize.LARGE_TOOLBAR);


        } else {
            // Change Toolbar Label
            tlb_station_label.set_markup(@"<b>$no_station_label</b>");

            // Update Play/Pause Button Icon
            play_pause_icon = new Gtk.Image.from_icon_name(play_icon_name,Gtk.IconSize.LARGE_TOOLBAR);

            // Update playing icon
            list_view.remove_play_icon ();

            controls_enabled = false;
        }

        if (controls_enabled) {
            tlb_prev_button.set_sensitive (true);
            tlb_play_button.set_sensitive (true);
            tlb_next_button.set_sensitive (true);
        } else {
            tlb_prev_button.set_sensitive (false);
            tlb_play_button.set_sensitive (false);
            tlb_next_button.set_sensitive (false);
        }

        // Set play/pause icon
        tlb_play_button.set_icon_widget( play_pause_icon );
        play_pause_icon.show();

    }

    /* ----------------- Dialog Operations ------------------- */

    private void dialog_add_success () {

        string genres_text = dialog_add.entry_genre.text;
        string[] genres    = genres_text.split (",");
        var genres_list = new Gee.ArrayList <string> ();

            foreach (string iter in genres) {
                iter = iter.strip ();
                if (iter != "")
                    genres_list.add (iter);
            }

        list_view.add (dialog_add.entry_name.text.strip (),
                       genres_list,
                       dialog_add.entry_url.text.strip ());

        if(view_index == 0 && Radio.App.database.count_stations () > 0)
            change_view(1);
    }

    private void dialog_edit_open (int station_id) {

            var station = Radio.App.database.get_station_by_id (station_id);

            string genre_text = "";
            int arraylist_size = station.genres.size;

            //Create a string with genre names
            for (int i=0; i<arraylist_size; i++) {
                genre_text = genre_text+station.genres[i];
                if (i != arraylist_size - 1)
                    genre_text = genre_text + ", ";
            }

            dialog_edit.entry_name.set_text(station.name);
            dialog_edit.entry_genre.text = genre_text;
            dialog_edit.entry_url.text = station.url;
            dialog_edit.show(false);
    }

    private void dialog_edit_success () {

        string genres_text = dialog_edit.entry_genre.text;
        string[] genres    = genres_text.split (",");
        var genres_list = new Gee.ArrayList <string> ();

        foreach (string iter in genres) {
                iter = iter.strip ();
                if (iter != "")
                    genres_list.add (iter.strip ());
        }

        var station = new Radio.Station (list_view.context_menu_row_id,
                                        dialog_edit.entry_name.text.strip (),
                                        dialog_edit.entry_url.text.strip (),
                                        genres_list);
        list_view.update(station);

        // If currently playing change && url changed , update playback
        if (Radio.App.playback_status == Radio.PlaybackStatus.PLAYING &&
            station.id == Radio.App.playing_station.id &&
            station.url != Radio.App.playing_station.url) {

            this.change_station(station);
        }
    }

    /* -------------------- Station Packages ------------------ */

    private void import_package () {

        var file_chooser_import = new Gtk.FileChooserDialog (_("Import Radio Stations Package"),
            null,Gtk.FileChooserAction.OPEN, _("Cancel"),Gtk.ResponseType.CANCEL, _("Open"),Gtk.ResponseType.ACCEPT);
        file_chooser_import.transient_for = this;
        file_chooser_import.destroy_with_parent = true;
        file_chooser_import.set_current_folder (Environment.get_home_dir () + "/Documents");
        var file_filter = new Gtk.FileFilter ();
        file_filter.set_filter_name (_("eRadio Package"));
        file_filter.add_pattern ("*.erpkg");
        file_chooser_import.add_filter(file_filter);

        var response_type = file_chooser_import.run ();

        if ( response_type == Gtk.ResponseType.ACCEPT) {

            try {
                var stations = Radio.PackageManager.parse(file_chooser_import.get_filename ());
                list_view.add_array (stations);

                if(view_index == 0 && Radio.App.database.count_stations () > 0)
                    change_view(1);

            } catch (Radio.Error error) {
                file_chooser_import.close ();
                dialog_error.show (error.message);
            }
        }

        file_chooser_import.destroy ();
    }


    /* ---------------- Button Singal Handlers ---------------- */


    public void play_pause_clicked () {

        if (Radio.App.player.has_url) {

            if (Radio.App.playback_status == Radio.PlaybackStatus.PLAYING)
                this.pause ();
            else
                this.play ();
        }
    }

    public void prev_clicked () {

        this.previous ();
    }

    public void next_clicked() {

        this.next ();
    }

    /* -------------- Other Signal Handlers -------------- */

    private void station_deleted (int station_id) {

        if(view_index == 1 && Radio.App.database.count_stations () == 0)
            change_view(0);

        // Stop playback
        if ( (Radio.App.playback_status == Radio.PlaybackStatus.PLAYING ||
              Radio.App.playback_status == Radio.PlaybackStatus.PAUSED ) &&
            Radio.App.playing_station.id == station_id) {

                this.stop ();
        }
    }



    /* Check for window resize and save new size to settings */
    public override bool configure_event (Gdk.EventConfigure event) {

        var settings = Radio.App.settings;

        if (settings.window_width != event.width)
            settings.window_width = event.width;
        if (settings.window_height != event.height)
            settings.window_height = event.height;
        return base.configure_event (event);
    }


}