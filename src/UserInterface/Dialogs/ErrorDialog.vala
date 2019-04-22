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


public class Radio.Dialogs.ErrorDialog : Gtk.Dialog {

    private const int CLOSE_BUTTON_ID = 0;
    private const int REPORT_BUTTON_ID = 1;

    private Gtk.Box main_box;


    public ErrorDialog () {
        build_interface ();
        connect_handlers_to_internal_signals ();
    }

    public ErrorDialog.with_parent (Gtk.Window parent_window) {
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
        width_request = 300;
        resizable = false;
        window_position = Gtk.WindowPosition.CENTER;
    }

    private void add_buttons_with_style () {
        add_button (_("Close"), CLOSE_BUTTON_ID) as Gtk.Button;
        var report_button = add_button (_("Report a bug"), REPORT_BUTTON_ID) as Gtk.Button;

        report_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        set_default_response (REPORT_BUTTON_ID);
    }

    private void create_main_content () {
        main_box = new Gtk.Box (Gtk.Orientation.VERTICAL,12);

        set_dialog_margins ();
        // TODO implement inkscape mockup
        var error_message = new Gtk.Label(_("A problem occured while inserting station to database."));
        error_message.set_line_wrap (true);
        error_message.set_max_width_chars (44);

        var error_message_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL,24);
        error_message_box.width_request = 100;
        error_message_box.pack_start (new Gtk.Image.from_icon_name ("dialog-error", Gtk.IconSize.DIALOG),false);
        error_message_box.pack_start (error_message,false);

        var report_info = new Gtk.Label(_("If you believe this is a bug please report it to help us improve our software."));
        report_info.set_line_wrap (true);
        report_info.set_max_width_chars (44);
        main_box.pack_start (error_message_box,false);
        main_box.pack_start (report_info,false);

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

    private void connect_handlers_to_internal_signals () {
        response.connect(handle_dialog_buttons_click);
    }

    private void handle_dialog_buttons_click (int response_id) {

        if (response_id == CLOSE_BUTTON_ID)
            hide ();
        else
            handle_report_button_click ();
    }

    private void handle_report_button_click () {
        stdout.printf("Report a bug pressed\n");
        // TODO redirect to eRadio's bug report page
    }

    public void show_with_message (string error_message) {

    }

}