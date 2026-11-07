extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("OMBRO NATIVO: " + mensagem)


func _executar() -> void:
	var cena: PackedScene = load("res://vega_animada/rig_nativo_v2/preview_ombro.tscn") as PackedScene
	if cena == null:
		get_tree().quit(1)
		return
	var prova: Control = cena.instantiate() as Control
	get_tree().root.add_child(prova)
	await get_tree().process_frame
	var rig: OmbroTroncoNativoV2 = prova.braco as OmbroTroncoNativoV2
	_verificar(rig != null, "preview precisa instanciar corpo nativo")
	_verificar(rig.esqueleto.get_bone_count() == 4, "quatro ossos corporais registrados")
	_verificar(rig.braco_original.esqueleto.get_bone_count() == 3, "braco aprovado continua instanciado, com tres ossos")
	_verificar(not rig.braco_original.animacao.active, "AnimationPlayer interno nao pode disputar escrita")
	_verificar(rig.pele.get_node(rig.pele.skeleton) == rig.esqueleto, "pele realmente vinculada ao Skeleton2D")
	_verificar(rig.pele.get_bone_count() == 4, "pesos da pele precisam existir no recurso")
	var originais: PackedVector2Array = rig.pele.polygon
	for indice: int in originais.size():
		var soma: float = 0
		for osso: int in 4:
			var peso: float = rig.pele.get_bone_weights(osso)[indice]
			_verificar(peso >= 0 and peso <= 1, "peso dentro do intervalo valido")
			soma += peso
		_verificar(absf(soma - 1) < .00001, "pesos normalizados em cada vertice")
		if originais[indice].y >= 410:
			_verificar(rig.pele.get_bone_weights(0)[indice] == 1, "pernas e pes pertencem somente a pelve fixa")
	var encaixe: int = originais.find(Vector2(201, 225))
	_verificar(encaixe >= 0 and rig.pele.get_bone_weights(3)[encaixe] == 1, "encaixe humano deve seguir exatamente o deltoide")
	var superior: Vector2 = rig.cotovelo.position
	var inferior: Vector2 = rig.punho.position
	var mao: Sprite2D = rig.punho.get_node("Mao") as Sprite2D
	var mao_transform: Transform2D = mao.transform
	var repouso: Vector2 = rig.ombro.global_position
	rig.definir_pose(&"extensao", true)
	var extensao: Vector2 = rig.ombro.global_position
	print("OMBRO NATIVO: deslocamento do encaixe = %s" % (rig.to_local(extensao) - rig.to_local(repouso)))
	_verificar(extensao.distance_to(repouso) > 3, "ombro precisa participar do golpe, nao so girar proteses")
	_verificar(absf(wrapf(rig.ombro.global_rotation - rig.global_rotation, -PI, PI) - deg_to_rad(-8)) < .001, "orientacao global do braco aprovado preservada na extensao")
	for nome: StringName in [&"repouso", &"guarda", &"extensao", &"soco"]:
		var animacao: Animation = rig.animacao.get_animation(nome)
		_verificar(animacao.get_track_count() == 6, "corpo e braco coordenados por seis trilhas")
		for trilha: int in animacao.get_track_count():
			_verificar(str(animacao.track_get_path(trilha)).ends_with(":rotation"), "nao animar escala ou posicao dos ossos")
			for chave: int in animacao.track_get_key_count(trilha):
				_verificar(typeof(animacao.track_get_key_value(trilha, chave)) == TYPE_FLOAT, "chaves de rotacao devem ser float, inclusive zero")
	for passo: int in 57:
		rig.inspecionar_tempo(float(passo) / 100)
		_verificar(rig.cotovelo.position == superior and rig.punho.position == inferior, "membros nao esticam")
		_verificar(mao.transform == mao_transform, "mao mantem tamanho e encaixe")
		_verificar(rig.pelve.transform == rig.pelve.rest, "pelve nao se move")
		_verificar(rig.pele.polygon == originais, "nenhum codigo reescreve a geometria da pele a cada frame")
		var deformados: PackedVector2Array = _vertices_deformados(rig)
		var ponto_pele: Vector2 = rig.to_global(deformados[encaixe])
		_verificar(ponto_pele.distance_to(rig.ombro.global_position) < .01, "pele e proteses compartilham a mesma ancora")
		for indice: int in originais.size():
			if originais[indice].y >= 430:
				_verificar(deformados[indice].distance_to(originais[indice]) < .01, "pernas e pes nao deslizam com o tronco")
		for face: PackedInt32Array in rig.pele.polygons:
			var ab: Vector2 = deformados[face[1]] - deformados[face[0]]
			var ad: Vector2 = deformados[face[3]] - deformados[face[0]]
			_verificar(ab.cross(ad) > 0, "pele nao dobra a malha sobre si mesma")
			var bc: Vector2 = deformados[face[2]] - deformados[face[1]]
			var bd: Vector2 = deformados[face[3]] - deformados[face[1]]
			_verificar(bc.cross(bd) > 0, "segunda metade da face nao inverte")
		for osso: Bone2D in [rig.pelve, rig.tronco, rig.clavicula, rig.deltoide, rig.ombro, rig.cotovelo, rig.punho]:
			_verificar(osso.scale == Vector2.ONE, "ossos nao mudam escala")
	rig.definir_pose(&"repouso", true)
	rig.reproduzir_soco()
	rig.animacao.advance(.15)
	var antes: Array[Transform2D] = [rig.tronco.transform, rig.deltoide.transform, rig.ombro.transform]
	rig.reproduzir_soco()
	rig.animacao.advance(0)
	_verificar(rig.tronco.transform.is_equal_approx(antes[0]) and rig.deltoide.transform.is_equal_approx(antes[1]) and rig.ombro.transform.is_equal_approx(antes[2]), "captura interrompe corpo e braco sem teleporte")
	rig.definir_movimento_reduzido(true)
	_verificar(not rig.animacao.is_playing() and rig.tronco.transform == rig.tronco.rest and rig.deltoide.transform == rig.deltoide.rest, "reduzido limpa movimento corporal")
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		await get_tree().process_frame
		prova.call("_layout")
		var limites: Rect2 = prova.get_global_rect()
		_verificar(limites.encloses((prova.get_node("ZoomPanel") as Control).get_global_rect()), "painel de detalhe cabe na viewport")
		_verificar(limites.encloses((prova.get_node("Rodape/Controles/Reduzido") as Control).get_global_rect()), "controles cabem na viewport")
	prova.queue_free()
	await get_tree().process_frame
	print("OMBRO NATIVO: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _vertices_deformados(rig: OmbroTroncoNativoV2) -> PackedVector2Array:
	# Oraculo de teste. O jogo/preview usa exclusivamente skinning nativo na GPU.
	var pontos: PackedVector2Array = rig.pele.polygon
	var saida: PackedVector2Array = PackedVector2Array()
	var matrizes: Array[Transform2D] = []
	for indice: int in rig.pele.get_bone_count():
		var osso: Bone2D = rig.esqueleto.get_node(rig.pele.get_bone_path(indice)) as Bone2D
		var atual: Transform2D = rig.esqueleto.global_transform.affine_inverse() * osso.global_transform
		matrizes.append(atual * osso.get_skeleton_rest().affine_inverse())
	for indice: int in pontos.size():
		var deformado: Vector2 = Vector2.ZERO
		for osso: int in matrizes.size():
			deformado += (matrizes[osso] * pontos[indice]) * rig.pele.get_bone_weights(osso)[indice]
		saida.append(deformado)
	return saida
