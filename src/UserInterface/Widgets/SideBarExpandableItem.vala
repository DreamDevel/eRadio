/*-
 *  Copyright (c) 2015 George Sofianos
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


public class Radio.Widgets.SideBarExpandableItem : Granite.Widgets.SourceList.ExpandableItem,
Granite.Widgets.SourceListSortable {

    public SideBarExpandableItem (string title) {
        base (title);
    }

    public bool allow_dnd_sorting () {
        return false;
    }

    public int compare (Granite.Widgets.SourceList.Item item, Granite.Widgets.SourceList.Item item2) {
        return item.name.ascii_ncasecmp (item2.name,1);
    }
}