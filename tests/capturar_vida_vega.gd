extends SceneTree

var jogo: Control
var pasta: String = "res://docs/evidencias_vida_vega"


func _initialize() -> void:
	if "--antes" in OS.get_cmdline_user_args():
		pasta += "_antes"
	call_deferred("_capturar")


func _capturar() -> void:
	DirAccess.make_dir_recursive_absolute(pasta)
	root.size = Vector2i(1920, 1080)
	jogo = (load("res://main.tscn") as PackedScene).instantiate() as Control
	root.add_child(jogo)
	await process_frame
	for resolucao: Vector2i in [Vector2i(1920, 1080), Vector2i(1024, 576)]:
		root.size = resolucao
		jogo.call("_iniciar_combate_por_id", "drone_seguranca", false)
		jogo.call("_sincronizar_viewport_com_janela")
		jogo.set("vida_jogador", 40)
		jogo.call("_atualizar_interface")
		await create_timer(0.35).timeout
		await _foto("cheia_%d" % resolucao.x)
		# Caminho real de dano do inimigo, antes das fixtures de apresentação.
		jogo.call("_executar_intencao_inimigo")
		jogo.call("_atualizar_interface")
		await create_timer(0.05).timeout
		await _foto("dano_%d" % resolucao.x)
		for vida: int in [20, 1, 0, 32]:
			jogo.set("vida_jogador", vida)
			jogo.call("_atualizar_interface")
			await create_timer(0.30).timeout
			await _foto("vida_%d_%d" % [vida, resolucao.x])
	jogo.queue_free()
	await process_frame
	quit()


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var caminho: String = "%s/%s.png" % [pasta, nome]
	print("CAPTURA %s: %s" % [caminho, error_string(root.get_texture().get_image().save_png(caminho))])
