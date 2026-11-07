extends SceneTree

const NOVA: PackedScene = preload("res://vega_animada/braco_reconstruido/ombro_integrado/vega_ombro.tscn")
const BASE: PackedScene = preload("res://vega_animada/braco_reconstruido/vega_movimento.tscn")
var falhas: int = 0
var poses: int = 0
var amostras_gpu: int = 0
var desvio_braco: float = 0
var desvio_guarda: float = 0
var deslocamento_pele: float = 0


func _initialize() -> void:
	_executar.call_deferred()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		if falhas <= 12:
			push_error("OMBRO INTEGRADO: " + mensagem)


func _executar() -> void:
	var base: VegaMovimentoBracoV1 = BASE.instantiate() as VegaMovimentoBracoV1
	var nova: VegaOmbroIntegradoV1 = NOVA.instantiate() as VegaOmbroIntegradoV1
	for atriz: VegaMovimentoBracoV1 in [base, nova]:
		atriz.size = Vector2(650, 850)
		root.add_child(atriz)
	_verificar(nova.vertices_ajustados > 0, "repesar uma região real, não só mudar um parâmetro")
	_verificar(base.modelo.pele.polygon == nova.vertices_originais, "origem não foi mutada")
	_verificar(base.modelo.pele.uv == nova.modelo.pele.uv
		and base.modelo.pele.polygons == nova.modelo.pele.polygons
		and base.modelo.pele.texture == nova.modelo.pele.texture, "arte/UV/faces preservadas")
	for indice: int in range(nova.modelo.pele.polygon.size()):
		var soma: float = 0
		for osso: int in range(nova.modelo.pele.get_bone_count()):
			var peso: float = nova.modelo.pele.get_bone_weights(osso)[indice]
			_verificar(peso >= 0 and peso <= 1, "peso válido")
			soma += peso
			_verificar(base.modelo.pele.get_bone_weights(osso)[indice] == nova.pesos_originais[osso][indice], "pesos originais isolados")
			_verificar(nova.remendo_ombro.get_bone_weights(osso)[indice] == peso, "acabamento acompanha a mesma pele")
			if not nova.REGIAO_PESOS.has_point(nova.vertices_originais[indice]) or osso not in [2, 3]:
				_verificar(peso == nova.pesos_originais[osso][indice], "pesos só de clavícula/deltoide e na região")
		_verificar(absf(soma - 1) < .00001, "pesos normalizados")
		if not nova.REGIAO_PESOS.has_point(nova.vertices_originais[indice]):
			_verificar(nova.modelo.pele.polygon[indice] == nova.vertices_originais[indice], "rebind não altera outras regiões")
	_verificar(nova.remendo_ombro.polygon == nova.modelo.pele.polygon, "geometria do acabamento alinhada")
	_verificar_clipes(base, nova)
	for atriz: VegaMovimentoBracoV1 in [base, nova]:
		atriz.inspecionar(&"respirar", 0)
	var antes: PackedVector2Array = _pele(base.modelo)
	var depois: PackedVector2Array = _pele(nova.modelo)
	for indice: int in range(antes.size()):
		desvio_guarda = maxf(desvio_guarda, antes[indice].distance_to(depois[indice]))
	_verificar(desvio_guarda < .001, "rebind preserva toda a silhueta na guarda")
	for nome: StringName in [&"soco", &"dano", &"respirar"]:
		var duracao: float = nova.modelo.animacao.get_animation(nome).length
		var passos: int = 48 if nome == &"respirar" else roundi(duracao * 100)
		for quadro: int in range(passos + 1):
			var tempo: float = duracao * quadro / passos
			base.inspecionar(nome, tempo)
			nova.inspecionar(nome, tempo)
			poses += 1
			var antigos: Array[Node2D] = [base.braco_novo.ombro, base.braco_novo.cotovelo, base.braco_novo.punho]
			var novos: Array[Node2D] = [nova.braco_novo.ombro, nova.braco_novo.cotovelo, nova.braco_novo.punho]
			for indice: int in range(novos.size()):
				var a: Transform2D = antigos[indice].global_transform
				var b: Transform2D = novos[indice].global_transform
				desvio_braco = maxf(desvio_braco, a.origin.distance_to(b.origin))
				_verificar(a.origin.distance_to(b.origin) < .001
					and a.x.distance_to(b.x) < .00001 and a.y.distance_to(b.y) < .00001, "prótese mantém trajetória e rigidez aprovadas")
			_verificar(nova.braco_novo.segmentos[2].scale == Vector2(.76, -.76), "mão aprovada intacta")
			_verificar(nova.modelo.sola_frente.global_transform.is_equal_approx(base.modelo.sola_frente.global_transform)
				and nova.modelo.sola_tras.global_transform.is_equal_approx(base.modelo.sola_tras.global_transform), "apoios mantidos")
			if nome == &"soco" and is_equal_approx(tempo, .2):
				_verificar(absf(rad_to_deg(nova.modelo.deltoide.rotation - base.modelo.deltoide.rotation) + 19.04) < .001, "deltoide participa do impacto")
				antes = _pele(base.modelo)
				depois = _pele(nova.modelo)
				for indice: int in range(antes.size()):
					deslocamento_pele = maxf(deslocamento_pele, antes[indice].distance_to(depois[indice]))
			if DisplayServer.get_name() != "headless":
				await RenderingServer.frame_post_draw
				_verificar_gpu(nova)
	_verificar(deslocamento_pele > 1, "pele responde de forma observável")
	nova.reiniciar()
	nova.socar()
	nova.modelo.animacao.advance(.12)
	var punho: Transform2D = nova.braco_novo.punho.global_transform
	nova.socar()
	_verificar(punho.is_equal_approx(nova.braco_novo.punho.global_transform), "recomando não teleporta")
	nova.receber_dano()
	_verificar(nova.estado_animacao == "dano", "dano interrompe")
	nova.modelo.animacao.advance(.30)
	_verificar(nova.estado_animacao == "repouso" and nova.modelo.animacao.is_playing(), "retorna à respiração")
	nova.definir_reduzido(true)
	punho = nova.braco_novo.punho.global_transform
	nova.socar()
	nova.modelo.animacao.advance(.2)
	_verificar(punho.is_equal_approx(nova.braco_novo.punho.global_transform) and not nova.modelo.animacao.is_playing(), "reduzido sem deslocamento")
	nova.definir_reduzido(false)
	_verificar(nova.modelo.animacao.is_playing(), "retoma movimento")
	_verificar_comparador()
	base.free()
	nova.free()
	await process_frame
	print("Ombro integrado: ", falhas, " falhas; ", poses, " poses; ", amostras_gpu, " amostras GPU; desvio braço ", desvio_braco,
		" px; guarda ", desvio_guarda, " px; resposta pele ", deslocamento_pele, " px")
	quit(0 if falhas == 0 else 1)


func _verificar_clipes(base: VegaMovimentoBracoV1, nova: VegaOmbroIntegradoV1) -> void:
	for nome: StringName in base.modelo.animacao.get_animation_list():
		var a: Animation = base.modelo.animacao.get_animation(nome)
		var b: Animation = nova.modelo.animacao.get_animation(nome)
		_verificar(a != b and a.length == b.length and a.loop_mode == b.loop_mode, "clipe privado com duração e loop mantidos")
		for trilha: int in range(a.get_track_count()):
			_verificar(a.track_get_path(trilha) == b.track_get_path(trilha)
				and a.track_get_interpolation_type(trilha) == b.track_get_interpolation_type(trilha)
				and a.track_get_key_count(trilha) == b.track_get_key_count(trilha), "destinos, interpolação e número de chaves mantidos")
			for chave: int in range(a.track_get_key_count(trilha)):
				_verificar(a.track_get_key_time(trilha, chave) == b.track_get_key_time(trilha, chave)
					and a.track_get_key_transition(trilha, chave) == b.track_get_key_transition(trilha, chave), "tempos/curvas preservados")
				if trilha not in [2, 3]:
					_verificar(a.track_get_key_value(trilha, chave) == b.track_get_key_value(trilha, chave), "somente deltoide/ombro dividem o giro")


func _pele(rig: ApoioCorporalNativoV2) -> PackedVector2Array:
	var matrizes: Array[Transform2D] = []
	for indice: int in range(rig.pele.get_bone_count()):
		var osso: Bone2D = rig.esqueleto.get_node(rig.pele.get_bone_path(indice)) as Bone2D
		var atual: Transform2D = rig.esqueleto.global_transform.affine_inverse() * osso.global_transform
		matrizes.append(atual * osso.get_skeleton_rest().affine_inverse())
	var resultado := PackedVector2Array()
	for indice: int in range(rig.pele.polygon.size()):
		var ponto := Vector2.ZERO
		for osso: int in range(matrizes.size()):
			ponto += (matrizes[osso] * rig.pele.polygon[indice]) * rig.pele.get_bone_weights(osso)[indice]
		resultado.append(ponto)
	return resultado


func _verificar_gpu(nova: VegaOmbroIntegradoV1) -> void:
	var braco: BracoRegistradoV1 = nova.braco_novo
	var viewport: SubViewport = nova.composicao.get_node("Desenho") as SubViewport
	var render: Image = viewport.get_texture().get_image()
	var pontos: Array[Vector2] = [braco.cotovelo.global_position, braco.punho.global_position,
		braco.segmentos[2].to_global(braco.registros[2] * Vector2(520, 1350))]
	for passo: int in range(-10, 11, 2):
		pontos.append(braco.global_position + Vector2(0, passo))
	for x: int in [0, 2, 4, 6]:
		for y: int in [-3, 0, 3]:
			pontos.append(braco.punho.to_global(Vector2(x, y)))
	for ponto: Vector2 in pontos:
		_verificar(render.get_pixelv(Vector2i(ponto.round())).a > .9, "GPU: continuidade nos pontos de ombro/cotovelo/punho/mão")
		amostras_gpu += 1


func _verificar_comparador() -> void:
	var laboratorio: Node2D = (load("res://vega_animada/braco_reconstruido/ombro_integrado/preview.tscn") as PackedScene).instantiate() as Node2D
	root.add_child(laboratorio)
	var atriz: VegaOmbroIntegradoV1 = laboratorio.get("atriz") as VegaOmbroIntegradoV1
	var base: VegaMovimentoBracoV1 = laboratorio.get("base") as VegaMovimentoBracoV1
	atriz.inspecionar(&"soco", .2)
	laboratorio.call("_alternar")
	_verificar(base.visible and not atriz.visible and is_equal_approx(base.modelo.animacao.current_animation_position, .2)
		and not base.modelo.animacao.is_playing(), "A compara mesma fase pausada")
	base.modelo.animacao.play()
	laboratorio.call("_alternar")
	_verificar(atriz.visible and not base.visible and is_equal_approx(atriz.modelo.animacao.current_animation_position, .2)
		and atriz.modelo.animacao.is_playing(), "A mantém fase e reprodução")
	laboratorio.free()
