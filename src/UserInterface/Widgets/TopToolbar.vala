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

using Radio;

public class Radio.Widgets.TopToolbar : Gtk.Toolbar {

    private Gtk.ToolButton  play_button;
    private Gtk.ToolButton  previous_button;
    private Gtk.ToolButton  next_button;
    private Gtk.ToolItem    volume_toolItem;
    private Gtk.ToolItem    label_toolItem;
    private Granite.Widgets.AppMenu application_menu;

    private Gtk.Label       playback_label;
    private Gtk.Scale       volume_scale;

    public TopToolbar () {
        build_interface ();
    }

    private void build_interface () {
        create_playback_buttons ();
        create_volume_slider ();
        create_playback_label ();
        create_application_menu ();
        append_toolbar_items ();
    }

    private void create_playback_buttons () {
        var icon_size = Gtk.IconSize.LARGE_TOOLBAR;
        var play_button_image = new Gtk.Image.from_icon_name("media-playback-start",icon_size);
        var previous_button_image = new Gtk.Image.from_icon_name("media-skip-backward",icon_size);
        var next_button_image = new Gtk.Image.from_icon_name("media-skip-forward",icon_size);

        this.play_button = new Gtk.ToolButton (play_button_image,"");
        this.previous_button = new Gtk.ToolButton (previous_button_image,"");
        this.next_button = new Gtk.ToolButton (next_button_image,"");

        // By default we disable the buttons
        play_button.set_sensitive (false);
        previous_button.set_sensitive (false);
        next_button.set_sensitive (false);
    }

    private void create_volume_slider () {
        volume_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 1, 0.01);
        volume_scale.width_request = 100;
        volume_scale.draw_value = false;

        volume_toolItem = new Gtk.ToolItem ();
        volume_toolItem.add (volume_scale);
        volume_toolItem.margin_left = 12;
        volume_toolItem.margin_right = 12;

        // TODO put it in other method ? Posibility to need try/catch because of the settings
        volume_scale.set_value(Radio.App.settings.volume);
    }

    private void create_playback_label () {
        playback_label = new Gtk.Label(null);
        playback_label.ellipsize = Pango.EllipsizeMode.END;
        // TODO Do not let label wrap to more than one lines

        label_toolItem = new Gtk.ToolItem ();
        label_toolItem.set_expand (true);
        label_toolItem.add (playback_label);
    }

    private void create_application_menu () {
        application_menu = (new Radio.Menus.ApplicationMenu ()).get_as_granite_app_menu ();
    }

    private void append_toolbar_items () {
        add (previous_button);
        add (play_button);
        add (next_button);
        add (volume_toolItem);
        add (label_toolItem);
        add (application_menu);
    }
}