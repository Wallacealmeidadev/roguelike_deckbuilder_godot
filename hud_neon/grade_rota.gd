@tool
extends Control
## Fundo ornamental da rota. A quantidade de colunas vem de MapaRun.

@export var total_pontos: int = 11:
	set(valor):
		total_pontos = maxi(2, valor)
		queue_redraw()

const CIANO: Color = Color("22e8f5")
const ROSA: Color = Color("f322b5")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	if size.x < 140.0 or size.y < 100.0:
		return
	var margem: float = 3.0
	var w: float = size.x - margem * 2.0
	var h: float = size.y - margem * 2.0
	var contorno: PackedVector2Array = PackedVector2Array([
		Vector2(margem + 18.0, margem), Vector2(margem + w - 18.0, margem),
		Vector2(margem + w, margem + 18.0), Vector2(margem + w, margem + h - 18.0),
		Vector2(margem + w - 18.0, margem + h), Vector2(margem + 18.0, margem + h),
		Vector2(margem, margem + h - 18.0), Vector2(margem, margem + 18.0)
	])
	draw_colored_polygon(contorno, Color("071020e8"))
	var borda: PackedVector2Array = contorno.duplicate()
	borda.append(contorno[0])
	draw_polyline(borda, Color(CIANO, 0.45), 2.0, true)
	draw_line(Vector2(32.0, 3.0), Vector2(minf(size.x * 0.24, 220.0), 3.0), CIANO, 3.0, true)
	draw_line(Vector2(size.x - 164.0, size.y - 3.0), Vector2(size.x - 31.0, size.y - 3.0), ROSA, 3.0, true)
	var linha_y: float = size.y * 0.5
	draw_line(Vector2(20.0, linha_y), Vector2(size.x - 20.0, linha_y), Color(CIANO, 0.13), 1.0, true)
	for indice: int in total_pontos:
		var x: float = lerpf(52.0, size.x - 52.0, float(indice) / float(total_pontos - 1))
		draw_line(Vector2(x, 24.0), Vector2(x, size.y - 32.0), Color(CIANO, 0.10), 1.0, true)
		draw_circle(Vector2(x, size.y - 25.0), 2.0, Color(ROSA, 0.38))
