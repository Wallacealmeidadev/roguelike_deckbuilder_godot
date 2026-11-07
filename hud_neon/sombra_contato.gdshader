shader_type canvas_item;
render_mode unshaded;
uniform vec4 tinta : source_color = vec4(0.012, 0.019, 0.028, 0.6);
void fragment() {
	float distancia = length((UV - vec2(0.5)) * 2.0);
	float borda = 1.0 - smoothstep(0.18, 1.0, distancia);
	COLOR = vec4(tinta.rgb, tinta.a * borda * borda);
}
