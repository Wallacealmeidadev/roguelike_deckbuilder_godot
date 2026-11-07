extends RefCounted
## Apenas tema e decoração do mapa/recompensa; sem estado ou progressão.

const GRADE_ROTA: Script = preload("res://hud_neon/grade_rota.gd")
const CIANO: Color = Color("22e8f5")
const ROSA: Color = Color("f322b5")
const VIOLETA: Color = Color("ab54f5")
const BRANCO: Color = Color("f3f5ff")
const MUTED: Color = Color("a0b6cb")


static func preparar(raiz: Node) -> void:
	var cabecalho: PanelContainer = raiz.get_node("MapaOverlay/MapaCabecalho") as PanelContainer
	cabecalho.add_theme_stylebox_override("panel", _moldura("botao_util", 16.0))
	(raiz.get_node("MapaOverlay/MapaCabecalho/MapaCabecalhoLinha/MapaTitulo") as Label).add_theme_color_override("font_color", CIANO)
	(raiz.get_node("MapaOverlay/MapaCabecalho/MapaCabecalhoLinha/MapaDistrito") as Label).add_theme_color_override("font_color", BRANCO)
	for caminho: String in ["MapaVidaLabel", "MapaBaralhoLabel"]:
		(raiz.get_node("MapaOverlay/MapaCabecalho/MapaCabecalhoLinha/MapaRecursos/%s" % caminho) as Label).add_theme_color_override("font_color", BRANCO)
	(raiz.get_node("MapaOverlay/MapaCabecalho/MapaCabecalhoLinha/MapaRecursos/MapaVidaIcone") as TextureRect).texture = load("res://hud_hq/icones/vida.svg") as Texture2D
	(raiz.get_node("MapaOverlay/MapaCabecalho/MapaCabecalhoLinha/MapaRecursos/MapaBaralhoIcone") as TextureRect).texture = load("res://hud_hq/icones/baralho.svg") as Texture2D
	var info: Label = raiz.get_node("MapaOverlay/MapaInfo") as Label
	info.add_theme_color_override("font_color", ROSA)
	info.add_theme_font_size_override("font_size", 18)
	(raiz.get_node("MapaOverlay/MapaMensagem") as Label).add_theme_color_override("font_color", MUTED)
	var grafo: Control = raiz.get_node("MapaOverlay/MapaGrafo") as Control
	var grade: Control = Control.new()
	grade.set_script(GRADE_ROTA)
	grade.name = "GradeNeon"
	grade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grafo.add_child(grade)
	grafo.move_child(grade, 0)
	grade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var detalhe: PanelContainer = raiz.get_node("MapaOverlay/MapaDetalhe") as PanelContainer
	var estilo_detalhe: StyleBoxFlat = StyleBoxFlat.new()
	estilo_detalhe.bg_color = Color("0a1024f5")
	estilo_detalhe.border_color = CIANO
	estilo_detalhe.set_border_width_all(2)
	estilo_detalhe.set_corner_radius_all(4)
	detalhe.add_theme_stylebox_override("panel", estilo_detalhe)
	(raiz.get_node("MapaOverlay/MapaDetalhe/MapaDetalheMargem/MapaDetalheConteudo/MapaDetalheLinha/MapaDetalheTextos/MapaDetalheTitulo") as Label).add_theme_color_override("font_color", BRANCO)
	_preparar_recompensa(raiz)
	_preparar_evento(raiz)
	_preparar_elite(raiz)
	_preparar_descanso(raiz)
	_estilizar_acao(raiz.get_node("Reiniciar") as Button, "botao_turno")


static func atualizar_mapa(raiz: Node, total_pontos: int) -> void:
	(raiz.get_node("MapaOverlay/MapaGrafo/GradeNeon") as Control).set("total_pontos", total_pontos)


static func atualizar_resultado(raiz: Node, vitoria: bool, chefe_provisorio: bool = false) -> void:
	(raiz.get_node("ResultadoLabel") as Label).add_theme_color_override("font_color", CIANO if vitoria else ROSA)
	(raiz.get_node("ResultadoLabel/NotaProvisorio") as Label).visible = chefe_provisorio


static func estilizar_no_mapa(botao: Button, tipo: String, estado: String) -> void:
	var acento: Color = _cor_tipo(tipo)
	var fundo: Color = Color("0a1327")
	var borda: Color = Color("465878")
	var largura: int = 1
	match estado:
		"disponivel":
			fundo = Color("0c2437")
			borda = CIANO
			largura = 3
		"atual":
			fundo = Color("112c35")
			borda = Color("78f5d9")
			largura = 3
		"concluido":
			fundo = Color("101d2d")
			borda = Color("5b8a96")
			largura = 2
		"reservado":
			fundo = Color("251327")
			borda = ROSA
			largura = 2
		_:
			if tipo == "elite" or tipo == "chefe":
				borda = Color(acento, 0.53)
	var placa: StyleBoxFlat = StyleBoxFlat.new()
	placa.bg_color = fundo
	placa.border_color = borda
	placa.set_border_width_all(largura)
	placa.set_corner_radius_all(5)
	placa.set_content_margin_all(4.0)
	if estado == "disponivel":
		placa.shadow_color = Color(CIANO, 0.27)
		placa.shadow_size = 6
	for nome_estado: String in ["normal", "hover", "focus", "pressed", "hover_pressed", "disabled"]:
		botao.add_theme_stylebox_override(nome_estado, placa)
	botao.modulate = Color.WHITE
	var icone: TextureRect = botao.get_node("Icone") as TextureRect
	icone.texture = load("res://hud_neon/mapa_%s.svg" % tipo) as Texture2D
	icone.modulate = Color.WHITE if estado in ["disponivel", "atual"] else Color("a4b2cd")
	var marcador: Label = botao.get_node("Marcador") as Label
	marcador.add_theme_color_override("font_color", CIANO if estado == "disponivel" else (ROSA if estado == "reservado" else MUTED))
	var interacao: Panel = botao.get_node("Interacao") as Panel
	var realce: StyleBoxFlat = StyleBoxFlat.new()
	realce.bg_color = Color.TRANSPARENT
	realce.border_color = acento
	realce.set_border_width_all(2)
	realce.set_corner_radius_all(5)
	interacao.add_theme_stylebox_override("panel", realce)


static func _preparar_recompensa(raiz: Node) -> void:
	var titulo: Label = raiz.get_node("ResultadoLabel") as Label
	titulo.add_theme_color_override("font_color", CIANO)
	titulo.add_theme_font_size_override("font_size", 43)
	var moldura: Panel = Panel.new()
	moldura.name = "MolduraNeon"
	moldura.show_behind_parent = true
	moldura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	moldura.add_theme_stylebox_override("panel", _moldura("botao_util", 8.0))
	titulo.add_child(moldura)
	moldura.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var nota: Label = Label.new()
	nota.name = "NotaProvisorio"
	nota.text = "Lastro definitivo ainda não implementado."
	nota.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nota.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nota.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Regular.ttf"))
	nota.add_theme_font_size_override("font_size", 17)
	nota.add_theme_color_override("font_color", MUTED)
	titulo.add_child(nota)
	nota.anchor_left = 0.0
	nota.anchor_right = 1.0
	nota.offset_top = 108.0
	nota.offset_bottom = 137.0
	nota.hide()
	var recompensa: Control = raiz.get_node("Recompensas") as Control
	var placa: Panel = Panel.new()
	placa.name = "PlacaNeon"
	placa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	placa.add_theme_stylebox_override("panel", _moldura("botao_util", 9.0))
	recompensa.add_child(placa)
	recompensa.move_child(placa, 0)
	placa.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	placa.offset_bottom = -72.0
	var legenda: Label = Label.new()
	legenda.name = "LegendaNeon"
	legenda.text = "TRANSMISSÃO DAS DOCAS  /  RECOMPENSA"
	legenda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	legenda.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Bold.ttf"))
	legenda.add_theme_font_size_override("font_size", 12)
	legenda.add_theme_color_override("font_color", ROSA)
	placa.add_child(legenda)
	legenda.position = Vector2(22.0, 9.0)
	legenda.size = Vector2(270.0, 20.0)
	_estilizar_acao(raiz.get_node("Recompensas/RecompensaAcoes/ConsultarBaralho") as Button, "botao_util")
	_estilizar_acao(raiz.get_node("Recompensas/RecompensaAcoes/Pular") as Button, "botao_turno")


static func _estilizar_acao(botao: Button, nome: String) -> void:
	var estilo: StyleBoxTexture = _moldura(nome, 8.0)
	for estado: String in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		botao.add_theme_stylebox_override(estado, estilo)
	var foco: StyleBoxFlat = StyleBoxFlat.new()
	foco.bg_color = Color.TRANSPARENT
	foco.border_color = CIANO
	foco.set_border_width_all(2)
	botao.add_theme_stylebox_override("focus", foco)
	botao.add_theme_color_override("font_color", BRANCO)
	botao.add_theme_color_override("font_hover_color", CIANO)
	botao.add_theme_color_override("font_focus_color", CIANO)


static func _preparar_evento(raiz: Node) -> void:
	var base: String = "EventoOverlay/"
	(raiz.get_node(base + "EventoTituloFaixa") as PanelContainer).add_theme_stylebox_override("panel", _moldura("botao_util", 8.0))
	(raiz.get_node(base + "EventoTitulo") as Label).add_theme_color_override("font_color", CIANO)
	(raiz.get_node(base + "EventoVidaIcone") as TextureRect).texture = load("res://hud_hq/icones/vida.svg") as Texture2D
	(raiz.get_node(base + "EventoBaralhoIcone") as TextureRect).texture = load("res://hud_hq/icones/baralho.svg") as Texture2D
	for caminho: String in ["EventoVidaLabel", "EventoBaralhoLabel"]:
		(raiz.get_node(base + caminho) as Label).add_theme_color_override("font_color", BRANCO)
	(raiz.get_node(base + "EventoQuadro") as PanelContainer).add_theme_stylebox_override("panel", _painel(Color("081022f5"), VIOLETA))
	(raiz.get_node(base + "EventoQuadroIcone") as TextureRect).modulate = CIANO
	(raiz.get_node(base + "EventoFaixaNome") as PanelContainer).add_theme_stylebox_override("panel", _moldura("botao_util", 8.0))
	(raiz.get_node(base + "EventoFaixaNome/EventoFaixaNomeLabel") as Label).add_theme_color_override("font_color", BRANCO)
	(raiz.get_node(base + "EventoNarrativaPainel") as PanelContainer).add_theme_stylebox_override("panel", _painel(Color("0b1530f5"), CIANO))
	for caminho: String in ["EventoTexto", "EventoResultado"]:
		(raiz.get_node(base + caminho) as Label).add_theme_color_override("font_color", BRANCO)
	for indice: int in 3:
		var opcao: Button = raiz.get_node(base + "EventoOpcoes/EventoOpcao%d" % (indice + 1)) as Button
		var moldura: StyleBoxTexture = _moldura("botao_util", 8.0)
		for estado: String in ["normal", "hover", "focus", "pressed", "hover_pressed", "disabled"]:
			opcao.add_theme_stylebox_override(estado, moldura)
		var interacao: Panel = opcao.get_node("Interacao") as Panel
		interacao.add_theme_stylebox_override("panel", _painel(Color.TRANSPARENT, CIANO))
	_estilizar_acao(raiz.get_node(base + "EventoContinuar") as Button, "botao_turno")


static func _preparar_elite(raiz: Node) -> void:
	var elite: Control = raiz.get_node("RecompensaElite") as Control
	var fundo: Panel = Panel.new()
	fundo.name = "RecompensaEliteFundo"
	fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fundo.z_index = 1
	fundo.add_theme_stylebox_override("panel", _moldura("botao_util", 12.0))
	raiz.add_child(fundo)
	raiz.move_child(fundo, elite.get_index())
	fundo.anchor_left = 0.065
	fundo.anchor_top = 0.085
	fundo.anchor_right = 0.935
	fundo.anchor_bottom = 0.94
	fundo.visible = elite.visible
	elite.visibility_changed.connect(func() -> void: fundo.visible = elite.visible)
	(raiz.get_node("RecompensaElite/TituloElite") as Label).add_theme_color_override("font_color", ROSA)
	(raiz.get_node("RecompensaElite/IndicadorEtapa") as Label).add_theme_color_override("font_color", CIANO)
	_estilizar_acao(raiz.get_node("RecompensaElite/RecompensaEliteAcoes/ConsultarBaralho") as Button, "botao_util")


static func _preparar_descanso(raiz: Node) -> void:
	var base: String = "DescansoOverlay/"
	(raiz.get_node(base + "FaixaTitulo") as PanelContainer).add_theme_stylebox_override("panel", _moldura("botao_util", 10.0))
	(raiz.get_node(base + "FaixaTitulo/Titulo") as Label).add_theme_color_override("font_color", CIANO)
	(raiz.get_node(base + "Subtitulo") as Label).add_theme_color_override("font_color", MUTED)
	(raiz.get_node(base + "VidaIcone") as TextureRect).texture = load("res://hud_hq/icones/vida.svg") as Texture2D
	(raiz.get_node(base + "BaralhoIcone") as TextureRect).texture = load("res://hud_hq/icones/baralho.svg") as Texture2D
	for caminho: String in ["VidaLabel", "BaralhoLabel"]:
		(raiz.get_node(base + caminho) as Label).add_theme_color_override("font_color", BRANCO)
	for nome: String in ["RecuperarPainel", "AprimorarPainel"]:
		var caminho_acao: String = base + "Acoes/" + nome
		var botao: Button = raiz.get_node(caminho_acao) as Button
		var estilo: StyleBoxTexture = _moldura("botao_util", 10.0)
		for estado: String in ["normal", "hover", "focus", "pressed", "hover_pressed", "disabled"]:
			botao.add_theme_stylebox_override(estado, estilo)
		(botao.get_node("Interacao") as Panel).add_theme_stylebox_override("panel", _painel(Color.TRANSPARENT, CIANO))
		(botao.get_node("Conteudo/Informacao") as PanelContainer).add_theme_stylebox_override("panel", _painel(Color("101c32"), VIOLETA))
		(botao.get_node("Conteudo/Informacao/Detalhe") as Label).add_theme_color_override("font_color", BRANCO)
	for caminho: String in ["Selecao/Titulo", "Comparacao/Titulo"]:
		(raiz.get_node(base + caminho) as Label).add_theme_color_override("font_color", CIANO)
	for caminho: String in ["Selecao/Voltar", "Comparacao/Voltar", "Comparacao/Confirmar", "Continuar"]:
		_estilizar_acao(raiz.get_node(base + caminho) as Button, "botao_turno" if caminho.ends_with("Confirmar") or caminho == "Continuar" else "botao_util")
	var resultado: PanelContainer = raiz.get_node(base + "Resultado") as PanelContainer
	resultado.add_theme_stylebox_override("panel", _painel(Color("0a1024f5"), CIANO))
	(raiz.get_node(base + "Resultado/Conteudo/Titulo") as Label).add_theme_color_override("font_color", CIANO)
	(raiz.get_node(base + "Resultado/Conteudo/Texto") as Label).add_theme_color_override("font_color", BRANCO)
	(raiz.get_node(base + "Resultado/Conteudo/Estado") as Label).add_theme_color_override("font_color", MUTED)


static func _painel(fundo: Color, borda: Color) -> StyleBoxFlat:
	var estilo: StyleBoxFlat = StyleBoxFlat.new()
	estilo.bg_color = fundo
	estilo.border_color = borda
	estilo.set_border_width_all(2)
	estilo.set_corner_radius_all(4)
	estilo.set_content_margin_all(8.0)
	return estilo


static func _moldura(nome: String, margem: float) -> StyleBoxTexture:
	var estilo: StyleBoxTexture = StyleBoxTexture.new()
	estilo.texture = load("res://hud_neon/%s.svg" % nome) as Texture2D
	for lado: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		estilo.set_texture_margin(lado, 24.0)
		estilo.set_content_margin(lado, margem)
	return estilo


static func _cor_tipo(tipo: String) -> Color:
	match tipo:
		"elite", "chefe":
			return ROSA
		"evento", "desmanche":
			return VIOLETA
		_:
			return CIANO
