extends SceneTree

var jogo: Control


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/evidencias_mira_carta")
	root.size = Vector2i(1920, 1080)
	jogo = (load("res://main.tscn") as PackedScene).instantiate() as Control
	root.add_child(jogo)
	await process_frame
	jogo.call("_iniciar_combate_por_id", "caranguejo_sucata", false)
	jogo.set_process(false)
	jogo.call("_sincronizar_viewport_com_janela")
	_preparar_mao()
	await create_timer(0.6).timeout
	await _foto("repouso_1920")
	var carta: Button = jogo.get_node("Mao").get_child(2) as Button
	carta.button_pressed = true
	await create_timer(0.2).timeout
	var sprite: Control = jogo.get_node("Alvo/DroneCampoSprite") as Control
	jogo.call("_atualizar_mira_carta", sprite.get_global_rect().get_center())
	await _foto("mira_1920")
	(jogo.get_node("Alvo") as Button).pressed.emit()
	await create_timer(0.06).timeout
	await _foto("confirmacao_1920")
	await create_timer(0.5).timeout
	root.size = Vector2i(1024, 576)
	jogo.call("_sincronizar_viewport_com_janela")
	jogo.call("_layout_hud_combate")
	_preparar_mao()
	await create_timer(0.3).timeout
	await _foto("repouso_1024")
	carta = jogo.get_node("Mao").get_child(0) as Button
	carta.button_pressed = true
	await create_timer(0.2).timeout
	jogo.call("_atualizar_mira_carta", (jogo.get_node("Jogador") as Control).get_global_rect().get_center())
	await _foto("protecao_1024")
	jogo.call("_iniciar_combate_por_id", "dois_caranguejos", false)
	_preparar_mao()
	await create_timer(0.3).timeout
	carta = jogo.get_node("Mao").get_child(2) as Button
	carta.button_pressed = true
	await create_timer(0.2).timeout
	sprite = jogo.get_node("AlvoMultiplo2/DroneCampoSprite") as Control
	jogo.call("_atualizar_mira_carta", sprite.get_global_rect().get_center())
	await _foto("mira_dupla_1024")
	jogo.queue_free()
	await process_frame
	quit()


func _preparar_mao() -> void:
	jogo.call("_limpar_mao")
	for id_carta: String in ["protecao", "direto_hidraulico", "golpe", "protecao", "quebra_chassi", "golpe"]:
		jogo.call("_criar_carta_na_mao", id_carta)
	jogo.call("_atualizar_interface")


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var caminho: String = "res://docs/evidencias_mira_carta/%s.png" % nome
	var erro: Error = root.get_texture().get_image().save_png(caminho)
	print("CAPTURA %s: %s" % [caminho, error_string(erro)])
