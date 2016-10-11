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


public class Radio.Widgets.MainStack : Gtk.Stack {

	public Radio.Widgets.DiscoverBox discover_box;
    public Radio.Widgets.StationsTreeViewScrollable stations_treeview;

    public MainStack () {
		initialize();
        build_interface ();
    }

	private void initialize () {
		homogeneous = false;
	}

    private void build_interface () {
    	create_views ();
    	append_views_to_stack ();
		connect_handlers_to_external_signals ();
    }

    private void create_views () {
    	discover_box = new Radio.Widgets.DiscoverBox ();
    	stations_treeview = new Radio.Widgets.StationsTreeViewScrollable ();
    }

    private void append_views_to_stack () {
    	add_named (stations_treeview,"stations");
		add_named (discover_box,"discover");
    }

	private void connect_handlers_to_external_signals () {
		var sidebar = (Radio.Widgets.SideBar) Radio.App.widget_manager.get_widget("SideBar");
		sidebar.item_selected.connect(handle_sidebar_item_selected);
	}

	private void handle_sidebar_item_selected (Granite.Widgets.SourceList.Item? item) {
        if (!App.ui_ready) // Prevent early call - IMPORTANT
            return;

		if (item.name == "Discover") {
            change_to_view_with_name("discover");
        } else {
            change_to_view_with_name("stations");
        }
	}

    public void change_to_view_with_name (string view_name) {
    	set_visible_child_name (view_name);
    }


}
