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
 *               Fotini Skoti <fotini.skoti@gmail.com>
 */

 public class Radio.ExtractDialog : Gtk.Dialog {

    Radio.StationSelectionList list;
    private Gtk.Window parent_window;

    public ExtractDialog (Gtk.Window parent) {

        int window_width;
        int window_height;
        parent_window = parent;
        parent.get_size(out window_width,out window_height);

        list = new Radio.StationSelectionList ();

        this.set_modal (true);
        this.transient_for = parent;
        this.width_request = window_width;
        this.height_request = 300;
        this.resizable = false;

        var content_area = this.get_content_area ();

        var scroll_view = new Gtk.ScrolledWindow (null, null);
        scroll_view.expand = true;
        scroll_view.add(list);

        content_area.add(scroll_view);

        this.add_buttons (_("Cancel"),0,_("Export"),1);

        this.show_all ();
        this.hide();

        this.response.connect ( (id)=>{

            this.hide();

            if (id == 1)
                extract_selected ();
        } );

    }

    private void extract_selected () {
        var selected_stations = list.get_selected();
        if (selected_stations != null && selected_stations.size > 0) {

            // Choose Path
            var file_chooser_export = new Gtk.FileChooserDialog (_("Export Radio Stations"),
                null,Gtk.FileChooserAction.SAVE, _("Cancel"),Gtk.ResponseType.CANCEL,_("Export"),Gtk.ResponseType.ACCEPT);

            file_chooser_export.transient_for = parent_window;
            file_chooser_export.destroy_with_parent = true;
            file_chooser_export.set_current_folder (Environment.get_home_dir () + "/Documents");
            var file_filter = new Gtk.FileFilter ();
            file_filter.set_filter_name (_("eRadio Package"));
            file_filter.add_pattern ("*.erpkg");
            file_chooser_export.add_filter(file_filter);

            var response_type = file_chooser_export.run ();
            if ( response_type == Gtk.ResponseType.ACCEPT) {

                // Get path and add extension if needed
                var path = file_chooser_export.get_filename ();
                if(path.length <= 6  || path.last_index_of(".erpkg",path.length-6) == -1 )
                    path += ".erpkg";

                // Create JSON And Save
                try {
                    Radio.PackageManager.extract(selected_stations,path);
                } catch (GLib.Error error) {
                    stderr.printf(error.message);
                }
            }

            file_chooser_export.destroy ();
        }
    }

    public new void show () {

        // Update list
        this.list.clear ();
        var stations = Radio.App.database.get_all_stations ();
        this.list.add_stations (stations);

        base.show ();
    }


 }