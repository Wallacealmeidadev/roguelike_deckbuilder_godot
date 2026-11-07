extends Control
## Realce breve sobre a moldura; nunca intercepta mouse nem altera o layout.
var intensidade: float = 0.0:
	set(valor):
		intensidade = valor
		queue_redraw()
var cor: Color = Color("e5b65c")
var animacao: Tween
var origem: Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	origem = get_parent() as Control
	origem.mouse_entered.connect(atualizar)
	origem.mouse_exited.connect(atualizar)
	origem.focus_entered.connect(atualizar)
	origem.focus_exited.connect(atualizar)
	origem.visibility_changed.connect(atualizar)
	if origem is BaseButton:
		(origem as BaseButton).button_down.connect(pressionar)
		(origem as BaseButton).button_up.connect(atualizar)
	resized.connect(queue_redraw)

func atualizar() -> void:
	var ativo: bool = origem.is_visible_in_tree() and (origem.has_focus() or origem.get_global_rect().has_point(origem.get_global_mouse_position()))
	if origem is BaseButton and (origem as BaseButton).disabled:
		ativo = false
	if animacao and animacao.is_valid():
		animacao.kill()
	animacao = create_tween()
	animacao.tween_property(self, "intensidade", 1.0 if ativo else 0.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func pressionar() -> void:
	if animacao and animacao.is_valid():
		animacao.kill()
	intensidade = 0.3

func _draw() -> void:
	if intensidade <= 0.001:
		return
	var margem: float = lerpf(9.0, 2.0, intensidade)
	var comprimento: float = minf(21.0, size.x * 0.18)
	var tinta: Color = Color(cor, intensidade)
	for canto: Vector2 in [Vector2(margem, margem), size - Vector2(margem, margem)]:
		var direcao: float = 1.0 if canto.x < size.x * 0.5 else -1.0
		draw_line(canto, canto + Vector2(comprimento * direcao, 0), tinta, 2.0, true)
		draw_line(canto, canto + Vector2(0, 9 * direcao), tinta, 2.0, true)


