extends TextureRect
## A caixa de clique permanece parada; somente o desenho e o motor se movem.

var estado_animacao: String = "repouso"
var deslocamento: Vector2 = Vector2.ZERO
var inclinacao: float = 0.0
var impulso: float = 0.0
var tempo: float = 0.0
var movimento_reduzido: bool = false
var _movimento: Tween
var _arte: TextureRect
var _efeitos: Control
var _sombra: Panel


func _ready() -> void:
	preparar()


func preparar() -> void:
	if _arte != null:
		return
	# O script é instalado numa TextureRect já pronta da cena principal.
	set_process(true)
	tempo = float(get_parent().get_index()) * 0.7
	_arte = TextureRect.new()
	_arte.name = "CorpoAnimado"
	_arte.texture = texture
	_arte.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_arte.stretch_mode = stretch_mode
	_arte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# A textura do contêiner continua disponível para retratos e inspeções.
	self_modulate.a = 0.0
	_arte.show_behind_parent = false
	add_child(_arte)
	_arte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_arte.modulate = Color("d3e4f5")
	_efeitos = Control.new()
	_efeitos.name = "Motor"
	_efeitos.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_efeitos.draw.connect(_desenhar_motor)
	_arte.add_child(_efeitos)
	_sombra = Panel.new()
	_sombra.name = "SombraDrone"
	_sombra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material_sombra: ShaderMaterial = ShaderMaterial.new()
	material_sombra.shader = preload("res://hud_neon/sombra_contato.gdshader")
	_sombra.material = material_sombra
	_sombra.add_theme_stylebox_override("panel", StyleBoxFlat.new())
	_sombra.z_index = -1
	add_child(_sombra)
	visibility_changed.connect(_ao_mudar_visibilidade)


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	var raiz: Node = _raiz_combate()
	var reduzido: bool = bool(raiz.get("movimento_reduzido")) if raiz != null else false
	if reduzido and not movimento_reduzido:
		reiniciar()
	movimento_reduzido = reduzido
	if not movimento_reduzido:
		tempo += delta
	var ondulacao: Vector2 = Vector2(sin(tempo * 1.3) * 1.5, sin(tempo * 2.0) * 4.0) if not movimento_reduzido else Vector2.ZERO
	_arte.position = deslocamento + ondulacao
	_arte.pivot_offset = size * Vector2(0.5, 0.55)
	_arte.rotation = inclinacao + (sin(tempo * 1.3) * 0.012 if not movimento_reduzido else 0.0)
	_sombra.position = Vector2(size.x * 0.05, size.y * 1.05)
	_sombra.size = Vector2(size.x * 0.90, maxf(14.0, size.y * 0.095))
	_sombra.modulate.a = 0.82 + (ondulacao.y / 80.0)
	_efeitos.queue_redraw()


func _raiz_combate() -> Node:
	var no: Node = get_parent()
	while no != null:
		if no.has_method("_atualizar_interface"):
			return no
		no = no.get_parent()
	return null


func _ao_mudar_visibilidade() -> void:
	if not is_visible_in_tree():
		reiniciar()


func reiniciar() -> void:
	if _movimento != null and _movimento.is_valid():
		_movimento.kill()
	deslocamento = Vector2.ZERO
	inclinacao = 0.0
	impulso = 0.0
	estado_animacao = "repouso"


func reagir(acao: String) -> void:
	reiniciar()
	if not is_visible_in_tree():
		return
	var raiz: Node = _raiz_combate()
	movimento_reduzido = bool(raiz.get("movimento_reduzido")) if raiz != null else false
	estado_animacao = acao
	impulso = 1.0
	_movimento = create_tween().set_parallel(true)
	if not movimento_reduzido:
		var avancar: bool = acao == "ataque"
		deslocamento = Vector2(14.0 if acao == "dano" else -5.0, 0.0)
		_movimento.tween_property(self, "deslocamento", Vector2(-22.0, -3.0) if avancar else Vector2.ZERO, 0.10).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_movimento.chain().tween_property(self, "deslocamento", Vector2.ZERO, 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		inclinacao = -0.045 if avancar else 0.03
		_movimento.parallel().tween_property(self, "inclinacao", 0.0, 0.16)
	_movimento.tween_property(self, "impulso", 0.0, 0.16 if movimento_reduzido else 0.26)
	_movimento.chain().tween_callback(func() -> void: estado_animacao = "repouso")


func _desenhar_motor() -> void:
	var centro: Vector2 = size * Vector2(0.55, 0.59)
	var raio: float = size.x * 0.075
	var luz: float = 0.32 + impulso * 0.5
	for indice: int in 4:
		_efeitos.draw_circle(centro + Vector2(0, float(indice) * 2.0), raio * (1.0 + indice * 0.24), Color(0.12, 0.9, 1.0, luz * (0.16 - indice * 0.03)))
	_efeitos.draw_arc(centro, raio, 0.05, PI - 0.05, 24, Color(0.5, 1.0, 1.0, luz), 1.5, true)
