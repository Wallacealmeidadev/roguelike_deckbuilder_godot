extends Control

const COR_PISO: Color = Color(0.10, 0.15, 0.19, 0.72)
const COR_LINHA: Color = Color(0.33, 0.45, 0.52, 0.38)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var horizonte: float = size.y * 0.37
	var ponto_fuga: Vector2 = Vector2(size.x * 0.5, horizonte)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0.0, horizonte),
			Vector2(size.x, horizonte),
			Vector2(size.x, size.y),
			Vector2(0.0, size.y)
		]),
		COR_PISO
	)

	for indice in range(9):
		var destino_x: float = size.x * (0.12 + float(indice) * 0.095)
		draw_line(ponto_fuga, Vector2(destino_x, size.y), COR_LINHA, 1.0)

	for indice in range(1, 6):
		var progresso: float = float(indice) / 6.0
		var y: float = lerpf(horizonte, size.y, progresso * progresso)
		draw_line(Vector2(0.08 * size.x, y), Vector2(0.92 * size.x, y), COR_LINHA, 1.0)
