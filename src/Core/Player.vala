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
 *               Fotini Skoti <fotini.skoti@gmail.com>
 */

using Gst;

public class Radio.Core.Player : GLib.Object {

    private Gst.Pipeline pipeline;
    private Gst.Element  source;
    private Gst.Element  converter;
    private Gst.Element  level;
    private Gst.Element  sink;
    private Gst.Bus bus;

    public bool has_url {get;set;}
    public PlayerStatus status;
    public Models.Station? station;

    public signal void volume_changed (double volume_value);
    public signal void play_status_changed(PlayerStatus status);
    public signal void playback_error(GLib.Error error);
    public signal void playing_station_updated (Models.Station updated_station);
    public signal void rms_db_updated (double db_value);

    public Player () {
        status = PlayerStatus.STOPPED;

        // Create GStreamer Elements
        create_gstreamer_elements ();
        link_gstreamer_elements ();


        // Connect internal signals
        connect_handlers_to_internal_signals ();
        connect_handlers_to_external_signals ();
    }

    private void create_gstreamer_elements () {
        pipeline  = new Gst.Pipeline ("main-pipeline");
        source    = Gst.ElementFactory.make ("uridecodebin","source");
        converter = Gst.ElementFactory.make ("audioconvert","converter");
        level     = Gst.ElementFactory.make ("level","level");
        sink      = Gst.ElementFactory.make ("autoaudiosink","sink");
        bus       = pipeline.get_bus();
    }

    private void link_gstreamer_elements () {
        pipeline.add_many (source,converter,level,sink);

        if (!converter.link (level) || !level.link(sink))
            error ("Couldn't link gstreamer elements");
    }

    private void connect_handlers_to_internal_signals () {
        source.pad_added.connect (handle_url_decoded);
        bus.add_watch (Priority.DEFAULT,handle_bus_has_message);
    }

    private void handle_url_decoded (Gst.Element element, Gst.Pad pad) {
        var struct_string = pad.get_current_caps ().to_string ();

        if (struct_string.has_prefix ("audio"))
            pad.link (converter.get_static_pad ("sink"));
        else
            warning ("Stream is not an audio");
    }

    private bool handle_bus_has_message (Gst.Bus bus, Gst.Message message) {
        switch(message.type) {
          case Gst.MessageType.ELEMENT:
              if (message.has_name ("level")) {
                   unowned Gst.Structure message_structure = message.get_structure ();
                   GLib.Value? rms_array_value = message_structure.get_value ("rms");
                   unowned GLib.ValueArray rms_array = (GLib.ValueArray) rms_array_value.get_boxed ();
                   var channels = rms_array.n_values;
                   double total_rms = 0;
                   foreach (GLib.Value rms in rms_array.values) {
                       total_rms += rms.get_double ();
                   }
                   double average_rms = total_rms / channels;
                   double final_rms = GLib.Math.pow (10,average_rms/20);
                   rms_db_updated (final_rms);
               }
               break;
            case Gst.MessageType.ERROR:
                GLib.Error error;
                string debug;
                message.parse_error(out error,out debug);

                if(error.message != "Cancelled") {
                    warning(error.message);
                    pipeline.set_state(State.NULL);
                    playback_error(error);
                    this.has_url = false;
                    stop();
                }

                break;

            case Gst.MessageType.EOS:
                debug("End Of Stream Reached");
                pipeline.set_state(State.NULL);
                break;
        }
        return true;
    }

    private void connect_handlers_to_external_signals () {
        // Make sure database instance exists
        App.instance.ui_build_finished.connect (()=>{
            Radio.App.database.station_updated.connect (handle_station_updated);
            Radio.App.database.station_removed.connect (handle_station_removed);
        });
    }

    private void handle_station_updated (Models.Station old_station, Models.Station new_station) {
        if (status != PlayerStatus.PLAYING || station.id != new_station.id)
            return;

        if (old_station.url != new_station.url) {
            stop ();
        } else {
            station = new_station;
            playing_station_updated (new_station);
        }
    }

    private void handle_station_removed (Models.Station removed_station) {
        if (station.id == removed_station.id)
            stop ();
    }

    public void add (Radio.Models.Station station) throws Radio.Error {

        if (status == PlayerStatus.PLAYING)
            stop ();

        string uri = station.url;
        string final_uri = station.url;
        string content_type = "";

        this.station = station;

        if (final_uri.has_prefix ("http")){
            content_type = this.get_content_type (uri);
        }

        // Check content type to decode
        if ( content_type == "audio/x-mpegurl" || content_type == "audio/mpegurl" ) {
            var list = M3UDecoder.parse (uri);
            // Temporary ignoring all links beside the first
            if ( list != null )
                final_uri = list[0];
            else
                throw new Radio.Error.General ("Could not decode m3u file, wrong url or corrupted file");
        }
        else if ( content_type == "text/html" && final_uri.has_suffix (".m3u")) {
            var list = M3UDecoder.parse (uri);
            // Temporary ignoring all links beside the first
            if ( list != null )
                final_uri = list[0];
            else
                throw new Radio.Error.General ("Could not decode m3u file, wrong url or corrupted file");
        }
        else if ( content_type == "audio/x-scpls" || content_type == "application/pls+xml") {
            var list = PLSDecoder.parse (uri);
            // Temporary ignoring all links beside the first
            if ( list != null )
                final_uri = list[0];
            else
                throw new Radio.Error.General ("Could not decode pls file, wrong url or corrupted file");

        }
        else if ( content_type == "video/x-ms-wmv" || content_type == "video/x-ms-wvx" || content_type == "video/x-ms-asf" || content_type == "video/x-ms-asx" || content_type == "audio/x-ms-wax" || uri.last_index_of (".asx",uri.length - 4) != -1) {
            var list = ASXDecoder.parse (uri);
            // Temporary ignoring all links beside the first
            if ( list != null )
                final_uri = list[0];
            else
                throw new Radio.Error.General ("Could not decode asx file, wrong url or corrupted file");
        }

        this.has_url = true;

        pipeline.set_state (State.READY);
        source.set ("uri",final_uri);
        debug (@"Station added: $(station.name)");
    }
    
    private string? get_content_type (string url) {

        var session = new Soup.Session();
        session.timeout = 2;
        var msg = new Soup.Message ("GET", url);


        string content_type = "";
        msg.got_headers.connect( ()=>{

            content_type = msg.response_headers.get_content_type (null);
            session.cancel_message (msg,Soup.Status.CANCELLED);
        });

        try {
            session.send (msg);
        } catch (GLib.Error error) {
            // Error code 19 is cancel, we do cancel after a while
            if (error.code != 19) {
                warning(error.message);
                return null;
            }
        }

        return content_type;


    }

    public void set_volume (double value) {
        pipeline.set_property ("volume",value);
        volume_changed (value);
    }

    public double get_volume () {
        var val = pipeline.get_property ("volume");
        return (double)val;
    }
    
    public void play() {
        start_streaming ();
    }

    public void pause() {
        pause_streaming ();
    }

    public void stop() {
        stop_streaming ();
    }
    
    private void start_streaming () {
        set_gstreamer_status(PlayerStatus.PLAYING);
        set_status(PlayerStatus.PLAYING);
    }
    
    private void pause_streaming () {
        set_gstreamer_status(PlayerStatus.PAUSED);
        set_status(PlayerStatus.PAUSED);
    }
    
    private void stop_streaming () {
        set_gstreamer_status(PlayerStatus.STOPPED);
        set_status(PlayerStatus.STOPPED);
    }
    
    private void set_gstreamer_status(PlayerStatus status) {
        if (pipeline == null)
            return;
        
        switch (status) {
            case PlayerStatus.PLAYING:
                pipeline.set_state(State.PLAYING);
                break;
            case PlayerStatus.PAUSED:
                pipeline.set_state(State.PAUSED);
                break;
            case PlayerStatus.STOPPED:
                pipeline.set_state(State.NULL);
                break;
        }
        
    }
    
    private void set_status(PlayerStatus status) {
            this.status = status;
            debug ("New player status: " + status.to_string());
            play_status_changed(status);
    }
}
