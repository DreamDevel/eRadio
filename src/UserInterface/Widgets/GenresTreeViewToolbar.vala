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


public class Radio.Widgets.GenresTreeViewToolbar : Gtk.Toolbar {

    private Gtk.ToolButton add_toolbutton;
    private Gtk.ToolButton remove_toolbutton;
    Radio.Widgets.GenresTreeView treeview;

    public GenresTreeViewToolbar () {
        build_interface ();
        connect_handlers_to_internal_signals ();
    }

    private void build_interface () {
        set_toolbar_style ();
        create_toolbar_buttons ();
        append_toolbar_buttons ();
    }

    private void set_toolbar_style () {
        try_to_set_toolbar_style ();
    }

    private void try_to_set_toolbar_style () {
        try {
            icon_size = Gtk.IconSize.SMALL_TOOLBAR;
            show_arrow = false;

            var css_provider = new Gtk.CssProvider ();
            var style = "* { background-image: linear-gradient(to bottom,
                                      shade (#FFF, 0.93),
                                      shade (#FFF, 0.97)
                                      ); border: 1px solid alpha (#000, 0.22);border-top:none; }";
            css_provider.load_from_data (style,style.length);
            get_style_context().add_provider (css_provider,Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (GLib.Error error) {
            warning (error.message);
        }
    }

    private void create_toolbar_buttons () {

        // TODO error handling images
        // TODO add tooltips
        Gtk.Image add_toolbutton_image = new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        add_toolbutton = new Gtk.ToolButton (add_toolbutton_image,null);

        Gtk.Image remove_toolbutton_image = new Gtk.Image.from_icon_name ("list-remove-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        remove_toolbutton = new Gtk.ToolButton (remove_toolbutton_image,null);
    }

    private void append_toolbar_buttons () {
        add (add_toolbutton);
        add (remove_toolbutton);
    }

    private void connect_handlers_to_internal_signals () {
        add_toolbutton.clicked.connect (handle_add_genre_click);
        remove_toolbutton.clicked.connect (handle_remove_genre_click);
    }

    private void handle_add_genre_click () {
        var treeview_model = treeview.model as Radio.Widgets.GenresListStore;
        treeview_model.add_new_default_entry ();
    }

    private void handle_remove_genre_click () {
        treeview.remove_selected_entry ();
    }

    public void connect_treeview (Radio.Widgets.GenresTreeView treeview) {
        this.treeview = treeview;
    }

}