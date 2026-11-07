extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	get_window().size = Vector2i(1024, 576)
	get_window().content_scale_size = Vector2i(1024, 576)
	var jogo: Node = (load("res://main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame

	_verificar(jogo.has_method("_transicionar_para_overlay"), "recompensa precisa de transicao de entrada")
	jogo.call("_resolver_vitoria")
	var recompensas: Control = jogo.get_node("Recompensas") as Control
	_verificar(recompensas.visible, "recompensa comum fica visivel apos a vitoria")
	_verificar(not (jogo.get_node("RecompensaPainel") as Control).visible, "recompensa nao deve usar painel gigante")
	var opcao: Button = jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao1") as Button
	_verificar(opcao.has_method("aplicar_visual"), "opcao comum precisa ser uma carta compartilhada")
	_verificar(opcao.custom_minimum_size.x >= 200.0, "carta de recompensa precisa ser maior que a carta da mao")
	_verificar(opcao.get_node("NomeLabel").visible, "carta de recompensa precisa mostrar o nome")
	_verificar(not (opcao.get_node("DescricaoLabel") as Label).text.is_empty(), "carta de recompensa precisa mostrar o efeito")
	_verificar(opcao.has_node("DescricaoBalao"), "opcao de recompensa precisa de balao de descricao")
	_verificar(opcao.get_node("DescricaoBalao") is PanelContainer, "tooltip precisa usar PanelContainer")
	_verificar(opcao.has_method("configurar_recompensa"), "carta precisa configurar o detalhe complementar")
	_verificar(not opcao.button_pressed, "recompensa nao deve iniciar selecionada")
	_verificar(not (opcao.get_node("SelecaoLabel") as Control).visible, "recompensa nao deve mostrar SELECIONADA")
	var detalhe_layout: String = (opcao.get_node("DescricaoBalao/BalaoTexto") as Label).text
	var texto_layout: Label = opcao.get_node("DescricaoBalao/BalaoTexto") as Label
	texto_layout.text = "Exposto."
	opcao.call("_dimensionar_balao")
	await get_tree().process_frame
	var altura_uma_layout: float = (opcao.get_node("DescricaoBalao") as Control).size.y
	texto_layout.text = "Enfraquecido.\nBarreira."
	opcao.call("_dimensionar_balao")
	await get_tree().process_frame
	var altura_duas_layout: float = (opcao.get_node("DescricaoBalao") as Control).size.y
	_verificar(altura_duas_layout > altura_uma_layout, "duas palavras-chave precisam aumentar a altura do tooltip")
	_verificar((opcao.get_node("DescricaoBalao") as Control).get_global_rect().encloses(texto_layout.get_global_rect()), "texto do tooltip precisa permanecer dentro do fundo")
	opcao.call("configurar_recompensa", detalhe_layout)
	opcao.grab_focus()
	await get_tree().process_frame
	_verificar((opcao.get_node("DescricaoBalao") as Control).visible, "hover da recompensa mostra o balao")
	_verificar(opcao.visible, "hover nao pode fazer a recompensa desaparecer")
	_verificar((opcao.get_node("NomeLabel") as Label).visible, "foco nao pode cobrir o nome")
	_verificar((opcao.get_node("CustoLabel") as Label).visible, "foco nao pode cobrir o custo")
	_verificar((opcao.get_node("DescricaoLabel") as Label).visible, "foco nao pode cobrir o efeito")
	_verificar(not (opcao.get_node("DescricaoLabel") as Label).text.contains("Custo"), "custo nao deve ser repetido na descricao")
	_verificar((opcao.get_node("DescricaoBalao/BalaoTexto") as Label).text != (opcao.get_node("DescricaoLabel") as Label).text, "tooltip deve complementar a descricao visivel")
	var detalhe_original: String = (opcao.get_node("DescricaoBalao/BalaoTexto") as Label).text
	var balao_texto: Label = opcao.get_node("DescricaoBalao/BalaoTexto") as Label
	balao_texto.text = "Exposto: os próximos golpes recebem dano adicional."
	opcao.call("_dimensionar_balao")
	var altura_uma_palavra_chave: float = (opcao.get_node("DescricaoBalao") as Control).size.y
	balao_texto.text = "Enfraquecido: reduz os próximos golpes inimigos.\nBarreira: absorve dano até ser consumida."
	opcao.call("_dimensionar_balao")
	var altura_duas_palavras_chave: float = (opcao.get_node("DescricaoBalao") as Control).size.y
	_verificar(altura_duas_palavras_chave > altura_uma_palavra_chave, "duas palavras-chave precisam aumentar a altura do tooltip")
	_verificar((opcao.get_node("DescricaoBalao") as Control).get_global_rect().encloses(balao_texto.get_global_rect()), "texto do tooltip precisa permanecer dentro do fundo")
	var imagem_foco: Image = ((opcao.get_node("Foco") as TextureRect).texture as Texture2D).get_image()
	_verificar(imagem_foco.get_pixel(imagem_foco.get_width() / 2, imagem_foco.get_height() / 2).a < 0.1, "foco deve ser apenas contorno, sem cobrir o conteudo")
	var estilo_foco: StyleBoxFlat = opcao.get_theme_stylebox("focus") as StyleBoxFlat
	_verificar(estilo_foco != null and is_zero_approx(estilo_foco.bg_color.a), "foco do tema precisa manter o fundo transparente")
	var escala_normal: float = opcao.scale.x
	var vizinha: Button = jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao2") as Button
	var posicao_vizinha: Vector2 = vizinha.position
	opcao.call("_ao_entrar")
	await get_tree().process_frame
	_verificar(opcao.visible and opcao.scale.x > escala_normal, "hover deve elevar a carta sem remove-la")
	_verificar(get_viewport().get_visible_rect().encloses((opcao.get_node("DescricaoBalao") as Control).get_global_rect()), "tooltip precisa permanecer dentro da viewport")
	_verificar(vizinha.position.is_equal_approx(posicao_vizinha), "hover nao deve reposicionar cartas vizinhas")
	_verificar(not (opcao.get_node("SelecaoLabel") as Control).visible, "hover nao deve ativar SELECIONADA")
	verificar_nao_cobre_informacao_vizinha(opcao, vizinha)
	opcao.call("_ao_sair")
	vizinha.call("_ao_entrar")
	await get_tree().process_frame
	_verificar(not (opcao.get_node("DescricaoBalao") as Control).visible, "mover o mouse deve fechar o tooltip da carta anterior")
	_verificar((vizinha.get_node("DescricaoBalao") as Control).visible, "mover o mouse deve mostrar somente o tooltip da carta atual")
	_verificar(not (vizinha.get_node("DescricaoBalao") as Control).get_global_rect().intersects(opcao.get_global_rect()), "tooltip deve preservar também a ilustração da carta vizinha")
	_verificar((vizinha.get_node("DescricaoBalao/BalaoTexto") as Label).get_theme_color("font_color").get_luminance() > 0.8, "tooltip neon deve usar texto claro")
	_verificar(not (vizinha.get_node("DescricaoBalao/BalaoPonta") as CanvasItem).visible, "tooltip não deve manter a ponta do balão branco")
	vizinha.call("_ao_sair")
	opcao.call("_ao_sair")
	opcao.release_focus()
	_get_viewport_release_focus()
	opcao.call("_atualizar_transformacao")
	await get_tree().create_timer(0.18).timeout
	_verificar(not (opcao.get_node("DescricaoBalao") as Control).visible, "sair do grupo deve fechar o tooltip")
	_verificar(is_zero_approx(opcao.scale.x - 1.0), "sair do grupo deve restaurar a escala")
	opcao.set_pressed_no_signal(true)
	opcao.call("_ao_alternar", true)
	_verificar(not opcao.button_pressed and not (opcao.get_node("SelecaoLabel") as Control).visible, "modo recompensa deve ignorar selecao visual do combate")
	for indice in range(3):
		var carta_mouse: Button = jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao%d" % (indice + 1)) as Button
		carta_mouse.call("_ao_entrar")
		await get_tree().process_frame
		_verificar(not (carta_mouse.get_node("SelecaoLabel") as Control).visible, "hover nao deve mostrar SELECIONADA em nenhuma carta")
		_verificar((carta_mouse.get_node("DescricaoBalao") as Control).visible, "hover deve acompanhar cada carta")
		carta_mouse.call("_ao_sair")
	for indice in range(3):
		var carta: Button = jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao%d" % (indice + 1)) as Button
		_verificar((carta.get_node("Arte") as TextureRect).texture != null, "toda carta de recompensa precisa de arte")
	var pular: Button = jogo.get_node("Recompensas/RecompensaAcoes/Pular") as Button
	_verificar(pular.text == "Pular recompensa", "botao de pular precisa manter o rotulo legivel")
	_verificar(pular.get_theme_stylebox("hover") == pular.get_theme_stylebox("normal"), "hover do pular nao deve sobrepor a moldura normal")
	var foco_pular: StyleBoxFlat = pular.get_theme_stylebox("focus") as StyleBoxFlat
	_verificar(foco_pular != null and is_zero_approx(foco_pular.bg_color.a), "foco do pular deve ser transparente")
	_verificar((jogo.get_node("Recompensas/RecompensaAcoes/ConsultarBaralho") as Control).visible, "recompensa precisa oferecer consulta do baralho")
	(jogo.get_node("Recompensas/RecompensaAcoes/ConsultarBaralho") as Button).pressed.emit()
	await get_tree().process_frame
	_verificar((jogo.get_node("BaralhoOverlay") as Control).visible, "consulta do baralho abre um painel")
	_verificar((jogo.get_node("BaralhoScrim") as Control).visible, "consulta do baralho escurece a recompensa")
	var modal: Control = jogo.get_node("BaralhoOverlay") as Control
	var fechar: Control = jogo.get_node("BaralhoOverlay/BaralhoFechar") as Control
	_verificar(modal.get_global_rect().encloses(fechar.get_global_rect()), "fechar deve ficar dentro do modal")
	_verificar((jogo.get_node("Recompensas") as Control).visible, "consulta preserva a oferta de recompensa")
	_verificar((jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao1") as Button).disabled, "consulta bloqueia as cartas da recompensa")
	(jogo.get_node("BaralhoOverlay/BaralhoFechar") as Button).pressed.emit()
	await get_tree().process_frame
	_verificar(not (jogo.get_node("BaralhoOverlay") as Control).visible, "consulta fecha sem avancar a recompensa")
	_verificar(not (jogo.get_node("BaralhoScrim") as Control).visible, "fechar consulta restaura o fundo")
	_verificar(not (jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao1") as Button).disabled, "fechar consulta restaura a interacao")

	var preview_helper: Node = Node.new()
	preview_helper.set_script(load("res://tests/preview_fluxo.gd"))
	preview_helper.call("_configurar_oferta_conhecida", jogo, true)
	var oferta_preview: RefCounted = jogo.get("oferta_recompensa") as RefCounted
	_verificar(oferta_preview.opcoes == ["protecao", "brecha", "golpe"], "preview precisa sincronizar as opcoes da oferta")
	for brecha in [true, false]:
		preview_helper.call("_configurar_oferta_conhecida", jogo, brecha)
		for indice in range(3):
			var carta_posicao: Button = jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao%d" % (indice + 1)) as Button
			carta_posicao.call("_ao_sair")
			carta_posicao.release_focus()
			_get_viewport_release_focus()
			carta_posicao.call("_ao_entrar")
			await get_tree().process_frame
			await get_tree().create_timer(0.2).timeout
			_verificar((carta_posicao.get_node("DescricaoBalao") as Control).visible, "tooltip precisa aparecer nas tres posicoes")
			_verificar(get_viewport().get_visible_rect().encloses(carta_posicao.call("obter_area_tooltip")), "tooltip precisa caber nas tres posicoes")
			_verificar((carta_posicao.get_node("DescricaoBalao") as Control).get_global_rect().encloses((carta_posicao.get_node("DescricaoBalao/BalaoTexto") as Label).get_global_rect()), "primeira e ultima linha precisam ficar dentro do balao")
			for nome_no in ["NomeLabel", "CustoLabel", "DescricaoLabel"]:
				_verificar(not (carta_posicao.get_node("DescricaoBalao") as Control).get_global_rect().intersects((carta_posicao.get_node(nome_no) as Control).get_global_rect()), "tooltip nao pode cobrir informacao da carta ativa")
			carta_posicao.call("_ao_sair")
			carta_posicao.grab_focus()
			await get_tree().process_frame
			_verificar((carta_posicao.get_node("DescricaoBalao") as Control).visible, "tooltip precisa aparecer com foco nas tres posicoes")
			_verificar(get_viewport().get_visible_rect().encloses(carta_posicao.call("obter_area_tooltip")), "tooltip focado precisa caber nas tres posicoes")
	preview_helper.call("_configurar_oferta_conhecida", jogo, true)
	jogo.call("_ao_clicar_recompensa", 1)
	_verificar((jogo.get("baralho_run") as Array[String]).has("brecha"), "clicar na carta exibida pelo preview precisa conceder a mesma carta")
	preview_helper.free()

	jogo.call("_mostrar_evento", "carga_descartada")
	_verificar(not recompensas.visible, "recompensa comum some quando o evento abre")

	jogo.queue_free()
	if falhas == 0:
		print("OK: apresentacao de recompensas")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)


func verificar_nao_cobre_informacao_vizinha(carta: Control, vizinha: Control) -> void:
	var balao: Rect2 = (carta.get_node("DescricaoBalao") as Control).get_global_rect().grow(2.0)
	for nome_no in ["NomeLabel", "CustoLabel", "DescricaoLabel"]:
		var informacao: Control = vizinha.get_node_or_null(nome_no) as Control
		if informacao != null and informacao.visible:
			_verificar(not balao.intersects(informacao.get_global_rect()), "tooltip nao deve cobrir informacao essencial da carta vizinha")


func _get_viewport_release_focus() -> void:
	get_viewport().gui_release_focus()
