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


public class Radio.Views.WelcomeView : Granite.Widgets.Welcome {


    public WelcomeView () {
    	base ("eRadio",_("Add a station to begin listening"));
        build_interface ();
    }

    private void build_interface () {
    	append_welcome_entries ();
        connect_handlers_to_internal_signals ();
        show_all ();
    }

    private void append_welcome_entries () {
    	// TODO Error handling for image load
    	var add_image = new Gtk.Image.from_icon_name("document-new",Gtk.IconSize.DND);
    	var import_image = new Gtk.Image.from_icon_name("document-import",Gtk.IconSize.DND);

    	add_image.set_pixel_size(128);
    	import_image.set_pixel_size(128);

    	append_with_image (add_image,_("Add"),_("Add a new station."));
    	append_with_image (import_image,_("Import"),_("Import stations from eradio package."));
    }

    private void connect_handlers_to_internal_signals () {
        activated.connect (handle_welcome_menu_click);
    }

    private void handle_welcome_menu_click (int index) {
        if (index == 0)
            handle_add_station_click ();
        // TODO handle import stations
    }

    private void handle_add_station_click () {
        Radio.App.add_dialog.show ();
    }
}