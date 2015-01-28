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
 *
 */


public class Radio.Widgets.StationsListStore : Gtk.ListStore {

    const int TITLE_COLUMN_ID = 0;
    const int GENRE_COLUMN_ID = 1;
    const int URL_COLUMN_ID = 2;
    const int ID_COLUMN_ID = 3;
    const int ICON_COLUMN_ID = 4;

    public StationsListStore () {

        set_column_types (new Type[] {
                typeof(string),  // station title column
                typeof(string),  // station genre column
                typeof(string),  // station url column
                typeof(int),     // station id column (hidden)
                typeof(string)  // icon column (icon name)
            });
        connect_handlers_to_external_signals ();
        load_stations_from_database ();
    }

    private void  connect_handlers_to_external_signals () {

        Radio.App.database.station_added.connect (handle_station_added);
        Radio.App.database.station_removed.connect (handle_station_removed);
        Radio.App.database.station_updated.connect (handle_station_updated);
    }

    private void load_stations_from_database () {
        var stations = Radio.App.database.get_all_stations ();
        foreach (var station in stations) {
            add_station_entry (station);
        }
    }

    private void handle_station_added (Radio.Models.Station station) {
        stdout.printf("StationsListStore Handling Station Added\n");
        add_station_entry (station);
    }

    private void add_station_entry (Radio.Models.Station station) {
        var genres_text = "";
        int number_of_genres = station.genres.size;

        if (number_of_genres != 0) {
            for (int i = 0; i < number_of_genres; i++) {
                genres_text += station.genres [i];
                if (i != number_of_genres - 1)
                    genres_text += ", ";
            }
        } else {
            genres_text = "Unknown";
        }

        Gtk.TreeIter iterator;
        append (out iterator);
        set_value (iterator,TITLE_COLUMN_ID,station.name);
        set_value (iterator,GENRE_COLUMN_ID,genres_text);
        set_value (iterator,URL_COLUMN_ID,station.url);
        set_value (iterator,ID_COLUMN_ID,station.id);
    }

    private void handle_station_removed (Radio.Models.Station station) {
        remove_station_with_id (station.id);
    }

    private void remove_station_with_id (int id) {
        this.foreach ((model, path, iter) => {
            Value id_value;
            get_value (iter, ID_COLUMN_ID, out id_value);

            if (id_value.get_int () == id) {
                remove(iter);
                return true;
            }
            return false;
        });
    }

    private void handle_station_updated (Radio.Models.Station old_station, Radio.Models.Station new_station) {
        stdout.printf("StationsListStore Handling Station Updated\n");

        var iterator = get_iterator_for_station_id (new_station.id);
        set_value (iterator,TITLE_COLUMN_ID,new_station.name);
        set_value (iterator,URL_COLUMN_ID,new_station.url);

        // TODO do not create duplicate array to string in every file, create a global method
        var genres_text = "";
        int number_of_genres = new_station.genres.size;

        if (number_of_genres != 0) {
            for (int i = 0; i < number_of_genres; i++) {
                genres_text += new_station.genres [i];
                if (i != number_of_genres - 1)
                    genres_text += ", ";
            }
        } else {
            genres_text = "Unknown";
        }

        set_value (iterator,GENRE_COLUMN_ID,genres_text);
    }

    private Gtk.TreeIter get_iterator_for_station_id (int station_id) {
        Gtk.TreeIter? return_iterator = null;
        this.foreach ((model, path, iter) => {
            Value id_value;
            get_value (iter, ID_COLUMN_ID, out id_value);

            if (id_value.get_int () == station_id) {
                return_iterator = iter;
                return true;
            }
            return false;
        });

        // TODO throw exception if iterator couldn't be found
        return return_iterator;
    }

    public int get_station_id_for_path (Gtk.TreePath path) {
        Gtk.TreeIter iterator;
        Value val;

        get_iter (out iterator,path);
        get_value (iterator, ID_COLUMN_ID, out val);
        return val.get_int ();
    }

    public int get_station_id_for_iterator (Gtk.TreeIter iter) {
        Value val;
        get_value (iter,ID_COLUMN_ID,out val);
        return val.get_int ();
    }

}