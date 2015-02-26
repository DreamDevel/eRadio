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


public class Radio.Dialogs.ProgressDialog : Gtk.Dialog {

    private Gtk.Box main_box;
    private Gtk.Label message_label;
    private Gtk.ProgressBar progress_bar;
    protected int progress_max;
    protected double current_progress = 0;
    protected bool active = false;

    public ProgressDialog () {
        build_interface ();
    }

    private void build_interface () {
        set_dialog_properties ();
        create_main_content ();
    }

    private void set_dialog_properties () {

        set_modal (true);
        set_deletable (false);
        resizable = false;
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
    }

    private void create_main_content () {
        main_box = new Gtk.Box (Gtk.Orientation.VERTICAL,12);
        main_box.width_request = 300;

        set_dialog_margins ();

        message_label = new Gtk.Label ("");
        main_box.pack_start (message_label,false);

        progress_bar = new Gtk.ProgressBar ();
        progress_bar.margin_top = 12;
        progress_bar.halign = Gtk.Align.CENTER;
        main_box.pack_start (progress_bar,false);

        var content_area = get_content_area ();
        content_area.add (main_box);
        content_area.show_all ();
    }

    private void set_dialog_margins () {
        var content_area = get_content_area ();

        main_box.margin_bottom = 24;
        main_box.margin_left = 12;
        main_box.margin_right = 6;
        content_area.margin_right = 6;
        content_area.margin_bottom = 6;
    }

    public void show_dialog (string message,int progress_max) {
        message_label.set_markup (@"<b>$message</b>");
        this.progress_max = progress_max;
        progress_bar.fraction = 0;
        current_progress = 0;
        active = true;
        base.show ();
    }

    public override void hide () {
        active = false;
        base.hide ();
    }

    public void update_progress (double progress_current) {
        current_progress = progress_current;
        progress_bar.fraction = progress_current / progress_max;
    }
}