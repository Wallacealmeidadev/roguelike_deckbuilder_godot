extends Control
## Preview isolado da candidata segmentada; nao carrega regras de combate.

@onready var vega: Control = $VegaAnimada
@onready var estado_label: Label = $Estado

func _ready() -> void:
	definir_estado("repouso")

func definir_estado(nome: String) -> void:
	estado_label.text = nome.to_upper()
	match nome:
		"guarda", "repouso", "reiniciar":
			vega.reiniciar()
		"soco":
			vega.socar()
		"dano":
			vega.receber_dano()
