extends SceneTree

const PASTA: String = "res://docs/evidencias_apoio_corporal"
var falhas: int = 0


func _initialize() -> void:
	call_deferred("_executar")


func _executar() -> void:
	DirAccess.make_dir_recursive_absolute(PASTA)
	var prova: Control = (load("res://vega_animada/rig_nativo_v2/preview_apoio.tscn") as PackedScene).instantiate() as Control
	root.add_child(prova)
	await process_frame
	if "--filmar" in OS.get_cmdline_user_args():
		root.size = Vector2i(1152, 648)
		root.content_scale_size = root.size
		await process_frame
		await create_timer(.5).timeout
		prova.call("_ciclo")
		await create_timer(.9).timeout
		prova.call("_pose", &"guarda")
		await create_timer(.5).timeout
		prova.call("_ciclo")
		await create_timer(.9).timeout
		prova.call("_combo", 10.0)
		await create_timer(.3).timeout
		prova.call("_ciclo")
		await create_timer(.9).timeout
	else:
		var nomes: Array[String] = ["repouso", "preparo", "impacto", "retorno", "guarda"]
		var tempos: Array[float] = [0.0, .1, .2, .28, .36]
		for resolucao: Vector2i in [Vector2i(1920, 1080), Vector2i(1024, 576)]:
			root.size = resolucao
			root.content_scale_size = root.size
			await process_frame
			for i: int in nomes.size():
				prova.call("_inspecionar", tempos[i])
				await _foto("%s_%d" % [nomes[i], resolucao.x])
			(prova.get_node("Rodape/Controles/Ossos") as CheckButton).button_pressed = true
			prova.call("_inspecionar", .2)
			await _foto("impacto_apoios_%d" % resolucao.x)
			(prova.get_node("Rodape/Controles/Ossos") as CheckButton).button_pressed = false
	prova.queue_free()
	await process_frame
	quit(0 if falhas == 0 else 1)


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var erro: Error = root.get_texture().get_image().save_png("%s/%s.png" % [PASTA, nome])
	if erro != OK:
		falhas += 1
	print("CAPTURA APOIO %s: %s" % [nome, error_string(erro)])
