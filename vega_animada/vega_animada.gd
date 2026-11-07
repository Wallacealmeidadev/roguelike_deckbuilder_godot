extends Control
## Cutout nativo: oito recortes em pivôs de ombro, cotovelo, quadril e pescoço.
## A apresentação não aplica dano, não consome cartas e não bloqueia input.
var estado_animacao: String = "repouso"
var tempo: float = 0.0
var movimento: Tween
const ALTURA_REFERENCIA: float = 460.0
const ESCALA_MAXIMA: float = 0.44
const QUADRIL_Y: float = -210.0
const OMBRO_FRENTE: float = 0.25
const COTOVELO_FRENTE: float = -1.55
const OMBRO_TRAS: float = -0.45
const COTOVELO_TRAS: float = -1.45
@onready var modelo: Node2D = $Modelo
@onready var tronco: Node2D = $Modelo/Tronco
@onready var cabeca: Node2D = $Modelo/Tronco/Cabeca
@onready var braco_frente: Node2D = $Modelo/Tronco/BracoFrente
@onready var cotovelo: Node2D = $Modelo/Tronco/BracoFrente/Cotovelo
@onready var cotovelo_tras: Node2D = $Modelo/Tronco/BracoTras/Cotovelo
@onready var braco_tras: Node2D = $Modelo/Tronco/BracoTras

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_ajustar_tamanho)
	visibility_changed.connect(_sincronizar_visibilidade)
	_ajustar_tamanho()
	_sincronizar_visibilidade()

func _ajustar_tamanho() -> void:
	var fator: float = minf(ESCALA_MAXIMA, maxf(0.01, (size.y - 12.0) / ALTURA_REFERENCIA))
	modelo.scale = Vector2.ONE * fator
	modelo.position = Vector2(size.x * 0.50, size.y - 8.0)
	queue_redraw()

func _sincronizar_visibilidade() -> void:
	reiniciar()
	set_process(is_visible_in_tree())

func reiniciar() -> void:
	if movimento and movimento.is_valid():
		movimento.kill()
	estado_animacao = "repouso"
	tempo = 0.0
	_pose_base()

func _pose_base() -> void:
	tronco.position = Vector2(0, QUADRIL_Y)
	tronco.rotation = 0.0
	cabeca.rotation = 0.0
	braco_frente.rotation = OMBRO_FRENTE
	cotovelo.rotation = COTOVELO_FRENTE
	braco_tras.rotation = OMBRO_TRAS
	cotovelo_tras.rotation = COTOVELO_TRAS

func _process(delta: float) -> void:
	if estado_animacao != "repouso":
		return
	tempo += delta
	var respiracao: float = sin(tempo * TAU / 2.8)
	tronco.position.y = QUADRIL_Y + respiracao * 3.8
	cabeca.rotation = sin(tempo * TAU / 2.8 - 0.4) * 0.028
	braco_frente.rotation = OMBRO_FRENTE + respiracao * 0.040
	braco_tras.rotation = OMBRO_TRAS - respiracao * 0.030

func socar() -> void:
	if not is_visible_in_tree():
		return
	_iniciar_acao("soco")
	# Antecipação curta, extensão rápida, pausa de impacto e recuperação.
	movimento.tween_property(braco_frente, "rotation", 0.48, 0.10)
	movimento.parallel().tween_property(cotovelo, "rotation", -2.05, 0.10)
	movimento.parallel().tween_property(tronco, "rotation", -0.045, 0.10)
	movimento.parallel().tween_property(cabeca, "rotation", 0.0, 0.10)
	movimento.parallel().tween_property(braco_tras, "rotation", OMBRO_TRAS, 0.10)
	movimento.parallel().tween_property(cotovelo_tras, "rotation", COTOVELO_TRAS, 0.10)
	movimento.tween_property(braco_frente, "rotation", -1.05, 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	movimento.parallel().tween_property(cotovelo, "rotation", -0.26, 0.09)
	movimento.parallel().tween_property(tronco, "position:x", 12.0, 0.09)
	movimento.parallel().tween_property(tronco, "rotation", 0.045, 0.09)
	movimento.tween_interval(0.055)
	movimento.tween_property(braco_frente, "rotation", OMBRO_FRENTE, 0.26).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	movimento.parallel().tween_property(cotovelo, "rotation", COTOVELO_FRENTE, 0.26)
	movimento.parallel().tween_property(tronco, "position:x", 0.0, 0.26)
	movimento.parallel().tween_property(tronco, "rotation", 0.0, 0.26)
	movimento.tween_callback(_concluir_acao)

func receber_dano() -> void:
	if not is_visible_in_tree():
		return
	_iniciar_acao("dano")
	movimento.tween_property(tronco, "rotation", -0.12, 0.075)
	movimento.parallel().tween_property(tronco, "position:x", -12.0, 0.075)
	movimento.parallel().tween_property(cabeca, "rotation", -0.12, 0.075)
	movimento.parallel().tween_property(braco_frente, "rotation", 0.44, 0.075)
	movimento.parallel().tween_property(cotovelo, "rotation", -1.95, 0.075)
	movimento.parallel().tween_property(braco_tras, "rotation", OMBRO_TRAS + 0.10, 0.075)
	movimento.parallel().tween_property(cotovelo_tras, "rotation", COTOVELO_TRAS - 0.15, 0.075)
	movimento.tween_interval(0.045)
	movimento.tween_property(tronco, "rotation", 0.0, 0.30).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	movimento.parallel().tween_property(tronco, "position:x", 0.0, 0.30)
	movimento.parallel().tween_property(cabeca, "rotation", 0.0, 0.30)
	movimento.parallel().tween_property(braco_frente, "rotation", OMBRO_FRENTE, 0.30)
	movimento.parallel().tween_property(cotovelo, "rotation", COTOVELO_FRENTE, 0.30)
	movimento.parallel().tween_property(braco_tras, "rotation", OMBRO_TRAS, 0.30)
	movimento.parallel().tween_property(cotovelo_tras, "rotation", COTOVELO_TRAS, 0.30)
	movimento.tween_callback(_concluir_acao)

func _iniciar_acao(estado: String) -> void:
	if movimento and movimento.is_valid():
		movimento.kill()
	# Uma interrupção parte da pose atual, sem saltar para a pose de repouso.
	estado_animacao = estado
	movimento = create_tween()

func _concluir_acao() -> void:
	_pose_base()
	estado_animacao = "repouso"
	tempo = 0.0

func _draw() -> void:
	if not is_instance_valid(modelo):
		return
	# Sombra independente da arte e imóvel sob os pés.
	var escala: float = modelo.scale.x
	draw_set_transform(modelo.position + Vector2(18, -3) * escala, 0.0, Vector2(1.0, 0.16) * escala)
	draw_circle(Vector2.ZERO, 100.0, Color(0.05, 0.045, 0.04, 0.09))
	draw_circle(Vector2.ZERO, 85.0, Color(0.05, 0.045, 0.04, 0.12))
	draw_circle(Vector2.ZERO, 65.0, Color(0.05, 0.045, 0.04, 0.13))
	draw_set_transform(Vector2.ZERO)
