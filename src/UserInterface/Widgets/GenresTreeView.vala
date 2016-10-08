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


public class Radio.Widgets.GenresTreeView : Gtk.TreeView {

	private Gtk.TreeViewColumn genre_column;
	private Gtk.CellRendererText cell_text_renderer;
  private Radio.Widgets.GenresListStore genres_liststore;

    public GenresTreeView () {
        build_interface ();
        connect_handlers_to_internal_signals ();
    }

    private void build_interface () {
        set_treeview_style ();
    	create_liststore ();
    	create_columns ();
    	append_columns ();

    	set_model (genres_liststore);
    }

    private void set_treeview_style () {
       set_headers_visible (false);
    }

    private void create_liststore () {
        genres_liststore = new Radio.Widgets.GenresListStore ();
    }

    private void create_columns () {
    	genre_column = new Gtk.TreeViewColumn ();

    	set_columns_properties ();
    	set_columns_renderers();
    }

    private void set_columns_properties () {
    	genre_column.set_title (_("Genre"));
    	genre_column.set_min_width (100);
    }

    private void set_columns_renderers () {
        cell_text_renderer = new Gtk.CellRendererText ();
        cell_text_renderer.set_property("editable", true);
    	genre_column.pack_start(cell_text_renderer,false);
    	genre_column.add_attribute(cell_text_renderer,"text",0);
    }

    private void append_columns () {
    	append_column(genre_column);
    }

    private void connect_handlers_to_internal_signals () {
        cell_text_renderer.edited.connect (handle_cell_editing_finished);
        genres_liststore.row_inserted.connect (handle_row_inserted);
    }

    private void handle_cell_editing_finished (string path, string new_text) {
        Gtk.TreeIter iterator;
        genres_liststore.get_iter_from_string (out iterator,path);
        var new_text_trimmed = new_text.strip ();
        var genre_exists = genres_liststore.does_genre_exists (new_text_trimmed);

        if(new_text_trimmed.length > 0 && !genre_exists)
            genres_liststore.update_genre_entry (iterator,new_text_trimmed);
    }

    private void handle_row_inserted (Gtk.TreePath path, Gtk.TreeIter iter) {
       set_cursor_on_cell (path,genre_column,cell_text_renderer,true);
    }

    public Gee.ArrayList<string> get_genres_in_array () {
        return genres_liststore.get_genres ();
    }

    public void clear_all_entries () {
        genres_liststore.clear ();
    }

    public void remove_selected_entry () {
        Gtk.TreeSelection selection_helper = get_selection ();
        Gtk.TreeIter iterator;

        var selection_exists = selection_helper.get_selected (null,out iterator);

        if (selection_exists)
            genres_liststore.remove (iterator);
    }

    public void clear_selection () {
        var selection = get_selection ();
        selection.unselect_all ();
    }

		public void add_genre (string genre_name) {
			genres_liststore.add_genre_entry(genre_name);
		}

}
