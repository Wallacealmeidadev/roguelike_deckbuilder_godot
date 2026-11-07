extends SceneTree

## Captura os componentes reais: nenhuma substituição de textura nesta execução.
const PASTA: String = "res://docs/evidencias_catalogo_cartas_hq"
const IDS: Array[String] = ["golpe", "protecao", "direto_hidraulico", "quebra_chassi", "brecha", "pulso_debilitante", "golpe_ariete", "ruptura_pressao", "placa_reforcada"]
var jogo: Control
var fichas: Array[Dictionary] = []
var falhas: int = 0


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute(PASTA)
	jogo = (load("res://main.tscn") as PackedScene).instantiate() as Control
	root.add_child(jogo)
	await process_frame
	for resolucao: Vector2i in [Vector2i(1920, 1080), Vector2i(1024, 576)]:
		root.size = resolucao
		jogo.call("_sincronizar_viewport_com_janela")
		jogo.call("_iniciar_combate_por_id", "drone_seguranca", false)
		jogo.call("_limpar_mao")
		# Fixture visual: uma cópia de cada carta, sem alterar compras/regras.
		for id_carta: String in IDS:
			jogo.call("_criar_carta_na_mao", id_carta)
		jogo.call("_atualizar_interface")
		root.gui_release_focus()
		var mouse: InputEventMouseMotion = InputEventMouseMotion.new()
		mouse.position = Vector2(5, 5)
		root.push_input(mouse, true)
		await create_timer(0.6).timeout
		var mao: Control = jogo.get_node("Mao") as Control
		if fichas.is_empty():
			for carta: Node in mao.get_children():
				fichas.append({"nome": str(carta.get("nome_carta")), "custo": int(carta.get("custo")), "descricao": str(carta.get("descricao"))})
		await _foto("mao_%d" % resolucao.x)
		for indice: int in IDS.size():
			var carta: Button = mao.get_child(indice) as Button
			carta.grab_focus()
			await create_timer(0.25).timeout
			await _foto("%s_%d" % [IDS[indice], resolucao.x], carta)
		root.gui_release_focus()
	jogo.queue_free()
	await process_frame
	await _prancha()
	quit(1 if falhas > 0 else 0)


func _prancha() -> void:
	root.size = Vector2i(960, 1000)
	root.content_scale_size = root.size
	var fundo: ColorRect = ColorRect.new()
	fundo.color = Color("#08121f")
	fundo.size = Vector2(960, 1000)
	fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(fundo)
	var cena_carta: PackedScene = load("res://carta.tscn") as PackedScene
	for indice: int in IDS.size():
		var carta: Button = cena_carta.instantiate() as Button
		carta.set("nome_carta", fichas[indice]["nome"])
		carta.set("custo", fichas[indice]["custo"])
		carta.set("descricao", fichas[indice]["descricao"])
		fundo.add_child(carta)
		carta.call("configurar_escala", 1.2, true)
		carta.position = Vector2(100 + (indice % 3) * 285, 34 + (indice / 3) * 320)
		var dados: Dictionary = preload("res://dados_cartas.gd").CARTAS[IDS[indice]]
		carta.call("aplicar_visual", IDS[indice], str(dados["tipo"]))
		carta.mouse_filter = Control.MOUSE_FILTER_IGNORE
		carta.focus_mode = Control.FOCUS_NONE
	await process_frame
	await _foto("catalogo_completo")
	fundo.queue_free()
	await process_frame


func _foto(nome: String, carta: Control = null) -> void:
	await RenderingServer.frame_post_draw
	var quadro: Image = root.get_texture().get_image()
	_salvar(quadro, "%s/%s.png" % [PASTA, nome])
	if carta != null:
		var origem: Vector2 = carta.get_global_transform_with_canvas() * Vector2.ZERO
		var fim: Vector2 = carta.get_global_transform_with_canvas() * carta.size
		var limites: Rect2i = Rect2i(Rect2(origem.floor(), (fim - origem).ceil()))
		var viewport: Rect2i = Rect2i(Vector2i.ZERO, quadro.get_size())
		if not viewport.encloses(limites):
			falhas += 1
			push_error("Carta fora da captura: %s" % nome)
		_salvar(quadro.get_region(limites.intersection(viewport)), "%s/%s_carta.png" % [PASTA, nome])


func _salvar(imagem: Image, caminho: String) -> void:
	var erro: Error = imagem.save_png(caminho)
	if erro != OK:
		falhas += 1
	print("CAPTURA %s: %s" % [caminho, error_string(erro)])
