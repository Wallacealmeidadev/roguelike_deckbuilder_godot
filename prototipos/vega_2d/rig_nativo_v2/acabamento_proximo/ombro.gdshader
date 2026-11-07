shader_type canvas_item;
render_mode unshaded;

uniform sampler2D pele_original : source_color, filter_linear, repeat_disable;
uniform vec2 tamanho_atlas;
uniform vec2 tamanho_pele;
uniform vec4 regiao;
uniform vec4 recorte;

float pele(vec3 cor) {
	return smoothstep(0.08, 0.18, cor.r - cor.b)
		* smoothstep(0.04, 0.12, cor.r - cor.g)
		* smoothstep(0.20, 0.40, cor.r);
}

void fragment() {
	// UVs vêm da malha de repouso, portanto a máscara acompanha o skinning.
	vec2 local = (UV * tamanho_atlas - recorte.xy) / recorte.zw;
	vec2 ponto_pele = regiao.xy + local * regiao.zw;
	vec4 original = texture(pele_original, (ponto_pele + vec2(300.0, 0.0)) / tamanho_pele);
	vec4 pintura = texture(TEXTURE, UV);
	COLOR.a *= original.a * pele(original.rgb) * pele(pintura.rgb);
}
