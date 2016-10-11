/*-
 *  Copyright (c) 2015 George Sofianos
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
 *               Fotini Skoti <fotini.skoti@gmail.com>
 */

public class Radio.Core.PlayerHelper {

    public void play_station_with_id (int station_id) {
        try_to_play_station_with_id (station_id);
    }

    private void try_to_play_station_with_id (int station_id) {
        try {
            var station = Radio.App.database.get_station_by_id (station_id);
            Radio.App.player.add (station);
            Radio.App.player.play ();
        } catch (Radio.Error error) {
            warning (error.message);
        }
    }

    public void play_selected_station () {
        try_to_play_selected_station ();
    }

    private void try_to_play_selected_station () {
        try {
            var treeview =  (Radio.Widgets.StationsTreeView) Radio.App.widget_manager.get_widget("MainStationsTreeview");
            var selected_station_id = treeview.get_selected_station_id ();
            if (selected_station_id == -1) {
                warning ("Could not get selected station from treeview");
                return;
            }

            var station = Radio.App.database.get_station_by_id (selected_station_id);

            if (Radio.App.player.station == null || station.id != Radio.App.player.station.id) {
                Radio.App.player.add (station);
            }
            Radio.App.player.play ();
        } catch (Radio.Error error) {
            warning (error.message);
        }
    }

    public void play_next_station () {
        try_to_play_next_station ();
    }

    private void try_to_play_next_station () {
        try {
            if (App.player.status != PlayerStatus.PLAYING)
                return;

            var treeview =  (Radio.Widgets.StationsTreeView) Radio.App.widget_manager.get_widget("MainStationsTreeview");

            var station_id_current = App.player.station.id;
            var station_id_next = treeview.get_next_station_id (station_id_current);
            if (station_id_next == -1)
                return;

            var next_station = App.database.get_station_by_id (station_id_next);
            Radio.App.player.add (next_station);
            Radio.App.player.play ();
        } catch (Radio.Error error) {
            warning (error.message);
        }
    }

    public void play_previous_station () {
        try_to_play_previous_station ();
    }

    private void try_to_play_previous_station () {
        try {
            if (App.player.status != PlayerStatus.PLAYING)
                return;

            var treeview =  (Radio.Widgets.StationsTreeView) Radio.App.widget_manager.get_widget("MainStationsTreeview");

            var station_id_current = App.player.station.id;
            var station_id_previous = treeview.get_previous_station_id (station_id_current);
            if (station_id_previous == -1)
                return;

            var previous_station = App.database.get_station_by_id (station_id_previous);
            Radio.App.player.add (previous_station);
            Radio.App.player.play ();
        } catch (Radio.Error error) {
            warning (error.message);
        }
    }

    public void play_pause () {
        if (App.player.status == PlayerStatus.PLAYING) {
            App.player.stop ();
        } else if (App.player.station != null) {
            App.player.play ();
        }
    }
}
