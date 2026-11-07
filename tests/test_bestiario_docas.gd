extends Node

var falhas: int = 0


func _ready() -> void:
	_testar_catalogo_e_pools()
	_testar_carga()
	_testar_estivador()
	_testar_reparador()
	_testar_sentinela()
	_testar_caranguejo()
	_testar_guindaste()
	_testar_duplas_e_alvos()
	_testar_integracao_cartas()
	if falhas == 0:
		print("OK: bestiário comum das Docas")
	get_tree().quit(0 if falhas == 0 else 1)


func _novo(id_inimigo: String) -> InimigoCombate:
	return InimigoCombate.new(id_inimigo, DadosInimigos.obter(id_inimigo))


func _acao(encontro: EncontroCombate, jogador: JogadorCombate) -> Dictionary:
	return encontro.executar_fase_inimiga(jogador)


func _testar_catalogo_e_pools() -> void:
	_verificar(DadosEncontrosDocas.ENCONTROS.size() == 9, "nove encontros comuns")
	for id_encontro in DadosEncontrosDocas.ENCONTROS.keys():
		for id_inimigo in DadosEncontrosDocas.obter(str(id_encontro)):
			_verificar(not DadosInimigos.obter(id_inimigo).is_empty(), "%s tem dados válidos" % id_inimigo)
	for id_encontro in DadosEncontrosDocas.EARLY_POOL:
		_verificar(DadosEncontrosDocas.obter(id_encontro).size() == 1, "abertura sem duplas")
	var mapa_a: MapaRun = MapaRun.new()
	var mapa_b: MapaRun = MapaRun.new()
	mapa_a.gerar(812)
	mapa_b.gerar(812)
	for no_id in ["inicio", "combate_entrada", "combate_reencontro", "combate_final"]:
		_verificar(mapa_a.obter_no(no_id)["id_conteudo"] == mapa_b.obter_no(no_id)["id_conteudo"], "seed reproduz %s" % no_id)


func _testar_carga() -> void:
	var inimigo: InimigoCombate = _novo("drone_carga")
	var jogador: JogadorCombate = JogadorCombate.new(40, 4)
	var encontro: EncontroCombate = EncontroCombate.new()
	encontro.iniciar(inimigo, ["golpe"])
	_verificar(_acao(encontro, jogador)["tipo"] == "defesa" and inimigo.barreira == 7, "Carga defende no turno 1")
	_verificar(inimigo.receber_golpe(9)["dano_na_vida"] == 2, "Barreira absorve antes da Vida")
	_verificar(_acao(encontro, jogador)["danos"] == [10] and inimigo.barreira == 0, "Carga ataca e expira Barreira")
	_verificar(_acao(encontro, jogador)["danos"] == [6], "Carga usa Braço Mecânico")
	_verificar(inimigo.texto_intencao().contains("+7"), "Carga reinicia o ciclo")


func _testar_estivador() -> void:
	var inimigo: InimigoCombate = _novo("estivador_aumentado")
	_verificar(inimigo.executar_intencao()["danos"] == [7], "Soco inicial causa 7")
	_verificar(inimigo.texto_intencao().contains("prepara +2"), "Ombro anuncia preparação")
	_verificar(inimigo.executar_intencao()["danos"] == [5], "Ombro causa 5")
	_verificar(inimigo.texto_intencao().contains("9"), "próximo Soco anuncia dano final 9")
	inimigo.reiniciar(34)
	inimigo.receber_golpe(16)
	_verificar(inimigo.vida == 18 and not inimigo.frenesi, "Frenesi não começa em 18")
	inimigo.receber_golpe(1)
	_verificar(inimigo.vida == 17 and inimigo.frenesi, "Frenesi começa exatamente em 17")
	_verificar(inimigo.texto_intencao().contains("FRENESI"), "intenção anuncia Frenesi")
	_verificar(inimigo.executar_intencao()["danos"] == [5, 5], "Frenesi usa dois golpes de 5")
	inimigo.vida = 25
	_verificar(inimigo.frenesi and inimigo.executar_intencao()["danos"] == [5, 5], "Frenesi permanece")


func _testar_reparador() -> void:
	var aliado: InimigoCombate = _novo("drone_carga")
	var reparador: InimigoCombate = _novo("drone_reparador")
	var encontro: EncontroCombate = EncontroCombate.new()
	var jogador: JogadorCombate = JogadorCombate.new(80, 4)
	encontro.iniciar_multiplos([aliado, reparador], ["golpe"])
	aliado.vida = 10
	_verificar(reparador.texto_intencao().contains(aliado.nome), "intenção de suporte indica alvo")
	var acoes: Array[Dictionary] = encontro.executar_fase_inimiga_multiplos(jogador)
	_verificar(acoes.size() == 2 and aliado.barreira == 13 and reparador.barreira == 0, "Reparador protege outro")
	encontro.executar_fase_inimiga_multiplos(jogador)
	encontro.executar_fase_inimiga_multiplos(jogador)
	_verificar(aliado.vida == 15 and reparador.vida == 18, "Reparador cura somente aliado")
	aliado.vida = 0
	_verificar(reparador.texto_intencao().contains("5"), "intenção muda ao ficar sozinho")
	_verificar(encontro.executar_fase_inimiga_multiplos(jogador)[0]["danos"] == [5], "Reparador solo ataca por 5")
	var novo_aliado: InimigoCombate = _novo("caranguejo_sucata")
	reparador.aliados = [weakref(novo_aliado)]
	reparador.indice_intencao = 2
	_verificar(reparador.texto_intencao().contains(novo_aliado.nome), "cura anuncia aliado vivo")
	novo_aliado.vida = 0
	_verificar(reparador.executar_intencao()["danos"] == [5], "queda do aliado antes da ação usa fallback seguro")


func _testar_sentinela() -> void:
	var sentinela: InimigoCombate = _novo("sentinela_inspecao")
	var jogador: JogadorCombate = JogadorCombate.new(60, 4)
	var encontro: EncontroCombate = EncontroCombate.new()
	encontro.iniciar(sentinela, ["golpe"])
	_acao(encontro, jogador)
	_verificar(sentinela.marcado and sentinela.texto_intencao().contains("14"), "Marcado mostra dano final 14")
	_verificar(_acao(encontro, jogador)["danos"] == [14], "Marcado soma 6 ao ataque próprio")
	_verificar(not sentinela.marcado, "Marcado é consumido")
	_verificar(_acao(encontro, jogador)["danos"] == [6], "Supressão não recebe bônus já consumido")


func _testar_caranguejo() -> void:
	var inimigo: InimigoCombate = _novo("caranguejo_sucata")
	var jogador: JogadorCombate = JogadorCombate.new(40, 4)
	jogador.estado.barreira = 4
	var encontro: EncontroCombate = EncontroCombate.new()
	encontro.iniciar(inimigo, ["golpe"])
	var acao: Dictionary = _acao(encontro, jogador)
	_verificar(acao["resultados_golpes"].size() == 3, "Garras são três golpes separados")
	_verificar(jogador.estado.vida == 35, "Barreira distribui absorção por golpe")
	_verificar(_acao(encontro, jogador)["tipo"] == "defesa" and inimigo.barreira == 8, "Casco dá Barreira própria")


func _testar_guindaste() -> void:
	var inimigo: InimigoCombate = _novo("guindaste_autonomo")
	var jogador: JogadorCombate = JogadorCombate.new(80, 4)
	var encontro: EncontroCombate = EncontroCombate.new()
	encontro.iniciar(inimigo, ["golpe"])
	_verificar(_acao(encontro, jogador)["tipo"] == "travar", "Guindaste trava sem dano")
	_verificar(_acao(encontro, jogador)["danos"] == [18], "Impacto causa 18")
	_verificar(_acao(encontro, jogador)["tipo"] == "recalibrar", "terceiro turno recalibra")
	_verificar(inimigo.recalibrando and inimigo.exposto == 0, "Recalibrando não é Exposto")
	_verificar(inimigo.receber_golpe(5)["dano"] == 8, "janela soma 50% com arredondamento")
	_acao(encontro, jogador)
	_verificar(not inimigo.recalibrando and inimigo.receber_golpe(5)["dano"] == 5, "janela expira na próxima ação")


func _testar_duplas_e_alvos() -> void:
	var primeiro: InimigoCombate = _novo("caranguejo_sucata")
	var segundo: InimigoCombate = _novo("caranguejo_sucata")
	var jogador: JogadorCombate = JogadorCombate.new(80, 4)
	var encontro: EncontroCombate = EncontroCombate.new()
	encontro.iniciar_multiplos([primeiro, segundo], ["golpe"])
	primeiro.vida = 0
	_verificar(not encontro.combate_terminou(jogador), "dupla não termina com primeira morte")
	_verificar(encontro.executar_fase_inimiga_multiplos(jogador).size() == 1, "morto não age")
	segundo.receber_golpe(30)
	_verificar(encontro.combate_terminou(jogador), "dupla termina após ambas as mortes")


func _testar_integracao_cartas() -> void:
	var catalogo: Dictionary = (load("res://dados_cartas.gd") as Script).get_script_constant_map()["CARTAS"]
	var resolucao: ResolucaoCartas = ResolucaoCartas.new()
	var jogador: Combatente = Combatente.new(40)
	var primeiro: InimigoCombate = _novo("caranguejo_sucata")
	var segundo: InimigoCombate = _novo("caranguejo_sucata")
	var resultado: Dictionary = resolucao.resolver("quebra_chassi", catalogo, jogador, segundo, "inimigo", {"energia": 4, "combo": 3})
	_verificar(resultado["valida"] and resultado["combo"] == 0, "Finalização consome Combo no novo alvo")
	_verificar(primeiro.vida == 22 and segundo.vida == 8, "Finalização atinge só o alvo selecionado")
	var cargo: InimigoCombate = _novo("drone_carga")
	cargo.barreira = 7
	resolucao.resolver("golpe", catalogo, jogador, cargo, "inimigo", {"energia": 4, "combo": 0})
	_verificar(cargo.barreira == 1 and cargo.vida == 26, "ataque normal respeita Barreira individual")
	resolucao.resolver("brecha", catalogo, jogador, cargo, "inimigo", {"energia": 4, "combo": 0})
	_verificar(cargo.exposto == 2, "Brecha aplica Exposto ao novo inimigo")
	var guindaste: InimigoCombate = _novo("guindaste_autonomo")
	guindaste.recalibrando = true
	resultado = resolucao.resolver("quebra_chassi", catalogo, jogador, guindaste, "inimigo", {"energia": 4, "combo": 10})
	_verificar(resultado["valida"] and guindaste.vida == 0 and guindaste.exposto == 0, "dano alto aproveita janela sem criar Exposto")


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
