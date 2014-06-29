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
 *  Authored by: Fotini Skoti <fotini.skoti@gmail.com>
 *
 */

public class M3UDecoder {

    public static Gee.ArrayList<string>? parse (string url) {

       string data = get_file (url);

       if (data == null){
          stderr.printf ("Failed to download m3u file\n");
          return null;
       }

       var myList = new Gee.ArrayList<string> ();
       string[] lines = data.split ("\n"); 

       foreach (unowned string str in lines) {
          if (str[0] != '#')
            myList.add(str);
       }  

        if (myList.size == 0)
            return null;

        return myList;
    }

    private static string? get_file (string url) {

      Soup.SessionSync session = new Soup.SessionSync ();
      Soup.Message msg = new Soup.Message ("GET", url);
      session.send_message (msg);

      var data = (string) msg.response_body.data;

      if (msg.status_code == 200)
        return data;
      else
        return null;    
    }

}
