class_name DesmancheOverlay
extends PanelContainer

signal remover_solicitado(indice: int)
signal recalibrar_solicitado(indice: int)
signal continuar_solicitado

var lista: VBoxContainer
var resultado: Label
var continuar: Button
var acoes: HBoxContainer
var remover_acao: Button
var recalibrar_acao: Button
var confirmar_acao: Button
var cancelar_selecao: Button
var indice_selecionado: int = -1
var acao_pendente: String = ""
var _tem_acao_valida: bool = false
var _modo_acao: String = "ambos"
var _filtro_carta: String = ""
var _deck_pode_remover: bool = false
const DADOS_CARTAS: Script = preload("res://dados_cartas.gd")


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var estilo: StyleBoxFlat = StyleBoxFlat.new()
	estilo.bg_color = Color("#101820")
	estilo.content_margin_left = 28
	estilo.content_margin_top = 22
	estilo.content_margin_right = 28
	estilo.content_margin_bottom = 22
	add_theme_stylebox_override("panel", estilo)
	var conteudo: VBoxContainer = VBoxContainer.new()
	conteudo.name = "Conteudo"
	conteudo.add_theme_constant_override("separation", 8)
	add_child(conteudo)
	var titulo: Label = Label.new()
	titulo.text = "DESMANCHE — escolha uma carta para remover ou recalibrar"
	conteudo.add_child(titulo)
	var rolagem: ScrollContainer = ScrollContainer.new()
	rolagem.name = "ListaScroll"
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolagem.custom_minimum_size.y = 240.0
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	conteudo.add_child(rolagem)
	lista = VBoxContainer.new()
	lista.name = "Lista"
	lista.add_theme_constant_override("separation", 2)
	rolagem.add_child(lista)
	acoes = HBoxContainer.new()
	acoes.name = "Acoes"
	acoes.add_theme_constant_override("separation", 8)
	conteudo.add_child(acoes)
	remover_acao = Button.new()
	remover_acao.name = "Remover"
	remover_acao.text = "REMOVER"
	remover_acao.pressed.connect(_solicitar_remocao)
	acoes.add_child(remover_acao)
	recalibrar_acao = Button.new()
	recalibrar_acao.name = "Recalibrar"
	recalibrar_acao.text = "RECALIBRAR"
	recalibrar_acao.pressed.connect(_solicitar_recalibracao)
	acoes.add_child(recalibrar_acao)
	confirmar_acao = Button.new()
	confirmar_acao.name = "Confirmar"
	confirmar_acao.text = "CONFIRMAR"
	confirmar_acao.pressed.connect(_confirmar_acao)
	acoes.add_child(confirmar_acao)
	cancelar_selecao = Button.new()
	cancelar_selecao.name = "CancelarSelecao"
	cancelar_selecao.text = "CANCELAR SELEÇÃO"
	cancelar_selecao.pressed.connect(_cancelar_selecao)
	acoes.add_child(cancelar_selecao)
	resultado = Label.new()
	resultado.name = "Resultado"
	resultado.hide()
	conteudo.add_child(resultado)
	continuar = Button.new()
	continuar.name = "Continuar"
	continuar.text = "Voltar ao mapa"
	continuar.hide()
	continuar.pressed.connect(func() -> void: continuar_solicitado.emit())
	conteudo.add_child(continuar)
	_atualizar_acoes()
	hide()


func mostrar(deck: Array[String], modo_acao: String = "ambos", filtro_carta: String = "") -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	indice_selecionado = -1
	acao_pendente = ""
	_modo_acao = modo_acao
	_filtro_carta = filtro_carta
	_deck_pode_remover = deck.size() > 1
	for filho in lista.get_children():
		lista.remove_child(filho)
		filho.queue_free()
	resultado.hide()
	continuar.hide()
	var descanso: DescansoRun = DescansoRun.new()
	var elegiveis: Array[Dictionary] = descanso.cartas_elegiveis(deck, filtro_carta)
	var quantidade_linhas: int = 0
	for indice in range(deck.size()):
		var token: String = deck[indice]
		var id_base: String = descanso.id_base(token)
		var dados: Dictionary = DADOS_CARTAS.CARTAS.get(id_base, {})
		if not _carta_passa_filtro(dados, filtro_carta):
			continue
		quantidade_linhas += 1
		var linha: HBoxContainer = HBoxContainer.new()
		linha.name = "Item%d" % indice
		lista.add_child(linha)
		var nome: Label = Label.new()
		nome.text = "%d. %s%s" % [indice + 1, str(dados.get("nome", id_base)), " +" if descanso.esta_aprimorada(token) else ""]
		nome.custom_minimum_size.x = 250
		linha.add_child(nome)
		var estado: Label = Label.new()
		estado.name = "Estado"
		estado.text = "JÁ RECALIBRADA" if descanso.esta_aprimorada(token) else ""
		estado.custom_minimum_size.x = 150
		linha.add_child(estado)
		var selecionar: Button = Button.new()
		selecionar.name = "Selecionar"
		selecionar.text = "Selecionar"
		selecionar.focus_mode = Control.FOCUS_ALL
		selecionar.pressed.connect(_selecionar_carta.bind(lista.get_child_count() - 1))
		linha.add_child(selecionar)
		linha.set_meta("token", token)
		linha.set_meta("indice", indice)
		linha.set_meta("aprimorada", descanso.esta_aprimorada(token))
		linha.custom_minimum_size.y = 32.0
	_tem_acao_valida = false
	if _modo_acao in ["ambos", "remover"] and deck.size() > 1 and quantidade_linhas > 0:
		_tem_acao_valida = true
	if _modo_acao in ["ambos", "recalibrar"] and not elegiveis.is_empty():
		_tem_acao_valida = true
	_atualizar_acoes()
	if not _tem_acao_valida:
		resultado.text = "Nenhuma ação válida para este baralho. O nó pode ser concluído com segurança."
		resultado.show()
		continuar.show()
	show()


func _carta_passa_filtro(dados: Dictionary, filtro: String) -> bool:
	if filtro.is_empty():
		return true
	if filtro == "vega_exclusiva":
		return str(dados.get("personagem", "")) == "vega" and bool(dados.get("exclusiva", false))
	return false


func mostrar_resultado(texto: String) -> void:
	for linha in lista.get_children():
		for filho in linha.get_children():
			if filho is Button:
				(filho as Button).disabled = true
	resultado.text = texto
	resultado.show()
	continuar.show()
	continuar.grab_focus()
	indice_selecionado = -1
	acao_pendente = ""
	_atualizar_acoes()


func possui_acao_valida() -> bool:
	return _tem_acao_valida


func _selecionar_carta(indice_linha: int) -> void:
	if indice_linha < 0 or indice_linha >= lista.get_child_count():
		return
	var linha: Node = lista.get_child(indice_linha)
	indice_selecionado = int(linha.get_meta("indice", -1))
	acao_pendente = ""
	_atualizar_acoes()


func _solicitar_remocao() -> void:
	if indice_selecionado < 0:
		return
	acao_pendente = "remover"
	_atualizar_acoes()


func _solicitar_recalibracao() -> void:
	if indice_selecionado < 0 or recalibrar_acao.disabled:
		return
	acao_pendente = "recalibrar"
	_atualizar_acoes()


func _confirmar_acao() -> void:
	if indice_selecionado < 0 or acao_pendente.is_empty():
		return
	if acao_pendente == "remover":
		remover_solicitado.emit(indice_selecionado)
	else:
		recalibrar_solicitado.emit(indice_selecionado)


func _cancelar_selecao() -> void:
	indice_selecionado = -1
	acao_pendente = ""
	_atualizar_acoes()


func _atualizar_acoes() -> void:
	if remover_acao == null:
		return
	var selecionada: bool = indice_selecionado >= 0
	var pode_remover: bool = _modo_acao in ["ambos", "remover"] and _deck_pode_remover
	var pode_recalibrar: bool = _modo_acao in ["ambos", "recalibrar"]
	remover_acao.visible = selecionada and acao_pendente.is_empty() and pode_remover
	recalibrar_acao.visible = selecionada and acao_pendente.is_empty() and pode_recalibrar
	confirmar_acao.visible = selecionada and not acao_pendente.is_empty()
	cancelar_selecao.visible = selecionada
	remover_acao.disabled = not selecionada or not pode_remover
	recalibrar_acao.disabled = not selecionada or not pode_recalibrar or _linha_selecionada_aprimorada()
	if confirmar_acao.visible:
		confirmar_acao.text = "CONFIRMAR REMOÇÃO" if acao_pendente == "remover" else "CONFIRMAR RECALIBRAÇÃO"


func _linha_selecionada_aprimorada() -> bool:
	if indice_selecionado < 0:
		return false
	for linha_variant in lista.get_children():
		var linha: Node = linha_variant as Node
		if int(linha.get_meta("indice", -1)) == indice_selecionado:
			return bool(linha.get_meta("aprimorada", false))
	return false
