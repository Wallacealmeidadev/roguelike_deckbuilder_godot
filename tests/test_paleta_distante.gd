extends SceneTree

const PROXIMA: Texture2D = preload("res://vega_animada/braco_reconstruido/braco_montado_01.png")
const DISTANTE: Texture2D = preload("res://vega_animada/braco_reconstruido/distante/braco_interno_01.png")
const CENA: PackedScene = preload("res://vega_animada/braco_reconstruido/distante/vega_distante.tscn")
var falhas: int = 0
var amostras_gpu: int = 0
var pixels_alterados: int = 0
var pixels_alfa: int = 0


func _initialize() -> void:
	_executar.call_deferred()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		if falhas <= 10:
			push_error("PALETA DISTANTE: " + mensagem)


func _executar() -> void:
	var referencia: Array[Vector3] = _medir("próxima", PROXIMA.get_image())
	var antes: Array[Vector3] = _medir("distante original", DISTANTE.get_image())
	var depois: Array[Vector3] = _medir("distante harmonizada (CPU)", DISTANTE.get_image(), true)
	for faixa: int in range(3):
		var erro_antes: float = referencia[faixa].distance_to(antes[faixa])
		var erro_depois: float = referencia[faixa].distance_to(depois[faixa])
		_verificar(erro_depois < erro_antes * .75, "cinzas mais próximos da referência em cada faixa amostrada")
	var atriz: VegaGuardaDistanteV1 = CENA.instantiate() as VegaGuardaDistanteV1
	atriz.size = Vector2(650, 850)
	root.add_child(atriz)
	for malha: Polygon2D in atriz.novo_distante.segmentos:
		_verificar(malha.material == atriz.material_distante, "um tratamento coerente nas três peças distantes")
	for malha: Polygon2D in atriz.braco_novo.segmentos:
		_verificar(malha.material != atriz.material_distante, "não recolorir o braço aprovado")
	var punho: Transform2D = atriz.novo_distante.punho.global_transform
	atriz.harmonizar_cor(0)
	_verificar(float(atriz.material_distante.get_shader_parameter(&"intensidade")) == 0, "comparação desliga correção")
	atriz.harmonizar_cor(1)
	_verificar(float(atriz.material_distante.get_shader_parameter(&"intensidade")) == 1
		and punho.is_equal_approx(atriz.novo_distante.punho.global_transform), "comparação não move juntas")
	if DisplayServer.get_name() != "headless":
		await _verificar_gpu(atriz)
	_verificar_tecla()
	atriz.free()
	await process_frame
	print("Paleta distante: ", falhas, " falhas; ", amostras_gpu, " amostras GPU; ", pixels_alterados,
		" pixels RGB alterados; ", pixels_alfa, " pixels alfa preservados")
	quit(0 if falhas == 0 else 1)


func _medir(nome: String, fonte: Image, aplicar: bool = false) -> Array[Vector3]:
	var somas: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]
	var contagens: Array[int] = [0, 0, 0]
	for y: int in range(0, fonte.get_height(), 4):
		for x: int in range(280, 751, 4):
			var cor: Color = fonte.get_pixel(x, y)
			if cor.a < .99 or maxf(cor.r, maxf(cor.g, cor.b)) - minf(cor.r, minf(cor.g, cor.b)) > .14:
				continue
			var luz: float = Vector3(cor.r, cor.g, cor.b).dot(Vector3(.2126, .7152, .0722))
			var faixa: int = 0 if luz < .30 else (1 if luz < .55 else 2)
			if luz < .12 or luz > .85:
				continue
			var medida: Color = _corrigir(cor) if aplicar else cor
			somas[faixa] += Vector3(medida.r, medida.g, medida.b)
			contagens[faixa] += 1
	var resultado: Array[Vector3] = []
	for faixa: int in range(3):
		resultado.append(somas[faixa] / maxf(1, contagens[faixa]))
		print(nome, " faixa ", faixa, ": ", resultado[faixa], " / ", contagens[faixa], " amostras")
	return resultado


func _corrigir(cor: Color) -> Color:
	# Oráculo independente para conferir o shader compilado em GPU.
	var rgb := Vector3(cor.r, cor.g, cor.b)
	var luz: float = rgb.dot(Vector3(.2126, .7152, .0722))
	var croma: float = maxf(cor.r, maxf(cor.g, cor.b)) - minf(cor.r, minf(cor.g, cor.b))
	var mascara: float = (1 - smoothstep(.1, .2, croma)) * smoothstep(.06, .14, luz)
	var ganho: Vector3 = Vector3(1, 1, 1.065).lerp(Vector3(.967, .981, 1.051), smoothstep(.2, .4, luz))
	ganho = ganho.lerp(Vector3(.978, .990, 1.033), smoothstep(.4, .68, luz))
	ganho = ganho.lerp(Vector3.ONE, smoothstep(.85, .98, luz))
	rgb *= Vector3.ONE.lerp(ganho, mascara)
	return Color(rgb.x, rgb.y, rgb.z, cor.a)


func _verificar_gpu(atriz: VegaGuardaDistanteV1) -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256, 32)
	viewport.transparent_bg = true
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var cores: Array[Color] = [Color(.218, .205, .207), Color(.42, .404, .416), Color(.673, .659, .674),
		Color(.025, .82, .95), Color(.9, .04, .65), Color(.01, .01, .01), Color(.42, .404, .416, .45), Color(0, 0, 0, 0)]
	var quantizadas: Array[Color] = []
	for indice: int in range(cores.size()):
		var amostra: Image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
		amostra.fill(cores[indice])
		quantizadas.append(amostra.get_pixel(0, 0))
		var sprite := Sprite2D.new()
		sprite.texture = ImageTexture.create_from_image(amostra)
		sprite.material = atriz.material_distante
		sprite.position = Vector2(indice * 32 + 16, 16)
		sprite.scale = Vector2.ONE * 4
		viewport.add_child(sprite)
	for ligada: bool in [true, false]:
		atriz.harmonizar_cor(1.0 if ligada else 0.0)
		await process_frame
		await RenderingServer.frame_post_draw
		var render: Image = viewport.get_texture().get_image()
		for indice: int in range(cores.size()):
			var observado: Color = render.get_pixel(indice * 32 + 16, 16)
			var esperado: Color = _corrigir(quantizadas[indice]) if ligada else quantizadas[indice]
			_verificar(absf(observado.a - esperado.a) < .01, "GPU: alfa preservado")
			if esperado.a > .99:
				_verificar(Vector3(observado.r, observado.g, observado.b).distance_to(Vector3(esperado.r, esperado.g, esperado.b)) < .012,
					"GPU: cinzas corrigidos, acentos/contorno preservados e intensidade zero neutra")
			amostras_gpu += 1
	viewport.free()
	var desenho: SubViewport = atriz.composicao.get_node("Desenho") as SubViewport
	atriz.harmonizar_cor(0)
	await process_frame
	await RenderingServer.frame_post_draw
	var antes: Image = desenho.get_texture().get_image()
	atriz.harmonizar_cor(1)
	await process_frame
	await RenderingServer.frame_post_draw
	var depois: Image = desenho.get_texture().get_image()
	_verificar(antes.get_format() == Image.FORMAT_RGBA8 and depois.get_format() == Image.FORMAT_RGBA8, "render RGBA8")
	var a: PackedByteArray = antes.get_data()
	var b: PackedByteArray = depois.get_data()
	var alfa_diferente: int = 0
	for indice: int in range(0, a.size(), 4):
		if a[indice + 3] != b[indice + 3]:
			alfa_diferente += 1
		if a[indice] != b[indice] or a[indice + 1] != b[indice + 1] or a[indice + 2] != b[indice + 2]:
			pixels_alterados += 1
		pixels_alfa += 1
	_verificar(alfa_diferente == 0 and pixels_alterados > 100, "render real muda cor sem mudar silhueta/transparência")


func _verificar_tecla() -> void:
	var laboratorio: Node2D = (load("res://vega_animada/braco_reconstruido/distante/preview.tscn") as PackedScene).instantiate() as Node2D
	root.add_child(laboratorio)
	var atriz: VegaGuardaDistanteV1 = laboratorio.get("candidata") as VegaGuardaDistanteV1
	var tecla := InputEventKey.new()
	tecla.keycode = KEY_C
	tecla.pressed = true
	laboratorio.call("_unhandled_key_input", tecla)
	_verificar(atriz.harmonizacao_cor == 0, "C desliga harmonização")
	laboratorio.call("_unhandled_key_input", tecla)
	_verificar(atriz.harmonizacao_cor == 1, "C restaura harmonização")
	laboratorio.free()
