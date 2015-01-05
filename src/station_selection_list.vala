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

public class Radio.StationSelectionList : Gtk.TreeView {

    private Gtk.TreeViewColumn  column_title;
    private Gtk.TreeViewColumn  column_genre;
    private Gtk.TreeViewColumn  column_url;
    private Gtk.ListStore       list_source;

    public StationSelectionList () {

        this.build_ui ();
    }

    private void build_ui () {

        this.list_source = new Gtk.ListStore (4,typeof(string),typeof(string),typeof(string),typeof(int));
        this.set_model(this.list_source);
        this.set_rules_hint(true);
        this.get_selection ().set_mode(Gtk.SelectionMode.MULTIPLE);

        var cell_text_renderer = new Gtk.CellRendererText ();

        this.insert_column_with_attributes (-1, _("Station"), cell_text_renderer, "text", 0);
        this.insert_column_with_attributes (-1, _("Genre"), cell_text_renderer, "text", 1);
        this.insert_column_with_attributes (-1, _("Url"), cell_text_renderer, "text", 2);

        var columns = this.get_columns ();
        foreach(Gtk.TreeViewColumn column in columns) {
            column.resizable = true;
            column.set_sizing(Gtk.TreeViewColumnSizing.FIXED);
        }

        column_title = columns.nth_data(0);
        column_genre = columns.nth_data(1);
        column_url   = columns.nth_data(2);

        column_title.set_fixed_width(Radio.App.settings.title_column_width);
        column_genre.set_fixed_width(Radio.App.settings.genre_column_width);

        column_title.set_min_width (140);
        column_genre.set_min_width (100);
    }

    public void add_stations (Gee.ArrayList<Radio.Models.Station> stations) {

        foreach (Radio.Models.Station station in stations) {
            add_row (station);
        }
    }

    public Gee.ArrayList<Radio.Models.Station>? get_selected () {

        // Get selected as TreePath
        var selection = this.get_selection ();
        var selected_paths = selection.get_selected_rows (null);
        var num_of_selected = selection.count_selected_rows ();

        var selected_stations = new Gee.ArrayList<Radio.Models.Station> ();
        if (num_of_selected > 0) {
            var selected_stations_ids = new int[num_of_selected];

            // Create a List Of IDs
            int i = 0;
            foreach (Gtk.TreePath path in selected_paths) {
                Gtk.TreeIter iter;
                GLib.Value val;
                list_source.get_iter (out iter,path);
                list_source.get_value (iter,3,out val);

                selected_stations_ids[i] = val.get_int ();
                i++;
            }

            // Get stations from database
            foreach (int id in selected_stations_ids) {
                var result = Radio.App.database.get_station_by_id (id);
                if (result != null)
                    selected_stations.add (result);

            }
        }

        return selected_stations;
    }

    public void clear () {
        list_source.clear ();
    }

    private void add_row (Radio.Models.Station station) {
        Gtk.TreeIter iter;

        string genre_text = "";
        int arraylist_size = station.genres.size;

        for (int i=0; i<arraylist_size; i++) {
            genre_text = genre_text+station.genres [i];
            if (i != arraylist_size - 1)
                genre_text = genre_text + ", ";
        }

        list_source.append(out iter);
        list_source.set_value(iter,0,station.name);
        if (genre_text != "")
            list_source.set_value(iter,1,genre_text);
        else
            list_source.set_value(iter,1,"Unknown");
        list_source.set_value(iter,2,station.url);
        list_source.set_value(iter,3,station.id);
    }
}