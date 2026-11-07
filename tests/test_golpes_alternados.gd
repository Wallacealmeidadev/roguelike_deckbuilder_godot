extends "res://tests/test_integracao_tronco.gd"

const ALTERNADA: PackedScene = preload("res://vega_animada/corpo_articulado/golpes_alternados/vega_alternada.tscn")
const REFERENCIA: PackedScene = preload("res://vega_animada/corpo_articulado/integracao_tronco/vega_integracao.tscn")
var amostras_juntas: int = 0
var faces_invertidas: int = 0
var max_intersecao: int = 0
var diferencas_proximo: int = 0
var alcance_distante: float = 0
var motivos: Dictionary[String, int] = {}


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		motivos[mensagem] = motivos.get(mensagem, 0) + 1
		if falhas <= 15:
			push_error("GOLPES ALTERNADOS: " + mensagem)


func _executar() -> void:
	var nova: VegaGolpesAlternadosV1 = ALTERNADA.instantiate() as VegaGolpesAlternadosV1
	var base: VegaIntegracaoTroncoV1 = REFERENCIA.instantiate() as VegaIntegracaoTroncoV1
	for atriz: VegaCorpoArticuladoV1 in [base, nova]:
		atriz.size = Vector2(650, 850)
		root.add_child(atriz)
	# Comparação gráfica controlada: mesmo tamanho de alvo, mesmo SCREEN_UV.
	# Não altera o arquivo da referência, a caixa lógica, a câmera ou os ossos.
	base.composicao.offset_right = nova.composicao.offset_right
	_verificar(not base.modelo.animacao.has_animation(nova.CLIPE_DISTANTE), "biblioteca nova não vaza o golpe distante para referência")
	if "--diagnosticar" in OS.get_cmdline_user_args():
		for nome: StringName in base.modelo.animacao.get_animation_list():
			var a: Animation = nova.modelo.animacao.get_animation(nome)
			var b: Animation = base.modelo.animacao.get_animation(nome)
			for trilha: int in range(b.get_track_count()):
				for chave: int in range(b.track_get_key_count(trilha)):
					if a.track_get_key_value(trilha, chave) != b.track_get_key_value(trilha, chave):
						print("Diferença ", nome, " / ", a.track_get_path(trilha), " / ", chave,
							": ", a.track_get_key_value(trilha, chave), " vs ", b.track_get_key_value(trilha, chave))
	_verificar_clipes(nova, base)
	var malha: Polygon2D = nova.modelo.pele
	_verificar(malha.polygon == base.modelo.pele.polygon and malha.uv == base.modelo.pele.uv
		and malha.polygons == base.modelo.pele.polygons and malha.texture == base.modelo.pele.texture, "mesma superfície/pintura aceita")
	for indice: int in range(malha.get_bone_count()):
		_verificar(malha.get_bone_weights(indice) == base.modelo.pele.get_bone_weights(indice), "pesos intactos")
	var escalas: Array[Transform2D] = []
	for braco: BracoRegistradoV1 in [nova.braco_novo, nova.novo_distante]:
		for parte: Polygon2D in braco.segmentos:
			escalas.append(parte.transform)
	var guarda: PackedVector2Array = _deformar(nova.modelo)
	var direcao_guarda: Vector2 = nova.braco_novo.punho.global_transform.x.normalized()
	var punho_guarda: Vector2 = nova.novo_distante.punho.global_position
	var vp: SubViewport = nova.composicao.get_node("Desenho") as SubViewport
	for distante: bool in [false, true]:
		for quadro: int in range(57):
			nova.inspecionar(nova.CLIPE_DISTANTE if distante else &"corpo_soco", quadro / 100.0)
			base.inspecionar(&"corpo_soco", quadro / 100.0)
			poses += 1
			if not distante:
				for indice: int in range(malha.get_bone_count()):
					var osso_a: Bone2D = nova.modelo.esqueleto.get_node(malha.get_bone_path(indice)) as Bone2D
					var osso_b: Bone2D = base.modelo.esqueleto.get_node(base.modelo.pele.get_bone_path(indice)) as Bone2D
					_verificar(osso_a.global_transform.is_equal_approx(osso_b.global_transform), "movimento próximo aprovado preservado")
				_verificar(nova.braco_novo.punho.global_transform.is_equal_approx(base.braco_novo.punho.global_transform)
					and nova.novo_distante.punho.global_transform.is_equal_approx(base.novo_distante.punho.global_transform), "mesmas mãos no golpe próximo")
			else:
				_verificar(nova.braco_novo.punho.global_transform.x.normalized().dot(direcao_guarda) > .99999,
					"mão próxima mantém direção da guarda durante direto distante")
			var pontos: PackedVector2Array = _deformar(nova.modelo)
			for indice: int in range(pontos.size()):
				if malha.uv[indice].y >= 680:
					_verificar(pontos[indice].distance_to(guarda[indice]) < .001, "botas não deslizam")
			for face: PackedInt32Array in malha.polygons:
				if (pontos[face[1]] - pontos[face[0]]).cross(pontos[face[3]] - pontos[face[0]]) <= 0 \
					or (pontos[face[2]] - pontos[face[1]]).cross(pontos[face[3]] - pontos[face[1]]) <= 0:
					faces_invertidas += 1
			var parte_indice: int = 0
			for par: Array in [[nova.braco_novo, nova.modelo.braco_original], [nova.novo_distante, nova.modelo.braco_distante]]:
				var braco: BracoRegistradoV1 = par[0]
				_verificar(braco.global_position.distance_to(par[1].global_position) < .001, "raízes permanecem nas inserções")
				_verificar(braco.cotovelo.position.distance_to(Vector2(braco.SUPERIOR, 0)) < .001
					and braco.punho.position.distance_to(Vector2(braco.INFERIOR, 0)) < .001, "comprimentos e centros não mudam")
				for parte: Polygon2D in braco.segmentos:
					_verificar(parte.transform == escalas[parte_indice], "sem girar/refletir/redimensionar pintura por fora do osso")
					parte_indice += 1
			if quadro in [0, 56]:
				for indice: int in range(pontos.size()):
					_verificar(pontos[indice].distance_to(guarda[indice]) < .001, "mesma guarda nos dois extremos")
			if quadro == 20:
				var intersecao: int = _intersecao(nova)
				max_intersecao = maxi(max_intersecao, intersecao)
				_verificar(intersecao == 0, "mãos distintas no impacto")
				if distante:
					alcance_distante = nova.novo_distante.punho.global_position.x - punho_guarda.x
					_verificar(alcance_distante > nova.novo_distante.INFERIOR * .9, "direto distante avança sem alongar os membros")
			if DisplayServer.get_name() != "headless":
				await process_frame
				await RenderingServer.frame_post_draw
				var imagem: Image = vp.get_texture().get_image()
				for braco: BracoRegistradoV1 in [nova.braco_novo, nova.novo_distante]:
					for osso: Bone2D in [braco.ombro, braco.cotovelo, braco.punho]:
						for deslocamento: int in [-3, 0, 3]:
							var ponto: Vector2i = Vector2i(osso.to_global(Vector2(deslocamento, 0)).round())
							_verificar(imagem.get_pixelv(ponto).a > .9, "GPU: encaixes cobertos durante as duas trajetórias")
							amostras_juntas += 1
				if quadro in [0, 10, 20, 36, 56]:
					if distante:
						_verificar_borda(nova, imagem)
					else:
						var vp_base: SubViewport = base.composicao.get_node("Desenho") as SubViewport
						var anterior: Image = vp_base.get_texture().get_image()
						var recorte: Image = imagem.get_region(Rect2i(Vector2i.ZERO, anterior.get_size()))
						if recorte.get_data() != anterior.get_data():
							diferencas_proximo += 1
	_verificar(faces_invertidas == 0, "nenhuma face corporal invertida")
	_verificar(diferencas_proximo == 0, "GPU: golpe próximo idêntico nas cinco poses com o mesmo canvas")
	_verificar_sequencia(nova)
	_verificar_laboratorio()
	nova.free()
	base.free()
	await process_frame
	print("Golpes alternados: ", falhas, " falhas; ", poses, " poses; ", amostras_juntas,
		" amostras GPU; inversões ", faces_invertidas, "; impactos com mãos sobrepostas ", max_intersecao,
		"; cinco poses próximas divergentes ", diferencas_proximo, "; avanço distante ", alcance_distante, " px")
	if falhas > 0:
		print("Motivos: ", motivos)
	quit(0 if falhas == 0 else 1)


func _intersecao(atriz: VegaGolpesAlternadosV1) -> int:
	var perto: BracoRegistradoV1 = atriz.braco_novo
	var longe: BracoDistanteRegistradoV1 = atriz.novo_distante
	var fonte_a: Image = perto.ARTE.get_image()
	var fonte_b: Image = longe.ARTE_INTERNA.get_image()
	var total: int = 0
	for y: int in range(1200, 1536, 4):
		for x: int in range(350, 731, 4):
			if fonte_a.get_pixel(x, y).a < .9:
				continue
			var mundo: Vector2 = perto.segmentos[2].to_global(perto.registros[2] * Vector2(x, y))
			var uv: Vector2 = longe.registros[2].affine_inverse() * longe.segmentos[2].to_local(mundo)
			if Geometry2D.is_point_in_polygon(uv, longe.segmentos[2].uv) and fonte_b.get_pixelv(Vector2i(uv)).a > .9:
				total += 1
	return total


func _verificar_borda(atriz: VegaGolpesAlternadosV1, imagem: Image) -> void:
	var braco: BracoDistanteRegistradoV1 = atriz.novo_distante
	var fonte: Image = braco.ARTE_INTERNA.get_image()
	for y: int in range(1200, 1536, 8):
		for x: int in range(300, 751, 8):
			if fonte.get_pixel(x, y).a < .9:
				continue
			var ponto: Vector2 = braco.segmentos[2].to_global(braco.registros[2] * Vector2(x, y))
			_verificar(Rect2(Vector2(2, 2), Vector2(imagem.get_size()) - Vector2(4, 4)).has_point(ponto), "mão inteira dentro da margem, sem cortar dedos")


func _verificar_sequencia(atriz: VegaGolpesAlternadosV1) -> void:
	atriz.reiniciar_sequencia()
	for golpe: int in range(6):
		atriz.socar_corpo()
		_verificar(atriz.ultimo_braco_distante == (golpe % 2 == 1), "sequência próximo/distante estável")
		var nome: StringName = atriz.CLIPE_DISTANTE if golpe % 2 == 1 else &"corpo_soco"
		_verificar(atriz.modelo.animacao.current_animation == nome, "clipe do braço correto")
		atriz.modelo.animacao.advance(.6)
		_verificar(atriz.estado_animacao == "guarda" and not atriz.modelo.animacao.is_playing(), "retorno automático sem fila")
	var a: Transform2D
	var b: Transform2D
	for iniciar_distante: bool in [false, true]:
		atriz.reiniciar_sequencia()
		if iniciar_distante:
			atriz.socar_corpo()
			atriz.modelo.animacao.advance(.6)
		atriz.socar_corpo()
		atriz.modelo.animacao.advance(.15)
		a = atriz.braco_novo.punho.global_transform
		b = atriz.novo_distante.punho.global_transform
		atriz.socar_corpo()
		_verificar(atriz.ultimo_braco_distante == not iniciar_distante and a.is_equal_approx(atriz.braco_novo.punho.global_transform)
			and b.is_equal_approx(atriz.novo_distante.punho.global_transform), "trocar braço nas duas direções captura a pose atual sem salto imediato")
		atriz.modelo.animacao.advance(.6)
	var ordem: bool = atriz.proximo_braco_distante
	atriz.inspecionar_golpe(true, 2)
	_verificar(atriz.proximo_braco_distante == ordem, "inspeção não consome a alternância")
	atriz.reduzir_corpo(true)
	a = atriz.braco_novo.punho.global_transform
	b = atriz.novo_distante.punho.global_transform
	for golpe: int in range(4):
		atriz.socar_corpo()
		_verificar(atriz.ultimo_braco_distante == (ordem if golpe % 2 == 0 else not ordem)
			and not atriz.modelo.animacao.is_playing(), "reduzido conserva ordem sem articulação")
		_verificar(a.is_equal_approx(atriz.braco_novo.punho.global_transform)
			and b.is_equal_approx(atriz.novo_distante.punho.global_transform), "reduzido mantém guarda de ambos os braços")
	atriz.reduzir_corpo(false)
	atriz.hide()
	atriz.socar_corpo()
	_verificar(not atriz.proximo_braco_distante and not atriz.ultimo_braco_distante, "ocultar cancela e não avança sequência")
	atriz.show()
	atriz.reiniciar_sequencia()
	_verificar(not atriz.proximo_braco_distante and not atriz.ultimo_braco_distante, "reinício volta ao braço próximo")


func _verificar_laboratorio() -> void:
	var cena: PackedScene = load("res://vega_animada/corpo_articulado/golpes_alternados/preview.tscn") as PackedScene
	var preview: Node2D = cena.instantiate() as Node2D
	root.add_child(preview)
	for tecla: Key in [KEY_1, KEY_2, KEY_3, KEY_T, KEY_T, KEY_Z, KEY_L, KEY_O, KEY_A, KEY_X, KEY_SPACE, KEY_SPACE, KEY_R, KEY_SPACE]:
		var evento := InputEventKey.new()
		evento.keycode = tecla
		evento.pressed = true
		preview._unhandled_key_input(evento)
	var atriz: VegaGolpesAlternadosV1 = preview.atriz_alternada as VegaGolpesAlternadosV1
	for zoom: TextureRect in preview.zooms:
		_verificar(zoom.size.is_equal_approx(Vector2(520, 408)), "ampliação cabe no painel sem cortar a mão por tamanho mínimo")
	_verificar(preview.ampliado and preview.lento and atriz.corpo_reduzido, "controles Z/L/R")
	_verificar(not atriz.ultimo_braco_distante and atriz.proximo_braco_distante, "X reinicia e Espaço alterna, inclusive reduzido")
	_verificar(atriz.intensidade_gola == 1, "atalho antigo não altera arte aceita")
	preview.free()
