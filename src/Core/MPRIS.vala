/*-Original Authors: Andreas Obergrusberger
 *                   Jörn Magens
 *
 * Edited by: Scott Ringwelski
 * Edited by: George Sofianos <georgesofianosgr@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

using Gee;

public class Radio.Core.MPRIS : GLib.Object {
    public MprisPlayer player = null;
    public MprisRoot root = null;

    private unowned DBusConnection conn;
    private uint owner_id;

    public void initialize () {
        owner_id = Bus.own_name(BusType.SESSION,
                                "org.mpris.MediaPlayer2." + Radio.App.APPLICATION_ID,
                                GLib.BusNameOwnerFlags.NONE,
                                on_bus_acquired,
                                on_name_acquired,
                                on_name_lost);

        if(owner_id == 0) {
            warning("Could not initialize MPRIS session.\n");
        }
    }

    private void on_bus_acquired (DBusConnection connection, string name) {
        this.conn = connection;
        debug ("Bus acquired");
        try {
            root = new MprisRoot ();
            connection.register_object ("/org/mpris/MediaPlayer2", root);
            player = new MprisPlayer (connection);
            connection.register_object ("/org/mpris/MediaPlayer2", player);
        }
        catch(IOError e) {
            warning("Could not create MPRIS player: %s\n", e.message);
        }
    }

    private void on_name_acquired(DBusConnection connection, string name) {
        debug ("Name acquired");
    }

    private void on_name_lost(DBusConnection connection, string name) {
        debug ("Name_lost");
    }
}

[DBus(name = "org.mpris.MediaPlayer2")]
public class MprisRoot : GLib.Object {

    public bool CanQuit {
        get {
            return true;
        }
    }

    public bool CanRaise {
        get {
            return true;
        }
    }

    public bool HasTrackList {
        get {
            return false;
        }
    }
    public string DesktopEntry {
        owned get {
            return Radio.App.APPLICATION_ID;
        }
    }

    public string Identity {
        owned get {
            return Radio.App.PROGRAM_NAME;
        }
    }

    public string[] SupportedUriSchemes {
        owned get {
            string[] sa = {"http", "https"};
            return sa;
        }
    }

    public string[] SupportedMimeTypes {
        owned get {
            string mime_types[1];
            mime_types[0] = "audio/mpeg";
            return mime_types;
        }
    }

    public void Quit () {
        Radio.App.main_window.destroy ();
    }

    public void Raise () {
        Radio.App.main_window.present ();
    }
}

[DBus(name = "org.mpris.MediaPlayer2.Player")]
public class MprisPlayer : GLib.Object {
    private unowned DBusConnection conn;

    private const string INTERFACE_NAME = "org.mpris.MediaPlayer2.Player";
    private uint send_property_source = 0;
    private HashTable<string,Variant> changed_properties = null;
    private HashTable<string,Variant> _metadata;
    private uint update_metadata_source = 0;


    public MprisPlayer(DBusConnection conn) {
        this.conn = conn;
        _metadata = new HashTable<string,Variant>(str_hash, str_equal);

        update_metadata(null);

        Radio.App.player.playing_station_updated.connect(handle_station_updated);
        Radio.App.player.play_status_changed.connect(playing_changed);
    }

    private void playing_changed(Radio.PlayerStatus status) {

        if(status == Radio.PlayerStatus.PLAYING) {
          update_metadata (Radio.App.player.station);
        } else if (status == Radio.PlayerStatus.STOPPED) {
          update_metadata (null);
        }

        trigger_metadata_update ();
    }

    private void trigger_metadata_update() {
        if(update_metadata_source != 0)
            Source.remove(update_metadata_source);

        update_metadata_source = Timeout.add(300, () => {

            Variant variant = this.PlaybackStatus;

            queue_property_for_notification("PlaybackStatus", variant);
            queue_property_for_notification("Metadata", _metadata);
            update_metadata_source = 0;
            return false;
        });
    }

    private void handle_station_updated (Radio.Models.Station? station) {
        update_metadata (station);
    }

    private void update_metadata (Radio.Models.Station? station) {
        if (station == null)
            _metadata.remove_all ();
        else
            set_media_metadata (station);

        trigger_metadata_update ();
    }

    private void set_media_metadata (Radio.Models.Station? station) {
        _metadata = new HashTable<string, Variant> (null, null);
        _metadata.insert("xesam:title", station.name);
        _metadata.insert("xesam:artist", get_simple_string_array(_("Unknown")));
    }

    private static string[] get_simple_string_array (string? text) {
    if (text == null)
        return new string [0];
    string[] array = new string[0];
    array += text;
    return array;
}

    private bool send_property_change() {

        if(changed_properties == null)
            return false;

        var builder             = new VariantBuilder(VariantType.ARRAY);
        var invalidated_builder = new VariantBuilder(new VariantType("as"));

        foreach(string name in changed_properties.get_keys()) {
            Variant variant = changed_properties.lookup(name);
            builder.add("{sv}", name, variant);
        }

        changed_properties = null;

        try {
            conn.emit_signal(null,
                             "/org/mpris/MediaPlayer2",
                             "org.freedesktop.DBus.Properties",
                             "PropertiesChanged",
                             new Variant("(sa{sv}as)",
                                         INTERFACE_NAME,
                                         builder,
                                         invalidated_builder)
                             );
        }
        catch(Error e) {
            warning (e.message);
            warning ("Could not send MPRIS property change");
        }
        send_property_source = 0;
        return false;
    }

    private void queue_property_for_notification(string property, Variant val) {
        // putting the properties into a hashtable works as akind of event compression

        if(changed_properties == null)
            changed_properties = new HashTable<string,Variant>(str_hash, str_equal);

        changed_properties.insert(property, val);

        if(send_property_source == 0) {
            send_property_source = Idle.add(send_property_change);
        }
    }

    public string PlaybackStatus {
        owned get {
            if(Radio.App.player.status == Radio.PlayerStatus.PLAYING) {
                return "Playing";
            } else if(Radio.App.player.status == Radio.PlayerStatus.STOPPED) {
                return "Stopped";
            } else if(Radio.App.player.status == Radio.PlayerStatus.PAUSED) {
                return "Paused";
            } else {
                return "Stopped";
            }
        }
    }

    public double Rate {
        get {
            return (double)1.0;
        }
        set {
        }
    }

    // Currently not needed
    public double Volume {
        get{
            return 1;
            //return App.player.volume;
        }
        set {
            //App.player.volume = value;
        }
    }

    public bool CanGoNext {
        get {
            return true;
        }
    }

    public bool CanGoPrevious {
        get {
            return true;
        }
    }

    public bool CanPlay {
        get {
            return true;
        }
    }

    public bool CanPause {
        get {
            return true;
        }
    }

    public bool CanSeek {
        get {
            return false;
        }
    }

    public bool CanControl {
        get {
            return true;
        }
    }

    public signal void Seeked(int64 Position);

    public void Next() {
        Radio.App.player_helper.play_next_station (this);
    }

    public void Previous() {
        Radio.App.player_helper.play_previous_station (this);
    }

    public void Pause() {
        Radio.App.player.stop ();
    }

    public void PlayPause() {
        Radio.App.player_helper.play_pause (this);
    }

    public void Stop() {
        Radio.App.player.stop ();
    }

    public void Play() {
        Radio.App.player.play ();
    }

    public void OpenUri(string Uri) {

    }
}
