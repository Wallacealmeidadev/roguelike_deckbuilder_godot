extends RefCounted
## Apresentacao simples do HUD. Nao resolve cartas, custos ou turnos.
const NORMAL: StyleBox = preload("res://hud_basico/normal.tres")
const HOVER: StyleBox = preload("res://prototipos/hud_antiga/hud_basico/hover.tres")
const PRESSIONADO: StyleBox = preload("res://prototipos/hud_antiga/hud_basico/pressionado.tres")
const DESABILITADO: StyleBox = preload("res://prototipos/hud_antiga/hud_basico/desabilitado.tres")
const PAINEL: StyleBox = preload("res://hud_basico/painel.tres")
const VIDA: StyleBox = preload("res://prototipos/hud_antiga/hud_basico/vida.tres")
const TRILHO: StyleBox = preload("res://prototipos/hud_antiga/hud_basico/vida_fundo.tres")
const MARCADORES: Script = preload("res://prototipos/hud_antiga/hud_basico/energia_marcadores.gd")

static func preparar(raiz: Node) -> void:
	for caminho: String in ["TopoCombate/TopoBaralho", "TopoCombate/TopoRota", "TopoCombate/TopoConfiguracoes", "EncerrarTurno", "Alvo", "BaralhoOverlay/BaralhoFechar", "ConfiguracoesOverlay/Som", "ConfiguracoesOverlay/Tela", "ConfiguracoesOverlay/Fechar"]:
		var botao: Button = raiz.get_node(caminho) as Button
		botao.add_theme_stylebox_override("normal", NORMAL)
		botao.add_theme_stylebox_override("hover", HOVER)
		botao.add_theme_stylebox_override("focus", HOVER)
		botao.add_theme_stylebox_override("pressed", PRESSIONADO)
		botao.add_theme_stylebox_override("disabled", DESABILITADO)
		botao.add_theme_color_override("font_color", Color("ece9e1"))
		botao.add_theme_color_override("font_disabled_color", Color("707780"))
	for caminho: String in ["StatsJogadorPanel", "CompraPainel", "DescartePainel", "ConfiguracoesOverlay", "HudInspecao"]:
		(raiz.get_node(caminho) as Control).add_theme_stylebox_override("panel", PAINEL)
	for caminho: String in ["VidaJogadorBar", "VidaInimigoBar"]:
		var barra: ProgressBar = raiz.get_node(caminho) as ProgressBar
		barra.add_theme_stylebox_override("background", TRILHO)
		barra.add_theme_stylebox_override("fill", VIDA)
	var energia: Control = raiz.get_node("EnergiaPainel") as Control
	var marcadores: Control = Control.new()
	marcadores.set_script(MARCADORES)
	marcadores.name = "Marcadores"
	marcadores.position = Vector2(53.0, 48.0)
	marcadores.size = Vector2(100.0, 14.0)
	energia.add_child(marcadores)
	legenda(energia, "ENERGIA", Vector2(53.0, 3.0))
	legenda(raiz.get_node("CompraPainel") as Control, "COMPRA", Vector2(7.0, 3.0))
	legenda(raiz.get_node("DescartePainel") as Control, "DESCARTE", Vector2(7.0, 3.0))
	legenda(raiz.get_node("StatsJogadorPanel") as Control, "BARREIRA", Vector2(12.0, 3.0))
	legenda(raiz.get_node("StatsJogadorPanel") as Control, "COMBO", Vector2(127.0, 3.0))
	for caminho: String in ["EnergiaIcone", "EnergiaVisualLabel", "CompraIcone", "CompraLabel", "DescarteIcone", "DescarteLabel", "BarreiraIcone", "BarreiraLabel", "ComboIcone", "ComboLabel"]:
		(raiz.get_node(caminho) as Control).z_index = 3
	(raiz.get_node("TopoCombate/TopoNome") as Label).add_theme_color_override("font_color", Color("ece9e1"))

static func legenda(pai: Control, texto: String, posicao: Vector2) -> void:
	var rotulo: Label = Label.new()
	rotulo.text = texto
	rotulo.position = posicao
	rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rotulo.add_theme_font_size_override("font_size", 11)
	rotulo.add_theme_color_override("font_color", Color("aab1b8"))
	pai.add_child(rotulo)
