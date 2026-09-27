extends Node

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

	_verificar(jogo.has_node("ArenaChao"), "a arena precisa de um piso visual próprio")
	_verificar(jogo.has_node("MaoDock"), "a mão precisa de uma área visual própria")
	_verificar(jogo.has_node("EnergiaPainel"), "a Energia precisa de um painel visual próprio")
	_verificar(jogo.has_node("RelíquiaPainel"), "as relíquias precisam de uma área visual própria")
	_verificar(jogo.has_method("_animar_faixa_turno"), "o turno precisa de uma entrada animada")
	_verificar(jogo.has_method("_animar_flash_dano"), "o dano precisa de feedback visual")
	_verificar(
		str((jogo.get_node("TurnoTituloLabel") as Label).get_theme_font("font").resource_path).ends_with("Bangers-Regular.ttf"),
		"o titulo do turno precisa usar Bangers"
	)
	_verificar(
		str((jogo.get_node("IntencaoVisualLabel") as Label).get_theme_font("font").resource_path).ends_with("Bangers-Regular.ttf"),
		"a intencao precisa usar Bangers"
	)
	_verificar(
		not (jogo.get_node("EnergiaVisualLabel") as Label).text.contains("Energia:"),
		"Energia visual nao deve depender de rotulo solto"
	)
	_verificar(
		(jogo.get_node("EnergiaPainel") as Panel).get_theme_stylebox("panel") is StyleBoxFlat,
		"Energia precisa de modulo estilizado"
	)
	_verificar(
		(jogo.get_node("VidaJogadorBar") as ProgressBar).get_theme_stylebox("fill").border_width_left >= 2,
		"Vida precisa de preenchimento cyberpunk"
	)
	_verificar(
		(jogo.get_node("VidaJogadorMoldura") as Panel).get_theme_stylebox("panel").border_width_left >= 2,
		"Vida precisa de moldura cyberpunk"
	)
	_verificar(
		not (jogo.get_node("VidaJogadorLabel") as Label).text.contains("Vida:"),
		"Vida deve usar valor integrado, sem rotulo solto"
	)
	_verificar((jogo.get_node("VidaJogadorIcone") as TextureRect).texture != null, "Vida precisa de icone proprio")
	_verificar((jogo.get_node("IntencaoPainel") as Control).size.x >= 280.0, "a intenção precisa de uma área dominante")
	_verificar((jogo.get_node("Jogador") as Control).size.x >= 190.0, "o placeholder da Vega está pequeno")
	_verificar((jogo.get_node("Alvo") as Control).size.x >= 190.0, "o placeholder do inimigo está pequeno")

	_verificar(jogo.get_node("Jogador/Interacao") is Panel, "o jogador precisa de destaque transparente separado")
	_verificar(jogo.get_node("Alvo/Interacao") is Panel, "o alvo precisa de destaque transparente separado")
	_verificar(jogo.get_node("EncerrarTurno/Interacao") is Panel, "o fim de turno precisa de destaque transparente separado")
	_verificar(
		(jogo.get_node("Alvo") as Button).get_theme_stylebox("normal") == (jogo.get_node("Alvo") as Button).get_theme_stylebox("focus"),
		"o alvo precisa preservar a moldura base entre estados"
	)
	_verificar(
		(jogo.get_node("Jogador") as Button).get_theme_stylebox("normal") == (jogo.get_node("Jogador") as Button).get_theme_stylebox("focus"),
		"o jogador precisa preservar a moldura base entre estados"
	)
	_verificar(jogo.has_node("EstadosInimigoBarreiraIcone"), "a barreira do inimigo precisa de icone proprio")
	_verificar(jogo.has_node("EstadosInimigoExpostoIcone"), "Exposto precisa de icone proprio")
	_verificar(jogo.has_node("EstadosInimigoEnfraquecidoIcone"), "Enfraquecido precisa de icone proprio")
	_verificar(jogo.get_node("IntencaoNomeVisualLabel") is Label, "a intenção precisa separar o nome do valor")
	_verificar(jogo.get_node("IntencaoValorVisualLabel") is Label, "a intenção precisa separar a multiplicidade")
	_verificar(not (jogo.get_node("IntencaoVisualLabel") as Label).visible, "o rótulo legado da intenção não pode duplicar a apresentação")
	_verificar(
		str((jogo.get_node("IntencaoNomeVisualLabel") as Label).text).to_upper().contains("RAJADA"),
		"o nome visual da intenção deve vir do inimigo ativo"
	)
	_verificar(
		str((jogo.get_node("IntencaoValorVisualLabel") as Label).text).contains("3"),
		"o valor visual da intenção deve preservar a multiplicidade real"
	)
	_verificar(
		not (jogo.get_node("IntencaoPainel") as Control).get_global_rect().intersects((jogo.get_node("Alvo") as Control).get_global_rect()),
		"a intencao precisa permanecer acima do alvo"
	)
	_verificar(
		not (jogo.get_node("EnergiaPainel") as Control).get_global_rect().intersects((jogo.get_node("Mao") as Control).get_global_rect()),
		"Energia nao pode invadir a mao"
	)
	_verificar(
		not (jogo.get_node("EncerrarTurno") as Control).get_global_rect().intersects((jogo.get_node("Mao") as Control).get_global_rect()),
		"o fim de turno nao pode invadir a mao"
	)
	_verificar(
		not (jogo.get_node("StatsJogadorPanel") as Control).get_global_rect().intersects((jogo.get_node("RelíquiaPainel") as Control).get_global_rect()),
		"a area de reliquias nao pode invadir Barreira e Combo"
	)
	_verificar(not (jogo.get_node("EstadosInimigoPainel") as Control).visible, "um inimigo sem estados nao deve mostrar um painel vazio")
	jogo.set("energia", 0)
	jogo.call("_atualizar_interface")
	_verificar((jogo.get_node("EnergiaVisualLabel") as Label).text.contains("0/4"), "Energia zerada ainda precisa mostrar atual/mÃ¡xima")
	jogo.set("energia", 4)
	jogo.call("_atualizar_interface")
	var inimigo: InimigoCombate = jogo.get("encontro_combate").inimigo as InimigoCombate
	inimigo.barreira = 4
	jogo.set("exposto_inimigo", 2)
	jogo.call("_atualizar_interface")
	_verificar((jogo.get_node("EstadosInimigoPainel") as Control).visible, "estados ativos precisam de painel")
	_verificar(
		not (jogo.get_node("EstadosInimigoPainel") as Control).get_global_rect().intersects((jogo.get_node("VidaInimigoBar") as Control).get_global_rect()),
		"estados do inimigo nao podem invadir a barra de Vida"
	)

	var mao: Control = jogo.get_node("Mao") as Control
	for carta_no in mao.get_children():
		_verificar((carta_no as Control).size.x >= 145.0, "a carta continua pequena demais")
		_verificar((carta_no as Control).has_method("animar_entrada"), "a carta precisa ter entrada animada")
	_verificar(absf((mao.get_child(0) as Control).rotation) > 0.001, "a mão precisa de uma curva visual")

	var carta: Button = mao.get_child(0) as Button
	carta.button_pressed = true
	await get_tree().create_timer(0.2).timeout
	_verificar(carta.scale.x > 1.0, "a carta selecionada precisa subir visualmente")
	_verificar(carta.z_index > 0, "a carta selecionada precisa passar à frente")
	_verificar(
		(carta.get_node("Foco") as Control).z_index < (carta.get_node("NomeLabel") as Control).z_index,
		"o foco da carta nao pode cobrir o nome"
	)
	_verificar(
		(carta.get_node("DescricaoLabel") as Label).visible and not (carta.get_node("DescricaoLabel") as Label).text.is_empty(),
		"a selecao nao pode esconder a descricao da carta"
	)
	_verificar(
		(carta.get_node("CustoLabel") as Label).visible and not (carta.get_node("CustoLabel") as Label).text.is_empty(),
		"a selecao nao pode esconder o custo da carta"
	)

	jogo.queue_free()
	if falhas == 0:
		print("OK: composição visual do combate")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
