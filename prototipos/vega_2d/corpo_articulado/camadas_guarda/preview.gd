extends Node2D
## Inspeção de duas peças, não um novo controlador da personagem.

const REFERENCIA: Texture2D = preload("res://docs/arte_vega/vega_corpo_volume_poses_04.png")
const CAMADAS: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/camadas_guarda/camadas_guarda.tscn")
const FONTE: Font = preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Regular.ttf")
var pecas: CamadasGuardaV1
var fantasma: Sprite2D
var conteudos: Array[Node2D] = []


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
		var referencia := Sprite2D.new()
		referencia.texture = REFERENCIA
		referencia.centered = false
		referencia.region_enabled = true
		referencia.region_rect = Rect2(0, 0, 610, REFERENCIA.get_height())
		conteudo.add_child(referencia)
		if indice == 1:
			fantasma = referencia
			fantasma.modulate.a = .16
			fantasma.hide()
			pecas = CAMADAS.instantiate() as CamadasGuardaV1
			conteudo.add_child(pecas)
	_enquadrar()
	get_viewport().size_changed.connect(_layout)
	_layout()
	if "--capturar" in OS.get_cmdline_user_args():
		_capturar.call_deferred()


func _enquadrar() -> void:
	for conteudo: Node2D in conteudos:
		conteudo.scale = Vector2.ONE * (.8 if pecas.separadas else 1.0)
		conteudo.position = Vector2(-40, -100) if pecas.separadas else Vector2(-60, -160)
	queue_redraw()


func _layout() -> void:
	var janela: Vector2 = get_viewport_rect().size
	var fator: float = minf(janela.x / 1152.0, janela.y / 648.0)
	scale = Vector2.ONE * fator
	position = (janela - Vector2(1152, 648) * fator) * .5


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
	match (event as InputEventKey).keycode:
		KEY_E:
			pecas.separar(not pecas.separadas)
			_enquadrar()
		KEY_T:
			pecas.tronco.visible = not pecas.tronco.visible
		KEY_P:
			pecas.quadril.visible = not pecas.quadril.visible
		KEY_F:
			fantasma.visible = not fantasma.visible
		KEY_O:
			pecas.mostrar_marcos = not pecas.mostrar_marcos
			pecas.queue_redraw()
		KEY_R:
			pecas.tronco.show()
			pecas.quadril.show()
			pecas.ajuste_tronco = Vector2.ZERO
			pecas.ajuste_quadril = Vector2.ZERO
			pecas.recalibrar()
			pecas.separar(false)
			pecas.mostrar_marcos = false
			pecas.queue_redraw()
			fantasma.hide()
			_enquadrar()
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-2000, -2000, 6000, 6000), Color("101722"))
	draw_string(FONTE, Vector2(32, 43), "VEGA / PREPARAÇÃO DAS CAMADAS DA GUARDA", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("e7ecf2"))
	draw_string(FONTE, Vector2(32, 83), "REFERÊNCIA APROVADA / prancha 04", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("97acbc"))
	draw_string(FONTE, Vector2(592, 83), "TRONCO + QUADRIL / camadas da guarda", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("69d6e3"))
	draw_string(FONTE, Vector2(592, 114), "Sem cabeça, braços ou pernas novas nesta etapa", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("efce75"))
	for indice: int in range(2):
		draw_rect(Rect2(32 + indice * 560, 130, 520, 430), Color("24303e"))
	draw_string(FONTE, Vector2(32, 593), "E: separar peças   T: tronco   P: quadril   F: referência translúcida   O: marcos   R: restaurar", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("c3ced8"))
	draw_string(FONTE, Vector2(32, 626), "Registro estático por escala uniforme. Ainda sem animação ou troca da Vega do F5.", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("97acbc"))


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_camadas_guarda_16"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var erro: Error = OK
	for modo: String in ["montadas", "separadas", "tronco", "quadril", "registro"]:
		pecas.tronco.visible = modo != "quadril"
		pecas.quadril.visible = modo != "tronco"
		pecas.separar(modo == "separadas")
		fantasma.visible = modo == "registro"
		pecas.mostrar_marcos = modo == "registro"
		pecas.queue_redraw()
		_enquadrar()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join(modo + ".png"))) as Error
	print("Camadas guarda: capturas ", error_string(erro))
	get_tree().quit(erro)
