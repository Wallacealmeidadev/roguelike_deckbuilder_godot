extends SceneTree

const PASTA: String = "res://docs/evidencias_braco_v2_combo_linear"
var falhas: int = 0


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute(PASTA)
	var cena: Control = (load("res://vega_animada/braco_v2/preview.tscn") as PackedScene).instantiate() as Control
	root.add_child(cena)
	await process_frame
	var braco: BracoV2Prova = cena.get_node("Braco") as BracoV2Prova
	var filmar: bool = "--filmar-combo" in OS.get_cmdline_user_args()
	var resolucoes: Array[Vector2i] = [Vector2i(1024, 576), Vector2i(1920, 1080)]
	if filmar:
		resolucoes.assign([Vector2i(1152, 648)])
	for resolucao: Vector2i in resolucoes:
		root.size = resolucao
		root.content_scale_size = resolucao
		await process_frame
		braco.definir_combate(true, true)
		(cena.get_node("Alternar") as Button).set_pressed_no_signal(true)
		var passo: int = 0
		for valor: int in [0, 1, 2, 5, 9, 10, 11, 0]:
			braco.definir_combo(valor, not filmar)
			if filmar:
				await create_timer(.6).timeout
			else:
				await _foto("%d_combo_%d_%d" % [passo, valor, resolucao.x])
			passo += 1
		braco.definir_combate(false, not filmar)
		(cena.get_node("Alternar") as Button).set_pressed_no_signal(false)
		if filmar:
			await create_timer(.8).timeout
		else:
			await _foto("repouso_%d" % resolucao.x)
	cena.queue_free()
	await process_frame
	quit(0 if falhas == 0 else 1)


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var erro: Error = root.get_texture().get_image().save_png("%s/%s.png" % [PASTA, nome])
	if erro != OK:
		falhas += 1
	print("CAPTURA COMBO %s: %s" % [nome, error_string(erro)])
