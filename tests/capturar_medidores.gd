extends SceneTree
## Estados reais renderizados: captura o movimento em quatro fases, nas duas resoluções.

var jogo: Control


func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/evidencias_medidores")
	root.size = Vector2i(1920, 1080)
	jogo = (load("res://main.tscn") as PackedScene).instantiate() as Control
	root.add_child(jogo)
	await process_frame
	jogo.call("_iniciar_combate_por_id", "caranguejo_sucata", false)
	jogo.call("_limpar_mao")
	for id_carta: String in ["direto_hidraulico", "protecao", "quebra_chassi", "golpe"]:
		jogo.call("_criar_carta_na_mao", id_carta)
	for resolucao: Vector2i in [Vector2i(1920, 1080), Vector2i(1024, 576)]:
		root.size = resolucao
		jogo.call("_sincronizar_viewport_com_janela")
		jogo.set("combo", 0)
		jogo.set("barreira", 0)
		jogo.call("_atualizar_interface")
		await create_timer(0.35).timeout
		await _foto("vazio_%d" % resolucao.x)
		# Valores de fixture para mostrar múltiplos segmentos e células sem mexer nas regras.
		jogo.set("combo", 3)
		jogo.set("barreira", 12)
		jogo.call("_atualizar_interface")
		await create_timer(0.07).timeout
		await _foto("carga_%d" % resolucao.x)
		await create_timer(0.28).timeout
		await _foto("carregado_%d" % resolucao.x)
		jogo.get("feedback_combate").consumir_combo()
		jogo.set("combo", 0)
		jogo.call("_atualizar_interface")
		await create_timer(0.08).timeout
		await _foto("descarga_%d" % resolucao.x)
		await create_timer(0.28).timeout
		jogo.get("feedback_combate").absorver_barreira(12, true)
		jogo.set("barreira", 0)
		jogo.call("_atualizar_interface")
		await create_timer(0.07).timeout
		await _foto("quebra_%d" % resolucao.x)
		await create_timer(0.28).timeout
		jogo.call("_mostrar_inspecao_hud", jogo.get_node("StatsJogadorPanel/ModuloBarreira"))
		await create_timer(0.14).timeout
		await _foto("inspecao_%d" % resolucao.x)
		(jogo.get_node("HudInspecao") as Control).hide()
	jogo.queue_free()
	await process_frame
	quit()


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var caminho: String = "res://docs/evidencias_medidores/%s.png" % nome
	var erro: Error = root.get_texture().get_image().save_png(caminho)
	print("CAPTURA %s: %s" % [caminho, error_string(erro)])
