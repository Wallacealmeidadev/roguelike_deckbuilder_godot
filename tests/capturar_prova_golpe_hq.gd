extends SceneTree

## Prova visual isolada: não troca os recursos usados pelo jogo normal.
const PASTA: String = "res://docs/evidencias_golpe_hq"
const PROVA: String = "res://assets/ui/runtime/cartas/arte_golpe_vega_hq_prova.png"

var jogo: Control
var falhas: int = 0
var pasta: String = PASTA
var caminho_prova: String = PROVA
var id_carta_prova: String = "golpe"


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	if OS.get_cmdline_user_args().has("--impacto"):
		pasta = "res://docs/evidencias_golpe_impacto_hq"
		caminho_prova = "res://assets/ui/runtime/cartas/arte_golpe_impacto_hq_prova.png"
	elif OS.get_cmdline_user_args().has("--protecao"):
		pasta = "res://docs/evidencias_protecao_bloqueio_hq"
		caminho_prova = "res://assets/ui/runtime/cartas/arte_protecao_bloqueio_hq_prova.png"
		id_carta_prova = "protecao"
	elif OS.get_cmdline_user_args().has("--quebra-chassi"):
		pasta = "res://docs/evidencias_quebra_chassi_ruptura_hq"
		caminho_prova = "res://assets/ui/runtime/cartas/arte_quebra_chassi_ruptura_hq_prova.png"
		id_carta_prova = "quebra_chassi"
	DirAccess.make_dir_recursive_absolute(pasta)
	var imagem: Image = Image.load_from_file(caminho_prova)
	if imagem == null or imagem.is_empty():
		push_error("Não foi possível abrir a ilustração de prova.")
		quit(1)
		return
	var textura: ImageTexture = ImageTexture.create_from_image(imagem)
	jogo = (load("res://main.tscn") as PackedScene).instantiate() as Control
	root.add_child(jogo)
	await process_frame
	for resolucao: Vector2i in [Vector2i(1920, 1080), Vector2i(1024, 576)]:
		root.size = resolucao
		jogo.call("_sincronizar_viewport_com_janela")
		jogo.call("_iniciar_combate_por_id", "drone_seguranca", false)
		jogo.call("_limpar_mao")
		# Fixture de apresentação, sem alterar catálogo, compras ou dano.
		var ids_mao: Array[String] = ["protecao", "direto_hidraulico", "golpe", "quebra_chassi", "golpe", "protecao"]
		if id_carta_prova != "golpe":
			ids_mao[0] = "golpe"
			ids_mao[2] = id_carta_prova
		for id_carta: String in ids_mao:
			jogo.call("_criar_carta_na_mao", id_carta)
		jogo.call("_atualizar_interface")
		root.gui_release_focus()
		var mouse: InputEventMouseMotion = InputEventMouseMotion.new()
		mouse.position = Vector2(5, 5)
		root.push_input(mouse, true)
		await create_timer(0.5).timeout
		var mao: Control = jogo.get_node("Mao") as Control
		var carta: Button = mao.get_child(2) as Button
		for versao: String in ["atual", "prova"]:
			if versao == "prova":
				for filho: Node in mao.get_children():
					if str(filho.get("id_carta_visual")) == id_carta_prova:
						(filho.get_node("Arte") as TextureRect).texture = textura
			root.gui_release_focus()
			await create_timer(0.25).timeout
			await _foto("%s_mao_%d" % [versao, resolucao.x])
			carta.grab_focus()
			await create_timer(0.25).timeout
			await _foto("%s_foco_%d" % [versao, resolucao.x], carta)
			print("LEITURA %s %d: carta=%s arte=%s" % [versao, resolucao.x, carta.size, (carta.get_node("Arte") as Control).size])
	root.gui_release_focus()
	jogo.queue_free()
	await process_frame
	quit(1 if falhas > 0 else 0)


func _foto(nome: String, carta: Control = null) -> void:
	await RenderingServer.frame_post_draw
	var quadro: Image = root.get_texture().get_image()
	_salvar(quadro, "%s/%s.png" % [pasta, nome])
	if carta != null:
		# Recorte da captura real, sem redimensionar a arte ou simular a HUD.
		var origem: Vector2 = carta.get_global_transform_with_canvas() * Vector2.ZERO
		var fim: Vector2 = carta.get_global_transform_with_canvas() * carta.size
		var limites: Rect2i = Rect2i(Rect2(origem.floor(), (fim - origem).ceil()))
		limites = limites.intersection(Rect2i(Vector2i.ZERO, quadro.get_size()))
		_salvar(quadro.get_region(limites), "%s/%s_carta.png" % [pasta, nome])


func _salvar(imagem: Image, caminho: String) -> void:
	var erro: Error = imagem.save_png(caminho)
	if erro != OK:
		falhas += 1
	print("CAPTURA %s: %s" % [caminho, error_string(erro)])
