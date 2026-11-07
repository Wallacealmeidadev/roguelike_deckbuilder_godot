extends SceneTree
## Prévia da cena real. Avanço fixo dos tweens evita depender do tempo de gravação.
func _initialize() -> void:
	call_deferred("capturar")
func capturar() -> void:
	root.size = Vector2i(640, 640)
	root.content_scale_size = Vector2i(640, 640)
	var fundo := ColorRect.new()
	fundo.color = Color("d7d4cc")
	fundo.size = Vector2(640, 640)
	root.add_child(fundo)
	var vega: Control = load("res://prototipos/vega_2d/vega_animada.tscn").instantiate()
	root.add_child(vega)
	vega.position = Vector2(145, 65)
	vega.size = Vector2(330, 540)
	vega.set_process(false)
	var titulo := Label.new()
	titulo.position = Vector2(24, 14)
	titulo.add_theme_color_override("font_color", Color("1d242a"))
	titulo.add_theme_font_size_override("font_size", 22)
	titulo.text = "VEGA / GUARDA"
	root.add_child(titulo)
	DirAccess.make_dir_recursive_absolute("res://docs/evidencias_guarda/frames")
	await process_frame
	vega.set_process(false)
	for i in 110:
		if i == 20 or i == 75:
			vega.socar()
			titulo.text = "VEGA / SOCO"
		if i == 48 or i == 80:
			vega.receber_dano()
			titulo.text = "VEGA / REAÇÃO AO DANO" if i == 48 else "VEGA / SOCO INTERROMPIDO POR DANO"
		if vega.estado_animacao != "repouso" and vega.movimento and vega.movimento.is_valid():
			vega.movimento.pause()
			vega.movimento.custom_step(0.05)
		else:
			vega._process(0.05)
			titulo.text = "VEGA / GUARDA"
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/evidencias_guarda/frames/%03d.png" % i)
	vega.queue_free()
	fundo.queue_free()
	titulo.queue_free()
	await process_frame
	quit()
