extends SceneTree

const DIRETORIO: String = "res://docs/evidencias_vega_corpo_inteiro"


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIRETORIO))
	var recurso: PackedScene = load("res://vega_animada/preview_vega_corpo_inteiro.tscn") as PackedScene
	if recurso == null:
		push_error("Preview da Vega corpo inteiro nao carregou")
		quit(1)
		return
	var preview: Control = recurso.instantiate() as Control
	root.add_child(preview)
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		root.size = resolucao
		await process_frame
		await process_frame
		await create_timer(1.2).timeout
		await RenderingServer.frame_post_draw
		var imagem: Image = root.get_texture().get_image()
		var caminho: String = "%s/neutra_%dx%d.png" % [DIRETORIO, resolucao.x, resolucao.y]
		var erro: Error = imagem.save_png(caminho)
		if erro != OK:
			push_error("Falha ao salvar captura: %s" % caminho)
			quit(1)
			return
		print("CAPTURA VEGA RIG: %s %s" % [caminho, imagem.get_size()])
	preview.queue_free()
	await process_frame
	quit(0)
