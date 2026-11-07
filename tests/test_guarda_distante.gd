extends SceneTree
## Estabilidade/cobertura não substituem revisão artística da guarda.

const NOVA: PackedScene = preload("res://vega_animada/braco_reconstruido/distante/vega_distante.tscn")
const APROVADA: PackedScene = preload("res://vega_animada/braco_reconstruido/ombro_integrado/vega_ombro.tscn")
const SOBREPOSICAO: Script = preload("res://tests/test_encaixe_braco_corpo.gd")
var falhas: int = 0
var amostras_juntas: int = 0
var amostras_gpu: int = 0


func _initialize() -> void:
	_executar.call_deferred()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		if falhas <= 12:
			push_error("GUARDA DISTANTE: " + mensagem)


func _executar() -> void:
	var nova: VegaGuardaDistanteV1 = NOVA.instantiate() as VegaGuardaDistanteV1
	var aprovada: VegaOmbroIntegradoV1 = APROVADA.instantiate() as VegaOmbroIntegradoV1
	for atriz: VegaOmbroIntegradoV1 in [aprovada, nova]:
		atriz.size = Vector2(650, 850)
		root.add_child(atriz)
		atriz.inspecionar(&"respirar", 0)
	var braco: BracoDistanteRegistradoV1 = nova.novo_distante
	var fonte: Image = braco.ARTE_INTERNA.get_image()
	var medida_proxima: Vector2 = _medir_mao(nova.braco_novo, nova.braco_novo.ARTE.get_image())
	var medida_distante: Vector2 = _medir_mao(braco, fonte)
	print("Mãos, comprimento/largura opacos no espaço nativo: próxima ", medida_proxima, "; distante ", medida_distante,
		"; razão ", medida_distante / medida_proxima)
	var razao: Vector2 = medida_distante / medida_proxima
	_verificar(razao.x >= .90 and razao.x <= .95 and razao.y >= .94 and razao.y <= 1.0, "mãos próximas em volume sem eliminar a diferença de projeção")
	_verificar(is_equal_approx(braco.segmentos[2].scale.x, braco.fator_mao_interna * nova.ajuste_mao_distante), "calibração uniforme só da palma")
	_verificar(fonte.get_size() == Vector2i(1024, 1536) and fonte.has_mipmaps(), "fonte real e mipmaps")
	for ponto: Vector2i in [Vector2i(0, 0), Vector2i(1023, 0), Vector2i(0, 1535), Vector2i(1023, 1535)]:
		_verificar(fonte.get_pixelv(ponto).a == 0, "fundo transparente")
	_verificar(braco.get_parent() == nova.modelo.deltoide_distante
		and braco.transform == nova.modelo.braco_distante.transform, "inserção, projeção e profundidade herdadas")
	_verificar(braco.z_index == nova.modelo.braco_distante.z_index
		and not nova.modelo.braco_distante.visible and braco.visible, "uma montagem distante por vez")
	_verificar(braco.segmentos.size() == 3 and braco.segmentos[0].texture != nova.braco_novo.ARTE, "vista interna própria, sem placas soltas")
	var origens: Array[Vector2] = [braco.FONTE_OMBRO, braco.FONTE_COTOVELO, braco.FONTE_PUNHO]
	var destinos: Array[Vector2] = [braco.FONTE_COTOVELO, braco.FONTE_PUNHO, braco.FONTE_PONTA]
	var comprimentos: Array[float] = [braco.SUPERIOR, braco.INFERIOR, braco.MAO]
	for indice: int in range(3):
		_verificar((braco.registros[indice] * origens[indice]).length() < .001, "origem no centro comum")
		_verificar((braco.registros[indice] * destinos[indice]).distance_to(Vector2(comprimentos[indice], 0)) < .001, "registro distal no eixo, sem cisalhamento")
		_verificar(is_equal_approx(braco.registros[indice].x.length(), braco.registros[indice].y.length()), "escala uniforme")
		_verificar(braco.segmentos[indice].texture == braco.ARTE_INTERNA, "três peças da mesma pintura")
	_verificar(braco.segmentos[2].to_global(Vector2.ZERO).distance_to(braco.punho.global_position) < .001, "raiz da palma centrada no punho")
	var polegar: Vector2 = braco.segmentos[2].to_global(braco.registros[2] * Vector2(592, 1324))
	var centro: Vector2 = braco.segmentos[2].to_global(braco.registros[2] * Vector2(500, 1324))
	_verificar(polegar.x < centro.x, "polegar palmar voltado para dentro na guarda")
	_verificar(is_equal_approx(absf(braco.segmentos[2].scale.x), absf(braco.segmentos[2].scale.y)), "palma não achatada")
	_verificar(absf(braco.cotovelo.rotation) <= deg_to_rad(120) + .0001, "folga mínima de 60 graus internos")
	var intersecao: Vector2i = SOBREPOSICAO._sobreposicao_central(braco, fonte, rad_to_deg(braco.cotovelo.rotation))
	_verificar(intersecao.y > 100 and intersecao.x == 0, "ventres pintados não se sobrepõem na faixa central amostrada")
	_verificar(nova.modelo.pele.polygon == aprovada.modelo.pele.polygon
		and nova.modelo.pele.uv == aprovada.modelo.pele.uv, "ombro próximo e corpo aprovados preservados")
	for osso: int in range(nova.modelo.pele.get_bone_count()):
		_verificar(nova.modelo.pele.get_bone_weights(osso) == aprovada.modelo.pele.get_bone_weights(osso), "pesos aprovados intactos")
	for indice: int in range(3):
		_verificar(nova.braco_novo.segmentos[indice].global_transform.is_equal_approx(aprovada.braco_novo.segmentos[indice].global_transform)
			and nova.braco_novo.segmentos[indice].polygon == aprovada.braco_novo.segmentos[indice].polygon
			and nova.braco_novo.segmentos[indice].uv == aprovada.braco_novo.segmentos[indice].uv, "montagem próxima intacta")
	for nome: StringName in aprovada.modelo.animacao.get_animation_list():
		var a: Animation = aprovada.modelo.animacao.get_animation(nome)
		var b: Animation = nova.modelo.animacao.get_animation(nome)
		_verificar(a.length == b.length, "clipes sem adaptação de movimento distante")
		for trilha: int in range(a.get_track_count()):
			_verificar(a.track_get_path(trilha) == b.track_get_path(trilha), "destinos das trilhas aprovadas intactos")
			for chave: int in range(a.track_get_key_count(trilha)):
				_verificar(a.track_get_key_value(trilha, chave) == b.track_get_key_value(trilha, chave), "chaves aprovadas intactas")
	# Cobertura CPU só das três peças novas: o torso não pode esconder um vão.
	for osso: Bone2D in [braco.ombro, braco.cotovelo, braco.punho]:
		for x: int in range(-6, 7, 2):
			for y: int in range(-4, 5, 2):
				var ponto: Vector2 = osso.to_global(Vector2(x, y))
				_verificar(_pintado(braco, fonte, ponto), "continuidade da própria prótese na junta")
				amostras_juntas += 1
	# Ponte punho–palma ampliada: conferir além do centro, sem apoio do torso.
	for x: int in range(-6, 13, 2):
		for y: int in range(-6, 7, 2):
			_verificar(_pintado(braco, fonte, braco.punho.to_global(Vector2(x, y))), "ponte punho–palma contínua após ampliar")
			amostras_juntas += 1
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var viewport: SubViewport = nova.composicao.get_node("Desenho") as SubViewport
		var render: Image = viewport.get_texture().get_image()
		for osso: Bone2D in [braco.ombro, braco.cotovelo, braco.punho]:
			for x: int in range(-6, 7, 2):
				for y: int in range(-4, 5, 2):
					var ponto: Vector2i = Vector2i(osso.to_global(Vector2(x, y)).round())
					_verificar(render.get_pixelv(ponto).a > .9, "cobertura renderizada das juntas")
					amostras_gpu += 1
		for x: int in range(-6, 13, 2):
			for y: int in range(-6, 7, 2):
				var ponto: Vector2i = Vector2i(braco.punho.to_global(Vector2(x, y)).round())
				_verificar(render.get_pixelv(ponto).a > .9, "GPU: ponte punho–palma ampliada")
				amostras_gpu += 1
	nova.comparar_distante(true)
	_verificar(nova.modelo.braco_distante.visible and not braco.visible, "comparador mostra só o antigo distante")
	nova.comparar_distante(false)
	_verificar(not nova.modelo.braco_distante.visible and braco.visible and nova.braco_novo.visible, "comparador preserva o próximo")
	var punho: Transform2D = braco.punho.global_transform
	for quadro: int in range(12):
		await process_frame
	_verificar(not nova.modelo.animacao.is_playing() and punho.is_equal_approx(braco.punho.global_transform), "12 quadros estáticos sem disputa com animador")
	print("Guarda distante: ", falhas, " falhas; ", amostras_juntas, " pontos CPU das juntas; ", amostras_gpu,
		" pontos GPU; sobreposição central ", intersecao)
	nova.free()
	aprovada.free()
	await process_frame
	quit(0 if falhas == 0 else 1)


func _pintado(braco: BracoDistanteRegistradoV1, fonte: Image, mundo: Vector2) -> bool:
	for indice: int in range(3):
		var uv: Vector2 = braco.registros[indice].affine_inverse() * braco.segmentos[indice].to_local(mundo)
		if not Geometry2D.is_point_in_polygon(uv, braco.segmentos[indice].uv):
			continue
		var pixel: Vector2i = Vector2i(uv.round())
		if Rect2i(Vector2i.ZERO, fonte.get_size()).has_point(pixel) and fonte.get_pixelv(pixel).a > .9:
			return true
	return false


func _medir_mao(braco: BracoRegistradoV1, fonte: Image) -> Vector2:
	# Mede só tinta da mão, em eixos do punho: giro da guarda não infla o bbox.
	var malha: Polygon2D = braco.segmentos[2]
	var minimo := Vector2(INF, INF)
	var maximo := Vector2(-INF, -INF)
	var projecao: float = (malha.get_parent() as Node2D).global_transform.x.length()
	for y: int in range(1190, fonte.get_height(), 2):
		for x: int in range(280, 751, 2):
			var uv := Vector2(x, y)
			if fonte.get_pixel(x, y).a < .9 or not Geometry2D.is_point_in_polygon(uv, malha.uv):
				continue
			var ponto: Vector2 = (malha.transform * (braco.registros[2] * uv)) * projecao
			minimo = minimo.min(ponto)
			maximo = maximo.max(ponto)
	return maximo - minimo
