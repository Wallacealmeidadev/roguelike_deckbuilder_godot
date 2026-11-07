extends SceneTree

var jogo: Node


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/evidencias_shell_neon")
	jogo = (load("res://main.tscn") as PackedScene).instantiate()
	root.add_child(jogo)
	root.size = Vector2i(1024, 576)
	await process_frame
	jogo.call("_iniciar_combate_por_id", "drone_carga", false)
	await create_timer(0.3).timeout
	await _foto("combate_1024")
	jogo.call("_mostrar_consulta_pilha", "compra")
	await _foto("baralho_1024")
	jogo.call("_fechar_consulta_baralho")
	jogo.call("_abrir_configuracoes")
	await _foto("configuracoes_1024")
	jogo.call("_fechar_configuracoes")
	root.size = Vector2i(1920, 1080)
	jogo.call("_sincronizar_viewport_com_janela")
	jogo.call("_layout_hud_combate")
	await create_timer(0.3).timeout
	await _foto("combate_1920")
	var compra: Array[String] = ["direto_hidraulico"]
	jogo.baralho_combate.compra.assign(compra)
	jogo.call("_comprar_cartas", 1)
	for carta: Button in jogo.mao.get_children():
		if str(carta.get_meta("id_carta")) == "direto_hidraulico":
			carta.button_pressed = true
			jogo.call("_jogar_carta", "inimigo", 0)
			break
	await create_timer(0.06).timeout
	await _foto("acao_1920")
	jogo.call("_iniciar_combate_por_id", "dois_caranguejos", false)
	await create_timer(0.3).timeout
	await _foto("dupla_1920")
	jogo.queue_free()
	await process_frame
	quit()


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var caminho: String = "res://docs/evidencias_shell_neon/%s.png" % nome
	var erro: Error = root.get_texture().get_image().save_png(caminho)
	print("CAPTURA %s: %s" % [caminho, error_string(erro)])
