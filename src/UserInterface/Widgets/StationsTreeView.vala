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


public class Radio.Widgets.StationsTreeView : Gtk.TreeView {

	private Gtk.TreeViewColumn play_icon_column;
	private Gtk.TreeViewColumn title_column;
	private Gtk.TreeViewColumn genre_column;
	private Gtk.TreeViewColumn url_column;
	private Gtk.CellRendererText cell_text_renderer;
	private Gtk.CellRendererPixbuf cell_pixbuf_renderer;
	public Radio.Widgets.StationsListStore stations_liststore;

    private Radio.Menus.StationsTreeViewContextMenu context_menu;

    public StationsTreeView () {
		initialize();
        build_interface ();
        connect_handlers_to_internal_signals ();
    }

	private void initialize () {
		Radio.App.widget_manager.add_widget(this,"MainStationsTreeview");
	}

    private void build_interface () {
    	create_liststore ();
    	create_columns ();
    	append_columns ();
        create_context_menu ();

    	set_model (stations_liststore);
    	set_rules_hint(true);
    }

    private void create_liststore () {
    	stations_liststore = new Radio.Widgets.StationsListStore ();
    }

    private void create_columns () {
    	play_icon_column = new Gtk.TreeViewColumn ();
    	title_column = new Gtk.TreeViewColumn ();
    	genre_column = new Gtk.TreeViewColumn ();
    	url_column = new Gtk.TreeViewColumn ();

        create_columns_renderers ();
    	set_columns_properties ();
    	set_columns_renderers();
    }

    private void create_columns_renderers () {
        cell_text_renderer = new Gtk.CellRendererText ();
        cell_pixbuf_renderer = new Gtk.CellRendererPixbuf ();
    }

    private void set_columns_properties () {
    	title_column.set_title (_("Station"));
    	genre_column.set_title (_("Genre"));
    	url_column.set_title (_("Url"));
    	play_icon_column.set_title (" ");

    	title_column.set_fixed_width(Radio.App.settings.title_column_width);
    	genre_column.set_fixed_width(Radio.App.settings.genre_column_width);

    	play_icon_column.set_min_width(30);
    	title_column.set_min_width (140);
    	genre_column.set_min_width (100);

    	title_column.set_sort_column_id(0);

    	play_icon_column.resizable = false;
        title_column.resizable = true;
        genre_column.resizable = true;
    }

    private void set_columns_renderers () {
    	title_column.pack_start(cell_text_renderer,false);
    	genre_column.pack_start(cell_text_renderer,false);
    	url_column.pack_start(cell_text_renderer,false);
    	play_icon_column.pack_start(cell_pixbuf_renderer,false);

    	title_column.add_attribute(cell_text_renderer,"text",0);
    	genre_column.add_attribute(cell_text_renderer,"text",1);
    	url_column.add_attribute(cell_text_renderer,"text",2);
    	play_icon_column.add_attribute(cell_pixbuf_renderer,"icon-name",4);
    }

    private void append_columns () {
    	append_column(play_icon_column);
    	append_column(title_column);
    	append_column(genre_column);
        // Disabled URL Column, maybe re-enable it by prefrences?
    	//append_column(url_column);
    }

    private void create_context_menu () {
        context_menu = new Radio.Menus.StationsTreeViewContextMenu ();
    }

    private void connect_handlers_to_internal_signals () {
        button_release_event.connect (handle_button_release);
        row_activated.connect (handle_row_activated);
        title_column.notify.connect(handle_title_column_resized);
        genre_column.notify.connect(handle_genre_column_resized);
    }

    private bool handle_button_release (Gdk.EventButton event) {
        if(event.button == 3)
            handle_right_click (event);

        return false;
    }

    private void handle_row_activated (Gtk.TreePath path, Gtk.TreeViewColumn column) {
        var station_id = stations_liststore.get_station_id_for_path (path);
        App.player_helper.play_station_with_id (station_id);
    }

    private void handle_right_click (Gdk.EventButton event) {
        var station = get_station_by_cursor_cords ((int)event.x,(int)event.y);
        if (station != null)
            open_context_menu_for_station (station);
    }

    private Radio.Models.Station? get_station_by_cursor_cords (int x, int y) {
        return try_to_get_station_by_cursor_cords (x,y);
    }

    private Radio.Models.Station? try_to_get_station_by_cursor_cords (int x, int y) {
        try {
            Gtk.TreePath path;
            Radio.Models.Station station = null;

            var row_exists = get_path_at_pos(x,y,out path,null,null,null);
            if (row_exists) {
                var station_id = stations_liststore.get_station_id_for_path (path);
                station = Radio.App.database.get_station_by_id (station_id);
            }

            return station;
        } catch (Radio.Error error) {
            warning (error.message);
            return null;
        }
    }

    private void handle_title_column_resized (GLib.ParamSpec param) {
        if (param.get_name () == "width") {
            Radio.App.settings.title_column_width = title_column.width;
        }
    }

    private void handle_genre_column_resized (GLib.ParamSpec param) {
        if (param.get_name () == "width") {
            Radio.App.settings.genre_column_width = genre_column.width;
        }
    }

    public int get_selected_station_id () {
        var selection = get_selection();
        Gtk.TreeIter? selected_iter;

         var selection_exists = selection.get_selected (null,out selected_iter);

        if (!selection_exists)
            return -1;

        var station_id = stations_liststore.get_station_id_for_iterator (selected_iter);
        return station_id;
    }

    public int get_next_station_id (int station_id) {
        var station_iter = stations_liststore.get_iterator_for_station_id (station_id);

        if (station_iter == null || !stations_liststore.iter_next(ref station_iter) )
            return -1;

        var next_station_id = stations_liststore.get_station_id_for_iterator (station_iter);
        return next_station_id;
    }

    public int get_previous_station_id (int station_id) {
        var station_iter = stations_liststore.get_iterator_for_station_id (station_id);

        if (station_iter == null || !stations_liststore.iter_previous(ref station_iter) )
            return -1;

        var prev_station_id = stations_liststore.get_station_id_for_iterator (station_iter);
        return prev_station_id;
    }

    private void open_context_menu_for_station (Radio.Models.Station station) {
        context_menu.popup_with_station (station);
    }

}
