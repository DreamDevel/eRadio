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

/* WebRadio URI Scheme 1.0
   WebRadio URIs can contain multiple parameters, in any order, separated from each other by '&'.
   The main paremeters are:
   - Name  : The station name
   - Url   : The stream url of the station
   - Genres: An array of strings seperated by comma (optional)

   The parameter format should be key=value
   Example: webradio:Url=http://stream.com/st1&Name=My Station
*/
public class Radio.Models.WebRadio : GLib.Object {

  public string   name {get;set;}
  public string   url  {get;set;}
  public string[] genres {get;set;}

  public WebRadio (string name,string url,string[] genres) {
    this.name = name;
    this.url = url;
    this.genres = genres;
  }

  public WebRadio.from_link (string link) {
    parse(link);
  }

  public void parse(string link) {
    var keyValueString = link.replace("webradio:","");
    var keyValueArray = keyValueString.split("&");
    foreach (string keyValue in keyValueArray) {
      var tempArray = keyValue.split("=");
      var key = tempArray[0];
      var value = tempArray[1];

      if (key.down() == "name")
        name = value;
      else if (key.down() == "url")
        url = value;
      else if (key.down() == "genres")
        genres = value.split(",");
    }
  }
}
