extends SceneTree

const CAMADAS: PackedScene = preload("res://vega_animada/corpo_articulado/camadas_guarda/camadas_guarda.tscn")
const PREVIEW: PackedScene = preload("res://vega_animada/corpo_articulado/camadas_guarda/preview.tscn")
const PASTA: String = "res://vega_animada/corpo_articulado/camadas_guarda/"
var falhas: int = 0
var sobreposicao: int = 0
var amostras_gpu: int = 0
var desvios_ombros: Array[float] = []
var recortes: Array[Rect2i] = []


func _initialize() -> void:
	_executar.call_deferred()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("CAMADAS GUARDA: " + mensagem)


func _executar() -> void:
	create_timer(20).timeout.connect(func() -> void:
		push_error("CAMADAS GUARDA: teste excedeu 20 s")
		quit(1))
	var pecas: CamadasGuardaV1 = CAMADAS.instantiate() as CamadasGuardaV1
	root.add_child(pecas)
	var tronco: Image = _carregar_png("tronco_02.png")
	_verificar(pecas.tronco.texture.resource_path == PASTA + "tronco_02.png", "bancada usa a revisão de volume do tronco")
	var quadril: Image = _carregar_png("quadril_01.png")
	for imagem: Image in [tronco, quadril]:
		_verificar(imagem.get_size() == Vector2i(1774, 887) and imagem.detect_alpha() != Image.ALPHA_NONE, "dimensões e canal alfa reais")
		var recorte: Rect2i = _limites_visiveis(imagem)
		recortes.append(recorte)
		_verificar(recorte.position.x > 0 and recorte.position.y > 0 and recorte.end.x < 1200 and recorte.end.y < 887, "uma peça isolada com margem transparente")
		for ponto: Vector2i in [Vector2i(0, 0), Vector2i(1773, 0), Vector2i(0, 886), Vector2i(1773, 886), Vector2i(1500, 440)]:
			_verificar(imagem.get_pixelv(ponto).a == 0, "sem fundo ou outras poses no canvas")
	for par: Array in [["tronco_01.png", "42e995c0ea9d0cbf31a74ae55b8a99081534c9878d1addcac308b7939c0b165b"],
			["tronco_02.png", "293bc2349cb0b8c9b90e72b295a8d181af0d5bc54755031115544a907fd0c982"],
			["quadril_01.png", "07b433e69ab4dfb27493126665100778078ce7f6699d7d74b097df4b75d01f76"]]:
		_verificar(FileAccess.get_sha256(PASTA + par[0]) == par[1], "fonte raster preservada")
		var configuracao := ConfigFile.new()
		_verificar(configuracao.load(PASTA + par[0] + ".import") == OK and configuracao.get_value("params", "mipmaps/generate") == true, "mipmaps configurados")
	var transformacao: Transform2D = pecas.registro_tronco
	_verificar((transformacao * pecas.pescoco_fonte).distance_to(pecas.pescoco_referencia) < .001
		and (transformacao * pecas.cintura_fonte).distance_to(pecas.cintura_referencia) < .001, "registro por pescoço/cintura")
	_verificar((pecas.registro_quadril * pecas.no_camisa_fonte).distance_to(pecas.no_camisa_referencia) < .001, "registro do nó da camisa")
	for t: Transform2D in [pecas.registro_tronco, pecas.registro_quadril]:
		_verificar(absf(t.x.length() - t.y.length()) < .00001 and absf(t.x.dot(t.y)) < .00001 and t.determinant() > 0,
			"escala uniforme, sem espelho/cisalhamento")
	desvios_ombros = [(transformacao * pecas.ombro_proximo_fonte).distance_to(pecas.ombro_proximo_referencia),
		(transformacao * pecas.ombro_distante_fonte).distance_to(pecas.ombro_distante_referencia)]
	for desvio: float in desvios_ombros:
		_verificar(desvio < 12, "marcos manuais dos ombros dentro da tolerância candidata")
	for ponto: Vector2i in [Vector2i(450, 430), Vector2i(360, 360), Vector2i(570, 370), Vector2i(440, 700)]:
		_verificar(tronco.get_pixelv(ponto).a > .9, "tecido oculto e continuação inferior desenhados")
	for y: int in range(340, 391):
		for x: int in range(245, 326):
			var p := Vector2(x, y)
			if _alfa(tronco, transformacao.affine_inverse() * p) > .9 and _alfa(quadril, pecas.registro_quadril.affine_inverse() * p) > .9:
				sobreposicao += 1
	_verificar(sobreposicao > 500, "margem opaca de sobreposição na cintura")
	var neutro_tronco: Transform2D = pecas.tronco.transform
	var neutro_quadril: Transform2D = pecas.quadril.transform
	pecas.separar(true)
	_verificar(pecas.tronco.position.is_equal_approx(neutro_tronco.origin + Vector2(0, -35))
		and pecas.quadril.position.is_equal_approx(neutro_quadril.origin + Vector2(0, 35)), "separação inspeciona peças sem alterar registro")
	pecas.separar(false)
	_verificar(pecas.tronco.transform == neutro_tronco and pecas.quadril.transform == neutro_quadril, "restauração exata")
	_verificar(pecas.quadril_atras.z_index < pecas.tronco.z_index and pecas.quadril_frente.z_index > pecas.tronco.z_index,
		"margem atrás, camisa à frente")
	_verificar(pecas.quadril_atras.region_rect.end.y == pecas.quadril_frente.region_rect.position.y
		and pecas.quadril_frente.position.y == pecas.CORTE_FRENTE, "recortes de desenho contíguos sem editar PNG")
	_verificar(FileAccess.get_sha256("res://docs/arte_vega/vega_corpo_volume_poses_04.png") == "a5f0f73b34a1576083cda86d44acac83dfd35134d10a85e29f47f0e70783a224", "prancha aprovada intacta")
	if DisplayServer.get_name() != "headless":
		await _verificar_gpu()
	_verificar_preview()
	pecas.free()
	await process_frame
	print("Camadas guarda: ", falhas, " falhas; sobreposição opaca ", sobreposicao,
		" px; amostras GPU ", amostras_gpu, "; desvios ombros px ", desvios_ombros, "; recortes ", recortes)
	quit(0 if falhas == 0 else 1)


func _carregar_png(nome: String) -> Image:
	var imagem := Image.new()
	_verificar(imagem.load_png_from_buffer(FileAccess.get_file_as_bytes(PASTA + nome)) == OK, "leitura PNG original")
	return imagem


func _limites_visiveis(imagem: Image) -> Rect2i:
	var minimo: Vector2i = imagem.get_size()
	var maximo := Vector2i(-1, -1)
	var maior_residual: float = 0
	for y: int in range(imagem.get_height()):
		for x: int in range(imagem.get_width()):
			var alfa: float = imagem.get_pixel(x, y).a
			if x >= 1200:
				maior_residual = maxf(maior_residual, alfa)
			if alfa > 2.0 / 255.0:
				minimo = minimo.min(Vector2i(x, y))
				maximo = maximo.max(Vector2i(x, y))
	_verificar(maior_residual <= 2.0 / 255.0, "fora da peça só existe ruído alfa descartado pelo material")
	return Rect2i(minimo, maximo - minimo + Vector2i.ONE)


func _alfa(imagem: Image, ponto: Vector2) -> float:
	var p := Vector2i(ponto.round())
	if not Rect2i(Vector2i.ZERO, imagem.get_size()).has_point(p):
		return 0
	return imagem.get_pixelv(p).a


func _verificar_gpu() -> void:
	var tela := SubViewport.new()
	tela.size = Vector2i(650, 650)
	tela.transparent_bg = true
	tela.world_2d = World2D.new()
	tela.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(tela)
	var pecas: CamadasGuardaV1 = CAMADAS.instantiate() as CamadasGuardaV1
	tela.add_child(pecas)
	await process_frame
	await RenderingServer.frame_post_draw
	var imagem: Image = tela.get_texture().get_image()
	for y: int in range(240, 421, 6):
		for x: int in range(250, 321, 6):
			_verificar(imagem.get_pixel(x, y).a > .9, "GPU: corpo/cintura sem abertura na faixa central amostrada")
			amostras_gpu += 1
	for ponto: Vector2i in [Vector2i(0, 0), Vector2i(649, 649), Vector2i(40, 300), Vector2i(600, 300)]:
		_verificar(imagem.get_pixelv(ponto).a == 0, "GPU: composição sem fundo opaco")
	pecas.mostrar_marcos = true
	await process_frame
	await RenderingServer.frame_post_draw
	var marcos: Image = tela.get_texture().get_image()
	var amarelos: int = 0
	for y: int in range(182, 189):
		for x: int in range(297, 304):
			var cor: Color = marcos.get_pixel(x, y)
			if absf(cor.r - 239.0 / 255.0) < .01 and absf(cor.g - 206.0 / 255.0) < .01 and absf(cor.b - 117.0 / 255.0) < .01:
				amarelos += 1
	_verificar(amarelos > 0, "GPU: marcos desenhados acima das peças")
	pecas.mostrar_marcos = false
	pecas.quadril.hide()
	await process_frame
	await RenderingServer.frame_post_draw
	_verificar(tela.get_texture().get_image().get_pixel(300, 450).a == 0, "GPU: quadril independente do tronco")
	pecas.quadril.show()
	pecas.tronco.hide()
	await process_frame
	await RenderingServer.frame_post_draw
	_verificar(tela.get_texture().get_image().get_pixel(300, 230).a == 0, "GPU: tronco independente do quadril")
	tela.free()


func _verificar_preview() -> void:
	var previa: Node2D = PREVIEW.instantiate() as Node2D
	root.add_child(previa)
	for tecla: Key in [KEY_E, KEY_T, KEY_P, KEY_F, KEY_O]:
		var evento := InputEventKey.new()
		evento.keycode = tecla
		evento.pressed = true
		previa._unhandled_key_input(evento)
	_verificar(previa.pecas.separadas and not previa.pecas.tronco.visible and not previa.pecas.quadril.visible
		and previa.fantasma.visible and previa.pecas.mostrar_marcos, "atalhos de inspeção")
	var restaurar := InputEventKey.new()
	restaurar.keycode = KEY_R
	restaurar.pressed = true
	previa._unhandled_key_input(restaurar)
	_verificar(not previa.pecas.separadas and previa.pecas.tronco.visible and previa.pecas.quadril.visible
		and not previa.fantasma.visible and not previa.pecas.mostrar_marcos, "R restaura bancada")
	_verificar(previa.fantasma.region_enabled and previa.fantasma.region_rect.size.x == 610,
		"somente guarda, sem vizinha na comparação separada")
	previa.free()
