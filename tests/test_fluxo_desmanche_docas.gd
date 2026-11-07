extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Node = (load("res://main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	var estado: RunState = jogo.get("run_state") as RunState
	estado.no_atual = "evento_meio"
	var antes: int = estado.deck.size()
	jogo.call("_ao_selecionar_no_mapa", "desmanche_docas")
	await get_tree().process_frame
	var overlay: Control = jogo.get_node_or_null("DesmancheOverlay") as Control
	_verificar(overlay != null and overlay.visible, "Desmanche deve abrir UI funcional")
	if overlay != null:
		var lista_scroll: ScrollContainer = overlay.get_node_or_null("Conteudo/ListaScroll") as ScrollContainer
		var lista: VBoxContainer = overlay.get_node_or_null("Conteudo/ListaScroll/Lista") as VBoxContainer
		_verificar(lista_scroll != null and lista_scroll.size.y > 0.0, "lista deve receber área visível")
		_verificar(lista != null and lista.get_child_count() == antes, "todas as cartas do deck devem aparecer")
		var selecionar: Button = overlay.get_node_or_null("Conteudo/ListaScroll/Lista/Item1/Selecionar") as Button
		_verificar(selecionar != null, "cada carta deve ter ação de seleção")
		if selecionar != null:
			selecionar.pressed.emit()
		var acoes: Control = overlay.get_node("Conteudo/Acoes") as Control
		var remover: Button = acoes.get_node("Remover") as Button
		var confirmar: Button = acoes.get_node("Confirmar") as Button
		var cancelar: Button = acoes.get_node("CancelarSelecao") as Button
		_verificar(remover.visible and not remover.disabled, "carta selecionada deve permitir remoção")
		cancelar.pressed.emit()
		_verificar(not remover.visible, "cancelar deve limpar a seleção")
		selecionar.pressed.emit()
		remover.pressed.emit()
		_verificar(confirmar.visible, "ação escolhida deve pedir confirmação")
		confirmar.pressed.emit()
		_verificar(estado.deck.size() == antes - 1, "uma única cópia deve ser removida uma vez")
		_verificar(not estado.concluidos.has("desmanche_docas"), "nó só conclui após continuar")
		var continuar: Button = overlay.get_node_or_null("Conteudo/Continuar") as Button
		if continuar != null:
			continuar.pressed.emit()
		_verificar(estado.concluidos.has("desmanche_docas"), "continuar conclui serviço")
		_verificar((jogo.get_node("MapaOverlay") as Control).visible, "serviço retorna ao mapa")
	jogo.queue_free()
	var host_longo: Control = Control.new()
	host_longo.size = Vector2(640, 480)
	get_tree().root.add_child(host_longo)
	var overlay_longo: DesmancheOverlay = DesmancheOverlay.new()
	host_longo.add_child(overlay_longo)
	await get_tree().process_frame
	var deck_longo: Array[String] = []
	for indice in range(30):
		deck_longo.append("golpe")
	overlay_longo.mostrar(deck_longo)
	await get_tree().process_frame
	var rolagem: ScrollContainer = overlay_longo.get_node("Conteudo/ListaScroll") as ScrollContainer
	_verificar((overlay_longo.get_node("Conteudo/ListaScroll/Lista") as Control).size.y > rolagem.size.y, "lista longa deve permitir rolagem")
	_verificar(overlay_longo.get_node_or_null("Conteudo/ListaScroll/Lista/Item29/Selecionar") != null, "última cópia continua acessível")
	host_longo.queue_free()
	var overlay_copias: DesmancheOverlay = DesmancheOverlay.new()
	get_tree().root.add_child(overlay_copias)
	await get_tree().process_frame
	overlay_copias.mostrar(["golpe", "golpe#aprimorado"])
	await get_tree().process_frame
	var selecionar_aprimorada: Button = overlay_copias.get_node("Conteudo/ListaScroll/Lista/Item1/Selecionar") as Button
	selecionar_aprimorada.pressed.emit()
	_verificar((overlay_copias.get_node("Conteudo/Acoes/Recalibrar") as Button).disabled, "carta já recalibrada deve desabilitar recalibração")
	overlay_copias.queue_free()
	var overlay_sem_acao: DesmancheOverlay = DesmancheOverlay.new()
	get_tree().root.add_child(overlay_sem_acao)
	await get_tree().process_frame
	overlay_sem_acao.size = Vector2(640, 480)
	overlay_sem_acao.mostrar(["golpe#aprimorado"])
	await get_tree().process_frame
	_verificar(not overlay_sem_acao.possui_acao_valida(), "deck sem ação válida deve ser detectado")
	_verificar((overlay_sem_acao.get_node("Conteudo/Resultado") as Label).visible, "deck sem ação deve explicar o motivo")
	_verificar((overlay_sem_acao.get_node("Conteudo/Continuar") as Button).visible, "deck sem ação deve ter saída segura")
	overlay_sem_acao.queue_free()
	if falhas == 0:
		print("OK: fluxo do Desmanche")
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
