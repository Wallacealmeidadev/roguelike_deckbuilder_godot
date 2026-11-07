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
	jogo.call("_iniciar_combate_por_id", "drone_seguranca", false)
	await get_tree().process_frame

	_verificar(jogo.has_node("ArenaChao"), "a arena precisa de um piso visual próprio")
	_verificar(jogo.has_node("MaoDock"), "a mão precisa de uma área visual própria")
	_verificar(jogo.has_node("EnergiaPainel"), "a Energia precisa de um painel visual próprio")
	_verificar(jogo.has_node("RelíquiaPainel"), "as relíquias precisam de uma área visual própria")
	_verificar(jogo.has_method("_animar_faixa_turno"), "o turno precisa de uma entrada animada")
	_verificar(jogo.has_method("_animar_flash_dano"), "o dano precisa de feedback visual")
	_verificar(
		not str((jogo.get_node("TurnoTituloLabel") as Label).get_theme_font("font").resource_path).ends_with("Bangers-Regular.ttf"),
		"o titulo do turno precisa usar tipografia condensada"
	)
	_verificar(
		not str((jogo.get_node("IntencaoVisualLabel") as Label).get_theme_font("font").resource_path).ends_with("Bangers-Regular.ttf"),
		"a intencao cotidiana deve usar tipografia condensada"
	)
	_verificar(
		not (jogo.get_node("EnergiaVisualLabel") as Label).text.contains("Energia:"),
		"Energia visual nao deve depender de rotulo solto"
	)
	_verificar(
		jogo.get_node("EnergiaPainel").get_theme_stylebox("panel") is StyleBoxEmpty,
		"Energia nao deve duplicar a placa neon"
	)
	_verificar(
		_eh_estilo_r2_plano(jogo.get_node("VidaJogadorBar") as Control, "fill"),
		"Vida precisa usar preenchimento plano R2"
	)
	_verificar(
		not (jogo.get_node("VidaJogadorMoldura") as Control).visible,
		"Vida nao deve desenhar moldura legada"
	)
	for nome_painel in [
		"IntencaoPainel",
		"StatsJogadorPanel",
		"RelíquiaPainel",
		"EstadosInimigoPainel",
		"CompraPainel",
		"DescartePainel"
	]:
		if nome_painel in ["StatsJogadorPanel", "IntencaoPainel", "EstadosInimigoPainel"]:
			_verificar(jogo.get_node(nome_painel).get_theme_stylebox("panel") is StyleBoxEmpty, "recursos nao devem duplicar a placa neon")
		elif nome_painel.begins_with("Rel"):
			_verificar(_eh_estilo_r2_plano(jogo.get_node(nome_painel) as Control), "a area de reliquias continua transparente")
		else:
			_verificar(jogo.get_node(nome_painel).get_theme_stylebox("panel") is StyleBoxTexture or jogo.get_node(nome_painel).get_theme_stylebox("panel") is StyleBoxFlat, "%s precisa usar moldura visual" % nome_painel)
	_verificar(
		not (jogo.get_node("VidaJogadorLabel") as Label).text.contains("Vida:"),
		"Vida deve usar valor integrado, sem rotulo solto"
	)
	_verificar(not (jogo.get_node("VidaJogadorIcone") as TextureRect).visible, "Vida nao deve manter icone persistente")
	_verificar((jogo.get_node("IntencaoPainel") as Control).get_global_rect().encloses((jogo.get_node("IntencaoNomeVisualLabel") as Control).get_global_rect()), "o tipo de ação precisa ficar no selo da intenção")
	_verificar(jogo.has_node("Alvo/ModuloInimigo"), "a intenção e a Vida devem estar na moldura ilustrada do alvo")
	_verificar(
		(jogo.get_node("Jogador/VegaAnimada") as Control).visible
			and not jogo.has_node("Jogador/VegaCampoRetrato")
			and not jogo.has_node("Jogador/VegaCampoNome"),
		"Vega de playtest precisa ser a unica arte de personagem no campo"
	)
	_verificar((jogo.get_node("Alvo") as Control).size.x >= 190.0, "o painel do inimigo está pequeno")

	_verificar(jogo.get_node("Jogador/Interacao") is Panel, "o jogador precisa de destaque transparente separado")
	_verificar(jogo.get_node("Alvo/Interacao") is Panel, "o alvo precisa de destaque transparente separado")
	_verificar(jogo.get_node("EncerrarTurno/Interacao") is Panel, "o fim de turno precisa de destaque transparente separado")
	_verificar(
		(jogo.get_node("Alvo") as Button).get_theme_stylebox("normal") != (jogo.get_node("Alvo") as Button).get_theme_stylebox("focus"),
		"o alvo precisa destacar foco com estilo separado"
	)
	_verificar(
		(jogo.get_node("Jogador") as Button).get_theme_stylebox("normal") == (jogo.get_node("Jogador") as Button).get_theme_stylebox("focus"),
		"o jogador nao deve usar a moldura inteira do botao ao receber foco"
	)
	_verificar(
		(jogo.get_node("Jogador") as Button).get_theme_stylebox("focus") is StyleBoxEmpty,
		"o foco do jogador deve permanecer transparente"
	)
	_verificar(
		(jogo.get_node("Jogador/Interacao") as Panel).get_theme_stylebox("panel") is StyleBoxFlat
			and is_zero_approx(((jogo.get_node("Jogador/Interacao") as Panel).get_theme_stylebox("panel") as StyleBoxFlat).bg_color.a),
		"o destaque da Vega deve ser uma borda transparente separada"
	)
	jogo.call("_mostrar_inspecao_hud", jogo.get_node("Jogador"))
	await get_tree().process_frame
	_verificar(not (jogo.get_node("HudInspecao") as Control).visible, "passar na Vega nao deve abrir tooltip sobre a arena")
	_verificar(jogo.has_node("EstadosInimigoBarreiraIcone"), "a barreira do inimigo precisa de icone proprio")
	_verificar(jogo.has_node("EstadosInimigoExpostoIcone"), "Exposto precisa de icone proprio")
	_verificar(jogo.has_node("EstadosInimigoEnfraquecidoIcone"), "Enfraquecido precisa de icone proprio")
	_verificar(jogo.get_node("IntencaoNomeVisualLabel") is Label, "a intenção precisa separar o nome do valor")
	_verificar(jogo.get_node("IntencaoValorVisualLabel") is Label, "a intenção precisa separar a multiplicidade")
	var painel_intencao: Control = jogo.get_node("IntencaoPainel") as Control
	var nome_intencao: Label = jogo.get_node("IntencaoNomeVisualLabel") as Label
	var valor_intencao: Label = jogo.get_node("IntencaoValorVisualLabel") as Label
	_verificar(painel_intencao.size.y >= 50.0, "a intenção compacta precisa de altura útil")
	_verificar(not nome_intencao.clip_text, "o nome da intenção não pode ser cortado")
	_verificar(nome_intencao.autowrap_mode == TextServer.AUTOWRAP_OFF, "o tipo compacto da intenção não deve quebrar linha")
	_verificar(not valor_intencao.clip_text, "o valor da intenção não pode ser cortado")
	_verificar(not (jogo.get_node("IntencaoVisualLabel") as Label).visible, "o rótulo legado da intenção não pode duplicar a apresentação")
	_verificar(
		nome_intencao.text == "ATACA" and str(jogo.call("_texto_inspecao_hud", painel_intencao)).to_upper().contains("RAJADA"),
		"o selo resume o tipo sem perder o nome completo na inspeção"
	)
	_verificar(
		str((jogo.get_node("IntencaoValorVisualLabel") as Label).text).contains("3"),
		"o valor visual da intenção deve preservar a multiplicidade real"
	)
	_verificar(
		(jogo.get_node("Alvo") as Control).get_global_rect().encloses((jogo.get_node("IntencaoPainel") as Control).get_global_rect()),
		"a intencao precisa permanecer presa ao alvo"
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
		not (jogo.get_node("RelíquiaPainel") as Control).visible or not (jogo.get_node("StatsJogadorPanel") as Control).get_global_rect().intersects((jogo.get_node("RelíquiaPainel") as Control).get_global_rect()),
		"reliquias visiveis nao podem invadir Barreira e Combo"
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
		_verificar((carta_no as Control).size.x >= 120.0, "a carta continua pequena demais")
		_verificar((carta_no as Control).has_method("animar_entrada"), "a carta precisa ter entrada animada")
	_verificar(absf((mao.get_child(0) as Control).rotation) > 0.001, "a mão precisa de uma curva visual")

	var carta: Button = mao.get_child(0) as Button
	carta.button_pressed = true
	await get_tree().create_timer(0.2).timeout
	_verificar(carta.scale.x > 1.0, "a carta selecionada precisa subir visualmente")
	_verificar(carta.z_index > 0, "a carta selecionada precisa passar à frente")
	var imagem_foco: Image = ((carta.get_node("Foco") as TextureRect).texture as Texture2D).get_image()
	_verificar(imagem_foco.get_pixel(imagem_foco.get_width() / 2, imagem_foco.get_height() / 2).a < 0.1, "o foco da carta precisa ser um contorno transparente")
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


func _eh_estilo_r2_plano(controle: Control, nome_estilo: String = "panel") -> bool:
	var estilo: StyleBox = controle.get_theme_stylebox(nome_estilo)
	if not estilo is StyleBoxFlat:
		return false
	var estilo_plano: StyleBoxFlat = estilo as StyleBoxFlat
	return estilo_plano.border_width_left == 0 or is_zero_approx(estilo_plano.bg_color.a)
