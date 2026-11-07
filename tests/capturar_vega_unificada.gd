extends SceneTree
## Prova estática de direção artística. Não troca a cena usada por F5.

const PASTA: String = "res://docs/evidencias_vega_unificada_01"
const ARTE: String = "res://docs/arte_vega/vega_guarda_unificada_01.png"
var jogo: Control
var falhas: int = 0


func _initialize() -> void:
	call_deferred("_executar")


func _executar() -> void:
	DirAccess.make_dir_recursive_absolute(PASTA)
	var imagem: Image = Image.load_from_file(ARTE)
	if imagem == null or imagem.is_empty():
		push_error("Não foi possível abrir a candidata: " + ARTE)
		quit(1)
		return
	var recorte: Rect2i = imagem.get_used_rect()
	var textura: ImageTexture = ImageTexture.create_from_image(imagem)
	jogo = (load("res://main.tscn") as PackedScene).instantiate() as Control
	root.add_child(jogo)
	await process_frame
	for resolucao: Vector2i in [Vector2i(1920, 1080), Vector2i(1024, 576)]:
		root.size = resolucao
		root.content_scale_size = resolucao
		jogo.call("_sincronizar_viewport_com_janela")
		jogo.call("_iniciar_combate_por_id", "drone_carga", false)
		jogo.movimento_reduzido = true
		jogo.call("_atualizar_interface")
		await create_timer(.4).timeout
		var vega: VegaCombateNativo = jogo.vega_animada as VegaCombateNativo
		await _foto("atual_%d" % resolucao.x)
		var modelo: ApoioCorporalNativoV2 = vega.modelo
		var base: Vector2 = vega.composicao.get_global_transform() * modelo.to_global(Vector2(365, 850))
		var altura: float = 820 * modelo.scale.y
		var candidata: Sprite2D = Sprite2D.new()
		candidata.texture = textura
		candidata.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		candidata.centered = false
		candidata.scale = Vector2.ONE * altura / recorte.size.y
		candidata.position = base - Vector2(recorte.position.x + recorte.size.x * .5, recorte.end.y) * candidata.scale
		jogo.add_child(candidata)
		# Esconde a composição original somente na instância deste capturador.
		# Sombras de contato ficam no piso para comparar o mesmo enquadramento.
		vega.visual.hide()
		await _foto("candidata_estatica_%d" % resolucao.x)
		print("CANDIDATA ESTATICA %d: altura %.1f px, arte %s, alfa canto %.1f" % [resolucao.x, altura, imagem.get_size(), imagem.get_pixel(0, 0).a])
		candidata.queue_free()
		vega.visual.show()
		await process_frame
	jogo.queue_free()
	await process_frame
	quit(0 if falhas == 0 else 1)


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var erro: Error = root.get_texture().get_image().save_png("%s/%s.png" % [PASTA, nome])
	if erro != OK:
		falhas += 1
	print("CAPTURA UNIFICADA %s: %s" % [nome, error_string(erro)])
