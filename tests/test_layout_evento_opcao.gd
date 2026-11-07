extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Node = (load("res://main.tscn") as PackedScene).instantiate()
	add_child(jogo)
	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	await get_tree().process_frame
	jogo.call("_mostrar_evento", "turno_encerrado")
	await get_tree().process_frame
	var valvula_opcoes: Control = jogo.get_node("EventoOverlay/EventoOpcoes") as Control
	var valvula_visiveis: Array[Button] = []
	for no_valvula in valvula_opcoes.get_children():
		var opcao_valvula: Button = no_valvula as Button
		if opcao_valvula != null and opcao_valvula.visible:
			valvula_visiveis.append(opcao_valvula)
	_verificar(valvula_visiveis.size() == 3, "ponto da queda deve exibir tres opcoes")
	_verificar((valvula_visiveis[2].get_node("Conteudo/Linha/Textos/Detalhe") as Control).visible == false, "a opcao sem detalhe deve ocultar o detalhe")
	var acao_isolada: Control = valvula_visiveis[2].get_node("Conteudo/Linha/Textos/Acao") as Control
	var textos_isolados: Control = valvula_visiveis[2].get_node("Conteudo/Linha/Textos") as Control
	_verificar(abs(acao_isolada.get_global_rect().get_center().y - textos_isolados.get_global_rect().get_center().y) <= 1.0, "titulo isolado deve ficar centralizado verticalmente")
	var textos_com_detalhe: Control = valvula_visiveis[0].get_node("Conteudo/Linha/Textos") as Control
	_verificar((textos_com_detalhe.get_node("Acao") as Control).custom_minimum_size.y >= 34.0, "titulo deve reservar altura para acentos Bangers")
	_verificar((textos_com_detalhe.get_node("Detalhe") as Control).custom_minimum_size.y >= 22.0, "detalhe deve reservar altura legivel")
	_verificar(textos_com_detalhe.get_combined_minimum_size().y >= 60.0, "duas linhas devem incluir espacamento vertical")
	_verificar(valvula_visiveis[0].custom_minimum_size.y >= 100.0, "botao deve propagar altura do conjunto vertical")
	jogo.call("_mostrar_evento", "ninho_sob_cais")
	await get_tree().process_frame

	var opcoes: Control = jogo.get_node("EventoOverlay/EventoOpcoes") as Control
	var estados: Array[Button] = []
	for no in opcoes.get_children():
		var opcao: Button = no as Button
		if opcao != null and opcao.visible:
			estados.append(opcao)

	_verificar(estados.size() == 3, "o evento deve exibir as tres opcoes reais")
	for opcao in estados:
		_verificar(opcao.has_node("Conteudo"), "a opcao deve ter MarginContainer interno")
		_verificar(opcao.has_node("Conteudo/Linha"), "a opcao deve ter HBox interno")
		_verificar(opcao.has_node("Conteudo/Linha/Textos"), "a opcao deve ter VBox de textos")
		_verificar(opcao.has_node("Conteudo/Linha/TipoIcone"), "o icone deve estar no HBox")
		_verificar(opcao.has_node("Conteudo/Linha/Seta"), "a seta deve estar no HBox")
		var area_botao: Rect2 = opcao.get_global_rect().grow(-2.0)
		var area_segura: Rect2 = (opcao.get_node("Conteudo") as Control).get_global_rect()
		_verificar(area_botao.encloses(area_segura), "a area segura deve ficar dentro da moldura logica")
		for caminho in ["Conteudo/Linha/Textos/Acao", "Conteudo/Linha/Textos/Detalhe", "Conteudo/Linha/Seta"]:
			var controle: Control = opcao.get_node(caminho) as Control
			if controle.visible:
				_verificar(area_segura.grow(0.5).encloses(controle.get_global_rect()), "%s deve ficar na area segura" % caminho)

	var combate: Button = estados[2]
	var tamanho_normal: Vector2 = combate.size
	var interacao_normal: Rect2 = (combate.get_node("Interacao") as Control).get_global_rect()
	combate.grab_focus()
	await get_tree().process_frame
	_verificar(combate.size.is_equal_approx(tamanho_normal), "foco nao deve alterar o tamanho")
	var interacao_foco: Rect2 = (combate.get_node("Interacao") as Control).get_global_rect()
	_verificar(interacao_foco.position.distance_to(interacao_normal.position) <= 0.1 and interacao_foco.size.distance_to(interacao_normal.size) <= 0.1, "foco nao deve deslocar o destaque")
	_verificar((combate.get_node("Conteudo") as Control).size.x > 0.0, "conteudo deve ter largura apos foco")
	var opcoes_com_tres: Control = jogo.get_node("EventoOverlay/EventoOpcoes") as Control
	_verificar(opcoes_com_tres.size.y >= opcoes_com_tres.get_combined_minimum_size().y, "container deve acomodar tres opcoes")
	combate.release_focus()
	get_viewport().gui_release_focus()

	jogo.queue_free()
	if falhas == 0:
		print("OK: layout interno da opcao de evento")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
