shader_type canvas_item;
render_mode unshaded;

// As fontes têm alguns pixels residuais de alfa 1/255 longe da peça.
// Remover só esse piso de ruído no desenho, sem regravar os PNGs.
void fragment() {
	if (COLOR.a <= 2.0 / 255.0) {
		discard;
	}
}
