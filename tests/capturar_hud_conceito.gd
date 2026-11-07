extends SceneTree

var jogo: Node


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/evidencias_hud_conceito")
	jogo = (load("res://main.tscn") as PackedScene).instantiate()
	root.add_child(jogo)
	root.size = Vector2i(1024, 576)
	await process_frame
	jogo.call("_iniciar_combate_por_id", "drone_carga", false)
	await create_timer(0.3).timeout
	await _foto("combate_1024")
	jogo.call("_iniciar_combate_por_id", "dois_caranguejos", false)
	await create_timer(0.3).timeout
	await _foto("dupla_1024")
	jogo.call("_iniciar_combate_por_id", "drone_carga", false)
	root.size = Vector2i(1920, 1080)
	jogo.call("_sincronizar_viewport_com_janela")
	jogo.call("_layout_hud_combate")
	await create_timer(0.3).timeout
	await _foto("combate_1920")
	jogo.call("_iniciar_combate_por_id", "dois_caranguejos", false)
	await create_timer(0.3).timeout
	await _foto("dupla_1920")
	jogo.queue_free()
	await process_frame
	quit()


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var caminho: String = "res://docs/evidencias_hud_conceito/%s.png" % nome
	var erro: Error = root.get_texture().get_image().save_png(caminho)
	print("CAPTURA %s: %s" % [caminho, error_string(erro)])
