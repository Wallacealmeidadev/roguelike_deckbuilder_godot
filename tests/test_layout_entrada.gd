extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		await get_tree().process_frame
		await _verificar_cena("res://ui_entrada/menu_principal.tscn", "PainelPrincipal", ["NovaRunButton", "SairButton"], resolucao)
		await _verificar_cena("res://ui_entrada/selecao_personagem.tscn", "PainelSelecao", ["VoltarButton", "ConfirmarButton"], resolucao)
	_terminar()


func _verificar_cena(caminho: String, nome_painel: String, nomes_botoes: Array[String], resolucao: Vector2i) -> void:
	var cena: PackedScene = load(caminho) as PackedScene
	var tela: Control = cena.instantiate() as Control
	get_tree().root.add_child(tela)
	await get_tree().process_frame
	await get_tree().process_frame
	var limite: Rect2 = Rect2(Vector2.ZERO, Vector2(resolucao))
	var painel: Control = tela.find_child(nome_painel, true, false) as Control
	_verificar(_dentro(painel.get_global_rect(), limite), "%s: painel %s deve caber em %s; viewport=%s" % [caminho, painel.get_global_rect(), resolucao, get_viewport().get_visible_rect()])
	for nome: String in nomes_botoes:
		var botao: Button = tela.find_child(nome, true, false) as Button
		_verificar(_dentro(botao.get_global_rect(), limite), "%s: %s %s deve caber em %s" % [caminho, nome, botao.get_global_rect(), resolucao])
		_verificar(botao.size.y >= 44.0, "%s: %s deve ter altura clicavel" % [caminho, nome])
	if nome_painel == "PainelSelecao":
		var arte: TextureRect = tela.find_child("VegaArte", true, false) as TextureRect
		var info: Control = tela.find_child("Informacoes", true, false) as Control
		_verificar(arte.get_global_rect().end.x < info.get_global_rect().position.x, "arte e informacoes nao devem se sobrepor")
		_verificar(_dentro(arte.get_global_rect(), limite), "arte deve caber em %s" % resolucao)
	else:
		var titulo: Label = tela.find_child("TituloSecundario", true, false) as Label
		_verificar(_dentro(titulo.get_global_rect(), limite), "titulo deve caber em %s" % resolucao)
	tela.queue_free()
	await get_tree().process_frame


func _dentro(retangulo: Rect2, limite: Rect2) -> bool:
	return retangulo.position.x >= -1.0 and retangulo.position.y >= -1.0 and retangulo.end.x <= limite.end.x + 1.0 and retangulo.end.y <= limite.end.y + 1.0


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)


func _terminar() -> void:
	print("LAYOUT ENTRADA: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)
