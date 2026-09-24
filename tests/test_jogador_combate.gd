extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var jogador: JogadorCombate = JogadorCombate.new(40, 4, 5)
	_verificar(jogador.estado.vida == 40, "o jogador deve começar com 40 de Vida")
	_verificar(jogador.energia == 4, "o jogador deve começar com 4 de Energia")
	_verificar(jogador.combo == 0, "o jogador deve começar sem Combo")

	jogador.estado.vida = 27
	jogador.estado.barreira = 8
	jogador.combo = 4
	jogador.energia = 1
	jogador.juntas_retorno_ativada_no_turno = true
	jogador.iniciar_combate(27)
	_verificar(jogador.estado.vida == 27, "a Vida deve persistir entre encontros")
	_verificar(jogador.estado.vida_maxima == 40, "a Vida máxima deve permanecer 40")
	_verificar(jogador.estado.barreira == 0, "a Barreira deve reiniciar no novo combate")
	_verificar(jogador.energia == 4, "a Energia deve reiniciar no novo combate")
	_verificar(jogador.combo == 0, "o Combo deve reiniciar no novo combate")
	_verificar(not jogador.juntas_retorno_ativada_no_turno, "Juntas deve reiniciar no novo combate")

	jogador.iniciar_combate(999)
	_verificar(jogador.estado.vida == 40, "a Vida preservada deve respeitar o máximo")
	jogador.iniciar_combate(-5)
	_verificar(jogador.estado.vida == 0, "a Vida preservada não pode ficar negativa")
	jogador.iniciar_combate(40)

	_verificar(not jogador.ganhar_combo(3, 2), "Juntas não deve ativar em 1 Combo")
	_verificar(jogador.combo == 1, "o primeiro ganho deve produzir 1 Combo")
	_verificar(jogador.ganhar_combo(3, 2), "Juntas deve ativar ao cruzar 2 Combo")
	_verificar(jogador.combo == 2, "o segundo ganho deve produzir 2 Combo")
	_verificar(jogador.estado.barreira == 3, "Juntas deve conceder 3 de Barreira")
	_verificar(not jogador.ganhar_combo(3, 2), "Juntas não deve repetir no mesmo turno")

	jogador.combo = 0
	jogador.ganhar_combo(3, 2)
	jogador.ganhar_combo(3, 2)
	_verificar(jogador.estado.barreira == 3, "voltar ao limiar não deve reativar Juntas no mesmo turno")

	jogador.combo = 5
	jogador.ganhar_combo(3, 2)
	_verificar(jogador.combo == 5, "Combo não pode ultrapassar o máximo")

	jogador.encerrar_turno()
	_verificar(jogador.energia == 0, "encerrar o turno deve zerar Energia")
	_verificar(jogador.combo == 0, "encerrar o turno deve zerar Combo")

	jogador.estado.barreira = 7
	jogador.iniciar_turno()
	_verificar(jogador.estado.barreira == 0, "iniciar turno deve remover a Barreira anterior")
	_verificar(jogador.energia == 4, "iniciar turno deve restaurar Energia")
	_verificar(not jogador.juntas_retorno_ativada_no_turno, "Juntas deve poder ativar no novo turno")
	jogador.ganhar_combo(3, 2)
	_verificar(jogador.ganhar_combo(3, 2), "Juntas deve ativar novamente no turno seguinte")

	var jogador_reliquias: JogadorCombate = JogadorCombate.new(40, 4, 5)
	_verificar(
		jogador_reliquias.possui_reliquia("juntas_retorno"),
		"Juntas deve começar equipada"
	)
	_verificar(
		jogador_reliquias.adicionar_reliquia("reservatorio_auxiliar"),
		"Reservatório deve ser adicionado"
	)
	_verificar(
		jogador_reliquias.adicionar_reliquia("mecanismo_recuo"),
		"Mecanismo deve ser adicionado"
	)
	_verificar(
		not jogador_reliquias.adicionar_reliquia("reservatorio_auxiliar"),
		"relíquia duplicada deve ser rejeitada"
	)
	jogador_reliquias.iniciar_turno()
	_verificar(
		jogador_reliquias.estado.barreira == 2,
		"Reservatório deve conceder 2 de Barreira"
	)
	_verificar(
		jogador_reliquias.registrar_finalizacao(2),
		"Mecanismo deve ativar após consumir Combo"
	)
	_verificar(
		jogador_reliquias.estado.barreira == 4,
		"Mecanismo deve conceder 2 de Barreira"
	)
	_verificar(
		not jogador_reliquias.registrar_finalizacao(1),
		"Mecanismo deve ativar uma vez por turno"
	)

	if falhas == 0:
		print("OK: JogadorCombate")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
