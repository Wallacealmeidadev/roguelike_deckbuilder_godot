extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame

	_verificar(jogo.get("roteiro_run").etapa_atual() == "combate_comum", "a run deve começar em combate comum")
	_verificar(jogo.get("combate_atual") == 1, "o primeiro combate deve ser o combate 1")
	_verificar(jogo.get("baralho_run").size() == 12, "o baralho inicial deve ter 12 cartas")
	_verificar(jogo.has_method("_resolver_vitoria"), "a vitória deve abrir a recompensa comum")
	_verificar(jogo.has_method("_escolher_recompensa"), "a recompensa deve entrar no baralho")

	jogo.set("vida_jogador", 31)
	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")

	var recompensas: GridContainer = jogo.get_node("Recompensas") as GridContainer
	var oferta: OfertaRecompensa = jogo.get("oferta_recompensa") as OfertaRecompensa
	_verificar(jogo.get("aguardando_recompensa"), "a vitória deve aguardar a escolha")
	_verificar(recompensas.visible, "as recompensas devem aparecer")
	_verificar(oferta.opcoes.size() == 3, "a oferta deve ter três opções")
	_verificar(not (jogo.get_node("Mao") as Control).visible, "a mão deve esconder durante recompensa")

	var id_escolhido: String = oferta.opcoes[0]
	var tamanho_anterior: int = jogo.get("baralho_run").size()
	(jogo.get_node("Recompensas/RecompensaOpcao1") as Button).pressed.emit()

	_verificar(jogo.get("baralho_run").size() == tamanho_anterior + 1, "a carta escolhida deve persistir")
	_verificar(jogo.get("baralho_run").has(id_escolhido), "a opção escolhida deve entrar no baralho")
	_verificar(jogo.get("roteiro_run").etapa_atual() == "evento", "a recompensa deve levar ao evento")
	_verificar((jogo.get_node("EventoOverlay") as Control).visible, "o evento seguinte deve aparecer")
	_verificar(not recompensas.visible, "a recompensa deve esconder ao avançar")
	_verificar(jogo.get("vida_jogador") == 31, "a Vida deve persistir entre etapas")

	jogo.queue_free()

	if falhas == 0:
		print("OK: recompensa no fluxo intercalado")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
