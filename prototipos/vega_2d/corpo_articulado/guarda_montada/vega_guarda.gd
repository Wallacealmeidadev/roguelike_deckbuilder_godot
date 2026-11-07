class_name VegaGuardaMontadaV1
extends CamadasGuardaV1
## Registro estático das peças existentes. Não é um novo rig de combate.

const BASE: Texture2D = preload("res://vega_animada/combate_v2/base_e_punhos_01.png")
const BRACO_PROXIMO: Script = preload("res://prototipos/vega_2d/braco_reconstruido/braco_registrado.gd")
const BRACO_DISTANTE: Script = preload("res://prototipos/vega_2d/braco_reconstruido/distante/braco_distante.gd")
const PALETA: Shader = preload("res://prototipos/vega_2d/braco_reconstruido/distante/paleta_distante.gdshader")
const PESCOCO: Shader = preload("res://prototipos/vega_2d/corpo_articulado/guarda_montada/pescoco.gdshader")
# Medidos na guarda/Combo zero da prova 15, em coordenadas do Modelo.
const OMBRO_PROXIMO_ACEITO := Vector2(205.2311, 225.7456)
const OMBRO_DISTANTE_ACEITO := Vector2(412.3492, 253.8059)
const CORTE_CAP_FONTE: float = 220.0

@export var insercao_proxima_fonte: Vector2 = Vector2(180, 400)
@export var insercao_distante_fonte: Vector2 = Vector2(710, 450)
# Vetores manuais da guarda de conceito, relativos à inserção próxima.
# São apresentação estática; não alteram alcance/dano ou o rig aprovado.
@export var cotovelo_proximo_relativo: Vector2 = Vector2(31, 117)
@export var punho_proximo_relativo: Vector2 = Vector2(118, 20)
# Encaixe na base do pescoço do recorte, não no ponto alto da nuca antiga.
@export var pescoco_cabeca_fonte: Vector2 = Vector2(610, 140)
@export_range(.7, 1.2, .01) var escala_cabeca: float = .85

var cabeca: Polygon2D
var proximo: BracoRegistradoV1
var distante: BracoDistanteRegistradoV1
var registro_bracos: Transform2D
var biceps_frente: Polygon2D


func _ready() -> void:
	super._ready()
	# A região tem alfa próprio; UV só delimita cabeça/cabelo/pescoço,
	# excluindo ombros e corpo antigos. Não grava outro bitmap.
	cabeca = Polygon2D.new()
	cabeca.name = "CabecaExistente"
	cabeca.texture = BASE
	cabeca.uv = PackedVector2Array([
		Vector2(500, 0), Vector2(755, 0), Vector2(755, 175),
		Vector2(680, 175), Vector2(665, 171), Vector2(650, 185),
		Vector2(622, 180), Vector2(600, 169), Vector2(580, 156),
		Vector2(562, 143), Vector2(550, 140), Vector2(500, 140)])
	cabeca.polygon = cabeca.uv.duplicate()
	var transicao := ShaderMaterial.new()
	transicao.shader = PESCOCO
	cabeca.material = transicao
	cabeca.z_index = 1
	add_child(cabeca)
	proximo = BRACO_PROXIMO.new() as BracoRegistradoV1
	proximo.name = "BracoProximo"
	proximo.z_index = 2
	add_child(proximo)
	proximo.ombro.rotation = deg_to_rad(75)
	proximo.cotovelo.rotation = deg_to_rad(-120)
	proximo.segmentos[2].scale = Vector2(.76, -.76)
	_separar_oclusao_proxima()
	distante = BRACO_DISTANTE.new() as BracoDistanteRegistradoV1
	distante.name = "BracoDistante"
	distante.z_index = -6
	add_child(distante)
	distante.ombro.rotation = deg_to_rad(135)
	distante.cotovelo.rotation = deg_to_rad(120)
	distante.segmentos[2].scale *= 1.20
	var paleta := ShaderMaterial.new()
	paleta.shader = PALETA
	for segmento: Polygon2D in distante.segmentos:
		segmento.material = paleta
	registrar_membros()
	guias.draw.connect(_desenhar_insercoes)


func registrar_membros() -> void:
	# Registro da referência aceita e do distante. O próximo recebe abaixo
	# a calibração estática da guarda, em vez de copiar a postura antiga.
	registro_bracos = registrar(OMBRO_PROXIMO_ACEITO, OMBRO_DISTANTE_ACEITO,
		tronco.transform * insercao_proxima_fonte, tronco.transform * insercao_distante_fonte)
	proximo.transform = registro_bracos * Transform2D(deg_to_rad(-7), OMBRO_PROXIMO_ACEITO)
	var raiz_distante := Transform2D(deg_to_rad(2), OMBRO_DISTANTE_ACEITO)
	raiz_distante.x *= -.92
	raiz_distante.y *= .92
	distante.transform = registro_bracos * raiz_distante
	_registrar_guarda_proxima()
	cabeca.scale = Vector2.ONE * escala_cabeca
	cabeca.position = tronco.transform * pescoco_fonte - pescoco_cabeca_fonte * escala_cabeca
	guias.queue_redraw()


func _registrar_guarda_proxima() -> void:
	var raiz: Vector2 = tronco.transform * insercao_proxima_fonte
	var superior: float = cotovelo_proximo_relativo.length()
	var eixo_antebraco: Vector2 = punho_proximo_relativo - cotovelo_proximo_relativo
	var inferior: float = eixo_antebraco.length()
	proximo.transform = Transform2D(0, raiz)
	proximo.ombro.rotation = cotovelo_proximo_relativo.angle()
	proximo.ombro.length = superior
	proximo.cotovelo.position = Vector2(superior, 0)
	proximo.cotovelo.rotation = eixo_antebraco.angle() - proximo.ombro.rotation
	proximo.cotovelo.length = inferior
	proximo.punho.position = Vector2(inferior, 0)
	proximo.punho.length = proximo.MAO * inferior / proximo.INFERIOR
	# Cada recorte continua com escala uniforme; mão acompanha a densidade
	# do antebraço em torno do mesmo centro de punho, sem ajuste solto.
	proximo.registros[0] = proximo.registro(proximo.OMBRO_FONTE, proximo.COTOVELO_FONTE, superior)
	proximo.registros[1] = proximo.registro(proximo.COTOVELO_FONTE, proximo.PUNHO_FONTE, inferior)
	proximo.registros[2] = proximo.registro(proximo.PUNHO_FONTE, proximo.PONTA_FONTE, proximo.punho.length)
	for indice: int in range(3):
		proximo.segmentos[indice].polygon = proximo.registros[indice] * proximo.segmentos[indice].uv
	biceps_frente.polygon = proximo.registros[0] * biceps_frente.uv


func _separar_oclusao_proxima() -> void:
	# Só a conexão proximal fica sob a pele; não esconder todo o bíceps.
	# Dois recortes contíguos da MESMA malha/fonte, presos ao mesmo osso.
	var superior: Polygon2D = proximo.segmentos[0]
	var contorno: PackedVector2Array = superior.uv.duplicate()
	var cap: Array[PackedVector2Array] = Geometry2D.intersect_polygons(contorno,
		PackedVector2Array([Vector2.ZERO, Vector2(1024, 0), Vector2(1024, CORTE_CAP_FONTE), Vector2(0, CORTE_CAP_FONTE)]))
	var resto: Array[PackedVector2Array] = Geometry2D.intersect_polygons(contorno,
		PackedVector2Array([Vector2(0, CORTE_CAP_FONTE), Vector2(1024, CORTE_CAP_FONTE), Vector2(1024, 1536), Vector2(0, 1536)]))
	assert(cap.size() == 1 and resto.size() == 1, "Recortes devem continuar conectados")
	superior.uv = cap[0]
	superior.polygon = proximo.registros[0] * cap[0]
	superior.z_index = -3
	biceps_frente = Polygon2D.new()
	biceps_frente.name = "BicepsVisivel"
	biceps_frente.texture = superior.texture
	biceps_frente.uv = resto[0]
	biceps_frente.polygon = proximo.registros[0] * resto[0]
	biceps_frente.z_index = 4
	proximo.ombro.add_child(biceps_frente)


func mostrar_juntas(ativo: bool) -> void:
	mostrar_marcos = ativo
	proximo.mostrar_marcos = ativo
	distante.mostrar_marcos = ativo


func _desenhar_insercoes() -> void:
	if not mostrar_marcos:
		return
	for ponto: Vector2 in [proximo.position, distante.position]:
		guias.draw_circle(ponto, 3, Color("ec5fb7"))
	guias.draw_line(pescoco_referencia, cabeca.transform * pescoco_cabeca_fonte, Color("69d6e3"), 2)
