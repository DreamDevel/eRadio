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


public abstract class Radio.Dialogs.StationDialog : Gtk.Dialog {

    private const int CANCEL_BUTTON_ID = 0;
    private const int ACTION_BUTTON_ID = 1;

    private Gtk.Box main_box;
    private Gtk.Box genres_box;
    private Gtk.Box entries_box;
    public Gtk.Entry name_entry;
    public Gtk.Entry url_entry;
    public Radio.Widgets.GenresTreeViewScrollable genres_treeview;
    private Radio.Widgets.GenresTreeViewToolbar genres_treeview_toolbar;


    public StationDialog () {
        build_interface ();
        connect_handlers_to_internal_signals ();
    }

    public StationDialog.with_parent (Gtk.Window parent_window) {
        this ();
        transient_for = parent_window;
    }
    private void build_interface () {
        set_dialog_properties ();
        add_buttons_with_style ();
        create_main_content ();
    }

    private void set_dialog_properties () {

        set_modal (true);
        set_deletable (false);
        resizable = false;
        window_position = Gtk.WindowPosition.CENTER;
    }

    private void add_buttons_with_style () {
        add_button (_("Close"), CANCEL_BUTTON_ID) as Gtk.Button;
        var action_button = add_button (get_action_button_name (), ACTION_BUTTON_ID) as Gtk.Button;
        action_button.set_sensitive (false);

        action_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        set_default_response (ACTION_BUTTON_ID);
    }

    private void create_main_content () {
        main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,28);

        create_genres_box ();
        create_entries_box ();
        set_dialog_margins ();

        main_box.pack_start (genres_box);
        main_box.pack_start (entries_box);

        var content_area = get_content_area ();
        content_area.add (main_box);
        content_area.show_all ();
    }

    private void create_genres_box () {
        genres_box = new Gtk.Box (Gtk.Orientation.VERTICAL,0);

        create_genres_treeview ();
        create_genres_toolbar ();

        var genres_label = new Gtk.Label (null);
        genres_label.set_markup ("<b>" + _("Genres") + "</b>");
        genres_label.set_halign (Gtk.Align.START);
        genres_label.margin_bottom = 6;

        genres_box.pack_start (genres_label);
        genres_box.pack_start (genres_treeview);
        genres_box.pack_start (genres_treeview_toolbar);
    }

    private void create_genres_treeview () {
        genres_treeview = new Radio.Widgets.GenresTreeViewScrollable ();
        genres_treeview.width_request = 160;
        genres_treeview.height_request = 140;
    }

    private void create_genres_toolbar () {
        genres_treeview_toolbar = new Radio.Widgets.GenresTreeViewToolbar ();
        genres_treeview_toolbar.connect_treeview (genres_treeview.treeview);
    }

    private void create_entries_box () {
        entries_box = new Gtk.Box (Gtk.Orientation.VERTICAL,6);

        var name_label = new Gtk.Label(null);
        var url_label = new Gtk.Label(null);

        name_label.set_markup ("<b>" + _("Name")  + "</b>");
        url_label.set_markup ("<b>" + _("Url")  + "</b>");

        name_entry = new Gtk.Entry ();
        url_entry = new Gtk.Entry ();

        name_label.set_halign (Gtk.Align.START);
        url_label.set_halign (Gtk.Align.START);

        name_entry.margin_bottom = 6;

        entries_box.pack_start (name_label,false);
        entries_box.pack_start (name_entry,false);
        entries_box.pack_start (url_label,false);
        entries_box.pack_start (url_entry,false);
    }

    private void set_dialog_margins () {
        var content_area = get_content_area ();

        main_box.margin_bottom = 24;
        main_box.margin_left = 12;
        main_box.margin_right = 6;
        content_area.margin_right = 6;
        content_area.margin_bottom = 6;
    }

    private void connect_handlers_to_internal_signals () {
        response.connect(handle_dialog_buttons_click);

        name_entry.buffer.inserted_text.connect(handle_entries_input_action);
        url_entry.buffer.inserted_text.connect(handle_entries_input_action);

        name_entry.buffer.deleted_text.connect(handle_entries_input_action);
        url_entry.buffer.deleted_text.connect(handle_entries_input_action);
    }

    private void handle_entries_input_action () {
        var action_button = get_widget_for_response (ACTION_BUTTON_ID) as Gtk.Button;
        if (name_entry.text.length > 0 && url_entry.text.length > 0 ) {
            action_button.set_sensitive (true);
        }
        else
            action_button.set_sensitive (false);
    }

    private void handle_dialog_buttons_click (int response_id) {

        if (response_id == CANCEL_BUTTON_ID)
            hide ();
        else
            handle_action_button_click ();
    }

    protected void clear_content () {
        name_entry.text = "";
        url_entry.text = "";
        genres_treeview.treeview.clear_all_entries ();
    }

    protected abstract string get_action_button_name ();
    protected abstract void handle_action_button_click ();

}