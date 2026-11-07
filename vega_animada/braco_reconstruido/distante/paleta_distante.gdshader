shader_type canvas_item;
render_mode unshaded;

// Ganhos RGB (não cores sRGB): aproximam os cinzas da fonte próxima.
// Não modificam UV, geometria, alfa ou os acentos saturados.
uniform float intensidade : hint_range(0.0, 1.0) = 1.0;
uniform vec3 ganho_sombra = vec3(1.0, 1.0, 1.065);
uniform vec3 ganho_meio = vec3(0.967, 0.981, 1.051);
uniform vec3 ganho_luz = vec3(0.978, 0.990, 1.033);

void fragment() {
	vec3 fonte = texture(TEXTURE, UV).rgb;
	float luz = dot(fonte, vec3(0.2126, 0.7152, 0.0722));
	float croma = max(fonte.r, max(fonte.g, fonte.b)) - min(fonte.r, min(fonte.g, fonte.b));
	float mascara = (1.0 - smoothstep(0.10, 0.20, croma)) * smoothstep(0.06, 0.14, luz);
	vec3 ganho = mix(ganho_sombra, ganho_meio, smoothstep(0.20, 0.40, luz));
	ganho = mix(ganho, ganho_luz, smoothstep(0.40, 0.68, luz));
	ganho = mix(ganho, vec3(1.0), smoothstep(0.85, 0.98, luz));
	COLOR.rgb *= mix(vec3(1.0), ganho, mascara * intensidade);
}
