shader_type canvas_item;

uniform vec4 color_base: hint_color;
uniform vec4 color_replace: hint_color;

void fragment(){
	vec4 color = texture(TEXTURE,UV);
	if (distance(color,color_base)<0.1){
		color = color_replace;
	}
	COLOR = color;
}