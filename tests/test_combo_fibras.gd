extends "res://tests/test_presenca_combate.gd"

const COMBO_FIBRAS: PackedScene = preload("res://vega_animada/corpo_articulado/combo_fibras/vega_combo.tscn")
var poses_combo: int = 0
var juntas_gpu: int = 0
var poses_base: int = 0
var vertices_fixos: int = 0
var amplitudes: Array[float] = []
var pixels_tensao: Array[int] = []
var salto_triangulacao: float = 0.0


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		motivos[mensagem] = motivos.get(mensagem, 0) + 1
		if falhas <= 12:
			push_error("COMBO FIBRAS: " + mensagem)


func _executar() -> void:
	var nova: VegaComboFibrasV1 = COMBO_FIBRAS.instantiate() as VegaComboFibrasV1
	var base: VegaPresencaCombateV1 = PRESENCA.instantiate() as VegaPresencaCombateV1
	for atriz: VegaPresencaCombateV1 in [nova, base]:
		atriz.size = Vector2(650, 850)
		root.add_child(atriz)
	_verificar(nova.fibras.size() == 4, "quatro superfícies macias, nenhuma mão")
	_verificar_clipes(nova, base)
	for lado: int in range(2):
		var a: BracoRegistradoV1 = nova.braco_novo if lado == 0 else nova.novo_distante
		var b: BracoRegistradoV1 = base.braco_novo if lado == 0 else base.novo_distante
		for indice: int in range(3):
			_verificar(a.segmentos[indice].polygon == b.segmentos[indice].polygon and a.segmentos[indice].uv == b.segmentos[indice].uv
				and a.segmentos[indice].transform == b.segmentos[indice].transform, "recortes/registro/mãos originais preservados")
	_verificar_malhas(nova)
	await _verificar_imagens_combo(nova)
	await _verificar_poses_combo(nova, base)
	await _verificar_fluxo(nova)
	await _verificar_transicao_combo(nova)
	_verificar_preview_combo()
	nova.free()
	base.free()
	await process_frame
	print("Combo fibras: ", falhas, " falhas; ", poses_combo, " poses; ", juntas_gpu,
		" amostras GPU de juntas; ", poses_base, " poses Combo 0 idênticas; ", vertices_fixos,
		" verificações de vértices rígidos; máximos locais px ", amplitudes,
		"; pixels alterados Combo 5/10/20 ", pixels_tensao, "; salto máximo triangulação ", salto_triangulacao)
	if falhas > 0:
		print("Motivos: ", motivos)
	quit(0 if falhas == 0 else 1)


func _verificar_malhas(atriz: VegaComboFibrasV1) -> void:
	for fibra: MalhaFibraComboV1 in atriz.fibras:
		var amplitude: float = 0.0
		for delta: Vector2 in fibra.deltas:
			amplitude = maxf(amplitude, delta.length())
		amplitudes.append(amplitude)
		_verificar(amplitude > .5 and amplitude < 12, "tensão presente sem volume excessivo")
	for valor: int in range(11):
		atriz.definir_combo_visual(valor, true)
		_verificar(is_equal_approx(atriz.tensao_visual, valor * .1), "dez passos lineares")
		for fibra: MalhaFibraComboV1 in atriz.fibras:
			var pontos: PackedVector2Array = fibra.malha.polygon
			for i: int in range(pontos.size()):
				_verificar(pontos[i].is_equal_approx(fibra.base[i] + fibra.deltas[i] * valor * .1), "deformação linear/reversível")
				_verificar(is_equal_approx(pontos[i].x, fibra.base[i].x), "nenhum alongamento axial")
				if fibra.deltas[i] == Vector2.ZERO:
					_verificar(pontos[i] == fibra.base[i], "placas/extremos sem deslocamento")
					vertices_fixos += 1
			for face: PackedInt32Array in fibra.malha.polygons:
				var sinal_base: float = (fibra.base[face[1]] - fibra.base[face[0]]).cross(fibra.base[face[2]] - fibra.base[face[0]])
				var sinal: float = (pontos[face[1]] - pontos[face[0]]).cross(pontos[face[2]] - pontos[face[0]])
				_verificar(sinal * sinal_base > 0, "sem face invertida/colapsada nas fibras")
				# Toda face que cruza uma placa tem seus três vértices presos.
				var uv := PackedVector2Array([fibra.malha.uv[face[0]], fibra.malha.uv[face[1]], fibra.malha.uv[face[2]]])
				if valor == 10:
					for placa: PackedVector2Array in fibra.protecoes:
						if not Geometry2D.intersect_polygons(uv, placa).is_empty():
							for indice: int in face:
								_verificar(fibra.deltas[indice] == Vector2.ZERO, "triângulos sobre placas inteiramente rígidos")
	atriz.definir_combo_visual(20, true)
	_verificar(atriz.combo_visual == 20 and atriz.tensao_visual == 1, "teto apenas visual")
	atriz.definir_combo_visual(-2, true)
	_verificar(atriz.combo_visual == 0 and atriz.tensao_visual == 0, "valor negativo limpa")
	for fibra: MalhaFibraComboV1 in atriz.fibras:
		_verificar(fibra.original.visible and not fibra.malha.visible, "zero restaura recorte aprovado")


func _verificar_poses_combo(nova: VegaComboFibrasV1, base: VegaPresencaCombateV1) -> void:
	var clipes: Array[StringName] = [&"corpo_soco", nova.CLIPE_DISTANTE, nova.RESPIRO, nova.FERIMENTO]
	for valor: int in [0, 5, 10]:
		nova.definir_combo_visual(valor, true)
		for nome: StringName in clipes:
			var clipe: Animation = nova.modelo.animacao.get_animation(nome)
			for quadro: int in range(13):
				var tempo: float = clipe.length * quadro / 12.0
				nova.inspecionar(nome, tempo)
				base.inspecionar(nome, tempo)
				poses_combo += 1
				_verificar(nova.braco_novo.punho.global_transform.is_equal_approx(base.braco_novo.punho.global_transform)
					and nova.novo_distante.punho.global_transform.is_equal_approx(base.novo_distante.punho.global_transform), "mãos/juntas seguem os gestos aprovados")
				_verificar(_deformar(nova.modelo) == _deformar(base.modelo), "corpo/botas/pesos sem mudança por Combo")
				for braco: BracoRegistradoV1 in [nova.braco_novo, nova.novo_distante]:
					_verificar(braco.cotovelo.position.is_equal_approx(Vector2(braco.SUPERIOR, 0))
						and braco.punho.position.is_equal_approx(Vector2(braco.INFERIOR, 0)), "comprimentos fixos")
				if DisplayServer.get_name() != "headless":
					await process_frame
					await RenderingServer.frame_post_draw
					var imagem: Image = (nova.composicao.get_node("Desenho") as SubViewport).get_texture().get_image()
					for braco: BracoRegistradoV1 in [nova.braco_novo, nova.novo_distante]:
						for osso: Bone2D in [braco.ombro, braco.cotovelo, braco.punho]:
							for deslocamento: int in [-3, 0, 3]:
								_verificar(imagem.get_pixelv(Vector2i(osso.to_global(Vector2(deslocamento, 0)).round())).a > .9, "GPU: juntas cobertas durante os quatro gestos")
								juntas_gpu += 1
					if valor == 0:
						var referencia: Image = (base.composicao.get_node("Desenho") as SubViewport).get_texture().get_image()
						_verificar(imagem.get_data() == referencia.get_data(), "GPU: Combo zero exatamente igual à versão 14")
						poses_base += 1


func _verificar_transicao_combo(atriz: VegaComboFibrasV1) -> void:
	atriz.reiniciar_sequencia()
	atriz.definir_combo_visual(10)
	var tween: Tween = atriz.transicao_fibras
	atriz.definir_combo_visual(20)
	_verificar(atriz.combo_visual == 20 and atriz.transicao_fibras == tween, "mesmo máximo não reinicia transição")
	var animacao: StringName = atriz.modelo.animacao.current_animation
	var ordem: bool = atriz.proximo_braco_distante
	await create_timer(.08).timeout
	_verificar(atriz.tensao_visual > 0 and atriz.tensao_visual < 1, "ganho percorre valores intermediários")
	var inicio: float = atriz.tensao_visual
	atriz.definir_combo_visual(0)
	_verificar(atriz.tensao_visual == inicio, "consumo captura tensão atual sem salto")
	_verificar(atriz.modelo.animacao.current_animation == animacao and atriz.proximo_braco_distante == ordem, "Combo não cancela gesto nem escolhe braço")
	await create_timer(.3).timeout
	_verificar(atriz.tensao_visual == 0 and atriz.transicao_fibras == null, "consumo termina sem Tween pendente")
	atriz.definir_combo_visual(10)
	await create_timer(.05).timeout
	atriz.reduzir_corpo(true)
	_verificar(atriz.tensao_visual == 1 and atriz.transicao_fibras == null, "reduzido resolve tensão sem transição espacial")
	atriz.definir_combo_visual(5)
	_verificar(atriz.tensao_visual == .5 and atriz.transicao_fibras == null, "reduzido conserva estado legível")
	atriz.reduzir_corpo(false)
	atriz.socar_corpo()
	atriz.modelo.animacao.advance(.13)
	atriz.definir_combo_visual(10)
	_verificar(atriz.modelo.animacao.current_animation == &"corpo_soco", "ganho durante ataque preserva ação")
	atriz.receber_dano()
	_verificar(atriz.combo_visual == 10 and atriz.alvo_tensao == 1, "dano não consome Combo")
	var inicio_consumo: float = atriz.tensao_visual
	atriz.definir_combo_visual(0)
	_verificar(atriz.modelo.animacao.current_animation == atriz.FERIMENTO and atriz.tensao_visual == inicio_consumo, "consumo durante dano não cancela gesto nem salta")
	atriz.modelo.animacao.advance(.3)
	_verificar(atriz.modelo.animacao.current_animation == atriz.RESPIRO, "retorno à guarda preservado")
	atriz.hide()
	_verificar(atriz.combo_visual == 0 and atriz.tensao_visual == 0 and atriz.transicao_fibras == null, "ocultação cancela/limpa")
	atriz.definir_combo_visual(10)
	_verificar(atriz.combo_visual == 0, "sem tensão acumulada invisível")
	atriz.show()
	atriz.definir_combo_visual(10, true)
	atriz.reiniciar_sequencia()
	_verificar(atriz.combo_visual == 0 and not atriz.proximo_braco_distante, "reset limpa Combo e ordem")


func _verificar_imagens_combo(atriz: VegaComboFibrasV1) -> void:
	if DisplayServer.get_name() == "headless":
		return
	atriz.inspecionar(&"corpo_soco", 0)
	atriz.definir_combo_visual(0, true)
	var desenho: SubViewport = atriz.composicao.get_node("Desenho") as SubViewport
	await process_frame
	await RenderingServer.frame_post_draw
	var referencia: Image = desenho.get_texture().get_image()
	# A malha subdividida neutra não deve aparecer como uma troca de recorte.
	for fibra: MalhaFibraComboV1 in atriz.fibras:
		fibra.original.hide()
		fibra.malha.show()
	await process_frame
	await RenderingServer.frame_post_draw
	var neutra: Image = desenho.get_texture().get_image()
	var divergencias: int = 0
	var pior: Vector2i = Vector2i.ZERO
	for y: int in range(neutra.get_height()):
		for x: int in range(neutra.get_width()):
			var a: Color = neutra.get_pixel(x, y)
			var b: Color = referencia.get_pixel(x, y)
			var delta: float = maxf(maxf(absf(a.r - b.r), absf(a.g - b.g)), maxf(absf(a.b - b.b), absf(a.a - b.a)))
			if delta > .02:
				divergencias += 1
			if delta > salto_triangulacao:
				salto_triangulacao = delta
				pior = Vector2i(x, y)
	print("Diagnóstico neutro: ", divergencias, " pixels > .02; pior ", pior, " cores ", referencia.get_pixelv(pior), " / ", neutra.get_pixelv(pior))
	referencia.save_png("res://docs/evidencias_vega_combo_15/diagnostico_original.png")
	neutra.save_png("res://docs/evidencias_vega_combo_15/diagnostico_neutra.png")
	_verificar(salto_triangulacao <= .02, "GPU: troca de triangulação sem salto visível")
	var maximo: Image
	for valor: int in [5, 10, 20]:
		atriz.definir_combo_visual(valor, true)
		await process_frame
		await RenderingServer.frame_post_draw
		var imagem: Image = desenho.get_texture().get_image()
		if valor == 10:
			maximo = imagem
		elif valor == 20:
			_verificar(imagem.get_data() == maximo.get_data(), "GPU: Combo 20 idêntico em pixels a 10")
		var alterados: int = 0
		for y: int in range(imagem.get_height()):
			for x: int in range(imagem.get_width()):
				if imagem.get_pixel(x, y) != referencia.get_pixel(x, y):
					alterados += 1
		pixels_tensao.append(alterados)
	_verificar(pixels_tensao[0] > 100 and pixels_tensao[1] > pixels_tensao[0], "GPU: meio/máximo têm tensão realmente renderizada")
	_verificar(pixels_tensao[1] == pixels_tensao[2], "GPU: 20 mantém o máximo visual de 10")
	atriz.definir_combo_visual(0, true)


func _verificar_preview_combo() -> void:
	var cena: PackedScene = load("res://vega_animada/corpo_articulado/combo_fibras/preview.tscn") as PackedScene
	var preview: Node2D = cena.instantiate() as Node2D
	root.add_child(preview)
	for tecla: Key in [KEY_UP, KEY_6, KEY_7, KEY_8, KEY_DOWN, KEY_0, KEY_SPACE, KEY_D, KEY_B, KEY_B, KEY_G, KEY_T, KEY_2, KEY_4, KEY_5, KEY_X, KEY_Z, KEY_L, KEY_R, KEY_7]:
		var evento := InputEventKey.new()
		evento.keycode = tecla
		evento.pressed = true
		preview._unhandled_key_input(evento)
	var atriz: VegaComboFibrasV1 = preview.atriz_combo as VegaComboFibrasV1
	_verificar(atriz.combo_visual == 10 and atriz.tensao_visual == 1 and atriz.corpo_reduzido, "atalhos de Combo/reduzido")
	_verificar(preview.ampliado and preview.lento and atriz.respiro_habilitado, "atalhos de inspeção preservados")
	_verificar(not atriz.proximo_braco_distante and not (preview.anterior as VegaPresencaCombateV1).proximo_braco_distante, "X reinicia ambos os lados da comparação")
	preview.free()
