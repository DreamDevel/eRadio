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

public class Radio.Widgets.HeaderBar : Gtk.HeaderBar {

    private Gtk.ToolButton  play_button;
    private Gtk.ToolButton  previous_button;
    private Gtk.ToolButton  next_button;
    private Gtk.Box         title_box;
    private Gtk.MenuButton  application_menu;

    private Gtk.Label       playback_label;

    private string play_icon_image_name = "media-playback-start";
    private string pause_icon_image_name = "media-playback-pause";
    private string next_icon_image_name = "media-skip-forward";
    private string previous_icon_image_name = "media-skip-backward";

    public HeaderBar () {
        initialize ();
        build_interface ();
        connect_handlers_to_internal_signals ();
        connect_handlers_to_external_signals ();
    }

    private void initialize () {
        show_close_button = true;
    }

    private void build_interface () {
        create_playback_buttons ();
        create_playback_label ();
        create_application_menu ();
        append_headerbar_items ();
    }

    private void create_playback_buttons () {
        play_button = new Gtk.ToolButton (null,"");
        previous_button = new Gtk.ToolButton (null,"");
        next_button = new Gtk.ToolButton (null,"");

        play_button.set_icon_name (play_icon_image_name);
        play_button.tooltip_text = _("Play");
        next_button.set_icon_name (next_icon_image_name);
        next_button.tooltip_text = _("Next");
        previous_button.set_icon_name (previous_icon_image_name);
        previous_button.tooltip_text = _("Previous");

        // By default we disable the buttons
        play_button.set_sensitive (false);
        previous_button.set_sensitive (false);
        next_button.set_sensitive (false);
    }

    private void create_playback_label () {
        playback_label = new Gtk.Label(null);
        playback_label.ellipsize = Pango.EllipsizeMode.END;
        // TODO Do not let label wrap to more than one lines

        var level_bar = new Radio.Widgets.LevelBar ();
        level_bar.width_request = 2;
        level_bar.height_request = 15;

        var level_bar2 = new Radio.Widgets.LevelBar ();
        level_bar2.width_request = 2;
        level_bar2.height_request = 15;

        title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,6);
        title_box.pack_start (level_bar,false);
        title_box.pack_start (playback_label,false);
        title_box.pack_start (level_bar2,false);
        title_box.show_all ();
    }

    private void create_application_menu () {
        application_menu = (new Radio.Menus.ApplicationMenu ()).get_as_gtk_menu_button ();
        application_menu.tooltip_text = _("Menu");
    }

    private void append_headerbar_items () {
        pack_start (previous_button);
        pack_start (play_button);
        pack_start (next_button);
        pack_end (application_menu);
        set_custom_title (title_box);
    }

    private void connect_handlers_to_internal_signals () {
        play_button.clicked.connect (handle_play_button_clicked);
        next_button.clicked.connect (handle_next_button_clicked);
        previous_button.clicked.connect (handle_previous_button_clicked);
    }

    private void handle_play_button_clicked () {
        switch (Radio.App.player.status) {

            case PlayerStatus.PLAYING:
                Radio.App.player.stop ();
                break;

            case PlayerStatus.PAUSED:
            case PlayerStatus.STOPPED:
                App.player.play ();
                break;
            default:
                assert_not_reached ();
        }
    }

    private void handle_next_button_clicked () {
        App.player_helper.play_next_station ();
    }

    private void handle_previous_button_clicked () {
        App.player_helper.play_previous_station ();
    }

    private void connect_handlers_to_external_signals () {
        // Use ui_build_finished to connect to widgets after creation
        Radio.App.instance
        .ui_build_finished.connect ( () => {
            var liststore =  (Radio.Widgets.StationsListStore) Radio.App.widget_manager.get_widget("MainStationsListStore");

            liststore.filter_applied.connect (handle_filter_applied);
            liststore.row_deleted.connect (update_previous_next_buttons_sensivity);
            liststore.entry_added.connect (update_previous_next_buttons_sensivity);
        });
        App.player.play_status_changed.connect (handle_player_status_changed);
        App.player.playing_station_updated.connect (handle_playing_station_updated);
    }

    private void handle_filter_applied (ListStoreFilterType filter_type,string filter_argument) {
        update_previous_next_buttons_sensivity ();
    }

    private void update_previous_next_buttons_sensivity () {
        if (App.player.status != PlayerStatus.PLAYING) {
            previous_button.set_sensitive (false);
            next_button.set_sensitive (false);
            return;
        }

        var treeview =  (Radio.Widgets.StationsTreeView) Radio.App.widget_manager.get_widget("MainStationsTreeview");

        var station_id_current = App.player.station.id;
        var station_id_next = treeview.get_next_station_id (station_id_current);
        var station_id_prev = treeview.get_previous_station_id (station_id_current);

        if (station_id_next != -1)
            next_button.set_sensitive (true);
        else
            next_button.set_sensitive (false);

        if (station_id_prev != -1)
            previous_button.set_sensitive (true);
        else
            previous_button.set_sensitive (false);
    }

    private void handle_player_status_changed (PlayerStatus status) {
        switch (status) {
            case PlayerStatus.PLAYING :
                    handle_player_status_playing ();
                break;
            case PlayerStatus.PAUSED  :
                handle_player_status_paused ();
                break;
            case PlayerStatus.STOPPED :
                handle_player_status_stopped ();
                break;
            default :
                assert_not_reached ();
        }
    }

    private void handle_player_status_playing () {
        play_button.set_icon_name (pause_icon_image_name);
        play_button.tooltip_text = _("Pause");
        play_button.set_sensitive (true);

        change_title (App.player.station.name);
        title_box.visible = true;

        update_previous_next_buttons_sensivity ();
    }

    private void handle_player_status_paused () {
        play_button.set_icon_name (play_icon_image_name);
    }

    private void handle_player_status_stopped () {
        play_button.set_icon_name (play_icon_image_name);

        change_title ("");
        title_box.visible = false;
    }

    private void change_title (string new_title) {
        playback_label.set_markup ("<b>" + new_title + "</b>");
    }

    private void handle_playing_station_updated (Models.Station updated_station) {
        change_title (updated_station.name);
    }
}
