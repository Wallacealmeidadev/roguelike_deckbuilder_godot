extends Node

var falhas: int = 0

func _ready() -> void:
	var jogo: Node = (load("res://main.tscn") as PackedScene).instantiate()
	add_child(jogo)
	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	await get_tree().process_frame

	var opcao: Button = jogo.get_node("EventoOverlay/EventoOpcoes/EventoOpcao1") as Button
	var hover: StyleBox = opcao.get_theme_stylebox("hover")
	var foco: StyleBox = opcao.get_theme_stylebox("focus")
	_verificar(hover is StyleBoxTexture, "hover deve reutilizar a moldura HQ base")
	_verificar(foco is StyleBoxTexture, "focus deve reutilizar a moldura HQ base")
	_verificar(opcao.get_theme_stylebox("hover") == opcao.get_theme_stylebox("normal"), "hover deve preservar a moldura base")
	_verificar(opcao.get_theme_stylebox("focus") == opcao.get_theme_stylebox("normal"), "focus deve preservar a moldura base")
	_verificar(opcao.has_node("Interacao"), "destaque deve ser uma camada separada")
	_verificar(opcao.has_node("Conteudo/Linha/Textos"), "opcao deve ter layout interno")
	jogo.call("_mostrar_evento", "posto_inspecao")
	await get_tree().process_frame
	for no_evento in (jogo.get_node("EventoOverlay/EventoOpcoes") as Control).get_children():
		var opcao_visivel: Button = no_evento as Button
		if opcao_visivel == null or not opcao_visivel.visible:
			continue
		var area_util: Rect2 = opcao_visivel.get_global_rect().grow(-4.0)
		var area_segura: Rect2 = (opcao_visivel.get_node("Conteudo") as Control).get_global_rect()
		_verificar(area_util.encloses(area_segura), "area interna deve permanecer dentro da opcao")
		_verificar(area_segura.encloses((opcao_visivel.get_node("Conteudo/Linha/Textos/Acao") as Control).get_global_rect()), "titulo deve permanecer na area segura")
		if (opcao_visivel.get_node("Conteudo/Linha/Textos/Detalhe") as Control).visible:
			_verificar(area_segura.encloses((opcao_visivel.get_node("Conteudo/Linha/Textos/Detalhe") as Control).get_global_rect()), "detalhe deve permanecer na area segura")
			opcao_visivel.grab_focus()
			await get_tree().process_frame
			_verificar(opcao_visivel.get_theme_stylebox("hover") == opcao_visivel.get_theme_stylebox("normal"), "hover deve manter a moldura base")
			_verificar((opcao_visivel.get_node("Interacao") as Control).visible, "hover deve mostrar somente a camada ciano")
			opcao_visivel.release_focus()
			get_viewport().gui_release_focus()
	jogo.call("_ocultar_evento")

	jogo.call("_resolver_vitoria")
	await get_tree().process_frame
	var helper: Node = Node.new()
	helper.set_script(load("res://tests/preview_fluxo.gd"))
	helper.call("_configurar_oferta_conhecida", jogo, true)
	jogo.call("_ao_clicar_recompensa", 1)
	await get_tree().process_frame
	var baralho_deterministico: Array[String] = ["brecha", "golpe", "protecao", "direto_hidraulico", "brecha", "golpe"]
	jogo.set("baralho_run", baralho_deterministico)
	jogo.call("_mostrar_evento", "posto_inspecao")
	jogo.call("_ao_escolher_evento", 0)
	await get_tree().process_frame
	await get_tree().process_frame

	var encontrou_brecha: Button = null
	for no in (jogo.get_node("Mao") as Control).get_children():
		var carta: Button = no as Button
		if carta != null and str(carta.get_meta("id_carta", "")) == "brecha":
			encontrou_brecha = carta
			break
	_verificar(encontrou_brecha != null, "Brecha adquirida deve chegar a mao")
	if encontrou_brecha != null:
		_verificar(not encontrou_brecha.disabled, "Brecha na mao nao deve estar desabilitada")
		_verificar(encontrou_brecha.modulate.is_equal_approx(Color.WHITE), "Brecha na mao nao deve estar escurecida")
		_verificar(encontrou_brecha.self_modulate.is_equal_approx(Color.WHITE), "Brecha na mao nao deve estar escurecida por self_modulate")
		_verificar(int(encontrou_brecha.get("custo")) == 1, "Brecha deve preservar custo 1")
		_verificar(jogo.get("energia") == 4, "Brecha deve chegar com 4 de Energia")
		jogo.call("_criar_carta_na_mao", "brecha")
		var direta: Button = (jogo.get_node("Mao") as Control).get_child((jogo.get_node("Mao") as Control).get_child_count() - 1) as Button
		_verificar(str(direta.get_meta("id_carta", "")) == "brecha", "Brecha direta deve usar o mesmo identificador")
		_verificar(int(direta.get("custo")) == int(encontrou_brecha.get("custo")), "Brecha direta deve usar o mesmo custo")
		var antes: int = int(jogo.get("vida_inimigo"))
		encontrou_brecha.button_pressed = true
		jogo.call("_ao_clicar_no_alvo")
		_verificar(int(jogo.get("energia")) == 3, "jogar Brecha deve consumir 1 Energia")
		_verificar(int(jogo.get("vida_inimigo")) < antes, "jogar Brecha deve causar dano")

	helper.queue_free()
	jogo.queue_free()
	if falhas == 0:
		print("OK: regressoes de evento e Brecha")
		get_tree().quit(0)
	else:
		get_tree().quit(1)

func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
