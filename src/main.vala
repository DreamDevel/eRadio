int main(string[] args) {

    Gtk.init (ref args);
    Gst.init (ref args);
    var app = new Radio.App ();
   	app.run(args);

    return 0;
}