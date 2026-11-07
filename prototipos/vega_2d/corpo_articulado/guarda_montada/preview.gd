extends Node2D
## Mesma bancada de inspeção, agora com os membros. Sem movimento nesta prova.

const CENA: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/guarda_montada/vega_guarda.tscn")
const REFERENCIA: Texture2D = preload("res://docs/arte_vega/vega_corpo_volume_poses_04.png")
const APROVADA: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/combo_fibras/vega_combo.tscn")
const FONTE: Font = preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Regular.ttf")
var vega: VegaGuardaMontadaV1
var conteudos: Array[Node2D] = []
var ampliada: bool = false
var atriz_aprovada: VegaComboFibrasV1
var referencia_nativa: Sprite2D
var prancha: Sprite2D
var ver_prancha: bool = true


func _ready() -> void:
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
			var referencia := Sprite2D.new()
			referencia.texture = REFERENCIA
			referencia.centered = false
			referencia.region_enabled = true
			referencia.region_rect = Rect2(0, 60, 610, REFERENCIA.get_height() - 60)
			referencia.position.y = 60
			prancha = referencia
			prancha.hide()
			conteudo.add_child(referencia)
		else:
			vega = CENA.instantiate() as VegaGuardaMontadaV1
			conteudo.add_child(vega)
	_preparar_referencia_nativa()
	_enquadrar()
	get_viewport().size_changed.connect(_layout)
	_layout()
	if "--capturar" in OS.get_cmdline_user_args():
		_capturar.call_deferred()


func _layout() -> void:
	var janela: Vector2 = get_viewport_rect().size
	var fator: float = minf(janela.x / 1152.0, janela.y / 648.0)
	scale = Vector2.ONE * fator
	position = (janela - Vector2(1152, 648) * fator) * .5


func _preparar_referencia_nativa() -> void:
	# Instância de referência intacta; apenas amostrada/pausada. Sua textura
	# de viewport é registrada no mesmo par de ombros da candidata.
	atriz_aprovada = APROVADA.instantiate() as VegaComboFibrasV1
	atriz_aprovada.size = Vector2(650, 850)
	atriz_aprovada.position = Vector2(-10000, -10000)
	add_child(atriz_aprovada)
	atriz_aprovada.definir_combo_visual(0, true)
	atriz_aprovada.inspecionar_presenca(false, 0)
	var desenho: SubViewport = atriz_aprovada.composicao.get_node("Desenho") as SubViewport
	desenho.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	referencia_nativa = Sprite2D.new()
	referencia_nativa.texture = desenho.get_texture()
	referencia_nativa.centered = false
	referencia_nativa.transform = vega.registro_bracos * atriz_aprovada.modelo.transform.affine_inverse()
	conteudos[0].add_child(referencia_nativa)
	prancha.visible = ver_prancha
	referencia_nativa.visible = not ver_prancha


func _enquadrar() -> void:
	for conteudo: Node2D in conteudos:
		conteudo.scale = Vector2.ONE * (1.2 if ampliada else .8)
		conteudo.position = Vector2(-100, -35) if ampliada else Vector2(0, -35)
	queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	match (event as InputEventKey).keycode:
		KEY_V:
			ver_prancha = not ver_prancha
			prancha.visible = ver_prancha
			referencia_nativa.visible = not ver_prancha
			queue_redraw()
		KEY_O:
			vega.mostrar_juntas(not vega.mostrar_marcos)
		KEY_B:
			vega.proximo.visible = not vega.proximo.visible
			vega.distante.visible = vega.proximo.visible
		KEY_C:
			vega.cabeca.visible = not vega.cabeca.visible
		KEY_T:
			vega.tronco.visible = not vega.tronco.visible
		KEY_P:
			vega.quadril.visible = not vega.quadril.visible
		KEY_Z:
			ampliada = not ampliada
			_enquadrar()
		KEY_R:
			for peca: CanvasItem in [vega.cabeca, vega.proximo, vega.distante, vega.tronco, vega.quadril]:
				peca.show()
			vega.mostrar_juntas(false)
			ampliada = false
			ver_prancha = true
			prancha.show()
			referencia_nativa.hide()
			_enquadrar()


func _draw() -> void:
	draw_rect(Rect2(-2000, -2000, 6000, 6000), Color("101722"))
	draw_string(FONTE, Vector2(32, 43), "VEGA / MONTAGEM ESTÁTICA DA GUARDA", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("e7ecf2"))
	draw_string(FONTE, Vector2(32, 83), "PRANCHA 04 / conceito" if ver_prancha else "GUARDA APROVADA / prova 15, Combo zero", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("97acbc"))
	draw_string(FONTE, Vector2(592, 83), "CAMADAS APROVADAS + CABEÇA E BRAÇOS", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("69d6e3"))
	draw_string(FONTE, Vector2(592, 114), "Encaixes candidatos; ainda sem animação ou pernas novas", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("efce75"))
	for indice: int in range(2):
		draw_rect(Rect2(32 + indice * 560, 130, 520, 430), Color("24303e"))
	draw_string(FONTE, Vector2(32, 593), "V: referência   O: juntas   Z: ampliar   B: braços   C: cabeça   T: tronco   P: quadril   R: restaurar", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("c3ced8"))
	draw_string(FONTE, Vector2(32, 626), "Fontes preservadas. Recortes e sobreposição nativos da Godot. F5 permanece inalterado.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("97acbc"))


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_guarda_montada_17"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var erro: Error = OK
	for modo: String in ["guarda", "juntas", "ampliada", "sem_tronco", "prancha", "prancha_ampliada"]:
		ver_prancha = modo.begins_with("prancha")
		prancha.visible = ver_prancha
		referencia_nativa.visible = not ver_prancha
		vega.mostrar_juntas(modo == "juntas")
		vega.tronco.visible = modo != "sem_tronco"
		ampliada = modo in ["ampliada", "prancha_ampliada"]
		_enquadrar()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join(modo + ".png"))) as Error
	print("Guarda montada: capturas ", error_string(erro))
	get_tree().quit(erro)
