extends SceneTree
var jogo: Node
var quadro: int = 0
func _initialize() -> void:
	call_deferred("capturar")
func capturar() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/evidencias_vega/frames")
	jogo = load("res://main.tscn").instantiate()
	root.add_child(jogo)
	root.size = Vector2i(1024, 576)
	await process_frame
	jogo._iniciar_combate_por_id("drone_carga", false)
	await foto("repouso_1024")
	jogo._limpar_mao()
	jogo.baralho_combate.compra.assign(["golpe", "protecao", "golpe"])
	jogo._comprar_cartas(3)
	await frames(18)
	for carta: Button in jogo.mao.get_children():
		if carta.get_meta("id_carta") == "golpe":
			carta.button_pressed = true
			jogo._jogar_carta("inimigo", 0)
			break
	await frames(16)
	jogo._iniciar_combate_por_id("caranguejo_sucata", false)
	jogo._executar_intencao_inimigo()
	await frames(16)
	root.size = Vector2i(1920, 1080)
	jogo._sincronizar_viewport_com_janela()
	jogo._layout_hud_combate()
	await foto("repouso_1920")
	jogo.vega_animada.socar()
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/evidencias_vega/soco_1920.png")
	jogo.vega_animada.receber_dano()
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/evidencias_vega/dano_1920.png")
	jogo.queue_free()
	await process_frame
	quit()
func foto(nome: String) -> void:
	await create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/evidencias_vega/%s.png" % nome)
func frames(total: int) -> void:
	for i in total:
		await create_timer(0.05).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/evidencias_vega/frames/%03d.png" % quadro)
		quadro += 1
