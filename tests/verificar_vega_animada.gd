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
	# Este verificador inspeciona a geometria do modelo anterior, não o padrão nativo.
	jogo.cena_apresentacao_vega = preload("res://vega_animada/combate_v2/vega_combate.tscn")
	root.add_child(jogo)
	root.size = Vector2i(1024, 576)
	await process_frame
	var vega: Control = jogo.jogador.get_node_or_null("VegaAnimada") as Control
	conferir(vega != null, "Vega de playtest ausente")
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
	var visual: Control = vega.get_node("Visual") as Control
	var modelo: ModeloVegaCombateV2 = vega.get_node("Visual/Modelo") as ModeloVegaCombateV2
	var antes: PackedVector2Array = modelo.corpo.polygon
	await create_timer(0.7).timeout
	conferir(modelo.corpo.polygon != antes, "Repouso visual nao tem respiracao localizada")
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
	print("VEGA PLAYTEST FUNCIONAL: %d falhas" % falhas)
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
	var visual: Control = vega.get_node_or_null("Visual") as Control
	var modelo: ModeloVegaCombateV2 = vega.get_node_or_null("Visual/Modelo") as ModeloVegaCombateV2
	var sombra: Panel = vega.get_node_or_null("Sombra") as Panel
	conferir(vega.get_child_count() == 2, "Composicao do playtest possui camadas inesperadas")
	conferir(vega.get_node_or_null("Modelo/Skeleton2D") == null, "Rig segmentado permanece no combate")
	conferir(vega.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Vega intercepta input")
	conferir(visual != null, "Contenedor visual proprio ausente")
	conferir(sombra != null and sombra.visible, "Contato visual com o piso ausente")
	conferir(modelo != null and not vega.has_node("Visual/Arte"), "Modelo v2 deve substituir a ilustracao antiga, sem sobrepor")
	if modelo != null:
		conferir(modelo.corpo.texture.resource_path == "res://vega_animada/combate_v2/base_e_punhos_01.png", "Atlas de combate incorreto")
		conferir(visual.position.is_zero_approx() and visual.scale == Vector2.ONE, "Feedback nao pode deslocar ou escalar a figura inteira")
