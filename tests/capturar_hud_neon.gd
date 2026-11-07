extends SceneTree

var jogo: Node


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/evidencias_hud_neon")
	jogo = (load("res://main.tscn") as PackedScene).instantiate()
	root.add_child(jogo)
	root.size = Vector2i(1024, 576)
	await process_frame
	jogo.call("_iniciar_combate_por_id", "drone_carga", false)
	await _mover(Vector2(512.0, 180.0))
	await _foto("combate_1024")
	root.size = Vector2i(1920, 1080)
	jogo.call("_sincronizar_viewport_com_janela")
	jogo.call("_layout_hud_combate")
	await _mover(Vector2(960.0, 240.0))
	await _foto("combate_1920")
	jogo.queue_free()
	await process_frame
	quit()


func _foto(nome: String) -> void:
	await create_timer(0.35).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/evidencias_hud_neon/%s.png" % nome)


func _mover(posicao: Vector2) -> void:
	var evento: InputEventMouseMotion = InputEventMouseMotion.new()
	evento.position = posicao
	evento.global_position = posicao
	root.push_input(evento)
	await process_frame
	jogo.hud_inspecao.esconder()
