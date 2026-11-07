extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	jogo.call("_mostrar_evento", "posto_inspecao")
	var evento: Control = jogo.get_node("EventoOverlay") as Control
	_verificar(evento.visible, "evento precisa aparecer durante a run")
	var titulo: PanelContainer = jogo.get_node("EventoOverlay/EventoTituloFaixa") as PanelContainer
	var estilo_titulo: StyleBoxTexture = titulo.get_theme_stylebox("panel") as StyleBoxTexture
	_verificar(estilo_titulo != null and estilo_titulo.texture.resource_path.begins_with("res://hud_neon/"), "cabecalho do evento precisa do tema neon")
	var narrativa: PanelContainer = jogo.get_node("EventoOverlay/EventoNarrativaPainel") as PanelContainer
	var estilo_narrativa: StyleBoxFlat = narrativa.get_theme_stylebox("panel") as StyleBoxFlat
	_verificar(estilo_narrativa != null and estilo_narrativa.bg_color.get_luminance() < 0.18, "narrativa precisa de fundo escuro legivel")
	_verificar((jogo.get_node("EventoOverlay/EventoVidaLabel") as Label).text == "40/40", "evento deve manter Vida real no cabecalho")
	var opcao: Button = jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao2") as Button
	_verificar(opcao.get_theme_stylebox("normal") is StyleBoxTexture, "escolha de evento precisa de moldura neon")
	_verificar(opcao.get_theme_stylebox("focus") == opcao.get_theme_stylebox("normal"), "foco deve preservar a area visual da escolha")
	opcao.pressed.emit()
	_verificar((jogo.get_node("EventoOverlay/EventoResultado") as Label).visible, "escolha ainda deve revelar a consequencia")
	_verificar((jogo.get_node("EventoOverlay/EventoContinuar") as Button).get_theme_stylebox("normal") is StyleBoxTexture, "continuar deve integrar o tema neon")

	jogo.call("_mostrar_recompensa_elite")
	var elite: Control = jogo.get_node("RecompensaElite") as Control
	_verificar(elite.visible, "a oferta elite deve continuar abrindo")
	_verificar(jogo.has_node("RecompensaEliteFundo"), "a oferta elite precisa de uma placa atras das opcoes")
	if jogo.has_node("RecompensaEliteFundo"):
		var fundo: Panel = jogo.get_node("RecompensaEliteFundo") as Panel
		_verificar(fundo.visible and fundo.mouse_filter == Control.MOUSE_FILTER_IGNORE, "placa elite deve aparecer sem capturar clique")
	var consultar: Button = jogo.get_node("RecompensaElite/RecompensaEliteAcoes/ConsultarBaralho") as Button
	_verificar(consultar.get_theme_stylebox("normal") is StyleBoxTexture, "consulta do elite precisa do botao neon")
	jogo.call("_ocultar_recompensa_elite")
	if jogo.has_node("RecompensaEliteFundo"):
		_verificar(not (jogo.get_node("RecompensaEliteFundo") as Panel).visible, "placa elite deve sumir junto da oferta")
	jogo.queue_free()
	if falhas == 0:
		print("OK: evento e elite com apresentacao neon")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
