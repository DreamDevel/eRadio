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
 */

public class Radio.ErrorDialog : Gtk.Dialog {

    private Gtk.Label text;

    public ErrorDialog () {

        this.title = "Error Occured";
        this.set_modal (true);
        this.transient_for = Radio.App.main_window;
        this.width_request = 300;
        this.height_request = 100;
        this.resizable = false;

        var content_area = this.get_content_area ();

        text = new Gtk.Label("Error Message");
        text.expand = true;

        content_area.add (text);
        this.add_buttons (_("Ok"),0);
        this.show_all ();
        this.hide();

        this.response.connect ( (id)=>{

            this.hide();
        } );
    }

    public new void show (string error_msg) {

        text.label = error_msg;
        base.show ();
    }
}