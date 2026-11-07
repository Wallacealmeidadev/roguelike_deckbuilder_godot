extends SceneTree
## Verifica origem/registro dos recortes. Não certifica anatomia ou animação.

const CENA: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/bracos_prancha/vega_fiel.tscn")
const PREVIEW: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/bracos_prancha/preview.tscn")
var falhas: int = 0
var amostras_gpu: int = 0


func _initialize() -> void:
	_executar.call_deferred()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("BRAÇOS PRANCHA: " + mensagem)


func _executar() -> void:
	create_timer(20).timeout.connect(func() -> void:
		push_error("BRAÇOS PRANCHA: teste excedeu 20 s")
		quit(1))
	var tela := SubViewport.new()
	tela.size = Vector2i(650, 650)
	tela.transparent_bg = true
	tela.world_2d = World2D.new()
	tela.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(tela)
	var vega: VegaBracosPranchaV1 = CENA.instantiate() as VegaBracosPranchaV1
	tela.add_child(vega)
	vega.definir_pintura_hq(false)
	# A/B conserva exatamente a candidata rejeitada como controle, não como
	# aprovação. Os testes de pixels nativos seguintes referem-se ao ANTES.
	vega.definir_ajuste(false)
	_verificar(not vega.proximo.visible and not vega.distante.visible, "peças antigas ocultas, sem dupla prótese")
	var partes: Array[Polygon2D] = [vega.recorte_proximo, vega.recorte_distante]
	var encaixes: Array[Vector2] = [vega.ENCAIXE_PROXIMO, vega.ENCAIXE_DISTANTE]
	var destinos: Array[Vector2] = [vega.insercao_proxima_fonte, vega.insercao_distante_fonte]
	for indice: int in range(2):
		var peca: Polygon2D = partes[indice]
		_verificar(peca.texture == vega.PRANCHA and peca.material == null, "prancha original sem repintura/paleta")
		_verificar(peca.uv == peca.polygon, "coordenadas de origem iguais às do desenho")
		_verificar(peca.scale == Vector2.ONE and peca.rotation == 0 and peca.skew == 0, "sem esticar, refletir ou girar")
		_verificar(peca.position == peca.position.round(), "translação inteira")
		_verificar((peca.position + encaixes[indice]).distance_to(vega.tronco.transform * destinos[indice]) <= .71, "inserção registrada por translação")
		_verificar(Geometry2D.triangulate_polygon(peca.polygon).size() == (peca.polygon.size() - 2) * 3, "contorno triangulável")
	_verificar(vega.recorte_distante.z_index < vega.tronco.z_index and vega.recorte_proximo.z_index > vega.tronco.z_index, "ordem de profundidade")
	for par: Array in [
		["res://docs/arte_vega/vega_corpo_volume_poses_04.png", "a5f0f73b34a1576083cda86d44acac83dfd35134d10a85e29f47f0e70783a224"],
		["res://prototipos/vega_2d/corpo_articulado/camadas_guarda/tronco_02.png", "293bc2349cb0b8c9b90e72b295a8d181af0d5bc54755031115544a907fd0c982"],
		["res://prototipos/vega_2d/corpo_articulado/camadas_guarda/quadril_01.png", "07b433e69ab4dfb27493126665100778078ce7f6699d7d74b097df4b75d01f76"],
		["res://prototipos/vega_2d/braco_reconstruido/braco_montado_01.png", "363c74b21ce88d01c5b00db286004bf59cac36a8d53a46617f5cf2648fb40fad"],
		["res://prototipos/vega_2d/braco_reconstruido/distante/braco_interno_01.png", "5e8e596f39f29c5c10bfea3b56a4336700bf81b44f409a22dcaaeaa9e2cc31a6"]]:
		_verificar(FileAccess.get_sha256(par[0]) == par[1], "fonte preservada: " + par[0])
	# Pontos de placa, fibra, aro e mão; margens não são aprovadas por amostragem.
	var proximos: Array[Vector2i] = [Vector2i(185, 255), Vector2i(185, 280), Vector2i(195, 320), Vector2i(219, 370), Vector2i(254, 318), Vector2i(275, 302), Vector2i(303, 276), Vector2i(321, 248), Vector2i(322, 220), Vector2i(340, 242)]
	var distantes: Array[Vector2i] = [Vector2i(379, 290), Vector2i(391, 317), Vector2i(413, 342), Vector2i(435, 360), Vector2i(459, 322), Vector2i(434, 309), Vector2i(459, 272), Vector2i(457, 245), Vector2i(446, 207), Vector2i(478, 227)]
	for indice: int in range(2):
		for ponto: Vector2i in proximos if indice == 0 else distantes:
			_verificar(Geometry2D.is_point_in_polygon(Vector2(ponto) + Vector2(.5, .5), partes[indice].polygon), "amostra interna ao recorte")
	if DisplayServer.get_name() != "headless":
		vega.tronco.hide()
		vega.quadril.hide()
		vega.cabeca.hide()
		await process_frame
		await RenderingServer.frame_post_draw
		var captura: Image = tela.get_texture().get_image()
		var origem: Image = vega.PRANCHA.get_image()
		for indice: int in range(2):
			for ponto: Vector2i in proximos if indice == 0 else distantes:
				var destino: Vector2i = ponto + Vector2i(partes[indice].position)
				var real: Color = captura.get_pixelv(destino)
				var esperado: Color = origem.get_pixelv(ponto)
				_verificar(real.a > .99 and absf(real.r - esperado.r) <= 2.0 / 255 and absf(real.g - esperado.g) <= 2.0 / 255 and absf(real.b - esperado.b) <= 2.0 / 255, "cor renderizada preservada em " + str(ponto))
				amostras_gpu += 1
		for ponto: Vector2i in [Vector2i(150, 280), Vector2i(420, 285), Vector2i(490, 310), Vector2i(490, 205)]:
			# Estes pontos são externos a ambos os recortes mesmo após translação.
			_verificar(captura.get_pixelv(ponto).a < .01, "amostra externa transparente " + str(ponto))
	await _verificar_volume(vega, tela)
	await _verificar_hq(vega, tela)
	await _verificar_ajuste(vega, tela)
	_verificar_preview()
	tela.free()
	await process_frame
	print("Braços prancha: ", falhas, " falhas; ", amostras_gpu, " amostras GPU. Prova estática, sem teste de movimento/anatomia.")
	quit(0 if falhas == 0 else 1)


func _verificar_preview() -> void:
	var preview: Node2D = PREVIEW.instantiate() as Node2D
	root.add_child(preview)
	for tecla: Key in [KEY_H, KEY_H, KEY_H, KEY_V, KEY_V, KEY_A, KEY_B, KEY_B, KEY_A, KEY_B, KEY_B, KEY_T, KEY_P, KEY_C, KEY_O, KEY_Z, KEY_R]:
		var evento := InputEventKey.new()
		evento.keycode = tecla
		evento.pressed = true
		preview._unhandled_key_input(evento)
		_verificar(not preview.fiel.proximo.visible and not preview.fiel.distante.visible, "atalhos não ressuscitam braços antigos")
		_verificar(preview.fiel.cap_proxima.visible == (preview.fiel.ajuste_ativo and preview.fiel.recorte_proximo.visible), "B/A mantém encaixe e corpo do braço sincronizados")
	_verificar(preview.fiel.recorte_proximo.visible and preview.fiel.recorte_distante.visible and preview.fiel.tronco.visible and preview.fiel.quadril.visible and preview.fiel.cabeca.visible, "R restaura camadas corretas")
	_verificar(not preview.ampliada and not preview.fiel.mostrar_marcos, "R restaura enquadramento e guias")
	_verificar(preview.fiel.ajuste_ativo, "R restaura candidata ajustada")
	_verificar(preview.fiel.volume_ativo, "R restaura volume candidato")
	_verificar(preview.fiel.pintura_hq_ativa and preview.fiel.recorte_distante.material != null, "R restaura pintura HQ")
	preview.free()


func _verificar_hq(vega: VegaBracosPranchaV1, tela: SubViewport) -> void:
	var pecas: Array[Polygon2D] = [vega.recorte_proximo, vega.recorte_distante, vega.cap_proxima]
	for peca: Polygon2D in pecas:
		var vertices: PackedVector2Array = peca.polygon.duplicate()
		var uv: PackedVector2Array = peca.uv.duplicate()
		var registro: Transform2D = peca.transform
		vega.definir_pintura_hq(true)
		_verificar(peca.polygon == vertices and peca.uv == uv and peca.transform == registro, "HQ não altera geometria/UV/encaixe")
		_verificar(peca.material != null and peca.texture == vega.PRANCHA, "HQ conserva fonte nas bordas por material local")
		vega.definir_pintura_hq(false)
		_verificar(peca.material == null, "H restaura pintura original")
	_verificar(vega.PINTURA_HQ.get_size() == vega.PRANCHA.get_size(), "atlas HQ registrado no mesmo canvas")
	if DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var antes: Image = tela.get_texture().get_image()
	vega.definir_pintura_hq(true)
	await process_frame
	await RenderingServer.frame_post_draw
	var depois: Image = tela.get_texture().get_image()
	var alterados: int = 0
	var alfa_diferente: int = 0
	var externo_diferente: int = 0
	for y: int in range(650):
		for x: int in range(650):
			var a: Color = antes.get_pixel(x, y)
			var b: Color = depois.get_pixel(x, y)
			if absf(a.a - b.a) > 1.0 / 255:
				alfa_diferente += 1
			if a.a < .01 and b != a:
				externo_diferente += 1
			if a.a > .99 and a != b:
				alterados += 1
	_verificar(alterados > 1000, "pintura HQ altera interior dos braços")
	_verificar(alfa_diferente == 0 and externo_diferente == 0, "H preserva silhueta/alfa e exterior dos braços")
	for ponto: Vector2i in [Vector2i(355, 322), Vector2i(370, 332), Vector2i(395, 352)]:
		var destino: Vector2i = ponto + Vector2i(vega.recorte_distante.position)
		_verificar(depois.get_pixelv(destino).a < .01, "resíduo branco sob bíceps distante excluído")
	print("HQ: ", alterados, " pixels internos alterados; ", alfa_diferente, " diferenças de alfa; ", externo_diferente, " diferenças externas.")
	vega.definir_pintura_hq(false)


func _verificar_volume(vega: VegaBracosPranchaV1, tela: SubViewport) -> void:
	vega.definir_ajuste(true)
	vega.definir_volume(true)
	for ponto: Vector2 in [vega.OMBRO_VOLUME, vega.COTOVELO_VOLUME, vega.PUNHO_VOLUME, vega.ARO_EXTERNO, vega.ARO_INTERNO]:
		_verificar(vega.deslocamento_volume(ponto).is_zero_approx(), "centros das juntas e aro não se deslocam")
	for ponto: Vector2 in [Vector2(322, 220), Vector2(340, 242)]:
		var antes: Vector2 = ponto - vega.PUNHO_VOLUME
		var depois: Vector2 = antes + vega.deslocamento_volume(ponto)
		_verificar(absf(depois.length() / antes.length() - 1.14) < .001 and absf(antes.cross(depois)) < .01, "mão cresce uniformemente 14% a partir do punho")
	for ponto: Vector2 in vega.uv_volume:
		if (ponto.x <= 225 and ponto.y <= 280) or ponto.distance_to(vega.COTOVELO_VOLUME) <= 18 or ponto.distance_to(vega.PUNHO_VOLUME) <= 15:
			_verificar(vega.deslocamento_volume(ponto).length() < .001, "borda proximal e regiões das juntas preservadas")
	var superior: Vector2 = vega.COTOVELO_VOLUME - vega.OMBRO_VOLUME
	var inferior: Vector2 = vega.PUNHO_VOLUME - vega.COTOVELO_VOLUME
	for indice: int in range(2):
		var eixo: Vector2 = superior if indice == 0 else inferior
		var inicio: Vector2 = vega.OMBRO_VOLUME if indice == 0 else vega.COTOVELO_VOLUME
		var normal: Vector2 = eixo.normalized().orthogonal()
		var centro: Vector2 = inicio + eixo * .5
		var delta: Vector2 = vega.deslocamento_volume(centro + normal * 15)
		_verificar(delta.length() > 2 and absf(delta.dot(eixo.normalized())) < .001, "aumento transversal observável sem alongar o segmento")
	vega.definir_volume(false)
	_verificar(vega.recorte_proximo.polygon == vega.contorno_frente and vega.recorte_proximo.uv == vega.contorno_frente, "V desligado restaura malha anterior exata")
	if DisplayServer.get_name() == "headless":
		vega.definir_volume(true)
		return
	vega.tronco.hide()
	vega.quadril.hide()
	vega.cabeca.hide()
	await process_frame
	await RenderingServer.frame_post_draw
	var antes: Image = tela.get_texture().get_image()
	vega.definir_volume(true)
	await process_frame
	await RenderingServer.frame_post_draw
	var depois: Image = tela.get_texture().get_image()
	var inverso: Transform2D = vega.recorte_proximo.transform.affine_inverse()
	var mao: int = 0
	var alterados: int = 0
	var erro_mao: float = 0
	for y: int in range(190, 390):
		for x: int in range(150, 390):
			var p := Vector2i(x, y)
			var uv: Vector2 = inverso * (Vector2(p) + Vector2(.5, .5))
			var a: Color = antes.get_pixelv(p)
			var b: Color = depois.get_pixelv(p)
			if uv.x >= 300 and uv.y >= 218 and uv.y <= 260 and a.a > .99:
				mao += 1
				erro_mao = maxf(erro_mao, maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), maxf(absf(a.b - b.b), absf(a.a - b.a)))))
			elif a != b:
				alterados += 1
	_verificar(mao > 1000 and erro_mao > .05, "redimensionamento da mão aparece na renderização")
	_verificar(alterados > 200, "volume muda a apresentação do braço")
	for ponto: Vector2i in [Vector2i(487, 225), Vector2i(437, 253), Vector2i(476, 257), Vector2i(475, 270), Vector2i(483, 246)]:
		var destino: Vector2i = ponto + Vector2i(vega.recorte_distante.position)
		_verificar(depois.get_pixelv(destino).a < .01, "fundo branco distante excluído do contorno " + str(ponto))
	print("Volume próximo: ", mao, " pixels da mão, erro máximo ", erro_mao, "; ", alterados, " pixels externos à mão alterados; 5 pontos de fundo distante excluídos.")


func _verificar_ajuste(vega: VegaBracosPranchaV1, tela: SubViewport) -> void:
	var distante_antes: Transform2D = vega.recorte_distante.transform
	var corpo_antes: Transform2D = vega.tronco.transform
	var cabeca_antes: Transform2D = vega.cabeca.transform
	vega.definir_ajuste(true)
	_verificar(vega.recorte_distante.transform == distante_antes and vega.tronco.transform == corpo_antes and vega.cabeca.transform == cabeca_antes, "registros distante/corpo/cabeça preservados")
	for par: Array in [[vega.ARO_EXTERNO, vega.PELE_EXTERNA], [vega.ARO_INTERNO, vega.PELE_INTERNA]]:
		_verificar((vega.recorte_proximo.transform * par[0]).distance_to(vega.tronco.transform * par[1]) < .001, "registro das duas extremidades do aro")
	var registro: Transform2D = vega.recorte_proximo.transform
	_verificar(absf(registro.x.length() - registro.y.length()) < .00001 and absf(registro.x.dot(registro.y)) < .00001 and registro.determinant() > 0, "um registro uniforme positivo para braço inteiro")
	_verificar(vega.cap_proxima.transform == registro, "encaixe usa o mesmo registro do bíceps/antebraço/mão")
	_verificar(vega.cap_proxima.z_index > vega.tronco.z_index, "bíceps cobre a axila, não é cortado pela pele")
	for parte: Polygon2D in [vega.cap_proxima]:
		_verificar(not Geometry2D.triangulate_polygon(parte.polygon).is_empty(), "superfície curva triangulável")
	for indice: int in range(vega.cap_proxima.uv.size()):
		if is_equal_approx(vega.cap_proxima.uv[indice].y, 280):
			_verificar(vega.cap_proxima.polygon[indice] == vega.cap_proxima.uv[indice], "borda inferior do encaixe não abre do bíceps")
	_verificar(FileAccess.get_sha256("res://prototipos/vega_2d/corpo_articulado/bracos_prancha/tronco_encaixe_01.png") == "5a12b8d881c84112799f87e07a0eac2ab818fa8d07ffa7cb6702a0cd20ac9f26", "nova fonte de edição localizada identificada")
	var config := ConfigFile.new()
	_verificar(config.load("res://prototipos/vega_2d/corpo_articulado/bracos_prancha/tronco_encaixe_01.png.import") == OK and config.get_value("params", "mipmaps/generate") == true, "mipmaps da edição do ombro")
	var imagem: Image = vega.OMBRO_EDITADO.get_image()
	_verificar(imagem.get_size() == Vector2i(1774, 887) and imagem.detect_alpha() != Image.ALPHA_NONE, "mesmo canvas e alfa real")
	if DisplayServer.get_name() == "headless":
		return
	# Tronco isolado, mesma transformação/filtro. Comparar toda a região
	# exterior à edição, não supor que o gerador preservou o resto da fonte.
	vega.tronco.show()
	vega.quadril.hide()
	vega.cabeca.hide()
	vega.recorte_proximo.hide()
	vega.recorte_distante.hide()
	vega.cap_proxima.hide()
	vega.tronco.material = vega.material_original
	await process_frame
	await RenderingServer.frame_post_draw
	var antes: Image = tela.get_texture().get_image()
	vega.tronco.material = vega.material_ombro
	await process_frame
	await RenderingServer.frame_post_draw
	var depois: Image = tela.get_texture().get_image()
	var iguais: int = 0
	var modificados: int = 0
	var exterior_diferente: int = 0
	var inverso: Transform2D = vega.tronco.transform.affine_inverse()
	for y: int in range(170, 390):
		for x: int in range(150, 400):
			var p := Vector2i(x, y)
			var uv: Vector2 = inverso * (Vector2(p) + Vector2(.5, .5))
			var fora: bool = uv.x >= 330 or uv.y >= 485 or uv.y <= 185
			var cor_antes: Color = antes.get_pixelv(p)
			var cor_depois: Color = depois.get_pixelv(p)
			if fora:
				if cor_antes == cor_depois:
					iguais += 1
				else:
					exterior_diferente += 1
			elif cor_antes != cor_depois:
				modificados += 1
	_verificar(iguais > 10000 and exterior_diferente == 0, "sem escurecer/alterar tronco fora da região do ombro")
	_verificar(modificados > 200, "edição efetivamente altera a região do ombro")
	print("Ombro local: ", iguais, " pontos externos idênticos; ", exterior_diferente, " externos diferentes; ", modificados, " internos alterados.")
