public class Radio.Core.DatabaseModels.GenreModel {
    private SQLHeavy.Database db;

    public void set_database (SQLHeavy.Database db) {
        this.db = db;
    }

    public void insert (string name) throws Radio.Error {

        try {
           SQLHeavy.Query query = db.prepare ("INSERT INTO `Genres` VALUES (null, :name);");
           query.set_string (":name", name);
           query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseWrite (
              "Couldn't Insert Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

    public void remove (int id) throws Radio.Error {
        try {
            SQLHeavy.Query query = db.prepare ("DELETE FROM `Genres` WHERE `id` = :id;");
            query.set_int (":id", id);
            query.execute ();
        }
        catch (SQLHeavy.Error e) {
            throw new Radio.Error.DatabaseWrite (
              "Couldn't Delete Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
    }

}