extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var cena: PackedScene = load("res://ui_entrada/selecao_personagem.tscn") as PackedScene
	_verificar(cena != null, "a cena de selecao deve existir")
	if cena == null:
		_terminar()
		return
	var selecao: Control = cena.instantiate() as Control
	get_tree().root.add_child(selecao)
	await get_tree().process_frame
	var confirmar: Button = selecao.find_child("ConfirmarButton", true, false) as Button
	var voltar: Button = selecao.find_child("VoltarButton", true, false) as Button
	var arte: TextureRect = selecao.find_child("VegaArte", true, false) as TextureRect
	var moldura_arte: Control = selecao.find_child("MolduraArte", true, false) as Control
	_verificar(confirmar != null and voltar != null and arte != null, "ficha deve ter arte e duas acoes")
	if confirmar != null and voltar != null and arte != null:
		_verificar(moldura_arte != null and not bool(moldura_arte.get("preencher")), "moldura da arte nao deve cobrir Vega")
		_verificar(arte.texture != null, "arte estatica aprovada deve aparecer")
		_verificar(arte.expand_mode == TextureRect.EXPAND_IGNORE_SIZE, "arte deve caber no layout sem impor tamanho original")
		_verificar(arte.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "arte deve preservar proporcao")
		_verificar(confirmar.custom_minimum_size.y >= 44.0 and voltar.custom_minimum_size.y >= 44.0, "acoes devem ter pelo menos 44 px")
		_verificar(get_viewport().gui_get_focus_owner() == confirmar, "CONFIRMAR deve receber foco inicial")
		var esquerda: InputEventAction = InputEventAction.new()
		esquerda.action = "ui_left"
		esquerda.pressed = true
		get_viewport().push_input(esquerda)
		await get_tree().process_frame
		_verificar(get_viewport().gui_get_focus_owner() == voltar, "seta para esquerda deve focar VOLTAR")
		var direita: InputEventAction = InputEventAction.new()
		direita.action = "ui_right"
		direita.pressed = true
		get_viewport().push_input(direita)
		await get_tree().process_frame
		_verificar(get_viewport().gui_get_focus_owner() == confirmar, "seta para direita deve voltar a CONFIRMAR")
		var ids: Array[String] = []
		var pedidos_voltar: Array[int] = [0]
		selecao.connect("personagem_confirmada", func(id: String) -> void: ids.append(id))
		selecao.connect("voltar_solicitado", func() -> void: pedidos_voltar[0] += 1)
		confirmar.pressed.emit()
		voltar.pressed.emit()
		_verificar(ids == ["vega"] and pedidos_voltar[0] == 1, "confirmar e voltar devem emitir intencoes corretas")
		_verificar(bool(selecao.get("vega_selecionada")), "Vega deve estar selecionada explicitamente")
	selecao.queue_free()
	_terminar()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)


func _terminar() -> void:
	print("SELECAO VEGA: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)
