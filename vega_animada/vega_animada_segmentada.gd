extends Control
## Candidata isolada do rig segmentado; a API de animação entra na Task 3.

const ALTURA_REFERENCIA: float = 460.0
const ESCALA_MAXIMA: float = 0.44

@onready var modelo: Node2D = $Modelo

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_ajustar_tamanho)
	_ajustar_tamanho()

func _ajustar_tamanho() -> void:
	var fator: float = minf(ESCALA_MAXIMA, maxf(0.01, (size.y - 12.0) / ALTURA_REFERENCIA))
	modelo.scale = Vector2.ONE * fator
	modelo.position = Vector2(size.x * 0.50, size.y - 8.0)
