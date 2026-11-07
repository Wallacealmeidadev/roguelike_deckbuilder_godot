extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	get_window().size = Vector2i(1024, 576)
	await get_tree().process_frame
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	await get_tree().process_frame

	_verificar(not (jogo.get_node("RunStatusLabel") as Control).visible, "bloco antigo de progresso nao deve ficar em repouso")
	_verificar((jogo.get_node("TopoCombate") as Control).visible, "faixa R3 deve aparecer no combate")
	_verificar((jogo.get_node("TopoCombate/TopoRetrato") as TextureRect).texture != null, "Vega precisa de retrato provisório")
	_verificar((jogo.get_node("TopoCombate/TopoVida") as Label).text == "40 / 40", "vida da faixa deve usar o estado real")
	_verificar(jogo.get_node("TopoCombate").get_theme_stylebox("panel") is StyleBoxEmpty, "faixa superior nao deve duplicar a moldura neon")
	_verificar(jogo.has_node("TopoCombate/ModuloJogador"), "faixa superior deve usar o modulo ilustrado do jogador")
	_verificar(jogo.get_node("StatsJogadorPanel").get_theme_stylebox("panel") is StyleBoxEmpty, "recursos nao devem duplicar a placa neon")
	_verificar(jogo.get_node("BaralhoOverlay").get_theme_stylebox("panel") is StyleBoxTexture, "overlay de pilha deve usar moldura neon")
	_verificar(jogo.has_node("EncerrarTurno/BotaoIlustrado") and (jogo.get_node("EncerrarTurno") as Button).get_theme_stylebox("normal") is StyleBoxEmpty, "fim de turno deve usar o botao ilustrado")
	_verificar((jogo.get_node("EnergiaPainel") as Panel).get_theme_stylebox("panel") is StyleBoxEmpty, "energia nao deve duplicar a placa neon")
	_verificar((jogo.get_node("BaralhoOverlay/BaralhoTitulo") as Label).get_theme_font("font") != load("res://ui_hq_v1/fontes/Bangers-Regular.ttf"), "titulo de overlay deve usar tipografia de HUD")
	var reliquias_topo: HBoxContainer = jogo.get_node("TopoCombate/TopoReliquias") as HBoxContainer
	_verificar(reliquias_topo.get_child_count() == 1, "uma reliquia deve gerar um icone individual")
	_verificar(not reliquias_topo.get_child(0).get_meta("nome_reliquia", "").is_empty(), "icone deve carregar o nome real da reliquia")
	_verificar(reliquias_topo.get_global_rect().encloses((reliquias_topo.get_child(0) as Control).get_global_rect()), "reliquia precisa ocupar seu encaixe sem texto solto")
	_verificar(not reliquias_topo.get_global_rect().intersects((jogo.get_node("TopoCombate/TopoBaralho") as Control).get_global_rect()), "sequencia de reliquias nao deve invadir os controles da direita")
	_verificar(not (jogo.get_node("MaoStatusLabel") as Control).visible, "contagem da mao nao deve aparecer no repouso")

	jogo.set("vida_jogador", 28)
	(jogo.get("jogador_combate") as JogadorCombate).adicionar_reliquia("reservatorio_auxiliar")
	jogo.call("_atualizar_interface")
	_verificar((jogo.get_node("TopoCombate/TopoVida") as Label).text == "28 / 40", "vida da faixa deve acompanhar dano real")
	_verificar(reliquias_topo.get_child_count() == 2, "reliquia adquirida deve gerar um novo icone")

	(jogo.get_node("TopoCombate/TopoRota") as Button).pressed.emit()
	_verificar(not (jogo.get_node("MapaOverlay") as Control).visible, "rota nao deve abrir mapa navegavel durante combate")
	_verificar((jogo.get_node("HudInspecao") as Control).visible, "rota deve mostrar progresso contextual")
	_verificar((jogo.get_node("HudInspecao/Texto") as Label).text.contains("PONTO 1/11"), "progresso deve vir do mapa real")
	_verificar(not (jogo.get_node("HudInspecao") as Control).get_global_rect().intersects((jogo.get_node("IntencaoIcone") as Control).get_global_rect()), "inspecao da rota nao deve cobrir simbolo da intencao")
	_verificar(not (jogo.get_node("HudInspecao") as Control).get_global_rect().intersects((jogo.get_node("IntencaoValorVisualLabel") as Control).get_global_rect()), "inspecao da rota nao deve cobrir valor da intencao")
	(jogo.get("jogador_combate") as JogadorCombate).adicionar_reliquia("mecanismo_recuo")
	jogo.call("_atualizar_interface")
	_verificar(reliquias_topo.get_child_count() == 3, "tres reliquias devem gerar tres icones")
	_verificar((reliquias_topo.get_child(0) as Button).icon != null, "cada reliquia deve usar um icone")
	_verificar((reliquias_topo.get_child(2) as Button).focus_mode != Control.FOCUS_NONE, "cada icone deve aceitar foco")
	(jogo.get("jogador_combate") as JogadorCombate).reliquias_run.clear()
	for id_reliquia in ["juntas_retorno", "reservatorio_auxiliar", "mecanismo_recuo"]:
		(jogo.get("jogador_combate") as JogadorCombate).adicionar_reliquia(id_reliquia)
	jogo.call("_atualizar_interface")
	_verificar(reliquias_topo.get_child_count() == 3, "varias reliquias devem caber na sequencia")
	_verificar(not reliquias_topo.get_global_rect().intersects((jogo.get_node("TopoCombate/TopoConfiguracoes") as Control).get_global_rect()), "varias reliquias nao devem invadir configuracoes")
	_verificar((jogo.call("_texto_inspecao_hud", reliquias_topo.get_child(1)) as String).contains("Reservatório Auxiliar"), "inspecao deve mostrar somente a reliquia focada")
	_verificar(not (jogo.call("_texto_inspecao_hud", reliquias_topo.get_child(1)) as String).contains("Juntas de Retorno"), "inspecao individual nao deve listar outras reliquias")
	jogo.call("_mostrar_inspecao_hud", reliquias_topo.get_child(1))
	_verificar((jogo.get_node("HudInspecao/Texto") as Label).text.contains("Reservatório Auxiliar"), "hover/foco do icone deve abrir a inspeção individual")
	jogo.call("_mostrar_inspecao_hud", reliquias_topo.get_child(2))
	await get_tree().process_frame
	var texto_reliquias: Label = jogo.get_node("HudInspecao/Texto") as Label
	_verificar(texto_reliquias.text.contains("Mecanismo de Recuo"), "inspecao deve seguir o terceiro icone")
	_verificar(not texto_reliquias.text.contains("Juntas de Retorno"), "inspecao nao deve voltar a listar todas as reliquias")
	_verificar(not (jogo.get_node("HudInspecao") as Control).get_global_rect().intersects((jogo.get_node("TopoCombate/TopoVida") as Control).get_global_rect()), "inspecao de reliquias nao deve cobrir vida no cabecalho")
	_verificar(not (jogo.get_node("HudInspecao") as Control).get_global_rect().intersects((jogo.get_node("Jogador") as Control).get_global_rect()), "inspecao de reliquias nao deve cobrir Vega")

	(jogo.get_node("TopoCombate/TopoBaralho") as Button).pressed.emit()
	_verificar((jogo.get_node("BaralhoOverlay") as Control).visible, "baralho completo deve abrir pela janela existente")
	_verificar((jogo.get_node("BaralhoOverlay/BaralhoResumo") as Label).text.contains("12 cartas"), "baralho deve usar a run real")
	(jogo.get_node("BaralhoOverlay/BaralhoFechar") as Button).pressed.emit()
	_verificar(not (jogo.get_node("BaralhoOverlay") as Control).visible, "baralho deve poder fechar no combate")

	(jogo.get_node("TopoCombate/TopoConfiguracoes") as Button).pressed.emit()
	_verificar((jogo.get_node("ConfiguracoesOverlay") as Control).visible, "menu de configuracoes deve abrir")
	_verificar((jogo.get_node("ConfiguracoesOverlay/Som") as Button).text.contains("SOM"), "menu deve ter controle de audio")
	var indice_master: int = AudioServer.get_bus_index("Master")
	var mute_antes: bool = AudioServer.is_bus_mute(indice_master)
	(jogo.get_node("ConfiguracoesOverlay/Som") as Button).pressed.emit()
	_verificar(AudioServer.is_bus_mute(indice_master) != mute_antes, "controle de som deve alterar o bus Master")
	(jogo.get_node("ConfiguracoesOverlay/Som") as Button).pressed.emit()
	(jogo.get_node("ConfiguracoesOverlay/Fechar") as Button).pressed.emit()
	_verificar(not (jogo.get_node("ConfiguracoesOverlay") as Control).visible, "menu de configuracoes deve fechar")

	jogo.call("_limpar_mao")
	for indice in range(10):
		jogo.call("_criar_carta_na_mao", "golpe")
	jogo.call("_atualizar_interface")
	_verificar((jogo.get_node("MaoStatusLabel") as Control).visible, "limite da mao deve aparecer ao ficar cheia")
	_verificar((jogo.get_node("MaoStatusLabel") as Label).text.contains("10/10"), "aviso de mao cheia deve mostrar o limite real")

	jogo.queue_free()
	if falhas == 0:
		print("OK: HUD R3")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
