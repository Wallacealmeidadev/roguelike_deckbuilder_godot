extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame

	_verificar(jogo.has_method("_dados_carta_token"), "o orquestrador deve resolver dados por token")
	if jogo.has_method("_dados_carta_token"):
		var dados_aprimorados: Dictionary = jogo.call("_dados_carta_token", "golpe#aprimorado")
		var dados_normais: Dictionary = jogo.call("_dados_carta_token", "golpe")
		_verificar(int(dados_aprimorados.get("valor", 0)) == 9, "Golpe aprimorado deve causar 9")
		_verificar(int(dados_normais.get("valor", 0)) == 6, "Golpe normal deve continuar causando 6")

	var deck: Array[String] = ["golpe#aprimorado"]
	jogo.set("baralho_run", deck)
	jogo.call("_iniciar_combate_por_id", "drone_seguranca", false)
	await get_tree().process_frame
	await get_tree().process_frame
	var mao: Control = jogo.get_node("Mao") as Control
	_verificar(mao.get_child_count() == 1, "o combate deve comprar a copia aprimorada")
	if mao.get_child_count() == 1:
		var carta: Button = mao.get_child(0) as Button
		_verificar(str(carta.get("descricao")).contains("9"), "a mao deve exibir o efeito aprimorado")

	if falhas == 0:
		print("OK: persistencia do aprimoramento")
		jogo.queue_free()
		get_tree().quit(0)
	else:
		jogo.queue_free()
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
