extends Node

@export_enum("recompensa", "foco", "carta_hover", "carta_saida", "brecha_tooltip", "pulso_tooltip", "brecha_mao", "brecha_jogada", "baralho", "pular_hover", "pular_foco", "pular_pressed", "elite", "elite_neutro", "elite_cartas", "elite_cartas_neutro", "evento", "evento_hover", "evento_foco", "evento_resultado") var modo: String = "recompensa"
@export var arquivo_saida: String = "res://docs/evidencias/preview_fluxo.png"
@export var resolucao_captura: Vector2i = Vector2i.ZERO


func _ready() -> void:
	var resolucao: Vector2i = _resolucao_da_linha_de_comando()
	if resolucao == Vector2i.ZERO:
		resolucao = resolucao_captura
	if resolucao != Vector2i.ZERO:
		DisplayServer.window_set_size(resolucao)
		get_window().size = resolucao
		for _frame in range(3):
			await get_tree().process_frame
	var jogo: Node = (load("res://main.tscn") as PackedScene).instantiate()
	add_child(jogo)
	await get_tree().process_frame
	# A cena principal começa no mapa; os previews entram no estado pedido abaixo.
	if modo == "brecha_mao" or modo == "brecha_jogada":
		jogo.call("_ao_selecionar_no_mapa", "inicio")
	if modo == "evento" or modo == "evento_hover" or modo == "evento_foco" or modo == "evento_resultado":
		jogo.call("_mostrar_evento", "fiscalizacao_corporativa")
		if modo == "evento_hover":
			var opcao_hover: Control = jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao3") as Control
			var centro_viewport: Vector2 = opcao_hover.get_global_rect().get_center()
			var escala_janela: Vector2 = Vector2(get_window().size) / get_viewport().get_visible_rect().size
			DisplayServer.warp_mouse(centro_viewport * escala_janela)
			await get_tree().process_frame
		elif modo == "evento_foco":
			(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao2") as Control).grab_focus()
		elif modo == "evento_resultado":
			jogo.call("_ao_escolher_evento", 0)
	elif modo == "elite" or modo == "elite_neutro" or modo == "elite_cartas" or modo == "elite_cartas_neutro":
		jogo.call("_mostrar_recompensa_elite")
		if modo == "elite_cartas" or modo == "elite_cartas_neutro":
			await get_tree().process_frame
			var id_reliquia: String = (jogo.get("oferta_reliquias") as OfertaRecompensa).opcoes[0]
			jogo.call("_escolher_recompensa_elite_reliquia", id_reliquia)
		if modo == "elite_neutro" or modo == "elite_cartas_neutro":
			get_viewport().gui_release_focus()
			get_viewport().warp_mouse(Vector2(8.0, 8.0))
			await get_tree().process_frame
	elif modo == "brecha_mao" or modo == "brecha_jogada":
		jogo.call("_resolver_vitoria")
		await get_tree().process_frame
		_configurar_oferta_conhecida(jogo, true)
		jogo.call("_ao_clicar_recompensa", 1)
		await get_tree().process_frame
		var baralho_deterministico: Array[String] = ["brecha", "brecha", "brecha", "brecha", "brecha", "brecha"]
		jogo.set("baralho_run", baralho_deterministico)
		jogo.call("_mostrar_evento", "valvula_vapor_contaminado")
		jogo.call("_ao_escolher_evento", 0)
		await get_tree().process_frame
		await get_tree().create_timer(0.3).timeout
		var brecha_mao: Button = null
		for no in (jogo.get_node("Mao") as Control).get_children():
			var carta: Button = no as Button
			if carta != null and str(carta.get_meta("id_carta", "")) == "brecha":
				brecha_mao = carta
				break
		if brecha_mao != null and modo == "brecha_jogada":
			brecha_mao.button_pressed = true
			jogo.call("_ao_clicar_no_alvo")
	else:
		# Usa a mesma fronteira de vitória do combate; a cena não injeta a tela diretamente.
		jogo.call("_resolver_vitoria")
		await get_tree().process_frame
		if modo == "foco":
			(jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao1") as Control).grab_focus()
		elif modo == "carta_hover" or modo == "carta_saida":
			var carta_mouse: Button = jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao2") as Button
			get_viewport().warp_mouse(carta_mouse.get_global_rect().get_center())
			await get_tree().process_frame
			if modo == "carta_saida":
				get_viewport().warp_mouse(Vector2(20.0, 20.0))
				await get_tree().create_timer(0.2).timeout
		elif modo == "brecha_tooltip" or modo == "pulso_tooltip":
			_configurar_oferta_conhecida(jogo, modo == "brecha_tooltip")
			var carta_palavra_chave: Button = jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao2") as Button
			get_viewport().warp_mouse(carta_palavra_chave.get_global_rect().get_center())
			await get_tree().process_frame
		elif modo == "baralho":
			jogo.call("_mostrar_consulta_baralho")
		elif modo == "pular_hover":
			var pular_hover: Button = jogo.get_node("Recompensas/RecompensaAcoes/Pular") as Button
			get_viewport().warp_mouse(pular_hover.get_global_rect().get_center())
			await get_tree().process_frame
		elif modo == "pular_foco":
			(jogo.get_node("Recompensas/RecompensaAcoes/Pular") as Control).grab_focus()
		elif modo == "pular_pressed":
			var pular: Button = jogo.get_node("Recompensas/RecompensaAcoes/Pular") as Button
			pular.grab_focus()
			pular.set_pressed_no_signal(true)
	await get_tree().create_timer(0.35).timeout
	print("PREVIEW viewport=%s janela=%s" % [get_viewport().get_visible_rect().size, get_window().size])
	get_viewport().get_texture().get_image().save_png(arquivo_saida)
	get_tree().quit(0)


func _resolucao_da_linha_de_comando() -> Vector2i:
	var argumentos: PackedStringArray = OS.get_cmdline_args()
	var indice: int = argumentos.find("--resolution")
	if indice < 0 or indice + 1 >= argumentos.size():
		return Vector2i.ZERO
	var partes: PackedStringArray = argumentos[indice + 1].split("x")
	if partes.size() != 2:
		return Vector2i.ZERO
	return Vector2i(int(partes[0]), int(partes[1]))


func _configurar_oferta_conhecida(jogo: Node, brecha: bool) -> void:
	var ids: Array[String] = []
	if brecha:
		ids = ["protecao", "brecha", "golpe"]
	else:
		ids = ["golpe", "pulso_debilitante", "protecao"]
	var oferta: OfertaRecompensa = jogo.get("oferta_recompensa") as OfertaRecompensa
	var opcoes_sincronizadas: Array[String] = ids.duplicate()
	oferta.opcoes = opcoes_sincronizadas
	for indice in range(ids.size()):
		var id_carta: String = ids[indice]
		var carta: Button = jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao%d" % (indice + 1)) as Button
		var dados: Dictionary = (jogo.get("CARTAS") as Dictionary)[id_carta]
		carta.set("nome_carta", dados["nome"])
		carta.set("custo", dados["custo"])
		carta.set("descricao", str(jogo.call("_descricao_recompensa", dados)))
		carta.call("aplicar_visual", id_carta, str(dados.get("tipo", "ataque")))
		carta.call("configurar_escala", jogo.call("_escala_recompensa"))
		carta.call("configurar_recompensa", str(jogo.call("_tooltip_recompensa", dados)))
