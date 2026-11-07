extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)

	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	await get_tree().process_frame

	var overlay: Control = jogo.get_node("EventoOverlay") as Control
	var recompensas: Control = jogo.get_node("Recompensas") as Control
	var recompensa_elite: Control = jogo.get_node("RecompensaElite") as Control
	var mao: Control = jogo.get_node("Mao") as Control
	var alvo: Button = jogo.get_node("Alvo") as Button
	var jogador: Button = jogo.get_node("Jogador") as Button

	_verificar(not overlay.visible, "overlay de evento começa oculto")
	jogo.call("_mostrar_evento", "carga_descartada")

	_verificar(overlay.visible, "overlay de evento aparece")
	_verificar(jogo.has_node("EventoOverlay/EventoQuadro"), "evento precisa de quadro visual do encontro")
	_verificar(jogo.has_node("EventoOverlay/EventoNarrativaPainel"), "evento precisa de painel narrativo claro")
	_verificar((jogo.get_node("EventoOverlay/EventoQuadro") as Control).visible, "quadro do evento aparece")
	_verificar((jogo.get_node("EventoOverlay/EventoNarrativaPainel") as Control).visible, "painel narrativo do evento aparece")
	_verificar(jogo.has_node("EventoOverlay/EventoVidaLabel"), "cabecalho precisa mostrar Vida real")
	_verificar(jogo.has_node("EventoOverlay/EventoBaralhoLabel"), "cabecalho precisa mostrar baralho real")
	_verificar(
		(jogo.get_node("EventoOverlay/EventoTitulo") as Label).get_theme_font("font").resource_path.ends_with("Bangers-Regular.ttf"),
		"titulo do evento precisa usar a tipografia do jogo"
	)
	_verificar(
		(jogo.get_node("EventoOverlay/EventoTitulo") as Label).text == "ENCONTRO",
		"cabeçalho deve mostrar a identidade do encontro"
	)
	_verificar(
		(jogo.get_node("EventoOverlay/EventoFaixaNome/EventoFaixaNomeLabel") as Label).text == "Carga Descartada",
		"faixa deve mostrar o nome real do evento"
	)
	_verificar(
		(jogo.get_node("EventoOverlay/EventoTitulo") as Label).get_global_rect().position.x < (jogo.get_node("EventoOverlay/EventoNarrativaPainel") as Control).get_global_rect().position.x,
		"faixa do evento deve permanecer à esquerda da narrativa"
	)
	_verificar(
		(jogo.get_node("EventoOverlay/EventoTexto") as Label).get_theme_font("font").resource_path.contains("BarlowSemiCondensed"),
		"narrativa deve usar Barlow"
	)
	var quadro: Control = jogo.get_node("EventoOverlay/EventoQuadro") as Control
	var quadro_icone: TextureRect = jogo.get_node("EventoOverlay/EventoQuadroIcone") as TextureRect
	var quadro_rect: Rect2 = quadro.get_global_rect()
	var icone_rect: Rect2 = quadro_icone.get_global_rect()
	_verificar(
		quadro_icone.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED,
		"simbolo do evento deve preservar proporcao e centralizacao"
	)
	_verificar(icone_rect.position.x >= quadro_rect.position.x + 16.0, "simbolo deve respeitar margem esquerda do quadro")
	_verificar(icone_rect.end.x <= quadro_rect.end.x - 16.0, "simbolo nao pode invadir a coluna narrativa")
	_verificar(icone_rect.position.y >= quadro_rect.position.y + 16.0, "simbolo deve respeitar margem superior do quadro")
	_verificar(icone_rect.end.y <= quadro_rect.end.y - 72.0, "simbolo deve ficar acima da faixa do nome")
	_verificar(jogo.has_node("EventoOverlay/EventoTituloFaixa"), "cabecalho deve usar uma faixa HQ propria")
	_verificar(
		(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button).visible,
		"primeira opção aparece"
	)
	_verificar(
		(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao2") as Button).visible,
		"segunda opção aparece"
	)
	_verificar(
		(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao3") as Button).visible,
		"terceira opção fica oculta quando não existe"
	)
	for indice in [1, 2, 3]:
		var opcao: Button = jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao%d" % indice) as Button
		_verificar(opcao.get_node("Conteudo/Linha/Textos/Acao").mouse_filter == Control.MOUSE_FILTER_IGNORE, "decoracao da escolha nao deve interceptar mouse")
		_verificar(indice in [2, 3] or opcao.get_node("Conteudo/Linha/Textos/Detalhe").text != "", "escolha deve mostrar resumo secundario quando houver informacao")
		_verificar(opcao.focus_mode != Control.FOCUS_NONE, "escolha deve aceitar teclado")
		_verificar(opcao.get_node("Conteudo/Linha/Textos/Acao").horizontal_alignment == HORIZONTAL_ALIGNMENT_LEFT, "acao deve alinhar a esquerda")
		_verificar(opcao.get_node("Conteudo/Linha/Textos/Detalhe").horizontal_alignment == HORIZONTAL_ALIGNMENT_LEFT, "detalhe deve alinhar a esquerda")
		_verificar(opcao.has_node("Conteudo/Linha/Seta"), "escolha deve reservar uma seta decorativa")
		_verificar(opcao.get_theme_stylebox("normal") is StyleBoxTexture, "escolha deve usar moldura HQ normal")
		_verificar(opcao.get_theme_stylebox("focus") == opcao.get_theme_stylebox("normal"), "foco deve preservar a moldura HQ base")
		_verificar(opcao.has_node("Interacao"), "foco deve usar camada ciano separada")
	var resultado_opcao: Button = jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao3") as Button
	_verificar(resultado_opcao.visible, "opcao real deve permanecer visível")
	jogo.call("_mostrar_evento", "posto_inspecao")
	var combate_opcao: Button = jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button
	_verificar(combate_opcao.get_node("Conteudo/Linha/Textos/Detalhe").text == "Combate", "combate deve ter resumo curto e claro")
	_verificar((combate_opcao.get_node("Conteudo/Linha/TipoIcone") as TextureRect).texture.resource_path.contains("combate"), "combate deve usar icone apropriado")
	var texto_generico: Button = jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button
	_verificar(not texto_generico.get_node("Conteudo/Linha/Textos/Detalhe").text.contains("segue a rota"), "nao mostrar mensagem generica de rota")
	_verificar(not recompensas.visible, "recompensa comum esconde durante evento")
	_verificar(not recompensa_elite.visible, "recompensa do elite esconde durante evento")
	_verificar(alvo.disabled, "alvo fica bloqueado durante evento")
	_verificar(jogador.disabled, "jogador fica bloqueado durante evento")
	for no in mao.get_children():
		_verificar((no as Button).disabled, "cartas ficam bloqueadas durante evento")

	# Resultado direto: a escolha some, o resultado aparece e o clique tardio nao reaplica a consequencia.
	jogo.call("_mostrar_evento", "carga_descartada")
	var vida_antes: int = int(jogo.get("vida_jogador"))
	var escolher: Button = jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button
	escolher.pressed.emit()
	await get_tree().process_frame
	_verificar((jogo.get_node("EventoOverlay/EventoResultado") as Control).visible, "resultado aparece depois da escolha")
	_verificar((jogo.get_node("EventoOverlay/EventoContinuar") as Control).visible, "continuar aparece depois da escolha")
	var resultado_rect: Rect2 = (jogo.get_node("EventoOverlay/EventoResultado") as Control).get_global_rect()
	var continuar: Button = jogo.get_node("EventoOverlay/EventoContinuar") as Button
	_verificar(continuar.get_global_rect().position.y >= resultado_rect.end.y + 12.0, "continuar deve ficar abaixo do resultado")
	_verificar(continuar.get_global_rect().end.y <= overlay.get_global_rect().end.y, "continuar deve caber no overlay")
	_verificar(continuar.get_theme_constant("content_margin_top") >= 12, "continuar deve ter margem interna superior")
	_verificar(continuar.get_theme_constant("content_margin_bottom") >= 12, "continuar deve ter margem interna inferior")
	_verificar(not escolher.visible, "opcoes desaparecem depois da escolha")
	var vida_apos: int = int(jogo.get("vida_jogador"))
	escolher.pressed.emit()
	_verificar(int(jogo.get("vida_jogador")) == vida_apos, "clique tardio nao pode reaplicar o evento")
	_verificar(vida_apos == vida_antes - 7, "consequencia de Vida deve permanecer a regra real")

	jogo.call("_ocultar_evento")
	_verificar(not overlay.visible, "overlay esconde ao sair do evento")
	_verificar(not overlay.visible, "quadro do evento esconde ao sair")
	_verificar(mao.visible, "mão retorna ao sair do evento")
	_verificar(not alvo.disabled, "alvo retorna ao combate")
	_verificar(not jogador.disabled, "jogador retorna ao combate")

	jogo.queue_free()

	if falhas == 0:
		print("OK: apresentação de eventos")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
