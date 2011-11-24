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

using Json;
using Soup;

class JsonSoup : GLib.Object {
    private Json.Parser parser = null;
    private unowned Json.Node node = null;

    /* Constructor */
    public JsonSoup.buffer(string buffer) {
        parser = new Parser();
        try {
            parser.load_from_data(buffer);
            node = parser.get_root();
        } catch (Error e) {
            warning("%s", e.message);
        }
    }
    public JsonSoup.file(string file) {
        parser = new Parser();
        try {
            parser.load_from_file(file);
            node = parser.get_root();
        } catch (Error e) {
            warning("%s", e.message);
        }
    }
    public JsonSoup.http(string url) {
        var session = new SessionSync();
        var message = new Message.from_uri("GET", new URI(url));
        if (session.send_message(message) != 200) {
            warning("Can not connect to %s", url);
        }
        parser = new Parser();
        try {
            parser.load_from_data((string) message.response_body.data);
            node = parser.get_root();
        } catch (Error e) {
            warning("%s", e.message);
        }
    }

    /* Destructor */
    ~JsonSoup() {
        node = null;
        parser = null;
    }

    /* Movement */
    public unowned JsonSoup object(string name) {
        if (node.get_node_type() != NodeType.OBJECT) {
            warning("This is not a object.");
            return this;
        }
        var object = node.get_object();
        if (object.has_member(name) == false) {
            warning("There is no such member as %s.", name);
            return this;
        }
        node = object.get_member(name);
        return this;
    }
    public unowned JsonSoup sibling(string name) {
        parent();
        object(name);
        return this;
    }
    public unowned JsonSoup array(int idx) {
        if (node.get_node_type() != NodeType.ARRAY) {
            warning("This is not a array.");
            return this;
        }
        var array = node.get_array();
        int length = (int) array.get_length();
        if (idx > length || idx < 0) {
            warning("Out of index. %d", idx);
            return this;
        }
        node = array.get_element(idx);
        return this;
    }
    public unowned JsonSoup parent() {
        unowned Json.Node parent_node = node.get_parent();
        if (parent_node == null) {
            warning("Already be root.");
            return this;
        }
        node = parent_node;
        return this;
    }
    public unowned JsonSoup grandparent() {
        parent();
        parent();
        return this;
    }
    public unowned JsonSoup reset() {
        node = parser.get_root();
        return this;
    }

    /* Type Checking */
    private bool is_value() {
        if (node.get_node_type() == NodeType.VALUE) {
            return true;
        } else {
            return false;
        }
    }
    public bool is_object() {
        return (node.get_node_type() == NodeType.OBJECT);
    }
    public bool is_array() {
        return (node.get_node_type() == NodeType.ARRAY);
    }
    public bool is_string() {
        if (is_value() == false) {
            return false;
        }
        return (node.get_value_type() == typeof(string));
    }
    public bool is_int() {
        if (is_value() == false) {
            return false;
        }
        return (node.get_value_type() == typeof(int64));
    }
    public bool is_double() {
        if (is_value() == false) {
            return false;
        }
        return (node.get_value_type() == typeof(double));
    }
    public bool is_bool() {
        if (is_value() == false) {
            return false;
        }
        return (node.get_value_type() == typeof(bool));
    }

    /* Fetch Data */
    public string get_string() {
        return node.get_string();
    }
    public int64 get_int() {
        return node.get_int();
    }
    public double get_double() {
        return node.get_double();
    }
    public bool get_bool() {
        return node.get_boolean();
    }
    public int length() {
        if (is_array() == false) {
            return 0;
        }
        var array = node.get_array();
        return (int) array.get_length();
    }
}
