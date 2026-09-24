extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)

	await get_tree().process_frame

	_verificar(jogo.has_node("IntencaoLabel"), "a cena precisa separar a intenção do inimigo")
	_verificar(jogo.has_node("EstadosInimigoLabel"), "a cena precisa separar os estados do inimigo")
	_verificar(jogo.has_node("AcaoLabel"), "a cena precisa mostrar a última ação")
	_verificar(jogo.has_node("MaoStatusLabel"), "a cena precisa mostrar o limite da mão")
	_verificar(
		(jogo.get_node("PilhasLabel") as Label).size.x >= 330.0,
		"o bloco de pilhas precisa ter largura para suas duas linhas"
	)
	_verificar(
		(jogo.get_node("PilhasLabel") as Label).size.y >= 55.0,
		"o bloco de pilhas precisa reservar altura para suas duas linhas"
	)
	_verificar(
		(jogo.get_node("Jogador") as Button).position.y >= 80.0,
		"o botão do jogador deve ficar abaixo do bloco de pilhas"
	)
	_verificar(
		(jogo.get_node("Jogador") as Button).position.x + (jogo.get_node("Jogador") as Button).size.x
			<= (jogo.get_node("EnergiaLabel") as Label).position.x,
		"o botão do jogador não deve invadir os indicadores de recurso"
	)

	if falhas == 0:
		var energia_label: Label = jogo.get_node("EnergiaLabel") as Label
		var intencao_label: Label = jogo.get_node("IntencaoLabel") as Label
		var estados_label: Label = jogo.get_node("EstadosInimigoLabel") as Label
		var acao_label: Label = jogo.get_node("AcaoLabel") as Label
		var mao_status_label: Label = jogo.get_node("MaoStatusLabel") as Label
		var alvo: Button = jogo.get_node("Alvo") as Button
		var inimigo_atual: InimigoCombate = jogo.get("estado_inimigo") as InimigoCombate

		_verificar(energia_label.text.contains("Energia: 4/4"), "a Energia deve mostrar o limite do turno")
		_verificar(
			alvo.text.contains(inimigo_atual.nome.to_upper()),
			"o alvo deve mostrar o nome do inimigo atual"
		)
		_verificar(
			intencao_label.text.contains(inimigo_atual.texto_intencao()),
			"a intenção atual deve ficar em uma área própria"
		)

		var estivador: InimigoCombate = InimigoCombate.new(
			"estivador_cibernetico",
			DadosInimigos.obter("estivador_cibernetico")
		)
		(jogo.get("encontro_combate") as EncontroCombate).inimigo = estivador
		jogo.call("_atualizar_interface")
		_verificar(alvo.text.contains("ESTIVADOR CIBERNÉTICO"), "o alvo deve mostrar o Estivador")
		_verificar(alvo.text.contains("Vida: 36"), "o alvo deve mostrar a Vida do Estivador")
		_verificar(intencao_label.text.contains("Pancada: 8"), "a intenção deve mostrar Pancada: 8")

		jogo.set("exposto_inimigo", 2)
		jogo.call("_atualizar_interface")
		_verificar(estados_label.text.contains("Exposto: 2"), "o estado Exposto deve ficar visível separado")

		jogo.call("_criar_carta_na_mao", "golpe")
		var mao: HBoxContainer = jogo.get_node("Mao") as HBoxContainer
		var carta: Button = mao.get_child(mao.get_child_count() - 1) as Button
		carta.button_pressed = true
		jogo.call("_jogar_carta", "inimigo")
		_verificar(acao_label.text.contains("GOLPE"), "a última ação deve registrar a carta jogada")

		jogo.set("energia", 0)
		jogo.call("_atualizar_interface")
		_verificar(energia_label.text.contains("SEM ENERGIA"), "a interface deve avisar quando a Energia acabar")

		while mao.get_child_count() < 10:
			jogo.call("_criar_carta_na_mao", "protecao")
		jogo.call("_atualizar_interface")
		_verificar(mao.get_child_count() == 10, "o teste deve alcançar o limite da mão")
		_verificar(mao_status_label.text.contains("MÃO CHEIA"), "a interface deve avisar quando a mão estiver cheia")

	jogo.queue_free()

	if falhas == 0:
		print("OK: apresentação do combate")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
