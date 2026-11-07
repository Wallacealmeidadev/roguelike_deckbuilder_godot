extends Control
## Preview isolado da nova fonte rig-ready; nao carrega regras de combate.

@onready var vega: Control = $VegaCorpoInteiroArticulada
@onready var estado_label: Label = $Estado


func _ready() -> void:
	vega.reiniciar()
	estado_label.text = "POSE NEUTRA"
