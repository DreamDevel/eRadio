public class Radio.StationList : Gtk.TreeView {

	private Gtk.ListStore list_source;
	private Radio.Stations stations_db;

	public StationList () {
		this.list_source = new Gtk.ListStore (4,typeof(string),typeof(string),typeof(string),typeof(int));
		this.set_model(this.list_source);

		var cell = new Gtk.CellRendererText ();
		this.insert_column_with_attributes (-1, "Station", cell, "text", 0);
		this.insert_column_with_attributes (-1, "Genre", cell, "text", 1);
		this.insert_column_with_attributes (-1, "Url", cell, "text", 2);

		// Get Directory paths
		var home_dir = File.new_for_path (Environment.get_home_dir ());
		var radio_dir = home_dir.get_child(".local").get_child("share").get_child("radio");
		var db_file = radio_dir.get_child("stations.db");

		this.stations_db = new Radio.Stations.with_db_file (db_file.get_path());
		this.reload_list ();
	}

	// Add a station to db and then reload_list
	/*public void add (Radio.Station station) {

		this.reload_list ();
	}


	public void delete () {

		this.reload_list ();
	}

	private void build_ui () {

	}*/

	public void doIT(){
		stdout.printf("helo from list\n");
	}


	// -------------- TreeView & ListStore Methods ------------ //


	private void reload_list () {
		this.clear_list ();
		var stations = stations_db.get_all ();
		foreach (Radio.Station station in stations) {
			this.add_row (station);
		}
	}

	private void add_row (Radio.Station station) {
		Gtk.TreeIter iter;
		list_source.append(out iter);
		list_source.set_value(iter,0,station.name);
		list_source.set_value(iter,1,station.genre);
		list_source.set_value(iter,2,station.url);
		list_source.set_value(iter,3,station.id);
	}

	private void clear_list () {
		list_source.clear ();
	}

}