extends Control
## Realce curto de foco/hover; não intercepta input nem altera o layout.

var intensidade: float = 0.0:
	set(valor):
		intensidade = clampf(valor, 0.0, 1.0)
		queue_redraw()
var cor: Color = Color("22e8f5")
var _origem: Control
var _animacao: Tween
var _ativo: bool = false
var confirmacao: float = 0.0:
	set(valor):
		confirmacao = valor
		queue_redraw()
var _tempo: float = 0.0
var _pressionamento: Tween
var _confirmar: Tween
var _turno: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_origem = get_parent() as Control
	_turno = _origem.name == "EncerrarTurno"
	_origem.mouse_entered.connect(atualizar)
	_origem.mouse_exited.connect(atualizar)
	_origem.focus_entered.connect(atualizar)
	_origem.focus_exited.connect(atualizar)
	_origem.visibility_changed.connect(atualizar)
	if _origem is BaseButton:
		(_origem as BaseButton).button_down.connect(_pressionar)
		(_origem as BaseButton).button_up.connect(_soltar)
	resized.connect(queue_redraw)


func _process(delta: float) -> void:
	# BaseButton não emite um sinal ao trocar disabled; só reavalia se o estado mudou.
	var ativo: bool = _deve_realcar()
	if ativo != _ativo:
		atualizar()
	if _turno and is_visible_in_tree():
		if not _reduzido():
			_tempo += delta
		queue_redraw()


func atualizar() -> void:
	_ativo = _deve_realcar()
	if _animacao != null and _animacao.is_valid():
		_animacao.kill()
	_animacao = create_tween()
	_animacao.tween_property(self, "intensidade", 1.0 if _ativo else 0.0, 0.125).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _pressionar() -> void:
	if _animacao != null and _animacao.is_valid():
		_animacao.kill()
	intensidade = 0.35
	if _turno and not _reduzido() and not (_origem.has_focus() and not (_origem as Button).is_hovered()):
		if _pressionamento != null and _pressionamento.is_valid():
			_pressionamento.kill()
		_origem.pivot_offset = _origem.size * 0.5
		_pressionamento = create_tween()
		_pressionamento.tween_property(_origem, "scale", Vector2.ONE * 0.97, 0.10).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _soltar() -> void:
	if _pressionamento != null and _pressionamento.is_valid():
		_pressionamento.kill()
	if _turno:
		_pressionamento = create_tween()
		_pressionamento.tween_property(_origem, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	atualizar()


func confirmar() -> void:
	if _confirmar != null and _confirmar.is_valid():
		_confirmar.kill()
	confirmacao = 1.0
	_confirmar = create_tween()
	_confirmar.tween_property(self, "confirmacao", 0.0, 0.16 if _reduzido() else 0.26).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_soltar()


func _reduzido() -> bool:
	var no: Node = _origem
	while no != null:
		if no.get("movimento_reduzido") != null:
			return bool(no.get("movimento_reduzido"))
		no = no.get_parent()
	return false


func _deve_realcar() -> bool:
	if not _origem.is_visible_in_tree():
		return false
	if _origem is BaseButton and (_origem as BaseButton).disabled:
		return false
	if _origem is BaseButton:
		return _origem.has_focus() or (_origem as BaseButton).is_hovered()
	return _origem.has_focus() or _origem.get_global_rect().has_point(_origem.get_global_mouse_position())


func _draw() -> void:
	if _origem == null:
		return
	var pronto: bool = _turno and not (_origem as Button).disabled and int(_origem.get_parent().get("energia")) == 0
	var convite: float = (0.18 + 0.10 * sin(_tempo * 2.0)) if pronto else 0.0
	var luz: float = maxf(intensidade, maxf(convite, confirmacao))
	if luz <= 0.001:
		return
	if _origem.name == "Alvo" or _origem.is_in_group("alvo_multiplo"):
		draw_line(Vector2(size.x * 0.34, size.y * 0.36), Vector2(size.x * 0.75, size.y * 0.36), Color(cor, luz * 0.8), 2.0, true)
		return
	var corte: float = minf(14.0, size.y * 0.24)
	var area: Rect2 = Rect2(Vector2(5, 5), size - Vector2(10, 10))
	if _turno:
		var arte: TextureRect = _origem.get_node("BotaoIlustrado") as TextureRect
		var fator: float = minf(size.x / arte.texture.get_width(), size.y / arte.texture.get_height())
		var desenho: Vector2 = arte.texture.get_size() * fator
		area = Rect2((size - desenho) * 0.5 + Vector2(5, 3), desenho - Vector2(10, 6))
		corte = area.size.y * 0.43
	var pontos: PackedVector2Array = PackedVector2Array([
		area.position + Vector2(corte, 0), Vector2(area.end.x - corte, area.position.y),
		Vector2(area.end.x, area.position.y + corte), Vector2(area.end.x, area.end.y - corte),
		Vector2(area.end.x - corte, area.end.y), Vector2(area.position.x + corte, area.end.y),
		Vector2(area.position.x, area.end.y - corte), area.position + Vector2(0, corte), area.position + Vector2(corte, 0)
	])
	draw_polyline(pontos, Color(cor, luz * 0.10), 7.0, true)
	draw_polyline(pontos, Color(cor, luz * 0.72), 1.3, true)
	if confirmacao > 0.0:
		draw_colored_polygon(pontos.slice(0, pontos.size() - 1), Color(cor, confirmacao * 0.20))
	if _turno and not _reduzido() and (intensidade > 0.1 or pronto):
		var x: float = lerpf(area.position.x + corte, area.end.x - corte - 20.0, fmod(_tempo * 0.35, 1.0))
		draw_line(Vector2(x, area.end.y), Vector2(x + 20.0, area.end.y), Color("d8fcff", luz * 0.9), 2.0, true)
