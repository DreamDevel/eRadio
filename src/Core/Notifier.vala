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
 *
 */

 public class Radio.Core.Notifier {
    private Notify.Notification? notification;

    public Notifier () {
        connect_handlers_to_external_signal ();
    }

    private void connect_handlers_to_external_signal () {
        App.player.play_status_changed.connect (handle_play_status_changed);
    }

    private void handle_play_status_changed (PlayerStatus status) {
        if (status != PlayerStatus.PLAYING)
            return;

        var playing_station = App.player.station;
        new_notification (playing_station.name,_("Radio Station Changed"));
    }

    public void new_notification (string title, string subtitle, Gdk.Pixbuf? icon=null) {
        // show only when main window is hidden
        if (App.main_window.is_active)
            return;

        if (notification == null) {
            notification = new Notify.Notification (title,subtitle,"eRadio");
        } else {
            notification.update (title,subtitle,null);
        }

        try_to_show_notification ();
    }

    private void try_to_show_notification () {
        try {
            notification.show ();
        } catch (GLib.Error e) {
            warning (e.message);
        }
    }
 }