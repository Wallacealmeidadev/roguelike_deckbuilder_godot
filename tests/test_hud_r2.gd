extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var cena: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Control = cena.instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	jogo.call("_iniciar_combate_por_id", "drone_seguranca", false)
	await get_tree().process_frame

	for item in [
		["RotaIcone", "rota.svg"],
		["EnergiaIcone", "energia.svg"],
		["IntencaoIcone", "hud_hq/icones/ataque.svg"],
		["EstadosInimigoBarreiraIcone", "barreira.svg"],
		["BarreiraIcone", "barreira.svg"],
		["ComboIcone", "combo.svg"],
		["ReliquiaIcone", "reliquia.svg"]
	]:
		var controle: TextureRect = jogo.get_node(str(item[0])) as TextureRect
		_verificar(
			str(controle.texture.resource_path).ends_with(str(item[1])),
			"%s precisa usar o SVG R2 %s" % [str(item[0]), str(item[1])]
		)
	for nome: String in ["CompraIcone", "DescarteIcone"]:
		_verificar((jogo.get_node(nome) as TextureRect).texture != null, "%s deve manter simbolo de pilha" % nome)

	for nome in ["VidaJogadorIcone", "VidaJogadorLabel", "VidaInimigoIcone"]:
		_verificar(not (jogo.get_node(nome) as Control).visible, "%s nao deve ficar persistente no R2" % nome)
	_verificar((jogo.get_node("VidaInimigoLabel") as Control).visible, "o inimigo deve mostrar o valor atual/maximo junto da barra fina")
	for nome in ["VidaJogadorMoldura", "VidaInimigoMoldura"]:
		_verificar(not (jogo.get_node(nome) as Control).visible, "%s nao deve permanecer no R2" % nome)
	_verificar((jogo.get_node("VidaJogadorBar") as Control).visible, "a barra de Vida do jogador deve permanecer visivel")
	_verificar((jogo.get_node("VidaInimigoBar") as Control).visible, "a barra de Vida do inimigo deve permanecer visivel")
	var intencao_icone: TextureRect = jogo.get_node("IntencaoIcone") as TextureRect
	var intencao_valor: Label = jogo.get_node("IntencaoValorVisualLabel") as Label
	var cor_intencao: Color = intencao_valor.get_theme_color("font_color")
	var luminancia_intencao: float = cor_intencao.r * 0.2126 + cor_intencao.g * 0.7152 + cor_intencao.b * 0.0722
	_verificar(luminancia_intencao >= 0.70, "valor da intenção precisa ter contraste claro")
	var retangulo_icone: Rect2 = intencao_icone.get_global_rect()
	var retangulo_valor: Rect2 = intencao_valor.get_global_rect()
	var grupo_minimo: Vector2 = Vector2(
		minf(retangulo_icone.position.x, retangulo_valor.position.x),
		minf(retangulo_icone.position.y, retangulo_valor.position.y)
	)
	var grupo_maximo: Vector2 = Vector2(
		maxf(retangulo_icone.end.x, retangulo_valor.end.x),
		maxf(retangulo_icone.end.y, retangulo_valor.end.y)
	)
	_verificar((grupo_maximo - grupo_minimo).x <= 220.0 and (grupo_maximo - grupo_minimo).y <= 72.0, "símbolo e valor da intenção precisam formar um grupo compacto")
	_verificar(intencao_valor.text.contains("3"), "o valor da intenção deve continuar vindo do encontro real")

	var inimigo: InimigoCombate = jogo.get("estado_inimigo") as InimigoCombate
	inimigo.indice_intencao = 1
	jogo.call("_atualizar_interface")
	await get_tree().process_frame
	_verificar(str(intencao_icone.texture.resource_path).ends_with("hud_hq/barreira.svg"), "a intencao de defesa deve usar o simbolo HQ correto")
	_verificar(intencao_valor.text.contains("6"), "a intenção de defesa deve manter seu valor real")
	inimigo.indice_intencao = 0
	jogo.call("_atualizar_interface")
	await get_tree().process_frame
	for nome in ["VidaJogadorBar", "VidaInimigoBar"]:
		var barra: ProgressBar = jogo.get_node(nome) as ProgressBar
		var trilho: StyleBox = barra.get_theme_stylebox("background")
		_verificar(trilho is StyleBoxFlat, "%s deve usar trilho simples" % nome)
		var preenchimento: StyleBox = barra.get_theme_stylebox("fill")
		_verificar(preenchimento is StyleBoxFlat, "%s deve usar preenchimento simples" % nome)
	for nome in ["CompraPainel", "DescartePainel"]:
		var painel: Panel = jogo.get_node(nome) as Panel
		var estilo: StyleBox = painel.get_theme_stylebox("panel")
		_verificar(estilo is StyleBoxTexture or estilo is StyleBoxFlat, "%s deve usar moldura visual" % nome)
	_verificar((jogo.get_node("IntencaoPainel") as Panel).get_theme_stylebox("panel") is StyleBoxEmpty and jogo.has_node("Alvo/ModuloInimigo"), "a intenção precisa usar a moldura ilustrada do alvo")
	_verificar((jogo.get_node("EnergiaPainel") as Panel).get_theme_stylebox("panel") is StyleBoxEmpty, "Energia nao deve desenhar a moldura antiga")
	_verificar(not (jogo.get_node("EnergiaVisualLabel") as Label).text.contains("Energia"), "Energia nao deve repetir o titulo")
	var energia_icone: TextureRect = jogo.get_node("EnergiaIcone") as TextureRect
	var energia_valor: Label = jogo.get_node("EnergiaVisualLabel") as Label
	_verificar((jogo.get_node("EnergiaPainel") as Control).get_global_rect().encloses(energia_valor.get_global_rect()), "valor da Energia deve ficar dentro da caixa do kit")
	_verificar(energia_valor.text == "4/4", "Energia cheia deve mostrar atual/maximo")
	jogo.set("energia", 2)
	jogo.call("_atualizar_interface")
	_verificar(energia_valor.text == "2/4", "Energia parcial deve manter contagem interna")
	var marcadores: Control = (jogo.get_node("EnergiaPainel/MolduraNeon") as Control)
	_verificar(int(marcadores.get("energia_atual")) == 2, "marcadores neon de Energia devem acompanhar a carga parcial")
	jogo.set("energia", 0)
	jogo.call("_atualizar_interface")
	_verificar(energia_valor.text == "0/4", "Energia vazia deve continuar legivel")
	_verificar(int(marcadores.get("energia_atual")) == 0, "marcadores neon de Energia devem zerar sem carga")
	jogo.set("energia", 4)
	jogo.set("combo", 100)
	jogo.call("_atualizar_interface")
	_verificar((jogo.get_node("ComboLabel") as Label).text == "100", "Combo alto nao deve ter denominador")
	_verificar((jogo.get_node("StatsJogadorPanel/ModuloCombo") as Control).get_global_rect().encloses((jogo.get_node("ComboLabel") as Label).get_global_rect()), "Combo deve permanecer dentro do medidor ilustrado")
	jogo.set("combo", 0)
	jogo.call("_atualizar_interface")
	_verificar(
		(jogo.get_node("CompraLabel") as Label).text == str(jogo.get("pilha_compra").size()),
		"Compra deve exibir apenas a contagem"
	)
	_verificar(
		(jogo.get_node("DescarteLabel") as Label).text == str(jogo.get("pilha_descarte").size()),
		"Descarte deve exibir apenas a contagem"
	)
	_verificar((jogo.get_node("CompraPainel") as Control).get_global_rect().encloses((jogo.get_node("CompraLabel") as Label).get_global_rect()), "Compra deve ter contagem dentro da caixa do kit")
	_verificar((jogo.get_node("DescartePainel") as Control).get_global_rect().encloses((jogo.get_node("DescarteLabel") as Label).get_global_rect()), "Descarte deve ter contagem dentro da caixa do kit")
	var compra_alta: Array[String] = []
	var descarte_alto: Array[String] = []
	for indice in range(12):
		compra_alta.append("golpe")
		descarte_alto.append("protecao")
	jogo.set("pilha_compra", compra_alta)
	jogo.set("pilha_descarte", descarte_alto)
	jogo.call("_atualizar_interface")
	_verificar((jogo.get_node("CompraLabel") as Label).text == "12", "Compra deve atualizar contagem de dois digitos")
	_verificar((jogo.get_node("DescarteLabel") as Label).text == "12", "Descarte deve atualizar contagem de dois digitos")
	jogo.set("pilha_compra", [] as Array[String])
	jogo.set("pilha_descarte", [] as Array[String])
	jogo.call("_atualizar_interface")
	_verificar((jogo.get_node("CompraLabel") as Label).text == "0", "Compra vazia deve continuar legivel")
	_verificar((jogo.get_node("DescarteLabel") as Label).text == "0", "Descarte vazio deve continuar legivel")
	_verificar(not (jogo.get_node("AcaoLabel") as Label).visible, "mensagens de acao nao devem ficar permanentes no repouso")
	_verificar((jogo.get_node("StatsJogadorPanel/ModuloCombo") as Control).visible, "Combo deve permanecer disponivel no repouso")

	jogo.set("barreira", 0)
	jogo.call("_atualizar_interface")
	_verificar((jogo.get_node("StatsJogadorPanel/ModuloBarreira") as Control).visible, "Barreira deve permanecer legivel no HUD")
	_verificar((jogo.get_node("BarreiraLabel") as Control).visible, "contador de Barreira deve permanecer legivel no HUD basico")
	_verificar((jogo.get_node("StatsJogadorPanel/ModuloCombo") as Control).visible, "Combo deve sobreviver a Barreira zerada")

	var inspecao: PanelContainer = jogo.get_node("HudInspecao") as PanelContainer
	var inspecao_texto: Label = jogo.get_node("HudInspecao/Texto") as Label
	_verificar(inspecao != null, "o HUD precisa de um painel de inspeção")
	_verificar((jogo.get_node("IntencaoPainel") as Control).focus_mode != Control.FOCUS_NONE, "intenção deve aceitar foco")
	_verificar((jogo.get_node("EnergiaPainel") as Control).focus_mode != Control.FOCUS_NONE, "Energia deve aceitar foco")

	jogo.call("_mostrar_inspecao_hud", jogo.get_node("IntencaoPainel"))
	await get_tree().process_frame
	_verificar(inspecao.visible, "a inspeção deve aparecer ao focar a intenção")
	_verificar(inspecao_texto.text.contains("Rajada"), "a inspeção deve explicar a intenção real")
	_verificar(inspecao_texto.get_visible_line_count() == inspecao_texto.get_line_count() and inspecao_texto.get_line_count() * inspecao_texto.get_theme_font("font").get_height(inspecao_texto.get_theme_font_size("font_size")) <= inspecao_texto.size.y, "a inspeção compacta precisa mostrar o texto completo")
	_verificar(_esta_dentro_da_viewport(inspecao), "a inspeção deve permanecer dentro da viewport: %s em %s" % [inspecao.get_global_rect(), get_viewport().get_visible_rect()])
	_verificar(absf(inspecao.get_global_rect().get_center().x - (jogo.get_node("IntencaoPainel") as Control).get_global_rect().get_center().x) < 360.0, "a inspeção deve permanecer proxima da intenção")
	jogo.call("_ao_sair_inspecao_hud", jogo.get_node("IntencaoPainel"))
	_verificar(not inspecao.visible, "a saída da inspeção deve funcionar para Panels")
	jogo.call("_mostrar_inspecao_hud", jogo.get_node("IntencaoPainel"))
	jogo.call("_mostrar_inspecao_hud", inspecao)
	_verificar(not inspecao.visible, "inspeção sem conteúdo deve ficar oculta")
	_verificar(jogo.get("hud_inspecao").controle_atual == null, "inspeção vazia não deve manter controle ativo")

	jogo.call("_animar_faixa_turno")
	await get_tree().create_timer(0.9).timeout
	_verificar(not (jogo.get_node("TurnoFaixa") as Control).visible, "anuncio de turno deve ser transitório")
	_verificar(not (jogo.get_node("TurnoNumeroPainel") as Control).visible, "contador do anuncio deve ser transitório")

	var vida_antes: int = int(jogo.get("vida_inimigo"))
	jogo.call("_causar_dano_no_inimigo", 3)
	await get_tree().process_frame
	var dano: Label = jogo.get_node("DanoFeedbackLabel") as Label
	_verificar(int(jogo.get("vida_inimigo")) == vida_antes - 3, "o feedback nao pode alterar a regra de dano")
	_verificar(dano.visible, "o dano deve ter feedback visual temporario")
	_verificar(dano.text.contains("-3"), "o feedback deve mostrar o dano recente")
	jogo.call("_mostrar_feedback_dano", 1, 0)
	_verificar(
		is_equal_approx(dano.position.y, (jogo.get("_dano_feedback_posicao_base") as Vector2).y),
		"feedbacks sucessivos devem reutilizar a posição base"
	)

	jogo.queue_free()
	if falhas == 0:
		print("OK: HUD R2")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _esta_dentro_da_viewport(controle: Control) -> bool:
	return get_viewport().get_visible_rect().encloses(controle.get_global_rect())


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
