extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		if falhas <= 12:
			push_error("ACABAMENTO PROXIMO: " + mensagem)


func _executar() -> void:
	var original: VegaCombateNativo = (load("res://vega_animada/rig_nativo_v2/vega_combate.tscn") as PackedScene).instantiate() as VegaCombateNativo
	var novo: VegaAcabamentoProximo = (load("res://prototipos/vega_2d/rig_nativo_v2/acabamento_proximo/vega_prova.tscn") as PackedScene).instantiate() as VegaAcabamentoProximo
	for ator: VegaCombateNativo in [original, novo]:
		ator.size = Vector2(400, 420)
		add_child(ator)
		ator.atualizar_estado(0, true, false)
	await get_tree().process_frame
	var a: ApoioCorporalNativoV2 = original.modelo
	var b: ApoioCorporalNativoV2 = novo.modelo
	_verificar(b.malhas.size() == 4 and novo.remendo_ombro != null, "variante usa rig e pintura local")
	_verificar(novo.remendo_ombro.polygon == a.pele.polygon and novo.remendo_ombro.polygons.size() > 0
		and novo.remendo_ombro.polygons.size() < a.pele.polygons.size(), "remendo conserva geometria e seleciona so faces locais")
	for osso: int in a.pele.get_bone_count():
		_verificar(novo.remendo_ombro.get_bone_weights(osso) == a.pele.get_bone_weights(osso), "pesos do ombro identicos a pele")
	for indice: int in range(4):
		var esperados: PackedVector2Array = a.bases[indice].duplicate()
		if indice == 2:
			esperados = _borda_expandida(esperados)
		_verificar(esperados == b.bases[indice] and a.deslocamentos[indice] == b.deslocamentos[indice],
			"so borda cortada do biceps muda; interior e perfil de Combo preservados")
		_verificar(b.malhas[indice].texture == (VegaAcabamentoProximo.ATLAS if indice < 2 else VegaAcabamentoProximo.ATLAS_INTERNO), "cada lado recebe sua vista propria")
	_verificar(a.pele.texture == b.pele.texture and a.pele.material == b.pele.material and a.pele.uv == b.pele.uv, "corpo original nao e sobrescrito")
	_conferir_recorte_e_filtro(novo)
	for caminho: String in ["Arte/FibraJunta", "Arte/Junta", "Arte/PlacaA", "Arte/PlacaB", "Arte/PlacaC"]:
		var antigo: Sprite2D = a.braco_original.cotovelo.get_node(caminho) as Sprite2D
		var novo_sprite: Sprite2D = b.braco_original.cotovelo.get_node(caminho) as Sprite2D
		_verificar(antigo.transform == novo_sprite.transform and antigo.texture != novo_sprite.texture, "placas mantem dimensoes/ancoras com textura privada")
		_verificar((antigo.texture as AtlasTexture).atlas == VegaAcabamentoProximo.ORIGINAL, "recurso original nao contaminado")
		var distante_a: Sprite2D = a.braco_distante.cotovelo.get_node(caminho) as Sprite2D
		var distante_b: Sprite2D = b.braco_distante.cotovelo.get_node(caminho) as Sprite2D
		_verificar(distante_a.transform == distante_b.transform
			and (distante_b.texture as AtlasTexture).atlas == VegaAcabamentoProximo.ATLAS_INTERNO,
			"pecas distantes recebem face interna sem virar eixos/ancoras outra vez")
	for braco: BracoNativoV2 in [a.braco_original, a.braco_distante]:
		var outro: BracoNativoV2 = b.braco_original if braco == a.braco_original else b.braco_distante
		var mao_a: Sprite2D = braco.punho.get_node("Mao") as Sprite2D
		var mao_b: Sprite2D = outro.punho.get_node("Mao") as Sprite2D
		_verificar(mao_a.position == mao_b.position and is_equal_approx(mao_b.rotation, PI / 2)
			and mao_b.scale == Vector2(.13, .13), "punhos pareados conservam encaixe, eixo longitudinal e escala comum")
		var atlas_esperado: Texture2D = VegaAcabamentoProximo.PUNHO_DORSAL if braco == a.braco_original else VegaAcabamentoProximo.PUNHOS
		_verificar((mao_b.texture as AtlasTexture).atlas == atlas_esperado
			and not mao_b.get_node("MioloLuva").visible, "dorso corrigido e palma anterior, sem miolo antigo sobreposto")
		for nome: String in ["ConectorPunho", "InteriorSoquete"]:
			var conector: Polygon2D = outro.punho.get_node(nome) as Polygon2D
			_verificar(conector.transform == Transform2D.IDENTITY and conector.visible,
				"conector segue o punho sem compensacao por frame")
			var imagem: Image = conector.texture.get_image()
			for uv: Vector2 in conector.uv:
				_verificar(imagem.get_pixel(int(uv.x), int(uv.y)).a > .95, "amostra de fibra do conector nao possui recorte transparente")
		_verificar(Geometry2D.is_point_in_polygon(Vector2(-7.7, .4), (outro.punho.get_node("ConectorPunho") as Polygon2D).polygon),
			"manga sobrepoe o interior do soquete, nao termina antes dele")
		_verificar(not outro.punho.get_node("NucleoPunho").visible, "nucleo antigo nao duplica o volume da manga")
		var miolo: Polygon2D = outro.punho.get_node("InteriorSoquete") as Polygon2D
		_verificar(miolo.material is ShaderMaterial, "interior possui mascara privada do aro")
		var manga: Polygon2D = outro.punho.get_node("ConectorPunho") as Polygon2D
		for ponto: Vector2 in manga.polygon:
			_verificar(ponto.x <= 10 and ponto.y >= -12, "manga curta nao conserva saliencia antiga")
		_verificar(not outro.cotovelo.get_node("Arte/FibraJunta").visible, "remendo retangular do cotovelo oculto")
		var nucleo: Polygon2D = outro.cotovelo.get_node("Arte/NucleoCotovelo") as Polygon2D
		for ponto: Vector2 in nucleo.polygon:
			var normalizado: Vector2 = (ponto - Vector2(8.5, 226)) / Vector2(41, 17)
			_verificar(normalizado.length_squared() <= 1.0001, "miolo do cotovelo contido sob a junta")
	var ossos: Array[Node] = a.find_children("*", "Bone2D", true, false)
	for carga: int in [0, 10]:
		a.definir_combo(carga, true)
		b.definir_combo(carga, true)
		for nome: StringName in [&"respirar", &"soco", &"soco_distante", &"dano"]:
			for rig: ApoioCorporalNativoV2 in [a, b]:
				rig.animacao.play(nome, 0)
				rig.animacao.pause()
			var duracao: float = a.animacao.get_animation(nome).length
			for amostra: int in range(57):
				for rig: ApoioCorporalNativoV2 in [a, b]:
					rig.animacao.seek(duracao * amostra / 56, true)
				for no: Node in ossos:
					var osso_a: Bone2D = no as Bone2D
					var osso_b: Bone2D = b.get_node(a.get_path_to(no)) as Bone2D
					var esperado: Transform2D = osso_a.transform
					if osso_a == a.braco_distante.cotovelo:
						esperado = Transform2D(_angulo_distante_esperado(a, nome, duracao * amostra / 56), osso_a.position)
					_verificar(esperado.is_equal_approx(osso_b.transform) and osso_a.length == osso_b.length,
						"somente dobra distante muda; demais poses/comprimentos identicos")
		for indice: int in range(4):
			var esperado: PackedVector2Array = b.bases[indice].duplicate()
			for ponto: int in esperado.size():
				esperado[ponto] += a.deslocamentos[indice][ponto] * b.tensao_combo
			_verificar(esperado == b.malhas[indice].polygon, "Combo conserva deltas, inclusive na borda completada")
	for rig: ApoioCorporalNativoV2 in [a, b]:
		rig.definir_combo(0, true)
		rig.definir_pose(&"repouso", true)
	_conferir_guarda(novo)
	if DisplayServer.get_name() != "headless":
		await _verificar_mascara(novo)
		await _verificar_folga_pele(novo)
		await _verificar_soquetes_gpu(novo)
		await _verificar_mascara_aro(novo)
		if "--capturar" in OS.get_cmdline_user_args():
			await _capturar_ampliado(novo)
	novo.socar()
	_verificar(not novo.ultimo_braco_distante, "primeiro golpe proximo")
	novo.socar()
	_verificar(novo.ultimo_braco_distante, "segundo golpe distante preservado")
	novo.atualizar_estado(10, true, true)
	_verificar(not b.animacao.is_playing() and b.tensao_combo == 1, "reduzido preserva guarda e destino de Combo")
	novo.reiniciar()
	_verificar(not novo.proximo_braco_distante and b.combo == 0, "reset preservado")
	original.queue_free()
	novo.queue_free()
	await get_tree().process_frame
	print("TEST ACABAMENTO PROXIMO: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _angulo_distante_esperado(original: ApoioCorporalNativoV2, nome: StringName, tempo: float) -> float:
	var fonte: Animation = original.animacao.get_animation(nome)
	var clipe: Animation = fonte.duplicate(true) as Animation
	for chave: int in clipe.track_get_key_count(9):
		var angulo: float = fonte.track_get_key_value(9, chave)
		if nome == &"respirar" or angulo > PI / 2:
			clipe.track_set_key_value(9, chave, angulo + VegaAcabamentoProximo.ABERTURA_COTOVELO)
	return clipe.value_track_interpolate(9, tempo)


func _conferir_guarda(ator: VegaAcabamentoProximo) -> void:
	var rig: ApoioCorporalNativoV2 = ator.modelo
	var original: Animation = preload("res://vega_animada/rig_nativo_v2/respirar.tres")
	_verificar(is_equal_approx(original.track_get_key_value(9, 0), deg_to_rad(168)), "respiracao original compartilhada nao contaminada")
	for nome: StringName in [&"respirar", &"soco", &"soco_distante", &"dano"]:
		var clipe: Animation = rig.animacao.get_animation(nome)
		rig.animacao.play(nome, 0)
		rig.animacao.pause()
		for i: int in range(57):
			var tempo: float = clipe.length * i / 56
			rig.animacao.seek(tempo, true)
			var punho: Vector2 = rig.to_local(rig.braco_distante.punho.global_position)
			var ombro: Vector2 = rig.to_local(rig.braco_distante.ombro.global_position)
			_verificar(punho.x - ombro.x > 60, "punho distante nao cruza para dentro do ombro em espera/golpes/dano")
			_verificar(rig.apoios.transform == rig.apoios.rest, "apoios fixos")
	rig.definir_pose(&"repouso", true)


func _capturar_ampliado(ator: VegaAcabamentoProximo) -> void:
	var pasta: String = "res://docs/evidencias_vega_face_interna_01"
	if "--dedao" in OS.get_cmdline_user_args():
		pasta = "res://docs/evidencias_vega_face_interna_02"
	if "--recorte" in OS.get_cmdline_user_args():
		pasta = "res://docs/evidencias_vega_recorte_filtro_01"
	if "--punhos" in OS.get_cmdline_user_args():
		pasta = "res://docs/evidencias_vega_soquetes_01"
	if "--juntas" in OS.get_cmdline_user_args():
		pasta = "res://docs/evidencias_vega_juntas_01"
	DirAccess.make_dir_recursive_absolute(pasta)
	if "--recorte" in OS.get_cmdline_user_args():
		ator.modelo.definir_combo(0, true)
		ator.modelo.animacao.play(&"respirar", 0)
		ator.modelo.animacao.pause()
		ator.modelo.animacao.seek(0, true)
		for filtro: CanvasItem.TextureFilter in [CanvasItem.TEXTURE_FILTER_LINEAR, CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS]:
			for parte: CanvasItem in [ator.modelo, ator.modelo.braco_original, ator.modelo.braco_distante]:
				parte.texture_filter = filtro
			await RenderingServer.frame_post_draw
			var arquivo: String = "%s/filtro_%s_tamanho_jogo.png" % [pasta, "antes" if filtro == CanvasItem.TEXTURE_FILTER_LINEAR else "depois"]
			_verificar(ator.modelo.get_viewport().get_texture().get_image().save_png(arquivo) == OK, "salvar comparacao de filtro")
	ator.size = Vector2(800, 850)
	await get_tree().process_frame
	await get_tree().process_frame
	for carga: int in [0, 10]:
		ator.modelo.definir_combo(carga, true)
		for nome: StringName in [&"respirar", &"soco", &"soco_distante"]:
			ator.modelo.animacao.play(nome, 0)
			ator.modelo.animacao.pause()
			ator.modelo.animacao.seek(0 if nome == &"respirar" else .2, true)
			await RenderingServer.frame_post_draw
			var arquivo: String = "%s/ampliado_%s_combo%d.png" % [pasta, nome, carga]
			var erro: Error = ator.modelo.get_viewport().get_texture().get_image().save_png(arquivo)
			_verificar(erro == OK, "salvar captura ampliada")
	if "--punhos" in OS.get_cmdline_user_args():
		ator.modelo.definir_combo(0, true)
		ator.modelo.animacao.play(&"respirar", 0)
		ator.modelo.animacao.pause()
		ator.modelo.animacao.seek(0, true)
		var janela: Viewport = ator.modelo.get_viewport()
		var anterior: Transform2D = janela.canvas_transform
		for lado: int in range(2):
			var braco: BracoNativoV2 = ator.modelo.braco_original if lado == 0 else ator.modelo.braco_distante
			var centro: Vector2 = braco.punho.global_position
			janela.canvas_transform = Transform2D(Vector2(4, 0), Vector2(0, 4), Vector2(janela.size) * .5 - centro * 4)
			await RenderingServer.frame_post_draw
			_verificar(janela.get_texture().get_image().save_png("%s/soquete_%s_zoom.png" % [pasta, "proximo" if lado == 0 else "distante"]) == OK, "capturar soquete ampliado")
		janela.canvas_transform = anterior
	if "--juntas" in OS.get_cmdline_user_args():
		ator.modelo.animacao.play(&"respirar", 0)
		ator.modelo.animacao.pause()
		ator.modelo.animacao.seek(0, true)
		var janela: Viewport = ator.modelo.get_viewport()
		for lado: int in range(2):
			var braco: BracoNativoV2 = ator.modelo.braco_original if lado == 0 else ator.modelo.braco_distante
			janela.canvas_transform = Transform2D(Vector2(3, 0), Vector2(0, 3), Vector2(janela.size) * .5 - braco.cotovelo.global_position * 3)
			await RenderingServer.frame_post_draw
			_verificar(janela.get_texture().get_image().save_png("%s/cotovelo_%d_zoom.png" % [pasta, lado]) == OK, "capturar cotovelo")
		janela.canvas_transform = Transform2D.IDENTITY
	ator.size = Vector2(400, 420)
	ator.modelo.definir_combo(0, true)
	ator.modelo.definir_pose(&"repouso", true)


func _borda_expandida(fonte: PackedVector2Array) -> PackedVector2Array:
	var pontos: PackedVector2Array = fonte.duplicate()
	for i: int in pontos.size():
		if is_zero_approx(fonte[i].x):
			pontos[i].x -= 12
		elif is_equal_approx(fonte[i].x, 298):
			pontos[i].x += 12
		if is_zero_approx(fonte[i].y):
			pontos[i].y -= 8
		elif is_equal_approx(fonte[i].y, 358):
			pontos[i].y += 8
	return pontos


func _conferir_recorte_e_filtro(ator: VegaAcabamentoProximo) -> void:
	var rig: ApoioCorporalNativoV2 = ator.modelo
	for parte: CanvasItem in [rig, rig.braco_original, rig.braco_distante]:
		_verificar(parte.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS, "sem override linear simples em um dos bracos")
	for textura: Texture2D in [ator.ATLAS, ator.ATLAS_INTERNO, ator.PUNHOS, ator.PUNHO_DORSAL, rig.pele.texture]:
		_verificar(textura.get_image().has_mipmaps(), "textura reduzida possui niveis de mipmap importados")
	_verificar(rig.get_viewport().msaa_2d == Viewport.MSAA_DISABLED, "nao exigir MSAA 2D nao suportado pelo GL Compatibility")
	var recorte: Rect2i = Rect2i(110, 491, 322, 374)
	var imagem: Image = ator.ATLAS_INTERNO.get_image()
	var cortados: int = 0
	for y: int in range(recorte.position.y, recorte.end.y):
		for x: int in [recorte.position.x, recorte.end.x - 1]:
			if imagem.get_pixel(x, y).a > .1:
				cortados += 1
	for x: int in range(recorte.position.x, recorte.end.x):
		for y: int in [recorte.position.y, recorte.end.y - 1]:
			if imagem.get_pixel(x, y).a > .1:
				cortados += 1
	print("BICEPS: %d pixels opacos na borda do recorte novo" % cortados)
	_verificar(cortados == 0, "nenhuma borda do recorte novo corta a silhueta pintada")


func _verificar_mascara(ator: VegaAcabamentoProximo) -> void:
	var rig: ApoioCorporalNativoV2 = ator.modelo
	rig.braco_original.hide()
	rig.braco_distante.hide()
	rig.pele.hide()
	await RenderingServer.frame_post_draw
	var pintura: Image = rig.get_viewport().get_texture().get_image()
	ator.remendo_ombro.hide()
	rig.pele.show()
	await RenderingServer.frame_post_draw
	var corpo: Image = rig.get_viewport().get_texture().get_image()
	var pintados: int = 0
	var escaparam: int = 0
	for y: int in pintura.get_height():
		for x: int in pintura.get_width():
			var alfa: float = pintura.get_pixel(x, y).a
			if alfa > .1:
				pintados += 1
				if corpo.get_pixel(x, y).a < alfa - .05:
					escaparam += 1
	print("OMBRO GPU: %d pixels pintados / %d fora da silhueta" % [pintados, escaparam])
	_verificar(pintados > 50 and escaparam == 0, "pintura visivel respeita silhueta original sem ombro extra")
	ator.remendo_ombro.show()
	rig.braco_original.show()
	rig.braco_distante.show()


func _verificar_folga_pele(ator: VegaAcabamentoProximo) -> void:
	# Imagem do punho isolado contra pele quente do corpo, não só distância de pivôs.
	var rig: ApoioCorporalNativoV2 = ator.modelo
	var mao: Sprite2D = rig.braco_distante.punho.get_node("Mao") as Sprite2D
	var maiores: int = 0
	rig.animacao.play(&"respirar", 0)
	rig.animacao.pause()
	for tempo: float in [0.0, .6, 1.2, 1.8, 2.4]:
		rig.animacao.seek(tempo, true)
		rig.braco_original.hide()
		rig.braco_distante.hide()
		ator.remendo_ombro.hide()
		rig.pele.show()
		await RenderingServer.frame_post_draw
		var corpo: Image = rig.get_viewport().get_texture().get_image()
		rig.pele.hide()
		# Desenho temporário com a transformação global exata, sem ancestros ocultos.
		var isolada: Sprite2D = Sprite2D.new()
		isolada.texture = mao.texture
		isolada.centered = false
		isolada.offset = mao.offset
		rig.add_child(isolada)
		isolada.global_transform = mao.global_transform
		await RenderingServer.frame_post_draw
		var punho: Image = rig.get_viewport().get_texture().get_image()
		var sobrepostos: int = 0
		for y: int in corpo.get_height():
			for x: int in corpo.get_width():
				var cor: Color = corpo.get_pixel(x, y)
				if punho.get_pixel(x, y).a > .2 and cor.a > .8 and cor.r > cor.g * 1.15 and cor.g > cor.b * 1.1:
					sobrepostos += 1
		maiores = maxi(maiores, sobrepostos)
		isolada.queue_free()
		await get_tree().process_frame
	print("PUNHO/PELE GPU: maximo %d pixels sobrepostos na respiracao" % maiores)
	_verificar(maiores == 0, "punho inteiro nao invade pele do ombro no ciclo de guarda")
	rig.pele.show()
	ator.remendo_ombro.show()
	rig.braco_original.show()
	rig.braco_distante.show()
	rig.definir_pose(&"repouso", true)


func _verificar_soquetes_gpu(ator: VegaAcabamentoProximo) -> void:
	var rig: ApoioCorporalNativoV2 = ator.modelo
	var amostras: int = 0
	var falhas_alfa: int = 0
	var amostras_cotovelo: int = 0
	var falhas_cotovelo: int = 0
	for carga: int in [0, 10]:
		rig.definir_combo(carga, true)
		for nome: StringName in [&"respirar", &"soco", &"soco_distante", &"dano"]:
			rig.animacao.play(nome, 0)
			rig.animacao.pause()
			var duracao: float = rig.animacao.get_animation(nome).length
			for indice: int in range(29):
				rig.animacao.seek(duracao * indice / 28, true)
				await RenderingServer.frame_post_draw
				var imagem: Image = rig.get_viewport().get_texture().get_image()
				for braco: BracoNativoV2 in [rig.braco_original, rig.braco_distante]:
					var nucleo: Polygon2D = braco.cotovelo.get_node("Arte/NucleoCotovelo") as Polygon2D
					var pixel_cotovelo: Vector2 = nucleo.to_global(Vector2(8.5, 226))
					amostras_cotovelo += 1
					if imagem.get_pixel(int(pixel_cotovelo.x), int(pixel_cotovelo.y)).a < .95:
						falhas_cotovelo += 1
					for local: Vector2 in [Vector2(-7.7, .4), Vector2(8, -10)]:
						var pixel: Vector2 = braco.punho.to_global(local)
						amostras += 1
						if imagem.get_pixel(int(pixel.x), int(pixel.y)).a < .95:
							falhas_alfa += 1
	print("SOQUETES GPU: %d amostras / %d falhas de cobertura" % [amostras, falhas_alfa])
	print("COTOVELOS GPU: %d amostras / %d falhas de cobertura" % [amostras_cotovelo, falhas_cotovelo])
	_verificar(falhas_alfa == 0, "miolo/manga continuam cobertos em respiracao, dois socos e dano, Combo 0/10")
	_verificar(falhas_cotovelo == 0, "centro dos cotovelos nao abre lacunas nos mesmos clipes/Combos")
	rig.definir_combo(0, true)
	rig.definir_pose(&"repouso", true)


func _verificar_mascara_aro(ator: VegaAcabamentoProximo) -> void:
	var rig: ApoioCorporalNativoV2 = ator.modelo
	var janela: Viewport = rig.get_viewport()
	var pintados: int = 0
	var fora: int = 0
	var sobre_acento: int = 0
	var sobre_metal: int = 0
	for braco: BracoNativoV2 in [rig.braco_original, rig.braco_distante]:
		var mao: Sprite2D = braco.punho.get_node("Mao") as Sprite2D
		var miolo: Polygon2D = braco.punho.get_node("InteriorSoquete") as Polygon2D
		var fundo: Sprite2D = Sprite2D.new()
		fundo.texture = mao.texture
		fundo.centered = false
		fundo.offset = mao.offset
		janela.add_child(fundo)
		fundo.global_transform = mao.global_transform
		var pintura: Polygon2D = miolo.duplicate() as Polygon2D
		janela.add_child(pintura)
		pintura.global_transform = miolo.global_transform
		rig.hide()
		pintura.hide()
		await RenderingServer.frame_post_draw
		var aro: Image = janela.get_texture().get_image()
		fundo.hide()
		pintura.show()
		await RenderingServer.frame_post_draw
		var recortado: Image = janela.get_texture().get_image()
		for y: int in recortado.get_height():
			for x: int in recortado.get_width():
				if recortado.get_pixel(x, y).a < .08:
					continue
				pintados += 1
				var original: Color = aro.get_pixel(x, y)
				var maior: float = maxf(original.r, maxf(original.g, original.b))
				var menor: float = minf(original.r, minf(original.g, original.b))
				if original.a < .8:
					fora += 1
				if maior - menor > .25:
					sobre_acento += 1
				if maior > .5:
					sobre_metal += 1
		fundo.queue_free()
		pintura.queue_free()
		rig.show()
		await get_tree().process_frame
	print("ARO GPU: %d pixels pintados / %d fora / %d acento / %d metal claro" % [pintados, fora, sobre_acento, sobre_metal])
	_verificar(pintados > 3 and fora == 0 and sobre_acento == 0 and sobre_metal == 0,
		"pintura atua no interior, preserva transparencia, acentos e metal claro do aro")
