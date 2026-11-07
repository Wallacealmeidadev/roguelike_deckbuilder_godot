@tool
extends Control

@export var preencher: bool = true:
	set(valor):
		preencher = valor
		queue_redraw()

@export var cor_linha: Color = Color("19e5ff"):
	set(valor):
		cor_linha = valor
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var largura: float = size.x
	var altura: float = size.y
	if largura < 64.0 or altura < 64.0:
		return
	var corte: float = minf(25.0, minf(largura, altura) * 0.07)
	var forma: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, corte), Vector2(corte, 0.0),
		Vector2(largura - corte, 0.0), Vector2(largura, corte),
		Vector2(largura, altura - corte), Vector2(largura - corte, altura),
		Vector2(corte, altura), Vector2(0.0, altura - corte)
	])
	if preencher:
		draw_colored_polygon(forma, Color("0d1430f2"))
	var contorno: PackedVector2Array = forma.duplicate()
	contorno.append(forma[0])
	draw_polyline(contorno, Color("02040e"), 8.0, true)
	draw_polyline(contorno, cor_linha.darkened(0.18), 2.0, true)
	draw_line(Vector2(corte + 24.0, 4.0), Vector2(minf(largura * 0.42, corte + 210.0), 4.0), Color("ff27c7"), 4.0, true)
	draw_line(Vector2(largura - corte - 112.0, altura - 4.0), Vector2(largura - corte - 26.0, altura - 4.0), Color("8e45ff"), 4.0, true)
	draw_line(Vector2(13.0, corte + 12.0), Vector2(13.0, minf(altura - corte - 12.0, corte + 65.0)), Color("19e5ff"), 2.0, true)
