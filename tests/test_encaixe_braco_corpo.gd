extends SceneTree
## Prova estática; alinhamento e cobertura não equivalem a aprovação artística.

const CANDIDATA: PackedScene = preload("res://vega_animada/braco_reconstruido/vega_encaixe.tscn")
const ANTERIOR: PackedScene = preload("res://vega_animada/rig_nativo_v2/acabamento_proximo/vega_prova.tscn")
var falhas: int = 0


func _initialize() -> void:
	_executar.call_deferred()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("ENCAIXE CORPORAL: " + mensagem)


func _executar() -> void:
	var candidata: VegaEncaixeBracoV1 = CANDIDATA.instantiate() as VegaEncaixeBracoV1
	candidata.size = Vector2(650, 850)
	root.add_child(candidata)
	var anterior: VegaAcabamentoProximo = ANTERIOR.instantiate() as VegaAcabamentoProximo
	anterior.size = candidata.size
	root.add_child(anterior)
	anterior.modelo.animacao.play(&"respirar", 0)
	anterior.modelo.animacao.seek(0, true)
	anterior.modelo.animacao.pause()
	anterior.hide()
	# Ocultar a apresentação chama sua desativação; reaplicar a amostra comparada.
	anterior.modelo.animacao.play(&"respirar", 0)
	anterior.modelo.animacao.seek(0, true)
	anterior.modelo.animacao.pause()
	var novo: BracoRegistradoV1 = candidata.braco_novo
	var modelo: ApoioCorporalNativoV2 = candidata.modelo
	_verificar(novo.get_parent() == modelo.deltoide, "prótese ligada ao deltoide existente")
	_verificar(novo.transform.is_equal_approx(modelo.braco_original.transform), "encaixe herdado, sem deslocar a raiz")
	_verificar(novo.global_position.distance_to(modelo.braco_original.global_position) < .001, "mesma âncora global do ombro")
	_verificar(not modelo.braco_original.is_visible_in_tree() and novo.is_visible_in_tree(), "braço antigo oculto por inteiro")
	_verificar(novo.segmentos.size() == 3, "três peças registradas, sem placas extras")
	for indice: int in [0, 1]:
		_verificar(novo.segmentos[indice].transform == Transform2D.IDENTITY
			and novo.segmentos[indice].texture == novo.ARTE, "correção não reflete ou redimensiona o resto do braço")
	var mao: Polygon2D = novo.segmentos[2]
	_verificar(mao.position == Vector2.ZERO and is_zero_approx(mao.rotation), "correção da mão não desloca a raiz nem gira dedos para trás")
	_verificar(mao.scale.is_equal_approx(Vector2(.76, -.76)), "mão reduzida uniformemente e refletida só transversalmente")
	_verificar(mao.to_global(Vector2.ZERO).distance_to(novo.punho.global_position) < .001,
		"reflexão e escala preservam o centro compartilhado do punho")
	var marco: Vector2 = novo.registros[2] * Vector2(520, 1350)
	_verificar((mao.transform * marco).x > 0 and is_equal_approx((mao.transform * marco).x, marco.x * .76),
		"dedos continuam para frente após reflexão")
	var mao_inferior: float = (novo.PUNHO_FONTE - novo.COTOVELO_FONTE).length()
	var escala_fonte_mao: float = novo.registros[2].x.length() * .76
	_verificar(absf(escala_fonte_mao / (novo.INFERIOR / mao_inferior) - 1.0) < .02,
		"mão recupera a escala raster do antebraço, sem aumento de 33%")
	_verificar(is_equal_approx(novo.cotovelo.position.x, modelo.braco_original.ombro.length)
		and is_equal_approx(novo.punho.position.x, modelo.braco_original.cotovelo.length), "comprimentos anteriores preservados")
	_verificar(is_equal_approx(novo.ombro.rotation, deg_to_rad(75))
		and is_equal_approx(novo.cotovelo.rotation, deg_to_rad(-120)), "guarda candidata explícita")
	var abertura: float = PI - absf(novo.cotovelo.rotation)
	_verificar(abertura >= deg_to_rad(59), "abrir de fato a dobra entre segmentos, não apenas afastar do tronco")
	var meio_superior: Vector2 = novo.ombro.to_global(Vector2(novo.SUPERIOR * .5, 0))
	var meio_inferior: Vector2 = novo.cotovelo.to_global(Vector2(novo.INFERIOR * .5, 0))
	_verificar(meio_superior.distance_to(meio_inferior) > 60, "separação legível entre os centros dos ventres")
	var fonte: Image = novo.ARTE.get_image()
	var sobreposicao: Vector2i = _sobreposicao_central(novo, fonte, -120)
	var sobreposicao_anterior: Vector2i = _sobreposicao_central(novo, fonte, -153)
	_verificar(sobreposicao.y > 100 and sobreposicao.x == 0, "amostra central pintada do antebraço não sobrepõe bíceps")
	_verificar(sobreposicao_anterior.x > 0, "regressão reproduz sobreposição da dobra anterior de 27 graus")
	print("Sobreposição central (pontos): atual ", sobreposicao, "; anterior ", sobreposicao_anterior)
	_verificar(modelo.pele.polygon == anterior.modelo.pele.polygon
		and modelo.pele.uv == anterior.modelo.pele.uv, "não recortar nem deslocar a pele para compensar prótese")
	for caminho: String in ["Skeleton2D/Pelve", "Skeleton2D/Pelve/Tronco",
		"Skeleton2D/Pelve/Tronco/Clavicula", "Skeleton2D/Pelve/Tronco/Clavicula/Deltoide",
		"Skeleton2D/Pelve/Tronco/ClaviculaDistante", "Skeleton2D/Pelve/Tronco/ClaviculaDistante/DeltoideDistante",
		"Skeleton2D/JoelhoTras", "Skeleton2D/JoelhoFrente", "Skeleton2D/Apoios"]:
		_verificar((modelo.get_node(caminho) as Node2D).transform.is_equal_approx(
			(anterior.modelo.get_node(caminho) as Node2D).transform), "pose corporal preservada: " + caminho)
	for osso: String in ["Skeleton2D/Ombro", "Skeleton2D/Ombro/Cotovelo", "Skeleton2D/Ombro/Cotovelo/Punho"]:
		_verificar((modelo.braco_distante.get_node(osso) as Node2D).transform.is_equal_approx(
			(anterior.modelo.braco_distante.get_node(osso) as Node2D).transform), "braço distante preservado")
	candidata.comparar(true)
	_verificar(modelo.braco_original.visible and not novo.visible, "comparação A oculta nova prótese")
	candidata.comparar(false)
	_verificar(not modelo.braco_original.visible and novo.visible, "comparação A restaura nova prótese")
	var antes: Transform2D = novo.punho.global_transform
	for quadro: int in range(12):
		await process_frame
	_verificar(not modelo.animacao.is_playing() and novo.punho.global_transform.is_equal_approx(antes), "prova permanece estática")
	var amostras: int = 0
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var viewport: SubViewport = candidata.composicao.get_node("Desenho") as SubViewport
		var imagem: Image = viewport.get_texture().get_image()
		var pontos: Array[Vector2] = [novo.cotovelo.global_position, novo.punho.global_position,
			mao.to_global(novo.registros[2] * Vector2(520, 1350))]
		# Pequena linha atravessando a transição vertical entre deltoide e cap da prótese.
		for passo: int in range(-10, 11, 2):
			pontos.append(novo.global_position + Vector2(0, passo))
		# Amostragem curta da ponte entre o colar do antebraço e a mão reduzida.
		for x: int in [0, 2, 4, 6]:
			for y: int in [-3, 0, 3]:
				pontos.append(novo.punho.to_global(Vector2(x, y)))
		for ponto: Vector2 in pontos:
			_verificar(imagem.get_pixelv(Vector2i(ponto.round())).a > .9, "GPU: mão, junta e transição do ombro ocupadas")
			amostras += 1
	candidata.free()
	anterior.free()
	await process_frame
	print("Encaixe corporal: ", falhas, " falhas; ", amostras, " amostras GPU; 12 quadros estáveis")
	quit(0 if falhas == 0 else 1)


static func _sobreposicao_central(braco: BracoRegistradoV1, fonte: Image, graus_cotovelo: float) -> Vector2i:
	# Faixa central 45–65% do antebraço: exclui sobreposição necessária da junta.
	# Amostra CPU da pintura e dos recortes reais, não só das linhas dos ossos.
	var superior: Transform2D = braco.registros[0]
	var inferior: Transform2D = Transform2D(deg_to_rad(graus_cotovelo), Vector2(braco.SUPERIOR, 0)) * braco.registros[1]
	var inverso: Transform2D = superior.affine_inverse()
	var total: int = 0
	var sobrepostos: int = 0
	for y: int in range(893, 1002, 6):
		for x: int in range(350, 731, 6):
			var uv: Vector2 = Vector2(x, y)
			if fonte.get_pixel(x, y).a < .9:
				continue
			total += 1
			var uv_superior: Vector2 = inverso * (inferior * uv)
			if not Geometry2D.is_point_in_polygon(uv_superior, braco.segmentos[0].uv):
				continue
			var pixel: Vector2i = Vector2i(uv_superior.round())
			if Rect2i(Vector2i.ZERO, fonte.get_size()).has_point(pixel) and fonte.get_pixelv(pixel).a > .9:
				sobrepostos += 1
	return Vector2i(sobrepostos, total)
