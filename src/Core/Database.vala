/*-
 *  Copyright (c) 2014 Dream Dev Developers (https://launchpad.net/~dreamdev)
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
 *  Authored by: Fotini Skoti <fotini.skoti@gmail.com>
 */

 public class Radio.Core.Database {

    private string database_path;
    private SQLHeavy.Database db;
    private Radio.Core.DatabaseModels.StationModel station_model;
    private Radio.Core.DatabaseModels.GenreModel genre_model;
    private Radio.Core.DatabaseModels.StationsGenresModel stations_genres_model;

    public signal void initialized ();
    public signal void genre_removed (Radio.Models.Genre genre);
    public signal void genre_added (Radio.Models.Genre genre);
    public signal void station_removed (Radio.Models.Station station);
    public signal void station_added (Radio.Models.Station station);
    public signal void station_updated (Radio.Models.Station old_station,Radio.Models.Station new_station);

    public Database () {
         station_model            = new Radio.Core.DatabaseModels.StationModel ();
         genre_model              = new Radio.Core.DatabaseModels.GenreModel ();
         stations_genres_model    = new Radio.Core.DatabaseModels.StationsGenresModel ();
    }

    public void connect_to_database_file (string path) throws Radio.Error {
        database_path = path;

        open_database ();
        pass_database_to_models ();
        create_schema ();
        initialized ();
    }

    private void open_database () throws Radio.Error {
        try {
            db = new SQLHeavy.Database (database_path);
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseCreate (
              "Couldn't Open Database: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    private void pass_database_to_models () {
        station_model.set_database (db);
        genre_model.set_database (db);
        stations_genres_model.set_database (db);
    }


    private void create_schema () throws Radio.Error {
        try {
          db.run ("""CREATE TABLE IF NOT EXISTS `Stations`(id INTEGER PRIMARY KEY, name TEXT, url TEXT, favorite INTEGER);
                     CREATE TABLE IF NOT EXISTS `Genres`(id INTEGER PRIMARY KEY, name TEXT);
                     CREATE TABLE IF NOT EXISTS `StationsGenres`(station_id INTEGER, genre_id INTEGER,
                     PRIMARY KEY(station_id,genre_id));""");
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseCreate (
              "Couldn't Create Tables: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    public void create_new_station (string name, Gee.ArrayList <string> genres, string url) throws Radio.Error {

        station_model.insert (name, url);
        var station_id = station_model.select_last_id ();

        add_not_existing_genres (genres);
        link_unlinked_genres (genres,station_id);

        this.station_added (this.get_station_by_id (station_id));
    }

    private void add_not_existing_genres (Gee.ArrayList <string> genres) throws Radio.Error {

        foreach (string genre_name in genres) {
            var genre = genre_model.select_by_name (genre_name);

            if (genre!=null)
                continue;

            genre_model.insert (genre_name);
            var added_genre = genre_model.select_by_name (genre_name);
            this.genre_added (added_genre);
        }
    }

    private void link_unlinked_genres (Gee.ArrayList <string> genres, int station_id) throws Radio.Error {
        bool genre_is_linked;

        foreach (string genre_name in genres) {
            genre_is_linked = false;
            var linked_genres = stations_genres_model.select_genres_by_station_id (station_id);

            foreach (string linked_genre in linked_genres) {
                if (genre_name == linked_genre) {
                    genre_is_linked = true;
                    break;
                }
            }
            if (!genre_is_linked) {
                var genre_id   = genre_model.select_by_name (genre_name).id;
                stations_genres_model.link (station_id, genre_id);
            }
       }
    }

    public void update_station (Radio.Models.Station station) throws Radio.Error {
        update_station_details (station.id, station.name, station.genres, station.url, station.favorite);
    }

    public void update_station_details (int id, string name, Gee.ArrayList<string> genres, string url, bool favorite) throws Radio.Error {

        var old_station = get_station_by_id (id);
        if (old_station == null)
            return;

        station_model.update (id, name, url,favorite);
        add_not_existing_genres (genres);
        link_unlinked_genres (genres, id);
        unlink_unused_linked_genres (genres, id);

        var new_station = get_station_by_id (id);
        this.station_updated (old_station,new_station);
    }

    private void unlink_unused_linked_genres (Gee.ArrayList<string> new_genres, int station_id) throws Radio.Error {

        bool genre_is_used;
        var old_linked_genres = stations_genres_model.select_genres_by_station_id (station_id);

        foreach (string old_genre in old_linked_genres) {
             genre_is_used = false;
             foreach (string new_genre in new_genres) {
                 if (old_genre == new_genre){
                    genre_is_used = true;
                    break;
                 }
             }
             if (!genre_is_used) {
                 var genre = genre_model.select_by_name (old_genre);
                 stations_genres_model.unlink (station_id, genre.id);
                 delete_genre_if_not_linked_with_any_stations (genre);
             }
         }
    }

    public void remove_station (int station_id) throws Radio.Error {

        if (!station_model.station_exists (station_id)) {
            throw new Radio.Error.DatabaseWrite (
              "Couldn't remove stations because it doesn't exist, id: $station_id");
        }
        var station = get_station_by_id (station_id);
        var station_genres = stations_genres_model.select_genres_by_station_id (station_id);

        foreach (string genre_name in station_genres) {
            var genre = genre_model.select_by_name (genre_name);
            stations_genres_model.unlink (station_id, genre.id);
            delete_genre_if_not_linked_with_any_stations (genre);
        }

        station_model.remove (station_id);
        this.station_removed (station);
    }

    private void delete_genre_if_not_linked_with_any_stations (Radio.Models.Genre genre) throws Radio.Error {
        if (stations_genres_model.count_entries_of_genre (genre.id) == 0) {
                genre_model.remove (genre.id);
                this.genre_removed (genre);
        }
    }

    public Gee.ArrayList<Radio.Models.Genre>? get_all_genres () throws Radio.Error {
        var genres_list = genre_model.select_all ();
        return genres_list;
    }

    public Gee.ArrayList<Radio.Models.Station>? get_all_stations () throws Radio.Error {
        var stations_list = station_model.select_all ();

        if (stations_list.size!=0) {
            foreach (Radio.Models.Station station in stations_list) {
                var genres  = stations_genres_model.select_genres_by_station_id (station.id);
                station.genres = genres;
            }
        }
        return stations_list;
    }

    public Gee.ArrayList<Radio.Models.Station>? get_favorite_stations () throws Radio.Error {
        var stations_list = station_model.select_favorites ();

        if (stations_list.size!=0) {
            foreach (Radio.Models.Station station in stations_list) {
                var genres  = stations_genres_model.select_genres_by_station_id (station.id);
                station.genres = genres;
            }
        }
        return stations_list;
    }

    public Gee.ArrayList<Radio.Models.Station> get_stations_by_genre_id (int id) throws Radio.Error {
        var stations_list = stations_genres_model.select_stations_by_genre_id (id);

        foreach (Radio.Models.Station station in stations_list) {
             var genres_of_station = stations_genres_model.select_genres_by_station_id (station.id);
            station.genres = genres_of_station;
        }
        return stations_list;
    }

    public Radio.Models.Station? get_station_by_id (int id) throws Radio.Error {
        var station = station_model.select_by_id (id);
        if (station!=null){
            var station_genres  = stations_genres_model.select_genres_by_station_id (id);
            station.genres = station_genres;
        }
        return station;
    }

    public Radio.Models.Station? get_station_by_name (string station_name) throws Radio.Error {
        var station = station_model.select_by_name (station_name);
        if (station!=null) {
            var station_genres = stations_genres_model.select_genres_by_station_id (station.id);
            station.genres = station_genres;
        }
        return station;
    }

    public Radio.Models.Genre? get_genre_by_name (string genre_name) throws Radio.Error {
        var genre = genre_model.select_by_name (genre_name);
        return genre;
    }

    public int count_stations () throws Radio.Error {
        var number_of_stations = station_model.count ();
        return number_of_stations;
    }

    public int count_favorite_stations () throws Radio.Error {
      var number_of_stations = station_model.count_favorite ();
      return number_of_stations;
    }

    public int count_entries_of_genre_id (int genre_id) throws Radio.Error {
        int number_of_entries = 0;
        number_of_entries = stations_genres_model.count_entries_of_genre (genre_id);
        return number_of_entries;
    }

}
