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

    public Radio.Models.Genre? select_by_id (int id) throws Radio.Error {
        Radio.Models.Genre? genre = null;
        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Genres` WHERE `id` = :id;");
            query.set_int (":id", id);
            SQLHeavy.QueryResult results = query.execute ();

            if (!results.finished) {
                var name    = results.get ("name").get_string ();
                genre = new Radio.Models.Genre (id,name);           
            }
        }
        catch (SQLHeavy.Error e){
            throw new Radio.Error.DatabaseRead (
              "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
        return genre;
    }

    public Radio.Models.Genre? select_by_name (string name) throws Radio.Error {
        Radio.Models.Genre? genre = null;
        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Genres` WHERE `name` = :name;");
            query.set_string (":name", name);
            SQLHeavy.QueryResult results = query.execute ();

            if (!results.finished) {
                var id    = (int) results.get ("id").get_int64 ();
                genre = new Radio.Models.Genre (id,name);           
            }
        }
        catch (SQLHeavy.Error e){
            throw new Radio.Error.DatabaseRead (
              "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
        return genre;
    }

    public Gee.ArrayList<Radio.Models.Genre>? select_all () throws Radio.Error {
        var genres_list = new Gee.ArrayList <Radio.Models.Genre> ();
        try {
            SQLHeavy.Query query = db.prepare ("SELECT * FROM `Genres`;");

            for (SQLHeavy.QueryResult results = query.execute (); !results.finished; results.next ()) {
                string name = results.get ("name").get_string ();
                int  id     = (int) results.get ("id").get_int64 ();
                var genre = new Radio.Models.Genre (id, name);
                genres_list.add (genre);
            }
        }
        catch (SQLHeavy.Error e) {
             throw new Radio.Error.DatabaseRead (
              "Couldn't Select Entry: Error Code %d \nError Message: %s\n".printf (e.code,e.message));
        }
        return genres_list;
    }

}