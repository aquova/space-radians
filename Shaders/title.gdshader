shader_type canvas_item;

const float SPEED = 0.05;

void fragment() {
	float alpha = texture(TEXTURE, UV).a;
	vec3 col = vec3(0.0, 0.0, 0.75);
	float x = 0.5 - UV.x;
	float y = 0.5 - UV.y;
	float r = -sqrt(x * x + y * y);
	float z = 1.0 + 0.5 * sin((r + TIME * SPEED) / 0.025);
	vec3 texcol = vec3(x, y, z);
	COLOR = vec4(col * texcol, alpha); 
}
