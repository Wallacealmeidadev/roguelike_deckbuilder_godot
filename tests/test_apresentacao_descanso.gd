extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame

	_verificar(jogo.has_node("DescansoOverlay"), "a cena principal deve instanciar o overlay de descanso")
	if jogo.has_node("DescansoOverlay"):
		var overlay: Control = jogo.get_node("DescansoOverlay") as Control
		for caminho in [
			"FaixaTitulo/Titulo",
			"VidaLabel",
			"BaralhoLabel",
			"Acoes/RecuperarPainel",
			"Acoes/AprimorarPainel",
			"Selecao",
			"Comparacao",
			"Resultado",
			"Continuar"
		]:
			_verificar(overlay.has_node(caminho), "overlay deve conter %s" % caminho)
		_verificar((overlay.get_node("Acoes/RecuperarPainel") as Button).focus_mode == Control.FOCUS_ALL, "recuperar deve aceitar foco de teclado")
		_verificar((overlay.get_node("Acoes/AprimorarPainel") as Button).focus_mode == Control.FOCUS_ALL, "aprimorar deve aceitar foco de teclado")
		_verificar(overlay.has_node("FaixaTitulo"), "descanso deve usar faixa HQ no titulo")
		_verificar(not overlay.has_node("Titulo"), "titulo nao deve ficar fora da faixa HQ")
		_verificar(overlay.has_node("VidaIcone"), "descanso deve mostrar icone de Vida")
		_verificar(overlay.has_node("BaralhoIcone"), "descanso deve mostrar icone de baralho")
		_verificar(overlay.has_node("Acoes/RecuperarPainel/Conteudo/Informacao"), "recuperar deve separar informacao essencial")
		_verificar(overlay.has_node("Acoes/AprimorarPainel/Conteudo/Informacao"), "aprimorar deve separar informacao essencial")
		for caminho in [
			"Selecao/Voltar/Interacao",
			"Comparacao/Voltar/Interacao",
			"Comparacao/Confirmar/Interacao",
			"Continuar/Interacao"
		]:
			_verificar(overlay.has_node(caminho), "botao deve ter destaque transparente em %s" % caminho)
		_verificar((overlay.get_node("Selecao/CartasScroll") as ScrollContainer).horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "seleção deve ter rolagem horizontal")
		_verificar((overlay.get_node("Comparacao/Cartas") as HBoxContainer).get_child_count() == 3, "comparação deve reservar carta, seta e carta melhorada")
		_verificar((overlay.get_node("Acoes/RecuperarPainel") as Control).custom_minimum_size.y >= 240.0, "painel de recuperar deve comportar símbolo, título e efeito")

		var faixa: Control = overlay.get_node("FaixaTitulo") as Control
		var subtitulo: Control = overlay.get_node("Subtitulo") as Control
		_verificar(
			faixa.get_global_rect().end.y + 4.0 <= subtitulo.get_global_rect().position.y,
			"instrucao inicial deve manter distancia da borda inferior do cabecalho"
		)
		_verificar(
			(overlay.get_node("Acoes/RecuperarPainel/Conteudo/Informacao") as Control).custom_minimum_size.y >= 70.0,
			"descricao de recuperar deve ter area vertical suficiente"
		)
		_verificar(
			(overlay.get_node("Acoes/AprimorarPainel/Conteudo/Informacao") as Control).custom_minimum_size.y >= 70.0,
			"descricao de aprimorar deve ter area vertical suficiente"
		)

		jogo.set("mapa_variante", 1)
		jogo.call("_iniciar_nova_run")
		await get_tree().process_frame
		(jogo.get("run_state") as RunState).no_atual = "combate_entrada"
		jogo.call("_ao_selecionar_no_mapa", "descanso_1")
		await get_tree().process_frame
		_verificar(overlay.visible, "overlay deve aparecer no descanso real do mapa")
		var recuperar: Control = overlay.get_node("Acoes/RecuperarPainel") as Control
		var aprimorar: Control = overlay.get_node("Acoes/AprimorarPainel") as Control
		var viewport_rect: Rect2 = get_viewport().get_visible_rect()
		_verificar(viewport_rect.encloses(recuperar.get_global_rect()), "painel recuperar deve caber na viewport")
		_verificar(viewport_rect.encloses(aprimorar.get_global_rect()), "painel aprimorar deve caber na viewport")

		_verificar((overlay.get_node("Comparacao/Cartas/Seta") as TextureRect).texture != null, "comparacao deve usar a seta do kit")
		_verificar((overlay.get_node("Comparacao/Cartas/Atual") as VBoxContainer).custom_minimum_size.y >= 400.0, "coluna atual deve reservar marcador e carta")
		_verificar((overlay.get_node("Selecao/Voltar") as Button).custom_minimum_size.y >= 70.0, "voltar deve ter altura para a legenda")
		_verificar((overlay.get_node("Continuar") as Button).custom_minimum_size.y >= 70.0, "continuar deve ter altura para a legenda")
		var confirmar: Button = overlay.get_node("Comparacao/Confirmar") as Button
		_verificar(confirmar.get_theme_stylebox("focus").resource_path == confirmar.get_theme_stylebox("normal").resource_path, "foco de confirmar deve preservar a moldura base")
		_verificar(overlay.has_node("Resultado/Conteudo/Simbolo"), "resultado deve conter simbolo")
		_verificar(overlay.has_node("Resultado/Conteudo/Estado"), "resultado deve conter estado resumido")

	if falhas == 0:
		print("OK: apresentação de descanso")
		jogo.queue_free()
		get_tree().quit(0)
	else:
		jogo.queue_free()
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
