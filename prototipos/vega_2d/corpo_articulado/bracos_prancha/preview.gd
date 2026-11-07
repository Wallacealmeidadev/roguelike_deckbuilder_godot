extends "res://prototipos/vega_2d/corpo_articulado/guarda_montada/preview.gd"
## Comparação de arte estática. Nenhuma promessa de rig ou áreas ocultas.

const CENA_FIEL: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/bracos_prancha/vega_fiel.tscn")
var fiel: VegaBracosPranchaV1


func _ready() -> void:
	if "--capturar" in OS.get_cmdline_user_args():
		get_tree().create_timer(15).timeout.connect(func() -> void:
			push_error("Captura da prancha excedeu 15 s")
			get_tree().quit(1))
	for indice: int in range(2):
		var painel := Control.new()
		painel.position = Vector2(32 + indice * 560, 130)
		painel.size = Vector2(520, 430)
		painel.clip_contents = true
		painel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(painel)
		var conteudo := Node2D.new()
		painel.add_child(conteudo)
		conteudos.append(conteudo)
		if indice == 0:
			prancha = Sprite2D.new()
			prancha.texture = REFERENCIA
			prancha.centered = false
			prancha.region_enabled = true
			prancha.region_rect = Rect2(0, 60, 610, REFERENCIA.get_height() - 60)
			prancha.position.y = 60
			conteudo.add_child(prancha)
		else:
			fiel = CENA_FIEL.instantiate() as VegaBracosPranchaV1
			vega = fiel
			conteudo.add_child(fiel)
	_enquadrar()
	get_viewport().size_changed.connect(_layout)
	_layout()
	if "--capturar" in OS.get_cmdline_user_args():
		_capturar.call_deferred()


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	match (event as InputEventKey).keycode:
		KEY_H:
			fiel.definir_pintura_hq(not fiel.pintura_hq_ativa)
			queue_redraw()
		KEY_A:
			fiel.definir_ajuste(not fiel.ajuste_ativo)
			queue_redraw()
		KEY_V:
			fiel.definir_volume(not fiel.volume_ativo)
			queue_redraw()
		KEY_B:
			fiel.recorte_proximo.visible = not fiel.recorte_proximo.visible
			fiel.recorte_distante.visible = fiel.recorte_proximo.visible
			fiel.cap_proxima.visible = fiel.recorte_proximo.visible and fiel.ajuste_ativo
		KEY_R:
			for peca: CanvasItem in [fiel.cabeca, fiel.tronco, fiel.quadril, fiel.recorte_proximo, fiel.recorte_distante]:
				peca.show()
			fiel.mostrar_juntas(false)
			fiel.definir_ajuste(true)
			fiel.definir_volume(true)
			fiel.definir_pintura_hq(true)
			ampliada = false
			_enquadrar()
		_:
			super._unhandled_key_input(event)
	# A prova antiga nunca reaparece sobre a pintura da prancha.
	fiel.proximo.hide()
	fiel.distante.hide()


func _draw() -> void:
	draw_rect(Rect2(-2000, -2000, 6000, 6000), Color("101722"))
	draw_string(FONTE, Vector2(32, 43), "VEGA / FIDELIDADE DA ARTE DOS BRAÇOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("e7ecf2"))
	draw_string(FONTE, Vector2(32, 83), "PRANCHA 04 / fonte aprovada", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("97acbc"))
	draw_string(FONTE, Vector2(592, 83), "ENCAIXE PRÓXIMO / " + ("ajustado" if is_instance_valid(fiel) and fiel.ajuste_ativo else "antes"), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("69d6e3"))
	draw_string(FONTE, Vector2(592, 114), "H: pintura " + ("HQ" if is_instance_valid(fiel) and fiel.pintura_hq_ativa else "original") + " · V: volume · A: encaixe · estático", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("efce75"))
	for indice: int in range(2):
		draw_rect(Rect2(32 + indice * 560, 130, 520, 430), Color("24303e"))
	draw_string(FONTE, Vector2(32, 593), "Z: ampliar   B: braços   C: cabeça   T: tronco   P: quadril   O: encaixes   R: restaurar", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("c3ced8"))
	draw_string(FONTE, Vector2(32, 626), "Próximo registrado pelo aro inteiro. Distante, rosto, regata e versão animada preservados. F5 anterior.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("97acbc"))


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_bracos_prancha_18/hq"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var erro: Error = OK
	for modo: String in ["guarda", "ampliada", "isolados", "encaixes", "antes", "ombro", "sem_volume", "distante", "pintura_original"]:
		fiel.definir_pintura_hq(modo != "pintura_original")
		fiel.definir_ajuste(modo != "antes")
		fiel.definir_volume(modo != "sem_volume")
		fiel.tronco.visible = modo != "isolados"
		fiel.quadril.visible = modo != "isolados"
		fiel.cabeca.visible = modo != "isolados"
		fiel.mostrar_juntas(modo == "encaixes")
		ampliada = modo in ["ampliada", "isolados", "antes", "sem_volume", "pintura_original"]
		_enquadrar()
		if modo == "ombro":
			for conteudo: Node2D in conteudos:
				conteudo.scale = Vector2.ONE * 3.2
				conteudo.position = Vector2(-430, -600)
		if modo == "distante":
			for conteudo: Node2D in conteudos:
				conteudo.scale = Vector2.ONE * 3.2
				conteudo.position = Vector2(-1100, -510)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join(modo + ".png"))) as Error
	print("Braços da prancha: capturas ", error_string(erro))
	get_tree().quit(erro)
