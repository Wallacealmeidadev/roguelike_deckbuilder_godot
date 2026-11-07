extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	_verificar(
		ResourceLoader.exists("res://dados_cartas.gd"),
		"o catálogo de cartas precisa existir como recurso próprio"
	)

	var constantes: Dictionary = {}
	if falhas == 0:
		var script_catalogo: Script = load("res://dados_cartas.gd") as Script
		constantes = script_catalogo.get_script_constant_map()
		_verificar(constantes.has("CARTAS"), "o catálogo precisa expor CARTAS")

		if constantes.has("CARTAS"):
			var cartas: Dictionary = constantes["CARTAS"]
			_verificar(cartas.size() == 9, "o catálogo deve conter nove cartas")
			var raras: Array[String] = script_catalogo.identificadores_por_raridade("rara")
			_verificar(raras.size() == 3, "o catálogo deve ter três cartas raras")
			_verificar(raras.has("golpe_ariete"), "Golpe de Aríete deve ser raro")
			_verificar(raras.has("ruptura_pressao"), "Ruptura de Pressão deve ser rara")
			_verificar(raras.has("placa_reforcada"), "Placa Reforçada deve ser rara")
			_verificar(cartas["golpe"]["raridade"] == "comum", "cartas atuais devem ser comuns")
			_verificar(cartas["golpe"]["valor"] == 6, "Golpe deve manter dano 6")
			_verificar(cartas["protecao"]["valor"] == 5, "Proteção deve manter Barreira 5")
			_verificar(cartas["quebra_chassi"]["bonus_combo"] == 3, "Quebra-chassi deve manter bônus 3")
			_verificar(cartas.has("direto_hidraulico"), "o catálogo deve conter Direto Hidráulico")
			_verificar(cartas["brecha"]["exposto"] == 2, "Brecha deve aplicar Exposto 2")
			_verificar(cartas["pulso_debilitante"]["enfraquecido"] == 2, "Pulso deve aplicar Enfraquecido 2")
			_verificar(cartas["golpe_ariete"]["valor"] == 12, "Golpe de Aríete deve causar 12")
			_verificar(cartas["ruptura_pressao"]["exposto"] == 2, "Ruptura deve aplicar Exposto 2")
			_verificar(cartas["placa_reforcada"]["valor"] == 8, "Placa deve conceder Barreira 8")

			if cartas.has("direto_hidraulico"):
				_verificar(cartas["direto_hidraulico"]["valor"] == 4, "Direto deve manter dano 4")
				_verificar(cartas["direto_hidraulico"]["barreira"] == 2, "Direto deve gerar Barreira 2")
				_verificar(cartas["direto_hidraulico"]["ganha_combo"] == 1, "Direto deve declarar ganho de Combo 1")
				_verificar(not cartas["golpe"].has("ganha_combo"), "Golpe não deve declarar ganho de Combo")

	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	await get_tree().process_frame

	_verificar(jogo.get("CARTAS").size() == 9, "main.gd deve continuar usando o catálogo completo")

	if constantes.has("CARTAS") and constantes["CARTAS"].has("direto_hidraulico"):
		var vida_inimigo_antes: int = jogo.get("vida_inimigo")
		jogo.call("_criar_carta_na_mao", "direto_hidraulico")
		var mao: Control = jogo.get_node("Mao") as Control
		var carta_direto: Button = mao.get_child(mao.get_child_count() - 1) as Button
		carta_direto.button_pressed = true
		jogo.call("_jogar_carta", "inimigo")
		_verificar(
			jogo.get("vida_inimigo") == vida_inimigo_antes - 4,
			"Direto deve causar 4 de dano"
		)
		_verificar(jogo.get("barreira") == 2, "Direto deve gerar 2 de Barreira")
		_verificar(jogo.get("combo") == 1, "Direto deve gerar 1 Combo")
		jogo.call("_limpar_mao")
		jogo.call("_criar_carta_na_mao", "golpe")
		var carta_golpe: Button = (jogo.get_node("Mao") as Control).get_child(0) as Button
		_verificar(not str(carta_golpe.get("descricao")).contains("Combo"), "Golpe não deve exibir Combo na carta")
		_verificar(not str(jogo.call("_tooltip_recompensa", {"tipo": "ataque", "valor": 6})).contains("acumulam Combo"), "Golpe não deve usar tooltip antigo de Combo")
		_verificar(str(jogo.call("_tooltip_recompensa", {"tipo": "ataque", "valor": 4, "barreira": 2, "ganha_combo": 1})).contains("ganha 1"), "Direto deve informar Combo explícito no tooltip")
	jogo.queue_free()

	if falhas == 0:
		print("OK: catálogo de cartas preserva os dados do combate")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
