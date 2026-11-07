extends "res://vega_animada/corpo_articulado/presenca_combate/preview.gd"

const COMBO_FIBRAS: PackedScene = preload("res://vega_animada/corpo_articulado/combo_fibras/vega_combo.tscn")
var atriz_combo: VegaComboFibrasV1


func _ready() -> void:
	anterior = PRESENCA.instantiate() as VegaPresencaCombateV1
	atriz_combo = COMBO_FIBRAS.instantiate() as VegaComboFibrasV1
	atriz_presenca = atriz_combo
	atriz_alternada = atriz_combo
	candidata = atriz_combo
	vega = candidata
	for indice: int in range(2):
		var atriz: VegaAcabamentoGolaV1 = anterior if indice == 0 else candidata
		atriz.size = Vector2(650, 850)
		atriz.position = Vector2(80 + indice * 560, 120)
		atriz.scale = Vector2.ONE * .50
		add_child(atriz)
		atriz.get_node("Sombra").hide()
		var recorte := AtlasTexture.new()
		recorte.atlas = (atriz.composicao.get_node("Desenho") as SubViewport).get_texture()
		recorte.region = Rect2(230, 65, 680, 430)
		var zoom := TextureRect.new()
		zoom.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		zoom.texture = recorte
		zoom.position = Vector2(32 + indice * 560, 130)
		zoom.size = Vector2(520, 408)
		zoom.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		zoom.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(zoom)
		zooms.append(zoom)
	atriz_combo.tensao_visual_alterada.connect(func(_valor: float) -> void: queue_redraw())
	get_viewport().size_changed.connect(_layout)
	_layout()
	_ampliar(false)
	if "--capturar" in OS.get_cmdline_user_args():
		_capturar.call_deferred()
	elif "--filmar" in OS.get_cmdline_user_args():
		_filmar.call_deferred()


func _pose(indice: int) -> void:
	pose_inspecionada = indice
	(anterior as VegaPresencaCombateV1).inspecionar_golpe(lado_distante, indice)
	atriz_combo.inspecionar_golpe(lado_distante, indice)
	queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	match (event as InputEventKey).keycode:
		KEY_UP:
			atriz_combo.definir_combo_visual(atriz_combo.combo_visual + 1)
		KEY_DOWN:
			atriz_combo.definir_combo_visual(atriz_combo.combo_visual - 1)
		KEY_0:
			atriz_combo.definir_combo_visual(0)
		KEY_6:
			atriz_combo.definir_combo_visual(5)
		KEY_7:
			atriz_combo.definir_combo_visual(10)
		KEY_8:
			atriz_combo.definir_combo_visual(20)
		KEY_D:
			(anterior as VegaPresencaCombateV1).receber_dano()
			atriz_combo.receber_dano()
		KEY_G:
			(anterior as VegaPresencaCombateV1).retomar_guarda()
			atriz_combo.retomar_guarda()
		KEY_4, KEY_5:
			var dano: bool = (event as InputEventKey).keycode == KEY_5
			(anterior as VegaPresencaCombateV1).inspecionar_presenca(dano, .1 if dano else 1.2)
			atriz_combo.inspecionar_presenca(dano, .1 if dano else 1.2)
		KEY_X:
			(anterior as VegaPresencaCombateV1).reiniciar_sequencia()
			atriz_combo.reiniciar_sequencia()
			lado_distante = false
			pose_inspecionada = 0
		KEY_B:
			var ativo: bool = not atriz_combo.respiro_habilitado
			(anterior as VegaPresencaCombateV1).definir_respiro(ativo)
			atriz_combo.definir_respiro(ativo)
		_:
			super._unhandled_key_input(event)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-2000, -2000, 6000, 6000), Color("101722"))
	draw_string(FONTE, Vector2(32, 44), "VEGA / TENSÃO DAS FIBRAS POR COMBO", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("e7ecf2"))
	draw_string(FONTE, Vector2(32, 82), "REFERÊNCIA / Combo 0", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("97acbc"))
	if not is_instance_valid(atriz_combo):
		return
	draw_string(FONTE, Vector2(592, 82), "COMBO %d / TENSÃO %.0f%%" % [atriz_combo.combo_visual, atriz_combo.tensao_visual * 100], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("69d6e3"))
	draw_string(FONTE, Vector2(592, 114), "Mãos, placas e juntas preservadas", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("efce75"))
	draw_string(FONTE, Vector2(32, 575), "↑/↓: um ponto   0: consumir   6: Combo 5   7: Combo 10   8: Combo 20 (mesmo máximo)", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("c3ced8"))
	draw_string(FONTE, Vector2(32, 603), "Espaço: golpes   D: dano   G: guarda   B: respiro   L: lento   R: reduzido   Z: ampliar", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("c3ced8"))
	draw_string(FONTE, Vector2(32, 631), "1/2/3 + T: poses   4/5: respiro/dano   O: juntas   X: reiniciar   |   F5 preservado", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("97acbc"))


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_combo_15"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var erro: Error = OK
	for valor: int in [0, 1, 5, 10, 20]:
		atriz_combo.definir_combo_visual(valor, true)
		for pose: int in range(4):
			if pose < 3:
				lado_distante = pose == 2
				atriz_combo.inspecionar_golpe(lado_distante, 0 if pose == 0 else 2)
				(anterior as VegaPresencaCombateV1).inspecionar_golpe(lado_distante, 0 if pose == 0 else 2)
			else:
				atriz_combo.inspecionar_presenca(true, .1)
				(anterior as VegaPresencaCombateV1).inspecionar_presenca(true, .1)
			_ampliar(false)
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var nome: String = "combo_%02d_pose_%d" % [valor, pose]
			erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join(nome + ".png"))) as Error
			if valor in [0, 5, 10] and pose == 0:
				_ampliar(true)
				await get_tree().process_frame
				await RenderingServer.frame_post_draw
				erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join("detalhe_" + nome + ".png"))) as Error
	print("Combo fibras: capturas ", error_string(erro))
	get_tree().quit(erro)


func _filmar() -> void:
	await get_tree().create_timer(.4).timeout
	for valor: int in [1, 2, 5, 10, 20, 0]:
		atriz_combo.definir_combo_visual(valor)
		(anterior as VegaPresencaCombateV1).socar_corpo()
		atriz_combo.socar_corpo()
		await get_tree().create_timer(.7).timeout
	get_tree().quit()
