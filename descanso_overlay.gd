extends Control

signal recuperar_solicitado
signal aprimorar_solicitado
signal carta_selecionada(indice: int)
signal voltar_solicitado
signal confirmar_solicitado(indice: int)
signal continuar_solicitado

const CENA_CARTA: PackedScene = preload("res://carta.tscn")
const FONTE_BANGERS: FontFile = preload("res://ui_hq_v1/fontes/Bangers-Regular.ttf")
const ICONE_VIDA: Texture2D = preload("res://ui_hq_v1/componentes/icones/vida.tres")
const ICONE_FORCA: Texture2D = preload("res://ui_hq_v1/componentes/icones/forca.tres")

@onready var subtitulo: Label = $Subtitulo
@onready var vida_label: Label = $VidaLabel
@onready var baralho_label: Label = $BaralhoLabel
@onready var recuperar_painel: Button = $Acoes/RecuperarPainel
@onready var aprimorar_painel: Button = $Acoes/AprimorarPainel
@onready var recuperar_detalhe: Label = $Acoes/RecuperarPainel/Conteudo/Informacao/Detalhe
@onready var aprimorar_detalhe: Label = $Acoes/AprimorarPainel/Conteudo/Informacao/Detalhe
@onready var selecao: Control = $Selecao
@onready var lista_cartas: HBoxContainer = $Selecao/CartasScroll/Cartas
@onready var comparacao: Control = $Comparacao
@onready var coluna_atual: VBoxContainer = $Comparacao/Cartas/Atual
@onready var coluna_melhorada: VBoxContainer = $Comparacao/Cartas/Melhorada
@onready var resultado: Control = $Resultado
@onready var resultado_simbolo: TextureRect = $Resultado/Conteudo/Simbolo
@onready var resultado_titulo: Label = $Resultado/Conteudo/Titulo
@onready var resultado_texto: Label = $Resultado/Conteudo/Texto
@onready var resultado_estado: Label = $Resultado/Conteudo/Estado
@onready var continuar: Button = $Continuar
@onready var voltar_selecao: Button = $Selecao/Voltar
@onready var voltar_comparacao: Button = $Comparacao/Voltar
@onready var confirmar: Button = $Comparacao/Confirmar

var _vida_maxima: int = 0
var _elegiveis: Array[Dictionary] = []
var _indice_selecionado: int = -1


func _ready() -> void:
	recuperar_painel.pressed.connect(func() -> void: recuperar_solicitado.emit())
	aprimorar_painel.pressed.connect(func() -> void: aprimorar_solicitado.emit())
	voltar_selecao.pressed.connect(func() -> void: voltar_solicitado.emit())
	voltar_comparacao.pressed.connect(func() -> void: voltar_solicitado.emit())
	confirmar.pressed.connect(_emitir_confirmacao)
	continuar.pressed.connect(func() -> void: continuar_solicitado.emit())
	for botao in [recuperar_painel, aprimorar_painel, voltar_selecao, voltar_comparacao, confirmar, continuar]:
		_registrar_destaque(botao as Button)
	get_viewport().size_changed.connect(_atualizar_layout_lista_cartas)


func _registrar_destaque(botao: Button) -> void:
	if botao.get_node_or_null("Interacao") == null:
		return
	botao.mouse_entered.connect(_atualizar_destaque.bind(botao))
	botao.mouse_exited.connect(_atualizar_destaque.bind(botao))
	botao.focus_entered.connect(_atualizar_destaque.bind(botao))
	botao.focus_exited.connect(_atualizar_destaque.bind(botao))
	_atualizar_destaque(botao)


func _atualizar_destaque(botao: Button) -> void:
	var camada: Control = botao.get_node_or_null("Interacao") as Control
	if camada != null:
		camada.visible = botao.is_hovered() or botao.has_focus()


func mostrar_resumo(
	vida_atual: int,
	vida_maxima: int,
	cartas_total: int,
	cura: int,
	elegiveis: Array[Dictionary]
) -> void:
	_vida_maxima = vida_maxima
	_elegiveis = elegiveis.duplicate(true)
	_indice_selecionado = -1
	vida_label.text = "VIDA %d/%d" % [vida_atual, vida_maxima]
	baralho_label.text = "BARALHO %d" % cartas_total
	recuperar_detalhe.text = "Recupere %d de Vida." % cura if cura > 0 else "Vida cheia."
	aprimorar_detalhe.text = "%d cartas elegíveis." % elegiveis.size() if not elegiveis.is_empty() else "Nenhuma carta elegível."
	recuperar_painel.disabled = cura <= 0
	aprimorar_painel.disabled = elegiveis.is_empty()
	subtitulo.visible = true
	subtitulo.text = "Escolha uma ação"
	show()
	_mostrar_inicio()


func mostrar_selecao(elegiveis: Array[Dictionary]) -> void:
	_elegiveis = elegiveis.duplicate(true)
	_indice_selecionado = -1
	# A instrução da seleção já ocupa o cabeçalho central deste estado.
	# O subtítulo global fica reservado à tela inicial e à comparação.
	subtitulo.visible = false
	for filho in lista_cartas.get_children():
		filho.queue_free()
	await get_tree().process_frame
	for item in _elegiveis:
		var carta: Button = _criar_carta_visual(item, 1.0, true, lista_cartas)
		carta.pressed.connect(_emitir_carta_selecionada.bind(int(item.get("indice", -1))))
	_atualizar_layout_lista_cartas()
	var foco: Control = lista_cartas.get_child(0) as Control if lista_cartas.get_child_count() > 0 else voltar_selecao
	_mostrar_estado(selecao, foco)


func _atualizar_layout_lista_cartas() -> void:
	if not is_instance_valid(lista_cartas) or not is_instance_valid(lista_cartas.get_parent()):
		return
	var area: Control = lista_cartas.get_parent() as Control
	var largura_disponivel: float = area.size.x
	var largura_conteudo: float = lista_cartas.get_combined_minimum_size().x
	if largura_conteudo <= largura_disponivel:
		lista_cartas.custom_minimum_size.x = largura_disponivel
		lista_cartas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lista_cartas.alignment = BoxContainer.ALIGNMENT_CENTER
	else:
		lista_cartas.custom_minimum_size.x = largura_conteudo
		lista_cartas.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		lista_cartas.alignment = BoxContainer.ALIGNMENT_BEGIN
	lista_cartas.queue_sort()


func mostrar_comparacao(carta_atual: Dictionary, carta_melhorada: Dictionary) -> void:
	_limpar_coluna(coluna_atual)
	_limpar_coluna(coluna_melhorada)
	subtitulo.visible = true
	subtitulo.text = "Confira antes de confirmar"
	_adicionar_marcador(coluna_atual, "ATUAL", Color("#d3e0e5"))
	_adicionar_marcador(coluna_melhorada, "MELHORADA", Color("#73e7ff"))
	_criar_carta_visual(carta_atual, 1.22, false, coluna_atual)
	_criar_carta_visual(carta_melhorada, 1.22, false, coluna_melhorada)
	_mostrar_estado(comparacao, confirmar)


func mostrar_resultado(tipo: String, detalhe: String, vida_atual: int, vida_maxima: int, estado: String) -> void:
	var recuperacao: bool = tipo == "RECUPERAR"
	resultado_simbolo.texture = ICONE_VIDA if recuperacao else ICONE_FORCA
	resultado_titulo.text = tipo
	resultado_texto.text = detalhe
	resultado_estado.text = estado
	resultado_estado.visible = not estado.is_empty()
	subtitulo.visible = false
	recuperar_painel.disabled = true
	aprimorar_painel.disabled = true
	vida_label.text = "VIDA %d/%d" % [vida_atual, vida_maxima]
	_mostrar_estado(resultado, continuar)


func atualizar_resumo(vida_atual: int, cartas_total: int) -> void:
	vida_label.text = "VIDA %d/%d" % [vida_atual, _vida_maxima]
	baralho_label.text = "BARALHO %d" % cartas_total


func _criar_carta_visual(item: Dictionary, escala: float, mostrar_copia: bool, pai: Control) -> Button:
	var carta: Button = CENA_CARTA.instantiate() as Button
	pai.add_child(carta)
	var dados: Dictionary = item.get("dados", {}) as Dictionary
	var id_carta: String = str(item.get("id", "carta"))
	carta.custom_minimum_size = Vector2(150, 240) * escala
	carta.set("nome_carta", str(dados.get("nome", id_carta)).to_upper())
	carta.set("custo", int(dados.get("custo", 0)))
	carta.set("descricao", str(item.get("descricao", "")))
	carta.call("aplicar_visual", id_carta, str(dados.get("tipo", "ataque")))
	var tooltip: String = str(item.get("tooltip", ""))
	if mostrar_copia:
		carta.call("configurar_descanso", "CÓPIA %d" % int(item.get("ocorrencia", 1)), tooltip)
	else:
		carta.call("configurar_descanso", "", tooltip)
		if not str(item.get("melhoria", "")).is_empty():
			carta.call("configurar_melhoria", str(item.get("melhoria", "")))
	carta.call("configurar_escala", escala)
	carta.focus_mode = Control.FOCUS_ALL
	return carta


func _adicionar_marcador(coluna: VBoxContainer, texto: String, cor: Color) -> void:
	var marcador: Label = Label.new()
	marcador.custom_minimum_size = Vector2(0, 28)
	marcador.text = texto
	marcador.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marcador.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marcador.add_theme_font_override("font", FONTE_BANGERS)
	marcador.add_theme_font_size_override("font_size", 20)
	marcador.add_theme_color_override("font_color", cor)
	marcador.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coluna.add_child(marcador)


func _limpar_coluna(coluna: Control) -> void:
	for filho in coluna.get_children():
		filho.free()


func _mostrar_inicio() -> void:
	_mostrar_estado(self, recuperar_painel)


func _mostrar_estado(estado: Control, foco: Control) -> void:
	$Acoes.visible = estado == self
	selecao.visible = estado == selecao
	comparacao.visible = estado == comparacao
	resultado.visible = estado == resultado
	continuar.visible = estado == resultado
	if is_instance_valid(foco):
		foco.grab_focus()


func _emitir_carta_selecionada(indice: int) -> void:
	_indice_selecionado = indice
	carta_selecionada.emit(indice)


func _emitir_confirmacao() -> void:
	if _indice_selecionado >= 0:
		confirmar_solicitado.emit(_indice_selecionado)
