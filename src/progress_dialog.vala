/*-
 *  Copyright (c) 2014 Dream Dev Developers (https://launchpad.net/~dreamdev)
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

public class Radio.ProgressDialog : Gtk.Dialog {

    Gtk.Label       text;
    Gtk.ProgressBar progress_bar;

    public ProgressDialog (Gtk.Window parent) {

        this.set_modal (true);
        this.transient_for = parent;
        this.width_request = 300;
        this.height_request = 100;
        this.resizable = false;

        var content_area = this.get_content_area ();

        text = new Gtk.Label("");
        text.expand = true;

        progress_bar = new Gtk.ProgressBar ();
        progress_bar.margin_left = 50;
        progress_bar.margin_right = 50;

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL,0);
        box.pack_start(text);
        box.pack_start(progress_bar,false);

        content_area.add (box);
        this.show_all ();
        this.hide();
    }

    public new void show (string message) {

        text.set_markup (@"<b>$message</b>");
        this.update(0);
        base.show ();
    }

    public void update (double progress_value) {

        progress_bar.set_fraction(progress_value);
    }
}