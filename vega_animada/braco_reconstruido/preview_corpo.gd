extends Node2D
## Inspeção estática do encaixe. A compara; O mostra marcos. Sem ações de combate.

const VEGA: PackedScene = preload("res://vega_animada/braco_reconstruido/vega_encaixe.tscn")
const FONTE: Font = preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Regular.ttf")
var vega: VegaEncaixeBracoV1


func _ready() -> void:
	vega = VEGA.instantiate() as VegaEncaixeBracoV1
	vega.size = Vector2(650, 850)
	vega.position = Vector2(80, 110)
	vega.scale = Vector2.ONE * .56
	add_child(vega)
	get_viewport().size_changed.connect(_layout)
	_layout()
	if "--capturar" in OS.get_cmdline_user_args():
		_capturar.call_deferred()


func _layout() -> void:
	var area: Vector2 = get_viewport_rect().size
	var fator: float = minf(area.x / 1152.0, area.y / 648.0)
	scale = Vector2.ONE * fator
	position = (area - Vector2(1152, 648) * fator) * .5
	queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match (event as InputEventKey).keycode:
			KEY_A:
				vega.comparar(not vega.comparar_anterior)
				queue_redraw()
			KEY_O:
				vega.mostrar_marcos(not vega.braco_novo.mostrar_marcos)


func _draw() -> void:
	draw_rect(Rect2(-2000, -2000, 6000, 6000), Color("101722"))
	draw_string(FONTE, Vector2(48, 55), "VEGA / ENCAIXE NO CORPO", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("e7ecf2"))
	draw_string(FONTE, Vector2(48, 84), "Guarda estática • um braço novo • apresentação do jogo preservada", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("97acbc"))
	var anterior: bool = is_instance_valid(vega) and vega.comparar_anterior
	draw_string(FONTE, Vector2(560, 170), "BRAÇO ANTERIOR" if anterior else "BRAÇO RECONSTRUÍDO", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("69d6e3"))
	draw_string(FONTE, Vector2(560, 216), "Preso ao deltoide do rig existente.", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("c3ced8"))
	var descricao: String = "Guarda anterior preservada para comparação." if anterior else "Guarda candidata: ombro %d° / cotovelo %d°." % [roundi(vega.angulo_ombro), roundi(vega.angulo_cotovelo)]
	draw_string(FONTE, Vector2(560, 250), descricao, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("97acbc"))
	var mao: String = "Montagem anterior preservada." if anterior else "Mão: escala 76%, polegar do lado oposto."
	draw_string(FONTE, Vector2(560, 284), mao, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("97acbc"))
	draw_string(FONTE, Vector2(560, 354), "A: comparar com o braço anterior", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("c3ced8"))
	draw_string(FONTE, Vector2(560, 390), "O: mostrar os centros das juntas", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("c3ced8"))
	draw_string(FONTE, Vector2(560, 465), "Conferir a inserção na pele, a folga da dobra", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("97acbc"))
	draw_string(FONTE, Vector2(560, 491), "e a posição do punho junto ao rosto.", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("97acbc"))
	draw_string(FONTE, Vector2(48, 626), "Ainda sem adaptar o segundo lado, Combo ou movimento da nova montagem. F5 não foi alterado.", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("97acbc"))


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_dobra_cotovelo_04"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var erro: Error = OK
	for anterior: bool in [false, true]:
		vega.comparar(anterior)
		queue_redraw()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var nome: String = "anterior.png" if anterior else "guarda.png"
		erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join(nome))) as Error
	vega.comparar(false)
	vega.mostrar_marcos(true)
	queue_redraw()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	erro = maxi(erro, get_viewport().get_texture().get_image().save_png(pasta.path_join("marcos.png"))) as Error
	vega.mostrar_marcos(false)
	await RenderingServer.frame_post_draw
	# Recorte de evidência do render nativo, não edição da textura da personagem.
	var desenho: SubViewport = vega.composicao.get_node("Desenho") as SubViewport
	var imagem: Image = desenho.get_texture().get_image()
	var origem: Vector2i = Vector2i(vega.braco_novo.global_position.round()) - Vector2i(100, 180)
	var regiao: Rect2i = Rect2i(origem, Vector2i(370, 410)).intersection(Rect2i(Vector2i.ZERO, imagem.get_size()))
	erro = maxi(erro, imagem.get_region(regiao).save_png(pasta.path_join("encaixe_zoom.png"))) as Error
	print("Capturas do encaixe corporal: ", error_string(erro))
	get_tree().quit(erro)
