public class Radio.Core.DatabaseModels.StationModel {
    private SQLHeavy.Database db;

    public void set_database (SQLHeavy.Database db) {
        this.db = db;
    }

    public void insert (string name, string url) throws Radio.Error {
        try {
          SQLHeavy.Query query = db.prepare ("INSERT INTO `Stations` VALUES (null, :name, :url);");

          query.set_string (":name", name);
          query.set_string (":url", url);
          query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseWrite (
              "Couldn't Insert Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    public void update (int id, string name, string url) throws Radio.Error {

        try {
            SQLHeavy.Query query = db.prepare ("UPDATE `Stations` SET `name` = :name, `url` = :url WHERE `id` = :id;");
            query.set_string (":name", name);
            query.set_string (":url", url);
            query.set_int (":id", id);
            query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseWrite (
              "Couldn't Update Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    public void remove (int id) throws Radio.Error {

        try {
            SQLHeavy.Query query = db.prepare ("DELETE FROM `Stations` WHERE `id` = :id;");
            query.set_int (":id", id);
            query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseWrite (
              "Couldn't Delete Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    public Radio.Models.Station? select_by_name (string station_name) {
        Radio.Models.Station? station = null;
        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Stations` WHERE `name` = :station_name;");
            query.set_string (":station_name", station_name);
            SQLHeavy.QueryResult results = query.execute ();

            if (!results.finished) {
                var station_id   = (int) results.get ("id").get_int64 ();
                var station_url  = results.get ("url").get_string ();
                station = new Radio.Models.Station (station_id, station_name, station_url);
            }
        }
        catch (SQLHeavy.Error e){
            throw new Radio.Error.DatabaseRead (
              "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
        return station;
    }

    public Radio.Models.Station? select_by_id (int station_id) {
        Radio.Models.Station? station = null;
        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Stations` WHERE `id` = :station_id;");
            query.set_int (":station_id", station_id);
            SQLHeavy.QueryResult results = query.execute ();

            if (!results.finished) {
                var station_name = results.get ("name").get_string ();
                var station_url  = results.get ("url").get_string ();
                station = new Radio.Models.Station (station_id, station_name, station_url);
            }
        }
        catch (SQLHeavy.Error e){
            throw new Radio.Error.DatabaseRead (
              "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
        return station;
    }

    public Gee.ArrayList<Radio.Models.Station> select_all () {
        var stations_list = new Gee.ArrayList <Radio.Models.Station> ();
        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Stations`;");

            for (SQLHeavy.QueryResult results = query.execute (); !results.finished; results.next ()) {
                string name = results.get ("name").get_string ();
                string url  = results.get ("url").get_string ();
                int  id     = (int) results.get ("id").get_int64 ();

                var station = new Radio.Models.Station (id, name, url);
                stations_list.add (station);
            }
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseRead (
                "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
        return stations_list;
    }

    // Returns -1 in case no stations exist
    public int select_last_id () throws Radio.Error {
        try {
            int id = -1;
            SQLHeavy.QueryResult results = db.execute ("SELECT * FROM Stations ORDER BY id DESC LIMIT 1");

            if (!results.finished) {
                id =(int) results.get ("id").get_int64 ();
            }
            return id;
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseRead (
                "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    public bool station_exists (int station_id) throws Radio.Error {
        var station = select_by_id (station_id);
        if (station!=null)
            return true;
        return false;
    }

    public int count () throws Radio.Error {
        var number_of_stations = 0;
        try {
            SQLHeavy.QueryResult results = db.execute ("SELECT COUNT(id) FROM Stations");
            if (!results.finished) {
                number_of_stations = results.fetch_int (0);
            }
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseRead (
              "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
        return number_of_stations;
    }

}