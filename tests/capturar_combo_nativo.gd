extends SceneTree

const PASTA: String = "res://docs/evidencias_combo_nativo"
var falhas: int = 0


func _initialize() -> void:
	call_deferred("_executar")


func _executar() -> void:
	DirAccess.make_dir_recursive_absolute(PASTA)
	var prova: Control = (load("res://vega_animada/rig_nativo_v2/preview_combo.tscn") as PackedScene).instantiate() as Control
	root.add_child(prova)
	await process_frame
	if "--filmar" in OS.get_cmdline_user_args():
		root.size = Vector2i(1152, 648)
		root.content_scale_size = root.size
		await process_frame
		prova.call("_pose", &"guarda", true)
		for valor: float in [0.0, 1.0, 5.0, 10.0]:
			prova.call("_combo", valor)
			await create_timer(.7).timeout
		prova.call("_ciclo")
		await create_timer(.7).timeout
		prova.call("_combo", 0.0)
		await create_timer(.7).timeout
	else:
		for resolucao: Vector2i in [Vector2i(1920, 1080), Vector2i(1024, 576)]:
			root.size = resolucao
			root.content_scale_size = root.size
			await process_frame
			for nome: StringName in [&"guarda", &"extensao"]:
				prova.call("_pose", nome, true)
				for valor: float in [0.0, 1.0, 5.0, 10.0]:
					prova.call("_combo", valor, true)
					await RenderingServer.frame_post_draw
					var arquivo: String = "%s/%s_combo%d_%d.png" % [PASTA, nome, int(valor), resolucao.x]
					var erro: Error = root.get_texture().get_image().save_png(arquivo)
					if erro != OK:
						falhas += 1
					print("CAPTURA COMBO NATIVO %s: %s" % [arquivo, error_string(erro)])
	prova.queue_free()
	await process_frame
	quit(0 if falhas == 0 else 1)
