/*-
 *  Copyright (c) 2014 Dream Dev Developers (https://launchpad.net/~dreamdev)
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

 public class Radio.Models.Station {

    public int    id {get;set;}
    public string name {get;set;}
    public string url {get;set;}
    public Gee.ArrayList<string> genres {get;set;}

    public Station (int id, string name, string url, Gee.ArrayList<string>? genres=null) {
        this.id = id;
        this.name = name;
        this.url = url;
        this.genres = genres;
    }
}