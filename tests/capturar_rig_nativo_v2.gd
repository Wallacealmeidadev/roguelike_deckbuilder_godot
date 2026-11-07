extends SceneTree

const PASTA: String = "res://docs/evidencias_rig_nativo_v2"
var falhas: int = 0


func _initialize() -> void:
	call_deferred("_executar")


func _executar() -> void:
	DirAccess.make_dir_recursive_absolute(PASTA)
	var prova: Control = (load("res://vega_animada/rig_nativo_v2/preview.tscn") as PackedScene).instantiate() as Control
	root.add_child(prova)
	await process_frame
	if "--filmar" in OS.get_cmdline_user_args():
		root.size = Vector2i(1152, 648)
		root.content_scale_size = root.size
		await process_frame
		await create_timer(.6).timeout
		prova.call("_ciclo")
		await create_timer(.9).timeout
		prova.call("_ciclo")
		await create_timer(.15).timeout
		prova.call("_ciclo")
		await create_timer(.9).timeout
	else:
		for resolucao: Vector2i in [Vector2i(1920, 1080), Vector2i(1024, 576)]:
			root.size = resolucao
			root.content_scale_size = resolucao
			await process_frame
			for nome: StringName in [&"repouso", &"guarda", &"extensao"]:
				prova.call("_pose", nome, true)
				await _foto("%s_%d" % [nome, resolucao.x])
			(prova.get_node("Rodape/Controles/Ossos") as CheckButton).button_pressed = true
			prova.call("_inspecionar", .15)
			await _foto("intermediaria_ossos_%d" % resolucao.x)
			(prova.get_node("Rodape/Controles/Ossos") as CheckButton).button_pressed = false
	prova.queue_free()
	await process_frame
	quit(0 if falhas == 0 else 1)


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var erro: Error = root.get_texture().get_image().save_png("%s/%s.png" % [PASTA, nome])
	if erro != OK:
		falhas += 1
	print("CAPTURA RIG %s: %s" % [nome, error_string(erro)])
