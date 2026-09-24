extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var catalogo: Script = load("res://dados_cartas.gd") as Script
	var cartas: Dictionary = catalogo.get_script_constant_map()["CARTAS"]
	var resolucao: ResolucaoCartas = ResolucaoCartas.new()

	var jogador: Combatente = Combatente.new(40)
	var inimigo: Combatente = Combatente.new(30)
	var resultado: Dictionary = resolucao.resolver(
		"golpe",
		cartas,
		jogador,
		inimigo,
		"inimigo",
		{"energia": 4, "combo": 0, "combo_maximo": 5}
	)
	_verificar(resultado["valida"], "Golpe deve ser válido contra o inimigo")
	_verificar(resultado["custo"] == 1, "Golpe deve retornar seu custo")
	_verificar(resultado["dano"] == 6, "Golpe deve retornar 6 de dano")
	_verificar(inimigo.vida == 24, "Golpe deve reduzir a Vida do inimigo")
	_verificar(resultado["combo"] == 1, "Golpe deve retornar o Combo seguinte")

	jogador = Combatente.new(40)
	inimigo = Combatente.new(30)
	resultado = resolucao.resolver(
		"direto_hidraulico",
		cartas,
		jogador,
		inimigo,
		"inimigo",
		{"energia": 4, "combo": 0, "combo_maximo": 5}
	)
	_verificar(resultado["dano"] == 4, "Direto Hidráulico deve causar 4")
	_verificar(resultado["barreira"] == 2, "Direto Hidráulico deve conceder 2 de Barreira")
	_verificar(jogador.barreira == 2, "a Barreira de Direto deve ser aplicada à fonte")

	jogador = Combatente.new(40)
	inimigo = Combatente.new(30)
	resultado = resolucao.resolver(
		"brecha",
		cartas,
		jogador,
		inimigo,
		"inimigo",
		{"energia": 4, "combo": 0, "combo_maximo": 5}
	)
	_verificar(inimigo.vida == 26, "Brecha deve causar 4 de dano")
	_verificar(inimigo.exposto == 2, "Brecha deve aplicar Exposto 2")
	_verificar(resultado["estados_aplicados"]["exposto"] == 2, "o resultado deve listar Exposto aplicado")

	jogador = Combatente.new(40)
	inimigo = Combatente.new(30)
	resultado = resolucao.resolver(
		"pulso_debilitante",
		cartas,
		jogador,
		inimigo,
		"inimigo",
		{"energia": 4, "combo": 2, "combo_maximo": 5}
	)
	_verificar(resultado["dano"] == 0, "Pulso não deve causar dano")
	_verificar(inimigo.enfraquecido == 2, "Pulso deve aplicar Enfraquecido 2")
	_verificar(jogador.barreira == 3, "Pulso deve conceder 3 de Barreira")
	_verificar(resultado["combo"] == 2, "Pulso deve manter o Combo")

	jogador = Combatente.new(40)
	inimigo = Combatente.new(30)
	resultado = resolucao.resolver(
		"quebra_chassi",
		cartas,
		jogador,
		inimigo,
		"inimigo",
		{"energia": 4, "combo": 3, "combo_maximo": 5}
	)
	_verificar(resultado["dano"] == 14, "Quebra-chassi deve calcular 5 + 3 por Combo")
	_verificar(inimigo.vida == 16, "Quebra-chassi deve causar o dano calculado")
	_verificar(resultado["combo"] == 0, "Quebra-chassi deve retornar Combo zerado")

	jogador = Combatente.new(40)
	inimigo = Combatente.new(30)
	resultado = resolucao.resolver(
		"ruptura_pressao",
		cartas,
		jogador,
		inimigo,
		"inimigo",
		{"energia": 4, "combo": 0, "combo_maximo": 5}
	)
	_verificar(resultado["valida"], "Ruptura de Pressão deve ser válida")
	_verificar(inimigo.vida == 26, "Ruptura deve causar 4 de dano")
	_verificar(inimigo.exposto == 2, "Ruptura deve aplicar Exposto 2")

	jogador = Combatente.new(40)
	inimigo = Combatente.new(30)
	resultado = resolucao.resolver(
		"placa_reforcada",
		cartas,
		jogador,
		inimigo,
		"jogador",
		{"energia": 4, "combo": 0, "combo_maximo": 5}
	)
	_verificar(resultado["valida"], "Placa Reforçada deve ser válida")
	_verificar(jogador.barreira == 8, "Placa Reforçada deve conceder 8 de Barreira")

	jogador = Combatente.new(40)
	inimigo = Combatente.new(30)
	resultado = resolucao.resolver(
		"golpe",
		cartas,
		jogador,
		inimigo,
		"jogador",
		{"energia": 4, "combo": 0, "combo_maximo": 5}
	)
	_verificar(not resultado["valida"], "Golpe não deve aceitar o alvo jogador")
	_verificar(inimigo.vida == 30, "carta em alvo inválido não deve causar dano")

	if falhas == 0:
		print("OK: ResolucaoCartas")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
