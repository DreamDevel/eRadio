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

public class Radio.StationList : Gtk.TreeView {

    private Gtk.ListStore   list_source;
    private Radio.Stations  stations_db;
    private Gtk.Menu        context_menu;

    public signal void activated(Radio.Station station);
    public signal void edit_station(int station_id);
    public signal void delete_station (int station_id);

    public int context_menu_row_id;

    private Gtk.TreeViewColumn column_play_icon;
    private Gtk.TreeViewColumn column_title;
    private Gtk.TreeViewColumn column_genre;
    private Gtk.TreeViewColumn column_url;

    private Gtk.TreeIter? iter_play_icon;

    public StationList () throws Radio.Error {
        // Station,Genre,Url,ID,Icon
        this.list_source = new Gtk.ListStore (5,typeof(string),typeof(string),typeof(string),typeof(int),typeof(string));
        this.set_model(this.list_source);
        this.set_rules_hint(true);

        var cell_text_renderer = new Gtk.CellRendererText ();
        var cell_pixbuf_renderer = new Gtk.CellRendererPixbuf ();

        var icon_column = new Gtk.TreeViewColumn ();
        icon_column.set_title (" ");
        icon_column.pack_start(cell_pixbuf_renderer,false);
        icon_column.add_attribute(cell_pixbuf_renderer,"icon-name",4);
        this.append_column(icon_column);

        this.insert_column_with_attributes (-1, _("Station"), cell_text_renderer, "text", 0);
        this.insert_column_with_attributes (-1, _("Genre"), cell_text_renderer, "text", 1);
        this.insert_column_with_attributes (-1, _("Url"), cell_text_renderer, "text", 2);

        var columns = this.get_columns ();
        foreach(Gtk.TreeViewColumn column in columns) {
            column.resizable = true;
            column.set_sizing(Gtk.TreeViewColumnSizing.FIXED);
        }

        column_play_icon = icon_column;
        column_title = columns.nth_data(1);
        column_genre = columns.nth_data(2);
        column_url   = columns.nth_data(3);

        column_title.set_fixed_width(Radio.App.settings.title_column_width);
        column_genre.set_fixed_width(Radio.App.settings.genre_column_width);

        column_play_icon.resizable = false;
        column_play_icon.set_min_width(30);
        column_title.set_min_width (140);
        column_genre.set_min_width (100);

        this.row_activated.connect (this.row_double_clicked);
        this.button_release_event.connect (this.open_context_menu);

        context_menu = new Gtk.Menu ();
        var menu_item_edit = new Gtk.MenuItem.with_label (_("Edit"));
        var menu_item_remove = new Gtk.MenuItem.with_label (_("Remove"));
        context_menu.add (menu_item_edit);
        context_menu.add (menu_item_remove);
        context_menu.show_all ();

        var home_dir = File.new_for_path (Environment.get_home_dir ());
        var radio_dir = home_dir.get_child(".local").get_child("share").get_child("eradio");
        var db_file = radio_dir.get_child("stations.db");

        // Create ~/.local/share/eradio path
        if (! radio_dir.query_exists ()) {
            try {
                radio_dir.make_directory_with_parents();
            } catch (GLib.Error error) {
                stderr.printf(error.message);
            }

        }

        try {
            this.stations_db = new Radio.Stations.with_db_file (db_file.get_path());
        } catch (Radio.Error e) {
            throw e;
        }

        this.reload_list ();

        menu_item_edit.activate.connect(this.edit_clicked);
        menu_item_remove.activate.connect(this.remove_clicked);
        column_title.notify.connect(this.title_column_resized);
        column_genre.notify.connect(this.genre_column_resized);

        //list_source.set_value(get_iterator(2),4,"eradio");

    }

    public new void add (string name,string url,string genre) {
        try {
                stations_db.add (name,url,genre);
                this.reload_list ();
            } catch (Radio.Error error) {
                stderr.printf (error.message);
            }
    }

    public void update (Radio.Station station) {
        try {
                stations_db.update (station);
                this.reload_list ();
            } catch (Radio.Error error) {
                stderr.printf (error.message);
            }
    }

    public Radio.Station get_station (int station_id) throws Radio.Error {
        var filters = new Gee.HashMap<string,string> ();
        filters["id"] = @"$station_id";
        try {
            var station = stations_db.get (filters);
            return station[0];
        } catch (Radio.Error error) {
            throw error;
        }
    }

    public int count () {

        var num_stations = 0;
        try {
            num_stations = stations_db.count ();
        } catch (Radio.Error e) {
            stderr.printf (e.message);
        }

        return num_stations;
    }

    // Seted this as public so we can simulate station selection from window
    public void row_double_clicked() {

        Gtk.TreeIter iter;
        Gtk.TreeModel model;

        var tree_selection = this.get_selection();

        if(tree_selection == null) {
            stderr.printf("Could not get TreeSelection");
        } else {
            // Get selection id
            GLib.Value val;
            tree_selection.get_selected(out model,out iter);
            model.get_value(iter,3,out val);

            // Get station object
            var filters = new Gee.HashMap<string,string>();
            filters["id"] = "%d".printf(val.get_int());
            Gee.ArrayList<Radio.Station> station_list;

            try {
                station_list = stations_db.get(filters);

                if (station_list.size == 1) {
                    Station station = station_list[0];
                    this.activated (station);
                }
                else {
                    throw new Radio.Error.GENERAL (
                        "Model returned more or less values than one - Possible Duplicate Entry or wrong entry request");
                }
            } catch (Radio.Error e) {
                stderr.printf(e.message);
            }
        }
    }

    private void edit_clicked () {
        edit_station (context_menu_row_id);
    }

    private void remove_clicked () {
        try {
            stations_db.delete (context_menu_row_id);
            this.delete_station (context_menu_row_id);
            this.reload_list ();
        } catch (Radio.Error error) {
            stderr.printf(error.message);
        }
    }

    private bool open_context_menu (Gdk.EventButton event) {
        if(event.button == 3) {
            Gtk.TreePath path;
            var row_exists = this.get_path_at_pos((int)event.x,(int)event.y,
                                                        out path,null,null,null);
            if (row_exists) {
                this.context_menu.popup (null,null,null,event.button,event.time);
                Gtk.TreeIter iter;
                Value val;
                list_source.get_iter (out iter, path);
                list_source.get_value (iter, 3, out val);
                context_menu_row_id = (int) val;
            }
        }
        return false;
    }


    public void set_play_icon (int station_id) {

        if (station_id >= 0) {
            var iterator = this.get_iterator (station_id);
            this.set_play_icon_by_iter (iterator);
        }
    }

    private void set_play_icon_by_iter (Gtk.TreeIter? iterator) {
        if (iterator != null) {
            this.remove_play_icon ();
            list_source.set_value(iterator,4,"audio-volume-high-panel");
            this.iter_play_icon = iterator;
        }
    }

    public void remove_play_icon () {
        if (this.iter_play_icon != null && list_source.iter_is_valid(this.iter_play_icon)) {
            list_source.set_value(this.iter_play_icon,4,"");
            this.iter_play_icon = null;
        }
    }
    // -------------- TreeView & ListStore Methods ------------ //


    private void reload_list () {
        // Save Station ID Before Clear List
        int station_id_icon = -1;
        if (this.iter_play_icon != null) {
            GLib.Value station_id_val;
            list_source.get_value(this.iter_play_icon,3, out station_id_val);
            station_id_icon = station_id_val.get_int ();
        }
        this.clear_list ();

        Gee.ArrayList<Radio.Station> stations;
        try {
            stations = stations_db.get_all ();

            foreach (Radio.Station station in stations) {
                this.add_row (station);
            }
            this.set_play_icon (station_id_icon);

        } catch (Radio.Error e) {
            stderr.printf(e.message);
        }
    }

    private void add_row (Radio.Station station) {
        Gtk.TreeIter iter;
        list_source.append(out iter);
        list_source.set_value(iter,0,station.name);
        list_source.set_value(iter,1,station.genre);
        list_source.set_value(iter,2,station.url);
        list_source.set_value(iter,3,station.id);
    }

    private void clear_list () {
        list_source.clear ();
    }

    /* Find iterator for specified station id */
    private Gtk.TreeIter? get_iterator (int station_id) {

        Gtk.TreeIter iter;
        bool iter_exist = this.model.get_iter_first (out iter);
        bool iter_found = false;

        while (iter_exist) {
            GLib.Value val;
            list_source.get_value(iter,3,out val);
            int id = val.get_int ();

            if (station_id == id) {
                iter_found = true;
                break;
            }

            iter_exist = this.model.iter_next (ref iter);
        }

        if(iter_found)
            return iter;
        else
            return null;

    }


    private void title_column_resized (GLib.ParamSpec param) {

        if (param.get_name () == "width") {
            Radio.App.settings.title_column_width = column_title.width;
        }
    }


    private void genre_column_resized (GLib.ParamSpec param) {

        if (param.get_name () == "width") {
            Radio.App.settings.genre_column_width = column_genre.width;
        }
    }

}