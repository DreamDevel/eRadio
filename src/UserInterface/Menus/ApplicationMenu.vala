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


public class Radio.Menus.ApplicationMenu : Gtk.Menu {

    private Gtk.MenuItem add_item;
    private Gtk.MenuItem import_item;
    private Gtk.MenuItem export_item;
    private Gtk.MenuItem backup_item;
    private Gtk.MenuItem donate_item;
    private Gtk.Menu backup_submenu;

    public ApplicationMenu () {
        build_interface ();
        connect_handlers_to_internal_signals ();
    }

    private void build_interface () {
        create_menu_entries ();
        append_menu_entries ();
    }

    private void create_menu_entries () {
        backup_submenu = new Gtk.Menu ();
        add_item = new Gtk.MenuItem.with_label (_("Add New Station"));
        backup_item = new Gtk.MenuItem.with_label (_("Backup"));
        import_item = new Gtk.MenuItem.with_label (_("Import Stations"));
        export_item = new Gtk.MenuItem.with_label (_("Export Stations"));
        donate_item = new Gtk.MenuItem.with_label (_("Donate"));
    }

    private void append_menu_entries () {
        backup_submenu.append(import_item);
        backup_submenu.append(export_item);
        backup_item.set_submenu (backup_submenu);

        append (add_item);
        append (backup_item);
        append (new Gtk.SeparatorMenuItem ());
        append (donate_item);
    }

    private void connect_handlers_to_internal_signals () {
        add_item.activate.connect (handle_add_item_click);
        import_item.activate.connect (handle_import_item_click);
    }

    private void handle_add_item_click () {
        Radio.App.add_dialog.show ();
    }

    private void handle_import_item_click () {
        App.import_package ();
    }

    public Granite.Widgets.AppMenu get_as_granite_app_menu () {
        return  Radio.App.instance.create_appmenu (this);
    }
}