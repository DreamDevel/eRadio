/*-
 *  Copyright (c) 2015 George Sofianos
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

 using Gee;


public class Radio.Widgets.SideBar : Granite.Widgets.SourceList {

    public Granite.Widgets.SourceList.ExpandableItem genre_list_item;
    public Granite.Widgets.SourceList.Item all_stations_item;

    private HashMap <int,Granite.Widgets.SourceList.Item> genre_list_items;

    public SideBar () {
        build_interface ();
        connect_handlers_to_external_signals ();
        load_genres ();
    }

    private void build_interface () {
        width_request = 150;

        genre_list_item = new Granite.Widgets.SourceList.ExpandableItem ("Genres");
        genre_list_item.expanded = true;

        var stations_number = Radio.App.database.count_stations ();
        all_stations_item = new Granite.Widgets.SourceList.Item ("All Stations");
        all_stations_item.badge = @"$stations_number";

        genre_list_items = new HashMap <int,Granite.Widgets.SourceList.Item> ();
        root.add (all_stations_item);
        root.add (genre_list_item);
    }

    private void load_genres () {
        var genres_list = Radio.App.database.get_all_genres ();
        foreach (var genre in genres_list) {
            var stations_of_genre = Radio.App.database.count_entries_of_genre_id (genre.id);
            add_genre (genre,stations_of_genre);
        }
    }

    private void connect_handlers_to_external_signals () {
        Radio.App.database.genre_added.connect (handle_genre_added);
        Radio.App.database.genre_removed.connect (handle_genre_removed);
        Radio.App.database.station_added.connect (handle_station_added);
        Radio.App.database.station_removed.connect (handle_station_removed);
        Radio.App.database.station_updated.connect (handle_station_updated);
    }

    private void handle_genre_added (Radio.Models.Genre genre) {
        add_genre (genre,0); // station added handler will increase the badge
    }

    private void handle_genre_removed (Radio.Models.Genre genre) {
        var item = genre_list_items[genre.id];
        genre_list_items.unset (genre.id);
        genre_list_item.remove (item);
    }

    private void handle_station_added (Radio.Models.Station station) {
        var number_of_stations = int.parse (all_stations_item.badge);
        number_of_stations++;
        all_stations_item.badge = @"$number_of_stations";

        foreach (var genre_name in station.genres) {
            increase_genre_badge (genre_name);
        }
    }

    private void handle_station_removed (Radio.Models.Station station) {
        var number_of_stations = int.parse (all_stations_item.badge);
        number_of_stations--;
        all_stations_item.badge = @"$number_of_stations";

        foreach (var genre_name in station.genres) {
            decrease_genre_badge (genre_name);
        }
    }

    private void handle_station_updated (Models.Station old_station, Models.Station new_station) {
        var old_genres = old_station.genres;
        var new_genres = new_station.genres;

        var genres_removed = remove_list_items (old_genres,new_genres);
        var genres_added = remove_list_items (new_genres,old_genres);

        foreach (var genre_name in genres_removed) {
            decrease_genre_badge (genre_name);
        }

        foreach (var genre_name in genres_added) {
            increase_genre_badge (genre_name);
        }
    }

    private ArrayList <string> remove_list_items (ArrayList <string> old_list ,ArrayList <string> new_list) {
        var not_found_entries = new ArrayList <string> ();

        foreach (var old_entry in old_list ) {
            bool found = false;
            foreach (var new_entry in new_list) {
                if (old_entry == new_entry) {
                    found = true;
                    break;
                }
            }

            if (!found)
                not_found_entries.add (old_entry);
        }
        return not_found_entries;
    }

    private void add_genre (Radio.Models.Genre genre,int stations) {
        var item = new Granite.Widgets.SourceList.Item (genre.name);
        item.badge = @"$stations";

        genre_list_item.add (item);
        genre_list_items[genre.id] = item;
    }

    private void increase_genre_badge (string genre_name) {
        var genre = App.database.get_genre_by_name (genre_name);
        var genre_item = genre_list_items[genre.id];
        var number_of_genre_entries = int.parse (genre_item.badge);
        number_of_genre_entries++;
        genre_item.badge = @"$number_of_genre_entries";
    }

    private void decrease_genre_badge (string genre_name) {
        var genre = App.database.get_genre_by_name (genre_name);
        if (genre == null)
            return;

        var genre_item = genre_list_items[genre.id];
        var number_of_genre_entries = int.parse (genre_item.badge);
        number_of_genre_entries--;
        genre_item.badge = @"$number_of_genre_entries";
    }

}
