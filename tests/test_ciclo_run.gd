extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)

	await get_tree().process_frame

	var primeiro_inimigo: InimigoCombate = jogo.get("estado_inimigo") as InimigoCombate
	var primeiro_id: String = primeiro_inimigo.identificador
	_verificar(
		DadosInimigos.identificadores().has(primeiro_id),
		"o primeiro combate deve usar o catálogo"
	)

	_verificar(jogo.has_node("Recompensas"), "a cena precisa do container Recompensas")
	_verificar(jogo.has_node("Recompensas/RecompensaOpcao1"), "a cena precisa da primeira opção")
	_verificar(jogo.has_node("Recompensas/RecompensaOpcao2"), "a cena precisa da segunda opção")
	_verificar(jogo.has_node("Recompensas/RecompensaOpcao3"), "a cena precisa da terceira opção")
	_verificar(jogo.has_node("Recompensas/Pular"), "a cena precisa da opção de skip")
	_verificar(jogo.has_node("RecompensaElite"), "a cena precisa da recompensa do elite")
	_verificar(jogo.has_method("_resolver_vitoria"), "a vitória precisa decidir entre recompensa e conclusão")
	_verificar(jogo.has_method("_escolher_recompensa"), "a recompensa precisa entrar no baralho da run")
	_verificar(
		jogo.has_method("_escolher_recompensa_elite_reliquia"),
		"a recompensa do elite precisa escolher relíquia"
	)
	_verificar(
		jogo.has_method("_escolher_recompensa_elite_carta"),
		"a recompensa do elite precisa escolher carta rara"
	)

	if falhas == 0:
		_verificar(jogo.get("combate_atual") == 1, "a run deve começar no combate 1")
		_verificar(jogo.get("baralho_run").size() == 12, "o baralho inicial da run deve ter 12 cartas")

		jogo.set("vida_jogador", 31)
		jogo.set("vida_inimigo", 0)
		jogo.call("_resolver_vitoria")

		var recompensas: GridContainer = jogo.get_node("Recompensas") as GridContainer
		var resultado: Label = jogo.get_node("ResultadoLabel") as Label
		var reiniciar: Button = jogo.get_node("Reiniciar") as Button
		_verificar(jogo.get("aguardando_recompensa"), "a primeira vitória deve aguardar recompensa")
		_verificar(recompensas.visible, "as recompensas devem aparecer após a primeira vitória")
		_verificar(not reiniciar.visible, "reiniciar deve permanecer escondido entre combates")

		var oferta: OfertaRecompensa = jogo.get("oferta_recompensa") as OfertaRecompensa
		_verificar(oferta.opcoes.size() == 3, "a vitória deve gerar três opções")
		var id_escolhido: String = oferta.opcoes[0]
		var quantidade_anterior: int = jogo.get("baralho_run").count(id_escolhido)
		var recompensa_escolhida: Button = jogo.get_node("Recompensas/RecompensaOpcao1") as Button
		recompensa_escolhida.pressed.emit()

		var baralho_run: Array = jogo.get("baralho_run")
		var segundo_inimigo: InimigoCombate = jogo.get("estado_inimigo") as InimigoCombate
		_verificar(jogo.get("combate_atual") == 2, "a escolha deve iniciar o combate 2")
		_verificar(segundo_inimigo.identificador != primeiro_id, "a run não deve repetir inimigo")
		_verificar(
			(jogo.get("seletor_inimigos") as SeletorInimigos).enfrentados.size() == 2,
			"dois encontros devem ser registrados"
		)
		_verificar(
			segundo_inimigo.vida == segundo_inimigo.vida_maxima,
			"o inimigo sorteado deve começar com Vida cheia"
		)
		_verificar(
			segundo_inimigo.indice_intencao == 0,
			"o novo inimigo deve começar na primeira intenção"
		)
		var encontro_combate: EncontroCombate = jogo.get("encontro_combate") as EncontroCombate
		_verificar(encontro_combate.turno == 1, "o novo encontro deve reiniciar seu próprio turno")
		_verificar(
			encontro_combate.baralho.compra.size() == 7,
			"o baralho temporário deve pertencer ao encontro"
		)
		_verificar(jogo.get("vida_jogador") == 31, "a Vida deve permanecer entre combates")
		_verificar(baralho_run.size() == 13, "a recompensa deve aumentar o baralho para 13 cartas")
		_verificar(
			baralho_run.count(id_escolhido) == quantidade_anterior + 1,
			"a opção escolhida deve ser adicionada ao baralho permanente"
		)
		_verificar(jogo.get("barreira") == 0, "a Barreira de Vega deve reiniciar")
		_verificar(jogo.get("barreira_inimigo") == 0, "a Barreira do inimigo deve reiniciar")
		_verificar(jogo.get("energia") == 4, "a Energia deve reiniciar")
		_verificar(jogo.get("combo") == 0, "o Combo deve reiniciar")
		_verificar(jogo.get("turno") == 1, "o contador de turnos deve reiniciar")
		_verificar(jogo.get("pilha_descarte").is_empty(), "o descarte deve começar vazio")
		_verificar(jogo.get_node("Mao").get_child_count() == 6, "o segundo combate deve comprar 6 cartas")
		_verificar(jogo.get("pilha_compra").size() == 7, "devem restar 7 cartas na compra")
		_verificar(not recompensas.visible, "as recompensas devem esconder ao iniciar o combate 2")

		jogo.set("vida_inimigo", 0)
		jogo.call("_resolver_vitoria")
		_verificar(jogo.get("aguardando_recompensa"), "a segunda vitória deve abrir recompensa comum")
		var oferta_segunda: OfertaRecompensa = jogo.get("oferta_recompensa") as OfertaRecompensa
		_verificar(oferta_segunda.opcoes.size() == 3, "a segunda recompensa deve ter três opções")
		(jogo.get_node("Recompensas/RecompensaOpcao1") as Button).pressed.emit()

		var elite: InimigoCombate = jogo.get("estado_inimigo") as InimigoCombate
		_verificar(jogo.get("combate_atual") == 3, "a segunda recompensa deve iniciar o combate 3")
		_verificar(
			elite.identificador == "unidade_contencao_portuaria",
			"o terceiro combate deve usar o elite"
		)
		_verificar(
			(jogo.get("seletor_inimigos") as SeletorInimigos).enfrentados.size() == 2,
			"o elite não deve entrar no histórico de comuns"
		)
		_verificar(not recompensas.visible, "as recompensas comuns devem esconder no elite")

		jogo.set("vida_inimigo", 0)
		jogo.call("_resolver_vitoria")

		var oferta_reliquias: OfertaRecompensa = jogo.get("oferta_reliquias") as OfertaRecompensa
		var oferta_cartas_raras: OfertaRecompensa = jogo.get("oferta_cartas_raras") as OfertaRecompensa
		var recompensa_elite: Control = jogo.get_node("RecompensaElite") as Control
		_verificar(jogo.get("aguardando_recompensa_elite"), "a vitória do elite deve aguardar recompensa")
		_verificar(oferta_reliquias.opcoes.size() == 2, "devem existir duas relíquias")
		_verificar(oferta_cartas_raras.opcoes.size() == 3, "devem existir três cartas raras")
		_verificar(recompensa_elite.visible, "a recompensa do elite deve aparecer")
		_verificar(
			not jogo.get_node("RecompensaElite/CartasRarasElite").visible,
			"cartas raras devem esperar a escolha da relíquia"
		)
		_verificar(not reiniciar.visible, "reiniciar deve esperar os dois prêmios")

		var id_reliquia: String = oferta_reliquias.opcoes[0]
		jogo.call("_escolher_recompensa_elite_reliquia", id_reliquia)
		_verificar(
			(jogo.get("jogador_combate") as JogadorCombate).reliquias_run.has(id_reliquia),
			"a relíquia deve persistir na run"
		)
		_verificar(
			jogo.get_node("RecompensaElite/CartasRarasElite").visible,
			"a escolha deve abrir as cartas raras"
		)
		_verificar(not reiniciar.visible, "a run não pode concluir após apenas a relíquia")

		var tamanho_baralho: int = jogo.get("baralho_run").size()
		var id_carta_rara: String = oferta_cartas_raras.opcoes[0]
		jogo.call("_escolher_recompensa_elite_carta", id_carta_rara)
		_verificar(
			jogo.get("baralho_run").size() == tamanho_baralho + 1,
			"a carta rara deve entrar no baralho"
		)
		_verificar(not jogo.get("aguardando_recompensa_elite"), "as duas escolhas devem encerrar a espera")
		_verificar(not recompensa_elite.visible, "a recompensa deve esconder ao concluir")
		_verificar(reiniciar.visible, "reiniciar deve aparecer ao concluir a run")
		_verificar(resultado.text.contains("RUN CONCLUÍDA"), "a terceira vitória deve concluir a run")

	jogo.queue_free()

	var jogo_invalido: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo_invalido)
	var seletor_invalido: SeletorInimigos = SeletorInimigos.new(["ausente"])
	jogo_invalido.set("seletor_inimigos", seletor_invalido)
	jogo_invalido.call("_iniciar_combate")
	_verificar(
		seletor_invalido.enfrentados.is_empty(),
		"configuração inválida não deve ser registrada"
	)
	_verificar(
		(jogo_invalido.get_node("AcaoLabel") as Label).text.contains("Não foi possível"),
		"falha de criação deve ficar visível"
	)
	jogo_invalido.queue_free()

	if falhas == 0:
		print("OK: ciclo de run com elite e recompensa dupla")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
