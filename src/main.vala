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
 */

int main(string[] args) {
    set_log_level_by_args (ref args);
    Gtk.init (ref args);
    Gst.init (ref args);
    var app = new Radio.App ();
    app.run(args);

    return 0;
}

void set_log_level_by_args (ref unowned string[] args) {
    foreach (var arg in args) {
        if (arg == "--debug")
            Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
    }
}