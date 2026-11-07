class_name CamadasGuardaV1
extends Node2D
## Bancada estática de registro. Não substitui a pele ou animação do combate.

const TRONCO: Texture2D = preload("res://prototipos/vega_2d/corpo_articulado/camadas_guarda/tronco_02.png")
const QUADRIL: Texture2D = preload("res://prototipos/vega_2d/corpo_articulado/camadas_guarda/quadril_01.png")
const ALFA_RESIDUAL: Shader = preload("res://prototipos/vega_2d/corpo_articulado/camadas_guarda/alfa_residual.gdshader")
const CORTE_FRENTE: float = 245.0

@export var pescoco_fonte: Vector2 = Vector2(500, 180)
@export var cintura_fonte: Vector2 = Vector2(440, 710)
@export var pescoco_referencia: Vector2 = Vector2(300, 185)
@export var cintura_referencia: Vector2 = Vector2(285, 360)
@export var ombro_proximo_fonte: Vector2 = Vector2(160, 360)
@export var ombro_distante_fonte: Vector2 = Vector2(705, 450)
@export var ombro_proximo_referencia: Vector2 = Vector2(185, 245)
@export var ombro_distante_referencia: Vector2 = Vector2(367, 275)
@export var no_camisa_fonte: Vector2 = Vector2(650, 315)
@export var no_camisa_referencia: Vector2 = Vector2(321, 390)
@export_range(.2, .6, .005) var escala_quadril: float = .385
@export var ajuste_tronco: Vector2 = Vector2.ZERO
@export var ajuste_quadril: Vector2 = Vector2.ZERO

var tronco: Sprite2D
var quadril: Node2D
var quadril_atras: Sprite2D
var quadril_frente: Sprite2D
var registro_tronco: Transform2D
var registro_quadril: Transform2D
var separadas: bool = false
var guias: Node2D
var mostrar_marcos: bool = false:
	set(valor):
		mostrar_marcos = valor
		if is_instance_valid(guias):
			guias.queue_redraw()


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	quadril = Node2D.new()
	quadril.name = "Quadril"
	add_child(quadril)
	# A extensão superior fica atrás do tronco. Camisa e coxas, à frente.
	quadril_atras = _sprite(QUADRIL, "SobreposicaoOculta", quadril)
	quadril_atras.region_enabled = true
	quadril_atras.region_rect = Rect2(0, 0, QUADRIL.get_width(), CORTE_FRENTE)
	quadril_atras.z_index = -1
	quadril_frente = _sprite(QUADRIL, "CamisaEQuadril", quadril)
	quadril_frente.region_enabled = true
	quadril_frente.region_rect = Rect2(0, CORTE_FRENTE, QUADRIL.get_width(), QUADRIL.get_height() - CORTE_FRENTE)
	quadril_frente.position.y = CORTE_FRENTE
	quadril_frente.z_index = 1
	tronco = _sprite(TRONCO, "Tronco", self)
	guias = Node2D.new()
	guias.name = "MarcosRegistro"
	guias.z_index = 10
	add_child(guias)
	guias.draw.connect(_desenhar_marcos)
	recalibrar()


func _sprite(textura: Texture2D, nome: String, pai: Node) -> Sprite2D:
	var parte := Sprite2D.new()
	parte.name = nome
	parte.texture = textura
	parte.centered = false
	var limpeza := ShaderMaterial.new()
	limpeza.shader = ALFA_RESIDUAL
	parte.material = limpeza
	pai.add_child(parte)
	return parte


static func registrar(a: Vector2, b: Vector2, destino_a: Vector2, destino_b: Vector2) -> Transform2D:
	var origem: Vector2 = b - a
	var destino: Vector2 = destino_b - destino_a
	assert(origem.length() > .001 and destino.length() > .001, "Registro precisa de dois pontos distintos")
	var fator: float = destino.length() / origem.length()
	var resultado := Transform2D(destino.angle() - origem.angle(), Vector2.ZERO).scaled(Vector2.ONE * fator)
	resultado.origin = destino_a - resultado * a
	return resultado


func recalibrar() -> void:
	registro_tronco = registrar(pescoco_fonte, cintura_fonte, pescoco_referencia, cintura_referencia)
	registro_quadril = Transform2D(0, Vector2.ZERO).scaled(Vector2.ONE * escala_quadril)
	registro_quadril.origin = no_camisa_referencia - registro_quadril * no_camisa_fonte
	separar(separadas)


func separar(ativo: bool) -> void:
	separadas = ativo
	tronco.transform = registro_tronco
	quadril.transform = registro_quadril
	tronco.position += ajuste_tronco + (Vector2(0, -35) if ativo else Vector2.ZERO)
	quadril.position += ajuste_quadril + (Vector2(0, 35) if ativo else Vector2.ZERO)
	if is_instance_valid(guias):
		guias.queue_redraw()


func _desenhar_marcos() -> void:
	if not mostrar_marcos:
		return
	for ponto: Vector2 in [ombro_proximo_referencia, ombro_distante_referencia, pescoco_referencia, cintura_referencia, no_camisa_referencia]:
		guias.draw_line(ponto - Vector2(6, 0), ponto + Vector2(6, 0), Color("efce75"), 1)
		guias.draw_line(ponto - Vector2(0, 6), ponto + Vector2(0, 6), Color("efce75"), 1)
	if is_instance_valid(tronco):
		for ponto: Vector2 in [ombro_proximo_fonte, ombro_distante_fonte]:
			guias.draw_circle(tronco.transform * ponto, 2, Color("69d6e3"))
		guias.draw_circle(quadril.transform * no_camisa_fonte, 2, Color("ec5fb7"))
