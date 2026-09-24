extends Node

var falhas: int = 0


func _ready() -> void:
	var jogador: JogadorCombate = JogadorCombate.new(40, 4, 5)
	var ajuda: Dictionary = ResolucaoEventos.resolver("operario_ferido", "ajudar", jogador)
	_verificar(ajuda["valida"], "ajudar deve ser válida")
	_verificar(ajuda["vida_delta"] == -10, "ajudar custa 10 de Vida")
	_verificar(ajuda["concluido"], "ajudar deve concluir o evento")
	_verificar(jogador.estado.vida == 40, "resolvedor não deve mutar diretamente a Vida")

	var valvula: Dictionary = ResolucaoEventos.resolver(
		"valvula_vapor_contaminado", "desligar", jogador
	)
	_verificar(valvula["valida"], "desligar deve ser válido")
	_verificar(valvula["tipo"] == "combate_especial", "válvula deve iniciar combate")
	_verificar(
		valvula["id_inimigo"] == "torreta_contencao",
		"válvula deve apontar para a máquina de contenção"
	)
	_verificar(not valvula["concluido"], "combate especial aguarda sua conclusão")

	var ladrao: Dictionary = ResolucaoEventos.resolver(
		"ladrao_de_cartas", "enfrentar", jogador
	)
	_verificar(ladrao["tipo"] == "combate_especial", "enfrentar deve iniciar combate")
	_verificar(ladrao["id_inimigo"] == "guarda_portuario", "ladrão deve apontar para o guarda")

	var invalida: Dictionary = ResolucaoEventos.resolver("operario_ferido", "ausente", jogador)
	_verificar(not invalida["valida"], "opção inválida deve ser rejeitada")
	_verificar(invalida["tipo"] == "invalida", "resultado inválido deve ser identificado")
	_verificar(jogador.estado.vida == 40, "opção inválida não altera Vida")

	var ausente: Dictionary = ResolucaoEventos.resolver("ausente", "opcao", jogador)
	_verificar(not ausente["valida"], "evento ausente deve ser rejeitado")
	_verificar(ausente["concluido"], "evento ausente deve encerrar sem efeito")

	for chave in ["valida", "tipo", "texto", "vida_delta", "id_inimigo", "concluido"]:
		_verificar(ajuda.has(chave), "resultado deve conter a chave %s" % chave)

	if falhas == 0:
		print("OK: resolução de eventos")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
