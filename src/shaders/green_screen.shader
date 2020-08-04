shader_type canvas_item;

void fragment(){
    vec4 col = texture(TEXTURE, UV);
	if (col.rgb == vec3(0,1.0,0)){
		col.a = 0.0;
	}
	COLOR = col;
}