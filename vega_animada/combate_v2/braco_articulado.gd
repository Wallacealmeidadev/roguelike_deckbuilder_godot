class_name BracoArticuladoV2
extends BracoV2Prova
## Reutiliza feixes/placas aprovados; acrescenta pivôs sem escalar com Combo.

const S: Vector2 = Vector2(-40, 45)
const E: Vector2 = Vector2(8, 233)
const W: Vector2 = Vector2(27, 435)
# Ajuste lateral da peça; não comprimir o comprimento do braço superior.
const PROJECAO_SUPERIOR: Vector2 = Vector2(.85, 1.0)
const VETOR_SUPERIOR: Vector2 = (E - S) * PROJECAO_SUPERIOR
const VETOR_INFERIOR: Vector2 = W - E

var ombro: Node2D
var articulacao_cotovelo: Node2D
var punho: Node2D
var articulado: bool = false
var lado_cotovelo: float = -1.0
var alvo_local: Vector2 = Vector2.ZERO


func _ready() -> void:
	super._ready()
	ombro = Node2D.new()
	ombro.name = "Ombro"
	add_child(ombro)
	articulacao_cotovelo = Node2D.new()
	articulacao_cotovelo.name = "CotoveloArticulado"
	articulacao_cotovelo.position = VETOR_SUPERIOR
	ombro.add_child(articulacao_cotovelo)
	punho = Node2D.new()
	punho.name = "Punho"
	punho.position = VETOR_INFERIOR
	articulacao_cotovelo.add_child(punho)
	for peca: Node2D in [biceps, get_node("PlacaSuperior")]:
		peca.reparent(ombro, false)
		peca.position = -S * PROJECAO_SUPERIOR
		peca.scale = PROJECAO_SUPERIOR
	antebraco.reparent(articulacao_cotovelo, false)
	antebraco.position = -E
	var ponte: Sprite2D = get_node("FibraDaJunta") as Sprite2D
	var origem_ponte: Vector2 = ponte.position
	ponte.reparent(articulacao_cotovelo, false)
	ponte.position = origem_ponte - E
	var origem_cotovelo: Vector2 = cotovelo.position
	cotovelo.reparent(articulacao_cotovelo, false)
	cotovelo.position = origem_cotovelo - E
	for placa: Sprite2D in placas:
		placa.reparent(articulacao_cotovelo, false)
	mao.reparent(punho, false)
	mao.position = Vector2.ZERO
	articulado = true
	_atualizar_geometria()


func configurar_punho(textura: Texture2D) -> void:
	mao.texture = textura
	mao.centered = false
	# Centro do encaixe e direção dos nós dos dedos, conferidos no atlas.
	mao.offset = -Vector2(50, 278)
	mao.scale = Vector2.ONE * .56
	mao.rotation = VETOR_INFERIOR.angle() - Vector2(162, -217).angle()


func _atualizar_geometria() -> void:
	super._atualizar_geometria()
	if articulado:
		for placa: Sprite2D in placas:
			placa.position -= E


func apontar_para(alvo_global: Vector2) -> void:
	# IK analítica de dois segmentos. Limita alcance; nunca estica os ossos.
	var alvo: Vector2 = to_local(alvo_global)
	var superior: float = VETOR_SUPERIOR.length()
	var inferior: float = VETOR_INFERIOR.length()
	var distancia: float = clampf(alvo.length(), absf(inferior - superior) + 8.0, superior + inferior - 8.0)
	alvo_local = alvo.normalized() * distancia if not alvo.is_zero_approx() else Vector2.RIGHT * distancia
	var cosseno: float = clampf((distancia * distancia - superior * superior - inferior * inferior) / (2.0 * superior * inferior), -1.0, 1.0)
	var flexao: float = acos(cosseno) * lado_cotovelo
	var direcao: float = alvo_local.angle() - atan2(inferior * sin(flexao), superior + inferior * cos(flexao))
	ombro.rotation = direcao - VETOR_SUPERIOR.angle()
	articulacao_cotovelo.rotation = flexao + VETOR_SUPERIOR.angle() - VETOR_INFERIOR.angle()
