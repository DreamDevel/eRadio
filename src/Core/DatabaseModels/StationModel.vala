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

}