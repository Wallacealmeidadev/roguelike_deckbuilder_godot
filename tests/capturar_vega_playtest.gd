extends SceneTree


func _initialize() -> void:
	call_deferred("capturar")


func capturar() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	root.add_child(jogo)
	for tamanho: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		root.size = tamanho
		jogo._sincronizar_viewport_com_janela()
		jogo._layout_hud_combate()
		jogo._iniciar_combate_por_id("drone_carga", false)
		await create_timer(0.5).timeout
		await RenderingServer.frame_post_draw
		var imagem: Image = root.get_texture().get_image()
		var caminho: String = "res://docs/evidencias_vega/playtest_estatico_%d.png" % tamanho.x
		var erro: Error = imagem.save_png(caminho)
		if erro != OK:
			push_error("Falha ao salvar captura: %s" % caminho)
			quit(1)
			return
		print("CAPTURA: %s %s" % [caminho, imagem.get_size()])
	jogo.queue_free()
	await process_frame
	quit(0)
