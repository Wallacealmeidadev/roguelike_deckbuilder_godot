extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		if falhas <= 15:
			push_error("DOIS BRACOS: " + mensagem)


func _executar() -> void:
	var prova: Control = (load("res://vega_animada/rig_nativo_v2/preview_dois_bracos.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(prova)
	var anterior: OmbroTroncoNativoV2 = (load("res://vega_animada/rig_nativo_v2/ombro_tronco.tscn") as PackedScene).instantiate() as OmbroTroncoNativoV2
	add_child(anterior)
	anterior.visible = false
	await get_tree().process_frame
	var rig: DoisBracosNativoV2 = prova.braco as DoisBracosNativoV2
	var distante: BracoNativoV2 = rig.braco_distante
	_verificar(rig.esqueleto.get_bone_count() == 6, "seis ossos corporais registrados")
	_verificar(rig.pele.get_bone_count() == 6, "pele ponderada para ambos os ombros")
	_verificar(not rig.braco_original.animacao.active and not distante.animacao.active, "somente o player externo escreve poses")
	_verificar(distante.esqueleto.get_bone_count() == 3, "segundo braco reutiliza cadeia nativa")
	_verificar(distante.scale.is_equal_approx(Vector2(-.92, .92)), "projecao uniforme fixa, nao encurtar so uma parte")
	for no: Node in distante.find_children("*", "Sprite2D", true, false):
		var arte: Sprite2D = no as Sprite2D
		var camada: int = 0
		var ancestral: Node = arte
		while ancestral != rig:
			if ancestral is CanvasItem:
				camada += (ancestral as CanvasItem).z_index
			ancestral = ancestral.get_parent()
		_verificar(camada < rig.pele.z_index and camada + rig.z_index > 0,
			"todas as pecas distantes ficam atras da pele, mas acima do fundo da previa")
	var originais: PackedVector2Array = rig.pele.polygon
	for i: int in originais.size():
		var soma: float = 0
		var influencias: int = 0
		for j: int in 6:
			var peso: float = rig.pele.get_bone_weights(j)[i]
			_verificar(peso >= 0 and peso <= 1, "peso valido")
			soma += peso
			if peso > .000001:
				influencias += 1
		_verificar(absf(soma - 1) < .00001 and influencias <= 4, "normalizacao e limite nativo de quatro influencias")
		if originais[i].y >= 410:
			_verificar(rig.pele.get_bone_weights(0)[i] == 1, "pes e pernas presos a pelve")
	var perto: int = originais.find(Vector2(201, 225))
	var longe: int = originais.find(Vector2(410, 253))
	for i: int in anterior.pele.polygon.size():
		var ponto_base: Vector2 = anterior.pele.polygon[i]
		var novo_indice: int = originais.find(ponto_base)
		_verificar(novo_indice >= 0, "vertices anteriores preservados no refinamento")
		if ponto_base.x <= 350:
			for osso: int in 4:
				_verificar(absf(rig.pele.get_bone_weights(osso)[novo_indice] - anterior.pele.get_bone_weights(osso)[i]) < .00001,
					"pesos do lado aprovado nao sao redistribuidos ao segundo ombro")
	_verificar(perto >= 0 and longe >= 0, "duas ancoras explicitas na malha")
	_verificar(rig.pele.get_bone_weights(3)[perto] == 1 and rig.pele.get_bone_weights(5)[longe] == 1, "conectores seguem seus deltoides")
	for nome: StringName in [&"RESET", &"repouso", &"guarda", &"extensao", &"soco"]:
		var atual: Animation = rig.animacao.get_animation(nome)
		var base: Animation = anterior.animacao.get_animation(nome)
		_verificar(atual.get_track_count() == 11, "onze trilhas coordenadas")
		for t: int in 11:
			_verificar(str(atual.track_get_path(t)).ends_with(":rotation"), "animar apenas rotacoes")
			for k: int in atual.track_get_key_count(t):
				_verificar(typeof(atual.track_get_key_value(t, k)) == TYPE_FLOAT, "rotacoes serializadas como float")
				if t < 6:
					_verificar(atual.track_get_key_value(t, k) == base.track_get_key_value(t, k), "nao alterar chaves aprovadas")
	var superior: Vector2 = distante.cotovelo.position
	var inferior: Vector2 = distante.punho.position
	var mao: Sprite2D = distante.punho.get_node("Mao") as Sprite2D
	var mao_base: Transform2D = mao.transform
	var escala_base: Vector2 = distante.scale
	for nome: StringName in [&"repouso", &"guarda", &"extensao"]:
		rig.definir_pose(nome, true)
		print("DOIS BRACOS %s: ombro=%s cotovelo=%s punho=%s rotacao=%s" % [nome,
			rig.to_local(distante.ombro.global_position), rig.to_local(distante.cotovelo.global_position),
			rig.to_local(distante.punho.global_position), distante.ombro.rotation_degrees])
	for passo: int in 57:
		var tempo: float = float(passo) / 100
		rig.inspecionar_tempo(tempo)
		anterior.inspecionar_tempo(tempo)
		_verificar(distante.cotovelo.position == superior and distante.punho.position == inferior, "comprimentos constantes")
		_verificar(mao.transform == mao_base and distante.scale == escala_base, "mao e projecao nao pulsam nem esticam")
		_verificar(rig.pelve.transform == rig.pelve.rest and rig.pele.polygon == originais, "pelve e geometria base imoveis")
		for par: Array in [[rig.ombro, anterior.ombro], [rig.cotovelo, anterior.cotovelo], [rig.punho, anterior.punho]]:
			var a: Bone2D = par[0] as Bone2D
			var b: Bone2D = par[1] as Bone2D
			_verificar(rig.to_local(a.global_position).distance_to(anterior.to_local(b.global_position)) < .01, "trajetoria do primeiro braco preservada")
		var pele: PackedVector2Array = _vertices_deformados(rig)
		_verificar(rig.to_global(pele[perto]).distance_to(rig.ombro.global_position) < .01, "encaixe proximo acompanha pele")
		_verificar(rig.to_global(pele[longe]).distance_to(distante.ombro.global_position) < .01, "encaixe distante acompanha pele")
		for i: int in originais.size():
			if originais[i].y >= 430:
				_verificar(pele[i].distance_to(originais[i]) < .01, "pes nao deslizam")
		for face: PackedInt32Array in rig.pele.polygons:
			_verificar((pele[face[1]] - pele[face[0]]).cross(pele[face[3]] - pele[face[0]]) > 0,
				"primeira metade da face nao inverte")
			_verificar((pele[face[2]] - pele[face[1]]).cross(pele[face[3]] - pele[face[1]]) > 0,
				"segunda metade da face nao inverte")
	rig.definir_pose(&"repouso", true)
	rig.reproduzir_soco()
	rig.animacao.advance(.15)
	var antes: Array[Transform2D] = [distante.ombro.transform, distante.cotovelo.transform, rig.deltoide_distante.transform]
	rig.reproduzir_soco()
	rig.animacao.advance(0)
	_verificar(distante.ombro.transform.is_equal_approx(antes[0]) and distante.cotovelo.transform.is_equal_approx(antes[1])
		and rig.deltoide_distante.transform.is_equal_approx(antes[2]), "interrupcao captura tambem segundo braco")
	rig.definir_movimento_reduzido(true)
	_verificar(not rig.animacao.is_playing() and rig.deltoide_distante.transform == rig.deltoide_distante.rest,
		"movimento reduzido cancela ciclo corporal")
	_verificar(absf(distante.ombro.rotation_degrees - 115) < .001 and absf(distante.cotovelo.rotation_degrees - 20) < .001,
		"movimento reduzido restaura repouso do segundo braco")
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		await get_tree().process_frame
		prova.call("_layout")
		prova.call("_reduzir", false)
		for tempo: float in [0.0, .1, .2, .36, .56]:
			prova.call("_inspecionar", tempo)
			var combinado: DoisBracosNativoV2 = prova.braco as DoisBracosNativoV2
			for braco: BracoNativoV2 in [combinado.braco_original, combinado.braco_distante]:
				var arte: Sprite2D = braco.punho.get_node("Mao") as Sprite2D
				var ret: Rect2 = arte.get_rect()
				for canto: Vector2 in [ret.position, Vector2(ret.end.x, ret.position.y), ret.end, Vector2(ret.position.x, ret.end.y)]:
					var p: Vector2 = arte.to_global(canto)
					_verificar(p.x >= 0 and p.x <= resolucao.x and p.y >= 112 and p.y < resolucao.y - 112,
						"maos do contexto nao cortam nem cobrem controles")
		(prova.get_node("Rodape/Controles/Ossos") as CheckButton).button_pressed = true
		prova.get_node("OssosOverlay").queue_redraw()
		await get_tree().process_frame
	prova.queue_free()
	anterior.queue_free()
	await get_tree().process_frame
	print("TEST DOIS BRACOS NATIVO: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _vertices_deformados(rig: DoisBracosNativoV2) -> PackedVector2Array:
	# Oraculo de teste; o runtime usa skinning nativo na GPU.
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
