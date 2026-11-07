extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("VEGA COMBATE V2: %s" % mensagem)


func _executar() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	# Regressão explícita do modelo anterior; o padrão ativo tem teste nativo próprio.
	jogo.cena_apresentacao_vega = preload("res://vega_animada/combate_v2/vega_combate.tscn")
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	var vega: VegaCombateV2 = jogo.vega_animada as VegaCombateV2
	_verificar(vega != null, "jogo precisa instanciar a cena v2")
	if vega == null:
		get_tree().quit(1)
		return
	_verificar(not vega.is_processing(), "modelo nao anima por tras do mapa")
	jogo.call("_iniciar_combate_por_id", "drone_carga", false)
	await get_tree().process_frame
	var modelo: ModeloVegaCombateV2 = vega.modelo
	_verificar(is_zero_approx(modelo.prontidao), "repouso inicial nao deve manter guarda elevada")
	for braco: BracoArticuladoV2 in [modelo.braco_ataque, modelo.braco_guarda]:
		_conferir_mao_em_repouso(modelo, braco)
	_verificar(BracoArticuladoV2.VETOR_SUPERIOR.length() / BracoArticuladoV2.VETOR_INFERIOR.length() > .9, "biceps nao pode ser comprimido para dois tercos do antebraco")
	_verificar(not vega.has_node("Visual/Arte"), "placeholder antigo nao pode existir como camada ativa")
	_verificar(modelo.corpo.texture.get_image().get_pixel(0, 0).a == 0, "atlas exige alfa real")
	jogo.movimento_reduzido = true
	jogo.call("_atualizar_interface")
	var placas: Array[Vector2] = []
	for placa: Sprite2D in modelo.braco_ataque.placas:
		placas.append(placa.scale)
	for valor: int in [0, 1, 5, 10, 11, 100]:
		jogo.combo = valor
		jogo.call("_atualizar_interface")
		_verificar(modelo.braco_ataque.combo == valor and modelo.braco_guarda.combo == valor, "Combo real chega aos dois bracos")
		_verificar(is_equal_approx(modelo.braco_ataque.tensao_combo, BracoV2Prova.tensao_por_combo(valor)), "progressao real preserva os dez passos")
		_verificar(is_zero_approx(modelo.prontidao), "Combo altera volume, nao prende personagem na guarda")
		for braco: BracoArticuladoV2 in [modelo.braco_ataque, modelo.braco_guarda]:
			_conferir_mao_em_repouso(modelo, braco)
		for indice: int in placas.size():
			_verificar(modelo.braco_ataque.placas[indice].scale == placas[indice], "Combo nao deforma placas rigidas")
	modelo.posar_prontidao(1)
	for pose: float in [-.5, 0.0, .25, .5, 1.0]:
		modelo.posar_golpe(pose)
		for braco: BracoArticuladoV2 in [modelo.braco_ataque, modelo.braco_guarda]:
			var fator: float = braco.global_transform.x.length()
			var superior: float = braco.ombro.global_position.distance_to(braco.articulacao_cotovelo.global_position)
			var inferior: float = braco.articulacao_cotovelo.global_position.distance_to(braco.punho.global_position)
			_verificar(absf(superior - BracoArticuladoV2.VETOR_SUPERIOR.length() * fator) < .01, "umero projetado nao estica durante soco")
			_verificar(absf(inferior - BracoArticuladoV2.VETOR_INFERIOR.length() * fator) < .01, "antebraco nao estica durante soco")
			_verificar(braco.mao.global_position.distance_to(braco.punho.global_position) < .01, "punho nao se separa da mao")
			_verificar(braco.punho.global_position.distance_to(braco.to_global(braco.alvo_local)) < .1, "solver alcanca o destino limitado sem descolar cotovelo")
		_conferir_pes(modelo)
	modelo.posar_golpe(0)
	jogo.call("_alternar_movimento")
	_verificar(not jogo.movimento_reduzido and vega.is_processing(), "configuracao reconecta modo suave sem perder Combo")
	jogo.combo = 0
	jogo.call("_atualizar_interface")
	vega.socar()
	vega.movimento.pause()
	vega.movimento.custom_step(.15)
	var pose_antes: float = modelo.golpe
	var movimento_anterior: Tween = vega.movimento
	vega.socar()
	_verificar(is_equal_approx(modelo.golpe, pose_antes) and not movimento_anterior.is_valid(), "ataque rapido substitui do ponto atual")
	vega.movimento.pause()
	vega.movimento.custom_step(.2)
	_verificar(modelo.golpe > .9 and is_equal_approx(modelo.prontidao, 1.0), "ataque chega a extensao com guarda ativa")
	var alcance: float = modelo.to_local(modelo.braco_ataque.punho.global_position).distance_to(modelo.to_local(modelo.braco_ataque.ombro.global_position))
	var comprimento: float = (BracoArticuladoV2.VETOR_SUPERIOR.length() + BracoArticuladoV2.VETOR_INFERIOR.length()) * absf(modelo.braco_ataque.scale.x)
	_verificar(alcance / comprimento > .94 and alcance <= comprimento, "soco usa o alcance calibrado sem alongar membros para satisfazer distancia absoluta")
	vega.receber_dano()
	_verificar(vega.estado_animacao == "dano", "dano interrompe ataque")
	vega.movimento.pause()
	vega.movimento.custom_step(.1)
	_verificar(vega.visual.modulate.g < .78, "dano conserva feedback magenta")
	_conferir_pes(modelo)
	vega.movimento.custom_step(.2)
	_verificar(vega.estado_animacao == "repouso" and is_zero_approx(modelo.golpe) and is_zero_approx(modelo.recuo) and is_zero_approx(modelo.prontidao), "retorno limpa pose sem callback antigo")
	vega.socar()
	vega.movimento.pause()
	vega.movimento.custom_step(.36)
	_verificar(modelo.prontidao > .9 and absf(modelo.golpe) < .01, "soco recolhe antes de baixar guarda")
	vega.movimento.custom_step(.1)
	var guarda_antes: float = modelo.prontidao
	_verificar(guarda_antes > 0 and guarda_antes < 1, "guarda relaxa progressivamente depois do golpe")
	vega.socar()
	_verificar(is_equal_approx(modelo.prontidao, guarda_antes), "novo ataque retoma altura dos bracos sem teleporte")
	vega.movimento.pause()
	vega.movimento.custom_step(.6)
	_verificar(vega.estado_animacao == "repouso" and is_zero_approx(modelo.prontidao), "soco completo volta aos bracos baixos")
	jogo.call("_limpar_mao")
	jogo.baralho_combate.compra.assign(["direto_hidraulico", "direto_hidraulico", "quebra_chassi"])
	jogo.call("_comprar_cartas", 3)
	jogo.energia = 4
	var vida_antes: int = jogo.vida_inimigo
	for esperado: int in [1, 2]:
		_selecionar(jogo, "direto_hidraulico")
		jogo.call("_jogar_carta", "inimigo", 0)
		_verificar(jogo.combo == esperado and modelo.braco_ataque.combo == esperado, "Direto real atualiza recurso e apresentacao")
		_verificar(vega.estado_animacao == "soco", "carta valida dispara articulacao")
	_verificar(jogo.vida_inimigo == vida_antes - 8 and jogo.energia == 2, "animacao nao bloqueia segundo ataque nem muda dano/custo")
	_selecionar(jogo, "quebra_chassi")
	jogo.call("_jogar_carta", "inimigo", 0)
	_verificar(jogo.combo == 0 and modelo.braco_ataque.combo == 0 and modelo.braco_guarda.combo == 0, "Finalizacao real zera tensao nos dois bracos")
	_verificar(jogo.vida_inimigo == vida_antes - 19 and jogo.energia == 1, "Finalizacao preserva bonus e custo")
	jogo.call("_alternar_movimento")
	vega.socar()
	vega.movimento.pause()
	vega.movimento.custom_step(.12)
	_verificar(is_zero_approx(modelo.golpe) and is_zero_approx(modelo.recuo) and is_zero_approx(modelo.prontidao), "modo reduzido nao move articulacoes amplamente")
	vega.movimento.custom_step(.3)
	_verificar(vega.estado_animacao == "repouso", "feedback reduzido termina")
	vega.socar()
	jogo.call("_iniciar_nova_run")
	await get_tree().process_frame
	_verificar(not vega.is_processing() and vega.estado_animacao == "repouso" and is_zero_approx(modelo.prontidao), "mapa encerra movimento sem callback residual")
	_verificar(modelo.braco_ataque.combo == 0 and modelo.braco_guarda.combo == 0, "run nova nao herda tensao")
	jogo.queue_free()
	await get_tree().process_frame
	print("VEGA COMBATE V2: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _conferir_pes(modelo: ModeloVegaCombateV2) -> void:
	var erro_uv: float = 0.0
	for indice: int in modelo.corpo.polygon.size():
		var original: Vector2 = modelo._pontos_originais[indice]
		erro_uv = maxf(erro_uv, original.distance_to(modelo.corpo.uv[indice] - ModeloVegaCombateV2.FONTE_CORPO.position))
		if original.y > 450:
			_verificar(modelo.corpo.polygon[indice] == original, "pernas e pes ficam apoiados, sem escala global")
	print("VEGA COMBATE V2: erro maximo do round-trip UV = %.8f px" % erro_uv)


func _conferir_mao_em_repouso(modelo: ModeloVegaCombateV2, braco: BracoArticuladoV2) -> void:
	# Limites desta montagem, não proporções anatômicas universais.
	# Quadril y=380, joelho mais alto aproximadamente y=600 no corpo-base.
	var punho: Vector2 = modelo.to_local(braco.punho.global_position)
	_verificar(punho.y >= 400 and punho.y <= 470, "pulso de repouso fica junto da parte superior da coxa, nao proximo ao joelho")
	var area: Rect2 = braco.mao.get_rect()
	var limite_inferior: float = -INF
	for canto: Vector2 in [area.position, area.position + Vector2(area.size.x, 0), area.end, area.position + Vector2(0, area.size.y)]:
		limite_inferior = maxf(limite_inferior, modelo.to_local(braco.mao.to_global(canto)).y)
	_verificar(limite_inferior <= 550, "ate o retangulo conservador da mao deve terminar antes da regiao do joelho")
	var comprimento_mao: float = Vector2(162, -217).length() * braco.mao.global_transform.x.length()
	var comprimento_antebraco: float = braco.articulacao_cotovelo.global_position.distance_to(braco.punho.global_position)
	var proporcao_mao: float = comprimento_mao / comprimento_antebraco
	_verificar(proporcao_mao >= .65 and proporcao_mao <= .85, "punho fechado com cuff nao pode parecer miniatura diante do antebraco")


func _selecionar(jogo: Control, id: String) -> void:
	for carta: Button in jogo.mao.get_children():
		if str(carta.get_meta("id_carta")) == id:
			carta.button_pressed = true
			return
	_verificar(false, "carta de teste ausente: " + id)
