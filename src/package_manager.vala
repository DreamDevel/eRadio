/*-
 *  Copyright (c) 2014 George Sofianos
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARadio.Models.StationRadio.Models.StationANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Authored by: George Sofianos <georgesofianosgr@gmail.com>
 *               Fotini Skoti <fotini.skoti@gmail.com>
 */

 using Gee;

 public class Radio.Core.PackageManager : GLib.Object {

    private Json.Parser parser;
    private Json.Builder builder;
    private double pkg_version {get;set;default=1.0;}

    public signal void parse_started (uint number_of_entries);
    public signal void parse_updated (uint number_of_parsed_entries);
    public signal void parse_finished (bool success);

    public signal void extract_started (uint number_of_entries);
    public signal void extract_updated (uint number_of_parsed_entries);
    public signal void extract_finished (bool success);

    public ArrayList<Radio.Models.Station> parse (string path) throws Radio.Error{

        if(parser == null)
            parser = new Json.Parser ();

        var stations_list = new ArrayList <Models.Station> ();

        try {
            parser.load_from_file (path);
        } catch (GLib.Error e) {
            stderr.printf(e.message);
            throw new Radio.Error.General ("Could not parse file");
        }

        var root = parser.get_root();
        var obj = root.get_object();

        // Check if object is valid
        if(obj.has_member ("pkg_version") && obj.has_member ("stations")) {
            /* DEBUG
            stdout.printf ("Pkg Version : %.1f\n",obj.get_double_member("pkg_version"));
            stdout.printf ("Pkg Name : %s\n\n",obj.get_string_member("pkg_name"));*/

            var stations = obj.get_array_member ("stations");
            var stations_length = stations.get_length();
            parse_started (stations_length);

            for(var i = 0; i < stations_length; i++) {

                var station_object = stations.get_object_element(i);

                var name = station_object.get_string_member ("Name");
                var genre = station_object.get_string_member ("Genre");
                var url = station_object.get_string_member ("Url");

                string[] strs = genre.split (",");
                var genres = new Gee.ArrayList<string> ();

                foreach (string str in strs) {

                    genres.add (str.strip());
                }

                var station = new Radio.Models.Station (-1,name,url,genres);

                stations_list.add (station);
                parse_updated (i+1);
                while (Gtk.events_pending())
                    Gtk.main_iteration ();
            }

        } else {
            parse_finished (false);
            throw new Radio.Error.General ("Could not parse file, package seems to be corrupted");
        }

        parse_finished (true);
        return stations_list;
    }

    public void extract (Gee.ArrayList<Radio.Models.Station> stations,string file_path) throws GLib.Error {

        extract_started (stations.size);

        if(builder == null)
            builder = new Json.Builder ();
        else
            builder.reset ();

        builder.begin_object ();
        builder.set_member_name ("pkg_version");
        builder.add_double_value (pkg_version);
        builder.set_member_name ("stations");
        builder.begin_array ();

        var counter = 0;

        foreach (Radio.Models.Station station in stations) {
            extract_updated (++counter);
            builder.begin_object ();

            string genre = "";
            var arraylist_size = station.genres.size;

            for (int i=0; i<arraylist_size; i++) {
                genre = genre + station.genres[i];
                if (i != arraylist_size - 1)
                    genre = genre + ", ";
            }

            builder.set_member_name ("Name");
            builder.add_string_value (station.name);
            builder.set_member_name ("Genre");
            builder.add_string_value (genre);
            builder.set_member_name ("Url");
            builder.add_string_value (station.url);

            builder.end_object ();
        }

        builder.end_array ();
        builder.end_object ();

        Json.Generator generator = new Json.Generator ();
        Json.Node root = builder.get_root ();
        generator.set_root (root);

        try {
            generator.to_file(file_path);
        } catch (GLib.Error error) {
            extract_finished (false);
            throw error;
        }

        extract_finished (true);
    }
 }
