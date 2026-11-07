class_name BracoV2Prova
extends Node2D
## Prova isolada: deformação local dos feixes; placas/juntas são peças rígidas.

signal ativacao_alterada(valor: float)
signal transformacao_finalizada(em_combate: bool)
signal combo_alterado(valor: int)

const ATLAS: Texture2D = preload("res://vega_animada/braco_v2/camadas.png")
const DURACAO: float = 0.5
const ALTURA: float = 570.0
const FAIXAS: int = 32
const DURACAO_COMBO: float = 0.2
const COMBO_TENSAO_MAXIMA: int = 10

@export_range(0.0, 0.7) var expansao_biceps: float = 0.45
@export_range(0.0, 0.7) var expansao_antebraco: float = 0.38
@export_range(0.0, 0.2) var contracao_combo_biceps: float = 0.18
@export_range(0.0, 0.2) var contracao_combo_antebraco: float = 0.14
var combo: int = 0
var tensao_combo: float = 0.0
var destino_tensao_combo: float = 0.0
var animando_combo: bool = false
var ativacao: float = 0.0
var destino: float = 0.0
var animando: bool = false
var movimento_reduzido: bool = false
var limites_fontes: Array[Rect2i] = []
var biceps: Polygon2D
var antebraco: Polygon2D
var cotovelo: Sprite2D
var mao: Sprite2D
var placas: Array[Sprite2D] = []
var _origens_placas: Array[Vector2] = []
var _animacao: Tween
var _animacao_combo: Tween


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
	_ler_camadas()
	_criar_ponte_cotovelo()
	biceps = _criar_feixe("Biceps", 0)
	antebraco = _criar_feixe("Antebraco", 1)
	_criar_placa_superior()
	for indice: int in 3:
		var peca: Sprite2D = _criar_peca("Placa%d" % indice, indice + 5, [Rect2(30, 241, 60, 112), Rect2(41, 309, 43, 95), Rect2(39, 376, 43, 65)][indice])
		peca.z_index = 10 + indice
		placas.append(peca)
		_origens_placas.append(peca.position)
	cotovelo = _criar_peca("Cotovelo", 2, Rect2(-54, 201, 125, 65))
	cotovelo.z_index = 20
	mao = _criar_peca("MaoEPulso", 3, Rect2(-25, 419, 105, 150))
	mao.z_index = 20
	definir_ativacao(0.0)


func _ler_camadas() -> void:
	# Limites conferidos no atlas de 1774×887: get_used_rect inclui poeira de
	# alfa quase zero e aproxima peças de células vizinhas. Não é um grid exato.
	limites_fontes.assign([
		Rect2i(124, 31, 286, 417), Rect2i(591, 23, 239, 425),
		Rect2i(970, 170, 287, 157), Rect2i(1430, 22, 243, 442),
		Rect2i(122, 499, 298, 358), Rect2i(589, 468, 248, 399),
		Rect2i(1035, 506, 150, 328), Rect2i(1463, 569, 190, 253),
	])


func _criar_feixe(nome: String, indice: int) -> Polygon2D:
	var peca: Polygon2D = Polygon2D.new()
	peca.name = nome
	peca.texture = ATLAS
	var uv: PackedVector2Array = PackedVector2Array()
	var faces: Array[PackedInt32Array] = []
	var fonte: Rect2 = Rect2(limites_fontes[indice])
	for fila: int in FAIXAS + 1:
		var t: float = float(fila) / FAIXAS
		uv.append(fonte.position + fonte.size * Vector2(0, t))
		uv.append(fonte.position + fonte.size * Vector2(1, t))
		if fila < FAIXAS:
			faces.append(PackedInt32Array([fila * 2, fila * 2 + 1, fila * 2 + 3, fila * 2 + 2]))
	peca.polygon = _pontos_feixe(indice, 0.0)
	peca.uv = uv
	peca.polygons = faces
	add_child(peca)
	return peca


func _criar_ponte_cotovelo() -> void:
	# A junta é oca: continuação de fibra por trás impede um buraco de cenário.
	var textura: AtlasTexture = AtlasTexture.new()
	textura.atlas = ATLAS
	textura.region = Rect2(250, 270, 100, 80)
	var ponte: Sprite2D = Sprite2D.new()
	ponte.name = "FibraDaJunta"
	ponte.texture = textura
	ponte.position = Vector2(17, 240)
	ponte.scale = Vector2(.83, .9)
	ponte.z_index = -1
	add_child(ponte)


func _pontos_feixe(indice: int, valor: float) -> PackedVector2Array:
	var area: Rect2 = Rect2(-100, 20, 145, 210) if indice == 0 else Rect2(-51, 236, 140, 210)
	var crescimento: float = expansao_biceps if indice == 0 else expansao_antebraco
	var contracao: float = contracao_combo_biceps if indice == 0 else contracao_combo_antebraco
	var pontos: PackedVector2Array = PackedVector2Array()
	for fila: int in FAIXAS + 1:
		var t: float = float(fila) / FAIXAS
		# Termina em zero nas duas juntas: nenhuma translação de ombro/pulso.
		var perfil: float = pow(sin(PI * t), 2.0)
		var aumento: float = area.size.x * 0.5 * (crescimento + contracao * tensao_combo) * valor * perfil
		var y: float = area.position.y + area.size.y * t
		pontos.append(Vector2(area.position.x - aumento, y))
		pontos.append(Vector2(area.end.x + aumento, y))
	return pontos


func _criar_peca(nome: String, indice: int, area: Rect2) -> Sprite2D:
	var textura: AtlasTexture = AtlasTexture.new()
	textura.atlas = ATLAS
	textura.region = Rect2(limites_fontes[indice])
	var peca: Sprite2D = Sprite2D.new()
	peca.name = nome
	peca.texture = textura
	peca.position = area.get_center()
	peca.scale = area.size / textura.get_size()
	add_child(peca)
	return peca


func _criar_placa_superior() -> void:
	# Esta célula contém fibra atrás da placa. O recorte é geometria em runtime,
	# não uma segunda pintura do braço: somente a casca rígida é exibida aqui.
	var recorte: PackedVector2Array = PackedVector2Array([Vector2(0, .38), Vector2(.28, .22), Vector2(.41, .03), Vector2(.53, 0), Vector2(.67, .01), Vector2(.72, .10), Vector2(.50, .11), Vector2(.47, .24), Vector2(.34, .34), Vector2(.53, .54), Vector2(.74, .91), Vector2(.72, .96), Vector2(.60, .96), Vector2(.29, .77), Vector2(.05, .71)])
	var fonte: Rect2 = Rect2(limites_fontes[4])
	var area: Rect2 = Rect2(-96, 14, 145, 214)
	var pontos: PackedVector2Array = PackedVector2Array()
	var uv: PackedVector2Array = PackedVector2Array()
	for ponto: Vector2 in recorte:
		pontos.append(area.position + ponto * area.size)
		uv.append(fonte.position + ponto * fonte.size)
	var placa: Polygon2D = Polygon2D.new()
	placa.name = "PlacaSuperior"
	placa.texture = ATLAS
	placa.polygon = pontos
	placa.uv = uv
	placa.z_index = 10
	add_child(placa)


func definir_ativacao(valor: float) -> void:
	_parar_animacao()
	destino = clampf(valor, 0.0, 1.0)
	if is_zero_approx(destino):
		definir_combo(0, true)
	_aplicar_ativacao(destino)


func _aplicar_ativacao(valor: float) -> void:
	ativacao = clampf(valor, 0.0, 1.0)
	_atualizar_geometria()
	ativacao_alterada.emit(ativacao)


func _atualizar_geometria() -> void:
	if not is_instance_valid(biceps):
		return
	biceps.polygon = _pontos_feixe(0, ativacao)
	antebraco.polygon = _pontos_feixe(1, ativacao)
	for indice: int in placas.size():
		var abertura: Vector2 = [Vector2(16, -2), Vector2(22, 0), Vector2(10, 1)][indice]
		abertura.x += [8.0, 8.0, 4.0][indice] * tensao_combo
		placas[indice].position = _origens_placas[indice] + abertura * ativacao
		placas[indice].rotation = [-0.055, -0.035, -0.02][indice] * ativacao


func definir_combate(ativo: bool, imediato: bool = false) -> void:
	var alvo: float = 1.0 if ativo else 0.0
	if not ativo:
		definir_combo(0, imediato)
	if is_equal_approx(destino, alvo) and (animando or is_equal_approx(ativacao, alvo)):
		if not imediato:
			return
	_parar_animacao()
	destino = alvo
	if movimento_reduzido or imediato or is_equal_approx(ativacao, alvo):
		_aplicar_ativacao(alvo)
		transformacao_finalizada.emit(ativo)
		return
	var inicio: float = ativacao
	animando = true
	_animacao = create_tween()
	_animacao.tween_method(_interpolar.bind(inicio, alvo), 0.0, 1.0, maxf(0.1, DURACAO * absf(alvo - inicio)))
	_animacao.finished.connect(_terminar.bind(ativo))


func _interpolar(tempo: float, inicio: float, alvo: float) -> void:
	_aplicar_ativacao(lerpf(inicio, alvo, curva_transformacao(tempo)))


static func curva_transformacao(tempo: float) -> float:
	# ease-in-out da skill animate: cubic-bezier(0.77, 0, 0.175, 1).
	if tempo <= 0.0 or tempo >= 1.0:
		return clampf(tempo, 0.0, 1.0)
	var inferior: float = 0.0
	var superior: float = 1.0
	for tentativa: int in 20:
		var t: float = (inferior + superior) * 0.5
		var x: float = 3.0 * (1.0 - t) * (1.0 - t) * t * 0.77 + 3.0 * (1.0 - t) * t * t * 0.175 + t * t * t
		if x < tempo:
			inferior = t
		else:
			superior = t
	var t: float = (inferior + superior) * 0.5
	return 3.0 * (1.0 - t) * t * t + t * t * t


func _terminar(ativo: bool) -> void:
	animando = false
	_aplicar_ativacao(destino)
	transformacao_finalizada.emit(ativo)


func _parar_animacao() -> void:
	if _animacao != null and _animacao.is_valid():
		_animacao.kill()
	animando = false


func definir_movimento_reduzido(ativo: bool) -> void:
	movimento_reduzido = ativo
	if ativo:
		_parar_animacao()
		_parar_animacao_combo()
		_aplicar_tensao_combo(destino_tensao_combo)
		_aplicar_ativacao(destino)


static func tensao_por_combo(valor: int) -> float:
	# Cada carga ocupa 10% da amplitude adicional; só a apresentação tem teto.
	return float(clampi(valor, 0, COMBO_TENSAO_MAXIMA)) / float(COMBO_TENSAO_MAXIMA)


func definir_combo(valor: int, imediato: bool = false) -> void:
	# Não acumular tensão escondida para reaparecer ao entrar no combate.
	combo = maxi(0, valor) if destino > 0.0 else 0
	var alvo: float = tensao_por_combo(combo)
	if is_equal_approx(destino_tensao_combo, alvo) and (animando_combo or is_equal_approx(tensao_combo, alvo)) and not imediato:
		combo_alterado.emit(combo)
		return
	_parar_animacao_combo()
	destino_tensao_combo = alvo
	if imediato or movimento_reduzido or is_equal_approx(tensao_combo, alvo):
		_aplicar_tensao_combo(alvo)
	else:
		animando_combo = true
		_animacao_combo = create_tween()
		_animacao_combo.tween_method(_interpolar_combo.bind(tensao_combo, alvo), 0.0, 1.0, DURACAO_COMBO)
		_animacao_combo.finished.connect(_terminar_combo)
	combo_alterado.emit(combo)


func _interpolar_combo(tempo: float, inicio: float, alvo: float) -> void:
	_aplicar_tensao_combo(lerpf(inicio, alvo, curva_transformacao(tempo)))


func _aplicar_tensao_combo(valor: float) -> void:
	tensao_combo = clampf(valor, 0.0, 1.0)
	_atualizar_geometria()


func _terminar_combo() -> void:
	animando_combo = false
	_aplicar_tensao_combo(destino_tensao_combo)


func _parar_animacao_combo() -> void:
	if _animacao_combo != null and _animacao_combo.is_valid():
		_animacao_combo.kill()
	animando_combo = false
