extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var cena: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Control = cena.instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	await get_tree().process_frame

	jogo.call("_limpar_mao")
	jogo.call("_criar_carta_na_mao", "golpe")
	var carta: Button = (jogo.get_node("Mao") as Control).get_child(0) as Button
	carta.button_pressed = true
	_verificar(carta.get_node("Foco").visible, "selecionar carta deve mostrar foco")
	var energia_inicial: int = jogo.get("energia")
	var vida_inimigo_inicial: int = jogo.get("vida_inimigo")
	(jogo.get_node("Jogador") as Button).pressed.emit()
	_verificar(jogo.get("energia") == energia_inicial, "alvo inválido não deve gastar Energia")
	_verificar(jogo.get("vida_inimigo") == vida_inimigo_inicial, "alvo inválido não deve causar dano")
	(jogo.get_node("Alvo") as Button).pressed.emit()
	_verificar(jogo.get("energia") == energia_inicial - 1, "clicar no inimigo deve gastar o custo")
	_verificar(jogo.get("vida_inimigo") < vida_inimigo_inicial, "clicar no inimigo deve causar dano")
	_verificar((jogo.get_node("Mao") as Control).get_child_count() == 0, "carta usada deve sair da mão")

	var turno_inicial: int = jogo.get("turno")
	(jogo.get_node("EncerrarTurno") as Button).pressed.emit()
	_verificar(jogo.get("turno") == turno_inicial + 1, "botão deve avançar o turno")
	_verificar(jogo.get("energia") == 4, "turno novo deve restaurar Energia")

	jogo.call("_limpar_mao")
	jogo.call("_criar_carta_na_mao", "golpe")
	var golpe_final: Button = (jogo.get_node("Mao") as Control).get_child(0) as Button
	golpe_final.button_pressed = true
	jogo.set("vida_inimigo", 1)
	(jogo.get_node("Alvo") as Button).pressed.emit()
	_verificar((jogo.get_node("Recompensas") as Control).visible, "vitória deve abrir recompensa")
	_verificar(not (jogo.get_node("EncerrarTurno") as Control).visible, "vitória deve ocultar botão de turno")
	jogo.queue_free()

	var derrota: Control = cena.instantiate() as Control
	get_tree().root.add_child(derrota)
	await get_tree().process_frame
	derrota.call("_ao_selecionar_no_mapa", "inicio")
	await get_tree().process_frame
	(derrota.get("encontro_combate") as EncontroCombate).inimigo = InimigoCombate.new(
		"drone_seguranca", DadosInimigos.obter("drone_seguranca")
	)
	derrota.set("vida_jogador", 1)
	(derrota.get_node("EncerrarTurno") as Button).pressed.emit()
	_verificar((derrota.get_node("ResultadoLabel") as Label).text.contains("DERROTA"), "derrota deve mostrar resultado")
	_verificar(not (derrota.get_node("EncerrarTurno") as Control).visible, "derrota deve ocultar botão de turno")
	derrota.queue_free()

	if falhas == 0:
		print("OK: interações do HUD de combate")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
