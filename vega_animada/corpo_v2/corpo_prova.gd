class_name VegaCorpoV2Prova
extends Node2D
## Montagem de apresentação isolada. Não conhece estado da run ou cartas.

signal apresentacao_alterada

const BASE: Texture2D = preload("res://vega_animada/corpo_v2/corpo_base_01.png")
const BRACO: Script = preload("res://vega_animada/braco_v2/braco_prova.gd")
const TAMANHO: Vector2 = Vector2(1024, 1536)
# Ponto visível de encaixe na cabeça do feixe, não centro do retângulo da UV.
const JUNTA_LOCAL: Vector2 = Vector2(-40, 45)
const OMBRO_FRENTE: Vector2 = Vector2(345, 345)
const OMBRO_TRAS: Vector2 = Vector2(702, 390)

var corpo: Sprite2D
var braco_frente: BracoV2Prova
var braco_tras: BracoV2Prova
var combo: int:
	get:
		return braco_frente.combo if is_instance_valid(braco_frente) else 0
var em_combate: bool:
	get:
		return is_instance_valid(braco_frente) and braco_frente.destino > 0.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	braco_tras = _criar_braco("BracoTras", OMBRO_TRAS, Vector2(.85, .85), -.24, 0)
	braco_frente = _criar_braco("BracoFrente", OMBRO_FRENTE, Vector2(-.95, .95), .18, 10)
	corpo = Sprite2D.new()
	corpo.name = "CorpoBase"
	corpo.texture = BASE
	corpo.centered = false
	# Deltoides e roupa ocluem os encaixes, inclusive placas/juntas dos braços.
	corpo.z_index = 50
	add_child(corpo)
	queue_redraw()


func _criar_braco(nome: String, ombro: Vector2, escala: Vector2, angulo: float, camada: int) -> BracoV2Prova:
	var braco: BracoV2Prova = BRACO.new() as BracoV2Prova
	braco.name = nome
	braco.scale = escala
	braco.rotation = angulo
	braco.z_index = camada
	braco.position = ombro - (JUNTA_LOCAL * escala).rotated(angulo)
	add_child(braco)
	return braco


func definir_combate(ativo: bool, imediato: bool = false) -> void:
	for braco: BracoV2Prova in [braco_frente, braco_tras]:
		braco.definir_combate(ativo, imediato)
	apresentacao_alterada.emit()


func definir_combo(valor: int, imediato: bool = false) -> void:
	for braco: BracoV2Prova in [braco_frente, braco_tras]:
		braco.definir_combo(valor, imediato)
	apresentacao_alterada.emit()


func definir_movimento_reduzido(ativo: bool) -> void:
	for braco: BracoV2Prova in [braco_frente, braco_tras]:
		braco.definir_movimento_reduzido(ativo)
	apresentacao_alterada.emit()


func _draw() -> void:
	# Contatos fixos no solo: nesta prova o corpo/pernas não se movem.
	for pe: Vector2 in [Vector2(173, 1482), Vector2(871, 1460)]:
		draw_set_transform(pe, 0.0, Vector2(1, .14))
		draw_circle(Vector2.ZERO, 104, Color(.02, .025, .035, .35))
	draw_set_transform(Vector2.ZERO)
