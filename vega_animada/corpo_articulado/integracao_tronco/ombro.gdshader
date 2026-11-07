shader_type canvas_item;
render_mode unshaded;

uniform sampler2D pele_original : source_color, filter_linear, repeat_disable;
uniform sampler2D pintura_tronco : source_color, filter_linear, repeat_disable;
uniform vec2 tamanho_atlas;
uniform vec2 tamanho_pele;
uniform vec4 regiao;
uniform vec4 recorte;
uniform float integracao : hint_range(0.0, 1.0) = 1.0;
varying vec4 modulacao;

float pele(vec3 cor) {
	return smoothstep(0.08, 0.18, cor.r - cor.b)
		* smoothstep(0.04, 0.12, cor.r - cor.g)
		* smoothstep(0.20, 0.40, cor.r);
}

void vertex() {
	modulacao = COLOR;
}

void fragment() {
	vec2 local = (UV * tamanho_atlas - recorte.xy) / recorte.zw;
	vec2 ponto_pele = regiao.xy + local * regiao.zw;
	vec2 uv_pele = (ponto_pele + vec2(300.0, 0.0)) / tamanho_pele;
	vec4 original = texture(pele_original, uv_pele);
	vec4 pintura_anterior = texture(TEXTURE, UV);
	// Manter exatamente a cobertura antiga, inclusive sobreposição semitransparente.
	COLOR.a *= original.a * pele(original.rgb) * pele(pintura_anterior.rgb);
	vec3 nova = texture(pintura_tronco, uv_pele).rgb * modulacao.rgb;
	COLOR.rgb = mix(COLOR.rgb, nova, integracao);
}
