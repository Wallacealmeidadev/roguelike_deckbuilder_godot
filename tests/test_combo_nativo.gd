extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		if falhas <= 12:
			push_error("COMBO NATIVO: " + mensagem)


func _executar() -> void:
	var prova: Control = (load("res://vega_animada/rig_nativo_v2/preview_combo.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(prova)
	var anterior: DoisBracosNativoV2 = (load("res://vega_animada/rig_nativo_v2/dois_bracos.tscn") as PackedScene).instantiate() as DoisBracosNativoV2
	add_child(anterior)
	anterior.visible = false
	await get_tree().process_frame
	var rig: ComboNativoV2 = prova.braco as ComboNativoV2
	_verificar(rig.malhas.size() == 4, "somente as quatro superficies de fibra sao preparadas")
	var rigidos: Array[Node2D] = []
	var estado_rigido: Array[Transform2D] = []
	for braco: BracoNativoV2 in [rig.braco_original, rig.braco_distante]:
		for peca: Node2D in [braco.punho.get_node("Mao"), braco.cotovelo.get_node("Arte/Junta"),
				braco.cotovelo.get_node("Arte/PlacaA"), braco.cotovelo.get_node("Arte/PlacaB"), braco.cotovelo.get_node("Arte/PlacaC")]:
			rigidos.append(peca)
			estado_rigido.append(peca.transform)
	for i: int in 4:
		_verificar(rig.malhas[i].polygon == rig.bases[i], "zero restaura o recorte original exato")
		var maximo: float = 0
		for delta: Vector2 in rig.deslocamentos[i]:
			maximo = maxf(maximo, absf(delta.x))
		_verificar(maximo > 0, "tensao realmente modifica fibra")
		print("COMBO NATIVO malha %d: aumento maximo transversal local %.3f px" % [i, maximo])
	for carga: int in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 100, 9223372036854775807]:
		rig.definir_combo(carga, true)
		var esperado: float = float(mini(carga, 10)) / 10
		_verificar(rig.combo == carga and is_equal_approx(rig.tensao_combo, esperado), "linear dez passos; contador sem teto mecanico")
		for i: int in rig.malhas.size():
			var malha: Polygon2D = rig.malhas[i]
			var largura: float = 298 if i % 2 == 0 else 239
			var altura: float = 358 if i % 2 == 0 else 425
			var amplitude: float = .18 if i % 2 == 0 else .14
			for j: int in malha.polygon.size():
				var ponto: Vector2 = malha.polygon[j]
				var base: Vector2 = rig.bases[i][j]
				_verificar(ponto.is_equal_approx(base + rig.deslocamentos[i][j] * esperado), "deformacao proporcional sem acumular erro")
				_verificar(ponto.y == base.y, "nao alongar fibras")
				_verificar(absf(ponto.x - base.x) <= largura * amplitude * .5 + .001, "volume fisico limitado, nao 100% do braco")
				if base.y == 0 or base.y == altura:
					_verificar(ponto == base, "extremos nos encaixes presos")
				if i % 2 == 0 and Geometry2D.is_point_in_polygon(base / Vector2(largura, altura), PackedVector2Array(ComboNativoV2.RECORTE_PLACA)):
					_verificar(ponto == base, "placa do biceps permanece rigida")
			for face: PackedInt32Array in malha.polygons:
				var p: PackedVector2Array = malha.polygon
				_verificar((p[face[1]] - p[face[0]]).cross(p[face[3]] - p[face[0]]) > 0,
					"primeira metade da face nao inverte")
				_verificar((p[face[2]] - p[face[1]]).cross(p[face[3]] - p[face[1]]) > 0,
					"segunda metade da face nao inverte")
		for i: int in rigidos.size():
			_verificar(rigidos[i].transform == estado_rigido[i], "mao, junta e placas nao crescem ou deslocam")
	rig.definir_combo(10, true)
	for passo: int in 57:
		var tempo: float = float(passo) / 100
		rig.inspecionar_tempo(tempo)
		anterior.inspecionar_tempo(tempo)
		for par: Array in [[rig.braco_original, anterior.braco_original], [rig.braco_distante, anterior.braco_distante]]:
			var a: BracoNativoV2 = par[0]
			var b: BracoNativoV2 = par[1]
			for ossos: Array in [[a.ombro, b.ombro], [a.cotovelo, b.cotovelo], [a.punho, b.punho]]:
				var aa: Bone2D = ossos[0]
				var bb: Bone2D = ossos[1]
				_verificar(aa.transform.is_equal_approx(bb.transform), "Combo nao disputa pose ou alonga ossos")
	rig.definir_combo(0, true)
	for i: int in 4:
		_verificar(rig.malhas[i].polygon == rig.bases[i], "consumo volta exatamente a base aprovada")
	rig.definir_combo(10)
	await get_tree().create_timer(.08).timeout
	_verificar(rig.tensao_combo > 0 and rig.tensao_combo < 1, "ganho percorre valores intermediarios")
	var tween: Tween = rig.get("_transicao") as Tween
	rig.definir_combo(11)
	_verificar(rig.get("_transicao") == tween and rig.combo == 11, "mesmo teto visual nao reinicia animacao")
	var antes: float = rig.tensao_combo
	rig.definir_combo(0)
	_verificar(rig.tensao_combo == antes, "consumo interrompe do valor atual sem salto")
	await get_tree().create_timer(.3).timeout
	_verificar(is_zero_approx(rig.tensao_combo), "vence destino mais recente")
	rig.definir_combo(10)
	await get_tree().create_timer(.04).timeout
	rig.definir_movimento_reduzido(true)
	_verificar(rig.tensao_combo == 1 and not rig.animacao.is_playing(), "reduzido resolve tensao e cancela soco")
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		await get_tree().process_frame
		prova.call("_layout")
		prova.call("_combo", 5.0, true)
		_verificar((prova.braco as ComboNativoV2).combo == 5 and (prova.zoom as ComboNativoV2).combo == 5, "controle sincroniza corpo e zoom")
		var slider: Control = prova.get_node("Rodape/Combo/Valor") as Control
		_verificar(slider.get_global_rect().position.y >= 0 and slider.get_global_rect().end.y <= resolucao.y, "controle de Combo cabe na janela")
	prova.queue_free()
	anterior.queue_free()
	await get_tree().process_frame
	print("TEST COMBO NATIVO: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)
