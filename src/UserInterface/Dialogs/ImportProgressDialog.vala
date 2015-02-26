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


public class Radio.Dialogs.ImportProgressDialog : Radio.Dialogs.ProgressDialog {

    public ImportProgressDialog () {
        base ();
        connect_handlers_to_external_signals ();
    }

    public ImportProgressDialog.with_parent (Gtk.Window parent_window) {
        this ();
        transient_for = parent_window;
    }

    private void connect_handlers_to_external_signals () {
        App.package_manager.parse_started.connect (handle_package_parse_started);
        App.package_manager.parse_finished.connect (handle_package_parse_finished);
        App.database.station_added.connect (handle_station_added);

    }

    private void handle_package_parse_started (uint number_of_stations) {
        show_dialog (_("Importing stations, please wait."),(int)number_of_stations);
    }

    private void handle_package_parse_finished (bool success) {
        if (!success)
            hide ();
    }

    private void handle_station_added () {
        if (!active)
            return;

        update_progress (current_progress+1);

        if (current_progress == progress_max)
            hide ();
    }
}