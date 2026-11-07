extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	await get_tree().process_frame
	var mao: Control = jogo.get_node("Mao") as Control
	for resolucao in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		await get_tree().process_frame
		for quantidade in [6, 10]:
			jogo.call("_limpar_mao")
			for indice in quantidade:
				jogo.call("_criar_carta_na_mao", "golpe")
			jogo.call("_redimensionar_cartas_da_mao")
			await get_tree().process_frame
			await get_tree().process_frame
			var dock: Rect2 = (jogo.get_node("MaoDock") as Control).get_global_rect()
			for caminho: String in ["EnergiaPainel", "CompraPainel", "DescartePainel", "EncerrarTurno"]:
				_verificar(not dock.intersects((jogo.get_node(caminho) as Control).get_global_rect()), "cais não pode cobrir %s em %s" % [caminho, resolucao])
			for indice_foco: int in [0, quantidade / 2, quantidade - 1]:
				var focada: Button = mao.get_child(indice_foco) as Button
				focada.grab_focus()
				await get_tree().create_timer(0.2).timeout
				var limites: Rect2 = _retangulo_transformado(focada)
				_verificar(limites.position.x >= dock.position.x and limites.end.x <= dock.end.x, "foco deve permanecer na coluna das cartas: %s" % limites)
				for caminho: String in ["EnergiaPainel", "CompraPainel", "DescartePainel", "EncerrarTurno", "StatsJogadorPanel"]:
					_verificar(not limites.intersects((jogo.get_node(caminho) as Control).get_global_rect()), "carta focada não pode cobrir %s em %s" % [caminho, resolucao])
				focada.release_focus()
			await get_tree().create_timer(0.2).timeout
			var anterior: Control
			for indice in quantidade:
				var carta: Control = mao.get_child(indice) as Control
				_verificar(absf(carta.rotation) > 0.001 or indice == (quantidade - 1) / 2, "curva da mao %d na carta %d" % [quantidade, indice])
				if anterior != null:
					_verificar(carta.z_index > anterior.z_index + 6, "moldura da carta precisa encobrir o texto da anterior")
					var passo: float = carta.position.x - anterior.position.x
					_verificar(passo > 38.0 and passo < carta.size.x, "cada carta precisa de uma faixa acessivel e de sobreposicao")
				anterior = carta
			var ativa: Button = mao.get_child(quantidade / 2) as Button
			var y_repouso: float = ativa.position.y
			ativa.grab_focus()
			await get_tree().create_timer(0.2).timeout
			_verificar(absf(ativa.rotation) < 0.001, "foco de teclado deve endireitar")
			_verificar(ativa.position.y < y_repouso - 8.0, "foco deve levantar")
			_verificar(ativa.z_index > (mao.get_child(0) as Control).z_index, "foco deve vir a frente")
			_verificar(not ativa.get_global_rect().intersects((jogo.get_node("IntencaoIcone") as Control).get_global_rect()), "carta erguida nao deve cobrir a intencao")
			_verificar(not ativa.get_global_rect().intersects((jogo.get_node("IntencaoValorVisualLabel") as Control).get_global_rect()), "carta erguida nao deve cobrir o valor da intencao")
			ativa.button_pressed = true
			ativa.release_focus()
			await get_tree().create_timer(0.2).timeout
			_verificar(ativa.z_index > 0 and absf(ativa.rotation) < 0.001, "selecao deve persistir sem foco")
			ativa.button_pressed = false
			await get_tree().create_timer(0.2).timeout
			_verificar(absf(ativa.rotation) > 0.001 or quantidade == 6, "cancelamento deve restaurar o leque")
	get_window().size = Vector2i(1024, 576)
	get_window().content_scale_size = Vector2i(1024, 576)
	await get_tree().process_frame
	await get_tree().process_frame
	(mao.get_child(0) as Button).grab_focus()
	var tab: InputEventKey = InputEventKey.new()
	tab.keycode = KEY_TAB
	tab.pressed = true
	get_viewport().push_input(tab, true)
	await get_tree().process_frame
	_verificar(get_viewport().gui_get_focus_owner() == mao.get_child(1), "Tab deve alcancar a proxima carta da mao")
	var aceitar: InputEventKey = InputEventKey.new()
	aceitar.keycode = KEY_ENTER
	aceitar.pressed = true
	get_viewport().push_input(aceitar, true)
	aceitar.pressed = false
	get_viewport().push_input(aceitar, true)
	await get_tree().process_frame
	_verificar((mao.get_child(1) as Button).button_pressed, "Enter deve selecionar a carta focada")
	(mao.get_child(1) as Button).button_pressed = false
	get_viewport().gui_release_focus()
	var carta_mouse: Button = mao.get_child(0) as Button
	var ponto_mouse: Vector2 = carta_mouse.get_global_rect().position + Vector2(18.0, 40.0)
	var movimento: InputEventMouseMotion = InputEventMouseMotion.new()
	movimento.position = ponto_mouse
	get_viewport().push_input(movimento, true)
	await get_tree().process_frame
	_verificar(bool(carta_mouse.get("_mouse_sobre")), "mouse deve alcançar a faixa exposta da carta")
	var clique: InputEventMouseButton = InputEventMouseButton.new()
	clique.button_index = MOUSE_BUTTON_LEFT
	clique.position = ponto_mouse
	clique.pressed = true
	get_viewport().push_input(clique, true)
	clique.pressed = false
	get_viewport().push_input(clique, true)
	await get_tree().process_frame
	_verificar(carta_mouse.button_pressed, "clique do mouse deve selecionar a carta")
	jogo.call("_atualizar_mira_carta", (jogo.get_node("Alvo/DroneCampoSprite") as Control).get_global_rect().get_center())
	_verificar((jogo.get_node("MiraCarta") as Control).visible and bool(jogo.get_node("MiraCarta").get("alvo_valido")), "ataque selecionado deve mirar o corpo do alvo valido")
	_verificar(not (jogo.get_node("Alvo/Interacao") as Control).visible, "mira nao deve duplicar um retangulo de selecao")
	_verificar(not (jogo.get_node("Jogador/Interacao") as Control).visible, "ataque nao deve destacar o alvo invalido")
	var cancelar: InputEventKey = InputEventKey.new()
	cancelar.keycode = KEY_ESCAPE
	cancelar.pressed = true
	get_viewport().push_input(cancelar, true)
	await get_tree().process_frame
	_verificar(not carta_mouse.button_pressed, "Escape deve cancelar a selecao sem jogar")
	_verificar(not (jogo.get_node("MiraCarta") as Control).visible, "Escape deve retirar a mira")
	_verificar(not (jogo.get_node("Alvo/Interacao") as Control).visible, "cancelamento deve retirar o destaque de alvo")
	for indice in mao.get_child_count():
		var carta_acessivel: Button = mao.get_child(indice) as Button
		var faixa: Vector2 = carta_acessivel.get_global_rect().position + Vector2(18.0, carta_acessivel.size.y - 20.0)
		var mover: InputEventMouseMotion = InputEventMouseMotion.new()
		mover.position = faixa
		get_viewport().push_input(mover, true)
		await get_tree().create_timer(0.15).timeout
		_verificar(bool(carta_acessivel.get("_mouse_sobre")), "mouse deve alcancar individualmente a carta %d de dez" % indice)
	# A jogada real continua resolvendo contra o alvo e retira a carta da mao.
	var primeira: Button = mao.get_child(0) as Button
	primeira.button_pressed = true
	var vida_antes: int = jogo.get("vida_inimigo")
	(jogo.get_node("Alvo") as Button).pressed.emit()
	_verificar(jogo.get("vida_inimigo") < vida_antes, "jogada real deve causar dano")
	_verificar(mao.get_child_count() == 9, "jogada deve remover a carta selecionada")
	jogo.queue_free()
	if falhas == 0:
		print("OK: mao HQ e foco")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)


func _retangulo_transformado(controle: Control) -> Rect2:
	var transformacao: Transform2D = controle.get_global_transform_with_canvas()
	var limite: Rect2 = Rect2(transformacao * Vector2.ZERO, Vector2.ZERO)
	for ponto: Vector2 in [Vector2(controle.size.x, 0), controle.size, Vector2(0, controle.size.y)]:
		limite = limite.expand(transformacao * ponto)
	return limite
