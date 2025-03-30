shader_type canvas_item;

uniform float alpha : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR.a *= alpha;
}
