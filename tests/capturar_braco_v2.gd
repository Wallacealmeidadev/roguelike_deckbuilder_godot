extends SceneTree

const PASTA: String = "res://docs/evidencias_braco_v2"
var falhas: int = 0


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute(PASTA)
	var cena: Control = (load("res://vega_animada/braco_v2/preview.tscn") as PackedScene).instantiate() as Control
	root.add_child(cena)
	await process_frame
	var braco: BracoV2Prova = cena.get_node("Braco") as BracoV2Prova
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		root.size = resolucao
		root.content_scale_size = resolucao
		await process_frame
		for indice: int in 4:
			braco.definir_ativacao([0.0, .5, 1.0, 0.0][indice])
			await _foto("%s_%d" % [["repouso", "intermediario", "combate", "retorno"][indice], resolucao.x])
		braco.definir_movimento_reduzido(true)
		braco.definir_combate(true)
		await _foto("reduzido_%d" % resolucao.x)
		braco.definir_movimento_reduzido(false)
	cena.queue_free()
	await process_frame
	quit(1 if falhas > 0 else 0)


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var caminho: String = "%s/%s.png" % [PASTA, nome]
	var erro: Error = root.get_texture().get_image().save_png(caminho)
	if erro != OK:
		falhas += 1
	print("CAPTURA %s: %s" % [caminho, error_string(erro)])
