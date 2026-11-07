extends Node

const DadosCartas = preload("res://dados_cartas.gd")

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	get_window().size = Vector2i(1280, 720)
	get_window().content_scale_size = Vector2i(1280, 720)
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	await get_tree().process_frame
	print("LAYOUT_DIAGNOSTICO viewport=%s root=%s janela=%s" % [jogo.get_viewport_rect().size, jogo.size, get_window().size])

	for resolucao in [Vector2i(1024, 576), Vector2i(1920, 1080), Vector2i(1024, 576)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		await get_tree().process_frame
		await get_tree().process_frame
		for carta_no in (jogo.get_node("Mao") as Control).get_children():
			var carta_dimensionada: Control = carta_no as Control
			_verificar(carta_dimensionada.size.is_equal_approx(carta_dimensionada.custom_minimum_size), "tamanho efetivo divergente no retorno %s: size=%s minimo=%s" % [resolucao, carta_dimensionada.size, carta_dimensionada.custom_minimum_size])

	var carta_nova: Button = (load("res://carta.tscn") as PackedScene).instantiate() as Button
	get_tree().root.add_child(carta_nova)
	carta_nova.call("configurar_escala", 0.8, true)
	await get_tree().process_frame
	_verificar(carta_nova.size.is_equal_approx(carta_nova.custom_minimum_size), "carta nova precisa aplicar o tamanho de combate: size=%s minimo=%s" % [carta_nova.size, carta_nova.custom_minimum_size])
	carta_nova.queue_free()
	get_window().size = Vector2i(1280, 720)
	get_window().content_scale_size = Vector2i(1280, 720)
	await get_tree().process_frame
	await get_tree().process_frame

	for nome in ["TurnoLabel", "PilhasLabel", "IntencaoLabel", "EstadosInimigoLabel"]:
		_verificar(not (jogo.get_node(nome) as Control).visible, "%s duplicou texto visual" % nome)

	var pares: Array[Array] = [
		["TurnoTituloLabel", "TurnoNumeroLabel"],
		["TurnoNumeroLabel", "AcaoLabel"],
		["IntencaoPainel", "EstadosInimigoPainel"],
		["VidaJogadorBar", "StatsJogadorPanel"],
		["StatsJogadorPanel", "MaoDock"],
		["VidaInimigoBar", "Mao"]
	]
	for par in pares:
		var primeiro: Control = jogo.get_node(par[0]) as Control
		var segundo: Control = jogo.get_node(par[1]) as Control
		_verificar(
			not primeiro.get_global_rect().intersects(segundo.get_global_rect()),
			"%s invade %s: %s / %s" % [par[0], par[1], primeiro.get_global_rect(), segundo.get_global_rect()]
		)

	var mao: Control = jogo.get_node("Mao") as Control
	for carta_no in mao.get_children():
		var carta: Control = carta_no as Control
		_verificar(not _retangulo_transformado(carta).intersects((jogo.get_node("StatsJogadorPanel") as Control).get_global_rect()), "carta invade os medidores de Barreira/Combo")
		_verificar(carta.size.x / carta.size.y < 0.72, "carta da mao esticada: %s" % carta.size)
		_verificar(jogo.get_global_rect().encloses(_retangulo_transformado(carta)), "carta cortada pela viewport: viewport=%s carta=%s escala=%s rotacao=%s" % [jogo.get_global_rect(), _retangulo_transformado(carta), carta.scale, carta.rotation])
		var titulo: Label = carta.get_node("NomeLabel") as Label
		var descricao: Label = carta.get_node("DescricaoLabel") as Label
		_verificar(titulo.get_theme_color("font_color").get_luminance() > 0.65, "titulo de carta ilegivel: %s" % titulo.text)
		_verificar(descricao.get_visible_line_count() == descricao.get_line_count(), "descricao de carta cortada: %s" % titulo.text)
	var carta_selecao: Button = mao.get_child(0) as Button
	carta_selecao.button_pressed = true
	carta_selecao.call("_atualizar_texto")
	_verificar(not (carta_selecao.get_node("SelecaoLabel") as Control).visible, "selecao de combate nao deve sair da raiz da carta")
	_verificar((carta_selecao.get_node("Foco") as Control).visible, "selecao de combate deve usar a camada interna")
	carta_selecao.button_pressed = false
	carta_selecao.call("_atualizar_texto")
	carta_selecao.call("_atualizar_transformacao", false)

	for nome_barra in ["VidaJogadorBar", "VidaInimigoBar"]:
		var barra: ProgressBar = jogo.get_node(nome_barra) as ProgressBar
		_verificar(barra.get_theme_stylebox("background") is StyleBoxFlat, "%s sem fundo proporcional" % nome_barra)

	jogo.call("_limpar_mao")
	for indice in 2:
		jogo.call("_criar_carta_na_mao", "golpe")
	await get_tree().process_frame
	for carta_no in mao.get_children():
		var carta: Control = carta_no as Control
		_verificar(carta.size.x / carta.size.y < 0.72, "carta esticada com mao curta: %s" % carta.size)

	get_window().size = Vector2i(1920, 1080)
	get_window().content_scale_size = Vector2i(1920, 1080)
	await get_tree().process_frame
	for carta_no in mao.get_children():
		var carta: Control = carta_no as Control
		_verificar(carta.size.y >= 240.0, "carta pequena demais em 1920x1080: %s" % carta.size)
		_verificar(carta.size.x / carta.size.y < 0.72, "carta esticada em 1920x1080: %s" % carta.size)
	_verificar((jogo.get_node("TopoCombate/TopoVida") as Label).get_theme_font_size("font_size") >= 26, "Vida do topo pequena em 1920x1080")
	_verificar((jogo.get_node("IntencaoNomeVisualLabel") as Label).get_theme_font_size("font_size") >= 14, "tipo da intenção pequeno em 1920x1080")
	var status: Label = jogo.get_node("RunStatusLabel") as Label
	var altura_linha_status: float = status.get_theme_font("font").get_height(status.get_theme_font_size("font_size"))
	_verificar(status.get_line_count() * altura_linha_status <= status.size.y + 2.0, "BARALHO precisa caber no painel em 1920x1080")
	for par in pares:
		var primeiro: Control = jogo.get_node(par[0]) as Control
		var segundo: Control = jogo.get_node(par[1]) as Control
		_verificar(not primeiro.get_global_rect().intersects(segundo.get_global_rect()), "%s invade %s em 1920x1080" % [par[0], par[1]])

	for resolucao in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		await get_tree().process_frame
		for id_carta in DadosCartas.CARTAS.keys():
			jogo.call("_limpar_mao")
			jogo.call("_criar_carta_na_mao", str(id_carta))
			await get_tree().process_frame
			var carta: Control = mao.get_child(0) as Control
			for nome in ["NomeLabel", "DescricaoLabel"]:
				var rotulo: Label = carta.get_node(nome) as Label
				var altura_linha: float = rotulo.get_theme_font("font").get_height(rotulo.get_theme_font_size("font_size"))
				_verificar(
					rotulo.get_line_count() * altura_linha <= rotulo.size.y + 2.0,
					"%s de %s não cabe em %s: %d linhas em %s" % [nome, id_carta, resolucao, rotulo.get_line_count(), rotulo.size]
				)

	get_window().size = Vector2i(1024, 576)
	get_window().content_scale_size = Vector2i(1024, 576)
	await get_tree().process_frame
	jogo.call("_limpar_mao")
	for _indice in 6:
		jogo.call("_criar_carta_na_mao", "golpe")
	jogo.call("_atualizar_interface")
	await _aguardar_animacoes_mao()
	for carta_no in mao.get_children():
		var carta_curta: Control = carta_no as Control
		_verificar(
			not carta_curta.get_global_rect().intersects((jogo.get_node("EncerrarTurno") as Control).get_global_rect()),
			"a mao curta nao pode cobrir Encerrar turno: carta=%s botao=%s" % [carta_curta.get_global_rect(), (jogo.get_node("EncerrarTurno") as Control).get_global_rect()]
		)
		_verificar(
			jogo.get_global_rect().encloses(carta_curta.get_global_rect()),
			"a mao curta precisa caber na viewport: carta=%s viewport=%s" % [carta_curta.get_global_rect(), jogo.get_global_rect()]
		)
		_verificar(
			jogo.get_global_rect().encloses(_retangulo_transformado(carta_curta)),
			"os cantos transformados da mao curta precisam caber na viewport: carta=%s" % _retangulo_transformado(carta_curta)
		)
	var estados_painel_1024: Control = jogo.get_node("EstadosInimigoPainel") as Control
	var estados_titulo_1024: Control = jogo.get_node("EstadosInimigoVisualLabel") as Control
	jogo.set("exposto_inimigo", 2)
	jogo.set("enfraquecido_inimigo", 1)
	jogo.call("_atualizar_interface")
	await get_tree().process_frame
	_verificar(estados_painel_1024.visible, "estados ativos precisam aparecer em 1024x576")
	_verificar(estados_painel_1024.size.y >= 18.0 and (jogo.get_node("Alvo") as Control).get_global_rect().encloses(estados_painel_1024.get_global_rect()), "estados devem caber dentro da placa inimiga: %s" % estados_painel_1024.size)
	_verificar(not estados_titulo_1024.visible, "titulo redundante ESTADOS nao deve comprimir os valores")
	for indice_foco_curto in [0, 3, 5]:
		var carta_foco_curta: Button = mao.get_child(indice_foco_curto) as Button
		carta_foco_curta.grab_focus()
		await get_tree().create_timer(0.2).timeout
		_verificar(carta_foco_curta.scale.x >= 1.07, "a carta %d precisa ampliar no foco: escala=%s" % [indice_foco_curto, carta_foco_curta.scale])
		_verificar(not carta_foco_curta.get_global_rect().intersects((jogo.get_node("EncerrarTurno") as Control).get_global_rect()), "o foco nao pode cobrir Encerrar turno: carta=%s botao=%s" % [carta_foco_curta.get_global_rect(), (jogo.get_node("EncerrarTurno") as Control).get_global_rect()])
		_verificar(not carta_foco_curta.get_global_rect().intersects((jogo.get_node("EnergiaPainel") as Control).get_global_rect()), "o foco nao pode cobrir Energia: carta=%s energia=%s" % [carta_foco_curta.get_global_rect(), (jogo.get_node("EnergiaPainel") as Control).get_global_rect()])
	jogo.call("_limpar_mao")
	var baralho_real: Array = jogo.get("baralho_run")
	var encontro: EncontroCombate = jogo.get("encontro_combate") as EncontroCombate
	var baralho_combate: BaralhoCombate = encontro.baralho
	baralho_combate.preparar(baralho_real)
	jogo.call("_comprar_cartas", 10)
	jogo.call("_atualizar_interface")
	await _aguardar_animacoes_mao()
	_verificar(
		jogo.get_global_rect().encloses((jogo.get_node("EncerrarTurno") as Control).get_global_rect()),
		"Encerrar turno precisa caber na menor resolucao"
	)
	_verificar(
		jogo.get_global_rect().encloses(mao.get_global_rect()),
		"a faixa da mao precisa permanecer dentro da viewport"
	)
	_verificar((jogo.get_node("MaoStatusLabel") as Label).text.contains("10/10"), "a interface precisa refletir a mao real cheia")
	for carta_no in mao.get_children():
		var carta_cheia: Control = carta_no as Control
		_verificar(carta_cheia.size.y >= 180.0, "as dez cartas nao podem ficar ilegiveis: %s" % carta_cheia.size)
		_verificar(jogo.get_global_rect().encloses(carta_cheia.get_global_rect()), "as dez cartas precisam caber na viewport: carta=%s" % carta_cheia.get_global_rect())
		_verificar(not carta_cheia.get_global_rect().intersects((jogo.get_node("EncerrarTurno") as Control).get_global_rect()), "a carta nao pode cobrir Encerrar turno: carta=%s botao=%s" % [carta_cheia.get_global_rect(), (jogo.get_node("EncerrarTurno") as Control).get_global_rect()])
		_verificar(jogo.get_global_rect().encloses(_retangulo_transformado(carta_cheia)), "os cantos transformados das dez cartas precisam caber na viewport: carta=%s" % _retangulo_transformado(carta_cheia))
	var cartas_foco: Array[int] = [0, 5, 9]
	for indice_foco in cartas_foco:
		var carta_foco: Button = mao.get_child(indice_foco) as Button
		carta_foco.grab_focus()
		await get_tree().create_timer(0.2).timeout
		_verificar(carta_foco.has_focus(), "a carta %d precisa aceitar foco de teclado" % indice_foco)
		_verificar(carta_foco.z_index > 0, "a carta %d precisa vir para frente no foco" % indice_foco)
		_verificar(carta_foco.scale.x >= 1.07, "a carta cheia %d precisa ampliar no foco: escala=%s" % [indice_foco, carta_foco.scale])
		_verificar(not carta_foco.get_global_rect().intersects((jogo.get_node("EncerrarTurno") as Control).get_global_rect()), "o foco da mao cheia nao pode cobrir Encerrar turno: carta=%s botao=%s" % [carta_foco.get_global_rect(), (jogo.get_node("EncerrarTurno") as Control).get_global_rect()])
		_verificar(not carta_foco.get_global_rect().intersects((jogo.get_node("EnergiaPainel") as Control).get_global_rect()), "o foco da mao cheia nao pode cobrir Energia: carta=%s energia=%s" % [carta_foco.get_global_rect(), (jogo.get_node("EnergiaPainel") as Control).get_global_rect()])
		_verificar(_z_efetivo(carta_foco) > _maior_z_irmaos(mao, carta_foco), "a carta focada precisa desenhar acima dos vizinhos")
		_verificar(jogo.get_global_rect().encloses(_retangulo_transformado(carta_foco)), "o foco da mao cheia precisa caber na viewport: carta=%s" % _retangulo_transformado(carta_foco))
		if indice_foco == 0:
			carta_foco.release_focus()
			carta_foco.call("_atualizar_transformacao")
			await get_tree().process_frame
			carta_foco.call("_atualizar_transformacao", false)
			var escala_imediata: Vector2 = carta_foco.scale
			await get_tree().create_timer(0.2).timeout
			_verificar(carta_foco.scale.is_equal_approx(escala_imediata), "transformacao imediata nao pode ser sobrescrita por tween antigo")

	jogo.queue_free()
	if falhas == 0:
		print("OK: layout de combate sem sobreposicao")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)


func _retangulo_transformado(controle: Control) -> Rect2:
	var transformacao: Transform2D = controle.get_global_transform_with_canvas()
	var pontos: Array[Vector2] = [
		transformacao * Vector2.ZERO,
		transformacao * Vector2(controle.size.x, 0.0),
		transformacao * controle.size,
		transformacao * Vector2(0.0, controle.size.y)
	]
	var limite: Rect2 = Rect2(pontos[0], Vector2.ZERO)
	for ponto in pontos:
		limite = limite.expand(ponto)
	return limite


func _z_efetivo(controle: CanvasItem) -> int:
	var total: int = 0
	var atual: Node = controle
	while atual != null:
		var item: CanvasItem = atual as CanvasItem
		if item != null:
			total += item.z_index
		atual = atual.get_parent()
	return total


func _maior_z_irmaos(mao: Control, carta_alvo: Control) -> int:
	var maior: int = -100000
	for no in mao.get_children():
		var carta: Control = no as Control
		if carta != null and carta != carta_alvo:
			maior = maxi(maior, _z_efetivo(carta))
	return maior


func _aguardar_animacoes_mao() -> void:
	await get_tree().create_timer(0.65).timeout
	for _indice in 2:
		await get_tree().process_frame
