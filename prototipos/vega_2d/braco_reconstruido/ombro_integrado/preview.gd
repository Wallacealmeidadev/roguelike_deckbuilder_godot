extends "res://prototipos/vega_2d/braco_reconstruido/preview_movimento.gd"

const OMBRO: PackedScene = preload("res://prototipos/vega_2d/braco_reconstruido/ombro_integrado/vega_ombro.tscn")
var comparar_base: bool = false
var base: VegaMovimentoBracoV1


func _ready() -> void:
	atriz = OMBRO.instantiate() as VegaOmbroIntegradoV1
	vega = atriz
	vega.size = Vector2(650, 850)
	vega.position = Vector2(80, 110)
	vega.scale = Vector2.ONE * .56
	add_child(vega)
	base = MOVIMENTO.instantiate() as VegaMovimentoBracoV1
	base.size = vega.size
	base.position = vega.position
	base.scale = vega.scale
	add_child(base)
	base.hide()
	get_viewport().size_changed.connect(_layout)
	_layout()
	if "--capturar" in OS.get_cmdline_user_args():
		_capturar.call_deferred()
	elif "--filmar" in OS.get_cmdline_user_args():
		_filmar.call_deferred()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if (event as InputEventKey).keycode == KEY_A:
			_alternar()
			queue_redraw()
			return
		if comparar_base:
			var nova: VegaMovimentoBracoV1 = atriz
			atriz = base
			super._unhandled_key_input(event)
			atriz = nova
			return
	super._unhandled_key_input(event)


func _alternar() -> void:
	var anterior: VegaMovimentoBracoV1 = base if comparar_base else atriz
	var clipe: StringName = anterior.modelo.animacao.assigned_animation
	var tempo: float = anterior.modelo.animacao.current_animation_position
	var tocando: bool = anterior.modelo.animacao.is_playing()
	var estado: String = anterior.estado_animacao
	var guias: bool = anterior.braco_novo.mostrar_marcos
	comparar_base = not comparar_base
	base.visible = comparar_base
	atriz.visible = not comparar_base
	var atual: VegaMovimentoBracoV1 = base if comparar_base else atriz
	atual.atualizar_estado(0, true, reduzido)
	atual.modelo.animacao.speed_scale = .25 if lento else 1.0
	atual.mostrar_marcos(guias)
	# Mostrar a outra variante na mesma fase, sem reiniciar o golpe.
	if not clipe.is_empty():
		atual.inspecionar(clipe, tempo)
		atual.estado_animacao = estado
		if tocando:
			atual.modelo.animacao.play()


func _draw() -> void:
	var nova: VegaMovimentoBracoV1 = atriz
	if comparar_base:
		atriz = base
	super._draw()
	atriz = nova
	draw_rect(Rect2(42, 24, 1000, 38), Color("101722"))
	draw_string(FONTE, Vector2(48, 55), "VEGA / JUNÇÃO DO OMBRO", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("e7ecf2"))
	draw_string(FONTE, Vector2(560, 513), "A: " + ("ombro anterior" if comparar_base else "ombro integrado"), HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("69d6e3"))


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_ombro_integrado_06"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var erro: Error = OK
	for tempo: float in [0.0, .1, .15, .2, .28, .36, .56]:
		for candidata: bool in [true, false]:
			var alvo: VegaMovimentoBracoV1 = atriz if candidata else base
			atriz.visible = candidata
			base.visible = not candidata
			alvo.inspecionar(&"soco", tempo)
			await RenderingServer.frame_post_draw
			var desenho: SubViewport = alvo.composicao.get_node("Desenho") as SubViewport
			var nome: String = ("novo" if candidata else "anterior") + "_%03d.png" % roundi(tempo * 100)
			erro = maxi(erro, desenho.get_texture().get_image().save_png(pasta.path_join(nome))) as Error
	print("Ombro integrado: capturas ", error_string(erro))
	get_tree().quit(erro)
