extends SceneTree
var falhas: int = 0
func _initialize() -> void:
	call_deferred("verificar")
func conferir(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error(mensagem)
func verificar() -> void:
	var jogo = load("res://main.tscn").instantiate()
	root.add_child(jogo)
	root.size = Vector2i(1024, 576)
	await process_frame
	jogo._iniciar_combate_por_id("drone_carga", false)
	jogo._mostrar_inspecao_hud(jogo.energia_painel)
	await process_frame
	conferir(jogo.hud_inspecao.visible, "Tooltip nÃ£o abre")
	var cor: Color = jogo.hud_inspecao.texto.get_theme_color("font_color")
	conferir(cor.get_luminance() > 0.6, "Texto do tooltip escuro sobre fundo escuro")
	conferir(jogo.hud_inspecao.texto.text.contains("4/4"), "Tooltip nÃ£o mostra Energia real")
	jogo.jogador_combate.energia = 2
	jogo._atualizar_interface()
	conferir(jogo.hud_inspecao.texto.text.contains("2/4"), "Tooltip ficou desatualizado durante hover")
	jogo.jogador_combate.energia = 4
	jogo._atualizar_interface()
	for botao: Button in [jogo.topo_baralho, jogo.topo_rota, jogo.topo_configuracoes, jogo.botao_encerrar_turno]:
		for estado: String in ["font_hover_color", "font_focus_color", "font_pressed_color"]:
			conferir(botao.get_theme_color(estado).get_luminance() > 0.6, "Texto ilegÃ­vel no estado " + estado + ": " + botao.name)
	# Repetir atualizaÃ§Ã£o nÃ£o pode destruir o botÃ£o atualmente inspecionado.
	var reliquia: Button = jogo.topo_reliquias.get_child(0)
	var id_antes: int = reliquia.get_instance_id()
	reliquia.grab_focus()
	jogo._atualizar_interface()
	conferir(is_instance_valid(reliquia), "Atualizar recursos destruiu relÃ­quia focada")
	conferir(jogo.topo_reliquias.get_child(0).get_instance_id() == id_antes, "RelÃ­quia foi recriada sem mudar o inventÃ¡rio")
	jogo.hud_inspecao.esconder()
	jogo._abrir_configuracoes()
	jogo._mostrar_inspecao_hud(jogo.energia_painel)
	conferir(not jogo.hud_inspecao.visible, "Hover vazou por trÃ¡s do modal")
	jogo._fechar_configuracoes()
	# Mouse real pela Ã¡rvore de GUI, sem emitir mouse_entered manualmente.
	root.gui_release_focus()
	var mover: InputEventMouseMotion = InputEventMouseMotion.new()
	mover.position = jogo.energia_painel.get_global_rect().get_center()
	mover.global_position = mover.position
	root.push_input(mover)
	await process_frame
	await process_frame
	conferir(jogo.hud_inspecao.visible, "Movimento do mouse nÃ£o abriu tooltip")
	conferir(jogo.hud_inspecao.controle_atual == jogo.energia_painel, "Hover atingiu camada errada")
	mover = InputEventMouseMotion.new()
	mover.position = Vector2(600, 190)
	mover.global_position = mover.position
	root.push_input(mover)
	await process_frame
	conferir(not jogo.hud_inspecao.visible, "Tooltip nÃ£o fechou ao sair")
	for controle: Control in [jogo.compra_painel, jogo.descarte_painel, jogo.barreira_icone, jogo.combo_icone, jogo.topo_rota, jogo.topo_baralho, jogo.topo_configuracoes, jogo.topo_reliquias.get_child(0)]:
		mover = InputEventMouseMotion.new()
		mover.position = controle.get_global_rect().get_center()
		mover.global_position = mover.position
		root.push_input(mover)
		await process_frame
		await process_frame
		conferir(jogo.hud_inspecao.visible and jogo.hud_inspecao.controle_atual == controle, "Hover real falhou em " + controle.name)
	conferir(jogo.hud_inspecao.position.y >= jogo.topo_combate.get_global_rect().end.y, "Tooltip de relÃ­quia sobrepÃ´s a barra superior")
	var encerrar: Button = jogo.botao_encerrar_turno
	encerrar.grab_focus()
	await create_timer(0.2).timeout
	conferir(encerrar.get_node("RealceNeon").intensidade > 0.95, "Realce animado nÃ£o atingiu o estado de foco")
	encerrar.disabled = true
	jogo._atualizar_destaque_hud(encerrar)
	await create_timer(0.2).timeout
	conferir(encerrar.get_node("RealceNeon").intensidade < 0.05, "BotÃ£o desabilitado manteve realce ativo")
	print("HOVER HQ: %d falhas" % falhas)
	jogo.queue_free()
	await process_frame
	quit(1 if falhas else 0)


