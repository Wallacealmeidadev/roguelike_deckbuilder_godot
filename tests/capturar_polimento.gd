extends SceneTree

var jogo: Control
var pasta: String = "res://docs/evidencias_polimento"


func _initialize() -> void:
	call_deferred("_executar")


func _executar() -> void:
	DirAccess.make_dir_recursive_absolute(pasta)
	jogo = (load("res://main.tscn") as PackedScene).instantiate() as Control
	root.add_child(jogo)
	await process_frame
	for resolucao: Vector2i in [Vector2i(1920, 1080), Vector2i(1024, 576)]:
		root.size = resolucao
		jogo.call("_sincronizar_viewport_com_janela")
		for caso: String in ["drone_seguranca", "carga", "guindaste"]:
			jogo.call("_iniciar_combate_por_id", caso, false)
			await create_timer(0.6).timeout
			await _foto("%s_%d" % [caso, resolucao.x])
		jogo.call("_iniciar_combate_por_id", "carga_reparador", false)
		await create_timer(0.5).timeout
		await _foto("dupla_%d" % resolucao.x)
		jogo.call("_iniciar_combate_por_id", "carga", false)
		var jogador: JogadorCombate = jogo.get("jogador_combate") as JogadorCombate
		jogador.reliquias_run.assign(["juntas_retorno", "reservatorio_auxiliar", "mecanismo_recuo"])
		jogo.call("_atualizar_interface")
		jogo.call("_mostrar_inspecao_hud", jogo.get_node("TopoCombate/TopoReliquias").get_child(0))
		await create_timer(0.3).timeout
		await _foto("inspecao_%d" % resolucao.x)
		jogo.get_node("HudInspecao").call("esconder")
		jogo.set("energia", 0)
		jogo.call("_atualizar_interface")
		(jogo.get_node("EncerrarTurno") as Button).grab_focus()
		await create_timer(0.2).timeout
		await _foto("energia_zero_%d" % resolucao.x)
		root.gui_release_focus()
		jogo.get_node("HudInspecao").call("esconder")
		jogo.call("_ao_encerrar_turno")
		await create_timer(0.07).timeout
		await _foto("confirmacao_%d" % resolucao.x)
		jogo.get_node("Alvo/DroneCampoSprite").call("reagir", "ataque")
		await create_timer(0.10).timeout
		await _foto("drone_acao_%d" % resolucao.x)
		jogo.call("_resolver_vitoria")
		await create_timer(0.3).timeout
		var opcao: Button = jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao1") as Button
		opcao.grab_focus()
		await create_timer(0.2).timeout
		await _foto("dica_carta_%d" % resolucao.x)
		root.gui_release_focus()
	jogo.queue_free()
	await process_frame
	quit()


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var caminho: String = "%s/%s.png" % [pasta, nome]
	print("CAPTURA %s: %s" % [caminho, error_string(root.get_texture().get_image().save_png(caminho))])
