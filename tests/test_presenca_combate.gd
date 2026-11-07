extends "res://tests/test_golpes_alternados.gd"

const PRESENCA: PackedScene = preload("res://vega_animada/corpo_articulado/presenca_combate/vega_presenca.tscn")
var amostras_presenca: int = 0
var desvios_golpes: int = 0
var deslocamento_respiro: float = 0
var deslocamento_dano: float = 0


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		motivos[mensagem] = motivos.get(mensagem, 0) + 1
		if falhas <= 12:
			push_error("PRESENÇA CORPORAL: " + mensagem)


func _executar() -> void:
	var nova: VegaPresencaCombateV1 = PRESENCA.instantiate() as VegaPresencaCombateV1
	var base: VegaGolpesAlternadosV1 = ALTERNADA.instantiate() as VegaGolpesAlternadosV1
	for atriz: VegaCorpoArticuladoV1 in [base, nova]:
		atriz.size = Vector2(650, 850)
		root.add_child(atriz)
	_verificar(nova.modelo.animacao.current_animation == nova.RESPIRO and nova.modelo.animacao.is_playing(), "começa respirando em guarda")
	_verificar(not base.modelo.animacao.has_animation(nova.RESPIRO) and not base.modelo.animacao.has_animation(nova.FERIMENTO), "clipes privados, referência intacta")
	_verificar_clipes(nova, base)
	nova.inspecionar(&"corpo_soco", 0)
	var malha: Polygon2D = nova.modelo.pele
	_verificar(malha.polygon == base.modelo.pele.polygon and malha.uv == base.modelo.pele.uv and malha.texture == base.modelo.pele.texture, "mesma pintura/malha/UV")
	for indice: int in range(malha.get_bone_count()):
		_verificar(malha.get_bone_weights(indice) == base.modelo.pele.get_bone_weights(indice), "pesos preservados")
	var guarda: PackedVector2Array = _deformar(nova.modelo)
	var face_a: int = malha.uv.find(Vector2(650, 80))
	var face_b: int = malha.uv.find(Vector2(675, 80))
	var distancia_rosto: float = guarda[face_a].distance_to(guarda[face_b])
	var punho: Vector2 = nova.braco_novo.punho.global_position
	var partes: Array[Transform2D] = []
	for braco: BracoRegistradoV1 in [nova.braco_novo, nova.novo_distante]:
		for parte: Polygon2D in braco.segmentos:
			partes.append(parte.transform)
	for dano: bool in [false, true]:
		var duracao: float = .26 if dano else 2.4
		var clipe: Animation = nova.modelo.animacao.get_animation(nova.FERIMENTO if dano else nova.RESPIRO)
		_verificar(clipe.length == duracao and clipe.loop_mode == (Animation.LOOP_NONE if dano else Animation.LOOP_LINEAR), "durações/loop nativos")
		for quadro: int in range(27 if dano else 121):
			var tempo: float = quadro * (.01 if dano else .02)
			nova.inspecionar_presenca(dano, tempo)
			poses += 1
			var pontos: PackedVector2Array = _deformar(nova.modelo)
			for indice: int in range(pontos.size()):
				if malha.uv[indice].y >= 680:
					_verificar(pontos[indice].distance_to(guarda[indice]) < .001, "botas imóveis")
			_verificar(absf(pontos[face_a].distance_to(pontos[face_b]) - distancia_rosto) < .001, "rosto rígido, sem esticar")
			for face: PackedInt32Array in malha.polygons:
				if (pontos[face[1]] - pontos[face[0]]).cross(pontos[face[3]] - pontos[face[0]]) <= 0 \
					or (pontos[face[2]] - pontos[face[1]]).cross(pontos[face[3]] - pontos[face[1]]) <= 0:
					faces_invertidas += 1
			var p: int = 0
			for par: Array in [[nova.braco_novo, nova.modelo.braco_original], [nova.novo_distante, nova.modelo.braco_distante]]:
				var braco: BracoRegistradoV1 = par[0]
				_verificar(braco.global_position.distance_to(par[1].global_position) < .001, "braço continua no ombro")
				_verificar(braco.cotovelo.position.is_equal_approx(Vector2(braco.SUPERIOR, 0))
					and braco.punho.position.is_equal_approx(Vector2(braco.INFERIOR, 0)), "centros/comprimentos preservados")
				for parte: Polygon2D in braco.segmentos:
					_verificar(parte.transform == partes[p], "sem alteração de escala/orientação das peças")
					p += 1
			if quadro == (10 if dano else 60):
				if dano:
					deslocamento_dano = nova.braco_novo.punho.global_position.distance_to(punho)
				else:
					deslocamento_respiro = nova.braco_novo.punho.global_position.distance_to(punho)
			if quadro == 0 or quadro == (26 if dano else 120):
				for indice: int in range(pontos.size()):
					_verificar(pontos[indice].distance_to(guarda[indice]) < .001, "extremos retornam à guarda aceita")
			if DisplayServer.get_name() != "headless":
				await process_frame
				await RenderingServer.frame_post_draw
				var imagem: Image = (nova.composicao.get_node("Desenho") as SubViewport).get_texture().get_image()
				for braco: BracoRegistradoV1 in [nova.braco_novo, nova.novo_distante]:
					for osso: Bone2D in [braco.ombro, braco.cotovelo, braco.punho]:
						for deslocamento: int in [-3, 0, 3]:
							_verificar(imagem.get_pixelv(Vector2i(osso.to_global(Vector2(deslocamento, 0)).round())).a > .9, "GPU: juntas ocupadas")
							amostras_presenca += 1
	_verificar(faces_invertidas == 0, "nenhuma face invertida")
	_verificar(deslocamento_respiro > .5 and deslocamento_respiro < 8 and deslocamento_dano > 3 and deslocamento_dano < 30, "movimento presente, limitado à amplitude proposta")
	await _verificar_golpes(nova, base)
	await _verificar_fluxo(nova)
	_verificar_preview_presenca()
	nova.free()
	base.free()
	await process_frame
	print("Presença corporal: ", falhas, " falhas; ", poses, " poses; ", amostras_presenca,
		" amostras GPU; inversões ", faces_invertidas, "; poses de golpes divergentes ", desvios_golpes,
		"; deslocamento punho respiro/dano ", deslocamento_respiro, "/", deslocamento_dano, " px")
	if falhas > 0:
		print("Motivos: ", motivos)
	quit(0 if falhas == 0 else 1)


func _verificar_golpes(nova: VegaPresencaCombateV1, base: VegaGolpesAlternadosV1) -> void:
	for distante: bool in [false, true]:
		for indice: int in range(5):
			nova.inspecionar_golpe(distante, indice)
			base.inspecionar_golpe(distante, indice)
			_verificar(nova.braco_novo.punho.global_transform.is_equal_approx(base.braco_novo.punho.global_transform)
				and nova.novo_distante.punho.global_transform.is_equal_approx(base.novo_distante.punho.global_transform), "gestos dos golpes preservados")
			if DisplayServer.get_name() != "headless":
				await process_frame
				await RenderingServer.frame_post_draw
				var a: Image = (nova.composicao.get_node("Desenho") as SubViewport).get_texture().get_image()
				var b: Image = (base.composicao.get_node("Desenho") as SubViewport).get_texture().get_image()
				if a.get_data() != b.get_data():
					desvios_golpes += 1
	_verificar(desvios_golpes == 0, "GPU: dez poses dos golpes idênticas à versão 13")


func _sem_salto(atriz: VegaPresencaCombateV1, acao: Callable) -> void:
	var a: Transform2D = atriz.braco_novo.punho.global_transform
	var b: Transform2D = atriz.novo_distante.punho.global_transform
	var tronco: Transform2D = atriz.modelo.tronco.global_transform
	acao.call()
	_verificar(a.is_equal_approx(atriz.braco_novo.punho.global_transform)
		and b.is_equal_approx(atriz.novo_distante.punho.global_transform)
		and tronco.is_equal_approx(atriz.modelo.tronco.global_transform), "transição captura mãos/tronco sem salto imediato")


func _verificar_fluxo(atriz: VegaPresencaCombateV1) -> void:
	atriz.reiniciar_sequencia()
	atriz.modelo.animacao.advance(.8)
	_sem_salto(atriz, atriz.socar_corpo)
	_verificar(not atriz.ultimo_braco_distante and atriz.proximo_braco_distante, "respiração não muda ordem")
	atriz.modelo.animacao.advance(.15)
	_sem_salto(atriz, atriz.receber_dano)
	_verificar(atriz.proximo_braco_distante, "dano durante próximo não consome braço distante")
	atriz.modelo.animacao.advance(.3)
	_verificar(atriz.modelo.animacao.current_animation == atriz.RESPIRO, "dano retorna à respiração")
	_sem_salto(atriz, atriz.socar_corpo)
	_verificar(atriz.ultimo_braco_distante and not atriz.proximo_braco_distante, "continua pelo distante")
	atriz.modelo.animacao.advance(.1)
	_sem_salto(atriz, atriz.receber_dano)
	atriz.modelo.animacao.advance(.05)
	_sem_salto(atriz, atriz.receber_dano)
	_verificar(not atriz.proximo_braco_distante, "danos repetidos preservam próximo ataque")
	_sem_salto(atriz, atriz.socar_corpo)
	atriz.modelo.animacao.advance(.6)
	_verificar(atriz.modelo.animacao.current_animation == atriz.RESPIRO and atriz.visual.modulate == Color.WHITE, "golpe retorna à respiração e cancela flash antigo")
	atriz.definir_respiro(false)
	_verificar(not atriz.modelo.animacao.is_playing(), "comparação estática sem oscilação")
	atriz.socar_corpo()
	atriz.modelo.animacao.advance(.6)
	_verificar(not atriz.modelo.animacao.is_playing(), "respiro desligado retorna à guarda estática")
	atriz.definir_respiro(true)
	_verificar(atriz.modelo.animacao.current_animation == atriz.RESPIRO and atriz.modelo.animacao.is_playing(), "retoma ciclo")
	atriz.socar_corpo()
	atriz.modelo.animacao.advance(.12)
	var golpe_em_curso: StringName = atriz.modelo.animacao.current_animation
	atriz.definir_respiro(false)
	_verificar(atriz.modelo.animacao.current_animation == golpe_em_curso, "preferência de respiro não interrompe golpe")
	atriz.modelo.animacao.advance(.6)
	_verificar(not atriz.modelo.animacao.is_playing(), "preferência vale após terminar golpe")
	atriz.definir_respiro(true)
	atriz.reduzir_corpo(true)
	var ordem: bool = atriz.proximo_braco_distante
	var a: Transform2D = atriz.braco_novo.punho.global_transform
	var b: Transform2D = atriz.novo_distante.punho.global_transform
	atriz.receber_dano()
	_verificar(atriz.proximo_braco_distante == ordem, "dano reduzido não altera ordem")
	atriz.socar_corpo()
	_verificar(atriz.proximo_braco_distante != ordem and not atriz.modelo.animacao.is_playing(), "ataque reduzido alterna sem articulação")
	_verificar(a.is_equal_approx(atriz.braco_novo.punho.global_transform)
		and b.is_equal_approx(atriz.novo_distante.punho.global_transform), "reduzido mantém guarda")
	await create_timer(.35).timeout
	_verificar(atriz.visual.modulate == Color.WHITE and not atriz.modelo.animacao.is_playing()
		and atriz.movimento == null, "feedback reduzido termina sem Tween/loop espacial pendente")
	atriz.reduzir_corpo(false)
	_verificar(atriz.modelo.animacao.current_animation == atriz.RESPIRO, "sair do reduzido retoma respiro")
	atriz.hide()
	atriz.receber_dano()
	atriz.socar_corpo()
	_verificar(not atriz.modelo.animacao.is_playing() and not atriz.proximo_braco_distante, "oculto pausa e ignora dano/ataque")
	atriz.show()
	_verificar(atriz.modelo.animacao.current_animation == atriz.RESPIRO and atriz.modelo.animacao.is_playing(), "mostrar retoma guarda viva")


func _verificar_preview_presenca() -> void:
	var cena: PackedScene = load("res://vega_animada/corpo_articulado/presenca_combate/preview.tscn") as PackedScene
	var preview: Node2D = cena.instantiate() as Node2D
	root.add_child(preview)
	for tecla: Key in [KEY_4, KEY_5, KEY_G, KEY_B, KEY_B, KEY_SPACE, KEY_D, KEY_L, KEY_Z, KEY_O, KEY_R, KEY_D, KEY_SPACE, KEY_X]:
		var evento := InputEventKey.new()
		evento.keycode = tecla
		evento.pressed = true
		preview._unhandled_key_input(evento)
	var atriz: VegaPresencaCombateV1 = preview.atriz_presenca as VegaPresencaCombateV1
	_verificar(atriz.respiro_habilitado and atriz.corpo_reduzido and preview.ampliado and preview.lento, "B/R/Z/L e inspeção")
	_verificar(not atriz.proximo_braco_distante and not atriz.ultimo_braco_distante, "X reseta sequência")
	preview.free()
