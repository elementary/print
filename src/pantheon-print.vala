//
//  Copyright (C) 2012 Andrea Basso
//  Copyright (C) 2014 Ezequiel Lewin
//
//  This program uses code originally written by Tarot Osuji for Leafpad http://tarot.freeshell.org/leafpad/
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

public class CustomOperation : Gtk.PrintOperation {        
    const int FONT_SIZE = 12;
    string content = "";
    int[] page_breaks;
    Cairo.Context context = null;
    Pango.Layout layout = null;
    Pango.FontDescription desc;    
    int height;
    int width;
    int line_count;

    public CustomOperation (string[] args, Gtk.Window main_window) {        
        var file = File.new_for_commandline_arg (args[1]);  

        if (file.query_exists ()) {
            try {
                var dis = new DataInputStream (file.read ());
                string line;
                
                while ((line = dis.read_line (null)) != null) 
                    if (line.validate())
                       content += line + "\n";
            } catch (Error e) {
                error ("%s", e.message);
            }
        }        

        //content = content.replace("&", "&amp;");       
        //content = content.replace("<", "&lt;");
        //content = content.replace(">", "&gt;");

        var setup = new Gtk.PageSetup ();

        setup.set_top_margin (15, Gtk.Unit.MM);
        setup.set_bottom_margin (15, Gtk.Unit.MM);
        setup.set_right_margin (20, Gtk.Unit.MM);
        setup.set_left_margin (20, Gtk.Unit.MM);
        set_default_page_setup (setup);        
    	begin_print.connect (beginprint);              
    	draw_page.connect (drawpage);
    }

    void beginprint (Gtk.PrintContext print_context) {
        layout = print_context.create_pango_layout ();
        layout.set_wrap (Pango.WrapMode.WORD_CHAR);

        desc = new Pango.FontDescription ();
        desc.set_family ("Open Sans");
        desc.set_absolute_size (FONT_SIZE*Pango.SCALE);
        layout.set_font_description (desc);
        
        width = (int)print_context.get_width ();
        layout.set_width (Pango.SCALE*width);
        height = (int)print_context.get_height ();     
  
        //layout.set_markup (content, -1);             
        layout.set_text (content, -1);
        line_count = layout.get_line_count ();
        Pango.LayoutLine layout_line;

        double page_height = 0;

        for (int line = 0; line < line_count; ++line) {
            Pango.Rectangle ink_rect, logical_rect;
            layout_line = layout.get_line (line);
            layout_line.get_extents (out ink_rect, out logical_rect);

            double line_height = logical_rect.height / Pango.SCALE;

            if (page_height + line_height > height) {
                page_breaks += line;
                page_height = 0;
            }
            
            page_height += line_height;
        }

        set_n_pages (page_breaks.length + 1);        
    }

    void drawpage(Gtk.PrintContext print_context, int page_num) {
        context = print_context.get_cairo_context ();
        context.set_source_rgb (0, 0, 0);    
           
        int layout_width, layout_height;

        layout.get_size (out layout_width, out layout_height);        
        context.move_to(layout_width / 2, (height - layout_height/Pango.SCALE) / 2);        
        Pango.cairo_show_layout (context, layout); 
       
        int line_num = 0;
        var line_per_page = height / FONT_SIZE;    
    
        if (line_count > line_per_page * (page_num + 1)) 
            line_num = line_per_page * (page_num + 1);
        else
            line_num = line_count;

        int j = 0;

        for (int i = line_per_page * page_num; i < line_num; i++) {
            var line = layout.get_line (i);
            context.move_to (0, FONT_SIZE * (j + 1));
            Pango.cairo_show_layout_line (context, line);
            j++;
        }
    }

}

public static void main (string[] args) {
  	Gtk.init (ref args);
  	var main_window = new Gtk.Window ();  	
  	var operation = new CustomOperation (args, main_window);

  	operation.run (Gtk.PrintOperationAction.PRINT_DIALOG, main_window);
}