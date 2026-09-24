extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame

	_verificar(jogo.has_node("RecompensaElite"), "a cena deve ter a área do elite")
	_verificar(
		jogo.has_node("RecompensaElite/ReliquiasElite/RelquiaOpcao1"),
		"deve haver a primeira relíquia"
	)
	_verificar(
		jogo.has_node("RecompensaElite/ReliquiasElite/RelquiaOpcao2"),
		"deve haver a segunda relíquia"
	)
	_verificar(
		jogo.has_node("RecompensaElite/CartasRarasElite/CartaRaraOpcao1"),
		"deve haver a primeira carta rara"
	)
	_verificar(
		jogo.has_node("RecompensaElite/CartasRarasElite/CartaRaraOpcao2"),
		"deve haver a segunda carta rara"
	)
	_verificar(
		jogo.has_node("RecompensaElite/CartasRarasElite/CartaRaraOpcao3"),
		"deve haver a terceira carta rara"
	)
	if jogo.has_node("RecompensaElite"):
		_verificar(
			not jogo.get_node("RecompensaElite").visible,
			"a área deve começar escondida"
		)

	jogo.queue_free()
	if falhas == 0:
		print("OK: interface da recompensa do elite")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
