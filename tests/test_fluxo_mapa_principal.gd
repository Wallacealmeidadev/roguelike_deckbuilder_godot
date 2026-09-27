extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	await _testar_inicio_e_evento(cena_principal)
	await _testar_evento_combate(cena_principal)
	await _testar_descanso_em_variante(cena_principal)

	if falhas == 0:
		print("OK: fluxo principal do mapa")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _novo_jogo(cena_principal: PackedScene, variante: int = 0) -> Node:
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	if variante != 0:
		jogo.set("mapa_variante", variante)
		jogo.call("_iniciar_nova_run")
		await get_tree().process_frame
	return jogo


func _testar_inicio_e_evento(cena_principal: PackedScene) -> void:
	var jogo: Node = await _novo_jogo(cena_principal)
	var mapa: MapaRun = jogo.get("mapa_run") as MapaRun
	var overlay_mapa: Control = jogo.get_node("MapaOverlay") as Control
	var pontos: Control = jogo.get_node("MapaOverlay/MapaGrafo/MapaPontos") as Control

	_verificar(jogo.get("mapa_gerado") == true, "a run deve gerar o mapa uma vez ao iniciar")
	_verificar(overlay_mapa.visible, "a nova run deve começar no mapa")
	_verificar(str(jogo.get("mapa_no_atual")).is_empty(), "nenhum nó deve estar concluído no início")
	_verificar(
		str(jogo.get("mapa_no_em_andamento")).is_empty(),
		"nenhum nó deve estar em andamento no início"
	)
	var iniciais: Array[String] = mapa.nos_no_ponto(1)
	_verificar(iniciais.size() == 1, "o mapa deve expor somente o nó inicial")
	_verificar(_contar_botoes_habilitados(pontos) == 1, "somente o nó inicial deve estar disponível")

	jogo.call("_ao_selecionar_no_mapa", iniciais[0])
	_verificar(
		str(jogo.get("mapa_no_em_andamento")) == iniciais[0],
		"selecionar o início deve registrar o nó em andamento"
	)
	_verificar(not overlay_mapa.visible, "o mapa deve ocultar-se durante o encontro")
	var id_em_andamento: String = str(jogo.get("mapa_no_em_andamento"))
	jogo.call("_ao_selecionar_no_mapa", iniciais[0])
	_verificar(
		str(jogo.get("mapa_no_em_andamento")) == id_em_andamento,
		"selecionar duas vezes o mesmo nó não deve reiniciar o encontro"
	)

	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	var oferta: OfertaRecompensa = jogo.get("oferta_recompensa") as OfertaRecompensa
	var tamanho_antes: int = (jogo.get("baralho_run") as Array[String]).size()
	(jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao1") as Button).pressed.emit()
	(jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao1") as Button).pressed.emit()
	_verificar((jogo.get("baralho_run") as Array[String]).size() == tamanho_antes + 1, "recompensa comum deve resolver uma vez")
	_verificar(str(jogo.get("mapa_no_em_andamento")).is_empty(), "recompensa deve concluir o nó inicial")
	_verificar((jogo.get("mapa_pontos_concluidos") as Array[String]).has(iniciais[0]), "nó inicial deve ficar concluído")
	_verificar(overlay_mapa.visible, "após a recompensa o mapa deve voltar")
	_verificar(_contar_botoes_habilitados(pontos) == 2, "a bifurcação deve liberar dois destinos")

	jogo.call("_ao_selecionar_no_mapa", "desvio_evento")
	_verificar((jogo.get_node("EventoOverlay") as Control).visible, "um destino de evento deve abrir o evento")
	jogo.call("_ao_escolher_evento", 1)
	jogo.call("_ao_continuar_evento")
	_verificar(overlay_mapa.visible, "evento direto deve retornar ao mapa")
	_verificar((jogo.get("mapa_pontos_concluidos") as Array[String]).has("desvio_evento"), "evento direto deve concluir o nó")
	_verificar(str(jogo.get("mapa_no_atual")) == "desvio_evento", "o mapa deve ancorar no último nó concluído")

	jogo.queue_free()


func _testar_evento_combate(cena_principal: PackedScene) -> void:
	var jogo: Node = await _novo_jogo(cena_principal)
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	jogo.call("_ao_pular_recompensa")
	jogo.call("_ao_selecionar_no_mapa", "desvio_evento")
	jogo.call("_ao_escolher_evento", 0)
	_verificar(jogo.get("encontro_especial_pendente") == true, "evento especial deve preservar o vínculo com o nó de origem")
	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	jogo.call("_ao_continuar_evento")
	_verificar((jogo.get_node("MapaOverlay") as Control).visible, "combate especial deve retornar ao mapa após o resultado")
	_verificar((jogo.get("mapa_pontos_concluidos") as Array[String]).has("desvio_evento"), "evento com combate deve concluir o nó de origem")
	jogo.queue_free()


func _testar_descanso_em_variante(cena_principal: PackedScene) -> void:
	var jogo: Node = await _novo_jogo(cena_principal, 1)
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	jogo.call("_ao_pular_recompensa")
	jogo.call("_ao_selecionar_no_mapa", "descanso_inicial")
	jogo.set("vida_jogador", 30)
	var descanso: Control = jogo.get_node("DescansoOverlay") as Control
	_verificar(descanso.visible, "variante com descanso deve alcançar o descanso pelo mapa")
	(descanso.get_node("Acoes/RecuperarPainel") as Button).pressed.emit()
	(descanso.get_node("Continuar") as Button).pressed.emit()
	_verificar((jogo.get("mapa_pontos_concluidos") as Array[String]).has("descanso_inicial"), "descanso deve concluir o nó uma vez")
	_verificar((jogo.get_node("MapaOverlay") as Control).visible, "descanso deve retornar ao mapa")
	jogo.queue_free()


func _contar_botoes_habilitados(pontos: Control) -> int:
	var total: int = 0
	for botao_variant in pontos.get_children():
		var botao: Button = botao_variant as Button
		if botao != null and botao.has_meta("id_no") and not botao.disabled:
			total += 1
	return total


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
