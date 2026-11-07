extends RefCounted
## Camada visual da HUD: nÃ£o resolve aÃ§Ãµes nem guarda estado de combate.
const HOVER: Script = preload("res://hud_hq/hover_hq.gd")
const CREME: Color = Color("f2ecdf")

static func moldura(nome: String, margem: float = 10.0) -> StyleBoxTexture:
	var estilo: StyleBoxTexture = StyleBoxTexture.new()
	estilo.texture = load("res://hud_hq/molduras/%s.svg" % nome) as Texture2D
	for lado: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		estilo.set_texture_margin(lado, 24.0)
		estilo.set_content_margin(lado, margem)
	return estilo

static func icone(nome: String) -> Texture2D:
	var caminho: String = "res://hud_hq/icones/%s.svg" % nome
	if not ResourceLoader.exists(caminho):
		caminho = "res://hud_hq/icones/juntas_retorno.svg"
	return load(caminho) as Texture2D

static func realce(controle: Control, cor: Color = Color("e5b65c")) -> void:
	if controle.has_node("HoverHQ"):
		return
	var efeito: Control = Control.new()
	efeito.set_script(HOVER)
	efeito.name = "HoverHQ"
	efeito.set("cor", cor)
	efeito.z_index = 7
	controle.add_child(efeito)

static func botao(controle: Button, acento: String = "azul", margem: float = 9.0) -> void:
	controle.flat = false
	for estado: String in ["normal", "hover", "pressed", "hover_pressed", "disabled"]:
		var arquivo: String = acento
		if estado == "hover":
			arquivo = "hover"
		elif estado == "pressed" or estado == "hover_pressed":
			arquivo = "pressionado"
		elif estado == "disabled":
			arquivo = "desabilitado"
		controle.add_theme_stylebox_override(estado, moldura(arquivo, margem))
	var foco: StyleBoxFlat = StyleBoxFlat.new()
	foco.bg_color = Color.TRANSPARENT
	foco.border_color = Color("e5b65c")
	foco.set_border_width_all(2)
	controle.add_theme_stylebox_override("focus", foco)
	for estado: String in ["font_color", "font_hover_color", "font_focus_color", "font_pressed_color", "font_hover_pressed_color"]:
		controle.add_theme_color_override(estado, CREME)
	controle.add_theme_color_override("font_disabled_color", Color("89939c"))
	controle.add_theme_color_override("icon_disabled_color", Color("68717a"))
	controle.add_theme_constant_override("icon_max_width", 32)
	realce(controle)

static func preparar(raiz: Node) -> void:
	# O cenário já reserva uma área de chão para as cartas.
	(raiz.get_node("MaoDock") as Panel).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	# Textos soltos precisam se separar dos materiais claros do cais.
	for caminho: String in ["Jogador", "MaoStatusLabel"]:
		var rotulo: Control = raiz.get_node(caminho) as Control
		rotulo.add_theme_color_override("font_outline_color", Color("11171d"))
		rotulo.add_theme_constant_override("outline_size", 4)
	for caminho: String in ["TopoCombate", "CompraPainel", "DescartePainel", "BaralhoOverlay", "ConfiguracoesOverlay"]:
		(raiz.get_node(caminho) as Control).add_theme_stylebox_override("panel", moldura("azul"))
	for caminho: String in ["TopoCombate/TopoBaralho", "TopoCombate/TopoRota", "TopoCombate/TopoConfiguracoes", "Alvo", "BaralhoOverlay/BaralhoFechar", "ConfiguracoesOverlay/Som", "ConfiguracoesOverlay/Tela", "ConfiguracoesOverlay/Fechar"]:
		botao(raiz.get_node(caminho) as Button)
	botao(raiz.get_node("EncerrarTurno") as Button, "ambar")
	var encerrar: Button = raiz.get_node("EncerrarTurno") as Button
	encerrar.icon = icone("fim_turno")
	encerrar.expand_icon = true
	encerrar.add_theme_constant_override("icon_max_width", 23)
	for caminho: String in ["TopoCombate/TopoBaralho", "TopoCombate/TopoRota", "TopoCombate/TopoConfiguracoes"]:
		(raiz.get_node(caminho) as Control).tooltip_text = ""
	var faixa: TextureRect = raiz.get_node("TurnoFaixa") as TextureRect
	faixa.texture = null
	var painel_turno: Panel = Panel.new()
	painel_turno.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painel_turno.add_theme_stylebox_override("panel", moldura("azul"))
	faixa.add_child(painel_turno)
	painel_turno.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	(raiz.get_node("TurnoNumeroPainel") as Panel).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	(raiz.get_node("TurnoNumeroLabel") as Label).add_theme_color_override("font_color", Color("e5b65c"))
	(raiz.get_node("TopoCombate/TopoBaralho") as Button).icon = icone("baralho")
	(raiz.get_node("TopoCombate/TopoRota/Icone") as TextureRect).texture = icone("rota")
	(raiz.get_node("TopoCombate/TopoConfiguracoes/Icone") as TextureRect).texture = icone("configuracoes")
	(raiz.get_node("TopoCombate/TopoCoracao") as TextureRect).texture = icone("vida")
	(raiz.get_node("CompraIcone") as TextureRect).texture = icone("baralho")
	(raiz.get_node("DescarteIcone") as TextureRect).texture = icone("descarte")
	for caminho: String in ["CompraPainel", "DescartePainel", "EnergiaPainel", "StatsJogadorPanel"]:
		realce(raiz.get_node(caminho) as Control)
	# As antigas camadas de hover tinham preenchimento que cobria o conteÃºdo.
	for caminho: String in ["Alvo/Interacao", "EncerrarTurno/Interacao", "CompraPainel/Interacao", "DescartePainel/Interacao"]:
		var borda: StyleBoxFlat = StyleBoxFlat.new()
		borda.bg_color = Color.TRANSPARENT
		borda.border_color = Color("e5b65c")
		borda.set_border_width_all(1)
		(raiz.get_node(caminho) as Panel).add_theme_stylebox_override("panel", borda)
	var destaque_jogador: StyleBoxFlat = StyleBoxFlat.new()
	destaque_jogador.bg_color = Color.TRANSPARENT
	destaque_jogador.border_color = Color("40e4df")
	destaque_jogador.set_border_width_all(1)
	(raiz.get_node("Jogador/Interacao") as Panel).add_theme_stylebox_override("panel", destaque_jogador)
	var inspecao: PanelContainer = raiz.get_node("HudInspecao") as PanelContainer
	inspecao.add_theme_stylebox_override("panel", moldura("ambar", 18.0))
	var texto: Label = inspecao.get_node("Texto") as Label
	texto.add_theme_color_override("font_color", CREME)
	texto.add_theme_font_size_override("font_size", 17)
	texto.add_theme_constant_override("line_spacing", 5)
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Etiqueta discreta que ancora o inventÃ¡rio no shell compartilhado.
	var relicario: Control = raiz.get_node("TopoCombate/TopoRelicario") as Control
	relicario.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var titulo: Label = Label.new()
	titulo.text = "RELÃQUIAS"
	titulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	titulo.add_theme_font_size_override("font_size", 10)
	titulo.add_theme_color_override("font_color", Color("8faebc"))
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	relicario.add_child(titulo)
	titulo.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	titulo.position.y = -12
