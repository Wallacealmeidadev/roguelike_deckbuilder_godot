extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)

	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	await get_tree().process_frame

	_verificar(jogo.has_node("IntencaoLabel"), "a cena precisa separar a intencao do inimigo")
	_verificar(jogo.has_node("EstadosInimigoLabel"), "a cena precisa separar os estados do inimigo")
	_verificar(jogo.has_node("AcaoLabel"), "a cena precisa mostrar a ultima acao")
	_verificar(jogo.has_node("MaoStatusLabel"), "a cena precisa mostrar o limite da mao")
	_verificar(jogo.has_node("TurnoTituloLabel"), "o turno precisa separar titulo e numero")
	_verificar(jogo.has_node("TurnoNumeroLabel"), "o turno precisa reservar uma linha para o numero")
	_verificar(jogo.has_node("IntencaoVisualLabel"), "a intencao precisa ter texto visual separado")
	_verificar(jogo.has_node("EstadosInimigoVisualLabel"), "os estados precisam ter texto visual separado")
	_verificar(jogo.has_node("AlvoVisualLabel"), "o alvo precisa ter texto visual separado")
	_verificar(jogo.has_node("RunStatusLabel"), "o resumo da run precisa ter uma area visual propria")
	_verificar(
		(jogo.get_node("PilhasLabel") as Label).size.x >= 330.0,
		"o bloco legado de pilhas precisa conservar largura"
	)
	_verificar(
		(jogo.get_node("PilhasLabel") as Label).size.y >= 55.0,
		"o bloco legado de pilhas precisa conservar altura"
	)
	_verificar(jogo.theme != null, "a interface de combate precisa usar o tema do kit")
	_verificar(jogo.has_node("FundoUI"), "a interface precisa usar o fundo compartilhado do kit")
	_verificar(jogo.has_node("VidaJogadorBar"), "a interface precisa mostrar a barra de Vida da Vega")
	_verificar(jogo.has_node("VidaInimigoBar"), "a interface precisa mostrar a barra de Vida do inimigo")
	_verificar(jogo.has_node("CompraLabel"), "a interface precisa separar o contador de compra")
	_verificar(jogo.has_node("DescarteLabel"), "a interface precisa separar o contador de descarte")
	_verificar(jogo.has_node("TurnoLabel"), "a interface precisa manter o texto de turno legado")
	_verificar(jogo.has_node("IntencaoPainel"), "a intencao precisa ter um painel proprio")
	_verificar(jogo.has_node("EstadosInimigoPainel"), "os estados precisam ter um painel proprio")
	_verificar(
		(jogo.get_node("Jogador") as Button).position.y >= 80.0,
		"o botao do jogador deve ficar abaixo do bloco de pilhas"
	)

	if falhas == 0:
		var energia_label: Label = jogo.get_node("EnergiaLabel") as Label
		var intencao_label: Label = jogo.get_node("IntencaoLabel") as Label
		var estados_label: Label = jogo.get_node("EstadosInimigoLabel") as Label
		var acao_label: Label = jogo.get_node("AcaoLabel") as Label
		var mao_status_label: Label = jogo.get_node("MaoStatusLabel") as Label
		var alvo: Button = jogo.get_node("Alvo") as Button
		var inimigo_atual: InimigoCombate = jogo.get("estado_inimigo") as InimigoCombate
		var viewport_size: Vector2 = jogo.get_viewport_rect().size
		var mao: Control = jogo.get_node("Mao") as Control
		var encerrar_turno: Button = jogo.get_node("EncerrarTurno") as Button
		_verificar(mao.position.x >= 0.0, "a mao nao pode sair pela esquerda da janela")
		_verificar(
			mao.position.x + mao.size.x <= viewport_size.x + 1.0,
			"a mao nao pode sair pela direita da janela"
		)
		_verificar(
			mao.position.y + mao.size.y <= viewport_size.y + 1.0,
			"a mao nao pode sair pela parte inferior da janela"
		)
		_verificar(
			encerrar_turno.position.x + encerrar_turno.size.x <= viewport_size.x + 1.0,
			"o botao de encerrar turno nao pode sair pela direita da janela"
		)
		_verificar(
			encerrar_turno.position.y + encerrar_turno.size.y <= viewport_size.y + 1.0,
			"o botao de encerrar turno nao pode sair pela parte inferior da janela"
		)

		_verificar(energia_label.text.contains("Energia: 4/4"), "a Energia deve mostrar o limite do turno")
		_verificar(
			alvo.text.contains(inimigo_atual.nome.to_upper()),
			"o alvo legado deve manter o nome do inimigo atual"
		)
		_verificar(
			intencao_label.text.contains(inimigo_atual.texto_intencao()),
			"a intencao legada deve manter o valor atual"
		)
		_verificar(
			(jogo.get_node("TurnoTituloLabel") as Label).text == "SEU TURNO",
			"o titulo do turno deve ocupar uma linha propria"
		)
		_verificar(
			(jogo.get_node("TurnoNumeroLabel") as Label).text.contains("TURNO 1"),
			"o numero do turno deve ocupar uma linha propria"
		)

		var estivador: InimigoCombate = InimigoCombate.new(
			"estivador_cibernetico",
			DadosInimigos.obter("estivador_cibernetico")
		)
		(jogo.get("encontro_combate") as EncontroCombate).inimigo = estivador
		jogo.call("_atualizar_interface")
		_verificar(alvo.text.contains("ESTIVADOR"), "o alvo deve manter o Estivador")
		_verificar(alvo.text.contains("Vida: 36"), "o alvo deve manter a Vida do Estivador")
		_verificar(intencao_label.text.contains("Pancada: 8"), "a intencao deve mostrar Pancada: 8")

		jogo.set("exposto_inimigo", 2)
		jogo.call("_atualizar_interface")
		_verificar(estados_label.text.contains("Exposto: 2"), "o estado Exposto deve continuar visivel")

		jogo.call("_criar_carta_na_mao", "golpe")
		var carta: Button = mao.get_child(mao.get_child_count() - 1) as Button
		_verificar(carta.has_node("Moldura"), "a carta precisa usar a moldura compartilhada")
		_verificar(carta.has_node("Arte"), "a carta precisa ter uma camada de ilustracao")
		_verificar(carta.has_node("NomeLabel"), "a carta precisa ter nome em camada propria")
		_verificar(carta.has_node("DescricaoLabel"), "a carta precisa ter descricao em camada propria")
		_verificar(carta.has_node("Foco"), "a carta precisa ter uma camada de foco selecionavel")
		_verificar(carta.tooltip_text.is_empty(), "a carta nao deve abrir tooltip sobre a mao")
		carta.button_pressed = true
		jogo.call("_jogar_carta", "inimigo")
		_verificar(acao_label.text.contains("GOLPE"), "a ultima acao deve registrar a carta jogada")

		jogo.set("energia", 0)
		jogo.call("_atualizar_interface")
		_verificar(energia_label.text.contains("SEM ENERGIA"), "a interface deve avisar quando a Energia acabar")

		while mao.get_child_count() < 10:
			jogo.call("_criar_carta_na_mao", "protecao")
		jogo.call("_atualizar_interface")
		_verificar(mao.get_child_count() == 10, "o teste deve alcancar o limite da mao")
		_verificar(mao_status_label.text.contains("CHEIA"), "a interface deve avisar quando a mao estiver cheia")

		jogo.call("_mostrar_recompensas")
		_verificar(not (jogo.get_node("RunStatusLabel") as Control).visible, "o resumo deve sumir na recompensa")
		_verificar(not (jogo.get_node("EnergiaVisualLabel") as Control).visible, "a Energia deve sumir na recompensa")
		_verificar(not (jogo.get_node("CompraLabel") as Control).visible, "a compra deve sumir na recompensa")
		_verificar(not (jogo.get_node("DescarteLabel") as Control).visible, "o descarte deve sumir na recompensa")
		_verificar(not (jogo.get_node("EncerrarTurno") as Control).visible, "o botao de turno deve sumir na recompensa")
		_verificar(not (jogo.get_node("PilhasPainel") as Control).visible, "a caixa vazia do resumo deve sumir na recompensa")
		_verificar(not (jogo.get_node("StatsJogadorPanel") as Control).visible, "a caixa vazia de estados deve sumir na recompensa")
		_verificar(not (jogo.get_node("VidaJogadorMoldura") as Control).visible, "a moldura de Vida deve sumir na recompensa")

	jogo.queue_free()

	if falhas == 0:
		print("OK: apresentacao do combate")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
