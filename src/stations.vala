/*-
 *  Copyright (c) 2014 George Sofianos
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
 */

public class Radio.Stations {

    private string database_path;
    private Sqlite.Database db;

    public Stations.with_db_file (string path) throws Radio.Error {
        database_path = path;
        var dbstatus = Sqlite.Database.open (database_path,out db);

        if (dbstatus != Sqlite.OK) {
            throw new Radio.Error.SQLITE_OPEN_DB_FAILED(
                "Couldn't Open Database: Error Code %d \nError Message: %s\n".printf(db.errcode (),db.errmsg ()));
        }

        // Create Stations Table if doesn't exist
        string query = "CREATE TABLE IF NOT EXISTS `Stations`( ID INTEGER PRIMARY KEY, Name TEXT, URL TEXT, Genre TEXT)";
        dbstatus = db.exec (query);

        if (dbstatus != Sqlite.OK) {
            throw new Radio.Error.SQLITE_CREATE_FAILED(
                "Couldn't Create Table: Error Code %d \nError Message: %s\n".printf(db.errcode (),db.errmsg ()));
        }

    }

    public void add (string name,string url,string genre) throws Radio.Error {

        string query = "INSERT INTO Stations VALUES(NULL,?,?,?)";

        Sqlite.Statement stmt;
        var query_status = db.prepare_v2 (query,query.length,out stmt);

        stmt.bind_text(1,name);
        stmt.bind_text(2,url);
        stmt.bind_text(3,genre);

        if (query_status != Sqlite.OK) {
            throw new Radio.Error.SQLITE_SELECT_FAILED(
                "Couldn't Insert Entry: Error Code %d \nError Message: %s\n".printf(db.errcode (),db.errmsg ()));
        }

        stmt.step ();
    }

    public void update (Radio.Station station) throws Radio.Error {
        // TODO fix genre for db v2
        /*string query = @"UPDATE Stations SET Name=? , URL=? , Genre=? WHERE ID=?";

        Sqlite.Statement stmt;
        var query_status = db.prepare_v2 (query,query.length,out stmt);

        stmt.bind_text(1,station.name);
        stmt.bind_text(2,station.url);
        stmt.bind_text(3,station.genre);
        stmt.bind_int(4,station.id);

        if (query_status != Sqlite.OK) {
            throw new Radio.Error.SQLITE_SELECT_FAILED(
                "Couldn't Update Entry: Error Code %d \nError Message: %s\n".printf(db.errcode (),db.errmsg ()));
        }

        stmt.step ();*/
    }

    public void delete (int id) throws Radio.Error {

        string query = @"DELETE FROM Stations WHERE ID=$id";

        var dbstatus = db.exec (query);

        if (dbstatus != Sqlite.OK) {
            throw new Radio.Error.SQLITE_DELETE_FAILED(
                "Couldn't Delete Entry: Error Code %d \nError Message: %s\n".printf(db.errcode (),db.errmsg ()));
        }
    }

    public Gee.ArrayList<Radio.Station> get_all (bool sort = true,bool ascending = true) throws Radio.Error {

        string query = "SELECT * FROM Stations";

        if (sort) {
            if (ascending)
                query += " ORDER BY LOWER(Name) ASC";
            else
                query += " ORDER BY LOWER(Name) DESC";
        }

        Gee.ArrayList<Radio.Station> result;
        try {
            result = select (query);
        } catch (Radio.Error e) {
            throw e;
        }

        return result;
    }

    public Gee.ArrayList<Radio.Station> get (Gee.HashMap<string,string> filters) throws Radio.Error {

        // Build query string
        string query = "SELECT * FROM Stations WHERE ";
        var filters_count = 0;
        if (filters.has_key ("id")) {
            query += "ID=" + filters["id"];
            filters_count++;
        }
        if (filters.has_key ("name")) {
            if(filters_count>0)
                query += " AND";

            query += " Name='" + filters["name"] + "'";
            filters_count++;
        }
        if (filters.has_key ("genre")) {
            if(filters_count>0)
                query += " AND";

            query += " Genre='" + filters["genre"] + "'";
            filters_count++;
        }
        if (filters.has_key ("url")) {
            if(filters_count>0)
                query += " AND";

            query += " URL='" + filters["url"] + "'";
            filters_count++;
        }

        Gee.ArrayList<Radio.Station> result;
        try {
            result = select (query);
        } catch (Radio.Error e) {
            throw e;
        }

        return result;
    }

    public int count () throws Radio.Error {

        var query = "SELECT COUNT(id) FROM Stations";

        Sqlite.Statement stmt;
        var query_status = db.prepare_v2 (query,query.length,out stmt);

        if (query_status != Sqlite.OK) {
            throw new Radio.Error.SQLITE_SELECT_FAILED(
                "Couldn't Count Entries: Error Code %d \nError Message: %s\n".printf(db.errcode (),db.errmsg ()));
        }

        stmt.step ();
        var count_str = stmt.column_text(0);
        return int.parse(count_str);
    }

    private Gee.ArrayList<Radio.Station> select (string query) throws Radio.Error {

        /*Sqlite.Statement stmt;
        var query_status = db.prepare_v2 (query,query.length,out stmt);

        if (query_status != Sqlite.OK) {
            throw new Radio.Error.SQLITE_DELETE_FAILED(
                "Couldn't Get Entry: Error Code %d \nError Message: %s\n".printf(db.errcode (),db.errmsg ()));
        }

        var stations_list = new Gee.ArrayList<Radio.Station> ();
        var columns_number = stmt.column_count ();
        int rc = 0;
        do {
            // Get next Row
            rc = stmt.step ();

            switch (rc) {
                case Sqlite.DONE:
                    break;
                case Sqlite.ROW:

                    int id = 0;
                    string name = "";
                    string url = "";
                    string genre = "";

                    // Iterate throught columns to create Station object
                    for (int col = 0; col < columns_number; col++) {

                        string col_name = stmt.column_name (col);
                        string col_value = stmt.column_text(col);
                        if ( col_name == "ID")
                            id = int.parse(col_value);
                        else if (col_name == "Name")
                            name = col_value;
                        else if (col_name == "URL")
                            url = col_value;
                        else if (col_name == "Genre")
                            genre = col_value;
                    }

                    // Add final station object to stations array
                    var station = new Radio.Station (id,name,url,genre);
                    stations_list.add(station);

                    break;
                default:
                    throw new Radio.Error.SQLITE_GENERAL(
                        "Error: %d, %s\n".printf(rc,db.errmsg()));
            }
        } while (rc == Sqlite.ROW);

        return stations_list;*/

        //temp
        return new Gee.ArrayList<Radio.Station> ();
    }
}
