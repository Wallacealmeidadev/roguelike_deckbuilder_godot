extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		for caso: Array in [["drone_seguranca", "cais"], ["carga", "patio"], ["guindaste", "bombas"]]:
			jogo.call("_iniciar_combate_por_id", caso[0], false)
			await get_tree().process_frame
			_verificar(jogo.get_node("ArenaChao").get("id_arena") == caso[1], "arena deve acompanhar o encontro sem sorteio extra")
			_verificar((jogo.get_node("ArenaChao/CenarioDocas") as TextureRect).texture != null, "arena precisa de arte real")
		jogo.call("_iniciar_combate_por_id", "carga_reparador", false)
		await get_tree().process_frame
		for placa: Button in jogo.get("alvos_multiplos"):
			var sprite: Control = placa.get_node("DroneCampoSprite") as Control
			var sombra: Control = sprite.get_node("SombraDrone") as Control
			var piso: float = sombra.get_global_rect().get_center().y
			_verificar(absf(piso - resolucao.y * 0.61) < 15.0, "sombra do drone deve acompanhar o piso da Vega")
			_verificar(sprite.get_global_rect().position.y > placa.get_global_rect().end.y, "corpo do drone não deve ficar atrás da placa")
		jogo.call("_iniciar_combate_por_id", "carga", false)
		await get_tree().process_frame
		var drone: Control = jogo.get_node("Alvo/DroneCampoSprite") as Control
		var area: Rect2 = drone.get_global_rect()
		var corpo: Control = drone.get_node("CorpoAnimado") as Control
		var posicao: Vector2 = corpo.position
		await get_tree().create_timer(0.2).timeout
		_verificar(corpo.position != posicao, "repouso do drone deve se mover")
		_verificar(drone.get_global_rect() == area, "repouso não deve mover a caixa de clique")
		drone.call("reagir", "ataque")
		await get_tree().create_timer(0.07).timeout
		_verificar(drone.get("estado_animacao") == "ataque", "drone deve responder ao ataque")
		drone.call("reagir", "dano")
		_verificar(drone.get("estado_animacao") == "dano", "dano deve substituir feedback anterior")
		_verificar(drone.get_global_rect() == area, "recuo também deve preservar a caixa de clique")
		var fim: Button = jogo.get_node("EncerrarTurno") as Button
		fim.grab_focus()
		await get_tree().create_timer(0.16).timeout
		_verificar(not (fim.get_node("Interacao") as Control).visible, "foco não deve reativar caixa retangular")
		_verificar(float(fim.get_node("RealceNeon").get("intensidade")) > 0.9, "teclado deve continuar com foco visível")
		var inimigo: InimigoCombate = jogo.get("estado_inimigo") as InimigoCombate
		inimigo.indice_intencao = 1
		var vida_antes: int = int(jogo.get("vida_jogador"))
		jogo.call("_ao_encerrar_turno")
		_verificar(float(fim.get_node("RealceNeon").get("confirmacao")) > 0.0, "encerrar turno precisa confirmar visualmente")
		_verificar(int(jogo.get("turno")) == 2, "animação não pode adiar a resolução lógica do turno")
		_verificar(drone.get("estado_animacao") == "ataque" and int(jogo.get("vida_jogador")) < vida_antes, "intenção real deve causar dano e acionar o movimento do drone")
		jogo.set("movimento_reduzido", true)
		await get_tree().process_frame
		drone.call("reagir", "ataque")
		await get_tree().create_timer(0.05).timeout
		_verificar(corpo.position.is_zero_approx() and is_zero_approx(corpo.rotation), "modo reduzido deve evitar suspensão e investida")
		var visual_vega: Control = jogo.get_node("Jogador/VegaAnimada/Visual") as Control
		_verificar(visual_vega.scale.is_equal_approx(Vector2.ONE), "modo reduzido deve parar respiração transformada")
		jogo.set("movimento_reduzido", false)
		get_viewport().gui_release_focus()
	jogo.queue_free()
	await get_tree().process_frame
	print("POLIMENTO COMBATE: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error(mensagem)
