@tool
extends Control
## Moldura vetorial com tinta e retícula. Só redesenha quando necessário.
@export var energia: bool = false
var impacto_energia: float = 0.0:
	set(valor):
		impacto_energia = valor
		queue_redraw()
var impacto_barreira: float = 0.0:
	set(valor):
		impacto_barreira = valor
		queue_redraw()
var impacto_combo: float = 0.0:
	set(valor):
		impacto_combo = valor
		queue_redraw()
var quebra_barreira: bool = false
const AMBAR: Color = Color("e5b65c")
const AZUL: Color = Color("8faebc")
const LARANJA: Color = Color("ef8a50")
const TINTA: Color = Color("080c11")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	if energia:
		moldura(Rect2(Vector2.ZERO, size), AMBAR, impacto_energia)
	else:
		moldura(Rect2(0, 0, 108, size.y), AZUL, impacto_barreira)
		moldura(Rect2(116, 0, maxf(0.0, size.x - 116.0), size.y), LARANJA, impacto_combo)
		if impacto_combo > 0.0:
			estampido(Vector2(132, 36), LARANJA, impacto_combo)
		if impacto_barreira > 0.0 and quebra_barreira:
			fragmentos(Vector2(36, 35), impacto_barreira)

func moldura(area: Rect2, cor: Color, pulso: float) -> void:
	var x: float = area.position.x + 2.0
	var y: float = area.position.y + 2.0
	var w: float = area.size.x - 6.0
	var h: float = area.size.y - 6.0
	if w < 16 or h < 16:
		return
	var pontos: PackedVector2Array = PackedVector2Array([
		Vector2(x + 7, y), Vector2(x + w, y), Vector2(x + w, y + h - 8),
		Vector2(x + w - 8, y + h), Vector2(x, y + h), Vector2(x, y + 7)
	])
	var sombra: PackedVector2Array = pontos.duplicate()
	for i in sombra.size():
		sombra[i] += Vector2(2, 2)
	draw_colored_polygon(sombra, TINTA)
	var fundo: Color = Color("171d24").lerp(cor.darkened(0.62), pulso * 0.55)
	draw_colored_polygon(pontos, fundo)
	var contorno: PackedVector2Array = pontos.duplicate()
	contorno.append(pontos[0])
	draw_polyline(contorno, TINTA, 5.0, true)
	draw_polyline(contorno, cor.darkened(0.36).lerp(cor, pulso), 1.25, true)
	# Tinta e retícula ficam nas margens; o centro dos números permanece limpo.
	draw_line(Vector2(x + 10, y), Vector2(x + 39, y), cor, 3.0, true)
	draw_line(Vector2(x + 5, y + h - 2), Vector2(x + 21, y + h - 2), cor.darkened(0.3), 2.0, true)
	for linha in 3:
		for coluna in 4:
			var ponto: Vector2 = Vector2(x + w - 7 - coluna * 4, y + 6 + linha * 4)
			draw_circle(ponto, 0.65, Color(cor, 0.14))
	for i in 2:
		var origem: Vector2 = Vector2(x + w - 15 - i * 6, y + h - 2)
		draw_line(origem, origem + Vector2(4, -4), cor.darkened(0.18), 1.5, true)

func estampido(centro: Vector2, cor: Color, intensidade: float) -> void:
	var progresso: float = 1.0 - intensidade
	for i in 7:
		var direcao: Vector2 = Vector2.from_angle(float(i) * TAU / 7.0 - 0.3)
		var inicio: Vector2 = centro + direcao * (14.0 + progresso * 8.0)
		var fim: Vector2 = centro + direcao * (22.0 + progresso * 10.0)
		draw_line(inicio, fim, Color(cor, intensidade), 2.0 * intensidade, true)

func fragmentos(centro: Vector2, intensidade: float) -> void:
	for i in 5:
		var direcao: Vector2 = Vector2.from_angle(float(i) * TAU / 5.0)
		var ponto: Vector2 = centro + direcao * (15.0 + (1.0 - intensidade) * 13.0)
		var forma: PackedVector2Array = PackedVector2Array([ponto, ponto + Vector2(3, -3), ponto + Vector2(4, 2)])
		draw_colored_polygon(forma, Color(AZUL, intensidade))
