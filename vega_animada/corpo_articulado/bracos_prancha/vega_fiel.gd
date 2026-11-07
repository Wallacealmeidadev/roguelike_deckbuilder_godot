class_name VegaBracosPranchaV1
extends VegaGuardaMontadaV1
## Prova de origem da arte: recorta pixels da prancha, sem refazer o rig.

const PRANCHA: Texture2D = preload("res://docs/arte_vega/vega_corpo_volume_poses_04.png")
const PINTURA_HQ: Texture2D = preload("res://vega_animada/corpo_articulado/bracos_prancha/bracos_hq_01.png")
const MATERIAL_HQ: Shader = preload("res://vega_animada/corpo_articulado/bracos_prancha/pintura_hq.gdshader")
const OMBRO_EDITADO: Texture2D = preload("res://vega_animada/corpo_articulado/bracos_prancha/tronco_encaixe_01.png")
const OMBRO_LOCAL: Shader = preload("res://vega_animada/corpo_articulado/bracos_prancha/ombro_local.gdshader")
const ENCAIXE_PROXIMO := Vector2(187, 251)
const ENCAIXE_DISTANTE := Vector2(380, 278)
const ARO_EXTERNO := Vector2(162, 252)
const ARO_INTERNO := Vector2(214, 264)
const PELE_EXTERNA := Vector2(123, 341)
const PELE_INTERNA := Vector2(275, 374)
const CURVATURA_ARO: float = 20
const OMBRO_VOLUME := Vector2(188, 265)
const COTOVELO_VOLUME := Vector2(224, 371)
const PUNHO_VOLUME := Vector2(305, 282)
const VOLUME_BICEPS: float = .24
const VOLUME_ANTEBRACO: float = .45
const VOLUME_MAO: float = .14
const CONTORNO_PROXIMO: Array[Vector2] = [
	Vector2(162, 251), Vector2(169, 247), Vector2(179, 244),
	Vector2(188, 244), Vector2(198, 246), Vector2(206, 251),
	Vector2(211, 258), Vector2(213, 265), Vector2(214, 274),
	Vector2(211, 278), Vector2(217, 285), Vector2(222, 297),
	Vector2(226, 312), Vector2(233, 318), Vector2(241, 309),
	Vector2(252, 300), Vector2(264, 292), Vector2(278, 281),
	Vector2(286, 270), Vector2(291, 263), Vector2(291, 258),
	Vector2(293, 252), Vector2(295, 243), Vector2(295, 236),
	Vector2(298, 229), Vector2(302, 223), Vector2(308, 219),
	Vector2(312, 218), Vector2(316, 214), Vector2(321, 211),
	Vector2(326, 212), Vector2(330, 214), Vector2(334, 217),
	Vector2(338, 217), Vector2(342, 219), Vector2(345, 223),
	Vector2(348, 223), Vector2(352, 227), Vector2(354, 233),
	Vector2(357, 238), Vector2(357, 243), Vector2(354, 249),
	Vector2(351, 253), Vector2(348, 260), Vector2(340, 267),
	Vector2(328, 275),
	Vector2(318, 281), Vector2(314, 287), Vector2(308, 292),
	Vector2(301, 294), Vector2(295, 299), Vector2(289, 307),
	Vector2(282, 320), Vector2(277, 334), Vector2(270, 348),
	Vector2(263, 360), Vector2(255, 369), Vector2(247, 375),
	Vector2(246, 382), Vector2(241, 385), Vector2(234, 384),
	Vector2(225, 387), Vector2(215, 386), Vector2(207, 383),
	Vector2(203, 377), Vector2(202, 370), Vector2(201, 364),
	Vector2(197, 357), Vector2(193, 348), Vector2(185, 336),
	Vector2(178, 323), Vector2(176, 311), Vector2(176, 301),
	Vector2(169, 293), Vector2(165, 283), Vector2(163, 272),
	Vector2(161, 263), Vector2(162, 256)]
const CONTORNO_DISTANTE: Array[Vector2] = [
	Vector2(350, 283), Vector2(359, 279), Vector2(368, 272),
	Vector2(376, 266), Vector2(384, 267), Vector2(393, 273),
	Vector2(402, 287), Vector2(410, 298), Vector2(416, 307),
	Vector2(418, 309), Vector2(422, 301), Vector2(427, 294),
	Vector2(432, 287), Vector2(438, 281), Vector2(439, 273),
	Vector2(441, 265), Vector2(442, 257), Vector2(441, 253),
	Vector2(436, 248), Vector2(433, 244), Vector2(429, 240),
	Vector2(426, 238), Vector2(424, 232), Vector2(423, 227),
	Vector2(425, 222), Vector2(428, 218), Vector2(431, 216),
	Vector2(431, 211), Vector2(434, 205), Vector2(438, 201),
	Vector2(441, 201), Vector2(443, 197), Vector2(446, 196),
	Vector2(448, 196), Vector2(450, 198), Vector2(454, 196),
	Vector2(458, 196), Vector2(461, 197), Vector2(463, 200),
	Vector2(468, 200), Vector2(472, 202), Vector2(474, 205),
	Vector2(478, 206), Vector2(481, 209), Vector2(483, 213),
	Vector2(486, 216), Vector2(485, 221), Vector2(485, 225),
	Vector2(484, 229), Vector2(483, 234), Vector2(482, 240),
	Vector2(479, 246), Vector2(478, 250), Vector2(475, 254),
	Vector2(474, 257), Vector2(474, 264), Vector2(473, 270),
	Vector2(471, 274), Vector2(471, 278), Vector2(471, 282),
	Vector2(474, 286), Vector2(475, 290), Vector2(476, 300),
	Vector2(475, 316), Vector2(474, 323), Vector2(470, 332),
	Vector2(466, 340), Vector2(462, 346), Vector2(459, 351),
	Vector2(458, 355), Vector2(456, 360), Vector2(454, 363),
	Vector2(451, 365), Vector2(448, 365), Vector2(444, 368),
	Vector2(438, 370), Vector2(431, 370), Vector2(422, 368),
	Vector2(416, 364), Vector2(413, 358),
	Vector2(403, 350), Vector2(395, 346), Vector2(387, 340),
	Vector2(378, 333), Vector2(370, 325), Vector2(362, 319),
	Vector2(354, 315), Vector2(350, 310)]

var recorte_proximo: Polygon2D
var recorte_distante: Polygon2D
var cap_proxima: Polygon2D
var ajuste_ativo: bool = true
var material_original: Material
var material_ombro: ShaderMaterial
var registro_proximo_antes: Transform2D
var registro_proximo_novo: Transform2D
var contorno_frente: PackedVector2Array
var volume_ativo: bool = true
var uv_volume: PackedVector2Array
var pintura_hq_ativa: bool = true
var hq_proximo: ShaderMaterial
var hq_distante: ShaderMaterial


func _ready() -> void:
	super._ready()
	proximo.hide()
	distante.hide()
	recorte_proximo = _recorte("ProximoDaPrancha", PackedVector2Array(CONTORNO_PROXIMO), 2)
	recorte_distante = _recorte("DistanteDaPrancha", PackedVector2Array(CONTORNO_DISTANTE), -1)
	# Só translação, arredondada para não ressintetizar os pixels nativos.
	recorte_proximo.position = (tronco.transform * insercao_proxima_fonte - ENCAIXE_PROXIMO).round()
	recorte_distante.position = (tronco.transform * insercao_distante_fonte - ENCAIXE_DISTANTE).round()
	registro_proximo_antes = recorte_proximo.transform
	# O desenho inteiro do membro recebe um único registro pelos DOIS lados
	# da inserção. Não recalibrar mão/antebraço independentemente.
	registro_proximo_novo = registrar(ARO_EXTERNO, ARO_INTERNO,
		tronco.transform * PELE_EXTERNA, tronco.transform * PELE_INTERNA)
	var regiao_cap := PackedVector2Array([Vector2(150, 230), Vector2(225, 230), Vector2(225, 280), Vector2(150, 280)])
	var cap: Array[PackedVector2Array] = Geometry2D.intersect_polygons(recorte_proximo.polygon, regiao_cap)
	var frente: Array[PackedVector2Array] = Geometry2D.clip_polygons(recorte_proximo.polygon, regiao_cap)
	assert(cap.size() == 1 and frente.size() == 1, "Partição do aro deve manter duas superfícies conectadas")
	cap_proxima = _recorte("AroEBicepsSobreAxila", _subdividir_borda(cap[0]), 2)
	# O contorno inferior do deltoide é convexo, não uma linha entre dois
	# pivôs. Adaptar somente a borda do encaixe; a base em y280 permanece
	# idêntica ao bíceps da frente. UV/pintura e todo o resto do braço intactos.
	var borda_encaixe: PackedVector2Array = cap_proxima.polygon.duplicate()
	for indice: int in range(borda_encaixe.size()):
		borda_encaixe[indice] = _acompanhar_deltoide(borda_encaixe[indice])
	cap_proxima.polygon = borda_encaixe
	contorno_frente = frente[0]
	uv_volume = _subdividir_borda(contorno_frente)
	material_original = tronco.material
	material_ombro = ShaderMaterial.new()
	material_ombro.shader = OMBRO_LOCAL
	material_ombro.set_shader_parameter("ombro_editado", OMBRO_EDITADO)
	definir_ajuste(true)
	hq_proximo = _material_hq(CONTORNO_PROXIMO)
	hq_distante = _material_hq(CONTORNO_DISTANTE)
	definir_pintura_hq(true)


func definir_pintura_hq(ativa: bool) -> void:
	# Mesmo canvas de origem: trocar só os pixels, nunca os encaixes ou UV.
	assert(PINTURA_HQ.get_size() == PRANCHA.get_size(), "Pintura HQ precisa manter o canvas da fonte")
	pintura_hq_ativa = ativa
	recorte_proximo.material = hq_proximo if ativa else null
	cap_proxima.material = hq_proximo if ativa else null
	recorte_distante.material = hq_distante if ativa else null


func _material_hq(contorno: Array[Vector2]) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = MATERIAL_HQ
	material.set_shader_parameter("pintura", PINTURA_HQ)
	material.set_shader_parameter("quantidade", contorno.size())
	var pontos := PackedVector2Array(contorno)
	pontos.resize(128)
	material.set_shader_parameter("contorno", pontos)
	return material


static func _acompanhar_deltoide(ponto: Vector2) -> Vector2:
	var t: float = clampf((ponto.x - ARO_EXTERNO.x) / (ARO_INTERNO.x - ARO_EXTERNO.x), 0, 1)
	return ponto + Vector2(0, CURVATURA_ARO * sin(PI * t) * clampf((280 - ponto.y) / 36, 0, 1))


static func _subdividir_borda(contorno: PackedVector2Array) -> PackedVector2Array:
	# Interpolar a curva em intervalos curtos; não dobrar uma faixa de metal
	# com uma única aresta longa. A subdivisão não altera UV/pintura.
	var resultado := PackedVector2Array()
	for indice: int in range(contorno.size()):
		var a: Vector2 = contorno[indice]
		var b: Vector2 = contorno[(indice + 1) % contorno.size()]
		var passos: int = maxi(1, ceili(a.distance_to(b) / 2))
		for passo: int in range(passos):
			resultado.append(a.lerp(b, float(passo) / passos))
	return resultado


static func deslocamento_volume(ponto: Vector2) -> Vector2:
	# A mão cresce a partir do punho fixo, com transição contínua no conector.
	var direcao_mao: Vector2 = (PUNHO_VOLUME - COTOVELO_VOLUME).normalized()
	var distancia_mao: float = (ponto - PUNHO_VOLUME).dot(direcao_mao)
	if distancia_mao > 0:
		return (ponto - PUNHO_VOLUME) * VOLUME_MAO * smoothstep(15, 32, distancia_mao)
	# O antebraço ganha largura; os centros e comprimentos dos ossos ficam fixos.
	if ponto.distance_to(COTOVELO_VOLUME) <= 18 or ponto.distance_to(PUNHO_VOLUME) <= 15:
		return Vector2.ZERO
	var eixo_superior: Vector2 = COTOVELO_VOLUME - OMBRO_VOLUME
	var eixo_inferior: Vector2 = PUNHO_VOLUME - COTOVELO_VOLUME
	var ts: float = (ponto - OMBRO_VOLUME).dot(eixo_superior) / eixo_superior.length_squared()
	var ti: float = (ponto - COTOVELO_VOLUME).dot(eixo_inferior) / eixo_inferior.length_squared()
	var ds: float = ponto.distance_to(OMBRO_VOLUME + eixo_superior * clampf(ts, 0, 1))
	var di: float = ponto.distance_to(COTOVELO_VOLUME + eixo_inferior * clampf(ti, 0, 1))
	var superior: bool = ds < di
	var t: float = ts if superior else ti
	if t <= 0 or t >= 1:
		return Vector2.ZERO
	var eixo: Vector2 = eixo_superior if superior else eixo_inferior
	var inicio: Vector2 = OMBRO_VOLUME if superior else COTOVELO_VOLUME
	var normal: Vector2 = eixo.normalized().orthogonal()
	var lateral: float = (ponto - inicio).dot(normal)
	var peso: float = smoothstep(.18, .40, t) * (1 - smoothstep(.68, .94, t))
	if superior:
		peso *= smoothstep(280, 300, ponto.y)
	else:
		peso = smoothstep(.12, .32, t) * (1 - smoothstep(.78, 1, t))
		peso *= smoothstep(18, 27, ponto.distance_to(COTOVELO_VOLUME))
		peso *= smoothstep(15, 25, ponto.distance_to(PUNHO_VOLUME))
	return normal * lateral * peso * (VOLUME_BICEPS if superior else VOLUME_ANTEBRACO)


func definir_volume(ativo: bool) -> void:
	volume_ativo = ativo
	_atualizar_volume()


func _atualizar_volume() -> void:
	if ajuste_ativo and volume_ativo:
		recorte_proximo.uv = uv_volume.duplicate()
		var vertices: PackedVector2Array = uv_volume.duplicate()
		for indice: int in range(vertices.size()):
			vertices[indice] += deslocamento_volume(uv_volume[indice])
		recorte_proximo.polygon = vertices
	else:
		recorte_proximo.internal_vertex_count = 0
		recorte_proximo.polygon = contorno_frente if ajuste_ativo else PackedVector2Array(CONTORNO_PROXIMO)
		recorte_proximo.uv = recorte_proximo.polygon.duplicate()


func definir_ajuste(ativo: bool) -> void:
	ajuste_ativo = ativo
	tronco.material = material_ombro if ativo else material_original
	recorte_proximo.transform = registro_proximo_novo if ativo else registro_proximo_antes
	_atualizar_volume()
	cap_proxima.transform = registro_proximo_novo
	cap_proxima.visible = ativo and recorte_proximo.visible
	guias.queue_redraw()


func _recorte(nome: String, contorno: PackedVector2Array, camada: int) -> Polygon2D:
	var peca := Polygon2D.new()
	peca.name = nome
	peca.texture = PRANCHA
	peca.uv = contorno.duplicate()
	peca.polygon = contorno.duplicate()
	peca.antialiased = true
	peca.z_index = camada
	add_child(peca)
	return peca


func mostrar_juntas(ativo: bool) -> void:
	# Não desenhar ossos da montagem antiga como se fossem estes recortes.
	super.mostrar_juntas(false)
	mostrar_marcos = ativo


func _desenhar_insercoes() -> void:
	if not mostrar_marcos or not is_instance_valid(recorte_proximo):
		return
	for ponto: Vector2 in [recorte_proximo.transform * ENCAIXE_PROXIMO, recorte_distante.transform * ENCAIXE_DISTANTE]:
		guias.draw_circle(ponto, 3, Color("ec5fb7"))
	if ajuste_ativo:
		for ponto: Vector2 in [ARO_EXTERNO, ARO_INTERNO]:
			guias.draw_circle(recorte_proximo.transform * ponto, 2, Color("69d6e3"))
