extends Node

var falhas: int = 0
const IDS_EVENTOS: Array[String] = [
	"ponto_da_queda",
	"turno_encerrado",
	"carga_descartada",
	"caixa_preta",
	"agua_morta",
	"sobrevivente",
	"posto_inspecao",
	"ninho_sob_cais"
]


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	_testar_catalogo_e_familias()
	_testar_resolucao_de_dados()
	await _testar_fluxo_ui_e_deck()
	await _testar_combate_pendente()
	await _testar_custo_letal()
	if falhas == 0:
		print("OK: oito eventos reais das Docas")
	get_tree().quit(0 if falhas == 0 else 1)


func _testar_catalogo_e_familias() -> void:
	_verificar(DadosEventos.EVENTOS.size() == 8, "o catálogo deve conter oito eventos")
	for id_evento in IDS_EVENTOS:
		var dados: Dictionary = DadosEventos.obter(id_evento)
		_verificar(not dados.is_empty(), "evento carregável: %s" % id_evento)
		_verificar((dados.get("opcoes", []) as Array).size() == 3, "evento tem três opções: %s" % id_evento)

	var mapa_a: MapaRun = MapaRun.new()
	var mapa_b: MapaRun = MapaRun.new()
	mapa_a.gerar(81234)
	mapa_b.gerar(81234)
	var eventos_a: Array[String] = []
	var eventos_b: Array[String] = []
	for no in ["evento_cais", "evento_meio", "evento_final"]:
		eventos_a.append(str(mapa_a.obter_no(no).get("id_conteudo", "")))
		eventos_b.append(str(mapa_b.obter_no(no).get("id_conteudo", "")))
	_verificar(eventos_a == eventos_b, "a mesma seed repete o conteúdo dos eventos")
	_verificar(eventos_a.size() == eventos_a.duplicate().size(), "eventos da run não repetem")
	_verificar(mapa_a.eventos_consecutivos_validos(), "famílias consecutivas são evitadas no grafo")
	mapa_a.conexoes["evento_cais"] = ["evento_meio"]
	mapa_a.nos["evento_cais"]["familia"] = mapa_a.nos["evento_meio"]["familia"]
	_verificar(not mapa_a.eventos_consecutivos_validos(), "validação rejeita famílias iguais quando eventos são adjacentes")


func _testar_resolucao_de_dados() -> void:
	var jogador: JogadorCombate = JogadorCombate.new(40, 4)
	var sem_flags: Array[String] = []
	var com_relatorios: Array[String] = ["viu_relatorios_ataques"]
	_verificar(DadosEventos.opcoes_disponiveis("sobrevivente", sem_flags).size() == 2, "Sobrevivente começa sem opção condicional")
	_verificar(DadosEventos.opcoes_disponiveis("sobrevivente", com_relatorios).size() == 3, "relatórios liberam Eles já sabiam")
	_verificar(DadosEventos.opcoes_disponiveis("posto_inspecao", ["extraiu_caixa_preta"]).size() == 3, "caixa-preta libera o Posto")
	var custo: Dictionary = ResolucaoEventos.resolver("agua_morta", "fechar_valvula", jogador)
	_verificar(int(custo["vida_delta"]) == -6, "custo da Água Morta é seis")
	var recompensa: Dictionary = ResolucaoEventos.resolver("agua_morta", "coletar_amostra", jogador)
	_verificar(str((recompensa["recompensa"] as Dictionary).get("id_reliquia", "")) == "reliquia_evento_agua_morta_provisorio", "Amostra usa hook provisório")
	var exclusiva: Array[Dictionary] = (DescansoRun.new() as DescansoRun).cartas_elegiveis(["golpe", "golpe#aprimorado"], "vega_exclusiva")
	_verificar(exclusiva.size() == 1, "filtro de carta exclusiva usa metadado e ignora recalibrada")


func _novo_jogo() -> Node:
	var jogo: Node = (load("res://main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	return jogo


func _testar_fluxo_ui_e_deck() -> void:
	var jogo: Node = await _novo_jogo()
	var estado: RunState = jogo.get("run_state") as RunState
	jogo.call("_mostrar_evento", "ponto_da_queda")
	(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button).pressed.emit()
	_verificar(estado.possui_flag("viu_relatorios_ataques"), "Ponto da Queda persiste a flag pela UI")
	jogo.call("_mostrar_evento", "sobrevivente")
	_verificar((jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao3") as Button).visible, "Sobrevivente mostra opção após a flag")
	(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao3") as Button).pressed.emit()
	_verificar(estado.possui_flag("compartilhou_relatorios"), "Sobrevivente persiste a escolha condicional")
	var reliquias_antes: int = (jogo.get("jogador_combate") as JogadorCombate).reliquias_run.size()
	jogo.call("_mostrar_evento", "carga_descartada")
	(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button).pressed.emit()
	var reliquias_depois: int = (jogo.get("jogador_combate") as JogadorCombate).reliquias_run.size()
	_verificar(reliquias_depois == reliquias_antes + 1, "recompensa global é concedida uma vez")
	jogo.call("_mostrar_evento", "carga_descartada")
	(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button).pressed.emit()
	_verificar((jogo.get("jogador_combate") as JogadorCombate).reliquias_run.size() == reliquias_depois, "reabrir evento não duplica relíquia")

	estado.deck = ["golpe", "protecao", "golpe#aprimorado"]
	var tamanho_antes: int = (jogo.get("baralho_run") as Array[String]).size()
	jogo.call("_mostrar_evento", "turno_encerrado")
	(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button).pressed.emit()
	var overlay: DesmancheOverlay = jogo.get("desmanche_overlay") as DesmancheOverlay
	_verificar(overlay.visible and overlay.lista.get_child_count() == 3, "evento de remoção mostra todas as cartas elegíveis")
	(overlay.lista.get_child(0).get_node("Selecionar") as Button).pressed.emit()
	overlay.remover_acao.pressed.emit()
	overlay.confirmar_acao.pressed.emit()
	_verificar((jogo.get("baralho_run") as Array[String]).size() == tamanho_antes - 1, "remoção de evento altera deck persistente")
	overlay.continuar.pressed.emit()
	_verificar(estado.possui_flag("ajudou_estivadores"), "flag do evento só entra ao concluir ação de deck")

	jogo.call("_mostrar_evento", "caixa_preta")
	(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao3") as Button).pressed.emit()
	overlay = jogo.get("desmanche_overlay") as DesmancheOverlay
	_verificar(overlay.lista.get_child_count() == 2, "filtro Vega mantém cartas recalibradas visíveis")
	(overlay.lista.get_child(0).get_node("Selecionar") as Button).pressed.emit()
	overlay.recalibrar_acao.pressed.emit()
	overlay.confirmar_acao.pressed.emit()
	overlay.continuar.pressed.emit()
	_verificar((jogo.get("baralho_run") as Array[String]).has("golpe#aprimorado"), "recalibração de evento persiste token")
	jogo.queue_free()


func _testar_combate_pendente() -> void:
	var jogo: Node = await _novo_jogo()
	var estado: RunState = jogo.get("run_state") as RunState
	estado.no_atual = "inicio"
	_verificar(estado.iniciar_no("evento_cais"), "nó de evento pode ficar pendente para o combate especial")
	jogo.call("_mostrar_evento", "posto_inspecao")
	(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button).pressed.emit()
	_verificar(bool(jogo.get("encontro_especial_pendente")), "combate preserva evento pendente")
	_verificar(not estado.concluidos.has("evento_cais"), "evento não conclui antes da vitória")
	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	jogo.call("_ao_continuar_evento")
	_verificar(estado.concluidos.has("evento_cais"), "vitória conclui o nó de evento")
	jogo.queue_free()
	var jogo_derrota: Node = await _novo_jogo()
	var estado_derrota: RunState = jogo_derrota.get("run_state") as RunState
	estado_derrota.no_atual = "inicio"
	_verificar(estado_derrota.iniciar_no("evento_cais"), "nó de evento pode iniciar combate para derrota")
	jogo_derrota.call("_mostrar_evento", "posto_inspecao")
	(jogo_derrota.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button).pressed.emit()
	jogo_derrota.set("vida_jogador", 0)
	jogo_derrota.call("_mostrar_resultado")
	_verificar(not estado_derrota.concluidos.has("evento_cais"), "derrota em evento-combate não conclui o nó")
	_verificar(not bool(jogo_derrota.get("mapa_ativo")), "derrota em evento-combate encerra a tentativa")
	jogo_derrota.queue_free()


func _testar_custo_letal() -> void:
	var jogo: Node = await _novo_jogo()
	var estado: RunState = jogo.get("run_state") as RunState
	estado.no_atual = "inicio"
	_verificar(estado.iniciar_no("evento_cais"), "nó de custo pode ficar pendente")
	jogo.set("vida_jogador", 20)
	jogo.call("_mostrar_evento", "agua_morta")
	(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button).pressed.emit()
	_verificar(int(jogo.get("vida_jogador")) == 14, "custo sobrevivido persiste Vida")
	_verificar(estado.vida_atual == 14, "RunState persiste custo sobrevivido")
	# O mesmo teste usa uma nova tentativa para cobrir a morte sem reaproveitar o nó concluído.
	jogo.queue_free()
	jogo = await _novo_jogo()
	estado = jogo.get("run_state") as RunState
	estado.no_atual = "inicio"
	_verificar(estado.iniciar_no("evento_cais"), "nó de custo letal pode ficar pendente")
	jogo.set("vida_jogador", 8)
	jogo.call("_mostrar_evento", "ninho_sob_cais")
	(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button).pressed.emit()
	_verificar(int(jogo.get("vida_jogador")) == 0, "custo letal reduz Vida a zero")
	_verificar(not bool(jogo.get("mapa_ativo")), "morte por custo encerra a tentativa")
	_verificar(not estado.concluidos.has("evento_cais"), "morte por custo não conclui o nó")
	jogo.queue_free()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
