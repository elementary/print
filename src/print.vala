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
        int MARGIN_LEFT = 20;
        int MARGIN_TOP = 50;
    
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
            
            desc.set_family ("Open Sans");;
            desc.set_absolute_size (Pango.SCALE*FONT_SIZE);
            layout.set_wrap (Pango.WrapMode.WORD_CHAR);
            layout.set_width (Pango.SCALE*((int)print_context.get_width ()));
            int height = (int)print_context.get_height ();
            layout.set_height (Pango.SCALE*height);
    
            context.move_to (MARGIN_LEFT, MARGIN_TOP);
            layout.set_font_description (desc);
            
            string written_lines = "";
            int pages = 1;
            foreach (string line in content.split ("\n")) {
                written_lines += line + "\n";
                layout.set_text (written_lines, -1);
                if (layout.get_line_count () >= height/(FONT_SIZE+2)) {
                    layout.set_text ("", -1);
                    context.move_to (MARGIN_LEFT, MARGIN_TOP);
                    pages_text += written_lines;
                    written_lines = "";
                    pages++;
                }
            }
            pages_text += written_lines;
            set_n_pages (pages);
        });
        
        draw_page.connect ( (operation, print_context, page_num)=> {
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
