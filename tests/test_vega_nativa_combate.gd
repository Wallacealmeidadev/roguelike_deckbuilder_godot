extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("VEGA NATIVA COMBATE: " + mensagem)


func _executar() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	if "--acabamento" in OS.get_cmdline_user_args():
		jogo.cena_apresentacao_vega = load("res://vega_animada/rig_nativo_v2/acabamento_proximo/vega_prova.tscn") as PackedScene
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	var vega: VegaCombateNativo = jogo.vega_animada as VegaCombateNativo
	_verificar(vega != null, "padrao do jogo deve usar adaptador nativo, nao uma fixture")
	if vega == null:
		get_tree().quit(1)
		return
	var rig: ApoioCorporalNativoV2 = vega.modelo
	_verificar(not rig.animacao.is_playing() and rig.combo == 0, "mapa nao anima ou retém Combo")
	_verificar(rig.esqueleto.get_bone_count() == 9 and rig.malhas.size() == 4, "rig com apoio e quatro fibras de Combo integrado")
	_verificar(vega.mouse_filter == Control.MOUSE_FILTER_IGNORE and vega.visual.mouse_filter == Control.MOUSE_FILTER_IGNORE,
		"apresentacao nao intercepta clique")
	_verificar(not vega.has_node("Visual/Arte") and not jogo.has_node("Jogador/VegaCampoRetrato"), "sem placeholder sobreposto")
	var previa: ApoioCorporalNativoV2 = (load("res://vega_animada/rig_nativo_v2/apoio_corporal.tscn") as PackedScene).instantiate() as ApoioCorporalNativoV2
	add_child(previa)
	previa.visible = false
	await get_tree().process_frame
	_verificar(not previa.animacao.has_animation(&"respirar") and not previa.animacao.has_animation(&"dano"), "clips adicionais nao contaminam recursos das previas")
	_conferir_repouso(vega, previa)
	previa.queue_free()
	jogo.call("_iniciar_combate_por_id", "drone_carga", false)
	await get_tree().process_frame
	_verificar(rig.animacao.current_animation == "respirar" and vega.estado_animacao == "repouso", "combate inicia guarda viva, sem baixar os bracos")
	rig.animacao.pause()
	rig.animacao.seek(1.2, true)
	_verificar(absf(rig.tronco.rotation) > .001 and rig.pelve.transform == rig.pelve.rest and rig.apoios.transform == rig.apoios.rest,
		"respiracao nao levanta ou escala pes/pelve")
	_verificar(vega.visual.position == Vector2.ZERO and vega.visual.scale == Vector2.ONE, "sem mover personagem inteiro para simular respiracao")
	jogo.movimento_reduzido = true
	jogo.call("_atualizar_interface")
	for valor: int in [0, 1, 5, 10, 11, 100]:
		jogo.combo = valor
		jogo.call("_atualizar_interface")
		_verificar(rig.combo == valor and is_equal_approx(rig.tensao_combo, BracoV2Prova.tensao_por_combo(valor)), "Combo real e saturacao chegam ao rig")
		_verificar(rig.pelve.transform == rig.pelve.rest, "Combo nao muda postura")
	jogo.movimento_reduzido = false
	jogo.combo = 0
	jogo.call("_atualizar_interface")
	vega.socar()
	rig.animacao.advance(.15)
	var antes: Array[Transform2D] = [rig.pelve.transform, rig.ombro.transform, rig.braco_distante.punho.transform]
	vega.socar()
	rig.animacao.advance(0)
	_verificar(rig.pelve.transform.is_equal_approx(antes[0]) and rig.ombro.transform.is_equal_approx(antes[1])
		and rig.braco_distante.punho.transform.is_equal_approx(antes[2]), "ataque rapido captura pose completa sem teleporte")
	rig.animacao.advance(.2)
	_verificar(vega.estado_animacao == "soco" and rig.pelve.position.x > rig.pelve.rest.origin.x, "impacto nativo usa apoio corporal")
	_verificar(rig.apoios.transform == rig.apoios.rest, "soco preserva apoio fixo")
	vega.receber_dano()
	_verificar(vega.estado_animacao == "dano" and rig.animacao.current_animation == "dano", "dano interrompe soco no player nativo")
	rig.animacao.advance(.1)
	vega.movimento.pause()
	vega.movimento.custom_step(.1)
	_verificar(vega.visual.modulate.g < .78 and rig.pelve.position.x < rig.pelve.rest.origin.x, "dano conserva feedback magenta e recuo localizado")
	_verificar(rig.apoios.transform == rig.apoios.rest, "reacao ao dano nao desliza botas")
	rig.animacao.advance(.2)
	_verificar(vega.estado_animacao == "repouso", "reacao termina em repouso sem callback de ataque antigo")
	vega.reiniciar()
	_conferir_alternancia(vega)
	vega.reiniciar()
	jogo.call("_limpar_mao")
	jogo.baralho_combate.compra.assign(["direto_hidraulico", "direto_hidraulico", "quebra_chassi"])
	jogo.call("_comprar_cartas", 3)
	jogo.energia = 0
	_selecionar(jogo, "direto_hidraulico")
	jogo.call("_jogar_carta", "inimigo", 0)
	_verificar(vega.estado_animacao == "repouso", "carta sem energia nao dispara soco")
	_verificar(not vega.proximo_braco_distante, "carta invalida nao consome alternancia")
	jogo.energia = 4
	var vida_antes: int = jogo.vida_inimigo
	for esperado: int in [1, 2]:
		_selecionar(jogo, "direto_hidraulico")
		jogo.call("_jogar_carta", "inimigo", 0)
		_verificar(jogo.combo == esperado and rig.combo == esperado and vega.estado_animacao == "soco", "ataques consecutivos atualizam estado e animam")
		_verificar(vega.ultimo_braco_distante == (esperado == 2), "cartas reais alternam proximo e distante sem aguardar animacao")
	_verificar(jogo.vida_inimigo == vida_antes - 8 and jogo.energia == 2, "animacao nao atrasa dano/custo ou bloqueia segunda carta")
	_selecionar(jogo, "quebra_chassi")
	jogo.call("_jogar_carta", "inimigo", 0)
	_verificar(jogo.combo == 0 and rig.combo == 0 and jogo.vida_inimigo == vida_antes - 19 and jogo.energia == 1,
		"Finalizacao consome Combo e preserva dano/bonus/custo")
	var proximo_antes: bool = vega.proximo_braco_distante
	jogo.baralho_combate.compra.assign(["protecao"])
	jogo.call("_comprar_cartas", 1)
	_selecionar(jogo, "protecao")
	jogo.call("_jogar_carta", "jogador", 0)
	_verificar(jogo.energia == 0 and vega.proximo_braco_distante == proximo_antes, "habilidade defensiva nao consome alternancia de socos")
	jogo.estado_inimigo.indice_intencao = 1
	jogo.barreira = 0
	var vida_jogador: int = jogo.vida_jogador
	jogo.call("_executar_intencao_inimigo")
	_verificar(jogo.vida_jogador < vida_jogador and vega.estado_animacao == "dano", "intencao real dispara reacao quando vida recebe dano")
	jogo.movimento_reduzido = true
	jogo.call("_atualizar_interface")
	var repouso: Transform2D = rig.pelve.transform
	vega.socar()
	vega.movimento.pause()
	vega.movimento.custom_step(.12)
	_verificar(rig.pelve.transform == repouso and not rig.animacao.is_playing(), "reduzido so confirma acao sem articulacao ampla")
	vega.movimento.custom_step(.2)
	_verificar(vega.estado_animacao == "repouso", "feedback reduzido conclui")
	var ultimo_reduzido: bool = vega.ultimo_braco_distante
	vega.socar()
	_verificar(vega.ultimo_braco_distante != ultimo_reduzido and not rig.animacao.is_playing(), "reduzido mantem sequencia sem articular os bracos")
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		jogo.call("_sincronizar_viewport_com_janela")
		jogo.call("_layout_hud_combate")
		await get_tree().process_frame
		var solo: float = (vega.composicao.get_global_transform() * rig.sola_tras.global_position).y
		_verificar(absf(solo - jogo.jogador.get_global_rect().end.y) < 14, "apoio continua no piso da arena nas duas resolucoes")
		_verificar((vega.get_node("Sombra") as Control).get_child_count() == 2, "dois contatos com o piso preservados")
		if DisplayServer.get_name() != "headless":
			await _conferir_camadas(jogo, rig)
	jogo.movimento_reduzido = false
	jogo.call("_atualizar_interface")
	vega.socar()
	jogo.call("_iniciar_nova_run")
	await get_tree().process_frame
	await get_tree().create_timer(.7).timeout
	_verificar(not rig.animacao.is_playing() and rig.combo == 0 and vega.estado_animacao == "repouso", "mapa para animacao e nao herda Combo/callbacks")
	_verificar(not vega.proximo_braco_distante, "nova run reinicia sequencia pelo braco proximo")
	jogo.queue_free()
	await get_tree().process_frame
	print("TEST VEGA NATIVA COMBATE: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _selecionar(jogo: Control, id: String) -> void:
	for carta: Button in jogo.mao.get_children():
		if str(carta.get_meta("id_carta")) == id:
			carta.button_pressed = true
			return
	_verificar(false, "carta de teste ausente: " + id)


func _conferir_repouso(vega: VegaCombateNativo, previa: ApoioCorporalNativoV2) -> void:
	var rig: ApoioCorporalNativoV2 = vega.modelo
	var face_interna: bool = vega is VegaAcabamentoProximo and (vega as VegaAcabamentoProximo).corrigir_braco_distante
	var respirar: Animation = rig.animacao.get_animation(&"respirar")
	for nome: StringName in [&"repouso", &"RESET", &"soco", &"soco_distante", &"dano"]:
		var clipe: Animation = rig.animacao.get_animation(nome)
		for trilha: int in range(11):
			var destino: float = respirar.track_get_key_value(trilha, 0)
			_verificar(is_equal_approx(clipe.track_get_key_value(trilha, 0), destino)
				and is_equal_approx(clipe.track_get_key_value(trilha, clipe.track_get_key_count(trilha) - 1), destino),
				"espera/retorno/reset/reduzido compartilham guarda de combate")
	var guarda: Animation = previa.animacao.get_animation(&"guarda")
	for trilha: int in range(11):
		var esperado: float = guarda.track_get_key_value(trilha, 0)
		if face_interna and trilha == 9:
			esperado += VegaAcabamentoProximo.ABERTURA_COTOVELO
		_verificar(is_equal_approx(respirar.track_get_key_value(trilha, 0), esperado),
			"guarda preservada exceto abertura declarada do cotovelo distante na variante")
	var original: Animation = previa.animacao.get_animation(&"soco")
	var atual: Animation = rig.animacao.get_animation(&"soco")
	for trilha: int in original.get_track_count():
		for chave: int in original.track_get_key_count(trilha):
			_verificar(atual.track_get_key_time(trilha, chave) == original.track_get_key_time(trilha, chave), "tempos preservados")
			if trilha < 11 and chave in [0, original.track_get_key_count(trilha) - 1]:
				continue
			var esperado: Variant = original.track_get_key_value(trilha, chave)
			if face_interna and trilha == 9:
				esperado = float(esperado) + VegaAcabamentoProximo.ABERTURA_COTOVELO
			_verificar(atual.track_get_key_value(trilha, chave) == esperado, "preparo/impacto preservados exceto dobra distante declarada")
	rig.definir_pose(&"repouso", true)
	for braco: BracoNativoV2 in [rig.braco_original, rig.braco_distante]:
		var punho_local: Vector2 = rig.to_local(braco.punho.global_position)
		_verificar(punho_local.y > 160 and punho_local.y < 320, "punhos altos protegendo peito/rosto na espera")
		var mao: Sprite2D = braco.punho.get_node("Mao") as Sprite2D
		_verificar(mao.material is ShaderMaterial and mao.modulate == Color.WHITE, "correcao tonal isolada sem tingir fibras ou alterar transparencia")
	var perto: Sprite2D = rig.braco_original.punho.get_node("Mao") as Sprite2D
	var longe: Sprite2D = rig.braco_distante.punho.get_node("Mao") as Sprite2D
	_verificar(perto.material == longe.material, "mesmo acabamento nas duas maos")
	_verificar(perto.position == Vector2(-8, 0) and longe.position == perto.position
		and perto.scale == (Vector2(.13, .13) if face_interna else Vector2(.3696, .3696)), "assentamento preservado e escala da arte declarada")
	if face_interna:
		_verificar((perto.texture as AtlasTexture).atlas == VegaAcabamentoProximo.PUNHO_DORSAL
			and (longe.texture as AtlasTexture).atlas == VegaAcabamentoProximo.PUNHOS
			and perto.scale == longe.scale and is_equal_approx(longe.rotation, PI / 2), "variante usa par de vistas com escala/acabamento comuns")
	else:
		_verificar(longe.texture.resource_path.ends_with("mao_palmar_01.png") and is_equal_approx(longe.rotation, PI / 2)
			and longe.scale == Vector2(.12, .12) and not longe.get_node("MioloLuva").visible, "vista palmar propria substitui dorso espelhado so no combate")
	_verificar(longe.texture.get_image().get_pixel(0, 0).a == 0.0, "sprite palmar tem transparencia real")
	_verificar((previa.braco_original.punho.get_node("Mao") as Sprite2D).material == null, "acabamento nao contamina previa")
	_verificar(not is_equal_approx(rig.cotovelo.rotation, previa.cotovelo.rotation), "repouso novo nao reescreve postura da prova anterior")
	_conferir_respiracao(rig)


func _conferir_alternancia(vega: VegaCombateNativo) -> void:
	var rig: ApoioCorporalNativoV2 = vega.modelo
	var original: Animation = rig.animacao.get_animation(&"soco")
	var distante: Animation = rig.animacao.get_animation(&"soco_distante")
	_verificar(distante.length == original.length and distante.get_track_count() == 14, "segundo soco nativo usa mesmo ciclo corporal")
	for trilha: int in range(11, 14):
		for chave: int in range(5):
			_verificar(distante.track_get_key_value(trilha, chave) == original.track_get_key_value(trilha, chave), "apoio inferior preservado no segundo golpe")
	for lado: int in range(4):
		vega.socar()
		var nome: StringName = &"soco_distante" if lado % 2 == 1 else &"soco"
		_verificar(rig.animacao.current_animation == str(nome) and vega.ultimo_braco_distante == (lado % 2 == 1), "sequencia proximo/distante/proximo/distante")
		rig.animacao.pause()
		for amostra: int in range(57):
			rig.animacao.seek(amostra * .01, true)
			_verificar(rig.apoios.transform == rig.apoios.rest, "nenhum soco move apoios")
			for braco: BracoNativoV2 in [rig.braco_original, rig.braco_distante]:
				_verificar(is_equal_approx(braco.cotovelo.position.length(), 128.06041074)
					and is_equal_approx(braco.punho.position.length(), 133.9084538), "alternancia nao alonga segmentos")
		rig.animacao.seek(.2, true)
		var punho: Bone2D = rig.braco_distante.punho if lado % 2 == 1 else rig.punho
		var defesa: Bone2D = rig.punho if lado % 2 == 1 else rig.braco_distante.punho
		_verificar(rig.to_local(punho.global_position).x > 430 and rig.to_local(defesa.global_position).y < 320, "braco escolhido estende, outro protege rosto")
		rig.animacao.play(nome, 0)
		rig.animacao.advance(.6)
		_verificar(vega.estado_animacao == "repouso" and rig.animacao.current_animation == "respirar", "ambos os socos retornam a guarda viva")
	vega.socar()
	rig.animacao.advance(.15)
	var antes: Array[Transform2D] = [rig.pelve.transform, rig.ombro.transform, rig.braco_distante.punho.transform]
	vega.socar()
	rig.animacao.advance(0)
	_verificar(rig.pelve.transform.is_equal_approx(antes[0]) and rig.ombro.transform.is_equal_approx(antes[1])
		and rig.braco_distante.punho.transform.is_equal_approx(antes[2]), "troca rapida de braco captura pose atual sem salto")
	vega.receber_dano()
	rig.animacao.advance(.3)
	_verificar(vega.estado_animacao == "repouso", "dano interrompe soco distante e retorna sem callback antigo")


func _conferir_respiracao(rig: ApoioCorporalNativoV2) -> void:
	rig.animacao.play(&"respirar", 0)
	rig.animacao.pause()
	rig.animacao.seek(0, true)
	var inicio: Transform2D = rig.tronco.transform
	var punhos: Array[Vector2] = [rig.to_local(rig.punho.global_position), rig.to_local(rig.braco_distante.punho.global_position)]
	var maior: float = 0.0
	for amostra: int in range(49):
		rig.animacao.seek(amostra * .05, true)
		_verificar(rig.pelve.transform == rig.pelve.rest and rig.apoios.transform == rig.apoios.rest,
			"respiracao nao faz quadril/pes flutuarem")
		for lado: int in range(2):
			var braco: BracoNativoV2 = rig.braco_original if lado == 0 else rig.braco_distante
			var posicao: Vector2 = rig.to_local(braco.punho.global_position)
			maior = maxf(maior, posicao.distance_to(punhos[lado]))
			_verificar(posicao.y > 160 and posicao.y < 320 and posicao.distance_to(punhos[lado]) < 9,
				"respiracao move guarda discretamente sem derrubar ou esticar bracos")
	_verificar(maior > 1.0, "guarda tem respiro perceptivel, nao pose congelada")
	_verificar(rig.tronco.transform.is_equal_approx(inicio)
		and rig.to_local(rig.punho.global_position).is_equal_approx(punhos[0])
		and rig.to_local(rig.braco_distante.punho.global_position).is_equal_approx(punhos[1]), "ciclo de 2.4 segundos fecha sem salto")
	rig.definir_pose(&"repouso", true)


func _conferir_camadas(jogo: Control, rig: ApoioCorporalNativoV2) -> void:
	# Um painel de UI em z=2 precisa cobrir inclusive as peças internas em z alto.
	var painel: ColorRect = ColorRect.new()
	painel.color = Color(.1, .9, .2)
	painel.z_index = 2
	painel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vega: VegaCombateNativo = jogo.vega_animada as VegaCombateNativo
	painel.position = vega.composicao.get_global_transform() * rig.to_global(Vector2(320, 420)) - Vector2(8, 8)
	painel.size = Vector2(16, 16)
	jogo.add_child(painel)
	await RenderingServer.frame_post_draw
	var desenho: Image = rig.get_viewport().get_texture().get_image()
	var torso: Vector2 = rig.to_global(Vector2(320, 420))
	_verificar(desenho.get_pixel(int(torso.x), int(torso.y)).a > .8, "corpo permanece visivel na composicao isolada")
	var imagem: Image = get_viewport().get_texture().get_image()
	var p: Vector2 = painel.get_global_rect().get_center()
	var cor: Color = imagem.get_pixel(int(p.x), int(p.y))
	_verificar(cor.g > .8 and cor.r < .2 and cor.b < .3, "composicao transparente mantem UI acima das camadas internas do personagem")
	painel.queue_free()
	await get_tree().process_frame
