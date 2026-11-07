shader_type canvas_item;
render_mode unshaded;

// Só a pequena aba de pescoço do atlas antigo faz transição sobre a nova
// pele. Rosto/cabelo acima e à direita permanecem com o alfa original.
void fragment() {
	vec2 pixel = UV * vec2(1774.0, 887.0);
	float aba = (1.0 - smoothstep(650.0, 675.0, pixel.x)) * smoothstep(150.0, 182.0, pixel.y);
	COLOR.a *= 1.0 - aba;
}
