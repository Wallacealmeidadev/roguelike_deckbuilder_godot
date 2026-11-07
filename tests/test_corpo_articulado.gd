extends SceneTree

const NOVA: PackedScene = preload("res://vega_animada/corpo_articulado/vega_corpo.tscn")
const BASE: PackedScene = preload("res://vega_animada/braco_reconstruido/distante/vega_distante.tscn")
var falhas: int = 0
var poses: int = 0
var amostras_gpu: int = 0
var inversoes: int = 0
var inversoes_visiveis: int = 0
var max_guarda: float = 0
var max_influencias: int = 0
var intersecoes_maos: int = 0


func _initialize() -> void:
	_executar.call_deferred()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		if falhas <= 12:
			push_error("CORPO ARTICULADO: " + mensagem)


func _executar() -> void:
	var nova: VegaCorpoArticuladoV1 = NOVA.instantiate() as VegaCorpoArticuladoV1
	var base: VegaGuardaDistanteV1 = BASE.instantiate() as VegaGuardaDistanteV1
	for atriz: VegaGuardaDistanteV1 in [base, nova]:
		atriz.size = Vector2(650, 850)
		root.add_child(atriz)
	base.inspecionar(&"soco", 0)
	nova.pose_corpo(0)
	var rig: ApoioCorporalNativoV2 = nova.modelo
	_verificar(rig.pele.get_bone_count() == 11, "abdômen e cabeça registrados na pele")
	_verificar(rig.tronco.get_parent() == nova.abdomen and nova.abdomen.get_parent() == rig.pelve
		and nova.cabeca.get_parent() == rig.tronco, "cadeia corporal real, não compensação por frame")
	_verificar(rig.pele.uv == base.modelo.pele.uv and rig.pele.polygons == base.modelo.pele.polygons
		and rig.pele.texture == base.modelo.pele.texture, "pintura, UV e faces preservados")
	var antiga: PackedVector2Array = _deformar(base.modelo)
	var guarda: PackedVector2Array = _deformar(rig)
	for indice: int in range(guarda.size()):
		max_guarda = maxf(max_guarda, guarda[indice].distance_to(antiga[indice]))
		var soma: float = 0
		var influencias: int = 0
		for osso: int in range(11):
			var peso: float = rig.pele.get_bone_weights(osso)[indice]
			_verificar(peso >= 0 and peso <= 1, "peso válido")
			if peso > .000001:
				influencias += 1
			soma += peso
			_verificar(nova.remendo_ombro.get_bone_weights(osso)[indice] == peso, "acabamento segue a mesma pele")
		max_influencias = maxi(max_influencias, influencias)
		_verificar(absf(soma - 1) < .00001 and influencias <= 4, "pesos normalizados, máximo quatro influências")
	_verificar(max_guarda < .001, "rebind mantém a silhueta da guarda")
	for par: Array in [[nova.braco_novo, base.braco_novo], [nova.novo_distante, base.novo_distante]]:
		for indice: int in range(3):
			var a: Polygon2D = par[0].segmentos[indice]
			var b: Polygon2D = par[1].segmentos[indice]
			_verificar(a.polygon == b.polygon and a.uv == b.uv and a.texture == b.texture
				and a.transform == b.transform, "peças, mão e proporções aprovadas intactas")
	var fonte: Image = rig.pele.texture.get_image()
	var cabeca_a: int = rig.pele.uv.find(Vector2(650, 80))
	var cabeca_b: int = rig.pele.uv.find(Vector2(675, 80))
	var distancia_rosto: float = guarda[cabeca_a].distance_to(guarda[cabeca_b])
	var fixos: PackedVector2Array = rig.pele.polygon.duplicate()
	for quadro: int in range(57):
		var tempo: float = quadro / 100.0
		nova.inspecionar(&"corpo_soco", tempo)
		base.inspecionar(&"soco", tempo)
		poses += 1
		var pontos: PackedVector2Array = _deformar(rig)
		_verificar(rig.pele.polygon == fixos, "produção não reescreve vértices por frame")
		_verificar(absf(pontos[cabeca_a].distance_to(pontos[cabeca_b]) - distancia_rosto) < .001, "rosto não esticado")
		for indice: int in range(pontos.size()):
			if rig.pele.uv[indice].y >= 680:
				_verificar(pontos[indice].distance_to(guarda[indice]) < .001, "vértices das botas fixos")
		for face: PackedInt32Array in rig.pele.polygons:
			var area_a: float = (pontos[face[1]] - pontos[face[0]]).cross(pontos[face[3]] - pontos[face[0]])
			var area_b: float = (pontos[face[2]] - pontos[face[1]]).cross(pontos[face[3]] - pontos[face[1]])
			if minf(area_a, area_b) <= 0:
				inversoes += 1
				var uv: Vector2 = (rig.pele.uv[face[0]] + rig.pele.uv[face[1]] + rig.pele.uv[face[2]] + rig.pele.uv[face[3]]) * .25
				if fonte.get_pixelv(Vector2i(uv)).a > .1:
					inversoes_visiveis += 1
		for par: Array in [[nova.braco_novo, rig.braco_original], [nova.novo_distante, rig.braco_distante]]:
			_verificar(par[0].global_position.distance_to(par[1].global_position) < .001, "próteses acompanham sua inserção corporal")
		_verificar(absf(angle_difference(nova.braco_novo.punho.global_rotation, base.braco_novo.punho.global_rotation)) < .0001,
			"compensação mantém a direção aprovada do golpe")
		if quadro == 20:
			_verificar(absf(angle_difference(nova.cabeca.global_rotation, rig.tronco.global_rotation)) > deg_to_rad(8), "cabeça contrabalança peito no impacto")
			intersecoes_maos = _intersecao_maos(nova)
			if "--diagnosticar" in OS.get_cmdline_user_args():
				var rotacao: float = nova.novo_distante.ombro.rotation
				for angulo: float in [90.0, 105.0, 120.0, 135.0, 150.0, 165.0, 180.0, 195.0, 210.0]:
					nova.novo_distante.ombro.rotation = deg_to_rad(angulo)
					print("Guarda distante ", angulo, "°: ", _intersecao_maos(nova), " pontos sobrepostos; punho ", nova.novo_distante.punho.global_position)
				nova.novo_distante.ombro.rotation = rotacao
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			var imagem: Image = (nova.composicao.get_node("Desenho") as SubViewport).get_texture().get_image()
			for braco: BracoRegistradoV1 in [nova.braco_novo, nova.novo_distante]:
				for osso: Bone2D in [braco.ombro, braco.cotovelo, braco.punho]:
					for x: int in [-3, 0, 3]:
						var ponto: Vector2i = Vector2i(osso.to_global(Vector2(x, 0)).round())
						_verificar(imagem.get_pixelv(ponto).a > .9, "GPU: ombro/cotovelo/punho ocupados")
						amostras_gpu += 1
			for uv: Vector2 in [Vector2(650, 120), Vector2(650, 160), Vector2(650, 200), Vector2(620, 380)]:
				var indice: int = rig.pele.uv.find(uv)
				var ponto: Vector2i = Vector2i(rig.to_global(pontos[indice]).round())
				_verificar(imagem.get_pixelv(ponto).a > .9, "GPU: rosto/pescoço/peito/cintura ocupados")
				amostras_gpu += 1
	_verificar(inversoes == 0, "nenhuma face invertida, incluindo transparências")
	_verificar(intersecoes_maos == 0, "mãos têm silhuetas distintas no impacto amostrado")
	nova.pose_corpo(0)
	nova.socar_corpo()
	rig.animacao.advance(.12)
	var antes: Transform2D = nova.braco_novo.punho.global_transform
	nova.socar_corpo()
	_verificar(antes.is_equal_approx(nova.braco_novo.punho.global_transform), "interrupção sem salto imediato")
	rig.animacao.advance(.6)
	_verificar(nova.estado_animacao == "guarda" and not rig.animacao.is_playing(), "retorna à guarda estática")
	nova.reduzir_corpo(true)
	antes = nova.braco_novo.punho.global_transform
	nova.socar_corpo()
	_verificar(antes.is_equal_approx(nova.braco_novo.punho.global_transform) and not rig.animacao.is_playing(), "reduzido sem deslocamento")
	nova.reduzir_corpo(false)
	_verificar_preview()
	print("Corpo articulado: ", falhas, " falhas; ", poses, " poses; ", amostras_gpu, " amostras GPU; guarda ", max_guarda,
		" px; influências ", max_influencias, "; faces invertidas ", inversoes, " / visíveis ", inversoes_visiveis,
		"; mãos sobrepostas ", intersecoes_maos)
	nova.free()
	base.free()
	await process_frame
	quit(0 if falhas == 0 else 1)


func _deformar(rig: ApoioCorporalNativoV2) -> PackedVector2Array:
	var matrizes: Array[Transform2D] = []
	for indice: int in range(rig.pele.get_bone_count()):
		var osso: Bone2D = rig.esqueleto.get_node(rig.pele.get_bone_path(indice)) as Bone2D
		matrizes.append(rig.esqueleto.global_transform.affine_inverse() * osso.global_transform * osso.get_skeleton_rest().affine_inverse())
	var resultado := PackedVector2Array()
	for indice: int in range(rig.pele.polygon.size()):
		var ponto := Vector2.ZERO
		for osso: int in range(matrizes.size()):
			ponto += (matrizes[osso] * rig.pele.polygon[indice]) * rig.pele.get_bone_weights(osso)[indice]
		resultado.append(ponto)
	return resultado


func _intersecao_maos(atriz: VegaCorpoArticuladoV1) -> int:
	var perto: BracoRegistradoV1 = atriz.braco_novo
	var longe: BracoDistanteRegistradoV1 = atriz.novo_distante
	var imagem_a: Image = perto.ARTE.get_image()
	var imagem_b: Image = longe.ARTE_INTERNA.get_image()
	var total: int = 0
	for y: int in range(1200, 1536, 4):
		for x: int in range(350, 731, 4):
			var uv := Vector2(x, y)
			if imagem_a.get_pixel(x, y).a < .9:
				continue
			var mundo: Vector2 = perto.segmentos[2].to_global(perto.registros[2] * uv)
			var outro: Vector2 = longe.registros[2].affine_inverse() * longe.segmentos[2].to_local(mundo)
			if Geometry2D.is_point_in_polygon(outro, longe.segmentos[2].uv) and imagem_b.get_pixelv(Vector2i(outro)).a > .9:
				total += 1
	return total


func _verificar_preview() -> void:
	var laboratorio: Node2D = (load("res://vega_animada/corpo_articulado/preview.tscn") as PackedScene).instantiate() as Node2D
	root.add_child(laboratorio)
	var candidata: VegaCorpoArticuladoV1 = laboratorio.get("candidata") as VegaCorpoArticuladoV1
	var anterior: VegaGuardaDistanteV1 = laboratorio.get("anterior") as VegaGuardaDistanteV1
	var tecla := InputEventKey.new()
	tecla.pressed = true
	for codigo: Key in [KEY_1, KEY_2, KEY_3]:
		tecla.keycode = codigo
		laboratorio.call("_unhandled_key_input", tecla)
		_verificar(is_equal_approx(candidata.modelo.animacao.current_animation_position, anterior.modelo.animacao.current_animation_position), "poses comparadas no mesmo instante")
	tecla.keycode = KEY_L
	laboratorio.call("_unhandled_key_input", tecla)
	_verificar(candidata.modelo.animacao.speed_scale == .25 and anterior.modelo.animacao.speed_scale == .25, "L reduz ambas em quatro vezes")
	tecla.keycode = KEY_O
	laboratorio.call("_unhandled_key_input", tecla)
	_verificar(candidata.braco_novo.mostrar_marcos and candidata.novo_distante.mostrar_marcos, "O mostra as duas cadeias")
	tecla.keycode = KEY_R
	laboratorio.call("_unhandled_key_input", tecla)
	tecla.keycode = KEY_SPACE
	laboratorio.call("_unhandled_key_input", tecla)
	_verificar(candidata.corpo_reduzido and not candidata.modelo.animacao.is_playing() and not anterior.modelo.animacao.is_playing(), "R/Espaço mantêm as duas poses estáticas")
	laboratorio.free()
