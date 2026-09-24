extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame

	jogo.set("vida_jogador", 31)
	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")

	var recompensas: GridContainer = jogo.get_node("Recompensas") as GridContainer
	_verificar(recompensas.visible, "as opções devem aparecer após a vitória")
	_verificar(jogo.get("baralho_run").size() == 12, "o baralho deve manter o tamanho antes do skip")
	_verificar(jogo.has_node("Recompensas/Pular"), "a oferta deve ter uma opção de skip")

	var pular: Button = jogo.get_node("Recompensas/Pular") as Button
	pular.pressed.emit()

	_verificar(jogo.get("baralho_run").size() == 12, "skip não deve alterar o baralho")
	_verificar(jogo.get("vida_jogador") == 31, "skip deve preservar a Vida")
	_verificar(not jogo.get("aguardando_recompensa"), "skip deve encerrar a espera pela recompensa")
	_verificar(jogo.get("roteiro_run").etapa_atual() == "evento", "skip deve levar ao evento seguinte")
	_verificar((jogo.get_node("EventoOverlay") as Control).visible, "o evento deve aparecer após o skip")
	_verificar(not recompensas.visible, "a recompensa deve esconder após o skip")

	jogo.queue_free()

	if falhas == 0:
		print("OK: skip de recompensa")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
