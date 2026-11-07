shader_type canvas_item;
render_mode unshaded;

// Aproxima os claros neutros da luva do grafite das próteses.
// Preserva alfa, linhas escuras e os acentos saturados ciano/magenta.
uniform vec3 metal : source_color = vec3(0.68, 0.72, 0.8);

void fragment() {
	vec4 amostra = texture(TEXTURE, UV);
	float maior = max(amostra.r, max(amostra.g, amostra.b));
	float menor = min(amostra.r, min(amostra.g, amostra.b));
	float neutro = 1.0 - smoothstep(0.12, 0.32, maior - menor);
	float claro = smoothstep(0.22, 0.65, dot(amostra.rgb, vec3(0.2126, 0.7152, 0.0722)));
	COLOR *= vec4(mix(vec3(1.0), metal, neutro * claro), 1.0);
}
