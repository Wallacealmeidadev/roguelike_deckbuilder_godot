extends SceneTree

const DIRETORIO: String = "res://docs/evidencias_entrada_vega"


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIRETORIO))
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		DisplayServer.window_set_size(resolucao)
		root.size = resolucao
		root.content_scale_size = resolucao
		await process_frame
		var jogo: Control = (load("res://jogo.tscn") as PackedScene).instantiate() as Control
		root.add_child(jogo)
		await process_frame
		await _salvar("menu", resolucao)
		(jogo.find_child("NovaRunButton", true, false) as Button).pressed.emit()
		await create_timer(0.4).timeout
		await _salvar("selecao", resolucao)
		jogo.queue_free()
		await process_frame
	quit(0)


func _salvar(nome: String, resolucao: Vector2i) -> void:
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	var arquivo: String = "%s/%s_%dx%d.png" % [DIRETORIO, nome, resolucao.x, resolucao.y]
	var imagem: Image = root.get_texture().get_image()
	var erro: Error = imagem.save_png(arquivo)
	if erro != OK:
		push_error("Falha ao salvar %s: %s" % [arquivo, erro])
		quit(1)
		return
	print("CAPTURA ENTRADA: %s %s" % [arquivo, imagem.get_size()])
