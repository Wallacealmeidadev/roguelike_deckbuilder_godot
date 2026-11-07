class_name VegaCombateNativo
extends Control
## Adaptador de apresentação: as regras resolvem sem aguardar animações.

var estado_animacao: String = "repouso"
var movimento: Tween
var proximo_braco_distante: bool = false
var ultimo_braco_distante: bool = false
var _ativo: bool = false
var _reduzido: bool = false
var _contatos: Array[ColorRect] = []
@onready var visual: Control = $Visual
@onready var composicao: SubViewportContainer = $Visual/Composicao
@onready var modelo: ApoioCorporalNativoV2 = $Visual/Composicao/Desenho/Modelo


func _ready() -> void:
	resized.connect(_ajustar_tamanho)
	visibility_changed.connect(_sincronizar_visibilidade)
	# Biblioteca própria: acrescentar clips de combate não modifica as prévias.
	var biblioteca: AnimationLibrary = modelo.animacao.get_animation_library(&"").duplicate(true) as AnimationLibrary
	biblioteca.add_animation(&"respirar", preload("res://vega_animada/rig_nativo_v2/respirar.tres"))
	biblioteca.add_animation(&"dano", preload("res://vega_animada/rig_nativo_v2/dano.tres").duplicate(true) as Animation)
	biblioteca.add_animation(&"soco_distante", preload("res://vega_animada/rig_nativo_v2/soco_distante.tres").duplicate(true) as Animation)
	_ajustar_repouso(biblioteca)
	_uniformizar_maos()
	modelo.animacao.remove_animation_library(&"")
	modelo.animacao.add_animation_library(&"", biblioteca)
	modelo.animacao.animation_finished.connect(_ao_terminar_pose)
	for nome: String in ["ContatoEsquerdo", "ContatoDireito"]:
		var contato: ColorRect = ColorRect.new()
		contato.name = nome
		contato.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var material_contato: ShaderMaterial = ShaderMaterial.new()
		material_contato.shader = preload("res://hud_neon/sombra_contato.gdshader")
		contato.material = material_contato
		$Sombra.add_child(contato)
		_contatos.append(contato)
	_ajustar_tamanho()
	reiniciar()


func _ajustar_repouso(biblioteca: AnimationLibrary) -> void:
	# Só os extremos mudam: preparo/impacto/guarda e tempos continuam nativos.
	# A primeira chave da respiração é a fonte única da guarda entre ações.
	var base: Animation = biblioteca.get_animation(&"respirar")
	for nome: StringName in [&"repouso", &"RESET", &"soco", &"soco_distante", &"dano"]:
		var clipe: Animation = biblioteca.get_animation(nome)
		for indice: int in range(11):
			var trilha: int = clipe.find_track(base.track_get_path(indice), Animation.TYPE_VALUE)
			var valor: float = base.track_get_key_value(indice, 0)
			clipe.track_set_key_value(trilha, 0, valor)
			clipe.track_set_key_value(trilha, clipe.track_get_key_count(trilha) - 1, valor)


func _uniformizar_maos() -> void:
	var material_mao: ShaderMaterial = ShaderMaterial.new()
	material_mao.shader = preload("res://vega_animada/rig_nativo_v2/metal_maos.gdshader")
	for braco: BracoNativoV2 in [modelo.braco_original, modelo.braco_distante]:
		# Sprite somente: o miolo de fibras, a orientação e os encaixes não mudam.
		(braco.punho.get_node("Mao") as Sprite2D).material = material_mao
	# Vista palmar própria, sem espelhar a placa do dorso da mão próxima.
	var mao_distante: Sprite2D = modelo.braco_distante.punho.get_node("Mao") as Sprite2D
	mao_distante.texture = preload("res://vega_animada/rig_nativo_v2/mao_palmar_01.png")
	mao_distante.rotation = PI / 2
	mao_distante.scale = Vector2(.12, .12)
	mao_distante.offset = Vector2(-632, -1100)
	mao_distante.get_node("MioloLuva").hide()


func _ajustar_tamanho() -> void:
	if not is_instance_valid(modelo):
		return
	var fator: float = maxf(.001, minf(size.y / 850, size.x / 650))
	var respiro: float = 100 * clampf((1400 - get_viewport_rect().size.x) / 376, 0, 1)
	modelo.scale = Vector2.ONE * fator
	var origem: Vector2 = Vector2(size.x * .5 + (respiro - 365) * fator, size.y - 850 * fator)
	# Margem transparente preserva o alcance fora da caixa de clique.
	modelo.position = origem + Vector2(64, 64)
	for i: int in _contatos.size():
		var pe: Vector2 = Vector2(60 if i == 0 else 650, 838)
		_contatos[i].size = Vector2(150, 32) * fator
		_contatos[i].position = origem + pe * fator - _contatos[i].size * .5


func atualizar_estado(combo_atual: int, em_combate: bool, reduzido: bool) -> void:
	var iniciou: bool = not _ativo
	var mudou_reduzido: bool = _reduzido != reduzido
	_ativo = em_combate and is_visible_in_tree()
	if mudou_reduzido:
		_reduzido = reduzido
		_parar_feedback()
		modelo.definir_movimento_reduzido(reduzido)
		estado_animacao = "repouso"
	if not _ativo:
		_desativar()
		return
	modelo.definir_combo(combo_atual)
	if iniciou or mudou_reduzido:
		_iniciar_repouso()


func _sincronizar_visibilidade() -> void:
	if is_node_ready() and not is_visible_in_tree():
		_ativo = false
		_desativar()


func _desativar() -> void:
	_parar_feedback()
	proximo_braco_distante = false
	ultimo_braco_distante = false
	estado_animacao = "repouso"
	modelo.definir_pose(&"repouso", true)
	modelo.definir_combo(0, true)
	modelo.animacao.pause()


func reiniciar() -> void:
	if not is_instance_valid(modelo):
		return
	_parar_feedback()
	proximo_braco_distante = false
	ultimo_braco_distante = false
	estado_animacao = "repouso"
	visual.position = Vector2.ZERO
	visual.scale = Vector2.ONE
	modelo.definir_pose(&"repouso", true)
	modelo.definir_combo(0, true)
	if _ativo and is_visible_in_tree():
		_iniciar_repouso()
	else:
		modelo.animacao.pause()


func _iniciar_repouso() -> void:
	estado_animacao = "repouso"
	modelo.pose_atual = &"repouso"
	if _reduzido:
		modelo.definir_pose(&"repouso", true)
	else:
		_tocar(&"respirar", .16)


func _tocar(nome: StringName, captura: float) -> void:
	modelo.animacao.play_with_capture(nome, captura, 0, 1, false, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)


func socar() -> void:
	if not _ativo or not is_visible_in_tree():
		return
	_parar_feedback()
	ultimo_braco_distante = proximo_braco_distante
	proximo_braco_distante = not proximo_braco_distante
	estado_animacao = "soco"
	if _reduzido:
		_flash(Color(.75, 1, 1), "soco")
	elif ultimo_braco_distante:
		modelo.pose_atual = &"soco"
		_tocar(&"soco_distante", .1)
		modelo.pose_alterada.emit(&"soco")
	else:
		modelo.reproduzir_soco()


func receber_dano() -> void:
	if not _ativo or not is_visible_in_tree():
		return
	_parar_feedback()
	estado_animacao = "dano"
	if _reduzido:
		modelo.definir_pose(&"repouso", true)
	else:
		modelo.pose_atual = &"dano"
		_tocar(&"dano", .1)
	_flash(Color(1, .58, .88), "dano")


func _flash(cor: Color, estado: String) -> void:
	movimento = create_tween()
	movimento.tween_property(visual, "modulate", cor, .1)
	movimento.tween_property(visual, "modulate", Color.WHITE, .16)
	if _reduzido:
		movimento.tween_callback(_terminar_feedback_reduzido.bind(estado))


func _terminar_feedback_reduzido(estado: String) -> void:
	if _ativo and _reduzido and estado_animacao == estado:
		_iniciar_repouso()


func _ao_terminar_pose(nome: StringName) -> void:
	var acabou_soco: bool = nome in [&"soco", &"soco_distante"] and estado_animacao == "soco"
	if _ativo and (acabou_soco or (nome == &"dano" and estado_animacao == "dano")):
		_iniciar_repouso()


func _parar_feedback() -> void:
	if movimento != null and movimento.is_valid():
		movimento.kill()
	movimento = null
	visual.modulate = Color.WHITE
