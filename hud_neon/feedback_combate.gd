extends Node
## Feedback puramente visual dos recursos que o combate já resolveu.

var painel_energia: Control
var painel_stats: Control
var _raiz: Node
var _pronto: bool = false
var _energia: int = 0
var _barreira: int = 0
var _combo: int = 0
var _tweens: Dictionary = {}
var animador_combo: AnimationPlayer
var animador_barreira: AnimationPlayer


func preparar(raiz: Node) -> void:
	_raiz = raiz
	painel_energia = raiz.get_node("EnergiaPainel/MolduraNeon") as Control
	painel_stats = raiz.get_node("StatsJogadorPanel/MolduraNeon") as Control
	animador_combo = raiz.get_node("AnimacaoComboHUD") as AnimationPlayer
	animador_barreira = raiz.get_node("AnimacaoBarreiraHUD") as AnimationPlayer


func observar(energia: int, barreira: int, combo: int, animar: bool = true) -> void:
	var reduzido: bool = bool(_raiz.get("movimento_reduzido"))
	painel_stats.set("movimento_reduzido", reduzido)
	if reduzido and (animador_combo.is_playing() or animador_barreira.is_playing()):
		animador_combo.stop()
		animador_barreira.stop()
		painel_stats.set("impacto_combo", 0.0)
		painel_stats.set("impacto_barreira", 0.0)
	if _pronto and animar and painel_energia.is_visible_in_tree():
		if energia != _energia:
			_pulso(painel_energia, "impacto_energia", 0.27 if energia < _energia else 0.36)
			if not reduzido:
				_salto("EnergiaVisualLabel", 1.08 if energia < _energia else 1.12)
		if barreira > _barreira:
			painel_stats.set("quebra_barreira", false)
			_animar_recurso(animador_barreira, "barreira_ganho", "impacto_barreira")
		if combo > _combo:
			painel_stats.set("combo_origem", minf(float(_combo), float(painel_stats.get("combo_visual"))))
			painel_stats.set("consumindo_combo", false)
			_animar_recurso(animador_combo, "combo_ganho", "impacto_combo")
	_energia = energia
	_barreira = barreira
	_combo = combo
	_pronto = true


func consumir_combo() -> void:
	painel_stats.set("combo_descarga", maxf(float(_combo), float(painel_stats.get("combo_visual"))))
	painel_stats.set("consumindo_combo", true)
	_animar_recurso(animador_combo, "combo_consumo", "impacto_combo")


func absorver_barreira(quantidade: int, quebrou: bool) -> void:
	if quantidade <= 0:
		return
	painel_stats.set("quebra_barreira", quebrou)
	_animar_recurso(animador_barreira, "barreira_quebra" if quebrou else "barreira_impacto", "impacto_barreira")


func reiniciar() -> void:
	animador_combo.stop()
	animador_barreira.stop()
	for chave: String in _tweens.keys():
		_cancelar(chave)
	for nome: String in ["EnergiaVisualLabel"]:
		(_raiz.get_node(nome) as Control).scale = Vector2.ONE
	painel_energia.set("impacto_energia", 0.0)
	painel_stats.set("impacto_barreira", 0.0)
	painel_stats.set("impacto_combo", 0.0)
	painel_stats.set("quebra_barreira", false)
	painel_stats.set("consumindo_combo", false)
	painel_stats.set("combo_origem", 0.0)
	painel_stats.set("combo_descarga", 0.0)
	painel_stats.set("progresso_descarga", 0.0)
	_pronto = false


func _animar_recurso(animador: AnimationPlayer, animacao: String, propriedade: String) -> void:
	if not painel_stats.is_visible_in_tree():
		return
	_cancelar(propriedade)
	animador.stop()
	if bool(_raiz.get("movimento_reduzido")):
		_pulso(painel_stats, propriedade, 0.12)
		return
	animador.play(animacao)
	animador.advance(0.0)


func _pulso(controle: Control, propriedade: String, duracao: float) -> void:
	_cancelar(propriedade)
	controle.set(propriedade, 1.0)
	var tween: Tween = create_tween()
	tween.tween_property(controle, propriedade, 0.0, duracao).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tweens[propriedade] = tween


func _salto(nome: String, escala: float) -> void:
	_cancelar(nome)
	var controle: Control = _raiz.get_node(nome) as Control
	controle.pivot_offset = controle.size * 0.5
	controle.scale = Vector2.ONE
	var tween: Tween = create_tween()
	tween.tween_property(controle, "scale", Vector2.ONE * escala, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(controle, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tweens[nome] = tween


func _cancelar(chave: String) -> void:
	if not _tweens.has(chave):
		return
	var tween: Tween = _tweens[chave]
	if tween != null and tween.is_valid():
		tween.kill()
	_tweens.erase(chave)
