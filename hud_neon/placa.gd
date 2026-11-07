@tool
extends Control
## Desenha somente a camada visual da HUD; os numeros chegam do combate.

@export_enum("topo", "inimigo", "recursos", "energia", "mao") var modo: String = "topo":
	set(valor):
		modo = valor
		queue_redraw()

var energia_atual: int = 0:
	set(valor):
		energia_atual = valor
		queue_redraw()
var energia_maxima: int = 4:
	set(valor):
		energia_maxima = maxi(1, valor)
		queue_redraw()
var barreira_atual: int = 0:
	set(valor):
		barreira_atual = valor
		queue_redraw()
var combo_atual: int = 0:
	set(valor):
		combo_atual = valor
		queue_redraw()
var energia_visual: float = 0.0:
	set(valor):
		energia_visual = maxf(0.0, valor)
		queue_redraw()
var barreira_visual: float = 0.0:
	set(valor):
		barreira_visual = maxf(0.0, valor)
		queue_redraw()
var combo_visual: float = 0.0:
	set(valor):
		combo_visual = maxf(0.0, valor)
		queue_redraw()
var impacto_energia: float = 0.0:
	set(valor):
		impacto_energia = clampf(valor, 0.0, 1.0)
		queue_redraw()
var impacto_barreira: float = 0.0:
	set(valor):
		impacto_barreira = clampf(valor, 0.0, 1.0)
		queue_redraw()
var impacto_combo: float = 0.0:
	set(valor):
		impacto_combo = clampf(valor, 0.0, 1.0)
		queue_redraw()
var quebra_barreira: bool = false:
	set(valor):
		quebra_barreira = valor
		queue_redraw()
var combo_origem: float = 0.0
var combo_descarga: float = 0.0
var consumindo_combo: bool = false
var movimento_reduzido: bool = false
var progresso_descarga: float = 0.0:
	set(valor):
		progresso_descarga = clampf(valor, 0.0, 1.0)
		queue_redraw()
var _valores_preparados: bool = false
var _tweens_valores: Dictionary = {}
var _destinos_valores: Dictionary = {}

const CIANO: Color = Color("22e8f5")
const ROSA: Color = Color("f322b5")
const VIOLETA: Color = Color("ab54f5")
const TINTA: Color = Color("070a19")
const TRILHO: Color = Color("26304c")
const DURACAO_CARGA: float = 0.24
const DURACAO_DESCARGA: float = 0.16


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func animar_valores(animar: bool = true) -> void:
	var destinos: Dictionary = {
		"energia_visual": float(energia_atual),
		"barreira_visual": float(barreira_atual),
		"combo_visual": float(combo_atual)
	}
	for propriedade: String in destinos.keys():
		var tween_anterior: Tween = _tweens_valores.get(propriedade) as Tween
		var destino: float = float(destinos[propriedade])
		# Uma atualização de outra parte da HUD não reinicia a carga em andamento.
		if animar and _destinos_valores.get(propriedade) == destino and tween_anterior != null and tween_anterior.is_valid():
			continue
		if tween_anterior != null and tween_anterior.is_valid():
			tween_anterior.kill()
		_destinos_valores[propriedade] = destino
		if not _valores_preparados or not animar or not is_visible_in_tree():
			set(propriedade, destino)
		elif not is_equal_approx(float(get(propriedade)), destino):
			var tween: Tween = create_tween()
			var duracao: float = DURACAO_CARGA if destino > float(get(propriedade)) else DURACAO_DESCARGA
			tween.tween_property(self, propriedade, destino, duracao).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			_tweens_valores[propriedade] = tween
	_valores_preparados = true


func _draw() -> void:
	match modo:
		"recursos":
			_desenhar_recursos()
		"energia":
			_desenhar_energia()


func _desenhar_topo() -> void:
	var largura: float = size.x
	var altura: float = size.y
	_desenhar_moldura(Rect2(0.0, 0.0, largura * 0.325, altura), CIANO, 0.94)
	_desenhar_moldura(Rect2(largura * 0.335, altura * 0.12, largura * 0.325, altura * 0.76), VIOLETA, 0.90)
	_desenhar_moldura(Rect2(largura * 0.67, 0.0, largura * 0.33, altura), CIANO, 0.94)
	draw_line(Vector2(largura * 0.325 + 10.0, altura * 0.5), Vector2(largura * 0.335 - 3.0, altura * 0.5), ROSA, 2.0, true)
	draw_line(Vector2(largura * 0.66 + 3.0, altura * 0.5), Vector2(largura * 0.67 - 4.0, altura * 0.5), ROSA, 2.0, true)


func _desenhar_recursos() -> void:
	var painel: Control = get_parent() as Control
	var modulo_barreira: Control = painel.get_node_or_null("ModuloBarreira") as Control
	var modulo_combo: Control = painel.get_node_or_null("ModuloCombo") as Control
	if modulo_barreira == null or modulo_combo == null:
		return
	var area_barreira: Rect2 = _area_arte(modulo_barreira as TextureRect)
	var area_combo: Rect2 = _area_arte(modulo_combo as TextureRect)
	var escudo: PackedVector2Array = _pontos_na_area(area_barreira, PackedVector2Array([
		Vector2(0.25, 0.19), Vector2(0.39, 0.19), Vector2(0.464, 0.48),
		Vector2(0.39, 0.774), Vector2(0.25, 0.774), Vector2(0.174, 0.48)
	]))
	if impacto_barreira > 0.0:
		var cor_escudo: Color = VIOLETA if quebra_barreira else CIANO
		draw_colored_polygon(escudo, Color(cor_escudo, impacto_barreira * 0.23))
		_contornar(escudo, Color(cor_escudo, impacto_barreira), 2.0)
		if quebra_barreira and not movimento_reduzido:
			for indice: int in escudo.size():
				var inicio: Vector2 = escudo[indice]
				var fim: Vector2 = escudo[(indice + 1) % escudo.size()]
				var centro: Vector2 = area_barreira.position + area_barreira.size * Vector2(0.32, 0.48)
				var afastamento: Vector2 = ((inicio + fim) * 0.5 - centro).normalized() * (1.0 - impacto_barreira) * 5.0
				draw_line(inicio + afastamento, inicio.lerp(fim, 0.45) + afastamento, Color(CIANO, impacto_barreira), 2.0, true)
	# Cada célula representa até 5 pontos apenas visualmente; o número não tem teto.
	for indice: int in 3:
		var carga: float = clampf(barreira_visual / 5.0 - float(indice), 0.0, 1.0)
		var x: float = 0.612 + float(indice) * 0.132
		var celula: PackedVector2Array = _pontos_na_area(area_barreira, PackedVector2Array([
			Vector2(x - 0.025, 0.414), Vector2(x + 0.025, 0.414),
			Vector2(x + 0.047, 0.463), Vector2(x + 0.047, 0.555),
			Vector2(x + 0.025, 0.604), Vector2(x - 0.025, 0.604),
			Vector2(x - 0.047, 0.555), Vector2(x - 0.047, 0.463)
		]))
		if carga > 0.001:
			var preenchimento: PackedVector2Array = _recortar_carga(celula, lerpf(area_barreira.position.y + area_barreira.size.y * 0.604, area_barreira.position.y + area_barreira.size.y * 0.414, carga))
			if preenchimento.size() >= 3:
				draw_colored_polygon(preenchimento, Color(CIANO, 0.78))
			_contornar(celula, Color("9efbff", impacto_barreira * 0.8), 1.5)
	for indice: int in 7:
		var carga_combo: float = clampf(combo_visual - float(indice), 0.0, 1.0)
		var x: float = 0.309 + float(indice) * 0.089
		var segmento: PackedVector2Array = _pontos_na_area(area_combo, PackedVector2Array([
			Vector2(x, 0.352), Vector2(x + 0.068, 0.352),
			Vector2(x + 0.030, 0.656), Vector2(x - 0.038, 0.656)
		]))
		draw_colored_polygon(segmento, Color("10182f", 0.85))
		if carga_combo > 0.001:
			var topo: Vector2 = segmento[0].lerp(segmento[1], carga_combo)
			var base: Vector2 = segmento[3].lerp(segmento[2], carga_combo)
			draw_polygon(PackedVector2Array([segmento[0], topo, base, segmento[3]]), PackedColorArray([Color("ff83d8"), ROSA, Color("a70a88"), Color("cb0aa1")]))
			if carga_combo < 0.995 and not movimento_reduzido:
				draw_line(topo, base, Color("fff0fb"), 2.0, true)
		var ganho: bool = not consumindo_combo and float(indice) >= floorf(combo_origem) and float(indice) < float(combo_atual)
		if ganho and impacto_combo > 0.0:
			_contornar(segmento, Color(ROSA, impacto_combo * 0.35), 5.0)
			_contornar(segmento, Color("ffe5fa", impacto_combo), 1.5)
		if consumindo_combo and impacto_combo > 0.0 and float(indice) < combo_descarga:
			var frente: float = minf(combo_descarga, 7.0) * (1.0 - progresso_descarga)
			var intensidade: float = impacto_combo if movimento_reduzido else clampf(1.0 - absf(float(indice) + 0.5 - frente), 0.0, 1.0) * impacto_combo
			draw_colored_polygon(segmento, Color("fff0fb", intensidade * 0.75))
			_contornar(segmento, Color(ROSA, intensidade), 3.0)
	if combo_visual > 7.0:
		draw_circle(area_combo.position + Vector2(area_combo.size.x * 0.93, area_combo.size.y * 0.5), 3.0, CIANO)


func _area_arte(modulo: TextureRect) -> Rect2:
	var tamanho: Vector2 = modulo.texture.get_size()
	var ajuste: float = minf(modulo.size.x / tamanho.x, modulo.size.y / tamanho.y)
	var tamanho_real: Vector2 = tamanho * ajuste
	return Rect2(modulo.position + (modulo.size - tamanho_real) * 0.5, tamanho_real)


func _pontos_na_area(area: Rect2, pontos: PackedVector2Array) -> PackedVector2Array:
	var resultado: PackedVector2Array = PackedVector2Array()
	for ponto: Vector2 in pontos:
		resultado.append(area.position + ponto * area.size)
	return resultado


func _contornar(pontos: PackedVector2Array, cor: Color, espessura: float) -> void:
	var linha: PackedVector2Array = pontos.duplicate()
	linha.append(pontos[0])
	draw_polyline(linha, cor, espessura, true)


func _recortar_carga(pontos: PackedVector2Array, y_minimo: float) -> PackedVector2Array:
	var resultado: PackedVector2Array = PackedVector2Array()
	var anterior: Vector2 = pontos[pontos.size() - 1]
	for atual: Vector2 in pontos:
		if (anterior.y >= y_minimo) != (atual.y >= y_minimo):
			resultado.append(anterior.lerp(atual, (y_minimo - anterior.y) / (atual.y - anterior.y)))
		if atual.y >= y_minimo:
			resultado.append(atual)
		anterior = atual
	return resultado


func _desenhar_energia() -> void:
	var centro: Vector2 = Vector2(size.x * 0.5, size.y * 0.39)
	# O número precisa de uma superfície escura estável sobre a ilustração luminosa.
	draw_circle(centro, size.x * 0.235, Color("071323f5"))
	draw_arc(centro, size.x * 0.245, -PI * 0.5, PI * 1.5, 48, Color(CIANO, 0.30), 1.5, true)
	var proporcao: float = clampf(energia_visual / float(energia_maxima), 0.0, 1.0)
	if proporcao > 0.001:
		draw_arc(centro, size.x * 0.265, -PI * 0.5, -PI * 0.5 + TAU * proporcao, 48, Color(CIANO, 0.95), 3.0, true)
	if impacto_energia > 0.0:
		draw_arc(centro, size.x * 0.34 + (1.0 - impacto_energia) * 7.0, -PI * 0.5, PI * 1.5, 48, Color(CIANO, impacto_energia), 3.0, true)
	var total: int = mini(energia_maxima, 5)
	for indice: int in total:
		var ponto: Vector2 = Vector2(size.x * (0.20 + float(indice) * 0.15), size.y * 0.86)
		var carga: float = clampf(energia_visual - float(indice), 0.0, 1.0)
		if carga > 0.0:
			draw_circle(ponto, size.x * 0.045 * carga, Color(CIANO, 0.86))


func _desenhar_mao() -> void:
	var largura: float = size.x
	var altura: float = size.y
	if largura < 40.0 or altura < 40.0:
		return
	var pontos: PackedVector2Array = PackedVector2Array([
		Vector2(25.0, 2.0), Vector2(largura * 0.39, 2.0),
		Vector2(largura * 0.41, 11.0), Vector2(largura * 0.59, 11.0),
		Vector2(largura * 0.61, 2.0), Vector2(largura - 25.0, 2.0),
		Vector2(largura - 2.0, 25.0), Vector2(largura - 2.0, altura - 17.0),
		Vector2(largura - 19.0, altura - 2.0), Vector2(19.0, altura - 2.0),
		Vector2(2.0, altura - 17.0), Vector2(2.0, 25.0)
	])
	draw_colored_polygon(pontos, Color("080c22dd"))
	var contorno: PackedVector2Array = pontos.duplicate()
	contorno.append(pontos[0])
	draw_polyline(contorno, VIOLETA, 3.0, true)
	draw_line(Vector2(23.0, 2.0), Vector2(largura * 0.22, 2.0), CIANO, 4.0, true)
	draw_line(Vector2(largura * 0.66, 2.0), Vector2(largura - 26.0, 2.0), ROSA, 4.0, true)
	draw_line(Vector2(36.0, altura - 3.0), Vector2(largura * 0.34, altura - 3.0), ROSA, 4.0, true)
	draw_line(Vector2(largura * 0.68, altura - 3.0), Vector2(largura - 36.0, altura - 3.0), CIANO, 4.0, true)
	for lado: int in 2:
		var x: float = 13.0 if lado == 0 else largura - 13.0
		draw_line(Vector2(x, 35.0), Vector2(x, altura - 29.0), ROSA if lado == 0 else CIANO, 4.0, true)
	for indice: int in 13:
		var ponto: Vector2 = Vector2(largura * 0.43 + float(indice) * 7.0, 5.0)
		draw_circle(ponto, 1.0, Color(ROSA, 0.35))


func _desenhar_moldura(area: Rect2, cor: Color, opacidade: float) -> void:
	if area.size.x < 28.0 or area.size.y < 24.0:
		return
	var x: float = area.position.x + 2.0
	var y: float = area.position.y + 2.0
	var w: float = area.size.x - 4.0
	var h: float = area.size.y - 4.0
	var pontos: PackedVector2Array = PackedVector2Array([
		Vector2(x + 13.0, y), Vector2(x + w - 10.0, y),
		Vector2(x + w, y + 10.0), Vector2(x + w, y + h - 12.0),
		Vector2(x + w - 12.0, y + h), Vector2(x + 12.0, y + h),
		Vector2(x, y + h - 12.0), Vector2(x, y + 13.0)
	])
	draw_colored_polygon(pontos, Color(TINTA, opacidade))
	var contorno: PackedVector2Array = pontos.duplicate()
	contorno.append(pontos[0])
	draw_polyline(contorno, Color(cor, 0.83), 2.0, true)
	draw_line(Vector2(x + 18.0, y), Vector2(x + minf(69.0, w * 0.35), y), cor, 4.0, true)
	draw_line(Vector2(x + w - 45.0, y + h), Vector2(x + w - 17.0, y + h), ROSA, 3.0, true)
	draw_line(Vector2(x + 8.0, y + h - 7.0), Vector2(x + 23.0, y + h - 7.0), Color(cor, 0.45), 1.0, true)
	for indice: int in 4:
		var ponto: Vector2 = Vector2(x + w - 23.0 + float(indice % 2) * 6.0, y + 13.0 + float(indice / 2) * 6.0)
		draw_circle(ponto, 1.0, Color(cor, 0.45))


func _desenhar_canto(posicao: Vector2, cor: Color) -> void:
	for indice: int in 3:
		var inicio: Vector2 = posicao + Vector2(float(indice) * 5.0, 0.0)
		draw_line(inicio, inicio + Vector2(7.0, -7.0), Color(cor, 0.6), 2.0, true)
