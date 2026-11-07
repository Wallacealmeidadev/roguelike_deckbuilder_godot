extends SceneTree

const PASTA: String = "res://docs/evidencias_vega_corpo_v2_encaixe"
var falhas: int = 0


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute(PASTA)
	var recurso: PackedScene = load("res://prototipos/vega_2d/corpo_v2/preview.tscn") as PackedScene
	if recurso == null:
		quit(1)
		return
	var cena: Control = recurso.instantiate() as Control
	root.add_child(cena)
	await process_frame
	var vega: VegaCorpoV2Prova = cena.get_node("Vega") as VegaCorpoV2Prova
	var filmar: bool = "--filmar" in OS.get_cmdline_user_args()
	var resolucoes: Array[Vector2i] = [Vector2i(1024, 576), Vector2i(1920, 1080)]
	if filmar:
		resolucoes.assign([Vector2i(1152, 648)])
	for resolucao: Vector2i in resolucoes:
		root.size = resolucao
		root.content_scale_size = resolucao
		await process_frame
		vega.definir_combate(false, true)
		await _passo("repouso_%d" % resolucao.x, filmar)
		vega.definir_combate(true, not filmar)
		await _passo("combate_%d" % resolucao.x, filmar)
		for valor: int in [5, 10, 11, 0]:
			vega.definir_combo(valor, not filmar)
			await _passo("combo_%d_%d" % [valor, resolucao.x], filmar)
		vega.definir_combate(false, not filmar)
		await _passo("retorno_%d" % resolucao.x, filmar)
	cena.queue_free()
	await process_frame
	quit(0 if falhas == 0 else 1)


func _passo(nome: String, filmar: bool) -> void:
	if filmar:
		await create_timer(.8).timeout
		return
	await RenderingServer.frame_post_draw
	var erro: Error = root.get_texture().get_image().save_png("%s/%s.png" % [PASTA, nome])
	if erro != OK:
		falhas += 1
	print("CORPO V2 %s: %s" % [nome, error_string(erro)])
