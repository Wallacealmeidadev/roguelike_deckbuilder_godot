extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var cena: PackedScene = load("res://main.tscn") as PackedScene
	await _percorrer_rota(cena, "elite_docas")
	await _percorrer_rota(cena, "desmanche_docas")
	if falhas == 0:
		print("OK: onze nós, dois ramos e Boss provisório")
	get_tree().quit(0 if falhas == 0 else 1)


func _percorrer_rota(cena: PackedScene, ramo: String) -> void:
	var jogo: Node = cena.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.set("mapa_variante", 42)
	jogo.call("_iniciar_nova_run")
	await get_tree().process_frame
	var estado: RunState = jogo.get("run_state") as RunState
	var mapa_original: MapaRun = estado.mapa
	var rota: Array[String] = ["inicio", "evento_cais", "combate_entrada", "descanso_1", "evento_meio", ramo, "combate_reencontro", "evento_final", "descanso_2", "combate_final", "lastro"]
	for id_no in rota:
		_verificar(estado.destinos_disponiveis().has(id_no), "%s deve estar disponível após %s" % [id_no, estado.no_atual])
		jogo.call("_ao_selecionar_no_mapa", id_no)
		_verificar(estado.no_em_andamento == id_no, "%s deve entrar em andamento" % id_no)
		var tipo: String = str(mapa_original.obter_no(id_no).get("tipo", ""))
		match tipo:
			MapaRun.TIPO_COMBATE, MapaRun.TIPO_ELITE:
				for inimigo in (jogo.get("encontro_combate") as EncontroCombate).inimigos:
					inimigo.vida = 0
				jogo.call("_resolver_vitoria")
				_verificar(not estado.concluidos.has(id_no), "combate aguarda recompensa")
				jogo.call("_ao_pular_recompensa")
			MapaRun.TIPO_EVENTO:
				var id_evento: String = str(mapa_original.obter_no(id_no).get("id_conteudo", ""))
				var opcoes: Array[Dictionary] = DadosEventos.opcoes_disponiveis(id_evento, estado.flags)
				var indice_escolhido: int = -1
				for indice in range(opcoes.size()):
					if str(opcoes[indice].get("tipo", "")) not in ["combate_especial", "deck_remover", "deck_recalibrar"]:
						indice_escolhido = indice
						break
				_verificar(indice_escolhido >= 0, "evento deve ter saída sem combate")
				if indice_escolhido >= 0:
					jogo.call("_ao_escolher_evento", indice_escolhido)
					_verificar(not estado.concluidos.has(id_no), "evento aguarda continuar")
					jogo.call("_ao_continuar_evento")
			MapaRun.TIPO_DESCANSO:
				var recuperar: Button = jogo.get_node("DescansoOverlay/Acoes/RecuperarPainel") as Button
				if not recuperar.disabled:
					recuperar.pressed.emit()
				_verificar(not estado.concluidos.has(id_no), "REST aguarda continuar")
				(jogo.get_node("DescansoOverlay/Continuar") as Button).pressed.emit()
			MapaRun.TIPO_DESMANCHE:
				var selecionar_desmanche: Button = jogo.get_node("DesmancheOverlay/Conteudo/ListaScroll/Lista/Item1/Selecionar") as Button
				selecionar_desmanche.pressed.emit()
				(jogo.get_node("DesmancheOverlay/Conteudo/Acoes/Recalibrar") as Button).pressed.emit()
				(jogo.get_node("DesmancheOverlay/Conteudo/Acoes/Confirmar") as Button).pressed.emit()
				_verificar(not estado.concluidos.has(id_no), "Desmanche aguarda continuar")
				(jogo.get_node("DesmancheOverlay/Conteudo/Continuar") as Button).pressed.emit()
			MapaRun.TIPO_CHEFE:
				for inimigo in (jogo.get("encontro_combate") as EncontroCombate).inimigos:
					inimigo.vida = 0
				jogo.call("_resolver_vitoria")
		_verificar(estado.concluidos.has(id_no), "%s deve concluir após efeito e recompensa" % id_no)
		_verificar(estado.mapa == mapa_original and estado.seed == 42, "mapa e seed não regeneram ao reabrir")
	_verificar(estado.concluidos.size() == 11, "rota deve concluir onze nós")
	_verificar((jogo.get_node("ResultadoLabel") as Label).visible, "Boss provisório encerra run")
	jogo.queue_free()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
