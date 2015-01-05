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

// TODO refactor
public class Radio.Core.Player : GLib.Object {

    private Gst.Element pipeline;
    private Gst.Bus bus;

    public bool has_url {get;set;}

    public signal void volume_changed (double volume_value);
    public signal void play_status_changed(string status);
    public signal void playback_error(GLib.Error error);

    private bool busCallback(Gst.Bus bus, Gst.Message message) {
        switch(message.type) {

            case Gst.MessageType.ERROR:
                GLib.Error error;
                string debug;
                message.parse_error(out error,out debug);

                if(error.message != "Cancelled") {
                    stdout.printf("Error Occurred %s \n",error.message);
                    pipeline.set_state(State.NULL);
                    playback_error(error);
                    this.has_url = false;
                }

                break;

            case Gst.MessageType.EOS:
                pipeline.set_state(State.NULL);
                break;
        }
        return true;
    }

    public Player () {

        /*pipeline = Gst.ElementFactory.make ("playbin","play");
        bus = pipeline.get_bus();
        bus.add_watch (busCallback,null);*/
    }

    public void add (string uri) throws Radio.Error{

        string final_uri = uri;
        string content_type = "";

        if (final_uri.index_of("http") == 0){
            content_type = this.get_content_type (uri);
        }

        // Check content type to decode
        if ( content_type == "audio/x-mpegurl" || content_type == "audio/mpegurl" ) {
            var list = M3UDecoder.parse (uri);
            // Temporary ignoring all links beside the first
            if ( list != null )
                final_uri = list[0];
            else
                throw new Radio.Error.GENERAL ("Could not decode m3u file, wrong url or corrupted file");
        }
        else if ( content_type == "audio/x-scpls" || content_type == "application/pls+xml") {
            var list = PLSDecoder.parse (uri);
            // Temporary ignoring all links beside the first
            if ( list != null )
                final_uri = list[0];
            else
                throw new Radio.Error.GENERAL ("Could not decode pls file, wrong url or corrupted file");

        }
        else if ( content_type == "video/x-ms-wmv" || content_type == "video/x-ms-wvx" || content_type == "video/x-ms-asf" || content_type == "video/x-ms-asx" || content_type == "audio/x-ms-wax" || uri.last_index_of (".asx",uri.length - 4) != -1) {
            var list = ASXDecoder.parse (uri);
            // Temporary ignoring all links beside the first
            if ( list != null )
                final_uri = list[0];
            else
                throw new Radio.Error.GENERAL ("Could not decode asx file, wrong url or corrupted file");
        }

        this.has_url = true;

        pipeline.set_state (State.READY);
        pipeline.set_property ("uri",final_uri);

    }

    public void set_volume (double value) {
        pipeline.set_property ("volume",value);
        volume_changed (value);
    }

    public double get_volume () {
        var val = GLib.Value (typeof(double));
        pipeline.get_property ("volume", ref val);
        return (double)val;
    }

    public void play() {
        if(pipeline != null) {
            pipeline.set_state(State.PLAYING);
            play_status_changed("playing");
        }
    }

    public void pause() {
        if(pipeline != null) {
            pipeline.set_state(State.PAUSED);
            play_status_changed("paused");
        }

    }

    public void stop() {
        if(pipeline != null) {
            pipeline.set_state(State.NULL);
            play_status_changed("stopped");
            this.has_url = false;
        }
    }

    private string? get_content_type (string url) {

        Soup.SessionSync session = new Soup.SessionSync ();
        session.timeout = 2;
        Soup.Message msg = new Soup.Message ("GET", url);

        string content_type = "";
        msg.got_headers.connect( ()=>{

            content_type = msg.response_headers.get_content_type (null);
            session.cancel_message (msg,Soup.Status.CANCELLED);
        });

        session.send_message (msg);

        // Note: status code returns 1, possibly because we cancel request, so we check length
        if (content_type.length == 0) {
            stderr.printf("Could not get content type\n");
            return null;
        }

        return content_type;


    }
}
