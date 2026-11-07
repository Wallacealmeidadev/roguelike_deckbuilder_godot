extends SceneTree
## Diagnóstico isolado: captura poses atuais sem modificar o jogo/arte.


func _initialize() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var pasta: String = "res://docs/evidencias_vega_soquetes_inspecao_01"
	var juntas: bool = "--juntas" in OS.get_cmdline_user_args()
	if juntas:
		pasta = "res://docs/evidencias_vega_juntas_01"
	DirAccess.make_dir_recursive_absolute(pasta)
	var ator: VegaAcabamentoProximo = (load("res://prototipos/vega_2d/rig_nativo_v2/acabamento_proximo/vega_prova.tscn") as PackedScene).instantiate() as VegaAcabamentoProximo
	ator.refinar_juntas = juntas
	ator.size = Vector2(800, 850)
	root.add_child(ator)
	await process_frame
	await process_frame
	ator.atualizar_estado(10, true, false)
	ator.modelo.definir_combo(10, true)
	var viewport: Viewport = ator.modelo.get_viewport()
	var maior_desvio: float = 0
	var iniciais: Array[Transform2D] = []
	for braco: BracoNativoV2 in [ator.modelo.braco_original, ator.modelo.braco_distante]:
		var mao: Sprite2D = braco.punho.get_node("Mao") as Sprite2D
		var miolo: Polygon2D = braco.punho.get_node("InteriorSoquete") as Polygon2D
		iniciais.append(mao.global_transform.affine_inverse() * miolo.global_transform)
	for lado: int in range(2):
		var nome: StringName = &"soco" if lado == 0 else &"soco_distante"
		var braco: BracoNativoV2 = ator.modelo.braco_original if lado == 0 else ator.modelo.braco_distante
		ator.modelo.animacao.play(nome, 0)
		ator.modelo.animacao.pause()
		for amostra: int in range(57):
			ator.modelo.animacao.seek(amostra * .01, true)
			for indice: int in range(2):
				var outro: BracoNativoV2 = ator.modelo.braco_original if indice == 0 else ator.modelo.braco_distante
				var mao: Sprite2D = outro.punho.get_node("Mao") as Sprite2D
				var miolo: Polygon2D = outro.punho.get_node("InteriorSoquete") as Polygon2D
				var relativo: Transform2D = mao.global_transform.affine_inverse() * miolo.global_transform
				maior_desvio = maxf(maior_desvio, relativo.origin.distance_to(iniciais[indice].origin))
			if amostra not in [0, 10, 20, 28, 36, 46, 56]:
				continue
			viewport.canvas_transform = Transform2D(Vector2(4, 0), Vector2(0, 4), Vector2(viewport.size) * .5 - braco.punho.global_position * 4)
			await RenderingServer.frame_post_draw
			var arquivo: String = "%s/%s_%03d.png" % [pasta, nome, amostra]
			var erro: Error = viewport.get_texture().get_image().save_png(arquivo)
			print("INSPECAO %s: %s" % [arquivo, error_string(erro)])
	print("INSPECAO: desvio relativo maximo mao/miolo = %.6f px do atlas; sem alteracoes de pose" % maior_desvio)
	ator.queue_free()
	await process_frame
	quit()
