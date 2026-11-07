extends Control
## Rig segmentado isolado da Vega, com poses dirigidas por AnimationPlayer.

const ALTURA_REFERENCIA: float = 460.0
const ESCALA_MAXIMA: float = 0.44
const DURACAO_REPOUSO: float = 2.8
const DURACAO_SOCO: float = 0.56
const DURACAO_DANO: float = 0.42

const POSICAO_TRONCO: Vector2 = Vector2(0.0, -210.0)
const POSICAO_CABECA: Vector2 = Vector2(6.0, -130.0)
const ROTACAO_BRACO_FRENTE: float = 0.50
const ROTACAO_ANTEBRACO_FRENTE: float = -1.55
const ROTACAO_PUNHO_FRENTE: float = 0.0
const ROTACAO_BRACO_TRAS: float = -0.70
const ROTACAO_ANTEBRACO_TRAS: float = -1.45
const ROTACAO_PUNHO_TRAS: float = 0.0

var estado_animacao: String = "repouso"

@onready var modelo: Node2D = $Modelo
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_ajustar_tamanho)
	visibility_changed.connect(_ao_mudar_visibilidade)
	_configurar_animacoes()
	_ajustar_tamanho()
	reiniciar()

func _ajustar_tamanho() -> void:
	var fator: float = minf(ESCALA_MAXIMA, maxf(0.01, (size.y - 12.0) / ALTURA_REFERENCIA))
	modelo.scale = Vector2.ONE * fator
	modelo.position = Vector2(size.x * 0.50, size.y - 8.0)

func _ao_mudar_visibilidade() -> void:
	if not is_node_ready():
		return
	var visivel_na_arvore: bool = is_visible_in_tree()
	animation_player.active = visivel_na_arvore

func _criar_animacao(nome: StringName, duracao: float, loop: bool) -> Animation:
	var animacao: Animation = Animation.new()
	animacao.resource_name = String(nome)
	animacao.length = duracao
	animacao.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	return animacao

func _adicionar_trilha(animacao: Animation, caminho: NodePath, tempos: Array[float], valores: Array[Variant]) -> void:
	var indice: int = animacao.add_track(Animation.TYPE_VALUE)
	animacao.track_set_path(indice, caminho)
	for i: int in tempos.size():
		animacao.track_insert_key(indice, tempos[i], valores[i])

func _configurar_animacoes() -> void:
	var biblioteca: AnimationLibrary = AnimationLibrary.new()
	biblioteca.add_animation("guarda", _animacao_guarda())
	biblioteca.add_animation("repouso", _animacao_repouso())
	biblioteca.add_animation("soco", _animacao_soco())
	biblioteca.add_animation("dano", _animacao_dano())
	biblioteca.add_animation("reiniciar", _animacao_reiniciar())
	animation_player.add_animation_library("", biblioteca)
	animation_player.animation_finished.connect(_ao_terminar_animacao)

func _animacao_guarda() -> Animation:
	var animacao: Animation = _criar_animacao("guarda", 0.08, false)
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco:position"), [0.0], [POSICAO_TRONCO])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/Cabeca:position"), [0.0], [POSICAO_CABECA])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoFrente:rotation"), [0.0], [ROTACAO_BRACO_FRENTE])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoFrente/AntebracoFrente:rotation"), [0.0], [ROTACAO_ANTEBRACO_FRENTE])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoFrente/AntebracoFrente/PunhoFrente:rotation"), [0.0], [ROTACAO_PUNHO_FRENTE])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoTras:rotation"), [0.0], [ROTACAO_BRACO_TRAS])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoTras/AntebracoTras:rotation"), [0.0], [ROTACAO_ANTEBRACO_TRAS])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoTras/AntebracoTras/PunhoTras:rotation"), [0.0], [ROTACAO_PUNHO_TRAS])
	return animacao

func _animacao_repouso() -> Animation:
	var animacao: Animation = _criar_animacao("repouso", DURACAO_REPOUSO, true)
	var tempos: Array[float] = [0.0, DURACAO_REPOUSO * 0.5, DURACAO_REPOUSO]
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco:position"), tempos, [POSICAO_TRONCO, POSICAO_TRONCO + Vector2(0.0, -4.0), POSICAO_TRONCO])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/Cabeca:rotation"), tempos, [0.0, -0.025, 0.0])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoFrente:rotation"), tempos, [ROTACAO_BRACO_FRENTE, ROTACAO_BRACO_FRENTE - 0.025, ROTACAO_BRACO_FRENTE])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoTras:rotation"), tempos, [ROTACAO_BRACO_TRAS, ROTACAO_BRACO_TRAS + 0.025, ROTACAO_BRACO_TRAS])
	return animacao

func _animacao_soco() -> Animation:
	var animacao: Animation = _criar_animacao("soco", DURACAO_SOCO, false)
	var tempos: Array[float] = [0.0, 0.10, 0.24, 0.30, DURACAO_SOCO]
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco:rotation"), tempos, [0.0, -0.035, 0.08, 0.10, 0.0])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoFrente:rotation"), tempos, [ROTACAO_BRACO_FRENTE, ROTACAO_BRACO_FRENTE - 0.12, ROTACAO_BRACO_FRENTE - 0.32, ROTACAO_BRACO_FRENTE - 0.24, ROTACAO_BRACO_FRENTE])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoFrente/AntebracoFrente:rotation"), tempos, [ROTACAO_ANTEBRACO_FRENTE, ROTACAO_ANTEBRACO_FRENTE + 0.25, ROTACAO_ANTEBRACO_FRENTE + 0.75, ROTACAO_ANTEBRACO_FRENTE + 0.62, ROTACAO_ANTEBRACO_FRENTE])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoFrente/AntebracoFrente/PunhoFrente:rotation"), tempos, [ROTACAO_PUNHO_FRENTE, -0.08, -0.16, -0.10, ROTACAO_PUNHO_FRENTE])
	return animacao

func _animacao_dano() -> Animation:
	var animacao: Animation = _criar_animacao("dano", DURACAO_DANO, false)
	var tempos: Array[float] = [0.0, 0.12, 0.26, DURACAO_DANO]
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco:position"), tempos, [POSICAO_TRONCO, POSICAO_TRONCO + Vector2(-8.0, 0.0), POSICAO_TRONCO + Vector2(3.0, 0.0), POSICAO_TRONCO])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco:rotation"), tempos, [0.0, -0.08, 0.04, 0.0])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoFrente:rotation"), tempos, [ROTACAO_BRACO_FRENTE, ROTACAO_BRACO_FRENTE + 0.16, ROTACAO_BRACO_FRENTE + 0.06, ROTACAO_BRACO_FRENTE])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoTras:rotation"), tempos, [ROTACAO_BRACO_TRAS, ROTACAO_BRACO_TRAS - 0.16, ROTACAO_BRACO_TRAS - 0.06, ROTACAO_BRACO_TRAS])
	return animacao

func _animacao_reiniciar() -> Animation:
	var animacao: Animation = _criar_animacao("reiniciar", 0.01, false)
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco:position"), [0.0], [POSICAO_TRONCO])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco:rotation"), [0.0], [0.0])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/Cabeca:position"), [0.0], [POSICAO_CABECA])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/Cabeca:rotation"), [0.0], [0.0])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoFrente:rotation"), [0.0], [ROTACAO_BRACO_FRENTE])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoFrente/AntebracoFrente:rotation"), [0.0], [ROTACAO_ANTEBRACO_FRENTE])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoFrente/AntebracoFrente/PunhoFrente:rotation"), [0.0], [ROTACAO_PUNHO_FRENTE])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoTras:rotation"), [0.0], [ROTACAO_BRACO_TRAS])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoTras/AntebracoTras:rotation"), [0.0], [ROTACAO_ANTEBRACO_TRAS])
	_adicionar_trilha(animacao, NodePath("Modelo/Skeleton2D/Tronco/BracoTras/AntebracoTras/PunhoTras:rotation"), [0.0], [ROTACAO_PUNHO_TRAS])
	return animacao

func _ao_terminar_animacao(nome: StringName) -> void:
	if nome == "repouso":
		estado_animacao = "repouso"
		return
	if nome == "soco" or nome == "dano" or nome == "guarda" or nome == "reiniciar":
		estado_animacao = "repouso"
		animation_player.play("repouso", 0.08)

func socar() -> void:
	if not is_visible_in_tree():
		return
	estado_animacao = "soco"
	animation_player.play("soco", 0.08)

func receber_dano() -> void:
	if not is_visible_in_tree():
		return
	estado_animacao = "dano"
	animation_player.play("dano", 0.08)

func reiniciar() -> void:
	animation_player.stop()
	animation_player.play("reiniciar")
	animation_player.advance(0.0)
	animation_player.stop()
	estado_animacao = "repouso"
	animation_player.play("repouso")
