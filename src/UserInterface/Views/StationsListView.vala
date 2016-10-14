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


public class Radio.Views.StationsListView : Gtk.Paned {

    public Radio.Widgets.SideBar sidebar;
    public Radio.Widgets.MainStack main_stack;

    public StationsListView () {
        initialize();
        build_interface ();
        connect_handlers_to_internal_signals();
    }
    
    private void initialize () {
        warning(Radio.App.saved_state.sidebar_width.to_string());
        position = Radio.App.saved_state.sidebar_width;
    }

    private void build_interface () {
        sidebar = new Widgets.SideBar();
    	main_stack = new Radio.Widgets.MainStack();

        add1 (sidebar);
        add2 (main_stack);
        show_all ();
    }
    
    private void connect_handlers_to_internal_signals () {
        notify.connect(handle);
    }
    
    private void handle (ParamSpec pspec) {
    
        if (pspec.get_name() == "position") {
            Radio.App.saved_state.sidebar_width = position;
        }
    }

}
