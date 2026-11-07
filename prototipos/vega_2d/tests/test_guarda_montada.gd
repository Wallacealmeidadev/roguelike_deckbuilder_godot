extends SceneTree
## Guarda estática: centros/continuidade amostrada não aprovam anatomia.

const CENA: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/guarda_montada/vega_guarda.tscn")
const BASE: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/camadas_guarda/camadas_guarda.tscn")
const PREVIA: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/guarda_montada/preview.tscn")
const APROVADA: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/combo_fibras/vega_combo.tscn")
var falhas: int = 0
var amostras_cpu: int = 0
var amostras_gpu: int = 0
var sobreposicao_ventres: Vector2i = Vector2i.ZERO


func _initialize() -> void:
	_executar.call_deferred()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		if falhas <= 12:
			push_error("GUARDA MONTADA: " + mensagem)


func _executar() -> void:
	create_timer(20).timeout.connect(func() -> void:
		push_error("GUARDA MONTADA: teste excedeu 20 s")
		quit(1))
	var vega: VegaGuardaMontadaV1 = CENA.instantiate() as VegaGuardaMontadaV1
	var base: CamadasGuardaV1 = BASE.instantiate() as CamadasGuardaV1
	root.add_child(vega)
	root.add_child(base)
	_verificar(vega.tronco.texture == base.tronco.texture and vega.quadril_frente.texture == base.quadril_frente.texture,
		"mesmas fontes aprovadas de tronco e quadril")
	_verificar(vega.registro_tronco == base.registro_tronco and vega.registro_quadril == base.registro_quadril,
		"registro aprovado não recalibrado")
	_verificar(vega.proximo.position.is_equal_approx(vega.registro_tronco * vega.insercao_proxima_fonte)
		and vega.distante.position.is_equal_approx(vega.registro_tronco * vega.insercao_distante_fonte), "inserções derivadas do tronco")
	_verificar((vega.cabeca.transform * vega.pescoco_cabeca_fonte).distance_to(vega.pescoco_referencia) < .001, "registro da cabeça")
	_verificar(vega.pescoco_cabeca_fonte == Vector2(610, 140), "encaixe corrigido sem voltar ao marco alto da nuca")
	_verificar(Geometry2D.is_point_in_polygon(Vector2(625, 155), vega.cabeca.uv), "recorte preserva aba sob a mandíbula")
	_verificar(not Geometry2D.is_point_in_polygon(Vector2(690, 179), vega.cabeca.uv), "sem fragmento solto do ombro antigo")
	_verificar(vega.cabeca.scale.is_equal_approx(Vector2(.85, .85)), "cabeça reduzida uniformemente a 85%, sem mudar âncora")
	_verificar(not Geometry2D.is_point_in_polygon(Vector2(530, 150), vega.cabeca.uv), "recorte exclui ombro da pintura antiga")
	_verificar(vega.proximo.segmentos[0].z_index + vega.proximo.z_index < vega.tronco.z_index
		and vega.biceps_frente.z_index + vega.proximo.z_index > vega.tronco.z_index
		and vega.proximo.segmentos[1].z_index + vega.proximo.z_index > vega.tronco.z_index,
		"só cap sob deltoide; bíceps e antebraço à frente")
	_verificar(vega.distante.z_index + 4 < vega.tronco.z_index and vega.cabeca.z_index > vega.tronco.z_index,
		"distante atrás, cabeça cobre aba do pescoço")
	_verificar(vega.z_index + vega.distante.z_index + 1 > 0, "membros de trás acima do fundo da bancada")
	_verificar(vega.proximo.segmentos[2].scale.is_equal_approx(Vector2(.76, -.76))
		and is_equal_approx(vega.distante.segmentos[2].scale.x, vega.distante.fator_mao_interna * 1.20), "calibrações das mãos conservadas")
	_verificar(vega.distante.transform.determinant() < 0, "projeção distante com vista palmar própria")
	_verificar((vega.to_local(vega.proximo.cotovelo.global_position) - vega.proximo.position).distance_to(vega.cotovelo_proximo_relativo) < .001,
		"cotovelo próximo segue a guarda candidata, não a postura anterior")
	_verificar((vega.to_local(vega.proximo.punho.global_position) - vega.proximo.position).distance_to(vega.punho_proximo_relativo) < .001,
		"punho próximo registrado em conjunto com cotovelo")
	_verificar_montagem_aceita(vega)
	var fontes: Dictionary[String, String] = {
		"res://vega_animada/combate_v2/base_e_punhos_01.png": "c7a326bb5d511024b428d18dfce285add8d7b886030b1c5fe77f2d8f30733606",
		"res://prototipos/vega_2d/braco_reconstruido/braco_montado_01.png": "363c74b21ce88d01c5b00db286004bf59cac36a8d53a46617f5cf2648fb40fad",
		"res://prototipos/vega_2d/braco_reconstruido/distante/braco_interno_01.png": "5e8e596f39f29c5c10bfea3b56a4336700bf81b44f409a22dcaaeaa9e2cc31a6",
		"res://prototipos/vega_2d/corpo_articulado/camadas_guarda/tronco_02.png": "293bc2349cb0b8c9b90e72b295a8d181af0d5bc54755031115544a907fd0c982",
		"res://prototipos/vega_2d/corpo_articulado/camadas_guarda/quadril_01.png": "07b433e69ab4dfb27493126665100778078ce7f6699d7d74b097df4b75d01f76"}
	for caminho: String in fontes:
		_verificar(FileAccess.get_sha256(caminho) == fontes[caminho], "PNG original preservado: " + caminho)
	for braco: BracoRegistradoV1 in [vega.proximo, vega.distante]:
		_verificar(braco.segmentos.size() == 3 and is_equal_approx(absf(braco.scale.x), absf(braco.scale.y)), "três partes, escala uniforme")
		var superior: float = vega.cotovelo_proximo_relativo.length() if braco == vega.proximo else braco.SUPERIOR
		var inferior: float = (vega.punho_proximo_relativo - vega.cotovelo_proximo_relativo).length() if braco == vega.proximo else braco.INFERIOR
		_verificar(is_equal_approx(braco.cotovelo.position.x, superior)
			and is_equal_approx(braco.punho.position.x, inferior), "comprimentos coerentes com registro explícito da pose")
		for registro: Transform2D in braco.registros:
			_verificar(absf(registro.x.length() - registro.y.length()) < .00001, "nenhum recorte achatado para criar volume")
		_verificar(braco.segmentos[2].to_global(Vector2.ZERO).distance_to(braco.punho.global_position) < .001, "mão no centro do punho")
		var fonte: Image = braco.segmentos[0].texture.get_image()
		for osso: Bone2D in [braco.ombro, braco.cotovelo, braco.punho]:
			for y: int in range(-4, 5, 2):
				for x: int in range(-4, 5, 2):
					_verificar(_pintado(braco, fonte, osso.to_global(Vector2(x, y))), "CPU: continuidade da própria prótese")
					amostras_cpu += 1
	var repouso: Transform2D = vega.proximo.punho.global_transform
	sobreposicao_ventres = _medir_ventres(vega)
	_verificar(sobreposicao_ventres.y > 100 and sobreposicao_ventres.x == 0, "ventres próximos não se sobrepõem na faixa central amostrada")
	for quadro: int in range(12):
		await process_frame
	_verificar(repouso == vega.proximo.punho.global_transform, "guarda estática sem escritor por quadro")
	base.free()
	vega.free()
	_verificar_previa()
	if DisplayServer.get_name() != "headless":
		await _verificar_gpu()
	await process_frame
	print("Guarda montada: ", falhas, " falhas; juntas CPU ", amostras_cpu, "; GPU ", amostras_gpu,
		"; ventres sobrepostos/pintados ", sobreposicao_ventres)
	quit(0 if falhas == 0 else 1)


func _pintado(braco: BracoRegistradoV1, fonte: Image, ponto: Vector2) -> bool:
	var malhas: Array[Polygon2D] = braco.segmentos.duplicate()
	var registros: Array[Transform2D] = braco.registros.duplicate()
	var biceps: Polygon2D = braco.ombro.get_node_or_null("BicepsVisivel") as Polygon2D
	if is_instance_valid(biceps):
		malhas.append(biceps)
		registros.append(braco.registros[0])
	for indice: int in range(malhas.size()):
		var uv: Vector2 = registros[indice].affine_inverse() * malhas[indice].to_local(ponto)
		if Geometry2D.is_point_in_polygon(uv, malhas[indice].uv):
			var pixel := Vector2i(uv.round())
			if Rect2i(Vector2i.ZERO, fonte.get_size()).has_point(pixel) and fonte.get_pixelv(pixel).a > .9:
				return true
	return false


func _medir_ventres(vega: VegaGuardaMontadaV1) -> Vector2i:
	var braco: BracoRegistradoV1 = vega.proximo
	var fonte: Image = braco.ARTE.get_image()
	var contagem := Vector2i.ZERO
	for y: int in range(893, 1002, 6):
		for x: int in range(280, 751, 6):
			var uv := Vector2(x, y)
			if fonte.get_pixel(x, y).a < .9 or not Geometry2D.is_point_in_polygon(uv, braco.segmentos[1].uv):
				continue
			contagem.y += 1
			var mundo: Vector2 = braco.segmentos[1].to_global(braco.registros[1] * uv)
			for superior: Polygon2D in [braco.segmentos[0], vega.biceps_frente]:
				var na_fonte: Vector2 = braco.registros[0].affine_inverse() * superior.to_local(mundo)
				var pixel := Vector2i(na_fonte.round())
				if Geometry2D.is_point_in_polygon(na_fonte, superior.uv) and Rect2i(Vector2i.ZERO, fonte.get_size()).has_point(pixel) and fonte.get_pixelv(pixel).a > .9:
					contagem.x += 1
					break
	return contagem


func _verificar_montagem_aceita(vega: VegaGuardaMontadaV1) -> void:
	var aprovada: VegaComboFibrasV1 = APROVADA.instantiate() as VegaComboFibrasV1
	aprovada.size = Vector2(650, 850)
	root.add_child(aprovada)
	aprovada.definir_combo_visual(0, true)
	aprovada.inspecionar_presenca(false, 0)
	var pares: Array[Array] = [[vega.proximo, aprovada.braco_novo], [vega.distante, aprovada.novo_distante]]
	for par: Array in pares:
		var novo: BracoRegistradoV1 = par[0] as BracoRegistradoV1
		var antigo: BracoRegistradoV1 = par[1] as BracoRegistradoV1
		var matriz_aceita: Transform2D = aprovada.modelo.global_transform.affine_inverse() * antigo.global_transform
		var esperada: Transform2D = vega.registro_bracos * matriz_aceita
		_verificar(esperada.origin.distance_to(novo.position) < .001, "inserção preservada na revisão de pose")
		if novo == vega.distante:
			_verificar(esperada.x.distance_to(novo.transform.x) < .00001 and esperada.y.distance_to(novo.transform.y) < .00001,
				"distante continua com registro aceito, sem mudança nesta etapa")
		for indice: int in range(3):
			var osso_novo: Bone2D = [novo.ombro, novo.cotovelo, novo.punho][indice]
			var osso_antigo: Bone2D = [antigo.ombro, antigo.cotovelo, antigo.punho][indice]
			var destino: Vector2 = vega.registro_bracos * aprovada.modelo.to_local(osso_antigo.global_position)
			if novo == vega.distante:
				_verificar(destino.distance_to(vega.to_local(osso_novo.global_position)) < .001, "juntas distantes preservadas")
			_verificar(novo.segmentos[indice].texture == antigo.segmentos[indice].texture
				and novo.segmentos[indice].scale == antigo.segmentos[indice].scale, "fontes e calibrações aceitas preservadas")
		# Amostrar os dois recortes do superior próximo como união exata
		# do contorno aceito, sem esconder o bíceps nem duplicar área interna.
		if novo == vega.proximo:
			for y: int in range(10, 716, 15):
				for x: int in range(285, 751, 15):
					var p := Vector2(x, y)
					var original: bool = Geometry2D.is_point_in_polygon(p, antigo.segmentos[0].uv)
					var cap: bool = Geometry2D.is_point_in_polygon(p, novo.segmentos[0].uv)
					var frente: bool = Geometry2D.is_point_in_polygon(p, vega.biceps_frente.uv)
					var borda_comum: bool = is_equal_approx(p.y, vega.CORTE_CAP_FONTE)
					_verificar((cap or frente) == original and (not (cap and frente) or borda_comum), "cap/bíceps particionam a mesma pintura, só compartilham a borda")
	aprovada.free()


func _verificar_previa() -> void:
	var previa: Node2D = PREVIA.instantiate() as Node2D
	root.add_child(previa)
	_verificar(previa.ver_prancha and not previa.referencia_nativa.visible
		and not previa.atriz_aprovada.modelo.animacao.is_playing(), "referência real aceita, pausada em Combo zero")
	_tecla(previa, KEY_V)
	_verificar(not previa.ver_prancha and not previa.prancha.visible and previa.referencia_nativa.visible, "V compara com a prova aceita sem trocar peças")
	for tecla: Key in [KEY_O, KEY_B, KEY_C, KEY_T, KEY_P, KEY_Z]:
		_tecla(previa, tecla)
	_verificar(previa.vega.mostrar_marcos and previa.ampliada and not previa.vega.proximo.visible
		and not previa.vega.distante.visible and not previa.vega.cabeca.visible
		and not previa.vega.tronco.visible and not previa.vega.quadril.visible, "atalhos de inspeção")
	_tecla(previa, KEY_R)
	_verificar(not previa.vega.mostrar_marcos and not previa.ampliada and previa.vega.proximo.visible
		and previa.vega.distante.visible and previa.vega.cabeca.visible
		and previa.vega.tronco.visible and previa.vega.quadril.visible
		and previa.ver_prancha and not previa.referencia_nativa.visible, "R restaura montagem e prancha alvo")
	previa.free()


func _tecla(previa: Node2D, tecla: Key) -> void:
	var evento := InputEventKey.new()
	evento.keycode = tecla
	evento.pressed = true
	previa._unhandled_key_input(evento)


func _verificar_gpu() -> void:
	var tela := SubViewport.new()
	tela.size = Vector2i(650, 650)
	tela.transparent_bg = true
	tela.world_2d = World2D.new()
	tela.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(tela)
	var vega: VegaGuardaMontadaV1 = CENA.instantiate() as VegaGuardaMontadaV1
	tela.add_child(vega)
	# Primeiro só uma prótese: corpo e outro braço não podem mascarar vãos.
	for item: CanvasItem in [vega.cabeca, vega.tronco, vega.quadril, vega.proximo, vega.distante]:
		item.hide()
	for braco: BracoRegistradoV1 in [vega.proximo, vega.distante]:
		braco.show()
		await process_frame
		await RenderingServer.frame_post_draw
		var imagem: Image = tela.get_texture().get_image()
		for osso: Bone2D in [braco.ombro, braco.cotovelo, braco.punho]:
			for y: int in range(-4, 5, 2):
				for x: int in range(-4, 5, 2):
					var p := Vector2i(osso.to_global(Vector2(x, y)).round())
					_verificar(imagem.get_pixelv(p).a > .9, "GPU: junta opaca sem apoio de outra peça")
					amostras_gpu += 1
		braco.hide()
	for item: CanvasItem in [vega.cabeca, vega.tronco, vega.quadril, vega.proximo, vega.distante]:
		item.show()
	await process_frame
	await RenderingServer.frame_post_draw
	var montagem: Image = tela.get_texture().get_image()
	# A máscara de junção não deve alterar boca, queixo, olhos ou testa.
	var material_cabeca: Material = vega.cabeca.material
	vega.cabeca.material = null
	await process_frame
	await RenderingServer.frame_post_draw
	var sem_mascara: Image = tela.get_texture().get_image()
	for fonte: Vector2 in [Vector2(580, 65), Vector2(630, 85), Vector2(650, 115), Vector2(655, 140)]:
		var pixel := Vector2i((vega.cabeca.transform * fonte).round())
		_verificar(montagem.get_pixelv(pixel).is_equal_approx(sem_mascara.get_pixelv(pixel)), "GPU: transição não altera o rosto")
	vega.cabeca.material = material_cabeca
	for item: CanvasItem in [vega.tronco, vega.quadril, vega.proximo, vega.distante]:
		item.hide()
	await process_frame
	await RenderingServer.frame_post_draw
	var so_cabeca: Image = tela.get_texture().get_image()
	var sob_mandibula := Vector2i((vega.cabeca.transform * Vector2(625, 155)).round())
	_verificar(so_cabeca.get_pixelv(sob_mandibula).a > .9, "GPU: aba sob a mandíbula existe sem o corpo mascarar o recorte")
	for item: CanvasItem in [vega.tronco, vega.quadril, vega.proximo, vega.distante]:
		item.show()
	# Faixa central do pescoço e raízes dos ombros, na pose estática.
	for ponto: Vector2 in [Vector2(300, 185), Vector2(300, 195), Vector2(300, 205),
		vega.proximo.position, vega.distante.position]:
		for y: int in range(-2, 3):
			for x: int in range(-2, 3):
				_verificar(montagem.get_pixelv(Vector2i((ponto + Vector2(x, y)).round())).a > .9, "GPU: transição opaca na montagem")
				amostras_gpu += 1
	# Reproduzir o fundo da bancada detecta o erro inicial de z negativo.
	var fundo := Polygon2D.new()
	fundo.polygon = PackedVector2Array([Vector2.ZERO, Vector2(650, 0), Vector2(650, 650), Vector2(0, 650)])
	fundo.color = Color("24303e")
	tela.add_child(fundo)
	await process_frame
	await RenderingServer.frame_post_draw
	var com_fundo: Image = tela.get_texture().get_image()
	for ponto: Vector2 in [vega.cabeca.transform * Vector2(650, 100), vega.distante.punho.global_position]:
		var pixel := Vector2i(ponto.round())
		var antes: Color = montagem.get_pixelv(pixel)
		var depois: Color = com_fundo.get_pixelv(pixel)
		# Fundo opaco eleva alfa ~.99 a 1. RGB deve continuar sendo a peça,
		# não a cor do fundo. Não exigir invariância do canal alfa composto.
		var erro_rgb: float = maxf(absf(antes.r - depois.r), maxf(absf(antes.g - depois.g), absf(antes.b - depois.b)))
		_verificar(antes.a > .99 and depois.a == 1.0 and erro_rgb < 2.0 / 255.0, "GPU: rosto e braço distante visíveis acima do fundo")
	tela.free()
