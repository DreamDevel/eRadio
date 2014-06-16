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

using Gst;


public class Radio.StreamPlayer : GLib.Object {

    private Gst.Element pipeline;
    private Gst.Bus bus;
    public bool playing {get;private set;}
    public bool initialized {get;set;}

    private bool busCallback(Gst.Bus bus, Gst.Message message) {
        switch(message.type) {

            case Gst.MessageType.ERROR:
                GLib.Error error;
                string debug;
                message.parse_error(out error,out debug);
                stdout.printf("Error Ocured %s \n",error.message);
                pipeline.set_state(State.NULL);
                break;

            case Gst.MessageType.EOS:
                pipeline.set_state(State.NULL);
                break;
        }
        return true;
    }

    public StreamPlayer () {

        pipeline = Gst.ElementFactory.make ("playbin2","play");
        bus = pipeline.get_bus();
        bus.add_watch (busCallback);
        playing  = false;
    }

    public void add (string uri) {

        if (!this.initialized)
            this.initialized = true;

        pipeline.set_state(State.READY);
        pipeline.set_property("uri",uri);

    }

    public void set_volume (double value) {
        pipeline.set_property("volume",value);
    }

    public double get_volume () {
        var val = GLib.Value (typeof(double));
        pipeline.get_property ("volume", ref val);
        return (double)val;
    }

    public void play() {
        if(pipeline != null) {
            pipeline.set_state(State.PLAYING);
            playing = true;
        }
    }

    public void pause() {
        if(pipeline != null) {
            pipeline.set_state(State.PAUSED);
            playing = false;
        }

    }

    public void stop() {
        if(pipeline != null) {
            pipeline.set_state(State.NULL);
            playing = false;
        }
    }
}
