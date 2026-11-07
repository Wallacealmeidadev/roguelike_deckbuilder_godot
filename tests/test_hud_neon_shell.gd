extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	await get_tree().process_frame

	_verificar(not jogo.has_node("FeedbackRecursosHQ"), "feedback antigo nao deve permanecer ativo")
	_verificar(jogo.has_node("FeedbackRecursosNeon"), "feedback deve pertencer a camada neon")
	for caminho: String in ["TopoCombate", "StatsJogadorPanel", "EnergiaPainel", "MaoDock"]:
		var painel: Panel = jogo.get_node(caminho) as Panel
		_verificar(painel.get_theme_stylebox("panel") is StyleBoxEmpty, "%s nao deve desenhar shell sob a placa neon" % caminho)
	for caminho: String in ["EnergiaPainel/MolduraHQ", "StatsJogadorPanel/MolduraHQ", "EnergiaPainel/Marcadores", "EncerrarTurno/HoverHQ"]:
		_verificar(not jogo.has_node(caminho), "%s ainda pertence ao shell antigo" % caminho)
	for caminho: String in ["BaralhoOverlay", "ConfiguracoesOverlay", "HudInspecao"]:
		var estilo: StyleBox = (jogo.get_node(caminho) as Control).get_theme_stylebox("panel")
		_verificar(estilo is StyleBoxTexture and str((estilo as StyleBoxTexture).texture.resource_path).contains("hud_neon"), "%s precisa usar moldura neon" % caminho)
	for par: Array in [["EnergiaVisualLabel", "EnergiaPainel"], ["CompraIcone", "CompraPainel"], ["CompraLabel", "CompraPainel"], ["DescarteIcone", "DescartePainel"], ["DescarteLabel", "DescartePainel"]]:
		var leitura: Control = jogo.get_node(par[0]) as Control
		var painel_base: Control = jogo.get_node(par[1]) as Control
		_verificar(leitura.z_index > painel_base.z_index, "%s precisa ser legivel acima da placa" % par[0])
	_verificar((jogo.get_node("TurnoFaixa") as TextureRect).texture == null, "anuncio de turno nao deve usar faixa antiga")
	_verificar(jogo.has_node("TurnoFaixa/PlacaTurnoNeon"), "anuncio de turno precisa de placa neon")
	_verificar(jogo.has_node("EncerrarTurno/RealceNeon"), "acao principal precisa de realce animado da nova HUD")
	if jogo.has_node("EncerrarTurno/RealceNeon"):
		var encerrar: Button = jogo.get_node("EncerrarTurno") as Button
		var realce: Control = encerrar.get_node("RealceNeon") as Control
		encerrar.grab_focus()
		await get_tree().create_timer(0.2).timeout
		_verificar(realce.get("intensidade") > 0.9, "foco por teclado precisa acender o realce neon")
		encerrar.disabled = true
		await get_tree().create_timer(0.2).timeout
		_verificar(realce.get("intensidade") < 0.1, "acao desabilitada precisa apagar o realce neon")

	var energia_visual: Control = jogo.get_node("EnergiaPainel/MolduraNeon") as Control
	var stats_visual: Control = jogo.get_node("StatsJogadorPanel/MolduraNeon") as Control
	var animacao_combo: AnimationPlayer = jogo.get_node("AnimacaoComboHUD") as AnimationPlayer
	var animacao_barreira: AnimationPlayer = jogo.get_node("AnimacaoBarreiraHUD") as AnimationPlayer
	jogo.call("_limpar_mao")
	var compra: Array[String] = ["direto_hidraulico", "quebra_chassi"]
	jogo.get("baralho_combate").compra.assign(compra)
	jogo.call("_comprar_cartas", 2)
	_jogar(jogo, "direto_hidraulico")
	_verificar(int(jogo.get("energia")) == 3 and int(jogo.get("combo")) == 1 and int(jogo.get("barreira")) == 2, "feedback nao pode alterar regras de recursos")
	var dano_visual: Label = jogo.get_node("DanoFeedbackLabel") as Label
	var alvo_visual: Control = jogo.get_node("Alvo") as Control
	_verificar(dano_visual.visible, "numero de dano deve acompanhar a confirmacao da carta")
	var pulso_energia: Variant = energia_visual.get("impacto_energia")
	var pulso_combo: Variant = stats_visual.get("impacto_combo")
	var pulso_barreira: Variant = stats_visual.get("impacto_barreira")
	_verificar(pulso_energia is float and pulso_energia > 0.0, "gasto precisa iluminar a placa neon de Energia")
	_verificar(pulso_combo is float and pulso_combo > 0.0, "Combo precisa iluminar a placa neon")
	_verificar(pulso_barreira is float and pulso_barreira > 0.0, "Barreira precisa iluminar a placa neon")
	_verificar(animacao_combo.current_animation == "combo_ganho" and animacao_barreira.current_animation == "barreira_ganho", "ganho de Combo e Barreira deve animar os dois módulos simultaneamente")
	_verificar((jogo.get_node("BarreiraIcone") as Control).visible, "escudo precisa estar visível junto do número de Barreira")
	_verificar(not jogo.has_node("StatsJogadorPanel/LegendaBarreiraNeon"), "Barreira deve usar escudo em vez do texto redundante")
	(jogo.get_node("StatsJogadorPanel/ModuloBarreira") as Control).mouse_entered.emit()
	_verificar((jogo.get_node("HudInspecao/Texto") as Label).text.contains("Absorve dano"), "módulo visível de Barreira deve explicar a defesa por inspeção")
	(jogo.get_node("HudInspecao") as Control).hide()
	_verificar(dano_visual.visible and dano_visual.text.contains("-4"), "carta jogada precisa mostrar o dano real proximo do drone")
	_verificar(dano_visual.get_theme_font_size("font_size") >= 36, "numero de impacto deve ter leitura de acao")
	var sprite_inimigo: Control = alvo_visual.get_node("DroneCampoSprite") as Control
	_verificar(dano_visual.get_global_rect().intersects(sprite_inimigo.get_global_rect().grow(48.0)), "numero de dano deve surgir junto do drone, nao sobre os controles")
	_verificar(alvo_visual.modulate != Color.WHITE, "carta jogada precisa atingir visualmente o inimigo")
	_jogar(jogo, "quebra_chassi")
	_verificar(int(jogo.get("combo")) == 0, "Finalizacao precisa consumir o Combo real")
	pulso_combo = stats_visual.get("impacto_combo")
	_verificar(pulso_combo is float and pulso_combo > 0.0, "Finalizacao precisa acionar a placa neon")
	_verificar(animacao_combo.current_animation == "combo_consumo" and bool(stats_visual.get("consumindo_combo")), "Finalização deve substituir a carga pela descarga")
	await get_tree().create_timer(0.08).timeout
	_verificar(float(stats_visual.get("progresso_descarga")) > 0.0 and float(stats_visual.get("progresso_descarga")) < 1.0, "descarga deve percorrer os segmentos enquanto o Combo real já está zerado")
	await get_tree().create_timer(0.7).timeout
	pulso_energia = energia_visual.get("impacto_energia")
	pulso_combo = stats_visual.get("impacto_combo")
	_verificar(pulso_energia is float and is_zero_approx(pulso_energia), "pulso de Energia deve voltar ao repouso")
	_verificar(pulso_combo is float and is_zero_approx(pulso_combo), "pulso de Combo deve voltar ao repouso")
	jogo.set("movimento_reduzido", true)
	jogo.set("combo", 25)
	jogo.set("barreira", 40)
	jogo.call("_atualizar_interface")
	_verificar(int(jogo.get("combo")) == 25 and int(jogo.get("barreira")) == 40, "capacidade visual dos medidores não deve impor teto aos recursos")
	_verificar(not animacao_combo.is_playing() and not animacao_barreira.is_playing(), "movimento reduzido deve evitar as sequências de varredura")
	_verificar(is_equal_approx(float(stats_visual.get("combo_visual")), 25.0) and is_equal_approx(float(stats_visual.get("barreira_visual")), 40.0), "modo reduzido deve mostrar os recursos finais imediatamente")
	jogo.set("movimento_reduzido", false)

	jogo.call("_iniciar_combate_por_id", "caranguejo_sucata", false)
	jogo.call("_executar_intencao_inimigo")
	_verificar(dano_visual.visible and dano_visual.position.x < jogo.get_viewport().get_visible_rect().size.x * 0.5, "dano recebido precisa aparecer junto da Vega, nao no inimigo")

	jogo.queue_free()
	if falhas == 0:
		print("OK: shell e feedback neon do combate")
	get_tree().quit(0 if falhas == 0 else 1)


func _jogar(jogo: Control, id_carta: String) -> void:
	for no: Node in jogo.get_node("Mao").get_children():
		var carta: Button = no as Button
		if str(carta.get_meta("id_carta")) == id_carta:
			carta.button_pressed = true
			jogo.call("_jogar_carta", "inimigo", 0)
			return
	_verificar(false, "carta ausente na fixture: %s" % id_carta)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
