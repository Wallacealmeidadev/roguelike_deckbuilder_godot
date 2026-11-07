extends "res://vega_animada/braco_reconstruido/preview_corpo.gd"
## Reutiliza somente enquadramento/fonte da prancha; preserva a prévia estática.

const MOVIMENTO: PackedScene = preload("res://vega_animada/braco_reconstruido/vega_movimento.tscn")
var atriz: VegaMovimentoBracoV1
var reduzido: bool = false
var lento: bool = false


func _ready() -> void:
	atriz = MOVIMENTO.instantiate() as VegaMovimentoBracoV1
	vega = atriz
	vega.size = Vector2(650, 850)
	vega.position = Vector2(80, 110)
	vega.scale = Vector2.ONE * .56
	add_child(vega)
	get_viewport().size_changed.connect(_layout)
	_layout()
	if "--capturar" in OS.get_cmdline_user_args():
		_capturar.call_deferred()
	elif "--filmar" in OS.get_cmdline_user_args():
		_filmar.call_deferred()


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	match (event as InputEventKey).keycode:
		KEY_SPACE:
			atriz.socar()
		KEY_D:
			atriz.receber_dano()
		KEY_R:
			reduzido = not reduzido
			atriz.definir_reduzido(reduzido)
		KEY_G:
			atriz.reiniciar()
		KEY_L:
			lento = not lento
			atriz.modelo.animacao.speed_scale = .25 if lento else 1.0
		KEY_O:
			atriz.mostrar_marcos(not atriz.braco_novo.mostrar_marcos)
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-2000, -2000, 6000, 6000), Color("101722"))
	draw_string(FONTE, Vector2(48, 55), "VEGA / UM BRAÇO EM MOVIMENTO", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("e7ecf2"))
	draw_string(FONTE, Vector2(48, 84), "Respiração • preparo • impacto • retorno à guarda aprovada", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("97acbc"))
	if not is_instance_valid(atriz):
		return
	draw_string(FONTE, Vector2(560, 165), atriz.estado_animacao.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("69d6e3"))
	draw_string(FONTE, Vector2(560, 211), "Espaço: socar com o braço reconstruído", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("c3ced8"))
	draw_string(FONTE, Vector2(560, 247), "D: receber dano / interromper o soco", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("c3ced8"))
	draw_string(FONTE, Vector2(560, 283), "G: voltar à guarda    O: ver juntas", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("c3ced8"))
	draw_string(FONTE, Vector2(560, 339), "R: movimento reduzido — " + ("ligado" if reduzido else "desligado"), HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("c3ced8"))
	draw_string(FONTE, Vector2(560, 375), "L: câmera lenta — " + ("ligada" if lento else "desligada"), HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("c3ced8"))
	draw_string(FONTE, Vector2(560, 440), "Mesmo soco de 0,56 s; retorno à guarda 75°/−120°.", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("97acbc"))
	draw_string(FONTE, Vector2(560, 472), "Sem alongar ossos ou voltar a fechar o antebraço.", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("97acbc"))
	draw_string(FONTE, Vector2(48, 626), "Prova isolada: só um braço adaptado. Segundo lado, Combo e apresentação F5 permanecem anteriores.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("97acbc"))


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_movimento_05"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var erro: Error = OK
	for tempo: float in [0.0, .1, .15, .2, .28, .36, .56]:
		atriz.inspecionar(&"soco", tempo)
		var nome: String = "soco_%03d" % roundi(tempo * 100)
		erro = maxi(erro, await _foto_movimento(pasta, nome)) as Error
	for clipe: StringName in [&"dano", &"respirar"]:
		atriz.inspecionar(clipe, .1 if clipe == &"dano" else 1.2)
		erro = maxi(erro, await _foto_movimento(pasta, str(clipe))) as Error
	print("Capturas do movimento: ", error_string(erro))
	get_tree().quit(erro)


func _foto_movimento(pasta: String, nome: String) -> Error:
	await RenderingServer.frame_post_draw
	var erro: Error = get_viewport().get_texture().get_image().save_png(pasta.path_join(nome + ".png"))
	var desenho: SubViewport = atriz.composicao.get_node("Desenho") as SubViewport
	return maxi(erro, desenho.get_texture().get_image().save_png(pasta.path_join(nome + "_detalhe.png"))) as Error


func _filmar() -> void:
	await get_tree().create_timer(.6).timeout
	atriz.socar()
	await get_tree().create_timer(.8).timeout
	atriz.socar()
	await get_tree().create_timer(.15).timeout
	atriz.receber_dano()
	await get_tree().create_timer(.65).timeout
	atriz.socar()
	await get_tree().create_timer(.9).timeout
	get_tree().quit()
