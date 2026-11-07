class_name VegaGuardaDistanteV1
extends VegaOmbroIntegradoV1
## Só guarda estática; braço próximo aprovado não é recalibrado.

const BRACO_INTERNO: Script = preload("res://vega_animada/braco_reconstruido/distante/braco_distante.gd")
const PALETA: Shader = preload("res://vega_animada/braco_reconstruido/distante/paleta_distante.gdshader")
@export_range(110, 150, 1) var ombro_distante_guarda: float = 135
@export_range(105, 135, 1) var cotovelo_distante_guarda: float = 120
@export_range(1.0, 1.35, .01) var ajuste_mao_distante: float = 1.20
@export_range(0.0, 1.0, .05) var harmonizacao_cor: float = 1.0
var novo_distante: BracoDistanteRegistradoV1
var material_distante: ShaderMaterial
var ver_distante_anterior: bool = false


func _ready() -> void:
	super._ready()
	inspecionar(&"respirar", 0)
	_ativo = false
	novo_distante = BRACO_INTERNO.new() as BracoDistanteRegistradoV1
	novo_distante.name = "BracoInternoReconstruido"
	novo_distante.z_index = modelo.braco_distante.z_index
	modelo.deltoide_distante.add_child(novo_distante)
	# Mesma inserção, profundidade e projeção da cadeia distante existente.
	novo_distante.transform = modelo.braco_distante.transform
	# Calibração visual da palma, não da raiz ou dos ossos. A densidade raster
	# sozinha deixava a mão com apenas 77% do comprimento da próxima.
	novo_distante.segmentos[2].scale *= ajuste_mao_distante
	novo_distante.ombro.rotation = deg_to_rad(ombro_distante_guarda)
	novo_distante.cotovelo.rotation = deg_to_rad(cotovelo_distante_guarda)
	novo_distante.punho.rotation = 0
	material_distante = ShaderMaterial.new()
	material_distante.shader = PALETA
	for malha: Polygon2D in novo_distante.segmentos:
		malha.material = material_distante
	harmonizar_cor(harmonizacao_cor)
	comparar_distante(false)


func harmonizar_cor(intensidade: float) -> void:
	harmonizacao_cor = clampf(intensidade, 0, 1)
	material_distante.set_shader_parameter(&"intensidade", harmonizacao_cor)


func comparar_distante(anterior: bool) -> void:
	ver_distante_anterior = anterior
	modelo.braco_distante.visible = anterior
	novo_distante.visible = not anterior


func mostrar_juntas(ativo: bool) -> void:
	mostrar_marcos(ativo)
	novo_distante.mostrar_marcos = ativo
