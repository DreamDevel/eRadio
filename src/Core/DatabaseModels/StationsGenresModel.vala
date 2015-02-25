public class Radio.Core.DatabaseModels.StationsGenresModel {
    private SQLHeavy.Database db;

    public void set_database (SQLHeavy.Database db) {
        this.db = db;
    }

    public void link (int station_id, int genre_id) throws Radio.Error{

        try {
          SQLHeavy.Query query = db.prepare ("INSERT INTO `StationsGenres` VALUES (:station_id, :genre_id);");

          query.set_int (":station_id", station_id);
          query.set_int (":genre_id", genre_id);
          query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseWrite (
              "Couldn't Insert Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    public void unlink (int station_id, int genre_id) throws Radio.Error {

        try {
            SQLHeavy.Query query = db.prepare ("DELETE FROM StationsGenres WHERE station_id = :station_id AND genre_id = :genre_id;");

            query.set_int (":station_id", station_id);
            query.set_int (":genre_id", genre_id);
            query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseWrite (
              "Couldn't Delete Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    public Gee.ArrayList<string> select_genres_by_station_id (int station_id) throws Radio.Error {
        var genres_name = new Gee.ArrayList<string> ();
        try{
            SQLHeavy.Query query = db.prepare ("""SELECT Genres.name FROM Genres,StationsGenres WHERE StationsGenres.genre_id = Genres.id
                                                AND StationsGenres.station_id = :station_id;""");
            query.set_int (":station_id",station_id);

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

    public Gee.ArrayList<Radio.Models.Station> select_stations_by_genre_id (int id) throws Radio.Error {
        var stations_list = new Gee.ArrayList<Radio.Models.Station> ();
        try {
            SQLHeavy.Query query = db.prepare ("""SELECT Stations.* FROM Stations, StationsGenres
                WHERE Stations.id = StationsGenres.station_id AND StationsGenres.genre_id = :id;""");
            query.set_int (":id",id);

            for (SQLHeavy.QueryResult results = query.execute (); !results.finished; results.next ()) {
                string station_name = results.get ("name").get_string ();
                string station_url  = results.get ("url").get_string ();
                int  station_id     = (int) results.get ("id").get_int64 ();

                var station = new Radio.Models.Station (station_id, station_name, station_url);
                stations_list.add (station);
            }
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseRead (
                  "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
        return stations_list;
    }

    public int count_entries_of_genre (int genre_id) throws Radio.Error {
        int number_of_genre_entries = 0;
        try{
            SQLHeavy.Query query = db.prepare ("SELECT COUNT(genre_id) FROM StationsGenres WHERE genre_id = :genre_id;");
            query.set_int (":genre_id",genre_id);

            SQLHeavy.QueryResult results = query.execute ();
            if (!results.finished) {
                number_of_genre_entries = results.fetch_int (0);
            }
        }
        catch (SQLHeavy.Error e){
            throw new Radio.Error.DatabaseRead (
              "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
        return number_of_genre_entries;
    }

}