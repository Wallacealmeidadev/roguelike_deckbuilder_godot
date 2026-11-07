extends SceneTree

var jogo: Control


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/evidencias_hud_compacto")
	jogo = (load("res://main.tscn") as PackedScene).instantiate() as Control
	root.add_child(jogo)
	await process_frame
	for resolucao: Vector2i in [Vector2i(1920, 1080), Vector2i(1024, 576)]:
		root.size = resolucao
		jogo.call("_iniciar_combate_por_id", "carga", false)
		jogo.call("_sincronizar_viewport_com_janela")
		var jogador: JogadorCombate = jogo.get("jogador_combate") as JogadorCombate
		jogador.reliquias_run.assign(["juntas_retorno", "reservatorio_auxiliar", "mecanismo_recuo"])
		for quantidade: int in [6, 10]:
			jogo.call("_limpar_mao")
			var cartas: Array[String] = ["golpe", "protecao", "direto_hidraulico", "quebra_chassi"]
			for indice: int in quantidade:
				jogo.call("_criar_carta_na_mao", cartas[indice % cartas.size()])
			jogo.call("_atualizar_interface")
			var mouse: InputEventMouseMotion = InputEventMouseMotion.new()
			mouse.position = Vector2(5, 5)
			root.push_input(mouse, true)
			root.gui_release_focus()
			await create_timer(0.5).timeout
			await _foto("mao_%d_%d" % [quantidade, resolucao.x])
			var mao: Control = jogo.get_node("Mao") as Control
			(mao.get_child(quantidade - 1) as Button).grab_focus()
			await create_timer(0.25).timeout
			await _foto("foco_%d_%d" % [quantidade, resolucao.x])
			root.gui_release_focus()
		jogo.call("_mostrar_inspecao_hud", jogo.get_node("TopoCombate/TopoReliquias").get_child(0))
		await create_timer(0.25).timeout
		await _foto("reliquia_%d" % resolucao.x)
		jogo.get_node("HudInspecao").call("esconder")
		var inimigo: InimigoCombate = jogo.get("estado_inimigo") as InimigoCombate
		inimigo.barreira = 7
		jogo.set("exposto_inimigo", 2)
		jogo.set("enfraquecido_inimigo", 1)
		jogo.call("_atualizar_interface")
		await create_timer(0.3).timeout
		await _foto("estados_%d" % resolucao.x)
		jogo.call("_iniciar_combate_por_id", "unidade_contencao_portuaria", false)
		jogo.call("_atualizar_interface")
		await create_timer(0.4).timeout
		await _foto("preparacao_%d" % resolucao.x)
		jogo.call("_iniciar_combate_por_id", "carga_reparador", false)
		jogo.call("_atualizar_interface")
		await create_timer(0.5).timeout
		await _foto("multiplo_%d" % resolucao.x)
		for caso: Array in [["sentinela", 1], ["guindaste", 3]]:
			jogo.call("_iniciar_combate_por_id", caso[0], false)
			for indice: int in int(caso[1]):
				jogo.call("_executar_intencao_inimigo")
			jogo.call("_atualizar_interface")
			await create_timer(0.4).timeout
			await _foto("%s_%d" % [caso[0], resolucao.x])
	jogo.queue_free()
	await process_frame
	quit()


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var caminho: String = "res://docs/evidencias_hud_compacto/%s.png" % nome
	print("CAPTURA %s: %s" % [caminho, error_string(root.get_texture().get_image().save_png(caminho))])
