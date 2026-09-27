extends Node

const DADOS_CARTAS_TEST: Script = preload("res://dados_cartas.gd")
const DESCANSO_RUN_SCRIPT: Script = preload("res://descanso_run.gd")

var falhas: int = 0


func _ready() -> void:
	var descanso = DESCANSO_RUN_SCRIPT.new()
	_verificar(descanso.vida_a_recuperar(31, 40) == 8, "cura parcial deve usar a cura base")
	_verificar(descanso.vida_a_recuperar(36, 40) == 4, "cura deve ser limitada pela Vida maxima")
	_verificar(descanso.vida_a_recuperar(40, 40) == 0, "Vida cheia nao deve oferecer cura")

	var baralho: Array[String] = ["golpe", "golpe", "protecao", "golpe#aprimorado"]
	var elegiveis: Array[Dictionary] = descanso.cartas_elegiveis(baralho)
	_verificar(elegiveis.size() == 3, "tres copias nao aprimoradas devem ser elegiveis")
	_verificar(
		int(elegiveis[0]["indice"]) == 0 and int(elegiveis[1]["indice"]) == 1 and int(elegiveis[2]["indice"]) == 2,
		"a selecao deve preservar o indice da copia"
	)
	_verificar(
		int(elegiveis[0]["ocorrencia"]) == 1 and int(elegiveis[1]["ocorrencia"]) == 2,
		"copias iguais devem receber identificadores de ocorrencia distintos"
	)
	_verificar(not elegiveis.any(func(item: Dictionary) -> bool: return int(item["indice"]) == 3), "carta aprimorada nao deve voltar a ser elegivel")

	var dados_antes: Dictionary = DADOS_CARTAS_TEST.CARTAS["golpe"].duplicate(true)
	var dados_depois: Dictionary = descanso.dados_aprimorados("golpe", dados_antes)
	_verificar(int(dados_depois["valor"]) == 9, "Golpe deve receber mais 3 de dano na pre-visualizacao")
	_verificar(int(dados_antes["valor"]) == 6, "a pre-visualizacao nao pode mutar o catalogo")

	var baralho_confirmado: Array[String] = baralho.duplicate()
	_verificar(descanso.aplicar_melhoria(baralho_confirmado, 1), "a copia escolhida deve ser aprimorada")
	_verificar(baralho_confirmado[1] == "golpe#aprimorado", "somente a copia escolhida deve receber o sufixo")
	_verificar(baralho_confirmado[0] == "golpe", "a outra copia igual deve permanecer normal")
	_verificar(not descanso.aplicar_melhoria(baralho_confirmado, 1), "a mesma copia nao pode ser aprimorada duas vezes")
	_verificar(not descanso.aplicar_melhoria(baralho_confirmado, 3), "uma carta ja aprimorada deve ser rejeitada")

	if falhas == 0:
		print("OK: regras de descanso")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
