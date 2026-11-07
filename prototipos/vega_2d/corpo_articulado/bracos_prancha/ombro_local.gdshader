shader_type canvas_item;
render_mode unshaded;

uniform sampler2D ombro_editado : source_color, filter_linear_mipmap, repeat_disable;
varying vec4 cor_vertice;

void vertex() {
	cor_vertice = COLOR;
}

void fragment() {
	vec2 ponto = UV / TEXTURE_PIXEL_SIZE;
	// Só ombro próximo/axila. A regata, peito, pescoço e distante usam o original.
	float local = (1.0 - smoothstep(295.0, 325.0, ponto.x))
		* smoothstep(190.0, 215.0, ponto.y)
		* (1.0 - smoothstep(455.0, 480.0, ponto.y));
	vec4 original = texture(TEXTURE, UV);
	vec4 editado = texture(ombro_editado, UV);
	COLOR = mix(original, editado, local) * cor_vertice;
	if (COLOR.a <= 2.0 / 255.0) {
		discard;
	}
}
