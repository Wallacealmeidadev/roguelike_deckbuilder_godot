@tool
extends Control
## Indicador passivo; a regra de Energia permanece em JogadorCombate.
@export var atual: int = 4:
	set(valor):
		atual = valor
		queue_redraw()
@export var maxima: int = 4:
	set(valor):
		maxima = valor
		queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var quantidade: int = mini(maxi(maxima, atual), 12)
	if quantidade <= 0:
		return
	var passo: float = minf(18.0, size.x / float(quantidade))
	var raio: float = minf(5.0, passo * 0.32)
	for indice in quantidade:
		var centro: Vector2 = Vector2(passo * (float(indice) + 0.5), size.y * 0.5)
		draw_circle(centro, raio, Color("e4bd72") if indice < atual else Color("30373f"))
		draw_arc(centro, raio, 0.0, TAU, 20, Color("8b9299"), 1.0, true)
