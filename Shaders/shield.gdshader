shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (color.a != 0.0) {
		color.b = 1.0;
	}
	COLOR = color;
}
