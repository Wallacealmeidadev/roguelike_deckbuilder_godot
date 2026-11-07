extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Node = (load("res://main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	var estado: RunState = jogo.get("run_state") as RunState
	jogo.call("_mostrar_evento", "sobrevivente")
	_verificar(not (jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao3") as Button).visible, "sem flag, opção condicional fica oculta")
	jogo.call("_mostrar_evento", "ponto_da_queda")
	jogo.call("_ao_escolher_evento", 0)
	_verificar(estado.possui_flag("viu_relatorios_ataques"), "escolha do relatório persiste flag")
	jogo.call("_mostrar_evento", "sobrevivente")
	_verificar((jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao3") as Button).visible, "com flag, opção condicional aparece")
	jogo.call("_ao_escolher_evento", 2)
	_verificar(estado.possui_flag("compartilhou_relatorios"), "opção liberada concede outra flag")
	jogo.queue_free()
	if falhas == 0:
		print("OK: fluxo de flags no evento")
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
