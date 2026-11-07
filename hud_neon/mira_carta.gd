extends Control
## Mira de seleção: recebe pontos do controlador e nunca captura o clique.

var origem: Vector2
var destino: Vector2
var centro_alvo: Vector2
var raio_alvo: float = 0.0
var alvo_valido: bool = false
var cor: Color = Color("f322b5")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 40
	hide()


func apontar(inicio: Vector2, fim: Vector2, valido: bool, cor_carta: Color, raio: float) -> void:
	origem = inicio
	centro_alvo = fim
	alvo_valido = valido
	cor = cor_carta if valido else Color("a2b4c8", 0.72)
	raio_alvo = raio if valido else 0.0
	destino = fim
	if valido:
		destino -= (fim - inicio).normalized() * (raio_alvo + 8.0)
	show()
	queue_redraw()


func _draw() -> void:
	var distancia: float = origem.distance_to(destino)
	if distancia < 16.0:
		return
	var escala: float = clampf(get_viewport_rect().size.y / 720.0, 0.8, 1.3)
	var curva_a: Vector2 = origem + Vector2(0.0, -minf(150.0 * escala, distancia * 0.4))
	var curva_b: Vector2 = destino + Vector2(-signf(destino.x - origem.x) * minf(90.0 * escala, distancia * 0.18), 35.0 * escala)
	var pontos: PackedVector2Array = PackedVector2Array()
	for indice: int in 33:
		var t: float = float(indice) / 32.0
		var u: float = 1.0 - t
		pontos.append(origem * u * u * u + curva_a * 3.0 * u * u * t + curva_b * 3.0 * u * t * t + destino * t * t * t)
	draw_polyline(pontos, Color("050b19", 0.80), 7.0 * escala, true)
	draw_polyline(pontos, cor, 2.5 * escala, true)
	var direcao: Vector2 = (destino - pontos[31]).normalized()
	var lateral: Vector2 = Vector2(-direcao.y, direcao.x)
	var ponta: PackedVector2Array = PackedVector2Array([
		destino,
		destino - direcao * 18.0 * escala + lateral * 7.0 * escala,
		destino - direcao * 13.0 * escala,
		destino - direcao * 18.0 * escala - lateral * 7.0 * escala
	])
	draw_colored_polygon(ponta, cor)
	if alvo_valido:
		for canto: int in 4:
			var angulo: float = float(canto) * PI * 0.5 + 0.18
			draw_arc(centro_alvo, raio_alvo, angulo, angulo + 0.85, 10, Color("050b19", 0.80), 6.0 * escala, true)
			draw_arc(centro_alvo, raio_alvo, angulo, angulo + 0.85, 10, cor, 2.0 * escala, true)
