shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (color.a != 0.0) { 
		color.g = 0.16 * abs(sin(TIME)) + 0.84;
		color.b = abs(sin(TIME));
	}
	COLOR = color;
}