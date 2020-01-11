/*-
 *  Copyright (c) 2016 George Sofianos
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

using Radio;

public class Radio.Widgets.DiscoverBox : Gtk.Box {

    private Gtk.Image     discover_image;
    private Gtk.Label     header;
    private Gtk.Label     subheader;
    private Gtk.Label     donateText1;
    private Gtk.Label     donateText2;
    private Gtk.Button    donate_button;

    public DiscoverBox (Gtk.Orientation orientation = Gtk.Orientation.VERTICAL, int spacing = 0) {
        Object(orientation: orientation, spacing: spacing);

        initialize ();
        build_interface ();
        connect_handlers_to_internal_signals ();
    }

    private void initialize () {
        var cssProvider = new Gtk.CssProvider();
        var css = "
        GtkLabel.header {
            font-size:28px;
        }
        GtkLabel.donate{
            color: #666;
        }";
        try {
            cssProvider.load_from_buffer(css.data);
        } catch (GLib.Error error) {
            warning ("Couldn't parse CSS data");
        }
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(),
        cssProvider,Gtk.STYLE_PROVIDER_PRIORITY_USER);

        valign = Gtk.Align.CENTER;
    }

    private void build_interface () {
        create_elements ();
        append_elements();
    }

    private void create_elements () {
        discover_image = new Gtk.Image.from_icon_name("eradio-discover", Gtk.IconSize.DIALOG);
        header = new Gtk.Label(_("Discover"));
        header.get_style_context().add_class("header");
        subheader = new Gtk.Label(_("Find new radio stations instantly"));
        subheader.margin_bottom = 40;

        donateText1 = new Gtk.Label (_("This feature is currently not implemented."));
        donateText1.get_style_context().add_class("donate");
        donateText2 = new Gtk.Label (_("Support our work to keep improving our free applications."));
        donateText2.get_style_context().add_class("donate");

        donate_button = new Gtk.Button.with_label(_("Donate"));
        donate_button.margin_top = 20;
        donate_button.halign = Gtk.Align.CENTER;
    }

    private void append_elements () {
      pack_start(discover_image,false,false,0);
      pack_start (header, false, false, 0);
      pack_start (subheader, false, false, 0);

      pack_start (donateText1, false, false, 0);
      pack_start (donateText2, false, false, 0);
      pack_start (donate_button,false,false,0);
    }

    private void connect_handlers_to_internal_signals () {
        donate_button.clicked.connect(handle_donate_clicked);
    }

    private void handle_donate_clicked () {
        try {
                Process.spawn_command_line_async("xdg-open http://eradio.dreamdevel.com/donate/");
        } catch (SpawnError e) {
                warning(e.message);
        }
    }
  }
