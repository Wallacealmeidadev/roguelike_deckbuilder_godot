extends Node

var falhas: int = 0
var resolucao: ResolucaoCartas = ResolucaoCartas.new()
var cartas: Dictionary


func _ready() -> void:
	var script_cartas: Script = load("res://dados_cartas.gd") as Script
	cartas = script_cartas.get_script_constant_map()["CARTAS"]
	for id_inimigo in DadosInimigos.identificadores():
		_testar_cartas(id_inimigo)

	if falhas == 0:
		print("OK: cartas contra quatro inimigos")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _novo_inimigo(id_inimigo: String) -> InimigoCombate:
	return InimigoCombate.new(id_inimigo, DadosInimigos.obter(id_inimigo))


func _testar_cartas(id_inimigo: String) -> void:
	var jogador: Combatente = Combatente.new(40)
	var inimigo: InimigoCombate = _novo_inimigo(id_inimigo)
	var vida_inicial: int = inimigo.vida
	var resultado: Dictionary = resolucao.resolver(
		"golpe", cartas, jogador, inimigo, "inimigo",
		{"energia": 4, "combo": 0, "combo_maximo": 5}
	)
	_verificar(resultado["valida"] and inimigo.vida == vida_inicial - 6, "%s deve receber Golpe" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	resultado = resolucao.resolver(
		"protecao", cartas, jogador, jogador, "jogador",
		{"energia": 4, "combo": 0, "combo_maximo": 5}
	)
	_verificar(resultado["valida"] and jogador.barreira == 5, "Proteção deve funcionar durante %s" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	vida_inicial = inimigo.vida
	resolucao.resolver(
		"direto_hidraulico", cartas, jogador, inimigo, "inimigo",
		{"energia": 4, "combo": 0, "combo_maximo": 5}
	)
	_verificar(inimigo.vida == vida_inicial - 4 and jogador.barreira == 2, "Direto deve funcionar contra %s" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	vida_inicial = inimigo.vida
	resultado = resolucao.resolver(
		"quebra_chassi", cartas, jogador, inimigo, "inimigo",
		{"energia": 4, "combo": 3, "combo_maximo": 5}
	)
	_verificar(
		inimigo.vida == maxi(0, vida_inicial - 14) and resultado["combo"] == 0,
		"Quebra-chassi deve funcionar contra %s" % id_inimigo
	)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	resolucao.resolver(
		"brecha", cartas, jogador, inimigo, "inimigo",
		{"energia": 4, "combo": 0, "combo_maximo": 5}
	)
	_verificar(inimigo.exposto == 2, "Brecha deve aplicar Exposto em %s" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	resolucao.resolver(
		"pulso_debilitante", cartas, jogador, inimigo, "inimigo",
		{"energia": 4, "combo": 0, "combo_maximo": 5}
	)
	_verificar(
		inimigo.enfraquecido == 2 and jogador.barreira == 3,
		"Pulso deve funcionar contra %s" % id_inimigo
	)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
