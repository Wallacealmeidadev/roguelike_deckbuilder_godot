extends SceneTree

func _initialize() -> void:
	call_deferred("verificar")

func verificar() -> void:
	var cena: PackedScene = load("res://main.tscn")
	var jogo: Node = cena.instantiate()
	root.add_child(jogo)
	await process_frame
	jogo._iniciar_combate_por_id("drone_carga", false)
	if jogo.encontro_combate.inimigos.is_empty():
		jogo._iniciar_combate_por_id("carga", false)
	assert(not jogo.encontro_combate.inimigos.is_empty(), "combate nao foi aberto")

	for tamanho: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		root.size = tamanho
		jogo._sincronizar_viewport_com_janela()
		jogo._layout_hud_combate()
		await process_frame
		await process_frame
		var marcadores: Control = jogo.energia_painel.get_node("MolduraNeon") as Control
		assert(marcadores.get("energia_atual") == jogo.energia)
		assert(marcadores.get("energia_maxima") == jogo.ENERGIA_POR_TURNO)
		assert(jogo.energia_visual_label.text == "%d/%d" % [jogo.energia, jogo.ENERGIA_POR_TURNO])
		var turno_antes: int = jogo.turno
		jogo._mostrar_consulta_pilha("compra")
		assert(jogo.baralho_overlay.visible)
		jogo._fechar_consulta_baralho()
		assert(not jogo.baralho_overlay.visible)
		assert(jogo.turno == turno_antes)
		jogo.topo_configuracoes.pressed.emit()
		assert(jogo.configuracoes_overlay.visible)
		jogo.configuracoes_fechar.pressed.emit()
		assert(not jogo.configuracoes_overlay.visible)
		var viewport: Rect2 = Rect2(Vector2.ZERO, Vector2(tamanho))
		for controle: Control in [jogo.energia_painel, jogo.compra_painel, jogo.descarte_painel, jogo.botao_encerrar_turno, jogo.topo_combate]:
			assert(viewport.encloses(controle.get_global_rect()), "controle fora da tela: " + controle.name)

	jogo._iniciar_combate_por_id("dois_caranguejos", false)
	assert(jogo.encontro_combate.inimigos.size() == 2)
	await process_frame
	await process_frame
	jogo._mostrar_consulta_pilha("compra")
	assert(jogo.baralho_overlay.visible)
	jogo._fechar_consulta_baralho()
	jogo.jogador_combate.energia = 0
	jogo._atualizar_interface()
	assert(jogo.energia_painel.get_node("MolduraNeon").get("energia_atual") == 0)
	var turno: int = jogo.turno
	jogo.botao_encerrar_turno.pressed.emit()
	assert(jogo.turno == turno + 1)
	assert(jogo.energia_painel.get_node("MolduraNeon").get("energia_atual") == jogo.ENERGIA_POR_TURNO)
	print("HUD BASICO OK")
	jogo.queue_free()
	await process_frame
	quit()
