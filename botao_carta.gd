extends Button

@export var nome_carta: String = "GOLPE"
@export var custo: int = 1
@export_multiline var descricao: String = ""


func _ready() -> void:
	toggle_mode = true
	toggled.connect(_ao_alternar)
	_atualizar_texto()


func _ao_alternar(_selecionado: bool) -> void:
	_atualizar_texto()


func _atualizar_texto() -> void:
	text = "%s\nEnergia: %d\n\n%s" % [
		nome_carta,
		custo,
		descricao
	]

	if button_pressed:
		text += "\n\nSELECIONADA"
