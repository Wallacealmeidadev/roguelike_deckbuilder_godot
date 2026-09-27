extends Button

const MOLDURA_ATAQUE: Texture2D = preload("res://ui_hq_v1/componentes/cartas/carta_ataque.tres")
const MOLDURA_HABILIDADE: Texture2D = preload("res://ui_hq_v1/componentes/cartas/carta_habilidade.tres")
const ARTE_GOLPE: Texture2D = preload("res://ui_hq_v1/componentes/ilustracoes/arte_golpe.tres")
const ARTE_PROTECAO: Texture2D = preload("res://ui_hq_v1/componentes/ilustracoes/arte_protecao.tres")
const ARTE_QUEBRA_CHASSI: Texture2D = preload("res://ui_hq_v1/componentes/ilustracoes/arte_quebra_chassi.tres")
const TAMANHO_BASE: Vector2 = Vector2(150, 240)
const ESCALA_FOCO_COMBATE: float = 1.08
const ESCALA_FOCO_RECOMPENSA: float = 1.025

@export var nome_carta: String = "GOLPE"
@export var custo: int = 1
@export_multiline var descricao: String = ""

@onready var moldura: TextureRect = $Moldura
@onready var arte: TextureRect = $Arte
@onready var foco: TextureRect = $Foco
@onready var custo_label: Label = $CustoLabel
@onready var nome_label: Label = $NomeLabel
@onready var descricao_label: Label = $DescricaoLabel
@onready var descricao_destaque: RichTextLabel = $DescricaoDestaque
@onready var selecao_label: Label = $SelecaoLabel
@onready var descricao_balao: PanelContainer = $DescricaoBalao
@onready var balao_texto: Label = $DescricaoBalao/BalaoTexto
@onready var balao_ponta: Polygon2D = $DescricaoBalao/BalaoPonta
@onready var balao_ponta_contorno: Line2D = $DescricaoBalao/BalaoPontaContorno

var id_carta_visual: String = ""
var _escala_visual: float = 1.0
var _mouse_sobre: bool = false
var _animacao: Tween
var _modo_recompensa: bool = false
var _modo_descanso: bool = false
var _lado_ponta: String = "baixo"
var _melhoria_destaque: String = ""
static var _tooltip_ativo: Button
static var _hover_ativo: Button


func _ready() -> void:
	toggle_mode = true
	tooltip_text = ""
	toggled.connect(_ao_alternar)
	mouse_entered.connect(_ao_entrar)
	mouse_exited.connect(_ao_sair)
	focus_entered.connect(_ao_mudar_foco)
	focus_exited.connect(_ao_mudar_foco)
	aplicar_visual("", "ataque")
	descricao_balao.hide()


func _process(_delta: float) -> void:
	if _modo_recompensa and descricao_balao.visible:
		_posicionar_balao()


func aplicar_visual(id_carta: String, tipo: String) -> void:
	id_carta_visual = id_carta
	moldura.texture = MOLDURA_HABILIDADE if tipo == "habilidade" else MOLDURA_ATAQUE
	arte.texture = _obter_arte(id_carta)
	arte.visible = arte.texture != null
	nome_label.add_theme_color_override("font_color", Color("#f5f7fa"))
	_limpar_destaque_melhoria()
	_atualizar_texto()


func configurar_escala(fator: float, permitir_reducao: bool = false) -> void:
	# A mão de combate pode precisar de uma escala menor quando chega ao
	# limite de dez cartas. Recompensas e seleção de descanso mantêm o
	# limite visual anterior para não alterar sua composição aprovada.
	var escala_minima: float = 0.45 if permitir_reducao else 0.7
	var escala: float = clampf(fator, escala_minima, 2.2)
	_escala_visual = escala
	custom_minimum_size = TAMANHO_BASE * escala
	if permitir_reducao:
		# A mão é um Control com layout manual; seu posicionamento usa o
		# tamanho efetivo, não apenas o mínimo solicitado.
		size = custom_minimum_size
	pivot_offset = Vector2(custom_minimum_size.x * 0.5, custom_minimum_size.y) if permitir_reducao else custom_minimum_size * 0.5
	custo_label.add_theme_font_size_override("font_size", roundi(18.0 * escala))
	var tamanho_titulo: float = 12.0 if nome_carta.length() > 14 else 16.0
	nome_label.add_theme_font_size_override("font_size", roundi(tamanho_titulo * escala))
	descricao_label.add_theme_font_size_override("font_size", roundi(12.0 * escala))
	descricao_destaque.add_theme_font_size_override("normal_font_size", roundi(12.0 * escala))
	selecao_label.add_theme_font_size_override("font_size", roundi(13.0 * escala))
	balao_texto.add_theme_font_size_override("font_size", maxi(roundi(11.0 * escala), 12))
	_atualizar_transformacao(false)


func animar_entrada(atraso: float = 0.0) -> void:
	# A entrada não usa alpha no botão-raiz: ele também é a fonte do
	# estado de disponibilidade. Um fade no raiz fazia cartas recém
	# compradas parecerem desabilitadas durante a transição.
	modulate = Color.WHITE
	scale = Vector2.ONE * 0.95
	_animacao = create_tween()
	_animacao.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_animacao.tween_interval(atraso)
	_animacao.parallel().tween_property(self, "scale", Vector2.ONE, 0.18)


func normalizar_apresentacao_mao() -> void:
	if _animacao != null and _animacao.is_valid():
		_animacao.kill()
	modulate = Color.WHITE
	scale = Vector2.ONE


func _obter_arte(id_carta: String) -> Texture2D:
	match id_carta:
		"protecao":
			return ARTE_PROTECAO
		"pulso_debilitante", "placa_reforcada":
			return ARTE_PROTECAO
		"quebra_chassi":
			return ARTE_QUEBRA_CHASSI
		"golpe", "direto_hidraulico", "brecha", "golpe_ariete", "ruptura_pressao":
			return ARTE_GOLPE
		_:
			return null


func _ao_alternar(_selecionado: bool) -> void:
	if _modo_recompensa and button_pressed:
		button_pressed = false
	_atualizar_texto()
	_atualizar_transformacao()


func _ao_entrar() -> void:
	_mouse_sobre = true
	if _modo_recompensa:
		_hover_ativo = self
	_atualizar_transformacao()
	_atualizar_tooltip()


func _ao_sair() -> void:
	_mouse_sobre = false
	if _modo_recompensa and _hover_ativo == self:
		_hover_ativo = null
	_atualizar_transformacao()
	_atualizar_tooltip()


func _ao_mudar_foco() -> void:
	_atualizar_transformacao()
	_atualizar_tooltip()


func configurar_recompensa(detalhe: String) -> void:
	_modo_recompensa = true
	_modo_descanso = false
	_limpar_destaque_melhoria()
	button_pressed = false
	foco.hide()
	selecao_label.hide()
	balao_texto.text = detalhe
	_dimensionar_balao()
	tooltip_text = ""
	_atualizar_texto()
	_atualizar_transformacao(false)
	_atualizar_tooltip()


func configurar_descanso(identidade: String, explicacao: String = "") -> void:
	_modo_recompensa = true
	_modo_descanso = true
	_limpar_destaque_melhoria()
	button_pressed = false
	foco.hide()
	selecao_label.text = identidade.to_upper()
	selecao_label.visible = not identidade.is_empty()
	balao_texto.text = explicacao
	if explicacao.is_empty():
		descricao_balao.hide()
	else:
		_dimensionar_balao()
	tooltip_text = ""
	_atualizar_texto()
	_atualizar_transformacao(false)
	_atualizar_tooltip()


func configurar_melhoria(destaque: String) -> void:
	if destaque.is_empty():
		return
	_melhoria_destaque = destaque
	descricao_label.hide()
	descricao_destaque.show()
	_atualizar_descricao_destaque()


func _limpar_destaque_melhoria() -> void:
	_melhoria_destaque = ""
	descricao_label.show()
	descricao_destaque.hide()


func _atualizar_descricao_destaque() -> void:
	if _melhoria_destaque.is_empty():
		descricao_destaque.hide()
		return
	var novo_valor: String = ""
	var partes: PackedStringArray = _melhoria_destaque.split("→")
	if partes.size() == 2:
		novo_valor = partes[1].strip_edges()
	var linhas: PackedStringArray = ["[center]"]
	for linha in descricao.split("\n"):
		var trecho: String = linha
		if not novo_valor.is_empty() and linha.contains(novo_valor):
			trecho = "[bgcolor=#f0d9ec][color=#1c252d]%s[/color][/bgcolor]" % linha
		else:
			trecho = "[color=#1c252d]%s[/color]" % linha
		linhas.append(trecho)
	linhas.append("[/center]")
	descricao_destaque.text = "\n".join(linhas)


func _dimensionar_balao(largura: float = 240.0) -> void:
	descricao_balao.custom_minimum_size = Vector2(largura, 0.0)
	descricao_balao.size = Vector2(largura, 0.0)
	var estilo: StyleBox = descricao_balao.get_theme_stylebox("panel")
	var margem_esquerda: float = estilo.get_content_margin(SIDE_LEFT) if estilo != null else 0.0
	var margem_direita: float = estilo.get_content_margin(SIDE_RIGHT) if estilo != null else 0.0
	balao_texto.custom_minimum_size = Vector2(maxf(1.0, largura - margem_esquerda - margem_direita), 0.0)
	balao_texto.update_minimum_size()
	descricao_balao.reset_size()
	descricao_balao.queue_sort()
	var altura: float = ceilf(descricao_balao.get_combined_minimum_size().y)
	descricao_balao.size = Vector2(largura, altura)
	descricao_balao.reset_size()
	_configurar_ponta(_lado_ponta, descricao_balao.size)


func _atualizar_tooltip() -> void:
	if not _modo_recompensa or balao_texto.text.is_empty():
		descricao_balao.hide()
		return
	var deve_mostrar: bool = _mouse_sobre or has_focus()
	if deve_mostrar:
		if is_instance_valid(_tooltip_ativo) and _tooltip_ativo != self:
			(_tooltip_ativo.get_node_or_null("DescricaoBalao") as Control).hide()
		_tooltip_ativo = self
		descricao_balao.show()
		_posicionar_balao()
	else:
		descricao_balao.hide()
		if _tooltip_ativo == self:
			_tooltip_ativo = null
			var foco_atual: Control = get_viewport().gui_get_focus_owner() as Control
			if foco_atual != null and foco_atual != self and foco_atual.has_method("_atualizar_tooltip"):
				foco_atual.call("_atualizar_tooltip")


func _posicionar_balao() -> void:
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var carta_rect: Rect2 = get_global_rect()
	for largura in [240.0, 220.0, 200.0]:
		_dimensionar_balao(largura)
		var tamanho: Vector2 = descricao_balao.get_global_rect().size
		var candidatos: Array[Dictionary] = _criar_candidatos_tooltip(carta_rect, tamanho, viewport_rect)
		for candidato in candidatos:
			var corpo: Rect2 = candidato["corpo"]
			var envelope: Rect2 = candidato["envelope"]
			if not viewport_rect.encloses(envelope):
				continue
			if _tooltip_colide_com_outra_carta(envelope) or _tooltip_colide_com_informacao(envelope):
				continue
			_lado_ponta = str(candidato["ponta"])
			descricao_balao.global_position = corpo.position
			_configurar_ponta(_lado_ponta, descricao_balao.size)
			return
	descricao_balao.hide()
	push_warning("Tooltip sem posição protegida disponível para %s." % nome_carta)


func _criar_candidatos_tooltip(carta_rect: Rect2, tamanho: Vector2, viewport_rect: Rect2) -> Array[Dictionary]:
	const PONTA: float = 27.0
	var candidatos: Array[Dictionary] = []
	_candidato_tooltip(candidatos, Vector2(carta_rect.get_center().x - tamanho.x * 0.5, carta_rect.position.y - tamanho.y - 12.0), "baixo", tamanho, PONTA)
	_candidato_tooltip(candidatos, Vector2(carta_rect.get_center().x - tamanho.x * 0.5, carta_rect.end.y + 12.0), "cima", tamanho, PONTA)
	_candidato_tooltip(candidatos, Vector2(carta_rect.position.x - tamanho.x - 12.0, carta_rect.get_center().y - tamanho.y * 0.5), "direita", tamanho, PONTA)
	_candidato_tooltip(candidatos, Vector2(carta_rect.end.x + 12.0, carta_rect.get_center().y - tamanho.y * 0.5), "esquerda", tamanho, PONTA)
	_candidato_tooltip(candidatos, Vector2(carta_rect.get_center().x - tamanho.x * 0.5, carta_rect.position.y + 64.0), "cima", tamanho, PONTA)
	_candidato_tooltip(candidatos, Vector2(carta_rect.position.x - tamanho.x - 12.0, carta_rect.position.y + 32.0), "direita", tamanho, PONTA)
	_candidato_tooltip(candidatos, Vector2(carta_rect.end.x + 12.0, carta_rect.position.y + 32.0), "esquerda", tamanho, PONTA)
	_candidato_tooltip(candidatos, Vector2(viewport_rect.position.x + 8.0, carta_rect.get_center().y - tamanho.y * 0.5), "direita", tamanho, PONTA)
	_candidato_tooltip(candidatos, Vector2(viewport_rect.end.x - tamanho.x - 8.0, carta_rect.get_center().y - tamanho.y * 0.5), "esquerda", tamanho, PONTA)
	var raiz_jogavel: Node = _obter_raiz_jogavel()
	var titulo: Control = raiz_jogavel.get_node_or_null("ResultadoLabel") as Control
	if titulo != null and titulo.visible:
		var acima: Dictionary = candidatos[0]
		if (acima["envelope"] as Rect2).intersects(titulo.get_global_rect().grow(4.0)):
			_candidato_tooltip(candidatos, Vector2((acima["corpo"] as Rect2).position.x, titulo.get_global_rect().end.y + 8.0), "cima", tamanho, PONTA)
	return candidatos


func _candidato_tooltip(candidatos: Array[Dictionary], posicao: Vector2, ponta: String, tamanho: Vector2, altura_ponta: float) -> void:
	var corpo: Rect2 = Rect2(posicao, tamanho)
	var envelope: Rect2 = corpo
	match ponta:
		"baixo":
			envelope.size.y += altura_ponta
		"cima":
			envelope.position.y -= altura_ponta
			envelope.size.y += altura_ponta
		"direita":
			envelope.size.x += altura_ponta
		"esquerda":
			envelope.position.x -= altura_ponta
			envelope.size.x += altura_ponta
	candidatos.append({"corpo": corpo, "envelope": envelope, "ponta": ponta})


func obter_area_tooltip() -> Rect2:
	const PONTA: float = 27.0
	var area: Rect2 = descricao_balao.get_global_rect()
	match _lado_ponta:
		"baixo":
			area.size.y += PONTA
		"cima":
			area.position.y -= PONTA
			area.size.y += PONTA
		"direita":
			area.size.x += PONTA
		"esquerda":
			area.position.x -= PONTA
			area.size.x += PONTA
	return area


func _configurar_ponta(lado: String, tamanho: Vector2) -> void:
	var pontos: PackedVector2Array
	var posicao: Vector2
	match lado:
		"cima":
			pontos = PackedVector2Array([Vector2(32, 27), Vector2(58, 27), Vector2(40, 0)])
			posicao = Vector2(0, -25)
		"direita":
			pontos = PackedVector2Array([Vector2(0, 32), Vector2(0, 58), Vector2(27, 40)])
			posicao = Vector2(tamanho.x - 2, 0)
		"esquerda":
			pontos = PackedVector2Array([Vector2(27, 32), Vector2(27, 58), Vector2(0, 40)])
			posicao = Vector2(-25, 0)
		_:
			pontos = PackedVector2Array([Vector2(32, 0), Vector2(58, 0), Vector2(40, 27)])
			posicao = Vector2(0, tamanho.y - 2)
	balao_ponta.position = posicao
	balao_ponta.polygon = pontos
	balao_ponta_contorno.position = posicao
	balao_ponta_contorno.points = PackedVector2Array([pontos[0], pontos[1], pontos[2], pontos[0]])


func _tooltip_colide_com_outra_carta(candidato: Rect2) -> bool:
	var pai: Node = get_parent()
	if pai == null:
		return false
	for irmao in pai.get_children():
		var carta: Control = irmao as Control
		if carta == null or carta == self or not carta.visible:
			continue
		for nome_no in ["NomeLabel", "CustoLabel", "DescricaoLabel"]:
			var informacao: Control = carta.get_node_or_null(nome_no) as Control
			if informacao != null and informacao.visible and candidato.grow(4.0).intersects(informacao.get_global_rect().grow(4.0)):
				return true
	return false


func _tooltip_colide_com_informacao(candidato: Rect2) -> bool:
	var raiz: Node = _obter_raiz_jogavel()
	var caminhos: Array[String] = [
		"ResultadoLabel",
		"Recompensas/RecompensaAcoes/ConsultarBaralho",
		"Recompensas/RecompensaAcoes/Pular"
	]
	for caminho in caminhos:
		var controle: Control = raiz.get_node_or_null(caminho) as Control
		if controle != null and controle.visible and candidato.grow(4.0).intersects(controle.get_global_rect().grow(4.0)):
			return true
	var informacoes_carta: Array[NodePath] = [
		NodePath("NomeLabel"),
		NodePath("CustoLabel"),
		NodePath("DescricaoLabel")
	]
	for caminho_carta in informacoes_carta:
		var informacao: Control = get_node_or_null(caminho_carta) as Control
		if informacao != null and informacao.visible and candidato.grow(4.0).intersects(informacao.get_global_rect().grow(4.0)):
			return true
	return false


func _obter_raiz_jogavel() -> Node:
	var no: Node = self
	while no != null:
		if no.get_node_or_null("ResultadoLabel") != null:
			return no
		no = no.get_parent()
	return self


func _atualizar_transformacao(animar: bool = true) -> void:
	if _modo_recompensa and _hover_ativo != null and not is_instance_valid(_hover_ativo):
		_hover_ativo = null
	var fator: float = 1.0
	var selecionada: bool = button_pressed and not _modo_recompensa
	var destaque_mouse: bool = (_modo_recompensa and _hover_ativo == self) or (not _modo_recompensa and _mouse_sobre)
	var destaque_foco: bool = has_focus() and (not _modo_recompensa or _hover_ativo == null)
	if selecionada:
		fator = 1.06
		z_index = 10
	elif destaque_mouse:
		fator = ESCALA_FOCO_COMBATE if not _modo_recompensa else ESCALA_FOCO_RECOMPENSA
		z_index = 20
	elif destaque_foco:
		fator = ESCALA_FOCO_COMBATE if not _modo_recompensa else ESCALA_FOCO_RECOMPENSA
		z_index = 20
	else:
		z_index = 0

	var alvo: Vector2 = Vector2.ONE * fator
	if _animacao != null and _animacao.is_valid():
		_animacao.kill()
	_animacao = null
	if not animar:
		scale = alvo
		return
	_animacao = create_tween()
	_animacao.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_animacao.tween_property(self, "scale", alvo, 0.12)


func _atualizar_texto() -> void:
	text = ""
	nome_label.text = nome_carta
	custo_label.text = str(custo)
	descricao_label.text = descricao
	_atualizar_descricao_destaque()
	foco.visible = button_pressed and not _modo_recompensa
	# No combate, a seleção persistente é a camada Foco dentro da carta.
	# O rótulo antigo ficava ancorado depois da raiz e podia sair da viewport;
	# ele continua reservado para identificar cópias na seleção de descanso.
	selecao_label.visible = _modo_descanso and not selecao_label.text.is_empty()
	# O texto da carta ja esta inteiro no componente; tooltip cobre a mao e duplica a informacao.
	tooltip_text = ""
