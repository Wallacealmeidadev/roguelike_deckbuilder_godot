class_name BracoNativoV2
extends Node2D
## Prova FK: AnimationPlayer é o único escritor das rotações. Sem solver de IK.

signal pose_alterada(nome: StringName)

var movimento_reduzido: bool = false
var pose_atual: StringName = &"repouso"
@export var caminho_ombro: NodePath = NodePath("Skeleton2D/Ombro")
@export var caminho_cotovelo: NodePath = NodePath("Skeleton2D/Ombro/Cotovelo")
@export var caminho_punho: NodePath = NodePath("Skeleton2D/Ombro/Cotovelo/Punho")
@onready var animacao: AnimationPlayer = $AnimationPlayer
@onready var esqueleto: Skeleton2D = $Skeleton2D
@onready var ombro: Bone2D = get_node(caminho_ombro) as Bone2D
@onready var cotovelo: Bone2D = get_node(caminho_cotovelo) as Bone2D
@onready var punho: Bone2D = get_node(caminho_punho) as Bone2D


func _ready() -> void:
	animacao.animation_finished.connect(_ao_terminar)
	definir_pose(&"repouso", true)


func definir_pose(nome: StringName, imediato: bool = false) -> void:
	if nome not in [&"repouso", &"guarda", &"extensao"]:
		return
	pose_atual = nome
	if imediato or movimento_reduzido:
		# Uma captura anterior não pode misturar a pose antiga no salto deliberado.
		animacao.clear_caches()
		animacao.play(nome, 0)
		animacao.seek(0, true)
		animacao.pause()
	else:
		animacao.play_with_capture(nome, .16, 0, 1, false, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	pose_alterada.emit(nome)


func reproduzir_soco() -> void:
	if movimento_reduzido:
		definir_pose(&"repouso", true)
		return
	pose_atual = &"soco"
	animacao.play_with_capture(&"soco", .1, 0, 1, false, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	pose_alterada.emit(pose_atual)


func inspecionar_tempo(segundos: float) -> void:
	animacao.play(&"soco", 0)
	animacao.seek(clampf(segundos, 0, .56), true)
	animacao.pause()
	pose_atual = &"inspecao"
	pose_alterada.emit(pose_atual)


func definir_movimento_reduzido(ativo: bool) -> void:
	movimento_reduzido = ativo
	definir_pose(&"repouso", true)


func _ao_terminar(nome: StringName) -> void:
	if nome == &"soco":
		pose_atual = &"repouso"
		pose_alterada.emit(pose_atual)
