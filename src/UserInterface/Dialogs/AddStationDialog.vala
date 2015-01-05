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


public class Radio.Dialogs.AddStationDialog : Radio.Dialogs.StationDialog {

    public AddStationDialog () {
        base ();
    }

    public AddStationDialog.with_parent (Gtk.Window parent_window) {
        base.with_parent (parent_window);
    }

    protected override string get_action_button_name () {
        return "Add Station";
    }

    protected override void handle_action_button_click () {
        var name = name_entry.text.strip ();
        var url = url_entry.text.strip ();
        var genres = genres_treeview.treeview.get_genres_in_array ();

        Radio.App.database.create_new_station (name, genres, url);
        this.hide ();
    }

    public override void show () {
        clear_content ();
        base.show ();
    }

}