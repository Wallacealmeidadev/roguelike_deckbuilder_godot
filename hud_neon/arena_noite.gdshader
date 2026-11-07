shader_type canvas_item;

uniform float intensidade_noite : hint_range(0.0, 1.0) = 0.86;

void fragment() {
	vec4 imagem = texture(TEXTURE, UV);
	float luz = dot(imagem.rgb, vec3(0.2126, 0.7152, 0.0722));
	vec3 docas_noturnas = vec3(0.025, 0.085, 0.16) + luz * vec3(0.13, 0.20, 0.29);
	float distancia = distance(UV, vec2(0.52, 0.42));
	float vinheta = 1.0 - smoothstep(0.30, 0.88, distancia) * 0.27;
	vec3 cor = mix(imagem.rgb, docas_noturnas, intensidade_noite) * vinheta;
	COLOR = vec4(cor, imagem.a);
}
