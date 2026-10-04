extends SceneTree

var falhas: int = 0

func _initialize() -> void:
	call_deferred("verificar")

func conferir(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error(mensagem)

func verificar() -> void:
	var jogo: Control = load("res://main.tscn").instantiate() as Control
	root.add_child(jogo)
	root.size = Vector2i(1024, 576)
	await process_frame
	var vega: Control = jogo.jogador.get_node_or_null("VegaAnimada") as Control
	conferir(vega != null, "Vega articulada ausente")
	if vega == null:
		jogo.queue_free()
		await process_frame
		quit(1)
		return
	conferir(not vega.is_processing(), "Vega anima por tras do mapa")
	jogo._iniciar_combate_por_id("drone_carga", false)
	await process_frame
	conferir(vega.estado_animacao == "repouso", "Combate nao iniciou em repouso")
	conferir_composicao(vega)
	var cabeca: Node2D = vega.get_node("Modelo/Skeleton2D/Tronco/Cabeca") as Node2D
	var antes: float = cabeca.rotation
	await create_timer(0.23).timeout
	conferir(not is_equal_approx(antes, cabeca.rotation), "Respiracao nao articula a cabeca")
	jogo._limpar_mao()
	jogo.baralho_combate.compra.assign(["golpe", "golpe", "protecao"])
	jogo._comprar_cartas(3)
	jogo.jogador_combate.energia = 0
	jogo._atualizar_interface()
	selecionar(jogo, "golpe")
	jogo._jogar_carta("inimigo", 0)
	conferir(vega.estado_animacao == "repouso", "Carta invalida disparou soco")
	jogo.jogador_combate.energia = 4
	jogo._atualizar_interface()
	var vida_inimiga: int = jogo.vida_inimigo
	jogo._jogar_carta("inimigo", 0)
	conferir(vega.estado_animacao == "soco", "Ataque valido nao disparou animacao")
	conferir(jogo.energia == 3 and jogo.vida_inimigo == vida_inimiga - 6, "Soco mudou custo ou dano")
	selecionar(jogo, "golpe")
	jogo._jogar_carta("inimigo", 0)
	conferir(jogo.energia == 2 and jogo.vida_inimigo == vida_inimiga - 12, "Animacao bloqueou acao rapida")
	await create_timer(0.85).timeout
	conferir(vega.estado_animacao == "repouso", "Soco nao voltou ao repouso")
	conferir_composicao(vega)
	selecionar(jogo, "protecao")
	var barreira_antes: int = jogo.barreira
	var energia_antes: int = jogo.energia
	var ponto: Vector2 = jogo.jogador.get_global_rect().get_center()
	var mover: InputEventMouseMotion = InputEventMouseMotion.new()
	mover.position = ponto
	mover.global_position = ponto
	root.push_input(mover)
	await process_frame
	for pressionado: bool in [true, false]:
		var clique: InputEventMouseButton = InputEventMouseButton.new()
		clique.position = ponto
		clique.global_position = ponto
		clique.button_index = MOUSE_BUTTON_LEFT
		clique.pressed = pressionado
		root.push_input(clique)
		await process_frame
	conferir(jogo.barreira == barreira_antes + 5 and jogo.energia == energia_antes - 1, "Arte bloqueou clique real no alvo Vega")
	conferir(vega.estado_animacao == "repouso", "Protecao disparou soco")
	jogo._iniciar_combate_por_id("caranguejo_sucata", false)
	var vida_antes: int = jogo.vida_jogador
	jogo._executar_intencao_inimigo()
	conferir(jogo.vida_jogador < vida_antes and vega.estado_animacao == "dano", "Dano real nao disparou reacao")
	await create_timer(0.7).timeout
	conferir(vega.estado_animacao == "repouso", "Dano nao voltou ao repouso")
	conferir_composicao(vega)
	jogo._iniciar_combate_por_id("caranguejo_sucata", false)
	jogo.jogador_combate.estado.barreira = 99
	jogo._atualizar_interface()
	jogo._executar_intencao_inimigo()
	conferir(vega.estado_animacao == "repouso", "Dano completamente absorvido disparou reacao na Vida")
	vega.socar()
	jogo._iniciar_nova_run()
	await process_frame
	conferir(not vega.is_processing(), "Animacao continuou no mapa")
	jogo._iniciar_combate_por_id("drone_carga", false)
	await process_frame
	conferir(vega.estado_animacao == "repouso", "Novo combate herdou acao anterior")
	vega.socar()
	await create_timer(0.19).timeout
	vega.receber_dano()
	await create_timer(0.6).timeout
	conferir_composicao(vega)
	print("VEGA ANIMADA: %d falhas" % falhas)
	jogo.queue_free()
	await process_frame
	quit(1 if falhas else 0)

func selecionar(jogo: Node, id: String) -> void:
	for carta: Button in jogo.mao.get_children():
		if str(carta.get_meta("id_carta")) == id:
			carta.button_pressed = true
			return
	conferir(false, "Carta ausente: " + id)

func conferir_composicao(vega: Control) -> void:
	var modelo: Node2D = vega.get_node("Modelo") as Node2D
	var skeleton: Skeleton2D = vega.get_node("Modelo/Skeleton2D") as Skeleton2D
	var torso: Sprite2D = vega.get_node("Modelo/Skeleton2D/Tronco/Arte") as Sprite2D
	var cabeca_arte: Sprite2D = vega.get_node("Modelo/Skeleton2D/Tronco/Cabeca/Arte") as Sprite2D
	var perna_frente: Node2D = vega.get_node("Modelo/Skeleton2D/PernaFrente") as Node2D
	var perna_tras: Node2D = vega.get_node("Modelo/Skeleton2D/PernaTras") as Node2D
	var braco_frente: Node2D = vega.get_node("Modelo/Skeleton2D/Tronco/BracoFrente") as Node2D
	var braco_tras: Node2D = vega.get_node("Modelo/Skeleton2D/Tronco/BracoTras") as Node2D
	var antebraco_frente: Node2D = vega.get_node("Modelo/Skeleton2D/Tronco/BracoFrente/AntebracoFrente") as Node2D
	var antebraco_tras: Node2D = vega.get_node("Modelo/Skeleton2D/Tronco/BracoTras/AntebracoTras") as Node2D
	var punho_frente: Node2D = vega.get_node("Modelo/Skeleton2D/Tronco/BracoFrente/AntebracoFrente/PunhoFrente") as Node2D
	var punho_tras: Node2D = vega.get_node("Modelo/Skeleton2D/Tronco/BracoTras/AntebracoTras/PunhoTras") as Node2D
	conferir(skeleton != null, "Skeleton2D ausente no combate")
	conferir(modelo.scale.x <= 0.46, "Modelo da Vega cresce demais")
	conferir(modelo.scale.x >= 0.25, "Modelo da Vega ficou pequeno demais")
	conferir(perna_frente.scale.x > 0.0 and perna_tras.scale.x > 0.0, "Perna espelhada horizontalmente")
	conferir(braco_frente.position.x < 0.0 and braco_tras.position.x > 0.0, "Ombros nao estao separados")
	conferir(braco_frente.z_index > 0 and braco_tras.z_index > 0, "Bracos nao estao em camadas visiveis")
	conferir(antebraco_frente.position.x > 0.0 and antebraco_tras.position.x < 0.0, "Cotovelos nao abrem a guarda")
	conferir(absf(punho_frente.global_position.x - punho_tras.global_position.x) >= 40.0, "Punhos ficam no mesmo corredor central")
	conferir(torso.visible and cabeca_arte.visible, "Torso ou cabeca ocultos")
	var proporcao: float = torso.texture.get_height() * torso.scale.y / (cabeca_arte.texture.get_height() * cabeca_arte.scale.y)
	conferir(proporcao > 2.0 and proporcao < 2.6, "Torso desproporcional em relacao a cabeca")
	conferir(torso.scale.y >= 0.56, "Torso curto na silhueta")
	conferir(perna_frente.get_node("Arte").scale.y <= 0.48 and perna_tras.get_node("Arte").scale.y <= 0.48, "Pernas dominam a silhueta")
	conferir(not vega.get_node("Modelo/Skeleton2D/Tronco/BracoFrente/BracoSuperiorFrente/Arte").texture.resource_path.contains("pecas.png"), "Braco frontal reutiliza textura de braco completo")
	conferir(not vega.get_node("Modelo/Skeleton2D/Tronco/BracoTras/BracoSuperiorTras/Arte").texture.resource_path.contains("pecas.png"), "Braco traseiro reutiliza textura de braco completo")
