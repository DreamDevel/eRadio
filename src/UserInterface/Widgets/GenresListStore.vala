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


public class Radio.Widgets.GenresListStore : Gtk.ListStore {

    const int GENRE_COLUMN_ID = 0;
    const string DEFAULT_GENRE_STRING = "New Genre";

    public GenresListStore () {
        set_column_types (new Type[] {
                typeof(string),  // genre
        });
    }

    public void add_genre_entry (string genre_name) {
        Gtk.TreeIter iter;
        append(out iter);

        var genre_name_trimmed = genre_name.strip ();
        set_value(iter,0,genre_name_trimmed);
    }

    public void update_genre_entry (Gtk.TreeIter iterator, string new_genre_name) {
        set_value (iterator,GENRE_COLUMN_ID,new_genre_name);
    }

    public bool does_genre_exists (string genre_name) {
        Gtk.TreeIter iterator;
        var iterator_exists = get_iter_first (out iterator);

        while (iterator_exists) {
            Value genre_value;
            get_value (iterator,GENRE_COLUMN_ID,out genre_value);
            string genre = genre_value.get_string ();

            if (genre == genre_name)
                return true;

            iterator_exists = iter_next (ref iterator);
        }

        return false;
    }

    public Gee.ArrayList<string> get_genres () {
        var genres = new Gee.ArrayList<string> ();
        Gtk.TreeIter list_iterator;
        bool next_iterator_exists = get_iter_first (out list_iterator);

        while (next_iterator_exists) {
            Value genre_value;
            get_value (list_iterator,GENRE_COLUMN_ID,out genre_value);
            var genre_name = genre_value.get_string ();

            if (genre_name != DEFAULT_GENRE_STRING)
                genres.add (genre_name);

            next_iterator_exists = iter_next (ref list_iterator);
        }

        return genres;
    }

    public void add_new_default_entry () {
        add_genre_entry (DEFAULT_GENRE_STRING);
    }

}