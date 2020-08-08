shader_type canvas_item;

uniform vec4 color_remove: hint_color;

uniform bool activated = true;

void fragment(){
    vec4 col = texture(TEXTURE, UV);
	if (col.rgb == color_remove.rgb && activated){
		col.a = 0.0;
	}
	COLOR = col;
}