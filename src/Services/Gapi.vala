/*
 *         _____
 *  ______ ___(_)______ ____________________________  ______  __
 *  _  __ `/_  /__  __ `__ \__  __ \_  ___/  __ \_  |/_/_  / / /
 *  / /_/ /_  / _  / / / / /_  /_/ /  /   / /_/ /_>  < _  /_/ /
 *  \__,_/ /_/  /_/ /_/ /_/_  .___//_/    \____//_/|_| _\__, /
 *                         /_/                         /____/
 *
 *                                                 Version 0.1.0
 *
 *           Micael Dias (@aimproxy) <diasmicaelandre@gmail.com>
 *
 *  ============================================================
 *
 *  Copyright (C) [2019] [Micael DIAS (@aimproxy)]
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
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *  ============================================================
 *
 */

using App.Configs;
using App.Views;

namespace App.Services {
    public class Gapi {
        private static Gapi? instance;
        private Soup.Session session;

        public signal void request_page_success(List<Font?> list);

        public Gapi() {
            this.session = new Soup.Session();
            this.session.ssl_strict = false;
        }

        public struct Font {
            string family;
            string category;
        }

        public void load_trending () {
            var uri = Constants.GAPI +
                "webfonts?key=" + Constants.GAPI_KEY +
                "&?sort=trending";

            var msg = new Soup.Message ("GET", uri);

            session.queue_message (msg, (sess, mess) => {
               if (mess.status_code == 200) {
                    try {
                        var parser = new Json.Parser ();
                        parser.load_from_data ((string) msg.response_body.flatten ().data, -1);

                        var list = get_data (parser);
                        request_page_success (list);
                    } catch (Error e) {
                        show_message("Request page fail", e.message, "dialog-error");
                    }
                } else {
                    show_message("Request page fail", @"status code: $(mess.status_code)", "dialog-error");
                }
            });
        }

        private List<Font?> get_data (Json.Parser parser) {
            var fonts_list = new List<Font?> ();

            var root_object = parser.get_root ().get_object ();
            var res = root_object.get_array_member ("items");

            foreach (var font in res.get_elements ()) {
                var obj = font.get_object ();

                var font_structure = Font();
                font_structure.family = obj.get_string_member ("family");
                font_structure.category = obj.get_string_member ("category");

                fonts_list.append(font_structure);
            }

            return fonts_list;
        }

        public static unowned Gapi get_instance () {
            if (instance == null) {
                instance = new Gapi ();
            }
            return instance;
        }

        private void show_message (string txt_primary, string txt_secondary, string icon) {
           var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                txt_primary,
                txt_secondary,
                icon,
                Gtk.ButtonsType.CLOSE
            );

            message_dialog.run ();
            message_dialog.destroy ();
        }
    }
}
