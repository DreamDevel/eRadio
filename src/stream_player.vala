using Gst;


public class Radio.StreamPlayer : GLib.Object {

	private Gst.Element pipeline;
	private Gst.Bus bus;
	public bool playing {get;private set;}
	public bool initialized {get;private set;}

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

		pipeline = null;
		bus      = null;
		playing  = false;
	}

	public void add (string uri) {

		if (pipeline == null) {
			initialized = true;
		}

		// Set play state to null to free previous stream
		this.stop ();

		pipeline = Gst.ElementFactory.make("playbin2","play");
		pipeline.set("uri",uri);
		bus = pipeline.get_bus();
		bus.add_watch(busCallback);

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
