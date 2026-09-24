extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)

	await get_tree().process_frame

	var overlay: Control = jogo.get_node("EventoOverlay") as Control
	var recompensas: Control = jogo.get_node("Recompensas") as Control
	var recompensa_elite: Control = jogo.get_node("RecompensaElite") as Control
	var mao: HBoxContainer = jogo.get_node("Mao") as HBoxContainer
	var alvo: Button = jogo.get_node("Alvo") as Button
	var jogador: Button = jogo.get_node("Jogador") as Button

	_verificar(not overlay.visible, "overlay de evento começa oculto")
	jogo.call("_mostrar_evento", "operario_ferido")

	_verificar(overlay.visible, "overlay de evento aparece")
	_verificar(
		(jogo.get_node("EventoOverlay/EventoTitulo") as Label).text == "Operário ferido",
		"overlay deve mostrar o título do evento"
	)
	_verificar(
		(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button).visible,
		"primeira opção aparece"
	)
	_verificar(
		(jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao2") as Button).visible,
		"segunda opção aparece"
	)
	_verificar(
		not (jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao3") as Button).visible,
		"terceira opção fica oculta quando não existe"
	)
	_verificar(not recompensas.visible, "recompensa comum esconde durante evento")
	_verificar(not recompensa_elite.visible, "recompensa do elite esconde durante evento")
	_verificar(alvo.disabled, "alvo fica bloqueado durante evento")
	_verificar(jogador.disabled, "jogador fica bloqueado durante evento")
	for no in mao.get_children():
		_verificar((no as Button).disabled, "cartas ficam bloqueadas durante evento")

	jogo.call("_ocultar_evento")
	_verificar(not overlay.visible, "overlay esconde ao sair do evento")
	_verificar(mao.visible, "mão retorna ao sair do evento")
	_verificar(not alvo.disabled, "alvo retorna ao combate")
	_verificar(not jogador.disabled, "jogador retorna ao combate")

	jogo.queue_free()

	if falhas == 0:
		print("OK: apresentação de eventos")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
