extends Node

var falhas: int = 0


func _ready() -> void:
	var jogador: JogadorCombate = JogadorCombate.new(40, 4)
	var sem_inimigo: EncontroCombate = EncontroCombate.new()
	_verificar(sem_inimigo.combate_terminou(jogador), "um encontro sem inimigo não pode continuar")
	_verificar(sem_inimigo.executar_fase_inimiga(jogador).is_empty(), "sem inimigo não deve haver ação")

	var inimigo: InimigoCombate = InimigoCombate.new(
		"drone_seguranca",
		DadosInimigos.obter("drone_seguranca")
	)
	inimigo.barreira = 9
	inimigo.exposto = 2
	inimigo.indice_intencao = 3
	var baralho_run: Array[String] = ["golpe", "protecao"]
	var encontro: EncontroCombate = EncontroCombate.new()
	encontro.iniciar(inimigo, baralho_run)

	_verificar(encontro.inimigo == inimigo, "o encontro deve guardar o inimigo recebido")
	_verificar(encontro.turno == 1, "o encontro deve começar no turno 1")
	_verificar(inimigo.vida == 30, "o inimigo deve iniciar com Vida cheia")
	_verificar(inimigo.barreira == 0, "o inimigo deve reiniciar sua Barreira")
	_verificar(inimigo.exposto == 0, "o inimigo deve reiniciar seus estados")
	_verificar(inimigo.indice_intencao == 0, "o inimigo deve reiniciar na primeira intenção")
	_verificar(encontro.baralho.compra.size() == 2, "o encontro deve copiar o baralho da run")

	baralho_run.append("quebra_chassi")
	_verificar(encontro.baralho.compra.size() == 2, "o encontro não deve compartilhar a lista da run")

	var acao: Dictionary = encontro.executar_fase_inimiga(jogador)
	_verificar(acao["tipo"] == "ataque", "a fase inimiga deve executar ataque genérico")
	_verificar(acao["resultados_golpes"].size() == 2, "a Rajada deve resolver dois golpes")
	_verificar(jogador.estado.vida == 34, "a Rajada deve causar 6 de dano total")

	encontro.avancar_turno()
	_verificar(encontro.turno == 2, "avançar deve incrementar o turno")

	inimigo.vida = 0
	_verificar(encontro.combate_terminou(jogador), "Vida zero do inimigo deve encerrar o encontro")
	inimigo.vida = 30
	jogador.estado.vida = 0
	_verificar(encontro.combate_terminou(jogador), "Vida zero do jogador deve encerrar o encontro")
	_verificar(encontro.executar_fase_inimiga(jogador).is_empty(), "a fase inimiga não deve agir após o fim")

	jogador.estado.vida = 2
	inimigo.reiniciar(30)
	acao = encontro.executar_fase_inimiga(jogador)
	_verificar(jogador.estado.vida == 0, "um golpe letal deve zerar a Vida")
	_verificar(acao["resultados_golpes"].size() == 1, "o ataque deve parar após o golpe letal")

	if falhas == 0:
		print("OK: EncontroCombate genérico")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
