class_name ModeloVegaCombateV2
extends Node2D

const ATLAS: Texture2D = preload("res://vega_animada/combate_v2/base_e_punhos_01.png")
const BRACO: Script = preload("res://vega_animada/combate_v2/braco_articulado.gd")
const FONTE_CORPO: Rect2 = Rect2(300, 0, 730, 860)
const FONTE_PUNHO: Rect2 = Rect2(1218, 119, 286, 337)
const TAMANHO: Vector2 = Vector2(730, 860)
const HIP: Vector2 = Vector2(320, 380)
const OMBRO_ATAQUE: Vector2 = Vector2(201, 225)
const OMBRO_GUARDA: Vector2 = Vector2(410, 253)
const GUARDA_ATAQUE: Vector2 = Vector2(290, 200)
const GUARDA_OUTRO: Vector2 = Vector2(434, 212)
const REPOUSO_ATAQUE: Vector2 = Vector2(170, 420)
const REPOUSO_OUTRO: Vector2 = Vector2(475, 445)
const ALCANCE_SOCO: Vector2 = Vector2(250, -32)
const COLUNAS: int = 12
const LINHAS: int = 40

var corpo: Polygon2D
var braco_ataque: BracoArticuladoV2
var braco_guarda: BracoArticuladoV2
var golpe: float = 0.0
var prontidao: float = 0.0
var recuo: float = 0.0
var respiracao: float = 0.0
var _pontos_originais: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_criar_corpo()
	var textura_punho: AtlasTexture = AtlasTexture.new()
	textura_punho.atlas = ATLAS
	textura_punho.region = FONTE_PUNHO
	braco_guarda = _criar_braco("BracoGuarda", Vector2(-.64, .64), 20, textura_punho)
	braco_guarda.lado_cotovelo = 1.0
	braco_ataque = _criar_braco("BracoAtaque", Vector2(.66, .66), 40, textura_punho)
	atualizar_pose()


func _criar_braco(nome: String, escala: Vector2, camada: int, textura: Texture2D) -> BracoArticuladoV2:
	var braco: BracoArticuladoV2 = BRACO.new() as BracoArticuladoV2
	braco.name = nome
	braco.scale = escala
	braco.z_index = camada
	add_child(braco)
	braco.configurar_punho(textura)
	return braco


func _criar_corpo() -> void:
	corpo = Polygon2D.new()
	corpo.name = "Corpo"
	corpo.texture = ATLAS
	var uv: PackedVector2Array = PackedVector2Array()
	var faces: Array[PackedInt32Array] = []
	for y: int in LINHAS + 1:
		for x: int in COLUNAS + 1:
			var ponto: Vector2 = TAMANHO * Vector2(float(x) / COLUNAS, float(y) / LINHAS)
			_pontos_originais.append(ponto)
			uv.append(FONTE_CORPO.position + ponto)
			if x < COLUNAS and y < LINHAS:
				var i: int = y * (COLUNAS + 1) + x
				faces.append(PackedInt32Array([i, i + 1, i + COLUNAS + 2, i + COLUNAS + 1]))
	corpo.polygon = _pontos_originais
	corpo.uv = uv
	corpo.polygons = faces
	add_child(corpo)


func _ponto_tronco(ponto: Vector2) -> Vector2:
	var peso: float = clampf((HIP.y + 30 - ponto.y) / 110.0, 0.0, 1.0)
	if is_zero_approx(peso):
		return ponto
	var angulo: float = golpe * (.08 if golpe >= 0 else .025) - recuo * .035
	var rotacionado: Vector2 = HIP + (ponto - HIP).rotated(angulo * peso)
	return rotacionado + Vector2(-12 * recuo, -2.5 * respiracao) * peso


func atualizar_pose() -> void:
	if not is_instance_valid(braco_ataque):
		return
	var pontos: PackedVector2Array = PackedVector2Array()
	for ponto: Vector2 in _pontos_originais:
		pontos.append(_ponto_tronco(ponto))
	corpo.polygon = pontos
	braco_ataque.position = _ponto_tronco(OMBRO_ATAQUE)
	braco_guarda.position = _ponto_tronco(OMBRO_GUARDA)
	var alvo_ataque: Vector2 = REPOUSO_ATAQUE.lerp(GUARDA_ATAQUE, prontidao)
	if golpe >= 0:
		alvo_ataque = alvo_ataque.lerp(OMBRO_ATAQUE + ALCANCE_SOCO, golpe)
	else:
		alvo_ataque += Vector2(12, 6) * golpe
	braco_ataque.apontar_para(to_global(_ponto_tronco(alvo_ataque)))
	braco_guarda.apontar_para(to_global(_ponto_tronco(REPOUSO_OUTRO.lerp(GUARDA_OUTRO, prontidao))))


func posar_prontidao(valor: float) -> void:
	prontidao = clampf(valor, 0.0, 1.0)
	atualizar_pose()


func posar_golpe(valor: float) -> void:
	golpe = clampf(valor, -1.0, 1.0)
	atualizar_pose()


func posar_recuo(valor: float) -> void:
	recuo = clampf(valor, 0.0, 1.0)
	atualizar_pose()


func definir_combate(ativo: bool, imediato: bool = false) -> void:
	for braco: BracoArticuladoV2 in [braco_ataque, braco_guarda]:
		braco.definir_combate(ativo, imediato)


func definir_combo(valor: int, imediato: bool = false) -> void:
	for braco: BracoArticuladoV2 in [braco_ataque, braco_guarda]:
		braco.definir_combo(valor, imediato)


func definir_movimento_reduzido(ativo: bool) -> void:
	for braco: BracoArticuladoV2 in [braco_ataque, braco_guarda]:
		braco.definir_movimento_reduzido(ativo)
