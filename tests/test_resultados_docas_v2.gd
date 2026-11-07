extends Node

const DADOS_CARTAS: Script = preload("res://dados_cartas.gd")

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Node = (load("res://main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	var estado: RunState = jogo.get("run_state") as RunState
	estado.no_atual = "evento_meio"
	jogo.call("_ao_selecionar_no_mapa", "elite_docas")
	_verificar(estado.no_em_andamento == "elite_docas", "elite deve ser selecionável após evento")
	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	var oferta: OfertaRecompensa = jogo.get("oferta_recompensa") as OfertaRecompensa
	var raras: int = 0
	for id_carta in oferta.opcoes:
		if str((DADOS_CARTAS.CARTAS[id_carta] as Dictionary).get("raridade", "")) == "rara":
			raras += 1
	_verificar(raras == 1, "elite deve oferecer uma rara, não prêmio duplo")
	_verificar(not estado.concluidos.has("elite_docas"), "elite não conclui antes da oferta")
	jogo.call("_ao_pular_recompensa")
	_verificar(estado.concluidos.has("elite_docas"), "elite pode concluir pulando oferta")
	estado.no_atual = "combate_final"
	jogo.call("_ao_selecionar_no_mapa", "lastro")
	_verificar(estado.no_em_andamento == "lastro", "Boss provisório deve iniciar combate")
	_verificar(jogo.get("estado_inimigo") != null, "Boss provisório usa combate real")
	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	_verificar(estado.concluidos.has("lastro"), "vencer Boss conclui run")
	_verificar(not bool(jogo.get("mapa_ativo")), "run terminada não libera novos nós")
	jogo.queue_free()
	var jogo_derrota: Node = (load("res://main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(jogo_derrota)
	await get_tree().process_frame
	var estado_derrota: RunState = jogo_derrota.get("run_state") as RunState
	jogo_derrota.call("_ao_selecionar_no_mapa", "inicio")
	jogo_derrota.call("_iniciar_combate_por_id", "drone_seguranca", false)
	jogo_derrota.set("vida_jogador", 1)
	jogo_derrota.call("_ao_encerrar_turno")
	_verificar(not estado_derrota.concluidos.has("inicio"), "derrota não conclui combate")
	_verificar(not bool(jogo_derrota.get("mapa_ativo")), "derrota encerra a tentativa")
	_verificar((jogo_derrota.get_node("ResultadoLabel") as Label).text.contains("DERROTA"), "resultado de derrota é explícito")
	jogo_derrota.queue_free()
	var jogo_evento: Node = (load("res://main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(jogo_evento)
	await get_tree().process_frame
	var estado_evento: RunState = jogo_evento.get("run_state") as RunState
	estado_evento.no_atual = "inicio"
	estado_evento.mapa.nos["evento_cais"]["id_conteudo"] = "carga_descartada"
	jogo_evento.set("vida_jogador", 5)
	jogo_evento.call("_ao_selecionar_no_mapa", "evento_cais")
	jogo_evento.call("_ao_escolher_evento", 0)
	_verificar(not bool(jogo_evento.get("mapa_ativo")), "custo letal em evento encerra tentativa")
	_verificar(not estado_evento.concluidos.has("evento_cais"), "evento letal não conclui nó")
	_verificar((jogo_evento.get_node("ResultadoLabel") as Label).text.contains("DERROTA"), "evento letal mostra derrota")
	jogo_evento.queue_free()
	if falhas == 0:
		print("OK: elite e Boss provisório")
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
