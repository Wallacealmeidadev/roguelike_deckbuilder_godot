shader_type canvas_item;
render_mode unshaded;

// A pintura nova só ocupa a cavidade escura; não repinta metal/ciano/transparência.
uniform sampler2D aro : source_color, filter_linear, repeat_disable;
uniform vec2 tamanho_aro;
uniform vec2 origem_aro;
uniform vec2 eixo_x;
uniform vec2 eixo_y;
varying vec2 uv_aro;

void vertex() {
	uv_aro = (origem_aro + VERTEX.x * eixo_x + VERTEX.y * eixo_y) / tamanho_aro;
}

void fragment() {
	vec4 original = texture(aro, uv_aro);
	float claro = max(original.r, max(original.g, original.b));
	float croma = claro - min(original.r, min(original.g, original.b));
	float interior = (1.0 - smoothstep(0.13, 0.32, claro))
		* (1.0 - smoothstep(0.05, 0.18, croma));
	COLOR.a *= original.a * interior;
}
