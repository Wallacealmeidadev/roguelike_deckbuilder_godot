extends RefCounted
## Adapta a cena existente ao conceito neon sem possuir estado ou regras da run.

const PLACA: Script = preload("res://hud_neon/placa.gd")
const REALCE: Script = preload("res://hud_neon/realce.gd")
const BARRA_VIDA: Script = preload("res://hud_neon/barra_vida.gd")
const CIANO: Color = Color("22e8f5")
const ROSA: Color = Color("f322b5")
const VIOLETA: Color = Color("ab54f5")
const BRANCO: Color = Color("f3f5ff")
const MUTED: Color = Color("9eb7ce")


static func preparar(raiz: Node) -> void:
	var tema: Theme = (raiz as Control).theme.duplicate() as Theme
	tema.set_stylebox("panel", "TooltipPanel", preload("res://hud_neon/tooltip.tres"))
	tema.set_color("font_color", "TooltipLabel", BRANCO)
	tema.set_font("font", "TooltipLabel", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Regular.ttf"))
	tema.set_font_size("font_size", "TooltipLabel", 15)
	(raiz as Control).theme = tema
	for caminho: String in ["TopoCombate", "StatsJogadorPanel", "EnergiaPainel", "MaoDock"]:
		(raiz.get_node(caminho) as Panel).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_adicionar_modulo(raiz.get_node("TopoCombate") as Control, "ModuloJogador", "modulo_jogador.png", Rect2(64, 24, 2050, 660))
	var vida_integrada: Control = Control.new()
	vida_integrada.set_script(BARRA_VIDA)
	vida_integrada.name = "BarraVidaIntegrada"
	vida_integrada.set("modo", "jogador")
	vida_integrada.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vida_integrada.z_index = 2
	(raiz.get_node("TopoCombate") as Control).add_child(vida_integrada)
	(raiz.get_node("TopoCombate/TopoCoracao") as Control).hide()
	(raiz.get_node("TopoCombate/TopoVida") as Control).z_index = 4
	var leitura_vida: Label = raiz.get_node("TopoCombate/TopoVida") as Label
	leitura_vida.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	leitura_vida.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	leitura_vida.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Bold.ttf"))
	leitura_vida.add_theme_color_override("font_outline_color", Color("080d21"))
	leitura_vida.add_theme_constant_override("outline_size", 2)
	_adicionar_modulo(raiz.get_node("Alvo") as Control, "ModuloInimigo", "modulo_inimigo.png", Rect2(32, 80, 2100, 560))
	_adicionar_placa(raiz.get_node("StatsJogadorPanel") as Control, "recursos")
	_adicionar_placa(raiz.get_node("EnergiaPainel") as Control, "energia")
	_adicionar_modulo(raiz.get_node("StatsJogadorPanel") as Control, "ModuloBarreira", "medidor_barreira.png", Rect2(40, 112, 1700, 740))
	_adicionar_modulo(raiz.get_node("StatsJogadorPanel") as Control, "ModuloCombo", "medidor_combo.png", Rect2(40, 160, 2100, 390))
	_adicionar_modulo(raiz.get_node("EnergiaPainel") as Control, "ModuloEnergia", "modulo_energia.png", Rect2(112, 48, 1040, 1140))
	var cais: Control = preload("res://hud_neon/cais_cartas.gd").new() as Control
	cais.name = "CaisIlustrado"
	(raiz.get_node("MaoDock") as Control).add_child(cais)
	_adicionar_retrato_inimigo(raiz.get_node("Alvo") as Control)
	_preparar_drone(raiz.get_node("Alvo/DroneCampoSprite") as TextureRect)
	(raiz.get_node("EnergiaIcone") as TextureRect).hide()
	(raiz.get_node("ComboIcone") as TextureRect).hide()
	for caminho: String in ["EnergiaVisualLabel", "BarreiraIcone", "BarreiraLabel", "ComboIcone", "ComboLabel", "CompraIcone", "CompraLabel", "DescarteIcone", "DescarteLabel"]:
		(raiz.get_node(caminho) as Control).z_index = 3
	_adicionar_legenda(raiz.get_node("StatsJogadorPanel") as Control, "COMBO", Vector2(188.0, -15.0), ROSA)
	_adicionar_legenda(raiz.get_node("CompraPainel") as Control, "COMPRA", Vector2(7.0, 3.0), MUTED)
	_adicionar_legenda(raiz.get_node("DescartePainel") as Control, "DESCARTE", Vector2(7.0, 3.0), MUTED)
	var vazio: StyleBoxFlat = StyleBoxFlat.new()
	vazio.bg_color = Color.TRANSPARENT
	for estado: String in ["normal", "disabled"]:
		(raiz.get_node("Alvo") as Button).add_theme_stylebox_override(estado, vazio)
	var alvo_foco: StyleBoxFlat = StyleBoxFlat.new()
	alvo_foco.bg_color = Color.TRANSPARENT
	alvo_foco.border_color = ROSA
	alvo_foco.set_border_width_all(0)
	for estado: String in ["hover", "pressed", "hover_pressed", "focus"]:
		(raiz.get_node("Alvo") as Button).add_theme_stylebox_override(estado, alvo_foco)
	_adicionar_realce(raiz.get_node("Alvo") as Control, ROSA)
	for nome: String in ["TopoBaralho", "TopoRota", "TopoConfiguracoes"]:
		var botao_util: Button = raiz.get_node("TopoCombate/%s" % nome) as Button
		_estilizar_botao(botao_util, "botao_util")
	var faixa: TextureRect = raiz.get_node("TurnoFaixa") as TextureRect
	faixa.texture = null
	var placa_turno: Panel = Panel.new()
	placa_turno.name = "PlacaTurnoNeon"
	placa_turno.mouse_filter = Control.MOUSE_FILTER_IGNORE
	placa_turno.add_theme_stylebox_override("panel", _textura_moldura("botao_util"))
	faixa.add_child(placa_turno)
	placa_turno.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	(raiz.get_node("TurnoNumeroPainel") as Panel).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	(raiz.get_node("TurnoTituloLabel") as Label).add_theme_color_override("font_color", CIANO)
	(raiz.get_node("TurnoNumeroLabel") as Label).add_theme_color_override("font_color", ROSA)
	(raiz.get_node("IntencaoNomeVisualLabel") as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	(raiz.get_node("IntencaoNomeVisualLabel") as Label).autowrap_mode = TextServer.AUTOWRAP_OFF
	(raiz.get_node("IntencaoValorVisualLabel") as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var fim_turno: Button = raiz.get_node("EncerrarTurno") as Button
	_estilizar_botao(fim_turno, "botao_turno")
	_adicionar_modulo(fim_turno, "BotaoIlustrado", "botao_turno.png", Rect2(32, 128, 2110, 470))
	(fim_turno.get_node("BotaoIlustrado") as TextureRect).z_index = -1
	fim_turno.icon = null
	for estado: String in ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]:
		fim_turno.add_theme_stylebox_override(estado, StyleBoxEmpty.new())
	fim_turno.add_theme_color_override("font_color", CIANO)
	fim_turno.add_theme_color_override("font_hover_color", BRANCO)
	fim_turno.add_theme_color_override("font_focus_color", BRANCO)
	(raiz.get_node("IntencaoPainel") as Panel).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	(raiz.get_node("EstadosInimigoPainel") as Panel).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	for caminho: String in ["CompraPainel", "DescartePainel"]:
		_estilizar_painel(raiz.get_node(caminho) as Panel, VIOLETA)
		_adicionar_realce(raiz.get_node(caminho) as Control, VIOLETA)
	for caminho: String in ["Alvo/Interacao", "EncerrarTurno/Interacao", "CompraPainel/Interacao", "DescartePainel/Interacao", "Jogador/Interacao"]:
		var cor: Color = ROSA if caminho.begins_with("Alvo") else VIOLETA if caminho.begins_with("Compra") or caminho.begins_with("Descarte") else CIANO
		var borda: StyleBoxFlat = StyleBoxFlat.new()
		borda.bg_color = Color.TRANSPARENT
		borda.border_color = cor
		borda.set_border_width_all(0)
		(raiz.get_node(caminho) as Panel).add_theme_stylebox_override("panel", borda)
	for caminho: String in ["BaralhoOverlay", "ConfiguracoesOverlay", "HudInspecao"]:
		var margem: float = 12.0
		(raiz.get_node(caminho) as Control).add_theme_stylebox_override("panel", _textura_moldura("botao_util", margem))
	var estilo_dica: StyleBox = preload("res://hud_neon/tooltip.tres").duplicate() as StyleBox
	estilo_dica.set_content_margin(SIDE_TOP, 36.0)
	(raiz.get_node("HudInspecao") as Control).add_theme_stylebox_override("panel", estilo_dica)
	for caminho: String in ["BaralhoOverlay/BaralhoFechar", "ConfiguracoesOverlay/Som", "ConfiguracoesOverlay/Tela", "ConfiguracoesOverlay/Movimento", "ConfiguracoesOverlay/Fechar"]:
		_estilizar_botao(raiz.get_node(caminho) as Button, "botao_util")
	for caminho: String in ["BaralhoOverlay/BaralhoTitulo", "ConfiguracoesOverlay/Titulo"]:
		(raiz.get_node(caminho) as Label).add_theme_color_override("font_color", CIANO)
	for caminho: String in ["BaralhoOverlay/BaralhoResumo", "BaralhoOverlay/BaralhoVazio", "HudInspecao/Texto"]:
		(raiz.get_node(caminho) as Label).add_theme_color_override("font_color", BRANCO)
	var texto_inspecao: Label = raiz.get_node("HudInspecao/Texto") as Label
	texto_inspecao.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	texto_inspecao.add_theme_font_size_override("font_size", 17)
	texto_inspecao.add_theme_constant_override("line_spacing", 5)
	texto_inspecao.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Regular.ttf"))
	_estilizar_barra(raiz.get_node("VidaJogadorBar") as ProgressBar)
	_estilizar_barra(raiz.get_node("VidaInimigoBar") as ProgressBar)
	(raiz.get_node("VidaJogadorBar") as ProgressBar).modulate.a = 0.0
	preparar_barra_vida_inimigo(raiz.get_node("VidaInimigoBar") as ProgressBar)
	for caminho: String in ["TopoCombate/TopoNome", "EnergiaVisualLabel"]:
		(raiz.get_node(caminho) as Label).add_theme_color_override("font_color", CIANO)
	for caminho: String in ["AlvoVisualLabel", "ComboLabel"]:
		(raiz.get_node(caminho) as Label).add_theme_color_override("font_color", ROSA)
	for caminho: String in ["TopoCombate/TopoVida", "VidaInimigoLabel", "BarreiraLabel", "IntencaoNomeVisualLabel", "IntencaoValorVisualLabel"]:
		(raiz.get_node(caminho) as Label).add_theme_color_override("font_color", BRANCO)
	for caminho: String in ["StatsJogadorPanel", "EnergiaPainel"]:
		for filho: Node in raiz.get_node(caminho).get_children():
			if filho is Label:
				(filho as Label).add_theme_color_override("font_color", MUTED)
	var vida_inimigo: Label = raiz.get_node("VidaInimigoLabel") as Label
	vida_inimigo.z_index = 8
	vida_inimigo.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Bold.ttf"))
	(raiz.get_node("TopoCombate/TopoCoracao") as TextureRect).modulate = ROSA
	(raiz.get_node("CompraIcone") as TextureRect).modulate = CIANO
	(raiz.get_node("DescarteIcone") as TextureRect).modulate = VIOLETA
	(raiz.get_node("BarreiraIcone") as TextureRect).modulate = CIANO
	(raiz.get_node("DanoFeedbackLabel") as Label).add_theme_color_override("font_color", ROSA)
	(raiz.get_node("DanoFeedbackLabel") as Label).add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Bold.ttf"))
	(raiz.get_node("DanoFeedbackLabel") as Label).add_theme_font_size_override("font_size", 38)
	(raiz.get_node("DanoFeedbackLabel") as Label).add_theme_color_override("font_outline_color", Color("080c22"))
	(raiz.get_node("DanoFeedbackLabel") as Label).add_theme_constant_override("outline_size", 5)
	for caminho: String in ["AlvoVisualLabel", "IntencaoNomeVisualLabel", "IntencaoValorVisualLabel", "VidaInimigoLabel", "MaoStatusLabel", "EnergiaVisualLabel", "BarreiraLabel", "ComboLabel", "CompraLabel", "DescarteLabel"]:
		var leitura: Label = raiz.get_node(caminho) as Label
		leitura.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Bold.ttf"))
		leitura.add_theme_constant_override("outline_size", 0)
	var energia_texto: Label = raiz.get_node("EnergiaVisualLabel") as Label
	energia_texto.z_index = 5
	energia_texto.add_theme_color_override("font_color", BRANCO)
	energia_texto.add_theme_color_override("font_outline_color", Color("080d21"))
	energia_texto.add_theme_constant_override("outline_size", 2)
	var aviso_mao: Label = raiz.get_node("MaoStatusLabel") as Label
	aviso_mao.add_theme_stylebox_override("normal", _textura_moldura("botao_util", 5.0))
	aviso_mao.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	(raiz.get_node("AlvoVisualLabel") as Label).autowrap_mode = TextServer.AUTOWRAP_OFF
	(raiz.get_node("AlvoVisualLabel") as Label).clip_text = true
	(raiz.get_node("AlvoVisualLabel") as Label).text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS


static func atualizar(raiz: Node, energia: int, energia_maxima: int, barreira: int, combo: int, animar: bool = true) -> void:
	var indicador_energia: Control = raiz.get_node("EnergiaPainel/MolduraNeon") as Control
	indicador_energia.set("energia_atual", energia)
	indicador_energia.set("energia_maxima", energia_maxima)
	var indicadores: Control = raiz.get_node("StatsJogadorPanel/MolduraNeon") as Control
	indicadores.set("barreira_atual", barreira)
	indicadores.set("combo_atual", combo)
	indicador_energia.call("animar_valores", animar)
	indicadores.call("animar_valores", animar)
	var retrato: TextureRect = raiz.get_node("Alvo/RetratoInimigo") as TextureRect
	retrato.texture = (raiz.get_node("Alvo/DroneCampoSprite") as TextureRect).texture


static func atualizar_barras(raiz: Node, animar: bool = true) -> void:
	var jogador: ProgressBar = raiz.get_node("VidaJogadorBar") as ProgressBar
	(raiz.get_node("TopoCombate/BarraVidaIntegrada") as Control).call("definir_valor", roundi(jogador.value), roundi(jogador.max_value), animar)
	var inimigo: ProgressBar = raiz.get_node("VidaInimigoBar") as ProgressBar
	(inimigo.get_node("VidaAnimada") as Control).call("definir_valor", roundi(inimigo.value), roundi(inimigo.max_value), animar)
	for botao: Button in raiz.get("alvos_multiplos"):
		var barra: ProgressBar = botao.get_node("VidaBar") as ProgressBar
		(barra.get_node("VidaAnimada") as Control).call("definir_valor", roundi(barra.value), roundi(barra.max_value), animar)


static func preparar_barra_vida_inimigo(barra: ProgressBar) -> void:
	if barra.has_node("VidaAnimada"):
		return
	var preenchimento: StyleBoxFlat = barra.get_theme_stylebox("fill") as StyleBoxFlat
	if preenchimento != null:
		var base: StyleBoxFlat = preenchimento.duplicate() as StyleBoxFlat
		base.bg_color = Color("4c1c50")
		barra.add_theme_stylebox_override("fill", base)
	var arte: Control = Control.new()
	arte.set_script(BARRA_VIDA)
	arte.name = "VidaAnimada"
	arte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	barra.add_child(arte)
	arte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


static func _adicionar_placa(pai: Control, modo: String) -> void:
	var placa: Control = Control.new()
	placa.set_script(PLACA)
	placa.name = "MolduraNeon"
	placa.set("modo", modo)
	placa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pai.add_child(placa)
	pai.move_child(placa, 0)
	placa.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	placa.z_index = 2


static func _adicionar_modulo(pai: Control, nome: String, arquivo: String, recorte: Rect2) -> void:
	var textura: AtlasTexture = AtlasTexture.new()
	textura.atlas = load("res://assets/ui/runtime/conceito/%s" % arquivo) as Texture2D
	textura.region = recorte
	var arte: TextureRect = TextureRect.new()
	arte.name = nome
	arte.texture = textura
	arte.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	arte.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	arte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pai.add_child(arte)
	pai.move_child(arte, 0)
	arte.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


static func _adicionar_retrato_inimigo(alvo: Control) -> void:
	var retrato: TextureRect = TextureRect.new()
	retrato.name = "RetratoInimigo"
	retrato.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	retrato.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	retrato.mouse_filter = Control.MOUSE_FILTER_IGNORE
	alvo.add_child(retrato)
	alvo.move_child(retrato, 1)


static func estilizar_alvo_multiplo(botao: Button) -> void:
	var vazio: StyleBoxFlat = StyleBoxFlat.new()
	vazio.bg_color = Color.TRANSPARENT
	var foco: StyleBoxFlat = StyleBoxFlat.new()
	foco.bg_color = Color.TRANSPARENT
	foco.border_color = ROSA
	foco.set_border_width_all(0)
	for estado: String in ["normal", "disabled"]:
		botao.add_theme_stylebox_override(estado, vazio)
	for estado: String in ["hover", "focus", "pressed", "hover_pressed"]:
		botao.add_theme_stylebox_override(estado, foco)
	_adicionar_modulo(botao, "ModuloInimigo", "modulo_inimigo.png", Rect2(32, 80, 2100, 560))
	_adicionar_retrato_inimigo(botao)
	(botao.get_node("RetratoInimigo") as TextureRect).texture = (botao.get_node("DroneCampoSprite") as TextureRect).texture
	_adicionar_realce(botao, ROSA)
	for nome: String in ["Nome", "Intencao", "IntencaoValor", "VidaLabel", "BarreiraLabel"]:
		(botao.get_node(nome) as Label).add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Bold.ttf"))
	_preparar_drone(botao.get_node("DroneCampoSprite") as TextureRect)


static func _preparar_drone(sprite: TextureRect) -> void:
	if sprite.get_script() == null:
		sprite.set_script(preload("res://hud_neon/drone_animado.gd"))
	sprite.call("preparar")


static func icone_reliquia(id_reliquia: String) -> Texture2D:
	var caminho: String = "res://hud_hq/icones/%s.svg" % id_reliquia
	if not ResourceLoader.exists(caminho):
		caminho = "res://hud_hq/icones/juntas_retorno.svg"
	return load(caminho) as Texture2D


static func estilizar_reliquia(botao: Button) -> void:
	var normal: StyleBoxEmpty = StyleBoxEmpty.new()
	var foco: StyleBoxFlat = StyleBoxFlat.new()
	foco.bg_color = Color.TRANSPARENT
	foco.border_color = CIANO
	foco.set_border_width_all(0)
	for estado: String in ["normal", "disabled"]:
		botao.add_theme_stylebox_override(estado, normal)
	for estado: String in ["hover", "focus", "pressed", "hover_pressed"]:
		botao.add_theme_stylebox_override(estado, foco)
	_adicionar_realce(botao, CIANO)
	botao.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Bold.ttf"))
	botao.add_theme_color_override("font_color", BRANCO)
	botao.add_theme_constant_override("h_separation", 3)
	botao.alignment = HORIZONTAL_ALIGNMENT_CENTER
	botao.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	botao.clip_text = true


static func nome_curto_reliquia(id: String) -> String:
	var nomes: Dictionary = {"juntas_retorno": "Retorno", "reservatorio_auxiliar": "Reserva", "mecanismo_recuo": "Recuo", "reliquia_evento_agua_morta_provisorio": "Amostra"}
	return str(nomes.get(id, "Relíquia"))


static func _adicionar_legenda(pai: Control, texto: String, posicao: Vector2, cor: Color) -> void:
	var legenda: Label = Label.new()
	legenda.name = "Legenda%sNeon" % texto.capitalize()
	legenda.text = texto
	legenda.position = posicao
	legenda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	legenda.z_index = 4
	legenda.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Bold.ttf"))
	legenda.add_theme_font_size_override("font_size", 11)
	legenda.add_theme_color_override("font_color", cor)
	pai.add_child(legenda)


static func _adicionar_realce(controle: Control, cor: Color) -> void:
	var realce: Control = Control.new()
	realce.set_script(REALCE)
	realce.name = "RealceNeon"
	realce.set("cor", cor)
	realce.z_index = 7
	controle.add_child(realce)


static func _estilizar_botao(botao: Button, nome: String) -> void:
	var normal: StyleBoxTexture = _textura_moldura(nome)
	var hover: StyleBoxTexture = _textura_moldura("%s_hover" % nome)
	for estado: String in ["normal", "disabled"]:
		botao.add_theme_stylebox_override(estado, normal)
	for estado: String in ["hover", "focus", "pressed", "hover_pressed"]:
		botao.add_theme_stylebox_override(estado, hover)
	botao.add_theme_color_override("font_color", BRANCO)
	botao.add_theme_color_override("font_hover_color", BRANCO)
	botao.add_theme_color_override("font_focus_color", BRANCO)
	botao.add_theme_color_override("font_pressed_color", BRANCO)
	botao.add_theme_color_override("font_disabled_color", MUTED)
	_adicionar_realce(botao, CIANO if nome == "botao_turno" else VIOLETA)


static func _textura_moldura(nome: String, margem: float = 9.0) -> StyleBoxTexture:
	var estilo: StyleBoxTexture = StyleBoxTexture.new()
	estilo.texture = load("res://hud_neon/%s.svg" % nome) as Texture2D
	for lado: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		estilo.set_texture_margin(lado, 24.0)
		estilo.set_content_margin(lado, margem)
	return estilo


static func _estilizar_painel(painel: Panel, acento: Color) -> void:
	var estilo: StyleBoxFlat = StyleBoxFlat.new()
	estilo.bg_color = Color("0a1024ee")
	estilo.border_color = Color(acento, 0.85)
	estilo.set_border_width_all(1)
	estilo.set_corner_radius_all(2)
	estilo.set_content_margin_all(4.0)
	painel.add_theme_stylebox_override("panel", estilo)


static func _estilizar_barra(barra: ProgressBar) -> void:
	var trilho: StyleBoxFlat = StyleBoxFlat.new()
	trilho.bg_color = Color("1b2641")
	trilho.set_corner_radius_all(2)
	var preenchimento: StyleBoxFlat = StyleBoxFlat.new()
	preenchimento.bg_color = ROSA
	preenchimento.set_corner_radius_all(2)
	barra.add_theme_stylebox_override("background", trilho)
	barra.add_theme_stylebox_override("fill", preenchimento)
