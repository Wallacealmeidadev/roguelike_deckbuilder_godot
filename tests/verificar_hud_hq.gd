extends SceneTree

var falhas: int = 0

func _initialize() -> void:
	call_deferred("verificar")

func conferir(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error(mensagem)

func verificar() -> void:
	var cena: PackedScene = load("res://main.tscn")
	var jogo = cena.instantiate()
	root.add_child(jogo)
	await process_frame
	conferir(jogo.has_node("FeedbackRecursosNeon"), "Falta feedback neon de Energia/Barreira/Combo")
	if falhas > 0:
		jogo.queue_free()
		await process_frame
		quit(1)
		return
	jogo._iniciar_combate_por_id("drone_carga", false)
	var feedback = jogo.get_node("FeedbackRecursosNeon")
	await create_timer(0.6).timeout
	# Fixture real: duas cartas geradoras e uma Finalização.
	jogo._limpar_mao()
	jogo.baralho_combate.compra.assign(["direto_hidraulico", "direto_hidraulico", "quebra_chassi"])
	jogo._comprar_cartas(3)
	jogar(jogo, "direto_hidraulico")
	conferir(jogo.energia == 3 and jogo.combo == 1 and jogo.barreira == 2, "Carta alterou regra de recursos")
	await create_timer(0.07).timeout
	conferir(jogo.combo_label.scale.x > 1.0, "Ganho de Combo não teve salto visual")
	conferir(jogo.energia_painel.get_node("MolduraNeon").energia_atual == 3, "Marcadores neon não acompanharam gasto")
	jogar(jogo, "direto_hidraulico")
	jogar(jogo, "quebra_chassi")
	conferir(jogo.combo == 0 and jogo.energia == 1, "Finalização não preservou custos")
	conferir(feedback.painel_stats.impacto_combo > 0.0, "Finalização não disparou estampido")
	await create_timer(0.65).timeout
	conferir(jogo.combo_label.scale.is_equal_approx(Vector2.ONE), "Combo permaneceu escalado")
	conferir(feedback.painel_stats.impacto_combo == 0.0, "Combo continuou animando em repouso")
	# Dano real: Caranguejo aplica 3x3. Cinco de Barreira são consumidos.
	jogo._iniciar_combate_por_id("caranguejo_sucata", false)
	if jogo.encontro_combate.inimigos.is_empty():
		jogo._iniciar_combate_por_id("caranguejo", false)
	jogo.jogador_combate.estado.barreira = 5
	jogo._atualizar_interface()
	var vida_antes: int = jogo.vida_jogador
	jogo._executar_intencao_inimigo()
	conferir(jogo.barreira == 0 and jogo.vida_jogador == vida_antes - 4, "Absorção de Barreira foi alterada")
	conferir(feedback.painel_stats.quebra_barreira, "Barreira consumida não disparou fragmentos")
	await create_timer(0.65).timeout
	conferir(feedback.painel_stats.impacto_barreira == 0.0, "Barreira não voltou ao repouso")
	jogo.combo = 2
	jogo._atualizar_interface()
	await create_timer(0.5).timeout
	jogo._ao_encerrar_turno()
	conferir(feedback.painel_stats.impacto_combo == 0.0, "Fim de turno confundido com Finalização")
	conferir(jogo.energia == 4, "Energia não restaurada")
	await create_timer(0.65).timeout
	conferir(jogo.energia_visual_label.scale.is_equal_approx(Vector2.ONE), "Energia ficou escalada")
	conferir(jogo.combo_label.scale.is_equal_approx(Vector2.ONE), "Combo ficou escalado após reset")
	print("HUD NEON: %d falhas" % falhas)
	jogo.queue_free()
	await process_frame
	quit(1 if falhas > 0 else 0)

func jogar(jogo: Node, id_carta: String) -> void:
	for carta: Button in jogo.mao.get_children():
		if str(carta.get_meta("id_carta")) == id_carta:
			carta.button_pressed = true
			jogo._jogar_carta("inimigo", 0)
			return
	conferir(false, "Carta ausente: " + id_carta)
