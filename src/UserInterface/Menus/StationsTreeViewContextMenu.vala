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


public class Radio.Menus.StationsTreeViewContextMenu : Gtk.Menu {

    private Gtk.MenuItem favorite_item;
    private Gtk.MenuItem edit_item;
    private Gtk.MenuItem remove_item;
    private Radio.Models.Station context_station;

    public StationsTreeViewContextMenu () {
        build_interface ();
        connect_handlers_to_internal_signals ();
        show_all ();
    }

    private void build_interface () {
        create_menu_entries ();
        append_menu_entries ();
    }

    private void create_menu_entries () {
        favorite_item = new Gtk.MenuItem.with_label(_("Add to Favorites"));
        edit_item = new Gtk.MenuItem.with_label (_("Edit station info"));
        remove_item = new Gtk.MenuItem.with_label (_("Remove from Library"));
    }

    private void append_menu_entries () {
        append(edit_item);
        append(favorite_item);
        append(remove_item);
    }

    private void connect_handlers_to_internal_signals () {
        edit_item.activate.connect (handle_edit_item_click);
        remove_item.activate.connect (handle_remove_item_click);
        favorite_item.activate.connect (handle_favorite_item_click);
    }

    private void handle_edit_item_click () {
        Radio.App.edit_dialog.show_with_station (context_station);
    }

    private void handle_remove_item_click () {
        try_to_remove_station ();
    }

    private void handle_favorite_item_click () {
      try_to_favorite_station();
    }

    private void try_to_remove_station () {
        try {
            Radio.App.database.remove_station (context_station.id);
        } catch (Radio.Error error) {
            warning (error.message);
        }
    }

    private void try_to_favorite_station () {
        try {
            var station = new Radio.Models.Station(context_station.id,
              context_station.name,context_station.url,context_station.genres,
              !context_station.favorite);
            Radio.App.database.update_station (station);
        } catch (Radio.Error error) {
            warning (error.message);
        }
    }

    public void popup_with_station (Radio.Models.Station station) {
        context_station = station;
        update_favorite_item_text(station.favorite);
        popup (null,null,null,3,Gtk.get_current_event_time ());
    }

    private void update_favorite_item_text(bool is_favorite) {
      if (is_favorite)
        favorite_item.set_label("Remove from Favorites");
      else {
        favorite_item.set_label("Add to Favorites");
      }
    }
}
