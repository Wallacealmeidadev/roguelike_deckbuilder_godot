shader_type canvas_item;
render_mode unshaded;

uniform sampler2D pintura : source_color, filter_linear_mipmap;
uniform vec2 contorno[128];
uniform int quantidade = 0;
varying vec4 cor_vertice;

void vertex() {
	cor_vertice = COLOR;
}

void fragment() {
	vec2 p = UV / TEXTURE_PIXEL_SIZE;
	float distancia = 10000.0;
	for (int i = 0; i < quantidade; i++) {
		vec2 a = contorno[i];
		vec2 b = contorno[(i + 1) % quantidade];
		vec2 eixo = b - a;
		float t = clamp(dot(p - a, eixo) / max(dot(eixo, eixo), 0.001), 0.0, 1.0);
		distancia = min(distancia, length(p - (a + t * eixo)));
	}
	// A geração fornece o acabamento interno; as bordas vêm da fonte
	// registrada para não importar fundo/pele de contornos ressintetizados.
	vec4 original = texture(TEXTURE, UV);
	vec4 nova = texture(pintura, UV);
	COLOR = mix(original, nova, smoothstep(3.0, 7.0, distancia)) * cor_vertice;
}
