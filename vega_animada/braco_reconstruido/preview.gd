extends Node2D
## Prancha de inspeção, não interface de combate. O alterna os marcos.

const BRACO: Script = preload("res://vega_animada/braco_reconstruido/braco_registrado.gd")
const FONTE: Font = preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Regular.ttf")
var bracos: Array[BracoRegistradoV1] = []


func _ready() -> void:
	for pose: StringName in [&"neutro", &"guarda", &"extensao"]:
		var braco: BracoRegistradoV1 = BRACO.new() as BracoRegistradoV1
		add_child(braco)
		braco.definir_pose(pose)
		bracos.append(braco)
	bracos[0].position = Vector2(170, 175)
	bracos[0].scale = Vector2.ONE * 1.1
	bracos[1].position = Vector2(460, 245)
	bracos[1].scale = Vector2.ONE * 1.5
	bracos[2].position = Vector2(680, 360)
	bracos[2].scale = Vector2.ONE * 1.1
	get_viewport().size_changed.connect(_layout)
	_layout()
	if "--capturar" in OS.get_cmdline_user_args():
		_capturar.call_deferred()


func _layout() -> void:
	var area: Vector2 = get_viewport_rect().size
	var fator: float = minf(area.x / 1152.0, area.y / 648.0)
	scale = Vector2.ONE * fator
	position = (area - Vector2(1152, 648) * fator) * .5
	queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if (event as InputEventKey).keycode == KEY_O:
			for braco: BracoRegistradoV1 in bracos:
				braco.mostrar_marcos = not braco.mostrar_marcos
				braco.queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-2000, -2000, 6000, 6000), Color("101722"))
	draw_string(FONTE, Vector2(48, 64), "VEGA / UM BRAÇO, TRÊS SEGMENTOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("e7ecf2"))
	draw_string(FONTE, Vector2(48, 96), "Prova estática de encaixe • sem substituir a apresentação atual", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("97acbc"))
	for divisoria: float in [310.0, 630.0]:
		draw_line(Vector2(divisoria, 142), Vector2(divisoria, 550), Color("293342"))
	draw_string(FONTE, Vector2(70, 145), "ALINHAMENTO", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("69d6e3"))
	draw_string(FONTE, Vector2(395, 145), "GUARDA / 160°", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("69d6e3"))
	draw_string(FONTE, Vector2(740, 145), "EXTENSÃO", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("69d6e3"))
	draw_string(FONTE, Vector2(48, 598), "O: mostrar/ocultar eixos e centros compartilhados", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("c3ced8"))
	draw_string(FONTE, Vector2(48, 626), "Inspecionar: cotovelo fechado, punho centrado e placas presas à fibra. Arte ainda candidata.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("97acbc"))


func _capturar() -> void:
	await RenderingServer.frame_post_draw
	var pasta: String = "res://docs/evidencias_vega_braco_reconstruido_01"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var captura: Image = get_viewport().get_texture().get_image()
	var erro: Error = captura.save_png(pasta.path_join("montagem.png"))
	for braco: BracoRegistradoV1 in bracos:
		braco.mostrar_marcos = true
		braco.queue_redraw()
	await RenderingServer.frame_post_draw
	erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join("marcos.png"))) as Error
	print("Capturas do braço: ", error_string(erro))
	get_tree().quit(erro)
