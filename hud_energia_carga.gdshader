shader_type canvas_item;

uniform float fill_ratio : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 tinta = texture(TEXTURE, UV);
	vec2 ponto = UV * 48.0;
	// Preserva o contorno e os detalhes do SVG aprovado; apenas a tinta
	// turquesa da cavidade muda conforme a energia disponivel.
	float esquerda = mix(11.0, 9.0, clamp((ponto.y - 10.0) / 33.0, 0.0, 1.0));
	float direita = mix(37.0, 39.0, clamp((ponto.y - 10.0) / 33.0, 0.0, 1.0));
	bool cavidade = ponto.x > esquerda && ponto.x < direita && ponto.y > 10.0 && ponto.y < 43.0;
	bool turquesa = tinta.r < 0.45 && tinta.g > 0.65 && tinta.b > 0.65;
	if (cavidade && turquesa && ponto.y < 43.0 - 33.0 * fill_ratio) {
		tinta.rgb = vec3(0.063, 0.086, 0.118);
	}
	COLOR = tinta;
}
