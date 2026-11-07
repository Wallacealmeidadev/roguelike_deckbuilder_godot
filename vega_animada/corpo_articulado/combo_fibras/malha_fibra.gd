class_name MalhaFibraComboV1
extends RefCounted
## Deforma a pintura macia no espaço registrado; nunca escreve nos ossos.

const PASSO: float = 16.0
const MARGEM_RIGIDA: float = 28.0 # Maior que a diagonal de uma célula.
var original: Polygon2D
var malha: Polygon2D
var base: PackedVector2Array = PackedVector2Array()
var deltas: PackedVector2Array = PackedVector2Array()
var protecoes: Array[PackedVector2Array] = []


func preparar(peca: Polygon2D, registro: Transform2D, comprimento: float,
		superior: bool, distante: bool, amplitude: float) -> void:
	original = peca
	protecoes = _placas(superior, distante)
	# Aros completos são rígidos, inclusive o cuff pintado junto às fibras.
	protecoes.append(PackedVector2Array([Vector2(250, 560 if superior else 650), Vector2(780, 560 if superior else 650), Vector2(780, 735), Vector2(250, 735)]))
	if not superior:
		protecoes.append(PackedVector2Array([Vector2(250, 1080), Vector2(780, 1080), Vector2(780, 1230), Vector2(250, 1230)]))
	malha = original.duplicate() as Polygon2D
	malha.name = str(original.name) + "Tensao"
	malha.visible = false
	var uv := PackedVector2Array()
	var faces: Array[PackedInt32Array] = []
	var indices: Dictionary[Vector2, int] = {}
	var limites := Rect2(original.uv[0], Vector2.ZERO)
	for p: Vector2 in original.uv:
		limites = limites.expand(p)
	var topo: float = 260.0 if superior else 750.0
	var fundo: float = 530.0 if superior else 1050.0
	var recortes: Array[PackedVector2Array] = []
	# Não subdividir contornos rígidos dos aros: evita arredondamento na união
	# pintada do punho. Só o trecho central precisa de células deformáveis.
	for faixa: Vector2 in [Vector2(limites.position.y, topo), Vector2(fundo, limites.end.y)]:
		var tampa := PackedVector2Array([Vector2(limites.position.x, faixa.x), Vector2(limites.end.x, faixa.x), Vector2(limites.end.x, faixa.y), Vector2(limites.position.x, faixa.y)])
		recortes.append_array(Geometry2D.intersect_polygons(original.uv, tampa))
	for linha: int in range(ceili((fundo - topo) / PASSO)):
		for coluna: int in range(ceili(limites.size.x / PASSO)):
			var a: Vector2 = Vector2(limites.position.x, topo) + Vector2(coluna, linha) * PASSO
			var b: Vector2 = (a + Vector2.ONE * PASSO).min(Vector2(limites.end.x, fundo))
			var celula := PackedVector2Array([a, Vector2(b.x, a.y), b, Vector2(a.x, b.y)])
			recortes.append_array(Geometry2D.intersect_polygons(original.uv, celula))
	for recorte: PackedVector2Array in recortes:
		var triangulos: PackedInt32Array = Geometry2D.triangulate_polygon(recorte)
		var mapa := PackedInt32Array()
		for ponto: Vector2 in recorte:
			if indices.has(ponto):
				mapa.append(indices[ponto])
				continue
			indices[ponto] = uv.size()
			mapa.append(uv.size())
			uv.append(ponto)
			var local: Vector2 = registro * ponto
			base.append(local)
			var t: float = local.x / comprimento
			# Extremos/juntas presos; expansão só transversal no ventre.
			var perfil: float = smoothstep(.12, .28, t) * (1.0 - smoothstep(.72, .86, t))
			perfil *= smoothstep(topo + 28, topo + 60, ponto.y) * (1.0 - smoothstep(fundo - 60, fundo - 28, ponto.y))
			deltas.append(Vector2(0, local.y * amplitude * perfil * _liberdade(ponto)))
		for i: int in range(0, triangulos.size(), 3):
			faces.append(PackedInt32Array([mapa[triangulos[i]], mapa[triangulos[i + 1]], mapa[triangulos[i + 2]]]))
	malha.polygon = base
	malha.uv = uv
	malha.polygons = faces
	original.get_parent().add_child(malha)


func aplicar(tensao: float) -> void:
	var pontos: PackedVector2Array = base.duplicate()
	for i: int in range(pontos.size()):
		pontos[i] += deltas[i] * tensao
	malha.polygon = pontos
	# Combo zero usa exatamente o recorte aprovado, não outra triangulação.
	malha.visible = tensao > 0.0
	original.visible = not malha.visible


func _liberdade(ponto: Vector2) -> float:
	var distancia: float = INF
	for placa: PackedVector2Array in protecoes:
		if Geometry2D.is_point_in_polygon(ponto, placa):
			return 0.0
		for i: int in range(placa.size()):
			var a: Vector2 = placa[i]
			var eixo: Vector2 = placa[(i + 1) % placa.size()] - a
			var t: float = clampf((ponto - a).dot(eixo) / eixo.length_squared(), 0, 1)
			distancia = minf(distancia, ponto.distance_to(a + eixo * t))
	return smoothstep(MARGEM_RIGIDA, MARGEM_RIGIDA + 32.0, distancia)


static func _placas(superior: bool, distante: bool) -> Array[PackedVector2Array]:
	# Máscaras conservadoras lidas nas duas fontes aprovadas, não no atlas antigo.
	if superior and not distante:
		return [PackedVector2Array([Vector2(340, 0), Vector2(640, 0), Vector2(640, 265), Vector2(575, 265), Vector2(480, 180), Vector2(340, 145)]),
			PackedVector2Array([Vector2(595, 235), Vector2(660, 280), Vector2(660, 480), Vector2(530, 390), Vector2(525, 320), Vector2(560, 265)]),
			PackedVector2Array([Vector2(585, 420), Vector2(640, 455), Vector2(680, 570), Vector2(610, 600), Vector2(570, 535), Vector2(565, 475)])]
	if superior:
		return [PackedVector2Array([Vector2(375, 0), Vector2(680, 0), Vector2(680, 155), Vector2(550, 155), Vector2(455, 255), Vector2(375, 255)]),
			PackedVector2Array([Vector2(385, 240), Vector2(450, 265), Vector2(480, 330), Vector2(450, 370), Vector2(410, 430), Vector2(380, 400)]),
			PackedVector2Array([Vector2(395, 415), Vector2(445, 440), Vector2(490, 500), Vector2(440, 585), Vector2(390, 565)]),
			PackedVector2Array([Vector2(600, 330), Vector2(640, 380), Vector2(630, 455), Vector2(590, 465)])]
	if not distante:
		return [PackedVector2Array([Vector2(615, 665), Vector2(685, 700), Vector2(685, 820), Vector2(560, 1000), Vector2(540, 990), Vector2(540, 835)]),
			PackedVector2Array([Vector2(660, 830), Vector2(690, 835), Vector2(680, 970), Vector2(580, 1100), Vector2(545, 1080), Vector2(565, 970)]),
			PackedVector2Array([Vector2(635, 1000), Vector2(675, 1010), Vector2(655, 1170), Vector2(590, 1190), Vector2(580, 1110)])]
	return [PackedVector2Array([Vector2(390, 715), Vector2(440, 710), Vector2(490, 800), Vector2(470, 865), Vector2(425, 880), Vector2(385, 785)]),
		PackedVector2Array([Vector2(375, 840), Vector2(420, 875), Vector2(445, 965), Vector2(445, 1085), Vector2(390, 1035)]),
		PackedVector2Array([Vector2(600, 785), Vector2(640, 800), Vector2(650, 925), Vector2(620, 1000), Vector2(585, 1010), Vector2(590, 900)])]
