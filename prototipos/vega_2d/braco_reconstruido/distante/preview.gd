extends "res://prototipos/vega_2d/braco_reconstruido/preview_corpo.gd"
## Reutiliza a prancha diagnóstica, não cria outra interface de jogo.

const DISTANTE: PackedScene = preload("res://prototipos/vega_2d/braco_reconstruido/distante/vega_distante.tscn")
var candidata: VegaGuardaDistanteV1


func _ready() -> void:
	candidata = DISTANTE.instantiate() as VegaGuardaDistanteV1
	vega = candidata
	vega.size = Vector2(650, 850)
	vega.position = Vector2(80, 110)
	vega.scale = Vector2.ONE * .56
	add_child(vega)
	get_viewport().size_changed.connect(_layout)
	_layout()
	if "--capturar" in OS.get_cmdline_user_args():
		_capturar.call_deferred()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match (event as InputEventKey).keycode:
			KEY_A:
				candidata.comparar_distante(not candidata.ver_distante_anterior)
			KEY_O:
				candidata.mostrar_juntas(not candidata.novo_distante.mostrar_marcos)
			KEY_C:
				candidata.harmonizar_cor(0.0 if candidata.harmonizacao_cor > 0 else 1.0)
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-2000, -2000, 6000, 6000), Color("101722"))
	draw_string(FONTE, Vector2(48, 55), "VEGA / GUARDA DO BRAÇO DISTANTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("e7ecf2"))
	draw_string(FONTE, Vector2(48, 84), "Prova estática • vista interna própria • braço próximo aprovado preservado", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("97acbc"))
	if not is_instance_valid(candidata):
		return
	draw_string(FONTE, Vector2(560, 170), "DISTANTE ANTERIOR" if candidata.ver_distante_anterior else "DISTANTE / VISTA INTERNA", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("69d6e3"))
	draw_string(FONTE, Vector2(560, 216), "Palma fechada, fibra e placas da mesma fonte.", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("c3ced8"))
	draw_string(FONTE, Vector2(560, 252), "Guarda %d° / %d°; dobra interna de %d°." % [roundi(candidata.ombro_distante_guarda), roundi(candidata.cotovelo_distante_guarda), roundi(180 - candidata.cotovelo_distante_guarda)], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("97acbc"))
	draw_string(FONTE, Vector2(560, 354), "A: comparar somente o braço do fundo", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("c3ced8"))
	draw_string(FONTE, Vector2(560, 390), "O: conferir os centros das três juntas", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("c3ced8"))
	draw_string(FONTE, Vector2(560, 426), "C: paleta — " + ("harmonizada" if candidata.harmonizacao_cor > 0 else "original"), HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("c3ced8"))
	draw_string(FONTE, Vector2(560, 465), "Conferir pele–metal, cotovelo e raiz da palma.", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("97acbc"))
	draw_string(FONTE, Vector2(560, 493), "Sem socos nesta prova; avaliar a guarda primeiro.", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("97acbc"))
	draw_string(FONTE, Vector2(48, 626), "F5 e provas aprovadas intactos. Movimento distante, alternância e Combo não adaptados aqui.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("97acbc"))


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_distante_paleta_09"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var erro: Error = OK
	for harmonizada: bool in [true, false]:
		candidata.harmonizar_cor(1.0 if harmonizada else 0.0)
		queue_redraw()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var nome: String = "harmonizada" if harmonizada else "original"
		erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join(nome + ".png"))) as Error
		var desenho: SubViewport = candidata.composicao.get_node("Desenho") as SubViewport
		erro = maxi(erro, desenho.get_texture().get_image().save_png(pasta.path_join(nome + "_detalhe.png"))) as Error
	candidata.harmonizar_cor(1.0)
	candidata.mostrar_juntas(true)
	queue_redraw()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join("marcos.png"))) as Error
	candidata.mostrar_juntas(false)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var desenho: SubViewport = candidata.composicao.get_node("Desenho") as SubViewport
	var imagem: Image = desenho.get_texture().get_image()
	var origem := Vector2i(candidata.novo_distante.global_position.round()) - Vector2i(35, 140)
	var regiao: Rect2i = Rect2i(origem, Vector2i(240, 280)).intersection(Rect2i(Vector2i.ZERO, imagem.get_size()))
	erro = maxi(erro, imagem.get_region(regiao).save_png(pasta.path_join("juntas_detalhe.png"))) as Error
	print("Guarda distante: capturas ", error_string(erro))
	get_tree().quit(erro)
