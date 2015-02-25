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


public class Radio.Widgets.GenresTreeViewScrollable : Gtk.ScrolledWindow {

    public Radio.Widgets.GenresTreeView treeview;

    public GenresTreeViewScrollable () {
        build_interface ();
    }

    private void build_interface () {
        add_border_style ();
        create_treeview ();
        append_treeview ();
    }

    private void add_border_style () {
        try_to_add_border_style ();
    }

    private void try_to_add_border_style () {
        try {
            // We set shadow to make css border work
            this.shadow_type = Gtk.ShadowType.ETCHED_OUT;

            var css_provider = new Gtk.CssProvider ();
            var style = "* { border: 1px solid #C3C0C0; }";
            css_provider.load_from_data (style,style.length);
            get_style_context().add_provider (css_provider,Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (GLib.Error error) {
            warning (error.message);
        }
    }

    private void create_treeview () {
        treeview = new Radio.Widgets.GenresTreeView ();
    }

    private void append_treeview () {
        add (treeview);
    }
}