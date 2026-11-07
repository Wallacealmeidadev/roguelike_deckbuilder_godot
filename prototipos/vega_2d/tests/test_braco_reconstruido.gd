extends SceneTree
## Registro geométrico não é aprovação artística da perspectiva das juntas.

const BRACO: Script = preload("res://prototipos/vega_2d/braco_reconstruido/braco_registrado.gd")
var falhas: int = 0


func _initialize() -> void:
	_executar.call_deferred()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("BRAÇO RECONSTRUÍDO: " + mensagem)


func _executar() -> void:
	var braco: BracoRegistradoV1 = BRACO.new() as BracoRegistradoV1
	root.add_child(braco)
	var anterior: BracoNativoV2 = (load("res://vega_animada/rig_nativo_v2/braco_encaixado.tscn") as PackedScene).instantiate() as BracoNativoV2
	root.add_child(anterior)
	anterior.visible = false
	_verificar(is_equal_approx(braco.SUPERIOR, anterior.ombro.length)
		and is_equal_approx(braco.INFERIOR, anterior.cotovelo.length)
		and is_equal_approx(braco.MAO, anterior.punho.length), "mesmos três comprimentos do rig anterior")
	_verificar(braco.segmentos.size() == 3, "somente três segmentos; nenhuma placa solta")
	var origens: Array[Vector2] = [braco.OMBRO_FONTE, braco.COTOVELO_FONTE, braco.PUNHO_FONTE]
	var destinos: Array[Vector2] = [braco.COTOVELO_FONTE, braco.PUNHO_FONTE, braco.PONTA_FONTE]
	var comprimentos: Array[float] = [braco.SUPERIOR, braco.INFERIOR, braco.MAO]
	for i: int in range(3):
		var registro: Transform2D = braco.registros[i]
		_verificar((registro * origens[i]).length() < .001, "raiz do desenho coincide com osso")
		_verificar((registro * destinos[i]).distance_to(Vector2(comprimentos[i], 0)) < .001,
			"ponta registrada, sem deslocamento independente")
		_verificar(absf(registro.x.length() - registro.y.length()) < .00001,
			"calibração uniforme, sem achatamento lateral")
		_verificar(braco.segmentos[i].texture == braco.ARTE, "mesma fonte montada para todas as peças")
		_verificar(braco.segmentos[i].polygon.size() == braco.segmentos[i].uv.size(), "UV de cada vértice explícito")
	var osso_superior: Transform2D
	var osso_inferior: Transform2D
	for pose: StringName in [&"neutro", &"guarda", &"extensao"]:
		braco.definir_pose(pose)
		if pose != &"neutro":
			anterior.definir_pose(pose, true)
			_verificar(is_equal_approx(braco.ombro.rotation, anterior.ombro.rotation)
				and is_equal_approx(braco.cotovelo.rotation, anterior.cotovelo.rotation)
				and is_equal_approx(braco.punho.rotation, anterior.punho.rotation), "mesmos ângulos da prova anterior")
		osso_superior = braco.ombro.global_transform
		osso_inferior = braco.cotovelo.global_transform
		_verificar((osso_superior * (braco.registros[0] * braco.COTOVELO_FONTE)).distance_to(
			osso_inferior * (braco.registros[1] * braco.COTOVELO_FONTE)) < .001, "cotovelo compartilha centro em " + str(pose))
		_verificar((osso_inferior * (braco.registros[1] * braco.PUNHO_FONTE)).distance_to(
			braco.punho.global_transform * (braco.registros[2] * braco.PUNHO_FONTE)) < .001,
			"punho compartilha centro em " + str(pose))
		_verificar(is_equal_approx(braco.cotovelo.position.x, braco.SUPERIOR)
			and is_equal_approx(braco.punho.position.x, braco.INFERIOR), "comprimentos fixos")
	# Regressão da primeira captura: mão com z negativo ficava sob o fundo da prancha.
	var camada: int = 0
	var ancestral: Node = braco.segmentos[2]
	while ancestral != braco:
		if ancestral is CanvasItem:
			camada += (ancestral as CanvasItem).z_index
		ancestral = ancestral.get_parent()
	_verificar(camada > 0, "mão acima do fundo, contando ancestrais reais e não malhas irmãs")
	_verificar(Geometry2D.is_point_in_polygon(Vector2(520, 1350), braco.segmentos[2].uv),
		"punho pintado incluído no recorte da mão")
	var imagem: Image = braco.ARTE.get_image()
	for ponto: Vector2i in [Vector2i(558, 650), Vector2i(550, 1190), Vector2i(520, 1350)]:
		_verificar(imagem.get_pixelv(ponto).a > .95, "marcos usam pintura opaca")
	var amostras: int = 0
	if DisplayServer.get_name() != "headless":
		var viewport := SubViewport.new()
		viewport.size = Vector2i(900, 800)
		viewport.transparent_bg = true
		viewport.world_2d = World2D.new()
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		braco.reparent(viewport, false)
		braco.position = Vector2(350, 350)
		for pose: StringName in [&"neutro", &"guarda", &"extensao"]:
			braco.definir_pose(pose)
			await RenderingServer.frame_post_draw
			var render: Image = viewport.get_texture().get_image()
			var pontos: Array[Vector2] = [braco.cotovelo.global_position, braco.punho.global_position,
				braco.punho.global_transform * (braco.registros[2] * Vector2(520, 1350))]
			for ponto: Vector2 in pontos:
				_verificar(render.get_pixelv(Vector2i(ponto.round())).a > .9, "GPU: junta/mão presente em " + str(pose))
				amostras += 1
		braco.free()
		viewport.free()
	else:
		braco.free()
	anterior.free()
	print("Braço reconstruído: ", falhas, " falhas (3 poses, 3 registros, ", amostras, " amostras GPU)")
	quit(0 if falhas == 0 else 1)
