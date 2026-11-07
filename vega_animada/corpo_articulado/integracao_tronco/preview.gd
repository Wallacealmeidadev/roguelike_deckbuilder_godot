extends "res://vega_animada/corpo_articulado/acabamento_gola/preview.gd"
## Mesmos controles da prova 11; A compara a integração, não a gola.

const TRONCO: PackedScene = preload("res://vega_animada/corpo_articulado/integracao_tronco/vega_integracao.tscn")


func _ready() -> void:
	for indice: int in range(2):
		var atriz: VegaIntegracaoTroncoV1 = TRONCO.instantiate() as VegaIntegracaoTroncoV1
		atriz.size = Vector2(650, 850)
		atriz.position = Vector2(65 + indice * 560, 96)
		atriz.scale = Vector2.ONE * .55
		add_child(atriz)
		atriz.get_node("Sombra").hide()
		var recorte := AtlasTexture.new()
		recorte.atlas = (atriz.composicao.get_node("Desenho") as SubViewport).get_texture()
		recorte.region = Rect2(220, 85, 430, 370)
		var zoom := TextureRect.new()
		zoom.texture = recorte
		zoom.position = Vector2(32 + indice * 560, 130)
		zoom.size = Vector2(520, 408)
		zoom.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		zoom.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		zoom.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(zoom)
		zooms.append(zoom)
		if indice == 0:
			anterior = atriz
			atriz.definir_integracao(0)
		else:
			candidata = atriz
	vega = candidata
	get_viewport().size_changed.connect(_layout)
	_layout()
	# A primeira leitura é do corpo inteiro, na escala da comparação anterior.
	_ampliar(false)
	if "--capturar" in OS.get_cmdline_user_args():
		_capturar.call_deferred()


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	var atriz: VegaIntegracaoTroncoV1 = candidata as VegaIntegracaoTroncoV1
	match (event as InputEventKey).keycode:
		KEY_A:
			atriz.definir_integracao(0 if atriz.intensidade_integracao > 0 else 1)
		KEY_S:
			atriz.definir_sombra(0 if atriz.sombra_contato > 0 else .32)
		_:
			super._unhandled_key_input(event)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-2000, -2000, 6000, 6000), Color("101722"))
	draw_string(FONTE, Vector2(32, 44), "VEGA / TRONCO E PRÓTESES NA MESMA LEITURA", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("e7ecf2"))
	draw_string(FONTE, Vector2(32, 82), "ANTES / pintura e ombro anteriores", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("97acbc"))
	if not is_instance_valid(candidata):
		return
	var atriz: VegaIntegracaoTroncoV1 = candidata as VegaIntegracaoTroncoV1
	var titulo: String = "PINTURA + CONTATO" if atriz.intensidade_integracao > 0 else "ANTES / comparação A"
	draw_string(FONTE, Vector2(592, 82), titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("69d6e3"))
	var estado: String = candidata.estado_animacao.to_upper() + (" / sem sombra" if atriz.sombra_contato == 0 else "")
	draw_string(FONTE, Vector2(592, 114), estado, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("efce75"))
	draw_string(FONTE, Vector2(32, 580), "1/2/3: poses   Espaço: golpe   A: antes/depois   S: sombra   Z: ampliar   L: lento   R: reduzido", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("c3ced8"))
	draw_string(FONTE, Vector2(32, 615), "Mesmo rig e animação. Rosto, mãos e parte inferior preservados. Prova isolada, F5 inalterado.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("97acbc"))


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_integracao_12"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var erro: Error = OK
	for indice: int in range(3):
		_pose(indice)
		for zoom: bool in [false, true]:
			_ampliar(zoom)
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var nome: String = ("detalhe_" if zoom else "corpo_") + str(indice)
			erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join(nome + ".png"))) as Error
		for atriz: VegaAcabamentoGolaV1 in [anterior, candidata]:
			var desenho: SubViewport = atriz.composicao.get_node("Desenho") as SubViewport
			var nome: String = ("antes_" if atriz == anterior else "novo_") + str(indice)
			erro = maxi(erro, desenho.get_texture().get_image().save_png(pasta.path_join(nome + ".png"))) as Error
	print("Integração tronco: capturas ", error_string(erro))
	get_tree().quit(erro)
