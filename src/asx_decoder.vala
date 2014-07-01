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

 public class ASXDecoder {

	public static Gee.ArrayList<string>? parse (string url) {

        //download file to string
		string file = get_file (url);
		if (file == null) {
    		stderr.printf ("Failed to download file");
    		return null;
    	}

        //lower case string
        file = file.down();

        unowned Xml.Doc doc = Xml.Parser.parse_doc (file);
        if (doc == null) {
        	stderr.printf ("Unable to open file\n");
        	return null;
        }
       
        unowned Xml.Node root = doc.get_root_element ();
        if (root == null) {
        	stdout.printf ("Wanted root\n");
        	return null;
        }

        var hrefs_list = new Gee.ArrayList<string> ();

        if (root.name == "asx") {
            for (unowned Xml.Node iter = root.children; iter != null; iter = iter.next) {
        		if (iter.type == Xml.ElementType.ELEMENT_NODE && iter.name == "entry") {
        				var parsed_hrefs = get_hrefs (iter);
        			    foreach (string href in parsed_hrefs)
        			    	hrefs_list.add(href);			
        		}
        	}
        }

        if (hrefs_list.size == 0)
    		return null;

    	return hrefs_list;
	}

    private static Gee.ArrayList<string>? get_hrefs (Xml.Node node) {

    	var hrefs = new Gee.ArrayList<string> ();

    	for (unowned Xml.Node iter = node.children; iter != null; iter = iter.next) {
    		if (iter.type == Xml.ElementType.ELEMENT_NODE && iter.name == "ref") {
    	    		hrefs.add (iter.get_prop ("href"));
    		}
    	}

    	if (hrefs == null)
    		return null;

    	return hrefs;
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