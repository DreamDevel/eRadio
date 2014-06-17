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

public class Radio.StationDialog : Gtk.Dialog {

    public signal void button_clicked ();

    public Gtk.Entry entry_name {get;set;}
    public Gtk.Entry entry_genre {get;set;}
    public Gtk.Entry entry_url {get;set;}

    private Gtk.Label label_name;
    private Gtk.Label label_genre;
    private Gtk.Label label_url;

    private Gtk.Button button2;
    private Gtk.Button button_cancel;


    public StationDialog (Gtk.Window parent,string button2_text) {

        this.set_modal (true);
        this.transient_for = parent;
        this.width_request = 300;
        this.height_request = 150;
        this.resizable = false;

        var content_area = this.get_content_area ();
        var action_area = this.get_action_area () as Gtk.ButtonBox;

        // Build UI
        label_name = new Gtk.Label(_("Name") + ":");
        label_genre = new Gtk.Label(_("Genre") + ":");
        label_url = new Gtk.Label(_("Url") + ":");

        entry_name = new Gtk.Entry ();
        entry_genre = new Gtk.Entry ();
        entry_url = new Gtk.Entry ();

        entry_name.placeholder_text = _("enter station name");
        entry_genre.placeholder_text = _("enter station genre");
        entry_url.placeholder_text = _("enter station url");

        entry_name.max_length = 20;
        entry_genre.max_length = 14;

        var grid = new Gtk.Grid ();
        grid.set_halign (Gtk.Align.CENTER);
        grid.column_spacing = 20;
        grid.row_spacing = 7;

        grid.attach (label_name,0,0,1,1);
        grid.attach (entry_name,1,0,1,1);
        grid.attach (label_genre,0,1,1,1);
        grid.attach (entry_genre,1,1,1,1);
        grid.attach (label_url,0,2,1,1);
        grid.attach (entry_url,1,2,1,1);

        content_area.add (grid);
        this.add_buttons (_("Cancel"),0,button2_text,1);
        this.show_all ();
        this.hide();

        var buttons = action_area.get_children();
        button_cancel = buttons.nth_data(1) as Gtk.Button;
        button2 = buttons.nth_data(0) as Gtk.Button;


        // Connect Signals
        entry_name.buffer.inserted_text.connect(this.control_button2_sensitivity);
        entry_genre.buffer.inserted_text.connect(this.control_button2_sensitivity);
        entry_url.buffer.inserted_text.connect(this.control_button2_sensitivity);

        entry_name.buffer.deleted_text.connect(this.control_button2_sensitivity);
        entry_genre.buffer.deleted_text.connect(this.control_button2_sensitivity);
        entry_url.buffer.deleted_text.connect(this.control_button2_sensitivity);


        this.response.connect ( (id)=>{
            if (id == 1)
                button_clicked ();

            this.hide();
        } );
    }

    public new void show (bool clear_prev = true) {

        if (clear_prev)
            this.clear_entries ();

        this.set_focus (button_cancel);
        this.control_button2_sensitivity;

        base.show ();
    }

    private void control_button2_sensitivity () {

        if (entry_name.text.length > 0 && entry_genre.text.length > 0 && entry_url.text.length > 0 ) {
            button2.set_sensitive (true);
        }
        else
            button2.set_sensitive (false);

    }

    private void clear_entries () {
        this.entry_name.text = "";
        this.entry_genre.text = "";
        this.entry_url.text = "";
    }
}