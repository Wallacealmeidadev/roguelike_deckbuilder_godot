extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		if falhas <= 12:
			push_error("APOIO CORPORAL: " + mensagem)


func _executar() -> void:
	var prova: Control = (load("res://vega_animada/rig_nativo_v2/preview_apoio.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(prova)
	var anterior: ComboNativoV2 = (load("res://vega_animada/rig_nativo_v2/combo_nativo.tscn") as PackedScene).instantiate() as ComboNativoV2
	add_child(anterior)
	anterior.visible = false
	await get_tree().process_frame
	var rig: ApoioCorporalNativoV2 = prova.braco as ApoioCorporalNativoV2
	_verificar(rig.esqueleto.get_bone_count() == 9 and rig.pele.get_bone_count() == 9, "nove ossos/pesos corporais nativos")
	_verificar(rig.pele.get_node(rig.pele.skeleton) == rig.esqueleto, "pele usa skinning nativo")
	var originais: PackedVector2Array = rig.pele.polygon
	for i: int in originais.size():
		var soma: float = 0
		var influencias: int = 0
		for osso: int in 9:
			var peso: float = rig.pele.get_bone_weights(osso)[i]
			_verificar(peso >= 0 and peso <= 1, "peso valido")
			soma += peso
			if peso > .000001:
				influencias += 1
		_verificar(absf(soma - 1) < .00001 and influencias <= 4, "pesos normalizados e ate quatro influencias")
		if originais[i].y >= 680:
			_verificar(rig.pele.get_bone_weights(8)[i] == 1, "botas inteiras no apoio fixo")
	for nome: StringName in [&"RESET", &"repouso", &"guarda", &"extensao", &"soco"]:
		var animacao: Animation = rig.animacao.get_animation(nome)
		var base: Animation = anterior.animacao.get_animation(nome)
		_verificar(animacao.get_track_count() == 14, "um player coordena quatorze trilhas")
		for t: int in 11:
			for k: int in animacao.track_get_key_count(t):
				_verificar(animacao.track_get_key_value(t, k) == base.track_get_key_value(t, k), "chaves aprovadas do tronco/bracos preservadas")
		for t: int in range(11, 14):
			_verificar(str(animacao.track_get_path(t)).ends_with(":position"), "so pelve e joelhos mudam posicao")
			for k: int in animacao.track_get_key_count(t):
				_verificar(typeof(animacao.track_get_key_value(t, k)) == TYPE_VECTOR2, "chaves corporais sao Vector2")
	var sola_tras: Vector2 = rig.sola_tras.global_position
	var sola_frente: Vector2 = rig.sola_frente.global_position
	var encaixe_perto: int = originais.find(Vector2(201, 225))
	var encaixe_longe: int = originais.find(Vector2(410, 253))
	for passo: int in 57:
		var tempo: float = float(passo) / 100
		rig.inspecionar_tempo(tempo)
		anterior.inspecionar_tempo(tempo)
		var deslocamento: Vector2 = rig.pelve.position - rig.pelve.rest.origin
		_verificar(deslocamento.length() <= 8.3, "deslocamento de quadril limitado")
		if passo == 10:
			_verificar(deslocamento.x < 0 and deslocamento.y > 0, "preparo recua e flexiona")
		if passo == 20:
			_verificar(deslocamento.x > 0 and rig.joelho_frente.position.y > rig.joelho_frente.rest.origin.y, "impacto transfere peso e envolve joelho")
		_verificar(rig.apoios.transform == rig.apoios.rest, "apoio nao recebe movimento da pelve")
		_verificar(rig.sola_tras.global_position == sola_tras and rig.sola_frente.global_position == sola_frente, "marcadores das solas nao deslizam")
		_verificar(rig.pele.polygon == originais, "sem solver por frame reescrevendo pele")
		var pele: PackedVector2Array = _deformados(rig)
		_verificar(rig.to_global(pele[encaixe_perto]).distance_to(rig.ombro.global_position) < .01, "encaixe proximo acompanha corpo")
		_verificar(rig.to_global(pele[encaixe_longe]).distance_to(rig.braco_distante.ombro.global_position) < .01, "encaixe distante acompanha corpo")
		for i: int in originais.size():
			if originais[i].y >= 680:
				_verificar(pele[i].distance_to(originais[i]) < .01, "vertices das botas realmente fixos, nao so marcadores")
		for face: PackedInt32Array in rig.pele.polygons:
			_verificar((pele[face[1]] - pele[face[0]]).cross(pele[face[3]] - pele[face[0]]) > 0, "primeira metade da face sem inversao")
			_verificar((pele[face[2]] - pele[face[1]]).cross(pele[face[3]] - pele[face[1]]) > 0, "segunda metade da face sem inversao")
		for par: Array in [[rig.braco_original, anterior.braco_original], [rig.braco_distante, anterior.braco_distante]]:
			var a: BracoNativoV2 = par[0]
			var b: BracoNativoV2 = par[1]
			_verificar(a.cotovelo.transform == b.cotovelo.transform and a.punho.transform == b.punho.transform, "ossos dos bracos nao alongam")
			var mao: Sprite2D = a.punho.get_node("Mao") as Sprite2D
			var referencia: Sprite2D = b.punho.get_node("Mao") as Sprite2D
			_verificar(mao.transform == referencia.transform, "orientacao/tamanho/encaixe da mao preservados")
			_verificar((rig.to_local(a.punho.global_position) - anterior.to_local(b.punho.global_position)).distance_to(deslocamento) < .01,
				"braco acompanha translacao corporal sem mudar trajetoria relativa")
	rig.inspecionar_tempo(.2)
	var pelve: Transform2D = rig.pelve.transform
	var joelho: Transform2D = rig.joelho_frente.transform
	rig.definir_combo(10, true)
	_verificar(rig.pelve.transform == pelve and rig.joelho_frente.transform == joelho, "Combo nao provoca balanco das pernas")
	rig.definir_pose(&"repouso", true)
	rig.reproduzir_soco()
	rig.animacao.advance(.15)
	var antes: Vector2 = rig.pelve.position
	rig.reproduzir_soco()
	rig.animacao.advance(0)
	_verificar(rig.pelve.position.is_equal_approx(antes), "interrupcao captura tambem o quadril")
	rig.definir_movimento_reduzido(true)
	_verificar(rig.pelve.transform == rig.pelve.rest and rig.joelho_tras.transform == rig.joelho_tras.rest
		and rig.joelho_frente.transform == rig.joelho_frente.rest, "reduzido restaura postura corporal sem residuo")
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		await get_tree().process_frame
		prova.call("_layout")
		var painel: Control = prova.get_node("ZoomPanel") as Control
		var ampliado: ApoioCorporalNativoV2 = prova.zoom as ApoioCorporalNativoV2
		for marco: Marker2D in [ampliado.sola_tras, ampliado.sola_frente]:
			_verificar(painel.get_global_rect().has_point(marco.global_position), "zoom inferior enquadra os apoios")
		(prova.get_node("Rodape/Controles/Ossos") as CheckButton).button_pressed = true
		prova.get_node("OssosOverlay").queue_redraw()
		await get_tree().process_frame
	prova.queue_free()
	anterior.queue_free()
	await get_tree().process_frame
	print("TEST APOIO CORPORAL: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _deformados(rig: ApoioCorporalNativoV2) -> PackedVector2Array:
	# Oraculo de teste; a apresentacao usa Polygon2D/Skeleton2D nativos.
	var matrizes: Array[Transform2D] = []
	for i: int in rig.pele.get_bone_count():
		var osso: Bone2D = rig.esqueleto.get_node(rig.pele.get_bone_path(i)) as Bone2D
		var atual: Transform2D = rig.esqueleto.global_transform.affine_inverse() * osso.global_transform
		matrizes.append(atual * osso.get_skeleton_rest().affine_inverse())
	var saida: PackedVector2Array = PackedVector2Array()
	for i: int in rig.pele.polygon.size():
		var ponto: Vector2 = Vector2.ZERO
		for j: int in matrizes.size():
			ponto += (matrizes[j] * rig.pele.polygon[i]) * rig.pele.get_bone_weights(j)[i]
		saida.append(ponto)
	return saida
