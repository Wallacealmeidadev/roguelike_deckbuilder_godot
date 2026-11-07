extends "res://vega_animada/corpo_articulado/golpes_alternados/preview.gd"

const PRESENCA: PackedScene = preload("res://vega_animada/corpo_articulado/presenca_combate/vega_presenca.tscn")
var atriz_presenca: VegaPresencaCombateV1


func _ready() -> void:
	anterior = ALTERNADA.instantiate() as VegaAcabamentoGolaV1
	atriz_presenca = PRESENCA.instantiate() as VegaPresencaCombateV1
	atriz_alternada = atriz_presenca
	candidata = atriz_presenca
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


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	match (event as InputEventKey).keycode:
		KEY_D:
			atriz_presenca.receber_dano()
		KEY_B:
			atriz_presenca.definir_respiro(not atriz_presenca.respiro_habilitado)
		KEY_G:
			anterior.pose_corpo(0)
			atriz_presenca.retomar_guarda()
		KEY_4:
			anterior.pose_corpo(0)
			atriz_presenca.inspecionar_presenca(false, 1.2)
		KEY_5:
			anterior.pose_corpo(0)
			atriz_presenca.inspecionar_presenca(true, .10)
		_:
			super._unhandled_key_input(event)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-2000, -2000, 6000, 6000), Color("101722"))
	draw_string(FONTE, Vector2(32, 44), "VEGA / GUARDA VIVA E REAÇÃO AO DANO", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("e7ecf2"))
	draw_string(FONTE, Vector2(32, 82), "REFERÊNCIA / versão 13", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("97acbc"))
	if not is_instance_valid(atriz_presenca):
		return
	draw_string(FONTE, Vector2(592, 82), "PROVA / " + atriz_presenca.estado_animacao.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("69d6e3"))
	var proximo: String = "DISTANTE" if atriz_presenca.proximo_braco_distante else "PRÓXIMO"
	draw_string(FONTE, Vector2(592, 114), "Próximo Espaço: " + proximo, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("efce75"))
	draw_string(FONTE, Vector2(32, 580), "D: dano   B: respiro   G: retomar guarda   Espaço: golpes   L: lento   R: reduzido", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("c3ced8"))
	draw_string(FONTE, Vector2(32, 615), "1/2/3 + T: poses dos golpes   4: inspiração   5: dano   Z: ampliar   O: juntas   X: reiniciar", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("97acbc"))


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_presenca_14"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var erro: Error = OK
	for dano: bool in [false, true]:
		var tempos: Array[float] = atriz_presenca.TEMPOS_DANO if dano else atriz_presenca.TEMPOS_RESPIRO
		for indice: int in range(tempos.size()):
			atriz_presenca.inspecionar_presenca(dano, tempos[indice])
			_ampliar(false)
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var nome: String = ("dano_" if dano else "respiro_") + str(indice)
			erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join(nome + ".png"))) as Error
			var desenho: SubViewport = candidata.composicao.get_node("Desenho") as SubViewport
			erro = maxi(erro, desenho.get_texture().get_image().save_png(pasta.path_join("nativo_" + nome + ".png"))) as Error
			if indice == (1 if dano else 2):
				_ampliar(true)
				await get_tree().process_frame
				await RenderingServer.frame_post_draw
				erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join("detalhe_" + nome + ".png"))) as Error
	atriz_presenca.inspecionar_presenca(true, .1)
	atriz_presenca.mostrar_juntas(true)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join("marcos_dano.png"))) as Error
	print("Presença corporal: capturas ", error_string(erro))
	get_tree().quit(erro)


func _filmar() -> void:
	await get_tree().create_timer(2.6).timeout
	atriz_presenca.receber_dano()
	await get_tree().create_timer(.6).timeout
	atriz_presenca.socar_corpo()
	await get_tree().create_timer(.15).timeout
	atriz_presenca.receber_dano()
	await get_tree().create_timer(.5).timeout
	atriz_presenca.socar_corpo()
	await get_tree().create_timer(.7).timeout
	atriz_presenca.receber_dano()
	await get_tree().create_timer(.08).timeout
	atriz_presenca.receber_dano()
	await get_tree().create_timer(.8).timeout
	get_tree().quit()
