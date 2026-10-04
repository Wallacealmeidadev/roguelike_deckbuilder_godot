extends SceneTree

const DIRETORIO: String = "res://docs/evidencias_vega_segmentada"
var preview: Control
var vega: Control

func _initialize() -> void:
	call_deferred("capturar")

func capturar() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIRETORIO))
	var recurso: PackedScene = load("res://vega_animada/preview_vega_segmentada.tscn") as PackedScene
	if recurso == null:
		push_error("Preview da Vega segmentada nao carregou")
		quit(1)
		return
	preview = recurso.instantiate() as Control
	root.add_child(preview)
	vega = preview.get_node("VegaAnimada") as Control
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		root.size = resolucao
		await process_frame
		await process_frame
		await capturar_estado("guarda", resolucao, 0.20)
		await capturar_estado("repouso", resolucao, 1.20)
		vega.socar()
		preview.get_node("Estado").text = "SOCO"
		await aguardar(0.24)
		await salvar("soco", resolucao)
		vega.reiniciar()
		await aguardar(0.12)
		vega.socar()
		await aguardar(0.12)
		vega.receber_dano()
		preview.get_node("Estado").text = "INTERRUPCAO: SOCO -> DANO"
		await aguardar(0.20)
		await salvar("interrupcao", resolucao)
	preview.queue_free()
	await process_frame
	quit()

func capturar_estado(nome: String, resolucao: Vector2i, espera: float) -> void:
	preview.get_node("Estado").text = nome.to_upper()
	vega.reiniciar()
	await aguardar(espera)
	await salvar(nome, resolucao)

func aguardar(segundos: float) -> void:
	await create_timer(segundos).timeout
	await RenderingServer.frame_post_draw

func salvar(nome: String, resolucao: Vector2i) -> void:
	var imagem: Image = root.get_texture().get_image()
	var caminho: String = "%s/%s_%dx%d.png" % [DIRETORIO, nome, resolucao.x, resolucao.y]
	imagem.save_png(caminho)
