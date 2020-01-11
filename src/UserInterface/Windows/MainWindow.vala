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

    public MainWindow () {
        build_interface ();
        this.show_all();
    }

    private void build_interface () {
        set_window_properties ();
        create_child_widgets ();
        append_child_widgets ();
    }

    private void set_window_properties () {
        var saved_state = Radio.App.saved_state;

        this.set_title (Radio.App.PROGRAM_NAME);
        this.set_size_request (500, 250);
        this.set_default_size(saved_state.window_width,saved_state.window_height);
        this.set_application (Radio.App.instance);
        this.set_position (Gtk.WindowPosition.CENTER);
        this.icon_name = "eRadio";
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

    /* Check for window resize and save new size to saved_state */
    public override bool configure_event (Gdk.EventConfigure event) {

        var saved_state = Radio.App.saved_state;

        if (saved_state.window_width != event.width)
            saved_state.window_width = event.width;
        if (saved_state.window_height != event.height)
            saved_state.window_height = event.height;
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
