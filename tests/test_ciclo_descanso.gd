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
	jogo.set("vida_jogador", 30)
	jogo.call("_ao_selecionar_no_mapa", "descanso_1")
	var overlay: Control = jogo.get_node("DescansoOverlay") as Control
	var recuperar: Button = overlay.get_node("Acoes/RecuperarPainel") as Button
	var aprimorar: Button = overlay.get_node("Acoes/AprimorarPainel") as Button
	_verificar(overlay.visible and not recuperar.disabled, "REST deve abrir cura quando há Vida perdida")
	_verificar(not aprimorar.visible, "REST não oferece melhoria de carta")
	recuperar.pressed.emit()
	recuperar.pressed.emit()
	_verificar(estado.vida_atual == 38, "cura de 8 não deve duplicar")
	_verificar(not estado.concluidos.has("descanso_1"), "ação sem continuar não conclui nó")
	(overlay.get_node("Continuar") as Button).pressed.emit()
	_verificar(estado.concluidos.has("descanso_1"), "continuar conclui REST")
	_verificar((jogo.get_node("MapaOverlay") as Control).visible, "REST retorna ao mapa")
	jogo.queue_free()
	var jogo_cheio: Node = (load("res://main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(jogo_cheio)
	await get_tree().process_frame
	var estado_cheio: RunState = jogo_cheio.get("run_state") as RunState
	estado_cheio.no_atual = "combate_entrada"
	jogo_cheio.call("_ao_selecionar_no_mapa", "descanso_1")
	var continuar_cheio: Button = jogo_cheio.get_node("DescansoOverlay/Continuar") as Button
	_verificar(continuar_cheio.visible, "REST com Vida cheia deve permitir prosseguir")
	continuar_cheio.pressed.emit()
	_verificar(estado_cheio.concluidos.has("descanso_1"), "Vida cheia não bloqueia a rota")
	jogo_cheio.queue_free()
	if falhas == 0:
		print("OK: ciclo de descanso")
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
