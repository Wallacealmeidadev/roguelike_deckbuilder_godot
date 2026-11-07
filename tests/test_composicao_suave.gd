extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.call("_iniciar_combate_por_id", "drone_carga", false)
	await get_tree().process_frame

	_verificar(jogo.has_node("TopoCombate/BarraVidaIntegrada"), "coração e vida precisam formar uma peça desenhada em conjunto")
	_verificar(jogo.has_node("VidaInimigoBar/VidaAnimada"), "a barra do inimigo precisa de camada visual animada")
	_verificar(jogo.has_node("ConfiguracoesOverlay/Movimento"), "movimento reduzido precisa estar acessível nas configurações")
	var inspecao: Control = jogo.get_node("HudInspecao") as Control
	inspecao.hide()
	(jogo.get_node("StatsJogadorPanel") as Control).mouse_entered.emit()
	_verificar(not inspecao.visible, "painel geral não deve abrir inspeção de recursos sobre o campo só com hover")
	if jogo.has_node("TopoCombate/BarraVidaIntegrada"):
		_verificar(not (jogo.get_node("TopoCombate/TopoCoracao") as Control).visible, "coração solto não pode duplicar a barra integrada")

	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		await get_tree().process_frame
		jogo.call("_layout_hud_combate")
		var menu: Array[Control] = [
			jogo.get_node("TopoCombate/TopoBaralho") as Control,
			jogo.get_node("TopoCombate/TopoRota") as Control,
			jogo.get_node("TopoCombate/TopoConfiguracoes") as Control
		]
		var inimigo: Control = jogo.get_node("Alvo") as Control
		var turno: Control = jogo.get_node("TurnoFaixa") as Control
		var area_vida: Rect2 = (jogo.get_node("TopoCombate/BarraVidaIntegrada") as Control).get_global_rect()
		_verificar(not area_vida.intersects((jogo.get_node("TopoCombate/TopoReliquias") as Control).get_global_rect()), "coração e trilho não podem invadir as relíquias em %s" % resolucao)
		_verificar(area_vida.grow(1.0).encloses((jogo.get_node("TopoCombate/TopoVida") as Control).get_global_rect()), "o número de Vida deve caber dentro da peça em %s" % resolucao)
		_verificar(absf(inimigo.size.y - inimigo.size.x / 3.75) < 1.0, "mínimo legado não deve deslocar a moldura e os textos do inimigo em %s" % resolucao)
		for controle: Control in menu:
			_verificar(controle.get_global_rect().position.x >= float(resolucao.x) * 0.75, "%s deve ficar no canto direito em %s" % [controle.name, resolucao])
			_verificar(not controle.get_global_rect().intersects(inimigo.get_global_rect()), "%s não pode invadir a vida do inimigo em %s" % [controle.name, resolucao])
			_verificar(not controle.get_global_rect().intersects(turno.get_global_rect()), "%s não pode invadir a faixa de turno em %s" % [controle.name, resolucao])
		_verificar(inimigo.get_global_rect().position.y > menu[0].get_global_rect().end.y + 6.0, "vida do inimigo deve ficar abaixo dos menus em %s" % resolucao)

	get_window().size = Vector2i(1024, 576)
	get_window().content_scale_size = Vector2i(1024, 576)
	await get_tree().process_frame
	if jogo.has_node("TopoCombate/BarraVidaIntegrada"):
		var vida_visual: Control = jogo.get_node("TopoCombate/BarraVidaIntegrada") as Control
		jogo.set("vida_jogador", 20)
		jogo.call("_atualizar_interface")
		_verificar((jogo.get_node("VidaJogadorBar") as ProgressBar).value == 20.0, "a vida lógica precisa atualizar sem esperar animação")
		_verificar(is_equal_approx(float(vida_visual.get("proporcao_alvo")), 0.5), "a barra visual deve receber 20/40")
		_verificar(float(vida_visual.get("proporcao_visual")) > 0.5, "a transição visual deve partir do valor anterior")
		await get_tree().create_timer(0.05).timeout
		_verificar(float(vida_visual.get("proporcao_rastro")) > float(vida_visual.get("proporcao_visual")), "perda de Vida precisa deixar rastro breve no trilho")
		for atualizacao: int in 8:
			jogo.call("_atualizar_interface")
			await get_tree().create_timer(0.03).timeout
		_verificar(absf(float(vida_visual.get("proporcao_visual")) - 0.5) < 0.01, "a animação da vida deve terminar no valor real")
		_verificar(absf(float(vida_visual.get("proporcao_rastro")) - 0.5) < 0.01, "atualizações repetidas não podem prolongar o rastro")
		for vida_baixa: int in [1, 0]:
			jogo.set("vida_jogador", vida_baixa)
			jogo.call("_atualizar_interface")
			await get_tree().create_timer(0.30).timeout
			_verificar(is_equal_approx(float(vida_visual.get("proporcao_visual")), float(vida_baixa) / 40.0), "1 HP e zero precisam ter preenchimentos distintos e corretos")
			_verificar(is_equal_approx(float(vida_visual.get("proporcao_rastro")), float(vida_baixa) / 40.0), "não pode sobrar rastro de Vida depois do esvaziamento")
		jogo.set("vida_jogador", 32)
		jogo.call("_atualizar_interface")
		_verificar((jogo.get_node("TopoCombate/TopoVida") as Label).text == "32 / 40" and bool(vida_visual.get("curando")), "recuperação deve atualizar o número imediatamente e substituir a perda")
		await get_tree().create_timer(0.28).timeout
		_verificar(is_equal_approx(float(vida_visual.get("proporcao_visual")), 0.8), "recuperação precisa terminar no valor correto sem ultrapassá-lo")
		jogo.set("vida_jogador", 8)
		jogo.call("_atualizar_interface")
		await get_tree().create_timer(0.05).timeout
		jogo.set("vida_jogador", 28)
		jogo.call("_atualizar_interface")
		await get_tree().create_timer(0.28).timeout
		_verificar(is_equal_approx(float(vida_visual.get("proporcao_visual")), 0.7) and is_equal_approx(float(vida_visual.get("proporcao_rastro")), 0.7), "recuperação durante o dano deve substituir a transição anterior sem rastro antigo")
	var vida_inimigo_visual: Control = jogo.get_node("VidaInimigoBar/VidaAnimada") as Control
	jogo.set("vida_inimigo", 20)
	jogo.call("_atualizar_interface")
	_verificar((jogo.get_node("VidaInimigoBar") as ProgressBar).value == 20.0, "vida real do inimigo não deve esperar a barra")
	_verificar(float(vida_inimigo_visual.get("proporcao_visual")) > float(vida_inimigo_visual.get("proporcao_alvo")), "barra inimiga deve começar a interpolar do valor anterior")
	await get_tree().create_timer(0.3).timeout
	_verificar(absf(float(vida_inimigo_visual.get("proporcao_visual")) - float(vida_inimigo_visual.get("proporcao_alvo"))) < 0.01, "barra inimiga deve terminar no valor real")
	var stats_visual: Control = jogo.get_node("StatsJogadorPanel/MolduraNeon") as Control
	var energia_visual: Control = jogo.get_node("EnergiaPainel/MolduraNeon") as Control
	jogo.set("combo", 2)
	jogo.set("barreira", 6)
	jogo.set("energia", 2)
	jogo.call("_atualizar_interface")
	_verificar(int(stats_visual.get("combo_atual")) == 2 and int(stats_visual.get("barreira_atual")) == 6, "recursos reais precisam continuar imediatos")
	_verificar(int(energia_visual.get("energia_atual")) == 2, "Energia real precisa continuar imediata")
	await get_tree().create_timer(0.3).timeout
	var combo_animado: Variant = stats_visual.get("combo_visual")
	var barreira_animada: Variant = stats_visual.get("barreira_visual")
	var energia_animada: Variant = energia_visual.get("energia_visual")
	_verificar(combo_animado != null and absf(float(combo_animado) - 2.0) < 0.01, "segmentos de Combo precisam terminar no valor real")
	_verificar(barreira_animada != null and absf(float(barreira_animada) - 6.0) < 0.01, "células de Barreira precisam terminar no valor real")
	_verificar(energia_animada != null and absf(float(energia_animada) - 2.0) < 0.01, "pontos de Energia precisam terminar no valor real")

	jogo.call("_limpar_mao")
	jogo.call("_criar_carta_na_mao", "golpe")
	await get_tree().process_frame
	var carta: Button = (jogo.get_node("Mao") as Control).get_child(0) as Button
	carta.button_pressed = true
	await get_tree().create_timer(0.2).timeout
	_verificar(carta.scale.x >= 1.2, "selecionar uma carta precisa ampliá-la o suficiente para leitura")
	var mira: Control = jogo.get_node("MiraCarta") as Control
	var centro_inimigo: Vector2 = (jogo.get_node("Alvo/DroneCampoSprite") as Control).get_global_rect().get_center()
	var centro_jogador: Vector2 = (jogo.get_node("Jogador") as Control).get_global_rect().get_center()
	jogo.call("_atualizar_mira_carta", centro_jogador)
	_verificar(mira.visible and not bool(mira.get("alvo_valido")), "ataque não deve marcar Vega como alvo válido")
	jogo.call("_atualizar_mira_carta", centro_inimigo)
	_verificar(mira.visible and bool(mira.get("alvo_valido")), "ataque precisa apontar para o corpo do inimigo")
	var energia_antes: int = int(jogo.get("energia"))
	jogo.set("energia", 0)
	jogo.call("_atualizar_mira_carta", centro_inimigo)
	_verificar(not bool(mira.get("alvo_valido")), "sem Energia a mira não pode confirmar um alvo")
	jogo.set("energia", energia_antes)
	var posicao_carta: Vector2 = carta.global_position
	(jogo.get_node("Alvo") as Button).pressed.emit()
	_verificar(int(jogo.get("energia")) == energia_antes - 1, "animação não pode atrasar o custo real")
	_verificar((jogo.get_node("Mao") as Control).get_child_count() == 0, "carta jogada deve sair da mão imediatamente")
	_verificar(jogo.has_node("CartaConsumida"), "confirmação precisa recolher a carta no cais")
	_verificar(not mira.visible, "confirmar deve retirar a mira imediatamente")
	var dano_visual: Control = jogo.get_node("DanoFeedbackLabel") as Control
	_verificar(dano_visual.visible, "impacto precisa acompanhar a confirmação, sem esperar um voo")
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(carta):
		_verificar(carta.global_position.distance_to(posicao_carta) < 25.0, "carta deve permanecer junto da mão durante o recolhimento")
	await get_tree().create_timer(0.16).timeout
	_verificar(not jogo.has_node("CartaConsumida"), "carta consumida não deve deixar objeto no campo")

	jogo.call("_criar_carta_na_mao", "protecao")
	var protecao: Button = jogo.get_node("Mao").get_child(0) as Button
	protecao.button_pressed = true
	jogo.call("_atualizar_mira_carta", centro_inimigo)
	_verificar(not bool(mira.get("alvo_valido")), "Proteção não pode mirar o inimigo")
	jogo.call("_atualizar_mira_carta", centro_jogador)
	_verificar(bool(mira.get("alvo_valido")), "Proteção deve mirar Vega")
	energia_antes = int(jogo.get("energia"))
	var cancelar: InputEventMouseButton = InputEventMouseButton.new()
	cancelar.button_index = MOUSE_BUTTON_RIGHT
	cancelar.pressed = true
	get_viewport().push_input(cancelar, true)
	_verificar(not protecao.button_pressed and not mira.visible, "botão direito deve cancelar seleção e mira")
	_verificar(int(jogo.get("energia")) == energia_antes, "cancelamento não pode consumir Energia")
	protecao.button_pressed = true
	(jogo.get_node("Jogador") as Button).grab_focus()
	jogo.set("mira_por_teclado", true)
	jogo.call("_atualizar_mira_carta", centro_inimigo)
	_verificar(bool(mira.get("alvo_valido")) and (mira.get("centro_alvo") as Vector2).distance_to(centro_jogador) < 1.0, "teclado deve apontar para o combatente focado")
	var mover: InputEventMouseMotion = InputEventMouseMotion.new()
	mover.position = centro_inimigo
	get_viewport().push_input(mover, true)
	jogo.call("_atualizar_mira_carta", centro_inimigo)
	_verificar(not bool(mira.get("alvo_valido")), "movimento do mouse deve abandonar o alvo focado pelo teclado")
	protecao.button_pressed = false

	if jogo.has_node("ConfiguracoesOverlay/Movimento"):
		(jogo.get_node("ConfiguracoesOverlay/Movimento") as Button).pressed.emit()
		_verificar(bool(jogo.get("movimento_reduzido")), "menu deve ligar movimento reduzido")
		if jogo.has_node("TopoCombate/BarraVidaIntegrada"):
			jogo.set("vida_jogador", 10)
			jogo.call("_atualizar_interface")
			var vida_reduzida: Control = jogo.get_node("TopoCombate/BarraVidaIntegrada") as Control
			_verificar(is_equal_approx(float(vida_reduzida.get("proporcao_visual")), 0.25), "movimento reduzido deve evitar deslocamento da barra")

	jogo.queue_free()
	print("COMPOSIÇÃO SUAVE: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
