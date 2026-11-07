shader_type canvas_item;
render_mode unshaded;

uniform sampler2D retoque : source_color, filter_linear, repeat_disable;
uniform sampler2D pintura_tronco : source_color, filter_linear, repeat_disable;
uniform vec2 tamanho_atlas;
uniform vec2 contorno[10];
uniform vec2 contorno_tronco[10];
uniform float intensidade = 1.0;
uniform float integracao : hint_range(0.0, 1.0) = 1.0;
uniform float transicao = 3.0;
uniform float forca_sombra : hint_range(0.0, 0.6) = 0.32;
uniform vec4 braco_superior;
uniform vec4 antebraco;
uniform vec2 raios = vec2(22.0, 25.0);
uniform vec2 deslocamento = vec2(4.0, 7.0);
varying vec4 modulacao;

float mascara(vec2 ponto, bool gola, float suavidade) {
	float distancia = 10000.0;
	bool dentro = false;
	for (int i = 0; i < 10; i++) {
		vec2 a = gola ? contorno[i] : contorno_tronco[i];
		vec2 b = gola ? contorno[(i + 1) % 10] : contorno_tronco[(i + 1) % 10];
		vec2 eixo = b - a;
		float t = clamp(dot(ponto - a, eixo) / dot(eixo, eixo), 0.0, 1.0);
		distancia = min(distancia, length(ponto - a - eixo * t));
		if ((a.y > ponto.y) != (b.y > ponto.y)) {
			if (ponto.x < (b.x - a.x) * (ponto.y - a.y) / (b.y - a.y) + a.x) {
				dentro = !dentro;
			}
		}
	}
	return dentro ? smoothstep(0.0, suavidade, distancia) : 0.0;
}

float capsula(vec2 ponto, vec4 segmento, float raio) {
	vec2 eixo = segmento.zw - segmento.xy;
	vec2 inicio = segmento.xy + deslocamento;
	float t = clamp(dot(ponto - inicio, eixo) / max(dot(eixo, eixo), 0.001), 0.0, 1.0);
	float distancia = length(ponto - inicio - t * eixo);
	return 1.0 - smoothstep(raio - 3.0, raio + 5.0, distancia);
}

void vertex() {
	modulacao = COLOR;
}

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	vec2 ponto = UV * tamanho_atlas;
	float gola = mascara(ponto, true, transicao) * intensidade;
	vec3 cor = mix(original.rgb, texture(retoque, UV).rgb, gola);
	float area = mascara(ponto, false, 4.0);
	// Manter gola/pescoço 11 e tecido bordô da cintura, mesmo dentro do recorte.
	float bordo = smoothstep(0.02, 0.06, original.b - original.g)
		* smoothstep(0.05, 0.12, original.r - original.g);
	area *= (1.0 - mascara(ponto, true, transicao)) * (1.0 - bordo);
	cor = mix(cor, texture(pintura_tronco, UV).rgb, area * integracao);
	// Receptor é somente a regata, nunca rosto, pele, próteses ou transparência.
	float croma = max(original.r, max(original.g, original.b)) - min(original.r, min(original.g, original.b));
	float tecido = (1.0 - smoothstep(0.06, 0.16, croma)) * (1.0 - smoothstep(0.42, 0.60, original.r));
	vec2 pixel = SCREEN_UV / SCREEN_PIXEL_SIZE;
	float sombra = max(capsula(pixel, braco_superior, raios.x), capsula(pixel, antebraco, raios.y));
	cor *= 1.0 - sombra * tecido * area * forca_sombra * integracao;
	COLOR = vec4(cor, original.a) * modulacao;
}
