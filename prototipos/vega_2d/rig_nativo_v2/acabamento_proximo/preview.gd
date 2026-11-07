extends Control
## F6 abre uma cópia do combate com a variante visual; F5 permanece igual.


func _ready() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	jogo.cena_apresentacao_vega = preload("res://prototipos/vega_2d/rig_nativo_v2/acabamento_proximo/vega_prova.tscn")
	add_child(jogo)
	await get_tree().process_frame
	jogo.call("_iniciar_combate_por_id", "drone_carga", false)
