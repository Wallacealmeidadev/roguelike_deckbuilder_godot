extends SceneTree

var pasta: String = "res://docs/evidencias_vega_nativa_combate"
var jogo: Control
var falhas: int = 0


func _initialize() -> void:
	call_deferred("_executar")


func _executar() -> void:
	if "--ajuste-repouso" in OS.get_cmdline_user_args():
		pasta = "res://docs/evidencias_vega_repouso_22"
	if "--guarda-viva" in OS.get_cmdline_user_args():
		pasta = "res://docs/evidencias_vega_guarda_viva_22"
	if "--alternar" in OS.get_cmdline_user_args():
		pasta = "res://docs/evidencias_vega_alternancia_22"
	if "--acabamento" in OS.get_cmdline_user_args():
		pasta = "res://docs/evidencias_vega_acabamento_proximo_01"
	if "--face-interna" in OS.get_cmdline_user_args():
		pasta = "res://docs/evidencias_vega_face_interna_01"
	if "--recorte-filtro" in OS.get_cmdline_user_args():
		pasta = "res://docs/evidencias_vega_recorte_filtro_01"
	if "--punhos" in OS.get_cmdline_user_args():
		pasta = "res://docs/evidencias_vega_soquetes_01"
	if "--juntas" in OS.get_cmdline_user_args():
		pasta = "res://docs/evidencias_vega_juntas_01"
	DirAccess.make_dir_recursive_absolute(pasta)
	jogo = (load("res://main.tscn") as PackedScene).instantiate() as Control
	if "--acabamento" in OS.get_cmdline_user_args():
		jogo.cena_apresentacao_vega = load("res://prototipos/vega_2d/rig_nativo_v2/acabamento_proximo/vega_prova.tscn") as PackedScene
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
		var vega: VegaCombateNativo = jogo.vega_animada as VegaCombateNativo
		if filmar:
			jogo.call("_limpar_mao")
			jogo.baralho_combate.compra.assign(["direto_hidraulico", "direto_hidraulico", "quebra_chassi"])
			jogo.call("_comprar_cartas", 3)
			await create_timer(2.6 if "--guarda-viva" in OS.get_cmdline_user_args() else .7).timeout
			for id: String in ["direto_hidraulico", "direto_hidraulico", "quebra_chassi"]:
				_selecionar(id)
				jogo.call("_jogar_carta", "inimigo", 0)
				await create_timer(.75).timeout
			if "--guarda-viva" in OS.get_cmdline_user_args():
				await create_timer(2.4).timeout
			vega.receber_dano()
			await create_timer(2.6 if "--guarda-viva" in OS.get_cmdline_user_args() else .7).timeout
		else:
			if "--guarda-viva" in OS.get_cmdline_user_args():
				vega.modelo.animacao.pause()
				for tempo: float in [0.0, 1.2, 2.4]:
					vega.modelo.animacao.seek(tempo, true)
					await _foto("guarda_respiro_%03d_%d" % [int(tempo * 100), resolucao.x])
				vega.modelo.animacao.play(&"respirar")
			for valor: int in [0, 5, 10]:
				jogo.combo = valor
				jogo.call("_atualizar_interface")
				await create_timer(.3).timeout
				await _foto("repouso_combo%d_%d" % [valor, resolucao.x])
			vega.socar()
			vega.modelo.animacao.pause()
			for tempo: float in [.1, .2, .36, .56]:
				vega.modelo.animacao.seek(tempo, true)
				await _foto("soco_%03d_%d" % [int(tempo * 100), resolucao.x])
			if "--alternar" in OS.get_cmdline_user_args():
				vega.socar()
				vega.modelo.animacao.pause()
				for tempo: float in [.1, .2, .36, .56]:
					vega.modelo.animacao.seek(tempo, true)
					await _foto("soco_distante_%03d_%d" % [int(tempo * 100), resolucao.x])
			vega.receber_dano()
			vega.modelo.animacao.pause()
			vega.modelo.animacao.seek(.1, true)
			vega.movimento.pause()
			vega.movimento.custom_step(.1)
			await _foto("dano_%d" % resolucao.x)
			jogo.call("_abrir_configuracoes")
			await _foto("configuracoes_%d" % resolucao.x)
			jogo.call("_fechar_configuracoes")
	jogo.queue_free()
	await process_frame
	quit(0 if falhas == 0 else 1)


func _selecionar(id: String) -> void:
	for carta: Button in jogo.mao.get_children():
		if str(carta.get_meta("id_carta")) == id:
			carta.button_pressed = true
			return


func _foto(nome: String) -> void:
	await RenderingServer.frame_post_draw
	var erro: Error = root.get_texture().get_image().save_png("%s/%s.png" % [pasta, nome])
	if erro != OK:
		falhas += 1
	print("CAPTURA VEGA NATIVA %s: %s" % [nome, error_string(erro)])
	if nome.begins_with("repouso_combo0") or nome.begins_with("soco_020") or nome.begins_with("soco_distante_020") or nome.begins_with("guarda_respiro"):
		var vega: VegaCombateNativo = jogo.vega_animada as VegaCombateNativo
		erro = vega.modelo.get_viewport().get_texture().get_image().save_png("%s/detalhe_%s.png" % [pasta, nome])
		if erro != OK:
			falhas += 1
		print("CAPTURA DETALHE %s: %s" % [nome, error_string(erro)])
