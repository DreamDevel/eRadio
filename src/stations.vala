using Sqlite;
using Gee;
extern void exit(int exit_code);


namespace Radio {
	
	public class Stations {

		public Stations.with_db_file(string path) {
			database_path = path;
			var dbstatus = Database.open(database_path,out db);

			if(dbstatus != Sqlite.OK) {
				stderr.printf("Couldn't Open Database: Error Code %d \nError Message: %s\n",db.errcode(),db.errmsg());
				exit(-1);
			}

			// Create Stations Table if doesn't exist
			string query = """CREATE TABLE IF NOT EXISTS `Stations`(
				ID INTEGER PRIMARY KEY,
				Name TEXT,
				URL TEXT,
				Genre TEXT)
			""";
			dbstatus = db.exec(query);

			if(dbstatus != Sqlite.OK) {
				stderr.printf("Couldn't Create Table: Error Code %d \nError Message: %s\n",db.errcode(),db.errmsg());
				exit(-1);
			}

		}

		public void add(string name,string url,string genre) {

			string query = @"INSERT INTO Stations VALUES(NULL,'$name','$url','$genre')";
		
			var dbstatus = db.exec(query);

			if(dbstatus != Sqlite.OK) {
				stderr.printf("Couldn't Insert Entry: Error Code %d \nError Message: %s\n",db.errcode(),db.errmsg());
				exit(-1);
			}
		}

		public ArrayList<Radio.Station> get_all() {

			string query = "SELECT * FROM Stations";
			return select(query);
		}

		public ArrayList<Radio.Station> get(HashMap<string,string> filters) {


			string query = "SELECT * FROM Stations WHERE ";
			var filters_count = 0;
			if(filters.has_key("id")){
				query += "ID=" + filters["id"];
				filters_count++;
			}
			if(filters.has_key("name")) {
				if(filters_count>0)
					query += " AND";
				query += " Name='" + filters["name"] + "'";
				filters_count++;
			}
			if(filters.has_key("genre")) {
				if(filters_count>0)
					query += " AND";
				query += " Genre='" + filters["genre"] + "'";
				filters_count++;
			}
			if(filters.has_key("url")) {
				if(filters_count>0)
					query += " AND";
				query += " URL='" + filters["url"] + "'";
				filters_count++;
			}


			return select(query);
		}

		public void delete(int id) {
			
			string query = @"DELETE FROM Stations WHERE ID=$id";

			var dbstatus = db.exec(query);

			if(dbstatus != Sqlite.OK) {
				stderr.printf("Couldn't Delete Entry: Error Code %d \nError Message: %s\n",db.errcode(),db.errmsg());
				exit(-1);
			}
		}

		private ArrayList<Radio.Station> select(string query){

			Sqlite.Statement stmt;


			var query_status = db.prepare_v2(query,query.length,out stmt);

			if(query_status != Sqlite.OK) {
				stderr.printf("Couldn't Get Entry: Error Code %d \nError Message: %s\n",db.errcode(),db.errmsg());
				exit(-1);
			}

			var stations_list = new ArrayList<Radio.Station> ();
			var columns_number = stmt.column_count();
			int rc = 0;
			do {
				// Get next Row
				rc = stmt.step();

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
					        if( col_name == "ID")
					        	id = int.parse(col_value);
					        else if(col_name == "Name")
					        	name = col_value;
					        else if(col_name == "URL")
					        	url = col_value;
					        else if(col_name == "Genre")
					        	genre = col_value;

					        // Debug
					        //print ("%s = %s\n", stmt.column_name (col), col_value);
					    }

					    // Add final station object to stations array
					    var station = new Radio.Station(id,name,url,genre);
					    stations_list.add(station);

					    break;
					default:
					    printerr ("Error: %d, %s\n", rc, db.errmsg ());
					    break;
				}
			} while (rc == Sqlite.ROW);

			return stations_list;
		}

		private string database_path = "";
		private Database db;
	}
}