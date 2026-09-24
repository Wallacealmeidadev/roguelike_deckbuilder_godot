extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame

	var roteiro: RoteiroRun = jogo.get("roteiro_run") as RoteiroRun
	_verificar(roteiro != null, "a run deve possuir um roteiro")
	_verificar(roteiro.etapa_atual() == "combate_comum", "a etapa inicial deve ser combate comum")
	_verificar(jogo.get("combate_atual") == 1, "o primeiro combate deve ser numerado como 1")

	_derrotar_combate_comum(jogo)
	_verificar(
		roteiro.etapa_atual() == "evento" and (jogo.get_node("EventoOverlay") as Control).visible,
		"a recompensa do combate deve levar ao evento"
	)
	_concluir_evento_sem_combate(jogo)
	_verificar(roteiro.etapa_atual() == "combate_comum", "o evento deve levar ao segundo combate")
	_verificar(jogo.get("combate_atual") == 2, "o segundo combate deve ser numerado como 2")

	_derrotar_combate_comum(jogo)
	_concluir_evento_sem_combate(jogo)
	_verificar(roteiro.etapa_atual() == "elite", "o terceiro combate deve ser o elite")
	_verificar(
		(jogo.get("estado_inimigo") as InimigoCombate).identificador == "unidade_contencao_portuaria",
		"a terceira posição deve usar a Unidade de Contenção"
	)
	_verificar(jogo.get("combate_atual") == 3, "o elite deve ser o terceiro combate")

	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	var id_reliquia: String = (jogo.get("oferta_reliquias") as OfertaRecompensa).opcoes[0]
	jogo.call("_escolher_recompensa_elite_reliquia", id_reliquia)
	var id_carta_rara: String = (jogo.get("oferta_cartas_raras") as OfertaRecompensa).opcoes[0]
	jogo.call("_escolher_recompensa_elite_carta", id_carta_rara)
	_verificar(roteiro.etapa_atual() == "evento", "o elite deve levar ao evento seguinte")
	_verificar(not (jogo.get_node("Reiniciar") as Button).visible, "a run não termina após o elite")
	_concluir_evento_sem_combate(jogo)
	_verificar(jogo.get("combate_atual") == 4, "o quarto combate deve ser numerado como 4")

	_derrotar_combate_comum(jogo)
	_concluir_evento_sem_combate(jogo)
	_verificar(jogo.get("combate_atual") == 5, "o quinto combate deve ser numerado como 5")

	_derrotar_combate_comum(jogo)
	var resultado: Label = jogo.get_node("ResultadoLabel") as Label
	_verificar(roteiro.concluido(), "as nove posições devem concluir o roteiro pré-chefe")
	_verificar(resultado.visible, "o estado pré-chefe deve ser visível")
	_verificar(resultado.text.contains("PRE-CHEFE"), "o texto deve reservar explicitamente o chefe")
	_verificar(not resultado.text.contains("RUN CONCLUÍDA"), "não deve afirmar que a run terminou")

	jogo.queue_free()
	await _testar_combate_especial(cena_principal)

	if falhas == 0:
		print("OK: ciclo intercalado de encontros")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _derrotar_combate_comum(jogo: Node) -> void:
	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	var recompensa: Button = jogo.get_node("Recompensas/RecompensaOpcao1") as Button
	recompensa.pressed.emit()


func _concluir_evento_sem_combate(jogo: Node) -> void:
	var id_evento: String = str(jogo.get("etapa_evento_atual"))
	var opcoes: Array = DadosEventos.obter(id_evento).get("opcoes", [])
	var indice_seguro: int = -1
	for indice in range(opcoes.size()):
		if opcoes[indice].get("tipo", "") != "combate_especial":
			indice_seguro = indice
			break
	_verificar(indice_seguro >= 0, "cada evento de teste deve ter uma opção sem combate")
	jogo.call("_ao_escolher_evento", indice_seguro)
	jogo.call("_ao_continuar_evento")


func _testar_combate_especial(cena_principal: PackedScene) -> void:
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame

	var roteiro: RoteiroRun = jogo.get("roteiro_run") as RoteiroRun
	roteiro.indice_etapa = 1
	jogo.set("etapa_evento_atual", "valvula_vapor_contaminado")
	jogo.call("_mostrar_evento", "valvula_vapor_contaminado")
	jogo.call("_ao_escolher_evento", 0)

	_verificar(jogo.get("encontro_especial_pendente"), "válvula deve registrar combate especial pendente")
	_verificar(
		(jogo.get("estado_inimigo") as InimigoCombate).identificador == "torreta_contencao",
		"válvula deve iniciar a Torreta de Contenção"
	)
	_verificar(not (jogo.get_node("EventoOverlay") as Control).visible, "combate especial deve esconder o evento")
	_verificar(not (jogo.get_node("Recompensas") as Control).visible, "combate especial não deve abrir recompensa")

	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	_verificar(not jogo.get("encontro_especial_pendente"), "vitória especial deve limpar o estado pendente")
	_verificar((jogo.get_node("EventoOverlay") as Control).visible, "vitória especial deve voltar ao resultado do evento")
	_verificar(
		(jogo.get_node("EventoOverlay/EventoResultado") as Label).text.contains("máquina"),
		"resultado especial deve explicar a consequência"
	)
	_verificar(not (jogo.get_node("Recompensas") as Control).visible, "vitória especial não deve dar recompensa comum")
	jogo.call("_ao_continuar_evento")
	_verificar(roteiro.etapa_atual() == "combate_comum", "retorno deve avançar para a próxima etapa")

	var derrota: Node = cena_principal.instantiate()
	get_tree().root.add_child(derrota)
	await get_tree().process_frame
	var roteiro_derrota: RoteiroRun = derrota.get("roteiro_run") as RoteiroRun
	roteiro_derrota.indice_etapa = 1
	derrota.set("etapa_evento_atual", "valvula_vapor_contaminado")
	derrota.call("_mostrar_evento", "valvula_vapor_contaminado")
	derrota.call("_ao_escolher_evento", 0)
	derrota.set("vida_jogador", 1)
	derrota.call("_ao_encerrar_turno")
	_verificar(not derrota.get("encontro_especial_pendente"), "derrota especial deve limpar o estado pendente")
	_verificar(roteiro_derrota.etapa_atual() == "evento", "derrota não deve avançar o roteiro")
	_verificar((derrota.get_node("ResultadoLabel") as Label).text.contains("DERROTA"), "derrota especial deve encerrar a run")

	jogo.queue_free()
	derrota.queue_free()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
