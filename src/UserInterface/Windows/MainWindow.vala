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
 *               Fotini Skoti <fotini.skoti@gmail.com>
 */

public class Radio.Windows.MainWindow : Gtk.Window {

    private Gtk.Box         main_box;
    public Radio.Widgets.HeaderBar headerbar;
    public Radio.Widgets.ViewStack view_stack;

    private Notify.Notification? notification;
    private Gdk.Pixbuf notify_icon;

    public MainWindow () {

        // This should not be here, maybe create a notify class
        try {
            notify_icon = new Gdk.Pixbuf.from_file(Radio.App.instance.build_pkg_data_dir + "/notify.png");
        } catch (GLib.Error error) {
            stderr.printf(error.message);
        }

        build_interface ();

        this.show_all();

    }

    private void build_interface () {
        set_window_properties ();
        create_child_widgets ();
        append_child_widgets ();
    }

    private void set_window_properties () {
        var settings = Radio.App.settings;

        this.set_title (Radio.App.instance.program_name);
        this.set_size_request (500, 250);
        this.set_default_size(settings.window_width,settings.window_height);
        this.set_application (Radio.App.instance);
        this.set_position (Gtk.WindowPosition.CENTER);
        this.icon_name = "eradio";
        this.resizable = true;
    }

    private void create_child_widgets () {
        headerbar = new Radio.Widgets.HeaderBar ();
        view_stack = new Radio.Widgets.ViewStack ();
        main_box = new Gtk.Box (Gtk.Orientation.VERTICAL,0);
    }

    private void append_child_widgets () {
        this.set_titlebar (headerbar);
        main_box.pack_start (view_stack);
        this.add(main_box);
    }

    /* --------------- Playback Actions ------------- */

    public void change_station (Radio.Models.Station station) {

        Radio.App.playing_station = station;

        this.play ();
        this.new_notification (station.name,_("Radio Station Changed"));
    }

    public void play () {

        Radio.App.playback_status = Radio.PlaybackStatus.PLAYING;
        Radio.App.player.play ();

    }

    public void pause () {

        Radio.App.playback_status = Radio.PlaybackStatus.PAUSED;
        Radio.App.player.pause ();

    }

    public void stop () {

        Radio.App.playback_status = Radio.PlaybackStatus.STOPPED;
        Radio.App.playing_station = null;
        Radio.App.player.stop ();

    }

    public void next () {

        if(Radio.App.playback_status != Radio.PlaybackStatus.STOPPED) {

        }
    }

    public void previous () {

        if(Radio.App.playback_status != Radio.PlaybackStatus.STOPPED) {

        }
    }

    public void set_volume (double volume_value,bool update_slider=false) {
        Radio.App.player.set_volume(volume_value);
        Radio.App.settings.volume = volume_value;
    }

    public void new_notification (string title, string subtitle, Gdk.Pixbuf? icon=null) {

        if (notification == null) {
            notification = new Notify.Notification (title,subtitle,null);
            if (icon != null)
                notification.set_image_from_pixbuf (icon);
            else
                notification.set_image_from_pixbuf (notify_icon);
        } else {
            notification.update (title,subtitle,null);
        }

        try {
            if (!this.is_active)
                notification.show ();
        } catch (GLib.Error e) {
            stderr.printf("Could not show notification : %s",e.message);
        }
    }




    /* ---------------- Button Singal Handlers ---------------- */


    public void play_pause_clicked () {

        if (Radio.App.player.has_url) {

            if (Radio.App.playback_status == Radio.PlaybackStatus.PLAYING)
                this.pause ();
            else
                this.play ();
        }
    }

    public void prev_clicked () {

        this.previous ();
    }

    public void next_clicked() {

        this.next ();
    }



    /* Check for window resize and save new size to settings */
    public override bool configure_event (Gdk.EventConfigure event) {

        var settings = Radio.App.settings;

        if (settings.window_width != event.width)
            settings.window_width = event.width;
        if (settings.window_height != event.height)
            settings.window_height = event.height;
        return base.configure_event (event);
    }

    // Don't close application while playing
    public override bool delete_event (Gdk.EventAny event) {
        if (App.player.status == PlayerStatus.PLAYING) {
            hide ();
            return true;
        }

        return false;
    }


}