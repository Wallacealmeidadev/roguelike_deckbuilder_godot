extends Control
## Laboratório isolado: não instancia main.tscn nem altera o combate.

@onready var contexto: Node2D = $Contexto
@export var caminho_principal: NodePath = NodePath("Contexto/Braco")
@export var caminho_ampliado: NodePath = NodePath("Zoom")
@export var corpo_articulado: bool = false
@onready var braco: BracoNativoV2 = get_node(caminho_principal) as BracoNativoV2
@onready var zoom: BracoNativoV2 = get_node(caminho_ampliado) as BracoNativoV2
@onready var linha_tempo: HSlider = $Rodape/LinhaTempo
@onready var estado: Label = $Rodape/Estado
@onready var ossos: CheckButton = $Rodape/Controles/Ossos
@onready var sobreposicao: Node2D = $OssosOverlay


func _ready() -> void:
	resized.connect(_layout)
	for nome: String in ["Repouso", "Guarda", "Extensao"]:
		($Rodape/Controles.get_node(nome) as Button).pressed.connect(_pose.bind(StringName(nome.to_lower())))
	($Rodape/Controles/Ciclo as Button).pressed.connect(_ciclo)
	($Rodape/Controles/Reduzido as CheckButton).toggled.connect(_reduzir)
	ossos.toggled.connect(func(_ativo: bool) -> void: sobreposicao.queue_redraw())
	sobreposicao.draw.connect(_desenhar_ossos)
	linha_tempo.value_changed.connect(_inspecionar)
	braco.pose_alterada.connect(func(_nome: StringName) -> void: _atualizar_estado())
	_layout()
	_atualizar_estado()


func _layout() -> void:
	if not is_instance_valid(braco):
		return
	var fator: float = maxf(.1, minf((size.y - 230) / 860.0, size.x * .43 / 730.0))
	contexto.scale = Vector2.ONE * fator
	contexto.position = Vector2(size.x * .26 - 365 * fator, 112)
	# Envelope comum às três poses: não reenquadrar enquanto o braço se move.
	var fator_zoom: float = minf((size.y - 260) / 520.0, size.x * .43 / 470.0)
	zoom.scale = Vector2.ONE * fator_zoom
	zoom.position = Vector2(size.x * .54 + 80 * fator_zoom, 140 + 160 * fator_zoom)
	($LegendaZoom as Label).position = Vector2(size.x * .57, 92)
	if corpo_articulado:
		var painel: Control = get_node("ZoomPanel") as Control
		painel.position = Vector2(size.x * .54, 130)
		painel.size = Vector2(size.x * .43, size.y - 270)
		var fator_corpo: float = minf(painel.size.x / 640.0, painel.size.y / 480.0)
		zoom.scale = Vector2.ONE * fator_corpo
		zoom.position = Vector2((painel.size.x - 730 * fator_corpo) * .5, 0)


func _process(_delta: float) -> void:
	if braco.animacao.is_playing() and braco.pose_atual == &"soco":
		linha_tempo.set_value_no_signal(braco.animacao.current_animation_position)
	if ossos.button_pressed:
		sobreposicao.queue_redraw()


func _desenhar_ossos() -> void:
	if not is_instance_valid(ossos) or not ossos.button_pressed:
		return
	for rig: BracoNativoV2 in [braco, zoom]:
		var pontos: PackedVector2Array = PackedVector2Array()
		for osso: Bone2D in [rig.ombro, rig.cotovelo, rig.punho]:
			pontos.append(sobreposicao.to_local(osso.global_position))
		sobreposicao.draw_polyline(pontos, Color(.2, 1, 1, .9), 2, true)
		for ponto: Vector2 in pontos:
			sobreposicao.draw_circle(ponto, 4, Color(1, .3, .7))
		if rig is OmbroTroncoNativoV2:
			var corpo: OmbroTroncoNativoV2 = rig as OmbroTroncoNativoV2
			var pontos_corpo: PackedVector2Array = PackedVector2Array()
			for osso_corpo: Bone2D in [corpo.pelve, corpo.tronco, corpo.clavicula, corpo.deltoide]:
				pontos_corpo.append(sobreposicao.to_local(osso_corpo.global_position))
			sobreposicao.draw_polyline(pontos_corpo, Color(1, .7, .2), 2, true)
			for ponto_corpo: Vector2 in pontos_corpo:
				sobreposicao.draw_circle(ponto_corpo, 4, Color(1, .7, .2))


func _pose(nome: StringName, imediato: bool = false) -> void:
	linha_tempo.set_value_no_signal(.36 if nome == &"guarda" else .2 if nome == &"extensao" else 0.0)
	for rig: BracoNativoV2 in [braco, zoom]:
		rig.definir_pose(nome, imediato)


func _ciclo() -> void:
	linha_tempo.set_value_no_signal(0)
	for rig: BracoNativoV2 in [braco, zoom]:
		rig.reproduzir_soco()


func _reduzir(ativo: bool) -> void:
	linha_tempo.set_value_no_signal(0)
	for rig: BracoNativoV2 in [braco, zoom]:
		rig.definir_movimento_reduzido(ativo)


func _inspecionar(tempo: float) -> void:
	linha_tempo.set_value_no_signal(tempo)
	for rig: BracoNativoV2 in [braco, zoom]:
		rig.inspecionar_tempo(tempo)
	_atualizar_estado()


func _atualizar_estado() -> void:
	estado.text = "Pose: %s | Ossos com comprimento fixo | Sem IK e sem Combo nesta prova" % braco.pose_atual
	if corpo_articulado:
		estado.text = "Pose: %s | Pele ligada ao ombro/tronco | Pelve e pes fixos | Sem IK" % braco.pose_atual
