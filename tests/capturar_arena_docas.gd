extends SceneTree

var jogo: Node

func _initialize() -> void:
	call_deferred("capturar")

func capturar() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/evidencias_arena_docas")
	jogo = load("res://main.tscn").instantiate()
	root.add_child(jogo)
	root.size = Vector2i(1024, 576)
	await process_frame
	jogo._iniciar_combate_por_id("drone_carga", false)
	await foto("combate_1024")
	await mover(jogo.energia_painel.get_global_rect().get_center())
	await foto("hover_energia_1024")
	await mover(jogo.topo_reliquias.get_child(0).get_global_rect().get_center())
	await foto("hover_reliquia_1024")
	await mover(Vector2(600, 190))
	jogo.topo_baralho.pressed.emit()
	await foto("baralho_1024")
	jogo._fechar_consulta_baralho()
	root.gui_release_focus()
	jogo.hud_inspecao.esconder()
	root.size = Vector2i(1920, 1080)
	jogo._sincronizar_viewport_com_janela()
	jogo._layout_hud_combate()
	await mover(Vector2(900, 600))
	await foto("combate_1920")
	await mover(jogo.botao_encerrar_turno.get_global_rect().get_center())
	await foto("hover_turno_1920")
	jogo._iniciar_combate_por_id("dois_caranguejos", false)
	await foto("dupla_1920")
	jogo._iniciar_nova_run()
	await foto("mapa_1920")
	assert(not jogo.arena_chao.is_visible_in_tree(), "Arena de combate permaneceu no mapa")
	jogo.queue_free()
	await process_frame
	quit()

func mover(posicao: Vector2) -> void:
	var evento: InputEventMouseMotion = InputEventMouseMotion.new()
	evento.position = posicao
	evento.global_position = posicao
	root.push_input(evento)
	await process_frame

func foto(nome: String) -> void:
	await create_timer(0.35).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/evidencias_arena_docas/%s.png" % nome)
