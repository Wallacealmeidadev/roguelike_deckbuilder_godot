extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)

	await get_tree().process_frame

	_verificar(jogo.has_method("_ganhar_combo"), "o ganho de Combo precisa centralizar a regra da relíquia")
	_verificar(jogo.has_node("ReliquiaLabel"), "a relíquia precisa ser identificável na interface")

	if falhas == 0:
		_verificar(
			(jogo.get_node("ReliquiaLabel") as Label).text.contains("Juntas de Retorno"),
			"a interface precisa mostrar Juntas de Retorno"
		)

		jogo.set("vida_inimigo", 100)
		jogo.call("_ganhar_combo")
		_verificar(jogo.get("combo") == 1, "o primeiro ganho deve levar Combo a 1")
		_verificar(jogo.get("barreira") == 0, "Juntas não deve ativar antes de 2 Combo")

		jogo.call("_ganhar_combo")
		_verificar(jogo.get("combo") == 2, "o segundo ganho deve levar Combo a 2")
		_verificar(jogo.get("barreira") == 3, "Juntas deve conceder 3 de Barreira ao chegar a 2 Combo")
		var jogador_combate: JogadorCombate = jogo.get("jogador_combate") as JogadorCombate
		_verificar(
			jogador_combate.juntas_retorno_ativada_no_turno,
			"a ativação da relíquia deve pertencer ao estado do jogador"
		)

		jogo.call("_ganhar_combo")
		_verificar(jogo.get("combo") == 3, "Combo deve continuar acumulando depois da relíquia")
		_verificar(jogo.get("barreira") == 3, "Juntas só deve ativar uma vez por turno")

		jogo.set("combo", 0)
		jogo.call("_ganhar_combo")
		jogo.call("_ganhar_combo")
		_verificar(jogo.get("combo") == 2, "Combo deve poder voltar a 2 após ser consumido")
		_verificar(jogo.get("barreira") == 3, "consumir Combo não deve reativar Juntas no mesmo turno")

		jogo.call("_iniciar_turno")
		jogo.set("combo", 0)
		jogo.call("_ganhar_combo")
		jogo.call("_ganhar_combo")
		_verificar(jogo.get("barreira") == 3, "Juntas deve poder ativar novamente no turno seguinte")

	jogo.queue_free()

	if falhas == 0:
		print("OK: Juntas de Retorno ativa uma vez por turno")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
