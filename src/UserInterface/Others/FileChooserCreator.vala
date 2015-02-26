/*-
 *  Copyright (c) 2014 George Sofianos
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARadio.Models.StationRadio.Models.StationANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Authored by: George Sofianos <georgesofianosgr@gmail.com>
 *               Fotini Skoti <fotini.skoti@gmail.com>
 */

class Radio.UserInterface.FileChooserCreator {

    public static Gtk.FileChooserDialog create_import_dialog () {
        var file_chooser_import = new Gtk.FileChooserDialog (_("Import Radio Stations Package"),
            null, Gtk.FileChooserAction.OPEN,
            _("Cancel"), Gtk.ResponseType.CANCEL,
            _("Open"),Gtk.ResponseType.ACCEPT);

        file_chooser_import.transient_for = App.main_window;
        file_chooser_import.destroy_with_parent = true;
        file_chooser_import.set_current_folder (Environment.get_home_dir () + "/Documents");

        var filter = create_import_dialog_filter();
        file_chooser_import.add_filter(filter);
        return file_chooser_import;
    }

    private static Gtk.FileFilter create_import_dialog_filter () {
        var file_filter = new Gtk.FileFilter ();
        file_filter.set_filter_name (_("eRadio Package"));
        file_filter.add_pattern ("*.erpkg");
        return file_filter;
    }
}

