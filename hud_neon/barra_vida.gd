extends Control
## Camada visual: o ProgressBar irmão conserva o valor real para regras e inspeção.

@export_enum("jogador", "inimigo") var modo: String = "inimigo":
	set(valor):
		modo = valor
		queue_redraw()

var proporcao_visual: float = 1.0:
	set(valor):
		proporcao_visual = clampf(valor, 0.0, 1.0)
		queue_redraw()
var proporcao_alvo: float = 1.0
var proporcao_rastro: float = 1.0:
	set(valor):
		proporcao_rastro = clampf(valor, 0.0, 1.0)
		queue_redraw()
var impacto: float = 0.0:
	set(valor):
		impacto = clampf(valor, 0.0, 1.0)
		queue_redraw()
var curando: bool = false
var _preparada: bool = false
var _tween: Tween
var _tween_rastro: Tween
var _tween_impacto: Tween

const ROSA: Color = Color("f322b5")
const CIANO: Color = Color("22e8f5")
const FUNDO: Color = Color("080d21")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func definir_valor(atual: int, maximo: int, animar: bool = true) -> void:
	var destino: float = clampf(float(atual) / float(maxi(1, maximo)), 0.0, 1.0)
	if not _preparada or not animar or not is_visible_in_tree():
		_cancelar_transicoes()
		_preparada = true
		proporcao_alvo = destino
		proporcao_visual = destino
		proporcao_rastro = destino
		impacto = 0.0
		return
	# Compra, seleção e atualização de recursos não reiniciam uma perda de Vida.
	if is_equal_approx(proporcao_alvo, destino):
		return
	curando = destino > proporcao_alvo
	proporcao_alvo = destino
	_cancelar_transicoes()
	_tween = create_tween()
	_tween.tween_property(self, "proporcao_visual", destino, 0.24 if curando else 0.20).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if modo == "jogador" and not curando:
		proporcao_rastro = maxf(proporcao_rastro, proporcao_visual)
		_tween_rastro = create_tween()
		_tween_rastro.tween_interval(0.06)
		_tween_rastro.tween_property(self, "proporcao_rastro", destino, 0.20).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		proporcao_rastro = destino
	if modo == "jogador":
		impacto = 1.0
		_tween_impacto = create_tween()
		_tween_impacto.tween_property(self, "impacto", 0.0, 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _cancelar_transicoes() -> void:
	for transicao: Tween in [_tween, _tween_rastro, _tween_impacto]:
		if transicao != null and transicao.is_valid():
			transicao.kill()


func _draw() -> void:
	if size.x < 8.0 or size.y < 4.0:
		return
	if modo == "jogador":
		_desenhar_vida_integrada()
	else:
		_desenhar_preenchimento_inimigo()


func _desenhar_vida_integrada() -> void:
	var w: float = size.x
	var h: float = size.y
	var coracao: float = minf(h * 1.12, w * 0.18)
	var contorno: PackedVector2Array = PackedVector2Array([Vector2(0.50, 0.23)])
	_curva(contorno, Vector2(0.50, 0.23), Vector2(0.30, -0.03), Vector2(0.02, -0.01), Vector2(0.02, 0.28))
	_curva(contorno, Vector2(0.02, 0.28), Vector2(0.0, 0.50), Vector2(0.22, 0.76), Vector2(0.50, 0.98))
	_curva(contorno, Vector2(0.50, 0.98), Vector2(0.63, 0.86), Vector2(0.76, 0.87), Vector2(0.98, 0.87))
	for indice: int in contorno.size():
		contorno[indice] *= Vector2(coracao, h)
	contorno.append_array(PackedVector2Array([
		Vector2(w - 7.0, h * 0.87), Vector2(w - 2.0, h * 0.73),
		Vector2(w - 2.0, h * 0.29), Vector2(w - 7.0, h * 0.15), Vector2(coracao * 1.02, h * 0.15)
	]))
	var lobo_direito: PackedVector2Array = PackedVector2Array()
	_curva(lobo_direito, Vector2(1.02, 0.15), Vector2(0.94, -0.03), Vector2(0.65, -0.03), Vector2(0.50, 0.23))
	for ponto: Vector2 in lobo_direito:
		contorno.append(ponto * Vector2(coracao, h))
	contorno.remove_at(contorno.size() - 1)
	draw_colored_polygon(contorno, FUNDO)
	var linha: PackedVector2Array = contorno.duplicate()
	linha.append(contorno[0])
	draw_polyline(linha, ROSA, 1.5, true)
	var miolo: PackedVector2Array = PackedVector2Array([Vector2(0.50, 0.33)])
	_curva(miolo, Vector2(0.50, 0.33), Vector2(0.31, 0.10), Vector2(0.15, 0.13), Vector2(0.15, 0.33))
	_curva(miolo, Vector2(0.15, 0.33), Vector2(0.15, 0.46), Vector2(0.31, 0.64), Vector2(0.50, 0.82))
	_curva(miolo, Vector2(0.50, 0.82), Vector2(0.69, 0.64), Vector2(0.85, 0.46), Vector2(0.85, 0.33))
	_curva(miolo, Vector2(0.85, 0.33), Vector2(0.85, 0.13), Vector2(0.69, 0.10), Vector2(0.50, 0.33))
	miolo.remove_at(miolo.size() - 1)
	for indice: int in miolo.size():
		miolo[indice] *= Vector2(coracao, h)
	draw_colored_polygon(miolo, Color(ROSA, 0.15 + proporcao_visual * 0.80))
	var inicio: float = coracao * 0.90
	var fim: float = w - 5.0
	var trilho: PackedVector2Array = PackedVector2Array([
		Vector2(inicio, h * 0.23), Vector2(w - 9.0, h * 0.23), Vector2(fim, h * 0.33),
		Vector2(fim, h * 0.69), Vector2(w - 9.0, h * 0.79), Vector2(inicio, h * 0.79)
	])
	draw_colored_polygon(trilho, Color("19263d"))
	if not curando and proporcao_rastro > proporcao_visual:
		_desenhar_carga(trilho, lerpf(inicio, fim, proporcao_rastro), Color("ffd0eb", 0.55), Color("ff71c6", 0.30))
	if proporcao_visual > 0.0:
		_desenhar_carga(trilho, lerpf(inicio, fim, proporcao_visual), Color("ff8cde"), Color("cc079b"))
	# O número usa contorno próprio: o trecho atrás dele continua mostrando a Vida.
	if impacto > 0.0:
		draw_polyline(linha, Color(CIANO if curando else Color("ffb0df"), impacto), 2.5, true)


func _curva(pontos: PackedVector2Array, inicio: Vector2, controle_a: Vector2, controle_b: Vector2, fim: Vector2) -> void:
	for passo: int in range(1, 9):
		var t: float = float(passo) / 8.0
		var u: float = 1.0 - t
		pontos.append(inicio * u * u * u + controle_a * 3.0 * u * u * t + controle_b * 3.0 * u * t * t + fim * t * t * t)


func _desenhar_carga(trilho: PackedVector2Array, limite_x: float, topo: Color, base: Color) -> void:
	# Nos últimos frames antes de zero, o recorte pode colapsar numa linha.
	if limite_x - trilho[0].x < 0.01:
		return
	var pontos: PackedVector2Array = PackedVector2Array()
	var anterior: Vector2 = trilho[trilho.size() - 1]
	for atual: Vector2 in trilho:
		if (anterior.x <= limite_x) != (atual.x <= limite_x):
			pontos.append(anterior.lerp(atual, (limite_x - anterior.x) / (atual.x - anterior.x)))
		if atual.x <= limite_x:
			pontos.append(atual)
		anterior = atual
	if pontos.size() < 3:
		return
	var cores: PackedColorArray = PackedColorArray()
	for ponto: Vector2 in pontos:
		cores.append(topo.lerp(base, clampf((ponto.y / size.y - 0.23) / 0.56, 0.0, 1.0)))
	draw_polygon(pontos, cores)


func _desenhar_preenchimento_inimigo() -> void:
	var largura: float = maxf(0.0, (size.x - 2.0) * proporcao_visual)
	if largura <= 0.0:
		return
	draw_rect(Rect2(1.0, 1.0, largura, maxf(2.0, size.y - 2.0)), ROSA)
	draw_line(Vector2(2.0, 1.0), Vector2(1.0 + largura, 1.0), Color("ff9ce6"), 1.0, true)
