extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var catalogo: Script = load("res://dados_cartas.gd") as Script
	var cartas: Dictionary = catalogo.get_script_constant_map()["CARTAS"]
	_verificar(cartas.has("brecha"), "o catálogo precisa conter Brecha")
	_verificar(cartas.has("pulso_debilitante"), "o catálogo precisa conter Pulso Debilitante")

	if cartas.has("brecha"):
		_verificar(cartas["brecha"]["exposto"] == 2, "Brecha deve aplicar Exposto 2")
	if cartas.has("pulso_debilitante"):
		_verificar(
			cartas["pulso_debilitante"]["enfraquecido"] == 2,
			"Pulso Debilitante deve aplicar Enfraquecido 2"
		)

	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame

	var drone: InimigoCombate = InimigoCombate.new(
		"drone_seguranca",
		DadosInimigos.obter("drone_seguranca")
	)
	(jogo.get("encontro_combate") as EncontroCombate).inimigo = drone
	jogo.call("_atualizar_interface")

	var estado_jogador: Combatente = jogo.get("estado_jogador") as Combatente
	var estado_inimigo: Combatente = jogo.get("estado_inimigo") as Combatente
	var jogador_combate: JogadorCombate = jogo.get("jogador_combate") as JogadorCombate
	var encontro_combate: EncontroCombate = jogo.get("encontro_combate") as EncontroCombate
	_verificar(estado_jogador != null, "main deve expor um Combatente para o jogador")
	_verificar(estado_inimigo != null, "main deve expor um Combatente para o inimigo")
	_verificar(jogador_combate != null, "main deve orquestrar um JogadorCombate")
	_verificar(encontro_combate != null, "main deve orquestrar um EncontroCombate")
	if jogador_combate != null:
		_verificar(
			jogo.get("estado_jogador") == jogador_combate.estado,
			"o estado legado do jogador deve delegar para JogadorCombate"
		)
	if encontro_combate != null:
		_verificar(
			jogo.get("estado_inimigo") == encontro_combate.inimigo,
			"o estado legado do inimigo deve delegar para EncontroCombate"
		)

	_verificar(jogo.has_method("_calcular_dano_no_inimigo"), "o dano contra o inimigo precisa passar por um cálculo por golpe")
	_verificar(jogo.has_method("_calcular_dano_do_inimigo"), "o dano do inimigo precisa passar por um cálculo por golpe")

	if falhas == 0:
		jogo.set("vida_inimigo", 30)
		jogo.set("barreira_inimigo", 0)
		jogo.set("exposto_inimigo", 2)
		jogo.call("_causar_dano_no_inimigo", 4)
		_verificar(jogo.get("vida_inimigo") == 24, "Exposto deve acrescentar 2 ao primeiro golpe")
		_verificar(estado_inimigo.vida == jogo.get("vida_inimigo"), "a Vida legada deve delegar para o Combatente do inimigo")
		_verificar(jogo.get("exposto_inimigo") == 1, "Exposto deve consumir uma carga por golpe")

		jogo.call("_causar_dano_no_inimigo", 4)
		_verificar(jogo.get("vida_inimigo") == 18, "Exposto deve acrescentar 2 ao segundo golpe")
		_verificar(jogo.get("exposto_inimigo") == 0, "Exposto deve terminar depois de duas cargas")

		jogo.set("vida_inimigo", 30)
		jogo.set("barreira_inimigo", 6)
		jogo.set("exposto_inimigo", 1)
		jogo.call("_causar_dano_no_inimigo", 4)
		_verificar(jogo.get("barreira_inimigo") == 0, "o dano modificado deve respeitar a Barreira")
		_verificar(jogo.get("vida_inimigo") == 30, "Exposto deve ser consumido mesmo quando a Barreira absorve tudo")
		_verificar(jogo.get("exposto_inimigo") == 0, "Exposto deve consumir a carga contra Barreira")

		jogo.set("vida_jogador", 40)
		jogo.set("barreira", 0)
		jogo.set("enfraquecido_inimigo", 2)
		(jogo.get("estado_inimigo") as InimigoCombate).indice_intencao = 0
		jogo.call("_executar_intencao_inimigo")
		_verificar(jogo.get("vida_jogador") == 38, "Enfraquecido deve reduzir cada golpe da Rajada em 2")
		_verificar(jogo.get("enfraquecido_inimigo") == 0, "Enfraquecido deve consumir uma carga por golpe")

		jogo.call("_criar_carta_na_mao", "brecha")
		var mao: Control = jogo.get_node("Mao") as Control
		var carta_brecha: Button = mao.get_child(mao.get_child_count() - 1) as Button
		carta_brecha.button_pressed = true
		jogo.call("_jogar_carta", "inimigo")
		_verificar(jogo.get("exposto_inimigo") == 2, "Brecha jogada deve aplicar Exposto 2")
		_verificar(
			(jogo.get_node("EstadosInimigoLabel") as Label).text.contains("Exposto: 2"),
			"o Drone deve mostrar as cargas de Exposto"
		)

		jogo.call("_criar_carta_na_mao", "pulso_debilitante")
		var carta_pulso: Button = mao.get_child(mao.get_child_count() - 1) as Button
		carta_pulso.button_pressed = true
		jogo.call("_jogar_carta", "inimigo")
		_verificar(jogo.get("enfraquecido_inimigo") == 2, "Pulso jogado deve aplicar Enfraquecido 2")
		_verificar(jogo.get("barreira") == 3, "Pulso jogado deve conceder 3 de Barreira")
		_verificar(
			(jogo.get_node("EstadosInimigoLabel") as Label).text.contains("Enfraquecido: 2"),
			"o Drone deve mostrar as cargas de Enfraquecido"
		)

		jogo.set("exposto_inimigo", 2)
		jogo.set("enfraquecido_inimigo", 2)
		jogo.call("_iniciar_combate")
		_verificar(jogo.get("exposto_inimigo") == 0, "Exposto deve reiniciar entre combates")
		_verificar(jogo.get("enfraquecido_inimigo") == 0, "Enfraquecido deve reiniciar entre combates")

	jogo.queue_free()

	if falhas == 0:
		print("OK: estados Exposto e Enfraquecido")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
