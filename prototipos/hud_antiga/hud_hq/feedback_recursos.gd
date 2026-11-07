extends Node
## Escuta mudanças da apresentação, sem escrever no estado do jogo.
const PAINEL: Script = preload("res://prototipos/hud_antiga/hud_hq/painel_recursos.gd")
const ENERGIA: Texture2D = preload("res://prototipos/hud_antiga/hud_hq/energia.svg")
const BARREIRA: Texture2D = preload("res://hud_hq/barreira.svg")
const COMBO: Texture2D = preload("res://prototipos/hud_antiga/hud_hq/combo.svg")
var painel_energia: Control
var painel_stats: Control
var _raiz: Node
var _pronto: bool = false
var _energia: int = 0
var _barreira: int = 0
var _combo: int = 0
var _tweens: Dictionary = {}

func preparar(raiz: Node) -> void:
	_raiz = raiz
	painel_energia = adicionar_moldura(raiz.get_node("EnergiaPainel") as Panel, true)
	painel_stats = adicionar_moldura(raiz.get_node("StatsJogadorPanel") as Panel, false)
	for item: Array in [["EnergiaIcone", ENERGIA], ["BarreiraIcone", BARREIRA], ["ComboIcone", COMBO]]:
		var icone: TextureRect = raiz.get_node(item[0]) as TextureRect
		icone.texture = item[1]
	for nome: String in ["EnergiaVisualLabel", "BarreiraLabel", "ComboLabel"]:
		var rotulo: Label = raiz.get_node(nome) as Label
		rotulo.add_theme_color_override("font_color", Color("f4eee1"))
		rotulo.add_theme_color_override("font_outline_color", Color("080c11"))
		rotulo.add_theme_constant_override("outline_size", 2)

func adicionar_moldura(painel: Panel, eh_energia: bool) -> Control:
	# Mantém o contrato visual da HUD básica; a moldura vetorial fica sobreposta.
	var base_transparente: StyleBoxFlat = StyleBoxFlat.new()
	base_transparente.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	painel.add_theme_stylebox_override("panel", base_transparente)
	var moldura: Control = Control.new()
	moldura.set_script(PAINEL)
	moldura.set("energia", eh_energia)
	moldura.name = "MolduraHQ"
	moldura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painel.add_child(moldura)
	painel.move_child(moldura, 0)
	moldura.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return moldura

func observar(energia: int, barreira: int, combo: int, animar: bool = true) -> void:
	if _pronto and animar and (_raiz.get_node("EnergiaPainel") as Control).is_visible_in_tree():
		if energia != _energia:
			pulso(painel_energia, "impacto_energia", 0.30 if energia < _energia else 0.42)
			salto("EnergiaVisualLabel", 1.07 if energia < _energia else 1.13)
		if barreira > _barreira:
			painel_stats.set("quebra_barreira", false)
			pulso(painel_stats, "impacto_barreira", 0.36)
			salto("BarreiraIcone", 1.12)
		if combo > _combo:
			salto("ComboLabel", 1.20)
			salto("ComboIcone", 1.12)
	_energia = energia
	_barreira = barreira
	_combo = combo
	_pronto = true

func consumir_combo() -> void:
	pulso(painel_stats, "impacto_combo", 0.38)
	salto("ComboIcone", 1.24)

func absorver_barreira(quantidade: int, quebrou: bool) -> void:
	if quantidade <= 0:
		return
	painel_stats.set("quebra_barreira", quebrou)
	pulso(painel_stats, "impacto_barreira", 0.46 if quebrou else 0.28)
	salto("BarreiraIcone", 1.18)

func pulso(controle: Control, propriedade: String, duracao: float) -> void:
	cancelar(propriedade)
	controle.set(propriedade, 1.0)
	var tween: Tween = create_tween()
	tween.tween_property(controle, propriedade, 0.0, duracao).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tweens[propriedade] = tween

func salto(nome: String, escala: float) -> void:
	cancelar(nome)
	var controle: Control = _raiz.get_node(nome) as Control
	controle.pivot_offset = controle.size * 0.5
	controle.scale = Vector2.ONE
	var tween: Tween = create_tween()
	tween.tween_property(controle, "scale", Vector2.ONE * escala, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(controle, "scale", Vector2.ONE, 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tweens[nome] = tween

func cancelar(chave: String) -> void:
	if _tweens.has(chave):
		var tween: Tween = _tweens[chave]
		if tween != null and tween.is_valid():
			tween.kill()
		_tweens.erase(chave)

func reiniciar() -> void:
	for chave: String in _tweens.keys():
		cancelar(chave)
	for nome: String in ["EnergiaVisualLabel", "BarreiraIcone", "ComboLabel", "ComboIcone"]:
		(_raiz.get_node(nome) as Control).scale = Vector2.ONE
	painel_energia.set("impacto_energia", 0.0)
	painel_stats.set("impacto_barreira", 0.0)
	painel_stats.set("impacto_combo", 0.0)
	painel_stats.set("quebra_barreira", false)
	_pronto = false
