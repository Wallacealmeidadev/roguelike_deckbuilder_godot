class_name ComboNativoV2
extends DoisBracosNativoV2
## Combo deforma só a arte macia. AnimationPlayer continua dono dos ossos.

signal tensao_alterada(valor: float)

const REGRA_COMBO: Script = preload("res://vega_animada/braco_v2/braco_prova.gd")
const COLUNAS_SUPERIOR: int = 32
const FAIXAS_SUPERIOR: int = 48
const FAIXAS_INFERIOR: int = 32
# Mesmo recorte rígido usado na prova original de expansão, em UV normalizado.
const RECORTE_PLACA: Array[Vector2] = [
	Vector2(0, .38), Vector2(.28, .22), Vector2(.41, .03), Vector2(.53, 0),
	Vector2(.67, .01), Vector2(.72, .10), Vector2(.50, .11), Vector2(.47, .24),
	Vector2(.34, .34), Vector2(.53, .54), Vector2(.74, .91), Vector2(.72, .96),
	Vector2(.60, .96), Vector2(.29, .77), Vector2(.05, .71)]

@export_range(0.0, 0.2) var contracao_biceps: float = .18
@export_range(0.0, 0.2) var contracao_antebraco: float = .14
var combo: int = 0
var tensao_combo: float = 0.0
var destino_tensao_combo: float = 0.0
var malhas: Array[Polygon2D] = []
var bases: Array[PackedVector2Array] = []
var deslocamentos: Array[PackedVector2Array] = []
var _transicao: Tween


func _ready() -> void:
	super._ready()
	for braco: BracoNativoV2 in [braco_original, braco_distante]:
		_preparar_malha(braco.ombro.get_node("Arte/BracoSuperior") as Sprite2D, true)
		_preparar_malha(braco.cotovelo.get_node("Arte/Antebraco") as Sprite2D, false)
	_aplicar_tensao(0)


func _preparar_malha(origem: Sprite2D, superior: bool) -> void:
	var textura: AtlasTexture = origem.texture as AtlasTexture
	var tamanho: Vector2 = textura.region.size
	var colunas: int = COLUNAS_SUPERIOR if superior else 2
	var faixas: int = FAIXAS_SUPERIOR if superior else FAIXAS_INFERIOR
	var amplitude: float = contracao_biceps if superior else contracao_antebraco
	var pontos: PackedVector2Array = PackedVector2Array()
	var uv: PackedVector2Array = PackedVector2Array()
	var deltas: PackedVector2Array = PackedVector2Array()
	var faces: Array[PackedInt32Array] = []
	for fila: int in faixas + 1:
		var t: float = float(fila) / faixas
		# Extremos exatamente presos; perfil só atua no ventre da fibra.
		var perfil: float = 0.0 if fila == 0 or fila == faixas else pow(sin(PI * t), 2)
		for coluna: int in colunas + 1:
			var u: float = float(coluna) / colunas
			var ponto: Vector2 = tamanho * Vector2(u, t)
			pontos.append(ponto)
			uv.append(textura.region.position + ponto)
			var liberdade: float = _liberdade_fibra(ponto, tamanho) if superior else 1.0
			deltas.append(Vector2((u - .5) * tamanho.x * amplitude * perfil * liberdade, 0))
			if coluna < colunas and fila < faixas:
				var i: int = fila * (colunas + 1) + coluna
				faces.append(PackedInt32Array([i, i + 1, i + colunas + 2, i + colunas + 1]))
	var malha: Polygon2D = Polygon2D.new()
	malha.name = "FibraCombo" + origem.name
	malha.texture = textura.atlas
	malha.transform = origem.transform
	malha.z_index = origem.z_index
	malha.polygon = pontos
	malha.uv = uv
	malha.polygons = faces
	origem.get_parent().add_child(malha)
	origem.visible = false
	malhas.append(malha)
	bases.append(pontos)
	deslocamentos.append(deltas)


static func _liberdade_fibra(ponto: Vector2, tamanho: Vector2) -> float:
	var placa: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in RECORTE_PLACA:
		placa.append(p * tamanho)
	if Geometry2D.is_point_in_polygon(ponto, placa):
		return 0.0
	var distancia: float = INF
	for i: int in placa.size():
		var inicio: Vector2 = placa[i]
		var segmento: Vector2 = placa[(i + 1) % placa.size()] - inicio
		var t: float = clampf((ponto - inicio).dot(segmento) / segmento.length_squared(), 0, 1)
		distancia = minf(distancia, ponto.distance_to(inicio + segmento * t))
	# A margem fixa excede a diagonal das células (~12 px no atlas):
	# até as faces que atravessam a borda da placa ficam imóveis.
	return smoothstep(16, 40, distancia)


func definir_combo(valor: int, imediato: bool = false) -> void:
	combo = maxi(0, valor)
	var alvo: float = REGRA_COMBO.tensao_por_combo(combo)
	if is_equal_approx(alvo, destino_tensao_combo) and not imediato:
		return
	_parar_transicao()
	destino_tensao_combo = alvo
	if imediato or movimento_reduzido or is_equal_approx(tensao_combo, alvo):
		_aplicar_tensao(alvo)
		return
	_transicao = create_tween()
	_transicao.tween_method(_interpolar.bind(tensao_combo, alvo), 0.0, 1.0, REGRA_COMBO.DURACAO_COMBO)
	_transicao.finished.connect(_aplicar_tensao.bind(alvo))


func _interpolar(tempo: float, inicio: float, alvo: float) -> void:
	_aplicar_tensao(lerpf(inicio, alvo, REGRA_COMBO.curva_transformacao(tempo)))


func _aplicar_tensao(valor: float) -> void:
	tensao_combo = clampf(valor, 0, 1)
	for i: int in malhas.size():
		var pontos: PackedVector2Array = bases[i].duplicate()
		for j: int in pontos.size():
			pontos[j] += deslocamentos[i][j] * tensao_combo
		malhas[i].polygon = pontos
	tensao_alterada.emit(tensao_combo)


func definir_movimento_reduzido(ativo: bool) -> void:
	super.definir_movimento_reduzido(ativo)
	if ativo:
		_parar_transicao()
		_aplicar_tensao(destino_tensao_combo)


func _parar_transicao() -> void:
	if _transicao != null and _transicao.is_valid():
		_transicao.kill()
	_transicao = null


func _exit_tree() -> void:
	_parar_transicao()
