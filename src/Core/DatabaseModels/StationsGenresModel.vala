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
}