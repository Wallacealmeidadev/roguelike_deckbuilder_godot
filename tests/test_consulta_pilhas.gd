extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	await get_tree().process_frame
	var compra: Array[String] = ["golpe", "protecao"]
	var descarte: Array[String] = ["quebra_chassi"]
	jogo.set("pilha_compra", compra)
	jogo.set("pilha_descarte", descarte)
	var turno_antes: int = jogo.get("turno")
	var vida_topo: ProgressBar = jogo.get_node("VidaJogadorBar") as ProgressBar
	_verificar(vida_topo.value == 40.0 and vida_topo.max_value == 40.0, "barra do topo deve refletir Vida real")
	var preenchimento: TextureRect = jogo.get_node("TopoVidaPreenchimento") as TextureRect
	_verificar(not preenchimento.visible, "preenchimento HQ da Vida deve ficar oculto no HUD basico")

	var clique: InputEventMouseButton = InputEventMouseButton.new()
	clique.button_index = MOUSE_BUTTON_LEFT
	clique.pressed = true
	(jogo.get_node("CompraPainel") as Panel).gui_input.emit(clique)
	_verificar((jogo.get_node("BaralhoOverlay") as Control).visible, "Compra deve abrir overlay")
	_verificar(_ids_visiveis(jogo) == compra, "Compra deve mostrar somente cartas da pilha de compra")
	jogo.call("_fechar_consulta_baralho")
	_verificar(not (jogo.get_node("BaralhoOverlay") as Control).visible, "overlay deve fechar")

	(jogo.get_node("DescartePainel") as Panel).gui_input.emit(clique)
	_verificar(_ids_visiveis(jogo) == descarte, "Descarte deve mostrar somente cartas descartadas")
	jogo.call("_fechar_consulta_baralho")

	var deck_grande: Array[String] = []
	for _indice in 30:
		deck_grande.append("golpe")
	jogo.set("baralho_run", deck_grande)
	(jogo.get_node("TopoCombate/TopoBaralho") as Button).pressed.emit()
	await get_tree().process_frame
	_verificar(_ids_visiveis(jogo).size() == 30, "baralho grande deve criar todas as cartas reais")
	var rolagem: ScrollContainer = jogo.get_node("BaralhoOverlay/ListaScroll") as ScrollContainer
	var grade: GridContainer = jogo.get_node("BaralhoOverlay/ListaScroll/ListaCartas") as GridContainer
	_verificar(grade.size.y > rolagem.size.y, "baralho grande deve permanecer rolavel")
	(jogo.get_node("BaralhoOverlay/BaralhoFechar") as Button).pressed.emit()
	_verificar(not (jogo.get_node("BaralhoOverlay") as Control).visible, "botao Fechar deve encerrar consulta")

	jogo.set("pilha_descarte", [] as Array[String])
	(jogo.get_node("DescartePainel") as Panel).gui_input.emit(clique)
	_verificar((jogo.get_node("BaralhoOverlay/BaralhoVazio") as Label).visible, "descarte vazio deve informar ausencia de cartas")
	jogo.call("_fechar_consulta_baralho")
	_verificar(jogo.get("turno") == turno_antes, "consulta nao deve avancar turno")
	_verificar(jogo.get("pilha_compra") == compra, "consulta nao deve alterar compra")
	jogo.queue_free()
	get_tree().quit(0 if falhas == 0 else 1)


func _ids_visiveis(jogo: Control) -> Array[String]:
	var ids: Array[String] = []
	var grade: GridContainer = jogo.get_node("BaralhoOverlay/ListaScroll/ListaCartas") as GridContainer
	for carta in grade.get_children():
		ids.append(str(carta.get_meta("id_carta", "")))
	return ids


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
