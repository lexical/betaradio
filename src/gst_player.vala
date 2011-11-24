/* -*- coding: utf-8; indent-tabs-mode: nil; tab-width: 4; c-basic-offset: 4; -*- */
/* vim:set fileencodings=utf-8 tabstop=4 expandtab shiftwidth=4 softtabstop=4: */
/**
 * Copyright (C) 2010 Shih-Yuan Lee (FourDollars) <fourdollars@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gst;

class GstPlayer : GLib.Object {

    private static GstPlayer instance = null;
    private dynamic Element player = null;

    private GstPlayer(string name) {
        player = ElementFactory.make("playbin2", name);
        player.get_bus().add_watch(bus_callback);
    }

    ~GstPlayer() {
        player = null;
    }

    public static GstPlayer get_instance() {
        if (instance == null) {
            instance = new GstPlayer("BetaRadio");
        }
        return instance;
    }

    public void play(string url) {
        State state;
        State pending;

        while (player.get_state(out state, out pending, 2000) != Gst.StateChangeReturn.SUCCESS) {
            message("state: %s, pending: %s", state.to_string(), pending.to_string());
        }

        if (state != State.READY) {
            player.set_state(State.READY);
        }

        player.uri = url;

        while (player.get_state(out state, out pending, 2000) != Gst.StateChangeReturn.SUCCESS) {
            message("state: %s, pending: %s", state.to_string(), pending.to_string());
        }

        player.set_state(State.PLAYING);
    }

    public void stop() {
        State state;
        State pending;

        while (player.get_state(out state, out pending, 2000) != Gst.StateChangeReturn.SUCCESS) {
            message("state: %s, pending: %s", state.to_string(), pending.to_string());
        }

        if (state != State.READY) {
            player.set_state(State.READY);
        }
    }

    private bool bus_callback(Gst.Bus bus, Gst.Message msg) {
        switch (msg.type) {
            case Gst.MessageType.ERROR:
                GLib.Error err;
                string debug;
                msg.parse_error (out err, out debug);
                warning("Error: %s\n", err.message);
                player.set_state(State.NULL);
                break;
            case Gst.MessageType.EOS:
                warning("end of stream\n");
                break;
            case Gst.MessageType.STATE_CHANGED:
                Gst.State oldstate;
                Gst.State newstate;
                Gst.State pending;
                msg.parse_state_changed (out oldstate, out newstate,
                        out pending);
                GLib.stdout.printf ("state changed: %s->%s:%s\n",
                        oldstate.to_string (), newstate.to_string (),
                        pending.to_string ());
                break;
            case Gst.MessageType.BUFFERING:
                /* ignore buffering message */
                break;
            default:
                message("message type: %s", msg.type.to_string());
                break;
        }

        return true;
    }
}
