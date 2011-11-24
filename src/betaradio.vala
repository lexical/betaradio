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

using Gtk;
using Gst;

class BetaRadio : GLib.Object {
    private Gtk.StatusIcon icon = null;
    private Gtk.Menu menu = null;

    public static void main (string[] args) {
        Intl.bindtextdomain( Config.PACKAGE_NAME, Config.LOCALEDIR );
        Intl.bind_textdomain_codeset( Config.PACKAGE_NAME, "UTF-8" );
        Intl.textdomain( Config.PACKAGE_NAME );
        Gst.init(ref args);
        Gtk.init(ref args);
        var app = new BetaRadio();
        message("Running");
        Gtk.main();
        GLib.mem_profile();
    }

    public BetaRadio () {
        if (FileUtils.test(Config.DATADIR + "/pixmaps/betaradio/betaradio.png", FileTest.IS_REGULAR) == true) {
            icon = new Gtk.StatusIcon.from_file(Config.DATADIR + "/pixmaps/betaradio/betaradio.png");
        } else if (FileUtils.test("data/betaradio.png", FileTest.IS_REGULAR) == true) {
            icon = new Gtk.StatusIcon.from_file("data/betaradio.png");
        } else {
            icon = new Gtk.StatusIcon.from_stock(Gtk.Stock.MISSING_IMAGE);
        }
        icon.set_tooltip_text(_("Data Synchronizing ..."));

        try {
            Thread.create<void*> ( () => {
                menu = new Gtk.Menu();
                unowned SList<Gtk.RadioMenuItem> group = null;

                var stop = new Gtk.RadioMenuItem.with_label(group, _("Stop"));
                group = stop.get_group();
                menu.append(stop);
                stop.toggled.connect((e) => {
                    if (e.get_active() == true) {
                        GstPlayer.get_instance().stop();
                        icon.set_tooltip_text(_("BetaRadio Tuner"));
                    }
                });

                menu.append(new Gtk.SeparatorMenuItem());

                group = getMenu(menu, group);

                menu.append(new Gtk.SeparatorMenuItem());

                var quit = new Gtk.RadioMenuItem.with_label(group, _("Quit"));
                group = quit.get_group();
                menu.append(quit);
                quit.toggled.connect((e) => {
                    if (e.get_active() == true) {
                        GstPlayer.get_instance().stop();
                        icon.set_tooltip_text(_("BetaRadio Tuner"));
                        Gtk.main_quit();
                    }
                });

                menu.show_all();

                icon.button_release_event.connect((e) => {
                    menu.popup(null, null, null, e.button, e.time);
                    return true;
                });

                icon.set_tooltip_text(_("BetaRadio Tuner"));

                return null;
            }, true);
        } catch(GLib.ThreadError e) {
            debug("%s", e.message);
        }
    }

    private unowned SList<Gtk.RadioMenuItem> getMenu(Gtk.Menu menu, SList<Gtk.RadioMenuItem> group) {
        var list = new JsonSoup.http("http://betaradio.googlecode.com/svn/trunk/utils/list.json");
        if (list.is_array() == false) {
            var conn_err = new Gtk.MenuItem.with_label(_("Connection failed. Please restart this program."));
            menu.append(conn_err);
            return group;
        }
        int length = list.length();
        for (int i = 0; i < length; i++) {
            string feed = list.array(i).get_string();
            var json = new JsonSoup.http(feed);
            if (json.object("property").is_string() == false) {
                continue;
            }
            string title = json.sibling("title").get_string();
            var item = new Gtk.MenuItem.with_label(title);
            menu.append(item);
            var submenu = new Gtk.Menu();
            item.set_submenu(submenu);
            string property = json.sibling("property").get_string();
            if (property == "category" && json.sibling("category").is_array() == true) {
                group = getCategoryMenu(submenu, group, json);
            } else if (property == "channel" && json.sibling("channel").is_array() == true) {
                group = getChannelMenu(submenu, group, json);
            }
            list.parent();
        }
        return group;
    }

    private unowned SList<Gtk.RadioMenuItem> getCategoryMenu(Gtk.Menu menu, SList<Gtk.RadioMenuItem> group, JsonSoup json) {
        int length = json.length();
        for (int i = 0; i < length; i++) {
            string category = json.array(i).object("title").get_string();
            var item = new Gtk.MenuItem.with_label(category);
            var submenu = new Gtk.Menu();
            menu.append(item);
            item.set_submenu(submenu);
            int size = json.sibling("channel").length();
            for (int j = 0; j < size; j++) {
                string title = json.array(j).object("title").get_string();
                string type = json.sibling("type").get_string();
                string url = filter_url(json.sibling("url").get_string(), type);
                var radio = new Gtk.RadioMenuItem.with_label(group, title);
                group = radio.get_group();
                submenu.append(radio);
                radio.toggled.connect( (e) => {
                    if (e.get_active() == true) {
                        GstPlayer.get_instance().play(url);
                        icon.set_tooltip_text(title);
                    }
                });
                json.grandparent();
            }
            json.grandparent();
        }
        return group;
    }

    private unowned SList<Gtk.RadioMenuItem> getChannelMenu(Gtk.Menu menu, SList<Gtk.RadioMenuItem> group, JsonSoup json) {
        int length = json.length();
        for (int i = 0; i < length; i++) {
            string title = json.array(i).object("title").get_string();
            string type = json.sibling("type").get_string();
            string url = filter_url(json.sibling("url").get_string(), type);
            var radio = new Gtk.RadioMenuItem.with_label(group, title);
            group = radio.get_group();
            menu.append(radio);
            radio.toggled.connect( (e) => {
                if (e.get_active() == true) {
                    GstPlayer.get_instance().play(url);
                    icon.set_tooltip_text(title);
                }
            });
            json.grandparent();
        }
        return group;
    }

    private string filter_url(string url, string type) {
        /* http://bcr.media.hinet.net/RA000042 */
        /* mmsh://bcr.media.hinet.net/RA000042\?MSWMExt\=.asf */
        if (type == "mms" && url.has_prefix("http://") == true) {
            return url.replace("http", "mmsh").concat("\\?MSWMExt\\=.asf");
        }
        return url;
    }
}
