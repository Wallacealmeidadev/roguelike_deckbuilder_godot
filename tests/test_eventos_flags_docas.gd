extends Node

var falhas: int = 0


func _ready() -> void:
	var jogador: JogadorCombate = JogadorCombate.new(40, 4)
	var sem_flags: Array[String] = []
	var sobrevivente_antes: Array[Dictionary] = DadosEventos.opcoes_disponiveis("sobrevivente", sem_flags)
	_verificar(sobrevivente_antes.size() == 2, "sem relatório, opção extra do sobrevivente fica oculta")
	var resultado: Dictionary = ResolucaoEventos.resolver("ponto_da_queda", "vasculhar_terminal", jogador, sem_flags)
	_verificar(bool(resultado.get("valida", false)), "terminal pode ser vasculhado")
	_verificar((resultado.get("flags_concedidas", []) as Array).has("viu_relatorios_ataques"), "terminal concede flag")

	var com_flags: Array[String] = ["viu_relatorios_ataques"]
	var sobrevivente_depois: Array[Dictionary] = DadosEventos.opcoes_disponiveis("sobrevivente", com_flags)
	_verificar(sobrevivente_depois.size() == 3, "flag libera Eles já sabiam")
	var compartilhada: Dictionary = ResolucaoEventos.resolver("sobrevivente", "eles_ja_sabiam", jogador, com_flags)
	_verificar(bool(compartilhada.get("valida", false)), "opção condicional resolve com flag")

	var posto_sem: Array[Dictionary] = DadosEventos.opcoes_disponiveis("posto_inspecao", sem_flags)
	var posto_com: Array[Dictionary] = DadosEventos.opcoes_disponiveis("posto_inspecao", ["extraiu_caixa_preta"])
	_verificar(posto_sem.size() == 2, "posto oculta apresentação sem provas")
	_verificar(posto_com.size() == 3, "caixa-preta libera apresentação no posto")

	if falhas == 0:
		print("OK: eventos e flags das Docas")
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
