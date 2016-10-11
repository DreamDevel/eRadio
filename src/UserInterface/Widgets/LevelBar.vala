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

 class Radio.Widgets.LevelBar : Gtk.DrawingArea {

    public double max_level = 30;
    public double current_level = 0;

    private double height_of_fill = 0;

    Gdk.RGBA bg_color;
    Gdk.RGBA fg_color;

    public LevelBar () {
        initialize();
        connect_handlers_to_internal_signals();
        connect_handlers_to_external_signals();
    }

    private void initialize () {
        bg_color = {0.86,0.86,0.86,1};
        fg_color = {0.24,0.61,0.85,1};
    }

    private void connect_handlers_to_internal_signals () {
      draw.connect (handle_draw);
    }

    private bool handle_draw (Cairo.Context cr) {
        var height = this.height_request;

        if (max_level == 0)
            return true;

        height_of_fill = ( height / max_level ) * current_level;

        create_background_rect (cr);
        create_fill_rect (cr);

        return true;
    }

    private void connect_handlers_to_external_signals () {
        App.player.rms_db_updated.connect(handle_rms_db_updated);
        App.player.play_status_changed.connect(handle_player_status_changed);
    }

    private void handle_rms_db_updated (double db_value) {
        if (max_level < db_value*100)
            max_level = db_value*100;

        current_level = db_value*100;
        queue_draw ();
    }

    private void handle_player_status_changed (PlayerStatus status) {
        if (status != PlayerStatus.PLAYING) {
            current_level = 0;
            max_level = 30;
        }
    }


    private void create_background_rect (Cairo.Context cr) {
        var width = this.get_allocated_width ();
        var height = this.height_request;

        Gdk.cairo_set_source_rgba (cr,bg_color);
        Gdk.Rectangle rect = {0,0,width,height};
        Gdk.cairo_rectangle (cr,rect);
        cr.fill ();
    }

    private void create_fill_rect (Cairo.Context cr) {
        var width = this.get_allocated_width ();
        var height = this.height_request;
        var y = height - height_of_fill;

        Gdk.cairo_set_source_rgba (cr,fg_color);
        Gdk.Rectangle rect = {0,(int)y,width,(int)height_of_fill};
        Gdk.cairo_rectangle (cr,rect);
        cr.fill ();
    }
 }
