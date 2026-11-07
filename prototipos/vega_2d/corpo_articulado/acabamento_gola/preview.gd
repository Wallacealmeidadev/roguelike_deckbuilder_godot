extends "res://prototipos/vega_2d/braco_reconstruido/preview_corpo.gd"
## Duas instâncias do MESMO movimento: só o material da pele difere.

const GOLA: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/acabamento_gola/vega_gola.tscn")
var anterior: VegaAcabamentoGolaV1
var candidata: VegaAcabamentoGolaV1
var ampliado: bool = true
var lento: bool = false
var zooms: Array[TextureRect] = []


func _ready() -> void:
	for indice: int in range(2):
		var atriz: VegaAcabamentoGolaV1 = GOLA.instantiate() as VegaAcabamentoGolaV1
		atriz.size = Vector2(650, 850)
		atriz.position = Vector2(65 + indice * 560, 96)
		atriz.scale = Vector2.ONE * .55
		add_child(atriz)
		atriz.get_node("Sombra").hide()
		var recorte := AtlasTexture.new()
		recorte.atlas = (atriz.composicao.get_node("Desenho") as SubViewport).get_texture()
		recorte.region = Rect2(240, 100, 370, 290)
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
			anterior.definir_acabamento(0)
		else:
			candidata = atriz
	vega = candidata
	get_viewport().size_changed.connect(_layout)
	_layout()
	_ampliar(true)
	if "--capturar" in OS.get_cmdline_user_args():
		_capturar.call_deferred()


func _ampliar(valor: bool) -> void:
	ampliado = valor
	for atriz: VegaAcabamentoGolaV1 in [anterior, candidata]:
		# Esconde só a composição visível; o SubViewport mantém a pintura viva.
		atriz.composicao.self_modulate.a = 0 if ampliado else 1
	for zoom: TextureRect in zooms:
		zoom.visible = ampliado
	queue_redraw()


func _pose(indice: int) -> void:
	for atriz: VegaAcabamentoGolaV1 in [anterior, candidata]:
		atriz.pose_corpo(indice)
	queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	match (event as InputEventKey).keycode:
		KEY_1, KEY_G:
			_pose(0)
		KEY_2:
			_pose(1)
		KEY_3:
			_pose(2)
		KEY_SPACE:
			for atriz: VegaAcabamentoGolaV1 in [anterior, candidata]:
				atriz.socar_corpo()
		KEY_A:
			candidata.definir_acabamento(0 if candidata.intensidade_gola > 0 else 1)
		KEY_Z:
			_ampliar(not ampliado)
		KEY_O:
			candidata.mostrar_juntas(not candidata.novo_distante.mostrar_marcos)
		KEY_L:
			lento = not lento
			for atriz: VegaAcabamentoGolaV1 in [anterior, candidata]:
				atriz.modelo.animacao.speed_scale = .25 if lento else 1
		KEY_R:
			var reduzir: bool = not candidata.corpo_reduzido
			for atriz: VegaAcabamentoGolaV1 in [anterior, candidata]:
				atriz.reduzir_corpo(reduzir)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-2000, -2000, 6000, 6000), Color("101722"))
	draw_string(FONTE, Vector2(32, 44), "VEGA / ACABAMENTO LOCAL DO PESCOÇO E GOLA", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("e7ecf2"))
	draw_string(FONTE, Vector2(32, 82), "ANTES / pintura atual", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("97acbc"))
	if not is_instance_valid(candidata):
		return
	var titulo: String = "RETOQUE LOCAL" if candidata.intensidade_gola > 0 else "ANTES / comparação A"
	draw_string(FONTE, Vector2(592, 82), titulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("69d6e3"))
	draw_string(FONTE, Vector2(592, 114), candidata.estado_animacao.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("efce75"))
	draw_string(FONTE, Vector2(32, 580), "1/2/3: poses   Espaço: golpe   A: antes/depois   Z: ampliar/corpo   L: lento   R: reduzido", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("c3ced8"))
	draw_string(FONTE, Vector2(32, 615), "Mesmo rig, pesos e movimento. Rosto, cabelo, braços e parte inferior preservados. F5 inalterado.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("97acbc"))


func _process(_delta: float) -> void:
	queue_redraw()


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_gola_11"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var erro: Error = OK
	for indice: int in range(3):
		_pose(indice)
		for zoom: bool in [true, false]:
			_ampliar(zoom)
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var nome: String = ("detalhe_" if zoom else "corpo_") + str(indice)
			erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join(nome + ".png"))) as Error
		for atriz: VegaAcabamentoGolaV1 in [anterior, candidata]:
			var desenho: SubViewport = atriz.composicao.get_node("Desenho") as SubViewport
			var nome: String = ("antes_" if atriz == anterior else "novo_") + str(indice)
			erro = maxi(erro, desenho.get_texture().get_image().save_png(pasta.path_join(nome + ".png"))) as Error
	print("Gola: capturas ", error_string(erro))
	get_tree().quit(erro)
