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


public class Radio.Dialogs.EditStationDialog : Radio.Dialogs.StationDialog {

    Radio.Models.Station editing_station;

    public EditStationDialog () {
        base ();
    }

    public EditStationDialog.with_parent (Gtk.Window parent_window) {
        base.with_parent (parent_window);
    }

    protected override string get_action_button_name () {
        return _("Update Station");
    }

    protected override void handle_action_button_click () {
        try_to_update_station ();
        this.hide ();
    }

    private void try_to_update_station () {
        try {
            editing_station.name = name_entry.text.strip ();
            editing_station.url = url_entry.text.strip ();
            editing_station.genres = genres_treeview.treeview.get_genres_in_array ();

            Radio.App.database.update_station (editing_station);
        } catch (Radio.Error error) {
            warning (error.message);
        }
    }

    public void show_with_station (Radio.Models.Station station) {
        editing_station = station;

        clear_content ();

        name_entry.text = station.name;
        url_entry.text = station.url;
        var genres_liststore = genres_treeview.treeview.model as Radio.Widgets.GenresListStore;
        foreach (var genre in station.genres) {
            genres_liststore.add_genre_entry (genre);
        }

        genres_treeview.treeview.clear_selection ();
        base.show ();
    }

}
