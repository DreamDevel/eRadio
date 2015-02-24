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
    const string play_icon_name = "audio-volume-high-panel";

    public ListStoreFilterType current_filter_type = ListStoreFilterType.NONE;
    public string current_filter_argument = "";

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
        Radio.App.player.play_status_changed.connect (handle_player_status_changed);
    }

    private void load_stations_from_database () {
        var stations = Radio.App.database.get_all_stations ();
        foreach (var station in stations) {
            add_station_entry (station);
        }
    }

    private void handle_station_added (Radio.Models.Station station) {
        if (current_filter_type == ListStoreFilterType.GENRE) {
            foreach (var genre_name in station.genres) {
                if (genre_name == current_filter_argument) {
                    add_station_entry (station);
                    break;
                }
            }
        } else if (current_filter_type == Radio.ListStoreFilterType.NONE) {
            add_station_entry (station);
        }
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

        if (App.player.status == PlayerStatus.PLAYING && App.player.station.id == station.id)
             set_play_icon_to_iter (iterator);
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

    private void handle_player_status_changed (PlayerStatus status) {
        switch (status) {
            case PlayerStatus.PLAYING:
                set_play_icon_to_playing_station ();
                break;
            default :
                remove_play_icon_from_playing_station ();
                break;
        }
    }

    private void set_play_icon_to_playing_station () {
        var playing_station = App.player.station;
        var station_iter = get_iterator_for_station_id (playing_station.id);
        if (station_iter == null)
            return;

        set_play_icon_to_iter (station_iter);
    }

    private void set_play_icon_to_iter (Gtk.TreeIter iterator) {
        set_value(iterator,ICON_COLUMN_ID,play_icon_name);
    }

    private void remove_play_icon_from_playing_station () {
        var playing_station = App.player.station;
        var station_iter = get_iterator_for_station_id (playing_station.id);
        if (station_iter == null)
            return;

        remove_play_icon_from_iter (station_iter);
    }

    private void remove_play_icon_from_iter (Gtk.TreeIter iterator) {
        set_value(iterator,ICON_COLUMN_ID,"");
    }

    private Gtk.TreeIter? get_iterator_for_station_id (int station_id) {
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

    public void apply_filter (ListStoreFilterType filter_type,string filter_argument) {
        if (filter_type == current_filter_type && filter_argument == current_filter_argument) {
            return;
        } else if (filter_type == ListStoreFilterType.NONE) {
            clear ();
            load_stations_from_database ();

        } else if (filter_type == ListStoreFilterType.GENRE) {
            clear ();
            var genre = App.database.get_genre_by_name (filter_argument);
            var stations = App.database.get_stations_by_genre_id (genre.id);

            foreach (var station in stations) {
                add_station_entry (station);
            }

        }

        current_filter_type = filter_type;
        current_filter_argument = filter_argument;
    }
}