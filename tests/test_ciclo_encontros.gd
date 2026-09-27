extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	await _testar_rota_completa(cena_principal)
	await _testar_combate_especial(cena_principal)
	await _testar_derrota(cena_principal)

	if falhas == 0:
		print("OK: ciclo de encontros pelo mapa")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _novo_jogo(cena_principal: PackedScene) -> Node:
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	return jogo


func _vencer_combate(jogo: Node, elite: bool = false) -> void:
	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	if elite:
		var reliquia: String = (jogo.get("oferta_reliquias") as OfertaRecompensa).opcoes[0]
		jogo.call("_escolher_recompensa_elite_reliquia", reliquia)
		var carta: String = (jogo.get("oferta_cartas_raras") as OfertaRecompensa).opcoes[0]
		jogo.call("_escolher_recompensa_elite_carta", carta)
	else:
		jogo.call("_ao_pular_recompensa")


func _concluir_evento(jogo: Node, indice: int) -> void:
	jogo.call("_ao_escolher_evento", indice)
	jogo.call("_ao_continuar_evento")


func _testar_rota_completa(cena_principal: PackedScene) -> void:
	var jogo: Node = await _novo_jogo(cena_principal)
	_verificar((jogo.get_node("MapaOverlay") as Control).visible, "a rota deve começar no mapa")

	jogo.call("_ao_selecionar_no_mapa", "inicio")
	_vencer_combate(jogo)
	jogo.call("_ao_selecionar_no_mapa", "desvio_evento")
	_concluir_evento(jogo, 1)
	_verificar(str(jogo.get("mapa_no_atual")) == "desvio_evento", "o evento do primeiro desvio deve concluir")

	jogo.call("_ao_selecionar_no_mapa", "unidade_contencao_portuaria")
	_verificar(jogo.get("combate_atual") == 2, "o elite deve contar a posição realmente percorrida")
	_vencer_combate(jogo, true)
	_verificar((jogo.get("mapa_pontos_concluidos") as Array[String]).has("unidade_contencao_portuaria"), "elite deve concluir após os dois prêmios")

	jogo.call("_ao_selecionar_no_mapa", "carga_abandonada")
	_concluir_evento(jogo, 0)
	jogo.call("_ao_selecionar_no_mapa", "descanso_estrutura")
	jogo.set("vida_jogador", 30)
	var descanso: Control = jogo.get_node("DescansoOverlay") as Control
	(descanso.get_node("Acoes/RecuperarPainel") as Button).pressed.emit()
	(descanso.get_node("Continuar") as Button).pressed.emit()
	_verificar((jogo.get("mapa_pontos_concluidos") as Array[String]).has("descanso_estrutura"), "descanso deve concluir antes de liberar o reencontro")

	jogo.call("_ao_selecionar_no_mapa", "ultimo_acesso")
	_concluir_evento(jogo, 0)
	jogo.call("_ao_selecionar_no_mapa", "lastro")
	var resultado: Label = jogo.get_node("ResultadoLabel") as Label
	_verificar(resultado.visible, "o ponto reservado deve apresentar o pré-chefe")
	_verificar(resultado.text.contains("PRE-CHEFE"), "a chegada ao ponto do chefe deve ser provisória")
	_verificar(not resultado.text.contains("RUN CONCLUÍDA"), "a run não deve simular vitória do chefe")
	_verificar(not (jogo.get("mapa_pontos_concluidos") as Array[String]).has("lastro"), "Lastro não deve ser marcado como concluído")
	# O ponto reservado nao pode ser reaberto nem virar um encontro jogavel.
	jogo.call("_abrir_mapa")
	jogo.call("_ao_selecionar_no_mapa", "lastro")
	_verificar((jogo.get_node("MapaOverlay") as Control).visible, "reabrir o mapa deve apenas mostrar o ponto reservado")
	_verificar(str(jogo.get("mapa_no_em_andamento")).is_empty(), "o ponto reservado nao deve ficar em andamento")
	jogo.queue_free()


func _testar_combate_especial(cena_principal: PackedScene) -> void:
	var jogo: Node = await _novo_jogo(cena_principal)
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	_vencer_combate(jogo)
	jogo.call("_ao_selecionar_no_mapa", "desvio_evento")
	jogo.call("_ao_escolher_evento", 0)
	_verificar(jogo.get("encontro_especial_pendente") == true, "evento especial deve preservar o vínculo com o nó de origem")
	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	jogo.call("_ao_continuar_evento")
	_verificar((jogo.get_node("MapaOverlay") as Control).visible, "combate especial deve retornar ao mapa")
	_verificar((jogo.get("mapa_pontos_concluidos") as Array[String]).has("desvio_evento"), "combate especial deve concluir o evento de origem")
	jogo.queue_free()


func _testar_derrota(cena_principal: PackedScene) -> void:
	var jogo: Node = await _novo_jogo(cena_principal)
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	jogo.set("vida_jogador", 1)
	jogo.call("_ao_encerrar_turno")
	var resultado: Label = jogo.get_node("ResultadoLabel") as Label
	_verificar(resultado.visible and resultado.text.contains("DERROTA"), "derrota deve encerrar a tentativa")
	_verificar(not (jogo.get_node("MapaOverlay") as Control).visible, "derrota não deve liberar destinos")
	jogo.queue_free()


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
