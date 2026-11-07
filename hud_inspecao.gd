extends PanelContainer

const TAMANHO_MINIMO: Vector2 = Vector2(184.0, 88.0)
const MARGEM_VIEWPORT: float = 12.0

@onready var texto: Label = $Texto

var controle_atual: Control
var entrada: Tween
var titulo: Label
var _bloqueios: Array[Rect2] = []


func _ready() -> void:
	resized.connect(_ao_redimensionar)
	titulo = Label.new()
	titulo.name = "Titulo"
	titulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	titulo.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Bold.ttf"))
	titulo.add_theme_font_size_override("font_size", 12)
	titulo.add_theme_color_override("font_color", Color("22e8f5"))
	texto.add_child(titulo)
	titulo.position = Vector2(0, -23)


func _ao_redimensionar() -> void:
	call_deferred("reposicionar", _bloqueios)


func mostrar(controle: Control, mensagem: String, bloqueios: Array[Rect2] = []) -> void:
	_bloqueios.assign(bloqueios)
	if controle == null or mensagem.is_empty():
		hide()
		controle_atual = null
		return
	var mudou: bool = controle_atual != controle or not visible
	controle_atual = controle
	var quebra: int = mensagem.find("\n")
	titulo.text = mensagem.substr(0, quebra) if quebra >= 0 else "INFORMAÇÃO"
	texto.text = mensagem.substr(quebra + 1) if quebra >= 0 else mensagem
	show()
	if mudou:
		if entrada and entrada.is_valid():
			entrada.kill()
		modulate.a = 1.0 if controle.has_focus() else 0.0
		entrada = create_tween()
		entrada.tween_property(self, "modulate:a", 1.0, 0.0 if controle.has_focus() else 0.125).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	reset_size()
	queue_sort()
	var tamanho_minimo: Vector2 = get_combined_minimum_size()
	size = Vector2(maxf(tamanho_minimo.x, TAMANHO_MINIMO.x), maxf(tamanho_minimo.y, TAMANHO_MINIMO.y))
	global_position = _encontrar_posicao(controle.get_global_rect(), bloqueios)
	call_deferred("reposicionar", bloqueios)


func esconder(controle: Control = null) -> void:
	if controle != null and controle_atual != controle:
		return
	controle_atual = null
	hide()


func reposicionar(bloqueios: Array[Rect2] = []) -> void:
	if not visible or not is_instance_valid(controle_atual):
		return
	global_position = _encontrar_posicao(controle_atual.get_global_rect(), bloqueios)


func _encontrar_posicao(referencia: Rect2, bloqueios: Array[Rect2]) -> Vector2:
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var margem: float = MARGEM_VIEWPORT
	var candidatos: Array[Vector2] = [
		Vector2(referencia.position.x, referencia.position.y - size.y - margem),
		Vector2(referencia.position.x, referencia.end.y + margem),
		Vector2(referencia.position.x - size.x - margem, referencia.position.y),
		Vector2(referencia.end.x + margem, referencia.position.y),
		Vector2(referencia.position.x - size.x - 150.0, referencia.end.y + margem)
	]
	for candidato in candidatos:
		var area: Rect2 = Rect2(candidato, size)
		if viewport_rect.encloses(area) and not _colide_com_bloqueio(area, bloqueios):
			return candidato
	# Quando o entorno do ícone está ocupado, procurar um espaço livre no campo.
	var melhor: Vector2 = Vector2.ZERO
	var distancia: float = INF
	var posicoes_x: Array[float] = [margem, viewport_rect.end.x - size.x - margem]
	var posicoes_y: Array[float] = [margem, viewport_rect.end.y - size.y - margem]
	for bloqueio: Rect2 in bloqueios:
		posicoes_x.append(bloqueio.end.x + 8.0)
		posicoes_x.append(bloqueio.position.x - size.x - 8.0)
		posicoes_y.append(bloqueio.end.y + 8.0)
		posicoes_y.append(bloqueio.position.y - size.y - 8.0)
	for y: float in posicoes_y:
		for x: float in posicoes_x:
			var posicao: Vector2 = Vector2(x, y)
			if not viewport_rect.grow(-margem).encloses(Rect2(posicao, size)):
				continue
			if not _colide_com_bloqueio(Rect2(posicao, size), bloqueios):
				var distancia_atual: float = posicao.distance_squared_to(referencia.get_center())
				if distancia_atual < distancia:
					melhor = posicao
					distancia = distancia_atual
	if distancia < INF:
		return melhor
	var limitada: Vector2 = Vector2(
		clampf(candidatos[0].x, viewport_rect.position.x + MARGEM_VIEWPORT, viewport_rect.end.x - size.x - MARGEM_VIEWPORT),
		clampf(candidatos[0].y, viewport_rect.position.y + MARGEM_VIEWPORT, viewport_rect.end.y - size.y - MARGEM_VIEWPORT)
	)
	return limitada


func _colide_com_bloqueio(area: Rect2, bloqueios: Array[Rect2]) -> bool:
	for bloqueio in bloqueios:
		if area.grow(4.0).intersects(bloqueio.grow(4.0)):
			return true
	return false
