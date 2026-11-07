extends SceneTree

const PASTA: String = "res://docs/evidencias_vega_combate_v2_maos"
var jogo: Control
var falhas: int = 0


func _initialize() -> void:
	call_deferred("_executar")


func _executar() -> void:
	DirAccess.make_dir_recursive_absolute(PASTA)
	jogo = (load("res://main.tscn") as PackedScene).instantiate() as Control
	# Capturador histórico da montagem v2; não substituir suas evidências pelo rig novo.
	jogo.cena_apresentacao_vega = preload("res://prototipos/vega_2d/combate_v2/vega_combate.tscn")
	root.add_child(jogo)
	await process_frame
	var resolucoes: Array[Vector2i] = [Vector2i(1920, 1080), Vector2i(1024, 576)]
	var filmar: bool = "--filmar" in OS.get_cmdline_user_args()
	if filmar:
		resolucoes.assign([Vector2i(1152, 648)])
	for resolucao: Vector2i in resolucoes:
		root.size = resolucao
		root.content_scale_size = resolucao
		jogo.call("_sincronizar_viewport_com_janela")
		jogo.call("_iniciar_combate_por_id", "drone_carga", false)
		await create_timer(.6).timeout
		var vega: VegaCombateV2 = jogo.vega_animada as VegaCombateV2
		if filmar:
			jogo.call("_limpar_mao")
			jogo.baralho_combate.compra.assign(["direto_hidraulico", "direto_hidraulico", "quebra_chassi"])
			jogo.call("_comprar_cartas", 3)
			await create_timer(.8).timeout
			for id: String in ["direto_hidraulico", "direto_hidraulico", "quebra_chassi"]:
				for carta: Button in jogo.mao.get_children():
					if str(carta.get_meta("id_carta")) == id:
						carta.button_pressed = true
						break
				jogo.call("_jogar_carta", "inimigo", 0)
				await create_timer(.9).timeout
			vega.receber_dano()
			await create_timer(.8).timeout
		else:
			for combo: int in [0, 5, 10]:
				jogo.combo = combo
				jogo.call("_atualizar_interface")
				await create_timer(.3).timeout
				await _foto("repouso_combo_%d_%d" % [combo, resolucao.x])
			vega.socar()
			vega.movimento.pause()
			vega.movimento.custom_step(.1)
			await _foto("preparo_%d" % resolucao.x)
			vega.movimento.custom_step(.1)
			await _foto("extensao_%d" % resolucao.x)
			vega.movimento.custom_step(.2)
			await _foto("retorno_%d" % resolucao.x)
			vega.movimento.custom_step(.2)
			await _foto("repouso_apos_soco_%d" % resolucao.x)
			vega.receber_dano()
			vega.movimento.pause()
			vega.movimento.custom_step(.1)
			await _foto("dano_%d" % resolucao.x)
	jogo.queue_free()
	await process_frame
	quit(0 if falhas == 0 else 1)


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var erro: Error = root.get_texture().get_image().save_png("%s/%s.png" % [PASTA, nome])
	if erro != OK:
		falhas += 1
	print("CAPTURA VEGA COMBATE %s: %s" % [nome, error_string(erro)])
