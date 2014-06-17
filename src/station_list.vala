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

    public StationList () throws Radio.Error {
        this.list_source = new Gtk.ListStore (4,typeof(string),typeof(string),typeof(string),typeof(int));
        this.set_model(this.list_source);

        var cell = new Gtk.CellRendererText ();
        this.insert_column_with_attributes (-1, _("Station"), cell, "text", 0);
        this.insert_column_with_attributes (-1, _("Genre"), cell, "text", 1);
        this.insert_column_with_attributes (-1, _("Url"), cell, "text", 2);

        this.get_column (0).set_min_width (140);
        this.get_column (1).set_min_width (100);

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
        return true;
    }
    // -------------- TreeView & ListStore Methods ------------ //


    private void reload_list () {
        this.clear_list ();

        Gee.ArrayList<Radio.Station> stations;
        try {
            stations = stations_db.get_all ();

            foreach (Radio.Station station in stations) {
                this.add_row (station);
            }

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

}