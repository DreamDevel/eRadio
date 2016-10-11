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

// Keeps track of widgets to quickly get an instance
// Note* Be careful of the orded widgets added and requested
public class Radio.Core.WidgetManager {

    private Gee.HashMap<string,Object> widgets;

    public WidgetManager () {
        widgets = new Gee.HashMap<string,Object> ();
    }

    public void add_widget(Object widget, string name) {
        widgets[name] = widget;
    }

    public Object get_widget(string name) {
        return widgets[name];
    }
}
