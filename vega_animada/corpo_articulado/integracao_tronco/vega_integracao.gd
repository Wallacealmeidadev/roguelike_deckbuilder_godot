class_name VegaIntegracaoTroncoV1
extends VegaAcabamentoGolaV1
## Pintura registrada e sombra receptora. Nenhuma escrita nos ossos/clipes.

const PINTURA: Texture2D = preload("res://vega_animada/corpo_articulado/integracao_tronco/atlas_tronco_01.png")
const INTEGRACAO: Shader = preload("res://vega_animada/corpo_articulado/integracao_tronco/integracao.gdshader")
const OMBRO: Shader = preload("res://vega_animada/corpo_articulado/integracao_tronco/ombro.gdshader")
const CONTORNO_TRONCO: Array[Vector2] = [
	Vector2(476, 145), Vector2(546, 145), Vector2(574, 165), Vector2(622, 194),
	Vector2(657, 193), Vector2(655, 177), Vector2(681, 184), Vector2(722, 226),
	Vector2(695, 335), Vector2(517, 335),
]

@export_range(0.0, 1.0, .05) var intensidade_integracao: float = 1.0
@export_range(0.0, .6, .02) var sombra_contato: float = .32
var material_ombro: ShaderMaterial


func _ready() -> void:
	super._ready()
	material_gola.shader = INTEGRACAO
	material_gola.set_shader_parameter(&"retoque", RETOQUE)
	material_gola.set_shader_parameter(&"tamanho_atlas", modelo.pele.texture.get_size())
	material_gola.set_shader_parameter(&"contorno", PackedVector2Array(CONTORNO))
	material_gola.set_shader_parameter(&"contorno_tronco", PackedVector2Array(CONTORNO_TRONCO))
	material_gola.set_shader_parameter(&"pintura_tronco", PINTURA)
	_preparar_pintura_ombro()
	definir_acabamento(intensidade_gola)
	definir_integracao(intensidade_integracao)
	definir_sombra(sombra_contato)
	# Ler a pose depois da avaliação do AnimationPlayer, antes da renderização.
	RenderingServer.frame_pre_draw.connect(sincronizar_sombra)
	sincronizar_sombra()


func definir_integracao(valor: float) -> void:
	intensidade_integracao = clampf(valor, 0, 1)
	material_gola.set_shader_parameter(&"integracao", intensidade_integracao)
	material_ombro.set_shader_parameter(&"integracao", intensidade_integracao)


func _preparar_pintura_ombro() -> void:
	var anterior: ShaderMaterial = remendo_ombro.material as ShaderMaterial
	material_ombro = ShaderMaterial.new()
	material_ombro.shader = OMBRO
	for chave: StringName in [&"pele_original", &"tamanho_atlas", &"tamanho_pele", &"regiao", &"recorte"]:
		material_ombro.set_shader_parameter(chave, anterior.get_shader_parameter(chave))
	material_ombro.set_shader_parameter(&"pintura_tronco", PINTURA)
	remendo_ombro.material = material_ombro


func definir_sombra(valor: float) -> void:
	sombra_contato = clampf(valor, 0, .6)
	material_gola.set_shader_parameter(&"forca_sombra", sombra_contato)


func sincronizar_sombra() -> void:
	var ombro: Vector2 = braco_novo.ombro.get_global_transform_with_canvas().origin
	var cotovelo: Vector2 = braco_novo.cotovelo.get_global_transform_with_canvas().origin
	var punho: Vector2 = braco_novo.punho.get_global_transform_with_canvas().origin
	var fator: float = braco_novo.ombro.get_global_transform_with_canvas().x.length()
	material_gola.set_shader_parameter(&"braco_superior", Vector4(ombro.x, ombro.y, cotovelo.x, cotovelo.y))
	material_gola.set_shader_parameter(&"antebraco", Vector4(cotovelo.x, cotovelo.y, punho.x, punho.y))
	material_gola.set_shader_parameter(&"raios", Vector2(22, 25) * fator)
	material_gola.set_shader_parameter(&"deslocamento", Vector2(4, 7) * fator)
