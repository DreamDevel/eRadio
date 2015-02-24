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
    private Gtk.ToolItem    label_toolItem;
    private Granite.Widgets.AppMenu application_menu;

    private Gtk.Label       playback_label;

    private Gtk.Image play_button_image_play;
    private Gtk.Image play_button_image_pause;

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
        var icon_size = Gtk.IconSize.LARGE_TOOLBAR;
        play_button_image_play = new Gtk.Image.from_icon_name("media-playback-start",icon_size);
        play_button_image_pause = new Gtk.Image.from_icon_name("media-playback-pause",icon_size);
        var previous_button_image = new Gtk.Image.from_icon_name("media-skip-backward",icon_size);
        var next_button_image = new Gtk.Image.from_icon_name("media-skip-forward",icon_size);
        play_button_image_pause.show ();

        play_button = new Gtk.ToolButton (play_button_image_play,"");
        previous_button = new Gtk.ToolButton (previous_button_image,"");
        next_button = new Gtk.ToolButton (next_button_image,"");

        // By default we disable the buttons
        play_button.set_sensitive (false);
        previous_button.set_sensitive (false);
        next_button.set_sensitive (false);
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

    private void append_headerbar_items () {
        pack_start (previous_button);
        pack_start (play_button);
        pack_start (next_button);
        pack_end (application_menu);
        set_custom_title (label_toolItem);
    }

    private void connect_handlers_to_internal_signals () {
        play_button.clicked.connect (handle_play_button_clicked);
    }

    private void handle_play_button_clicked () {
        switch (Radio.App.player.status) {

            case PlayerStatus.PLAYING:
                Radio.App.player.stop ();
                break;

            case PlayerStatus.PAUSED:
            case PlayerStatus.STOPPED:
                var treeview =  Radio.App
                                .main_window
                                .view_stack
                                .stations_list_view
                                .stations_treeview
                                .treeview;
                var selected_station_id = treeview.get_selected_station_id ();
                if (selected_station_id == -1) {
                    // TODO Log internal error (possible bug)
                    break;
                }

                var station = Radio.App.database.get_station_by_id (selected_station_id);
                // TODO check error


                if (Radio.App.player.station == null || station.id != Radio.App.player.station.id) {
                    Radio.App.player.add (station);
                }

                Radio.App.player.play ();
                break;
            default:
                assert_not_reached ();
        }
    }


    private void connect_handlers_to_external_signals () {
        // Get Treeview selection and connect to change
        Radio.App.instance
        .ui_build_finished.connect ( () => {
            var treeview =  Radio.App.main_window.view_stack
            .stations_list_view.stations_treeview.treeview;
            var treeview_selection = treeview.get_selection ();

            treeview_selection.changed.connect (handle_treeview_station_selected);
        });

        App.player.play_status_changed.connect (handle_player_status_changed);
        App.player.playing_station_updated.connect (handle_playing_station_updated);
    }

    private void handle_treeview_station_selected () {

        var treeview =  Radio.App
                        .main_window
                        .view_stack
                        .stations_list_view
                        .stations_treeview
                        .treeview;
        var station_id_current = treeview.get_selected_station_id ();
        var station_id_next = treeview.get_next_station_id ();
        var station_id_prev = treeview.get_previous_station_id ();

        if (station_id_current != -1 && (Radio.App.player.status == PlayerStatus.STOPPED ||
            Radio.App.player.status == PlayerStatus.PAUSED) )
            play_button.set_sensitive (true);


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
                    play_button.set_sensitive (true);
                    change_title (App.player.station.name);
                break;
            case PlayerStatus.PAUSED  :
                handle_player_status_paused ();
                break;
            case PlayerStatus.STOPPED :
                handle_player_status_stopped ();
                playback_label.set_markup ("");
                break;
            default :
                assert_not_reached ();
        }
    }

    private void handle_player_status_playing () {
        play_button.set_icon_widget (play_button_image_pause);
    }

    private void handle_player_status_paused () {
        play_button.set_icon_widget (play_button_image_play);
    }

    private void handle_player_status_stopped () {
        play_button.set_icon_widget (play_button_image_play);
    }

    private void change_title (string new_title) {
        playback_label.set_markup ("<b>" + new_title + "</b>");
    }

    private void handle_playing_station_updated (Models.Station updated_station) {
        change_title (updated_station.name);
    }
}