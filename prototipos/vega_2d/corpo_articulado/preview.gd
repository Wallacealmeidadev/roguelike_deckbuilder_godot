extends "res://prototipos/vega_2d/braco_reconstruido/preview_corpo.gd"
## Comparação corporal na mesma fase. Sem integração com combate/HUD.

const CORPO: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/vega_corpo.tscn")
const BASE: PackedScene = preload("res://prototipos/vega_2d/braco_reconstruido/distante/vega_distante.tscn")
var candidata: VegaCorpoArticuladoV1
var anterior: VegaGuardaDistanteV1
var lento: bool = false
var indice_pose: int = 0


func _ready() -> void:
	candidata = CORPO.instantiate() as VegaCorpoArticuladoV1
	anterior = BASE.instantiate() as VegaGuardaDistanteV1
	vega = candidata
	for atriz: VegaGuardaDistanteV1 in [anterior, candidata]:
		atriz.size = Vector2(650, 850)
		atriz.scale = Vector2.ONE * .55
		atriz.position = Vector2(65 if atriz == anterior else 625, 96)
		add_child(atriz)
	anterior.modelo.animacao.animation_finished.connect(_terminar_base)
	get_viewport().size_changed.connect(_layout)
	_layout()
	if "--capturar" in OS.get_cmdline_user_args():
		_capturar.call_deferred()
	elif "--filmar" in OS.get_cmdline_user_args():
		_filmar.call_deferred()


func _pose(indice: int) -> void:
	indice_pose = 0 if candidata.corpo_reduzido else indice
	candidata.pose_corpo(indice_pose)
	anterior.inspecionar(&"soco", candidata.TEMPOS[indice_pose])
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
			candidata.socar_corpo()
			if not candidata.corpo_reduzido:
				anterior.modelo.animacao.play_with_capture(&"soco", .1, 0, 1, false, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		KEY_O:
			candidata.mostrar_juntas(not candidata.novo_distante.mostrar_marcos)
		KEY_L:
			lento = not lento
			candidata.modelo.animacao.speed_scale = .25 if lento else 1.0
			anterior.modelo.animacao.speed_scale = .25 if lento else 1.0
		KEY_R:
			candidata.reduzir_corpo(not candidata.corpo_reduzido)
			_pose(0)
	queue_redraw()


func _terminar_base(nome: StringName) -> void:
	if nome == &"soco":
		anterior.inspecionar(&"soco", 0)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-2000, -2000, 6000, 6000), Color("101722"))
	draw_string(FONTE, Vector2(42, 44), "VEGA / PROVA DO CORPO ARTICULADO", HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("e7ecf2"))
	draw_string(FONTE, Vector2(42, 78), "ANTES / controles existentes", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("97acbc"))
	draw_string(FONTE, Vector2(600, 78), "PROVA / abdômen + cabeça independente", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("69d6e3"))
	if not is_instance_valid(candidata):
		return
	draw_string(FONTE, Vector2(600, 112), candidata.estado_animacao.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("efce75"))
	draw_string(FONTE, Vector2(42, 586), "1: guarda   2: preparo   3: impacto   Espaço: golpe   O: juntas   L: lento   R: reduzido", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("c3ced8"))
	draw_string(FONTE, Vector2(42, 618), "Mesma pintura e braços. Prova mecânica; novas vistas e acabamento corporal ainda não desenhados.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("97acbc"))


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_corpo_articulado_10"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var erro: Error = OK
	for indice: int in range(5):
		_pose(indice)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var nome: String = "%03d" % roundi(candidata.TEMPOS[indice] * 100)
		erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join("comparacao_" + nome + ".png"))) as Error
		for atriz: VegaGuardaDistanteV1 in [anterior, candidata]:
			var desenho: SubViewport = atriz.composicao.get_node("Desenho") as SubViewport
			var prefixo: String = "antes_" if atriz == anterior else "novo_"
			erro = maxi(erro, desenho.get_texture().get_image().save_png(pasta.path_join(prefixo + nome + ".png"))) as Error
	candidata.mostrar_juntas(true)
	_pose(2)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join("marcos.png"))) as Error
	print("Corpo articulado: capturas ", error_string(erro))
	get_tree().quit(erro)


func _filmar() -> void:
	await get_tree().create_timer(.5).timeout
	candidata.socar_corpo()
	anterior.modelo.animacao.play_with_capture(&"soco", .1, 0, 1, false, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	await get_tree().create_timer(.8).timeout
	candidata.socar_corpo()
	anterior.modelo.animacao.play_with_capture(&"soco", .1, 0, 1, false, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	await get_tree().create_timer(.15).timeout
	candidata.socar_corpo()
	anterior.modelo.animacao.play_with_capture(&"soco", .1, 0, 1, false, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	await get_tree().create_timer(.8).timeout
	get_tree().quit()
