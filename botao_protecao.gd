extends Button

@export var nome_carta: String = "GOLPE"


func _ready() -> void:
	toggle_mode = true
	toggled.connect(_ao_alternar)
	_ao_alternar(button_pressed)


func _ao_alternar(selecionado: bool) -> void:
	if selecionado:
		text = "%s\nSELECIONADA" % nome_carta
	else:
		text = nome_carta
