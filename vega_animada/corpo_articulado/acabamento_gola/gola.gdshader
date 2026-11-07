shader_type canvas_item;
render_mode unshaded;

uniform sampler2D retoque : source_color, filter_linear, repeat_disable;
uniform vec2 tamanho_atlas;
uniform vec2 contorno[10];
uniform float intensidade : hint_range(0.0, 1.0) = 1.0;
uniform float transicao = 3.0;
varying vec4 modulacao;

void vertex() {
	modulacao = COLOR;
}

void fragment() {
	vec2 ponto = UV * tamanho_atlas;
	float distancia = 10000.0;
	bool dentro = false;
	for (int i = 0; i < 10; i++) {
		vec2 a = contorno[i];
		vec2 b = contorno[(i + 1) % 10];
		vec2 eixo = b - a;
		float t = clamp(dot(ponto - a, eixo) / dot(eixo, eixo), 0.0, 1.0);
		distancia = min(distancia, length(ponto - a - eixo * t));
		if ((a.y > ponto.y) != (b.y > ponto.y)) {
			if (ponto.x < (b.x - a.x) * (ponto.y - a.y) / (b.y - a.y) + a.x) {
				dentro = !dentro;
			}
		}
	}
	float mascara = dentro ? smoothstep(0.0, transicao, distancia) * intensidade : 0.0;
	vec4 original = texture(TEXTURE, UV);
	vec3 pintura = texture(retoque, UV).rgb;
	// Somente RGB local. Alfa, silhueta e modulação de dano continuam originais.
	COLOR = vec4(mix(original.rgb, pintura, mascara), original.a) * modulacao;
}
