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
          db.run ("""CREATE TABLE IF NOT EXISTS `Stations`(id INTEGER PRIMARY KEY, name TEXT, url TEXT);
                     CREATE TABLE IF NOT EXISTS `Genres`(id INTEGER PRIMARY KEY, name TEXT);
                     CREATE TABLE IF NOT EXISTS `StationsGenres`(station_id INTEGER, genre_id INTEGER,
                     PRIMARY KEY(station_id,genre_id));""");
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseCreate (
              "Couldn't Create Tables: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    // dimiourgeis ton radiofoniko sta8mo
    public void create_new_station (string name, Gee.ArrayList <string> genres, string url) throws Radio.Error {
        int flag = 0;

        try {
            station_model.insert (name, url);
            var station_id = station_model.select_last_id ();
            stdout.printf("Station ID: " + @"$station_id" + "\n");
            // add genres_list
                // insert genre entries
                    // insert genre - check if genre exist
                // link genres with station
            //call signal
            foreach (string genre_name in genres) {

                if (get_genre_by_name (genre_name) == null) { // (does_genre_exist)
                    genre_model.insert (genre_name);
                    //link genre with station
                    var added_genre = get_genre_by_name (genre_name);
                    stations_genres_model.link (station_id, added_genre.id);

                    this.genre_added (added_genre);
                }
                else { 
                    // Check if genre is already linked
                    var linked_genres = get_linked_genres (station_id);
                    foreach ( string genre in linked_genres){
                        if (genre == genre_name){
                            flag = 1;
                            break;
                        }
                    }

                    // Link unlinked genre
                    if (flag == 0) {
                        var genre_id   = get_genre_by_name (genre_name).id;
                        stations_genres_model.link (station_id, genre_id);
                    }
                }
            }
            this.station_added (this.get_station_by_id (station_id));
        }
        catch (Radio.Error e) {
            stderr.printf (e.message);
        }

    }

    // Stis 2 epomenes kaneis update ton sta8mo
    // #todo Needs to throw DatabaseWrite Error
    public void update_station (Radio.Models.Station station) {
        update_station_details (station.id,station.name,station.genres,station.url);
    }

    // #todo : Needs to throw DatabaseWrite Error
    // #cleancode : Too long method, create new submethods ?
    public void update_station_details (int id, string name, Gee.ArrayList<string> genres, string url) {

        int flag;

        try {
            var old_station = get_station_by_id (id);
            if ( old_station != null) {

                station_model.update (id, name, url);
                var existing_genres = get_linked_genres (id);

                foreach (string new_genre in genres) {

                    flag = 0;
                    foreach (string old_genre in existing_genres) {

                        if (new_genre == old_genre){
                            flag = 1;
                            break;
                        }
                    }

                    if (flag == 0) {
                        genre_model.insert (new_genre);
                        var added_genre = get_genre_by_name (new_genre);
                        stations_genres_model.link (id, added_genre.id);
                        this.genre_added (added_genre);

                    }
                }

                foreach (string old_genre in existing_genres) {
                    flag = 0;

                    foreach (string new_genre in genres) {
                        if (new_genre == old_genre){

                            flag = 1;
                             break;
                        }
                    }

                    if (flag == 0) {
                        var genre = get_genre_by_name (old_genre);
                        stations_genres_model.unlink (id, genre.id);
                        if (count_genre_entries_by_id (genre.id) == 0) {
                            genre_model.remove (genre.id);
                            this.genre_removed (genre);
                        }
                    }
                }

                var new_station = get_station_by_id (id);
                this.station_updated (old_station,new_station);

            }
        }
        catch (Radio.Error e) {
            stderr.printf (e.message);
        }
    }

    // Diagrafeis ton sta8mo
    // #todo : Needs to throw DatabaseWrite error
    // #cleancode : Too many nested things, Maybe create more submethods ?
    public void remove_station (int id) {
        try {
            var station = get_station_by_id (id);
            if (station != null) {

                var genres = get_linked_genres (id);

                foreach (string genre in genres) {
                    var genre_id = get_genre_by_name (genre).id;
                    stations_genres_model.unlink (id, genre_id);

                    if (count_genre_entries_by_id (genre_id) == 0) {

                        var removed_genre = this.get_genre_by_id (genre_id);
                        genre_model.remove (genre_id);
                        this.genre_removed (removed_genre);
                    }
                }
                station_model.remove (id);
                this.station_removed (station);
            }
        }
        catch (Radio.Error e) {
            stderr.printf (e.message);
        }
    }

    // #todo : Do not return NULL it's against #cleancode, prefer throwing DatabaseRead error
    public Gee.ArrayList<Radio.Models.Station>? get_all_stations () {

        var stations_list = new Gee.ArrayList<Radio.Models.Station> ();

        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Stations`;");

            for (SQLHeavy.QueryResult results = query.execute (); !results.finished; results.next ()) {

                string name = results.get ("name").get_string ();
                string url  = results.get ("url").get_string ();
                int  id     = (int) results.get ("id").get_int64 ();

                try {
                    var genres  = get_linked_genres (id);
                    var station = new Radio.Models.Station (id, name, url, genres);
                    stations_list.add (station);
                }
                catch (Radio.Error e) {
                    stderr.printf (e.message);
                    return null;
                }
            }
            return stations_list;
        }
        catch (SQLHeavy.Error e) {
            stderr.printf (e.message);
        }

        return null;
    }

    // #todo : Throw DatabaseRead error
    // #cleancode : It is not easy to understand the whole proccess, maybe submethods ?
    public Gee.ArrayList<Radio.Models.Station> get_stations_by_genre (int id) {

        var stations_list = new Gee.ArrayList<Radio.Models.Station> ();

        try {
            SQLHeavy.Query query = db.prepare ("""SELECT Stations.* FROM Stations, StationsGenres
                WHERE Stations.id = StationsGenres.station_id AND StationsGenres.genre_id = :id;""");
            query.set_int (":id",id);

            for (SQLHeavy.QueryResult results = query.execute (); !results.finished; results.next ()) {

                string station_name = results.get ("name").get_string ();
                string station_url  = results.get ("url").get_string ();
                int  station_id     = (int) results.get ("id").get_int64 ();

                try {
                    var genres  = get_linked_genres (station_id);
                    var station = new Radio.Models.Station (station_id, station_name, station_url, genres);
                    stations_list.add (station);
                }
                catch (Radio.Error e) {
                    stderr.printf (e.message);
                }
            }
        }
        catch (SQLHeavy.Error e) {
            stderr.printf (e.message);
        }
        return stations_list;
    }

    // #todo : Throw DatabaseRead error, Do not return NULL
    // #cleancode : Seems that it needs some cleaning to be more readable
    public Gee.ArrayList<Radio.Models.Genre>? get_all_genres () {

        var genres_list = new Gee.ArrayList<Radio.Models.Genre> ();

        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Genres`;");

            for (SQLHeavy.QueryResult results = query.execute (); !results.finished; results.next ()) {
                string name = results.get ("name").get_string ();
                int  id   = (int) results.get ("id").get_int64 ();

                var genre = new Radio.Models.Genre (id, name);
                genres_list.add (genre);
            }
        }
        catch (SQLHeavy.Error e) {
            stderr.printf(e.message);
        }

        if (genres_list.size == 0)
            return null;
        return genres_list;
    }

    // #todo : Do not return NULL
    public Radio.Models.Genre get_genre_by_id (int id) {
        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Genres` WHERE `id` = :id;");
            query.set_int (":id", id);

            SQLHeavy.QueryResult results = query.execute ();
            if (!results.finished) {

                string genre_name = results.get ("name").get_string ();
                int  genre_id     = (int) results.get ("id").get_int64 ();

                var genre = new Radio.Models.Genre (genre_id, genre_name);
                return genre;
            }
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseRead (
                "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
        return null;
    }

    // #todo : Throw DatabaseRead error, Do not return NULL
    public Radio.Models.Station? get_station_by_id (int id) {

        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Stations` WHERE `id` = :id;");
            query.set_int (":id", id);

            SQLHeavy.QueryResult results = query.execute ();
            if (!results.finished) {

                string station_name = results.get ("name").get_string ();
                string station_url  = results.get ("url").get_string ();

                try {
                    var genres  = get_linked_genres (id);
                    var station = new Radio.Models.Station (id, station_name, station_url, genres);
                    return station;
                }
                catch (Radio.Error e) {
                    stderr.printf (e.message);
                }
            }
        }
        catch (SQLHeavy.Error e) {
            stderr.printf (e.message);
        }
        return null;
    }

    // #todo : Throw DatabaseRead error, Do not return NULL
    public int? count_genre_entries_by_id (int id) {
        try{
            SQLHeavy.Query query = db.prepare ("SELECT COUNT(genre_id) FROM StationsGenres WHERE genre_id = :id;");
            query.set_int (":id",id);

            SQLHeavy.QueryResult results = query.execute ();
            if (!results.finished) {
                return results.fetch_int (0);
            }
        }
        catch (SQLHeavy.Error e) {
            stderr.printf (e.message);
        }
        return null;
    }

    // #todo : Throw DatabaseRead error instead of printing
    public int count_stations () {

        var num_stations = 0;
        try {
            SQLHeavy.QueryResult results = db.execute ("SELECT COUNT(id) FROM Stations");
            if (!results.finished) {
                num_stations = results.fetch_int (0);
            }
        }
        catch (SQLHeavy.Error e) {
            stderr.printf (e.message);
        }
        return num_stations;
    }

    // #todo : Throw DatabaseRead error, Do not return NULL
    private Radio.Models.Station? get_station_by_name (string name) throws Radio.Error {

        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Stations` WHERE `name` = :name;");
            query.set_string (":name", name);
            SQLHeavy.QueryResult results = query.execute ();

            if (!results.finished) {
                var station_id   = (int) results.get ("id").get_int64 ();
                var station_name = results.get ("name").get_string ();
                var station_url  = results.get ("url").get_string ();

                try {
                    var station_genres = get_linked_genres (station_id);
                    var station = new Radio.Models.Station (station_id, station_name, station_url, station_genres);
                    return station;
                }
                catch (Radio.Error e) {
                    stderr.printf (e.message);
                }
            }
        }
        catch (SQLHeavy.Error e){
            throw new Radio.Error.SQLITE_SELECT_FAILED (
              "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
        return null;
    }

    // #todo :  Do not return NULL
    public Radio.Models.Genre? get_genre_by_name (string name) throws Radio.Error {

        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Genres` WHERE `name` = :name;");
            query.set_string (":name", name);
            SQLHeavy.QueryResult results = query.execute ();

            if (!results.finished) {
                var id    = (int) results.get ("id").get_int64 ();
                var genre = new Radio.Models.Genre (id,name);
                return genre;
            }
        }
        catch (SQLHeavy.Error e){
            throw new Radio.Error.DatabaseRead (
              "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
        return null;
    }

    //return genres which are linked to given station
    private Gee.ArrayList<string> get_linked_genres (int id) throws Radio.Error {

        var genres_name = new Gee.ArrayList<string> ();

        try{
            SQLHeavy.Query query = db.prepare ("""SELECT Genres.name FROM Genres,StationsGenres WHERE StationsGenres.genre_id = Genres.id
                                                AND StationsGenres.station_id = :id;""");
            query.set_int (":id",id);

            for (SQLHeavy.QueryResult results = query.execute (); !results.finished; results.next ()) {
                genres_name.add (results.get ("name").get_string ());
            }
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseRead (
              "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }

        return genres_name;
    }

}