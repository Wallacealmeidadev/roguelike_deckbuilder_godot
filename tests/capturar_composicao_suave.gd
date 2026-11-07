extends SceneTree

var jogo: Node


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/evidencias_composicao_suave")
	root.size = Vector2i(1920, 1080)
	jogo = (load("res://main.tscn") as PackedScene).instantiate()
	root.add_child(jogo)
	await process_frame
	jogo.call("_iniciar_combate_por_id", "drone_carga", false)
	jogo.call("_sincronizar_viewport_com_janela")
	jogo.set("barreira", 12)
	jogo.set("combo", 1)
	jogo.set("energia", 3)
	jogo.call("_atualizar_interface")
	await create_timer(0.32).timeout
	await _foto("recursos_1920")
	jogo.call("_limpar_mao")
	jogo.call("_criar_carta_na_mao", "golpe")
	await process_frame
	var carta: Button = (jogo.get_node("Mao") as Control).get_child(0) as Button
	carta.button_pressed = true
	await create_timer(0.18).timeout
	await _foto("carta_selecionada_1920")
	(jogo.get_node("Alvo") as Button).pressed.emit()
	await create_timer(0.08).timeout
	await _foto("carta_em_voo_1920")
	await create_timer(0.26).timeout
	await _foto("apos_impacto_1920")
	root.size = Vector2i(1024, 576)
	jogo.call("_sincronizar_viewport_com_janela")
	jogo.call("_layout_hud_combate")
	await create_timer(0.16).timeout
	await _foto("composicao_1024")
	jogo.call("_mostrar_inspecao_hud", jogo.get_node("TopoCombate/TopoRota"))
	await process_frame
	await _foto("rota_1024")
	jogo.queue_free()
	await process_frame
	quit()


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var caminho: String = "res://docs/evidencias_composicao_suave/%s.png" % nome
	var erro: Error = root.get_texture().get_image().save_png(caminho)
	print("CAPTURA %s: %s" % [caminho, error_string(erro)])
