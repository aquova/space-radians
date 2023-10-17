shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (color.a != 0.0) { 
		float v = abs(sin(TIME));
		color.g = v;
		color.b = v;
	}
	COLOR = color;
}
