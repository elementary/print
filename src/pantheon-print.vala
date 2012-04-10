//
//  Copyright (C) 2012 Andrea Basso
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty ofprin
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

public class CustomOperation : Gtk.PrintOperation {
        int FONT_SIZE = 12;
        
        int height;
        int width;
        bool is_text = false;
        string content = "";
        string[] pages_text = {};
        Cairo.Context context = null;
        Pango.Layout layout = null;

    public CustomOperation (string[] args, Gtk.Window main_window) {
        
        var file = File.new_for_commandline_arg (args[1]);
    
        try {
            var file_info = file.query_info ("standard::content-type", 0, null);
            is_text = "text" in file_info.get_content_type ();
        } catch (Error e) {
            printerr ("Error: %s\n", e.message);
        }
        
        if (file.query_exists () && is_text) {
            try {
                var dis = new DataInputStream (file.read ());
                string line;
                
                while ((line = dis.read_line (null)) != null) 
                   content += line + "\n";
            } catch (Error e) {
                error ("%s", e.message);
            }
        }
        
        begin_print.connect ((print_context) => {
            context = print_context.get_cairo_context ();
            layout = Pango.cairo_create_layout (context);
            var desc = new Pango.FontDescription ();
            var setup = new Gtk.PageSetup ();
            
            setup.set_top_margin (54, Gtk.Unit.POINTS);
            setup.set_left_margin (36, Gtk.Unit.POINTS);            
            set_default_page_setup (setup);
            
            desc.set_family ("Open Sans");;
            desc.set_absolute_size (Pango.SCALE*FONT_SIZE);
            layout.set_wrap (Pango.WrapMode.WORD_CHAR);
            width = (int)print_context.get_width ();
            layout.set_width (Pango.SCALE*(width-36));
            height = (int)print_context.get_height ();
            layout.set_height (Pango.SCALE*(height-18));
            layout.set_font_description (desc);
            
            string written_lines = "";
            int pages = 1;
            foreach (string line in content.split ("\n")) {
                written_lines += line + "\n";
                layout.set_text (written_lines, -1);
                if (layout.get_line_count () >= height/(FONT_SIZE)) {
                    layout.set_text ("", -1);
                    context.move_to (0, 0);
                    pages_text += written_lines;
                    written_lines = "";
                    pages++;
                }
            }
            pages_text += written_lines;
            set_n_pages (pages);
        });
        
        draw_page.connect ( (operation, print_context, page_num)=> {
            context.move_to (0, 0);
            layout.set_text (pages_text[page_num], -1);
            Pango.cairo_show_layout(context, layout);
        });
    }
}

public static void main (string[] args) {
  	Gtk.init (ref args);
  	var main_window = new Gtk.Window ();
  	
  	var operation = new CustomOperation (args, main_window);
  	operation.run (Gtk.PrintOperationAction.PRINT_DIALOG, main_window);
}
