globalvar QTR_FORMAT, FONT_DICTIONARY;

vertex_format_begin();

vertex_format_add_position_3d();
vertex_format_add_texcoord();
vertex_format_add_color();

QTR_FORMAT = vertex_format_end();

draw_set_font(fntLiberationSans);
draw_text(0, 0, "load font texture");

FONT_DICTIONARY = [];

FONT_DICTIONARY[fntLiberationSans] = font_get_info(fntLiberationSans);
FONT_DICTIONARY[fntLiberationSans].tw = texture_get_texel_width(FONT_DICTIONARY[fntLiberationSans].texture)
FONT_DICTIONARY[fntLiberationSans].th = texture_get_texel_height(FONT_DICTIONARY[fntLiberationSans].texture)


function Text(style = {}) constructor{
	self.style = style;
	
	line = 0;
	lines = [0, 0];	//each 2 indeces are 1 line {x, y}
	
	caret = [[]]; //each 2 indeces in each sub array are a glyph [x, x + width]
	selected = {start: -1, finish: -1};
	
	text = get_default("text", "");
	fontIndex = get_default("font", fntLiberationSans);
	draw_set_font(fontIndex);
	draw_text(0, 0, text);	//load whatever glyphs we need into memory
	//for some reason the manual says some glyphs might not be loaded even though it already loads all
	//just incase the manual changes like the font info going (in texels) to (in pixels)
	
	if (array_get_index(FONT_DICTIONARY, fontIndex) == -1){
		font = font_get_info(fontIndex);
		font.tw = texture_get_texel_width(font.texture)
		font.th = texture_get_texel_height(font.texture)
	}
	
	texture = font.texture;
	
	vertex = {
		buffer: vertex_create_buffer(),
		normal: -2,
	}
	
	shift = {
		x: 0,
		y: 0,
	}
	
	vertex_begin(vertex.buffer, QTR_FORMAT);
	    
	text = string_replace_all(text, "	", "       ");
	string_foreach(text, function(character){
		switch (character){
		case "\t": 
			shift.x += font_get_size(fontIndex) * 3;
			return;
		case "\n":
			shift.x = 0;
			shift.y += font_get_size(fontIndex);
			line++;
			
			caret[line] = [];
			array_concat(lines, [shift.x, shift.y]);
			return;
		}
		
		var glyph = font.glyphs[$ character];
		array_push(caret[line], [shift.x + glyph.offset, shift.x + glyph.shift, glyph.h]);
		
		build_quad(vertex.buffer, shift.x + glyph.offset, shift.y + glyph.yoffset, glyph.w, glyph.h, {
			x: glyph.x * font.tw,	
			y: glyph.y * font.th,
			width: glyph.w * font.tw,
			height: glyph.h * font.th,	
		});
		
		shift.x += glyph.shift;
	});
	
	vertex_end(vertex.buffer);
	
	step = function(){
		if (device_mouse_check_button_pressed(0, mb_left)){
			var char = caret_binary_search(caret[0], device_mouse_x_to_gui(0));
			selected.start = char;
			selected.finish = char;
		}
		
		if (device_mouse_check_button(0, mb_left)){
			var char = caret_binary_search(caret[0], device_mouse_x_to_gui(0));
			selected.finish = char;
		}
	}
	
	
	draw_selection = function(line, left){
			draw_primitive_begin(pr_trianglelist);
			
			draw_vertex_colour(caret[line][selected.start][left], 0, c_aqua, 0.5);
			draw_vertex_colour(caret[line][selected.start][left], caret[0][selected.start][2], c_aqua, 0.5);
			draw_vertex_colour(caret[line][selected.finish][!left], caret[0][selected.finish][2], c_aqua, 0.5);
			
			draw_vertex_colour(caret[line][selected.start][left], 0, c_aqua, 0.5);
			draw_vertex_colour(caret[line][selected.finish][!left], 0, c_aqua, 0.5);
			draw_vertex_colour(caret[line][selected.finish][!left], caret[0][selected.finish][2], c_aqua, 0.5);
			
			draw_primitive_end();	
	}
	
	draw = function(){		
		if (selected.start != -1){
			var left = selected.start > selected.finish;
			
			draw_selection(0, left)
		}
		
		vertex_submit(vertex.buffer, pr_trianglelist, texture);

	}
	
	cleanup = function(){
		
	}
}

function caret_binary_search(caret_line, mx)
{
    var low = 0;
    var high = array_length(caret_line) - 1;
    
    while (low <= high)
    {
        var mid = (low + high) div 2;
        
        if (caret_line[mid][1] < mx) low = mid + 1;
        else high = mid - 1;
    }
    
    return clamp(low, 0, array_length(caret_line) - 1);
}

function build_quad(vbuff, tx, ty, w, h, uv = {x: 0, y: 0, width: 1, height: 1}, radius = {topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0}, color = c_white, opacity = 1 , d = 0, anchorx = 0, anchory = 0){
//first triangle
	//top left
	vertex_position_3d(vbuff, tx, ty, d);
	vertex_texcoord(vbuff, uv.x, uv.y);
	vertex_color(vbuff, color, opacity);
	
	//top right
	vertex_position_3d(vbuff, tx + w, ty, d);
	vertex_texcoord(vbuff, uv.x + uv.width, uv.y);
	vertex_color(vbuff, color, opacity);
	
	//bottom left
	vertex_position_3d(vbuff, tx, ty + h, d);
	vertex_texcoord(vbuff, uv.x, uv.y + uv.height);
	vertex_color(vbuff, color, opacity);

//second triangle
	//bottom right
	vertex_position_3d(vbuff, tx + w, ty + h, d);
	vertex_texcoord(vbuff, uv.x + uv.width, uv.y + uv.height);
	vertex_color(vbuff, color, opacity);

	//bottom left
	vertex_position_3d(vbuff, tx, ty + h, d);
	vertex_texcoord(vbuff, uv.x, uv.y + uv.height);
	vertex_color(vbuff, color, opacity);

	//top right
	vertex_position_3d(vbuff, tx + w, ty, d);
	vertex_texcoord(vbuff, uv.x + uv.width, uv.y);
	vertex_color(vbuff, color, opacity);
}