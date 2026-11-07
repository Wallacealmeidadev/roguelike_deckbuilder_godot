extends "res://prototipos/vega_2d/corpo_articulado/acabamento_gola/preview.gd"
## Esquerda mantém o golpe próximo da prova 12; direita alterna as cadeias novas.

const ALTERNADA: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/golpes_alternados/vega_alternada.tscn")
const REFERENCIA: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/integracao_tronco/vega_integracao.tscn")
var atriz_alternada: VegaGolpesAlternadosV1
var lado_distante: bool = true
var pose_inspecionada: int = 0


func _ready() -> void:
	anterior = REFERENCIA.instantiate() as VegaAcabamentoGolaV1
	atriz_alternada = ALTERNADA.instantiate() as VegaGolpesAlternadosV1
	candidata = atriz_alternada
	vega = candidata
	for indice: int in range(2):
		var atriz: VegaAcabamentoGolaV1 = anterior if indice == 0 else candidata
		atriz.size = Vector2(650, 850)
		atriz.position = Vector2(65 + indice * 560, 96)
		atriz.scale = Vector2.ONE * .55
		add_child(atriz)
		atriz.get_node("Sombra").hide()
		var recorte := AtlasTexture.new()
		recorte.atlas = (atriz.composicao.get_node("Desenho") as SubViewport).get_texture()
		recorte.region = Rect2(230, 65, 680, 430)
		var zoom := TextureRect.new()
		zoom.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		zoom.texture = recorte
		zoom.position = Vector2(32 + indice * 560, 130)
		zoom.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		zoom.size = Vector2(520, 408)
		zoom.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(zoom)
		zooms.append(zoom)
	get_viewport().size_changed.connect(_layout)
	_layout()
	_ampliar(false)
	if "--capturar" in OS.get_cmdline_user_args():
		_capturar.call_deferred()
	elif "--filmar" in OS.get_cmdline_user_args():
		_filmar.call_deferred()


func _pose(indice: int) -> void:
	pose_inspecionada = indice
	anterior.pose_corpo(indice)
	atriz_alternada.inspecionar_golpe(lado_distante, indice)
	queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	match (event as InputEventKey).keycode:
		KEY_A:
			# Não herdar o atalho de edição da gola da prévia antiga.
			return
		KEY_SPACE:
			anterior.socar_corpo()
			atriz_alternada.socar_corpo()
			lado_distante = atriz_alternada.ultimo_braco_distante
		KEY_T:
			lado_distante = not lado_distante
			_pose(pose_inspecionada)
		KEY_X:
			atriz_alternada.reiniciar_sequencia()
			anterior.pose_corpo(0)
			lado_distante = false
			pose_inspecionada = 0
		_:
			super._unhandled_key_input(event)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-2000, -2000, 6000, 6000), Color("101722"))
	draw_string(FONTE, Vector2(32, 44), "VEGA / GOLPE DISTANTE E ALTERNÂNCIA", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("e7ecf2"))
	draw_string(FONTE, Vector2(32, 82), "REFERÊNCIA / golpe próximo aprovado", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("97acbc"))
	if not is_instance_valid(atriz_alternada):
		return
	draw_string(FONTE, Vector2(592, 82), "PROVA / " + atriz_alternada.estado_animacao.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("69d6e3"))
	var proximo: String = "DISTANTE" if atriz_alternada.proximo_braco_distante else "PRÓXIMO"
	draw_string(FONTE, Vector2(592, 114), "Próximo Espaço: " + proximo, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("efce75"))
	draw_string(FONTE, Vector2(32, 580), "Espaço: alternar golpes   1/2/3: poses   T: lado inspecionado   X: reiniciar sequência", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("c3ced8"))
	draw_string(FONTE, Vector2(32, 615), "Z: ampliar   L: lento   O: juntas   R: reduzido   |   Mesma arte, ossos e comprimentos. F5 preservado.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("97acbc"))


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_alternancia_13"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var erro: Error = OK
	for distante: bool in [false, true]:
		lado_distante = distante
		for indice: int in range(5):
			_pose(indice)
			_ampliar(false)
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var nome: String = ("distante_" if distante else "proximo_") + str(indice)
			erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join(nome + ".png"))) as Error
			var desenho: SubViewport = candidata.composicao.get_node("Desenho") as SubViewport
			erro = maxi(erro, desenho.get_texture().get_image().save_png(pasta.path_join("nativo_" + nome + ".png"))) as Error
			if indice == 2:
				_ampliar(true)
				await get_tree().process_frame
				await RenderingServer.frame_post_draw
				erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join("detalhe_" + nome + ".png"))) as Error
	lado_distante = true
	_pose(2)
	_ampliar(true)
	atriz_alternada.mostrar_juntas(true)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join("marcos_distante.png"))) as Error
	print("Golpes alternados: capturas ", error_string(erro))
	get_tree().quit(erro)


func _filmar() -> void:
	await get_tree().create_timer(.4).timeout
	for golpe: int in range(4):
		anterior.socar_corpo()
		atriz_alternada.socar_corpo()
		await get_tree().create_timer(.7).timeout
	# Troca durante uma ação, sem fila e sem voltar à guarda antes do novo clipe.
	atriz_alternada.socar_corpo()
	await get_tree().create_timer(.15).timeout
	atriz_alternada.socar_corpo()
	await get_tree().create_timer(.8).timeout
	get_tree().quit()
