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

 public class Radio.Database {

    private string database_path;
    private SQLHeavy.Database db;

    public Database.with_db_file (string path) throws Radio.Error {

        database_path = path;

        try {
            db = new SQLHeavy.Database (database_path);
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.SQLITE_OPEN_DB_FAILED (
              "Couldn't Open Database: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }

        try {
          db.run ("""CREATE TABLE IF NOT EXISTS `Stations`(id INTEGER PRIMARY KEY, name TEXT, url TEXT);
                     CREATE TABLE IF NOT EXISTS `Genres`(id INTEGER PRIMARY KEY, name TEXT);
                     CREATE TABLE IF NOT EXISTS `StationsGenres`(station_id INTEGER, genre_id INTEGER,
                     PRIMARY KEY(station_id,genre_id));""");
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.SQLITE_CREATE_FAILED (
              "Couldn't Create Tables: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    public void new_station (string name, Gee.ArrayList <string> genres, string url) {
        int flag = 0;

        try {
            add_station (name, url);
            int? station_id = null;

            try {
                SQLHeavy.QueryResult results = db.execute ("SELECT * FROM Stations ORDER BY id DESC LIMIT 1");

                if (!results.finished){
                        station_id   = (int) results.get ("id").get_int64 ();
                }
            }
            catch (SQLHeavy.Error e) {
                throw new Radio.Error.SQLITE_SELECT_FAILED (
                    "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
            }

            if (station_id != null) {
                foreach (string genre_name in genres) {

                    if (get_genre_by_name (genre_name) == null) {
                        add_genre (genre_name);
                        var genre_id   = get_genre_by_name (genre_name).id;
                        link_genre (station_id, genre_id);
                    }
                    else {

                        var linked_genres = get_linked_genres (station_id);
                        foreach ( string genre in linked_genres){
                            if (genre == genre_name){
                                flag = 1;
                                break;
                            }
                        }

                        if (flag == 0) {
                            var genre_id   = get_genre_by_name (genre_name).id;
                            link_genre (station_id, genre_id);
                        }
                    }
                }
            }
        }
        catch (Radio.Error e) {
            stderr.printf (e.message);
        }

    }

    public void update_station_details (int id, string name, Gee.ArrayList<string> genres, string url) {

        int flag;

        try {
            if (get_station_by_id (id) != null) {

                update_station (id, name, url);
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
                        add_genre (new_genre);
                        link_genre (id, get_genre_by_name (new_genre).id);
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
                        unlink_genre (id, genre.id);
                        if (count_genre_entries_by_id (genre.id) == 0)
                            delete_genre (genre.id);
                    }
                }
            }
        }
        catch (Radio.Error e) {
            stderr.printf (e.message);
        }
    }

    public void remove_station (int id) {
        try {
            if (get_station_by_id (id) != null) {

                var genres = get_linked_genres (id);

                foreach (string genre in genres) {
                    var genre_id = get_genre_by_name (genre).id;
                    unlink_genre (id, genre_id);

                    if (count_genre_entries_by_id (genre_id) == 0)
                        delete_genre (genre_id);
                }
                delete_station (id);
            }
        }
        catch (Radio.Error e) {
            stderr.printf (e.message);
        }
    }

    public Gee.ArrayList<Radio.Station>? get_all_stations () {

        var stations_list = new Gee.ArrayList<Radio.Station> ();

        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Stations`;");

            for (SQLHeavy.QueryResult results = query.execute (); !results.finished; results.next ()) {

                string name = results.get ("name").get_string ();
                string url  = results.get ("url").get_string ();
                int  id     = (int) results.get ("id").get_int64 ();

                try {
                    var genres  = get_linked_genres (id);
                    var station = new Radio.Station (id, name, url, genres);
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

    public Gee.ArrayList<Radio.Station> get_stations_by_genre (int id) {

        var stations_list = new Gee.ArrayList<Radio.Station> ();

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
                    var station = new Radio.Station (station_id, station_name, station_url, genres);
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

    public Gee.ArrayList<Radio.Genre>? get_all_genres () {

        var genres_list = new Gee.ArrayList<Radio.Genre> ();

        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Genres`;");

            for (SQLHeavy.QueryResult results = query.execute (); !results.finished; results.next ()) {
                string name = results.get ("name").get_string ();
                int  id   = (int) results.get ("id").get_int64 ();

                var genre = new Radio.Genre (id, name);
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

    public Radio.Genre? get_genre_by_id (int id) {

        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Genres` WHERE `id` = :id;");
            query.set_int (":id", id);

            SQLHeavy.QueryResult results = query.execute ();
            if (!results.finished) {

                string genre_name = results.get ("name").get_string ();
                int  genre_id     = (int) results.get ("id").get_int64 ();

                var genre = new Radio.Genre (genre_id, genre_name);
                return genre;
            }
        }
        catch (SQLHeavy.Error e) {
            stderr.printf (e.message);
        }
        return null;
    }

    public Radio.Station? get_station_by_id (int id) {

        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Stations` WHERE `id` = :id;");
            query.set_int (":id", id);

            SQLHeavy.QueryResult results = query.execute ();
            if (!results.finished) {

                string station_name = results.get ("name").get_string ();
                string station_url  = results.get ("url").get_string ();

                try {
                    var genres  = get_linked_genres (id);
                    var station = new Radio.Station (id, station_name, station_url, genres);
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

    private Radio.Station? get_station_by_name (string name) throws Radio.Error {

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
                    var station = new Radio.Station (station_id, station_name, station_url, station_genres);
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

    private Radio.Genre? get_genre_by_name (string name) throws Radio.Error {

        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Genres` WHERE `name` = :name;");
            query.set_string (":name", name);
            SQLHeavy.QueryResult results = query.execute ();

            if (!results.finished) {
                var id    = (int) results.get ("id").get_int64 ();
                var genre = new Radio.Genre (id,name);
                return genre;
            }
        }
        catch (SQLHeavy.Error e){
            throw new Radio.Error.SQLITE_SELECT_FAILED (
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
            throw new Radio.Error.SQLITE_SELECT_FAILED (
              "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }

        return genres_name;
    }

    private void add_station (string name, string url) throws Radio.Error {

        try {
          SQLHeavy.Query query = db.prepare ("INSERT INTO `Stations` VALUES (null, :name, :url);");

          query.set_string (":name", name);
          query.set_string (":url", url);
          query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.SQLITE_INSERT_FAILED (
              "Couldn't Insert Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    private void add_genre (string name) throws Radio.Error {

        try {
           SQLHeavy.Query query = db.prepare ("INSERT INTO `Genres` VALUES (null, :name);");
           query.set_string (":name", name);
           query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.SQLITE_INSERT_FAILED (
              "Couldn't Insert Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    private void link_genre (int station_id, int genre_id) throws Radio.Error{

        try {
          SQLHeavy.Query query = db.prepare ("INSERT INTO `StationsGenres` VALUES (:station_id, :genre_id);");

          query.set_int (":station_id", station_id);
          query.set_int (":genre_id", genre_id);
          query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.SQLITE_INSERT_FAILED (
              "Couldn't Insert Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    private void unlink_genre (int station_id, int genre_id) throws Radio.Error {

        try {
            SQLHeavy.Query query = db.prepare ("DELETE FROM StationsGenres WHERE station_id = :station_id AND genre_id = :genre_id;");

            query.set_int (":station_id", station_id);
            query.set_int (":genre_id", genre_id);
            query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.SQLITE_DELETE_FAILED (
              "Couldn't Delete Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    private void update_station (int id, string name, string url) throws Radio.Error {

        try {
            SQLHeavy.Query query = db.prepare ("UPDATE `Stations` SET `name` = :name, `url` = :url WHERE `id` = :id;");
            query.set_string (":name", name);
            query.set_string (":url", url);
            query.set_int (":id", id);
            query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.SQLITE_UPDATE_FAILED (
              "Couldn't Update Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    private void delete_station (int id) throws Radio.Error {

        try {
            SQLHeavy.Query query = db.prepare ("DELETE FROM `Stations` WHERE `id` = :id;");
            query.set_int (":id", id);
            query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.SQLITE_DELETE_FAILED (
              "Couldn't Delete Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    private void delete_genre (int id) throws Radio.Error {

        try {
            SQLHeavy.Query query = db.prepare ("DELETE FROM `Genres` WHERE `id` = :id;");
            query.set_int (":id", id);
            query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.SQLITE_DELETE_FAILED (
              "Couldn't Delete Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }
}