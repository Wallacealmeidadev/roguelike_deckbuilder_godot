extends SceneTree


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/evidencias_vega_combate_v2_maos")
	root.size = Vector2i(1024, 1024)
	root.content_scale_size = root.size
	var fundo: ColorRect = ColorRect.new()
	fundo.color = Color("263547")
	fundo.size = Vector2(1024, 1024)
	root.add_child(fundo)
	var vega: VegaCombateV2 = (load("res://prototipos/vega_2d/combate_v2/vega_combate.tscn") as PackedScene).instantiate() as VegaCombateV2
	root.add_child(vega)
	vega.position = Vector2(147, 60)
	vega.size = Vector2(730, 900)
	vega.atualizar_estado(10, true, false)
	vega.set_process(false)
	vega.modelo.definir_combate(true, true)
	vega.modelo.definir_combo(10, true)
	for valor: float in [-1.0, 0.0, .5, 1.0]:
		vega.modelo.posar_prontidao(0 if valor < 0 else 1)
		vega.modelo.posar_golpe(maxf(0, valor))
		await RenderingServer.frame_post_draw
		print("POSE %s ombro=%s cotovelo=%s punho=%s alvo=%s" % [valor, vega.modelo.braco_ataque.ombro.global_position, vega.modelo.braco_ataque.articulacao_cotovelo.global_position, vega.modelo.braco_ataque.punho.global_position, vega.modelo.braco_ataque.alvo_local])
		root.get_texture().get_image().save_png("res://docs/evidencias_vega_combate_v2_maos/modelo_%d.png" % roundi(valor * 100))
	vega.queue_free()
	await process_frame
	quit()
