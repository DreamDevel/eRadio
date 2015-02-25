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
 *
 */


public class Radio.Widgets.ViewStack : Gtk.Stack {

	public Radio.Views.WelcomeView welcome_view;
    public Radio.Views.StationsListView stations_list_view;

    public ViewStack () {
        build_interface ();
        connect_handlers_to_external_signals ();
    }

    private void build_interface () {
    	create_views ();
    	append_views_to_stack ();
        change_view_based_on_station_count ();
    }

    private void create_views () {
    	welcome_view = new Radio.Views.WelcomeView ();
    	stations_list_view = new Radio.Views.StationsListView ();
    }

    private void append_views_to_stack () {
    	add_named (welcome_view,"welcome");
    	add_named (stations_list_view,"stations_list");
    }

    private void change_view_based_on_station_count () {
        try_to_change_view_based_on_station_count ();
    }

    private void try_to_change_view_based_on_station_count () {
        try {
            var number_of_stations = Radio.App.database.count_stations ();
            if (number_of_stations > 0)
                change_to_view_with_name ("stations_list");
            else
                change_to_view_with_name ("welcome");
        } catch (Radio.Error error) {
            warning (error.message);
            change_to_view_with_name ("welcome");
        }
    }

    private void connect_handlers_to_external_signals () {
        Radio.App.database.station_added.connect (handle_station_added);
        Radio.App.database.station_removed.connect (handle_station_removed);
    }

    private void handle_station_added () {
        change_view_based_on_station_count ();
    }

    private void handle_station_removed () {
        change_view_based_on_station_count ();
    }

    public void change_to_view_with_name (string view_name) {
    	set_visible_child_name (view_name);
    }


}