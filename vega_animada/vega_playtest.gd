extends Control
## Ilustracao unica provisoria para manter o combate legivel durante o playtest.

var estado_animacao: String = "repouso"
var movimento: Tween
var repouso: Tween
var _reduzido: bool = false
var _contatos: Array[Panel] = []

@onready var visual: Control = $Visual
@onready var arte: TextureRect = $Visual/Arte


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visibility_changed.connect(_ao_mudar_visibilidade)
	resized.connect(_encaixar_sombras)
	arte.self_modulate = Color("dae6f2")
	for nome: String in ["ContatoEsquerdo", "ContatoDireito"]:
		var contato: Panel = Panel.new()
		contato.name = nome
		contato.mouse_filter = Control.MOUSE_FILTER_IGNORE
		contato.z_index = -1
		contato.add_theme_stylebox_override("panel", StyleBoxFlat.new())
		var material_contato: ShaderMaterial = ShaderMaterial.new()
		material_contato.shader = preload("res://hud_neon/sombra_contato.gdshader")
		contato.material = material_contato
		add_child(contato)
		_contatos.append(contato)
	var difusa: Panel = $Sombra
	var material_difuso: ShaderMaterial = ShaderMaterial.new()
	material_difuso.shader = preload("res://hud_neon/sombra_contato.gdshader")
	material_difuso.set_shader_parameter("tinta", Color(0.015, 0.025, 0.04, 0.38))
	difusa.material = material_difuso
	_encaixar_sombras()
	reiniciar()


func _process(_delta: float) -> void:
	var no: Node = get_parent()
	while no != null and no.get("movimento_reduzido") == null:
		no = no.get_parent()
	var reduzido: bool = bool(no.get("movimento_reduzido")) if no != null else false
	if reduzido != _reduzido:
		_reduzido = reduzido
		reiniciar()


func _encaixar_sombras() -> void:
	if not is_instance_valid(arte) or _contatos.size() < 2:
		return
	var fator: float = minf(size.x / arte.texture.get_width(), size.y / arte.texture.get_height())
	var desenho: Vector2 = arte.texture.get_size() * fator
	var origem: Vector2 = (size - desenho) * 0.5
	visual.pivot_offset = Vector2(size.x * 0.5, origem.y + desenho.y * 0.985)
	var difusa: Panel = $Sombra
	difusa.set_anchors_preset(Control.PRESET_TOP_LEFT)
	difusa.position = origem + desenho * Vector2(0.02, 0.955)
	difusa.size = desenho * Vector2(0.96, 0.07)
	for indice: int in 2:
		var centro: Vector2 = origem + desenho * Vector2(0.15 if indice == 0 else 0.84, 0.985 if indice == 0 else 0.972)
		_contatos[indice].size = desenho * Vector2(0.28, 0.042)
		_contatos[indice].position = centro - _contatos[indice].size * 0.5


func _ao_mudar_visibilidade() -> void:
	if not visible and is_node_ready():
		reiniciar()
	elif visible and is_node_ready() and estado_animacao == "repouso":
		_iniciar_repouso()


func reiniciar() -> void:
	_resetar_visual()
	estado_animacao = "repouso"
	if is_visible_in_tree():
		_iniciar_repouso()


func _resetar_visual() -> void:
	if movimento != null and movimento.is_valid():
		movimento.kill()
	if repouso != null and repouso.is_valid():
		repouso.kill()
	visual.position = Vector2.ZERO
	visual.rotation = 0.0
	visual.scale = Vector2.ONE
	visual.modulate = Color.WHITE


func _iniciar_repouso() -> void:
	if repouso != null and repouso.is_valid():
		repouso.kill()
	visual.position = Vector2.ZERO
	visual.rotation = 0.0
	if _reduzido:
		return
	# Respiração com pivô no piso: a silhueta não levita entre os dois pés.
	repouso = create_tween().set_loops()
	repouso.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	repouso.tween_property(visual, "scale", Vector2(1.003, 1.004), 1.2)
	repouso.tween_property(visual, "scale", Vector2.ONE, 1.2)


func socar() -> void:
	if not is_visible_in_tree():
		return
	_iniciar_feedback("soco", Vector2(8.0, -2.0), Color.WHITE)


func receber_dano() -> void:
	if not is_visible_in_tree():
		return
	_iniciar_feedback("dano", Vector2(-6.0, 0.0), Color(1.0, 0.58, 0.88))


func _iniciar_feedback(estado: String, deslocamento: Vector2, cor: Color) -> void:
	_resetar_visual()
	estado_animacao = estado
	movimento = create_tween()
	movimento.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	movimento.tween_property(visual, "position", Vector2.ZERO if _reduzido else deslocamento, 0.10)
	movimento.parallel().tween_property(visual, "modulate", cor, 0.10)
	movimento.tween_property(visual, "position", Vector2.ZERO, 0.22)
	movimento.parallel().tween_property(visual, "modulate", Color.WHITE, 0.22)
	movimento.tween_callback(func() -> void:
		estado_animacao = "repouso"
		_iniciar_repouso()
	)
