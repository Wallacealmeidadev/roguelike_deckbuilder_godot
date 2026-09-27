extends Control

const BotaoCarta = preload("res://botao_carta.gd")
const INCLINACAO_MAXIMA: float = 0.06
const MARGEM_INFERIOR: float = 10.0


func _get_minimum_size() -> Vector2:
	# A mão ocupa uma faixa definida pelo HUD. As cartas podem se sobrepor
	# nessa faixa; o tamanho mínimo da soma dos filhos não deve expandi-la
	# para fora da viewport.
	return Vector2.ZERO


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_cartas()


func layout_cartas() -> void:
	_layout_cartas()


func _aplicar_curva() -> void:
	var quantidade: int = get_child_count()
	if quantidade < 2:
		return
	if quantidade > 6:
		for no in get_children():
			(no as Control).rotation = 0.0
		return
	var centro: float = float(quantidade - 1) * 0.5
	for indice in range(quantidade):
		var carta: Control = get_child(indice) as Control
		if carta == null:
			continue
		var deslocamento: float = float(indice) - centro
		var fator: float = deslocamento_normalizado(deslocamento, centro)
		carta.pivot_offset = Vector2(carta.size.x * 0.5, carta.size.y)
		carta.rotation = fator * INCLINACAO_MAXIMA


func _layout_cartas() -> void:
	var quantidade: int = get_child_count()
	if quantidade == 0 or size.x <= 0.0:
		return
	var margem: float = 16.0
	var largura_carta: float = 0.0
	var altura_carta: float = 0.0
	for no in get_children():
		var carta: Control = no as Control
		if carta != null:
			largura_carta = maxf(largura_carta, carta.size.x)
			altura_carta = maxf(altura_carta, carta.size.y)
	if largura_carta <= 0.0:
		return
	var largura_util: float = maxf(size.x - margem * 2.0, largura_carta)
	var passo_maximo: float = largura_carta + 3.0
	var passo: float = passo_maximo
	if quantidade > 1:
		var passo_disponivel: float = (largura_util - largura_carta) / float(quantidade - 1)
		passo = minf(passo_maximo, maxf(0.0, passo_disponivel))
	var grupo: float = passo * float(quantidade - 1) + largura_carta
	margem = maxf(margem, (size.x - grupo) * 0.5)
	for indice in range(quantidade):
		var carta: Control = get_child(indice) as Control
		if carta == null:
			continue
		carta.position.x = margem + passo * float(indice)
		carta.pivot_offset = Vector2(carta.size.x * 0.5, carta.size.y)
		var angulo_maximo: float = INCLINACAO_MAXIMA if quantidade <= 6 else 0.0
		var extensao_inferior: float = _extensao_inferior(carta.size, angulo_maximo, BotaoCarta.ESCALA_FOCO_COMBATE)
		carta.position.y = maxf(0.0, size.y - altura_carta - MARGEM_INFERIOR - extensao_inferior)
	if quantidade <= 6:
		_aplicar_curva()
	else:
		for no in get_children():
			(no as Control).rotation = 0.0


func deslocamento_normalizado(valor: float, limite: float) -> float:
	if is_zero_approx(limite):
		return 0.0
	return valor / limite


func _extensao_inferior(tamanho: Vector2, angulo: float, escala: float) -> float:
	var transformacao: Transform2D = Transform2D(angulo, Vector2.ZERO).scaled(Vector2.ONE * escala)
	var pivo: Vector2 = Vector2(tamanho.x * 0.5, tamanho.y)
	var extensao: float = 0.0
	for ponto in [Vector2.ZERO, Vector2(tamanho.x, 0.0), tamanho, Vector2(0.0, tamanho.y)]:
		extensao = maxf(extensao, (transformacao * (ponto - pivo)).y)
	return extensao
