extends SceneTree
## Prancha de inspeção: exibe regiões das fontes sem gerar outra pintura.

func _initialize() -> void:
	_executar.call_deferred()


func _executar() -> void:
	var tela := SubViewport.new()
	tela.size = Vector2i(1320, 510)
	tela.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(tela)
	var fundo := ColorRect.new()
	fundo.size = Vector2(1320, 510)
	fundo.color = Color("18222e")
	tela.add_child(fundo)
	var caminhos: Array[String] = [
		"res://docs/arte_vega/vega_v2_referencia_03.png",
		"res://docs/arte_vega/vega_v2_referencia_04.png",
		"res://vega_animada/combate_v2/base_e_punhos_01.png"]
	var titulos: Array[String] = ["A / Referência 03 — cabelo aprovado", "B / Referência 04 — troca de roupa", "C / Fonte da cabeça usada hoje"]
	var regioes: Array[Rect2] = [Rect2(950, 0, 450, 360), Rect2(950, 0, 450, 360), Rect2(500, 0, 255, 204)]
	for i: int in range(3):
		var titulo := Label.new()
		titulo.text = titulos[i]
		titulo.position = Vector2(20 + i * 440, 20)
		titulo.add_theme_font_size_override("font_size", 19)
		tela.add_child(titulo)
		var sprite := Sprite2D.new()
		sprite.texture = load(caminhos[i]) as Texture2D
		sprite.centered = false
		sprite.region_enabled = true
		sprite.region_rect = regioes[i]
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sprite.scale = Vector2.ONE * (410.0 / regioes[i].size.x)
		sprite.position = Vector2(15 + i * 440, 80)
		tela.add_child(sprite)
	var nota := Label.new()
	nota.text = "Fontes existentes, ampliadas sem redesenho. Ângulos e resolução distintos; comparação de identidade, não de anatomia."
	nota.position = Vector2(20, 458)
	nota.add_theme_font_size_override("font_size", 18)
	tela.add_child(nota)
	await process_frame
	await RenderingServer.frame_post_draw
	var erro: Error = tela.get_texture().get_image().save_png("res://docs/arte_vega/comparacao_identidade_2026_10_25.png")
	print("Comparação de identidade: ", error_string(erro))
	tela.free()
	quit(erro)
