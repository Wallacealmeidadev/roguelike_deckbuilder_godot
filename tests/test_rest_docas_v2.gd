extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Node = (load("res://main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	var estado: RunState = jogo.get("run_state") as RunState
	estado.no_atual = "combate_entrada"
	jogo.set("vida_jogador", 27)
	jogo.call("_ao_selecionar_no_mapa", "descanso_1")
	var overlay: Control = jogo.get_node("DescansoOverlay") as Control
	var melhorar: Button = overlay.get_node("Acoes/AprimorarPainel") as Button
	_verificar(overlay.visible, "REST abre overlay")
	_verificar(not melhorar.visible, "REST oferece somente cura nesta fase")
	(overlay.get_node("Acoes/RecuperarPainel") as Button).pressed.emit()
	_verificar(estado.vida_atual == 35, "cura provisória de oito persiste")
	(overlay.get_node("Continuar") as Button).pressed.emit()
	_verificar(estado.concluidos.has("descanso_1"), "REST concluído volta ao mapa")
	jogo.queue_free()
	if falhas == 0:
		print("OK: REST das Docas")
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
