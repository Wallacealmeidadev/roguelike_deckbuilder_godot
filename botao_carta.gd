extends Button

const MOLDURA_ATAQUE: Texture2D = preload("res://hud_neon/carta_ataque.svg")
const MOLDURA_HABILIDADE: Texture2D = preload("res://hud_neon/carta_habilidade.svg")
const ARTE_GOLPE: Texture2D = preload("res://assets/ui/runtime/cartas/arte_golpe_impacto_hq_prova.png")
const ARTE_PROTECAO: Texture2D = preload("res://assets/ui/runtime/cartas/arte_protecao_bloqueio_hq_prova.png")
const ARTE_QUEBRA_CHASSI: Texture2D = preload("res://assets/ui/runtime/cartas/arte_quebra_chassi_ruptura_hq_prova.png")
const ARTE_DIRETO_HIDRAULICO: Texture2D = preload("res://assets/ui/runtime/cartas/arte_direto_hidraulico_hq.png")
const ARTE_BRECHA: Texture2D = preload("res://assets/ui/runtime/cartas/arte_brecha_hq.png")
const ARTE_PULSO_DEBILITANTE: Texture2D = preload("res://assets/ui/runtime/cartas/arte_pulso_debilitante_hq.png")
const ARTE_GOLPE_ARIETE: Texture2D = preload("res://assets/ui/runtime/cartas/arte_golpe_ariete_hq.png")
const ARTE_RUPTURA_PRESSAO: Texture2D = preload("res://assets/ui/runtime/cartas/arte_ruptura_pressao_hq.png")
const ARTE_PLACA_REFORCADA: Texture2D = preload("res://assets/ui/runtime/cartas/arte_placa_reforcada_hq.png")
const TAMANHO_BASE: Vector2 = Vector2(150, 240)
const ESCALA_FOCO_COMBATE: float = 1.22
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
var _apresentacao_mao: bool = false
var _posicao_repouso: Vector2 = Vector2.ZERO
var _rotacao_repouso: float = 0.0
var _em_consumo: bool = false
var _animacao_dica: Tween
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
	balao_ponta.hide()
	balao_ponta_contorno.hide()
	for estado: String in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		var transparente: StyleBoxFlat = StyleBoxFlat.new()
		transparente.bg_color = Color.TRANSPARENT
		add_theme_stylebox_override(estado, transparente)


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
	var mudou_escala: bool = not is_equal_approx(escala, _escala_visual)
	_escala_visual = escala
	custom_minimum_size = TAMANHO_BASE * escala
	if permitir_reducao:
		# A mão é um Control com layout manual; seu posicionamento usa o
		# tamanho efetivo, não apenas o mínimo solicitado.
		size = custom_minimum_size
	pivot_offset = Vector2(custom_minimum_size.x * 0.5, custom_minimum_size.y) if permitir_reducao else custom_minimum_size * 0.5
	custo_label.add_theme_font_size_override("font_size", maxi(11, roundi(18.0 * escala)))
	var tamanho_titulo: float = 12.0 if nome_carta.length() > 14 else 15.0
	var tamanho_nome: int = maxi(10, roundi(tamanho_titulo * escala))
	var fonte_nome: Font = nome_label.get_theme_font("font")
	while tamanho_nome > 9 and fonte_nome.get_string_size(nome_carta, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho_nome).x > custom_minimum_size.x * 0.75:
		tamanho_nome -= 1
	nome_label.add_theme_font_size_override("font_size", tamanho_nome)
	nome_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	nome_label.clip_text = true
	nome_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	descricao_label.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Regular.ttf"))
	descricao_label.add_theme_font_size_override("font_size", maxi(10, roundi(12.0 * escala)))
	descricao_destaque.add_theme_font_size_override("normal_font_size", maxi(10, roundi(12.0 * escala)))
	selecao_label.add_theme_font_size_override("font_size", roundi(13.0 * escala))
	balao_texto.add_theme_font_size_override("font_size", maxi(roundi(11.0 * escala), 12))
	if mudou_escala or not _apresentacao_mao:
		_atualizar_transformacao(false)


func configurar_apresentacao_mao(posicao: Vector2, angulo: float) -> void:
	if _apresentacao_mao and _posicao_repouso.is_equal_approx(posicao) and is_equal_approx(_rotacao_repouso, angulo):
		return
	var reorganizar: bool = _apresentacao_mao
	_apresentacao_mao = true
	_posicao_repouso = posicao
	_rotacao_repouso = angulo
	_atualizar_transformacao(reorganizar)


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


func animar_consumo(movimento_reduzido: bool = false) -> void:
	_em_consumo = true
	if _animacao != null and _animacao.is_valid():
		_animacao.kill()
	_mouse_sobre = false
	descricao_balao.hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	z_index = 180
	_animacao = create_tween()
	_animacao.set_parallel(true)
	if not movimento_reduzido:
		_animacao.tween_property(self, "position", position + Vector2(0.0, 12.0), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_animacao.tween_property(self, "scale", scale * 0.94, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_animacao.tween_property(self, "modulate:a", 0.0, 0.12 if movimento_reduzido else 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_animacao.finished.connect(queue_free)


func normalizar_apresentacao_mao() -> void:
	if _animacao != null and _animacao.is_valid():
		_animacao.kill()
	modulate = Color.WHITE
	_atualizar_transformacao(false)


func _obter_arte(id_carta: String) -> Texture2D:
	match id_carta:
		"protecao":
			return ARTE_PROTECAO
		"pulso_debilitante":
			return ARTE_PULSO_DEBILITANTE
		"placa_reforcada":
			return ARTE_PLACA_REFORCADA
		"quebra_chassi":
			return ARTE_QUEBRA_CHASSI
		"golpe":
			return ARTE_GOLPE
		"direto_hidraulico":
			return ARTE_DIRETO_HIDRAULICO
		"brecha":
			return ARTE_BRECHA
		"golpe_ariete":
			return ARTE_GOLPE_ARIETE
		"ruptura_pressao":
			return ARTE_RUPTURA_PRESSAO
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
	_atualizar_transformacao(_modo_recompensa or _mouse_sobre)
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
			trecho = "[bgcolor=#51255c][color=#ffffff]%s[/color][/bgcolor]" % linha
		else:
			trecho = "[color=#e6f4ff]%s[/color]" % linha
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
		var estava_visivel: bool = descricao_balao.visible
		if is_instance_valid(_tooltip_ativo) and _tooltip_ativo != self:
			(_tooltip_ativo.get_node_or_null("DescricaoBalao") as Control).hide()
		_tooltip_ativo = self
		descricao_balao.show()
		_posicionar_balao()
		if not estava_visivel:
			if _animacao_dica != null and _animacao_dica.is_valid():
				_animacao_dica.kill()
			var reduzido: bool = _obter_raiz_jogavel().get("movimento_reduzido") == true
			descricao_balao.modulate.a = 1.0 if has_focus() or reduzido else 0.0
			_animacao_dica = create_tween()
			_animacao_dica.tween_property(descricao_balao, "modulate:a", 1.0, 0.0 if has_focus() else 0.125).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
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
	for largura in [240.0, 220.0, 200.0, 180.0, 160.0]:
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
	const PONTA: float = 0.0
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
	const PONTA: float = 0.0
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
	balao_ponta.hide()
	balao_ponta_contorno.hide()
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
		if candidato.grow(4.0).intersects(carta.get_global_rect().grow(4.0)):
			return true
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
	if _em_consumo:
		return
	if _modo_recompensa and _hover_ativo != null and not is_instance_valid(_hover_ativo):
		_hover_ativo = null
	var fator: float = 1.0
	var selecionada: bool = button_pressed and not _modo_recompensa
	var destaque_mouse: bool = (_modo_recompensa and _hover_ativo == self) or (not _modo_recompensa and _mouse_sobre)
	var destaque_foco: bool = has_focus() and (not _modo_recompensa or _hover_ativo == null)
	var erguida: bool = selecionada or destaque_mouse or destaque_foco
	if selecionada:
		fator = ESCALA_FOCO_COMBATE
		z_index = 160
	elif destaque_mouse:
		fator = ESCALA_FOCO_COMBATE if not _modo_recompensa else ESCALA_FOCO_RECOMPENSA
		z_index = 140
	elif destaque_foco:
		fator = ESCALA_FOCO_COMBATE if not _modo_recompensa else ESCALA_FOCO_RECOMPENSA
		z_index = 150
	else:
		# Cada carta é uma pilha completa: arte e texto não atravessam a vizinha.
		z_index = get_index() * 8 if _apresentacao_mao else 0

	var alvo: Vector2 = Vector2.ONE * fator
	var posicao_alvo: Vector2 = _posicao_repouso - Vector2(0.0, 35.0 * _escala_visual) if _apresentacao_mao and erguida else _posicao_repouso
	var angulo_alvo: float = 0.0 if _apresentacao_mao and erguida else _rotacao_repouso
	var raiz: Node = _obter_raiz_jogavel()
	if raiz.get("movimento_reduzido") == true:
		alvo = Vector2.ONE
		posicao_alvo = _posicao_repouso
		angulo_alvo = _rotacao_repouso
	if _animacao != null and _animacao.is_valid():
		_animacao.kill()
	_animacao = null
	if not animar:
		scale = alvo
		if _apresentacao_mao:
			position = posicao_alvo
			rotation = angulo_alvo
		return
	_animacao = create_tween()
	_animacao.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var duracao: float = 0.0 if raiz.get("movimento_reduzido") == true or _apresentacao_mao and destaque_foco and not destaque_mouse else 0.16
	_animacao.parallel().tween_property(self, "scale", alvo, duracao)
	if _apresentacao_mao:
		_animacao.parallel().tween_property(self, "position", posicao_alvo, duracao)
		_animacao.parallel().tween_property(self, "rotation", angulo_alvo, duracao)


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
