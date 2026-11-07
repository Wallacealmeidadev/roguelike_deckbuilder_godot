class_name BracoRegistradoV1
extends Node2D
## Prova estática. Uma imagem montada, três recortes e marcos compartilhados.
## Sem IK, expansão de Combo, clipes novos ou migração do combate.

const ARTE: Texture2D = preload("res://vega_animada/braco_reconstruido/braco_montado_01.png")
# Centros lidos na imagem produzida, não as coordenadas solicitadas no prompt.
const OMBRO_FONTE := Vector2(478, 135)
const COTOVELO_FONTE := Vector2(558, 650)
const PUNHO_FONTE := Vector2(550, 1190)
const PONTA_FONTE := Vector2(520, 1490)
# Comprimentos do rig aceito. A mão é calibrada no eixo, sem esticar só um lado.
const SUPERIOR: float = 128.06041074
const INFERIOR: float = 133.9084538
const MAO: float = 100.065

var ombro: Bone2D
var cotovelo: Bone2D
var punho: Bone2D
var segmentos: Array[Polygon2D] = []
var registros: Array[Transform2D] = []
var guias: Node2D
var mostrar_marcos: bool = false:
	set(valor):
		mostrar_marcos = valor
		if is_instance_valid(guias):
			guias.queue_redraw()


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var esqueleto := Skeleton2D.new()
	esqueleto.name = "Skeleton2D"
	add_child(esqueleto)
	ombro = _osso(esqueleto, "Ombro", Vector2.ZERO, SUPERIOR)
	cotovelo = _osso(ombro, "Cotovelo", Vector2(SUPERIOR, 0), INFERIOR)
	punho = _osso(cotovelo, "Punho", Vector2(INFERIOR, 0), MAO)
	# O cotovelo fechado pertence ao braço superior. A raiz do antebraço fica
	# atrás dele; não existe sprite de aro ou placa com deslocamento próprio.
	_segmento(ombro, "Superior", OMBRO_FONTE, COTOVELO_FONTE, SUPERIOR,
		PackedVector2Array([Vector2(280, 0), Vector2(750, 0), Vector2(750, 610),
		Vector2(663, 610), Vector2(663, 660), Vector2(628, 704),
		Vector2(558, 713), Vector2(483, 704), Vector2(441, 665),
		Vector2(441, 610), Vector2(280, 610)]), 4)
	_segmento(cotovelo, "Antebraco", COTOVELO_FONTE, PUNHO_FONTE, INFERIOR,
		PackedVector2Array([Vector2(280, 650), Vector2(750, 650),
		Vector2(750, 1190), Vector2(633, 1190), Vector2(615, 1208),
		Vector2(550, 1215), Vector2(485, 1208), Vector2(475, 1190),
		Vector2(280, 1190)]), 2)
	_segmento(punho, "Mao", PUNHO_FONTE, PONTA_FONTE, MAO,
		PackedVector2Array([Vector2(280, 1190), Vector2(750, 1190),
		Vector2(750, 1536), Vector2(280, 1536)]), 1)
	guias = Node2D.new()
	guias.name = "Marcos"
	guias.z_index = 10
	add_child(guias)
	guias.draw.connect(_desenhar_marcos)
	definir_pose(&"neutro")


func _osso(pai: Node, nome: String, origem: Vector2, comprimento: float) -> Bone2D:
	var osso := Bone2D.new()
	osso.name = nome
	osso.position = origem
	osso.auto_calculate_length_and_angle = false
	osso.length = comprimento
	osso.rest = osso.transform
	pai.add_child(osso)
	return osso


func registro(origem: Vector2, destino: Vector2, comprimento: float) -> Transform2D:
	var eixo: Vector2 = destino - origem
	var fator: float = comprimento / eixo.length()
	var base := Transform2D(-eixo.angle(), Vector2.ZERO).scaled(Vector2.ONE * fator)
	base.origin = -(base * origem)
	return base


func _segmento(osso: Bone2D, nome: String, origem: Vector2, destino: Vector2,
		comprimento: float, uv: PackedVector2Array, camada: int) -> void:
	var transformar: Transform2D = registro(origem, destino, comprimento)
	var vertices := PackedVector2Array()
	for ponto: Vector2 in uv:
		vertices.append(transformar * ponto)
	var malha := Polygon2D.new()
	malha.name = nome
	malha.texture = ARTE
	malha.polygon = vertices
	malha.uv = uv
	malha.z_index = camada
	osso.add_child(malha)
	segmentos.append(malha)
	registros.append(transformar)


func definir_pose(nome: StringName) -> void:
	# Mesmos ângulos da prova nativa aceita; apenas amostragem estática.
	match nome:
		&"guarda":
			ombro.rotation = deg_to_rad(105)
			cotovelo.rotation = deg_to_rad(-160)
		&"extensao":
			ombro.rotation = deg_to_rad(-8)
			cotovelo.rotation = deg_to_rad(7)
		_:
			ombro.rotation = PI * .5
			cotovelo.rotation = 0
	punho.rotation = 0
	guias.queue_redraw()


func _desenhar_marcos() -> void:
	if not mostrar_marcos or not is_instance_valid(punho):
		return
	var a: Vector2 = to_local(ombro.global_position)
	var b: Vector2 = to_local(cotovelo.global_position)
	var c: Vector2 = to_local(punho.global_position)
	# A variante corporal pode calibrar/refletir a malha da mão sem mover o osso.
	var d: Vector2 = to_local(segmentos[2].to_global(Vector2(MAO, 0)))
	guias.draw_polyline(PackedVector2Array([a, b, c, d]), Color(1, .83, .3), .8, true)
	for ponto: Vector2 in [a, b, c]:
		guias.draw_circle(ponto, 2, Color(1, .83, .3))
