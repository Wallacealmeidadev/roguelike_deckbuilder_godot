extends SceneTree


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/evidencias_run_neon")
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		root.size = resolucao
		root.content_scale_size = resolucao
		await process_frame
		var jogo: Node = (load("res://main.tscn") as PackedScene).instantiate()
		root.add_child(jogo)
		await create_timer(0.35).timeout
		await _foto("mapa", resolucao)
		jogo.call("_ao_selecionar_no_mapa", "inicio")
		await process_frame
		jogo.call("_mostrar_recompensas")
		await create_timer(0.35).timeout
		await _foto("recompensa", resolucao)
		jogo.call("_ao_pular_recompensa")
		await process_frame
		jogo.call("_ao_selecionar_no_mapa", "evento_cais")
		await create_timer(0.35).timeout
		await _foto("evento", resolucao)
		jogo.call("_ocultar_evento")
		jogo.call("_mostrar_recompensa_elite")
		await create_timer(0.35).timeout
		await _foto("elite", resolucao)
		var primeira_reliquia: String = (jogo.get("oferta_reliquias") as OfertaRecompensa).opcoes[0]
		jogo.call("_escolher_recompensa_elite_reliquia", primeira_reliquia)
		await create_timer(0.35).timeout
		await _foto("elite_cartas", resolucao)
		jogo.call("_ocultar_recompensa_elite")
		jogo.set("vida_jogador", 30)
		jogo.call("_mostrar_descanso")
		await create_timer(0.35).timeout
		await _foto("descanso", resolucao)
		jogo.set("vida_jogador", 0)
		jogo.call("_mostrar_resultado")
		await create_timer(0.35).timeout
		await _foto("derrota", resolucao)
		jogo.set("vida_jogador", 1)
		jogo.set("mapa_no_em_andamento", "lastro")
		jogo.call("_resolver_vitoria")
		await create_timer(0.35).timeout
		await _foto("boss_provisorio", resolucao)
		jogo.queue_free()
		await process_frame
	quit(0)


func _foto(nome: String, resolucao: Vector2i) -> void:
	await RenderingServer.frame_post_draw
	var arquivo: String = "res://docs/evidencias_run_neon/%s_%dx%d.png" % [nome, resolucao.x, resolucao.y]
	root.get_texture().get_image().save_png(arquivo)
