class_name VegaAcabamentoGolaV1
extends VegaCorpoArticuladoV1
## Retoque na UV da pele existente; não acrescenta uma peça rígida ao pescoço.

const RETOQUE: Texture2D = preload("res://vega_animada/corpo_articulado/acabamento_gola/atlas_gola_01.png")
const SOMBREADOR: Shader = preload("res://vega_animada/corpo_articulado/acabamento_gola/gola.gdshader")
# Coordenadas do atlas 1774 x 887. O topo contorna a mandíbula sem incluir a face.
const CONTORNO: Array[Vector2] = [
	Vector2(587, 148), Vector2(603, 157), Vector2(624, 163), Vector2(642, 158),
	Vector2(656, 180), Vector2(662, 205), Vector2(648, 217), Vector2(618, 208),
	Vector2(573, 179), Vector2(567, 156),
]

@export_range(0.0, 1.0, .05) var intensidade_gola: float = 1.0
var material_gola: ShaderMaterial


func _ready() -> void:
	super._ready()
	material_gola = ShaderMaterial.new()
	material_gola.shader = SOMBREADOR
	material_gola.set_shader_parameter(&"retoque", RETOQUE)
	material_gola.set_shader_parameter(&"tamanho_atlas", modelo.pele.texture.get_size())
	material_gola.set_shader_parameter(&"contorno", PackedVector2Array(CONTORNO))
	modelo.pele.material = material_gola
	definir_acabamento(intensidade_gola)


func definir_acabamento(valor: float) -> void:
	intensidade_gola = clampf(valor, 0, 1)
	if is_instance_valid(material_gola):
		material_gola.set_shader_parameter(&"intensidade", intensidade_gola)
