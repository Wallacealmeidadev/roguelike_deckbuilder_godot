class_name VegaCombateV2
extends Control
## Apresentação da Vega. Não aplica dano, não resolve cartas nem bloqueia input.

var estado_animacao: String = "repouso"
var movimento: Tween
var _tempo: float = 0.0
var _reduzido: bool = false
var _ativo: bool = false
var _contatos: Array[Panel] = []
@onready var visual: Control = $Visual
@onready var modelo: ModeloVegaCombateV2 = $Visual/Modelo


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_ajustar_tamanho)
	visibility_changed.connect(_sincronizar_visibilidade)
	for nome: String in ["ContatoEsquerdo", "ContatoDireito"]:
		var contato: Panel = Panel.new()
		contato.name = nome
		contato.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var material_contato: ShaderMaterial = ShaderMaterial.new()
		material_contato.shader = preload("res://hud_neon/sombra_contato.gdshader")
		contato.material = material_contato
		$Sombra.add_child(contato)
		_contatos.append(contato)
	_ajustar_tamanho()
	reiniciar()


func _ajustar_tamanho() -> void:
	if not is_instance_valid(modelo):
		return
	var fator: float = maxf(.001, minf(size.y / 850.0, size.x / 650.0))
	modelo.scale = Vector2.ONE * fator
	# A postura larga precisa liberar o medidor de Barreira em janelas compactas.
	var respiro_lateral: float = 100.0 * clampf((1400.0 - get_viewport_rect().size.x) / 376.0, 0.0, 1.0)
	modelo.position = Vector2(size.x * .5 + (respiro_lateral - 365) * fator, size.y - 850 * fator)
	for indice: int in _contatos.size():
		var pe: Vector2 = Vector2(60 if indice == 0 else 650, 838)
		_contatos[indice].size = Vector2(150, 32) * fator
		_contatos[indice].position = modelo.position + pe * fator - _contatos[indice].size * .5
	modelo.atualizar_pose()


func _process(delta: float) -> void:
	_tempo += delta
	modelo.respiracao = sin(_tempo * TAU / 2.4) if estado_animacao == "repouso" and not _reduzido else 0.0
	modelo.atualizar_pose()


func atualizar_estado(combo_atual: int, em_combate: bool, reduzido: bool) -> void:
	if _reduzido != reduzido:
		_reduzido = reduzido
		_parar_movimento()
		modelo.posar_golpe(0)
		modelo.posar_recuo(0)
		modelo.posar_prontidao(0)
		visual.modulate = Color.WHITE
		modelo.respiracao = 0
		modelo.atualizar_pose()
	_ativo = em_combate and is_visible_in_tree()
	modelo.definir_movimento_reduzido(_reduzido)
	modelo.definir_combate(_ativo, not _ativo)
	modelo.definir_combo(combo_atual if _ativo else 0, not _ativo)
	set_process(_ativo and not _reduzido)
	if not _ativo:
		_parar_movimento()
		modelo.posar_golpe(0)
		modelo.posar_recuo(0)
		modelo.posar_prontidao(0)
		modelo.respiracao = 0
		modelo.atualizar_pose()


func _sincronizar_visibilidade() -> void:
	if not is_node_ready():
		return
	if not is_visible_in_tree():
		atualizar_estado(0, false, _reduzido)
	else:
		reiniciar()


func reiniciar() -> void:
	if not is_instance_valid(modelo):
		return
	_parar_movimento()
	modelo.posar_golpe(0)
	modelo.posar_recuo(0)
	modelo.posar_prontidao(0)
	modelo.respiracao = 0
	visual.position = Vector2.ZERO
	visual.scale = Vector2.ONE
	visual.modulate = Color.WHITE
	_ativo = is_visible_in_tree()
	modelo.definir_combate(_ativo, true)
	modelo.definir_combo(0, true)
	set_process(_ativo and not _reduzido)


func _parar_movimento() -> void:
	if movimento != null and movimento.is_valid():
		movimento.kill()
	estado_animacao = "repouso"


func socar() -> void:
	if not is_visible_in_tree() or not _ativo:
		return
	_parar_movimento()
	estado_animacao = "soco"
	modelo.posar_recuo(0)
	visual.modulate = Color.WHITE
	movimento = create_tween()
	if _reduzido:
		movimento.tween_property(visual, "modulate", Color(.75, 1, 1), .1)
		movimento.tween_property(visual, "modulate", Color.WHITE, .16)
	else:
		movimento.tween_method(_interpolar_golpe.bind(modelo.golpe, -.5), 0.0, 1.0, .1)
		movimento.parallel().tween_method(_interpolar_prontidao.bind(modelo.prontidao, 1.0), 0.0, 1.0, .1)
		movimento.tween_method(_interpolar_golpe.bind(-.5, 1.0), 0.0, 1.0, .1)
		movimento.tween_method(_interpolar_golpe.bind(1.0, 0.0), 0.0, 1.0, .16)
		movimento.tween_method(_interpolar_prontidao.bind(1.0, 0.0), 0.0, 1.0, .2)
	movimento.tween_callback(_terminar_movimento)


func _interpolar_golpe(tempo: float, inicio: float, alvo: float) -> void:
	modelo.posar_golpe(lerpf(inicio, alvo, BracoV2Prova.curva_transformacao(tempo)))


func _interpolar_prontidao(tempo: float, inicio: float, alvo: float) -> void:
	modelo.posar_prontidao(lerpf(inicio, alvo, BracoV2Prova.curva_transformacao(tempo)))


func receber_dano() -> void:
	if not is_visible_in_tree() or not _ativo:
		return
	_parar_movimento()
	estado_animacao = "dano"
	movimento = create_tween()
	movimento.tween_method(modelo.posar_recuo, modelo.recuo, 0.0 if _reduzido else 1.0, .1)
	movimento.parallel().tween_method(_interpolar_golpe.bind(modelo.golpe, 0.0), 0.0, 1.0, .1)
	movimento.parallel().tween_method(_interpolar_prontidao.bind(modelo.prontidao, 0.0 if _reduzido else 1.0), 0.0, 1.0, .1)
	movimento.parallel().tween_property(visual, "modulate", Color(1, .58, .88), .1)
	movimento.tween_method(modelo.posar_recuo, 0.0 if _reduzido else 1.0, 0.0, .16)
	movimento.parallel().tween_property(visual, "modulate", Color.WHITE, .16)
	movimento.parallel().tween_method(_interpolar_prontidao.bind(0.0 if _reduzido else 1.0, 0.0), 0.0, 1.0, .16)
	movimento.tween_callback(_terminar_movimento)


func _terminar_movimento() -> void:
	estado_animacao = "repouso"
	modelo.posar_golpe(0)
	modelo.posar_recuo(0)
	modelo.posar_prontidao(0)
	visual.modulate = Color.WHITE
