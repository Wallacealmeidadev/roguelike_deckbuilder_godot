extends Control
## Candidata cutout da Vega. Preview isolado; ainda nao e carregada pelo combate.

var estado_animacao: String = "repouso"
@export var idle_habilitado: bool = false

@onready var visual: Node2D = $Visual
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_ajustar_tamanho)
	_criar_animacao_idle()
	_ajustar_tamanho()
	reiniciar()


func _ajustar_tamanho() -> void:
	if not is_instance_valid(visual):
		return
	var fator: float = minf(0.52, maxf(0.01, (size.y - 108.0) / 1074.0))
	visual.scale = Vector2.ONE * fator
	visual.position = Vector2(size.x * 0.5 - 310.0 * fator, size.y - 108.0 - 1074.0 * fator)
	queue_redraw()


func _criar_animacao_idle() -> void:
	animation_player.root_node = NodePath("..")
	var biblioteca: AnimationLibrary = AnimationLibrary.new()
	var idle: Animation = Animation.new()
	idle.length = 2.8
	idle.loop_mode = Animation.LOOP_LINEAR
	_adicionar_trilha(idle, NodePath("Visual/Skeleton2D/Torso:position:y"), [0.0, -2.5, 0.0])
	_adicionar_trilha(idle, NodePath("Visual/Skeleton2D/Torso/Cabeca:rotation"), [0.02, 0.045, 0.02])
	_adicionar_trilha(idle, NodePath("Visual/Skeleton2D/Torso/OmbroA:rotation"), [-0.14, -0.122, -0.14])
	_adicionar_trilha(idle, NodePath("Visual/Skeleton2D/Torso/OmbroB:rotation"), [0.12, 0.106, 0.12])
	biblioteca.add_animation("idle", idle)
	animation_player.add_animation_library("", biblioteca)


func _adicionar_trilha(animacao: Animation, caminho: NodePath, valores: Array[float]) -> void:
	var trilha: int = animacao.add_track(Animation.TYPE_VALUE)
	animacao.track_set_path(trilha, caminho)
	animacao.track_set_interpolation_type(trilha, Animation.INTERPOLATION_CUBIC)
	animacao.track_insert_key(trilha, 0.0, valores[0])
	animacao.track_insert_key(trilha, animacao.length * 0.5, valores[1])
	animacao.track_insert_key(trilha, animacao.length, valores[2])


func reiniciar() -> void:
	estado_animacao = "repouso"
	if idle_habilitado and animation_player.has_animation("idle"):
		animation_player.play("idle")
	else:
		animation_player.stop()


func socar() -> void:
	# API reservada; golpes so serao criados apos aprovacao visual do idle.
	reiniciar()


func receber_dano() -> void:
	# API reservada; reacao so sera criada apos aprovacao visual do idle.
	reiniciar()


func _draw() -> void:
	var fator: float = maxf(visual.scale.x, 0.01)
	draw_set_transform(Vector2(size.x * 0.5 + 18.0 * fator, size.y - 48.0), 0.0, Vector2(1.0, 0.18) * fator)
	draw_circle(Vector2.ZERO, 105.0, Color(0.02, 0.025, 0.03, 0.18))
	draw_circle(Vector2.ZERO, 78.0, Color(0.02, 0.025, 0.03, 0.14))
	draw_set_transform(Vector2.ZERO)
