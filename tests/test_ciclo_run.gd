extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame

	_verificar(jogo.get("mapa_gerado") == true, "a run deve gerar o mapa ao iniciar")
	_verificar((jogo.get_node("MapaOverlay") as Control).visible, "a run deve começar no mapa")
	_verificar(jogo.get("combate_atual") == 0, "nenhum combate deve ser contado antes de escolher o início")
	_verificar((jogo.get("baralho_run") as Array[String]).size() == 12, "o baralho inicial deve ter 12 cartas")

	jogo.call("_ao_selecionar_no_mapa", "inicio")
	_verificar(jogo.get("combate_atual") == 1, "o primeiro nó de combate deve ser numerado como 1")
	_verificar(jogo.has_method("_resolver_vitoria"), "a vitória deve abrir a recompensa comum")

	jogo.set("vida_jogador", 31)
	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	var recompensas: Control = jogo.get_node("Recompensas") as Control
	var oferta: OfertaRecompensa = jogo.get("oferta_recompensa") as OfertaRecompensa
	_verificar(jogo.get("aguardando_recompensa") == true, "a vitória deve aguardar a escolha")
	_verificar(recompensas.visible, "as recompensas devem aparecer")
	_verificar(oferta.opcoes.size() == 3, "a oferta deve ter três opções")

	var id_escolhido: String = oferta.opcoes[0]
	var tamanho_anterior: int = (jogo.get("baralho_run") as Array[String]).size()
	(jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao1") as Button).pressed.emit()
	(jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao1") as Button).pressed.emit()

	_verificar((jogo.get("baralho_run") as Array[String]).size() == tamanho_anterior + 1, "a carta escolhida deve persistir uma vez")
	_verificar((jogo.get("baralho_run") as Array[String]).has(id_escolhido), "a opção escolhida deve entrar no baralho")
	_verificar((jogo.get("mapa_pontos_concluidos") as Array[String]).has("inicio"), "o combate inicial deve ser concluído após a recompensa")
	_verificar((jogo.get_node("MapaOverlay") as Control).visible, "o mapa deve voltar depois da recompensa")
	_verificar(jogo.get("vida_jogador") == 31, "a Vida deve persistir entre encontros")

	jogo.queue_free()

	if falhas == 0:
		print("OK: ciclo de run pelo mapa")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
