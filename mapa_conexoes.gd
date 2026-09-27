extends Control

const COR_FUTURA: Color = Color("#56636d")
const COR_DISPONIVEL: Color = Color("#27d9ef")
const COR_PERCORRIDA: Color = Color("#78e8dc")

var segmentos: Array[Dictionary] = []


func configurar(
	conexoes: Dictionary,
	posicoes: Dictionary,
	estados: Dictionary
) -> void:
	segmentos.clear()
	for origem_variant in conexoes.keys():
		var origem: String = str(origem_variant)
		for destino_variant in conexoes[origem]:
			var destino: String = str(destino_variant)
			var chave: String = "%s>%s" % [origem, destino]
			segmentos.append({
				"origem": origem,
				"destino": destino,
				"estado": str(estados.get(chave, "futura"))
			})
	queue_redraw()


func atualizar_posicoes(posicoes: Dictionary) -> void:
	for segmento in segmentos:
		var origem: String = str(segmento.get("origem", ""))
		var destino: String = str(segmento.get("destino", ""))
		segmento["posicao_origem"] = posicoes.get(origem, Vector2.ZERO)
		segmento["posicao_destino"] = posicoes.get(destino, Vector2.ZERO)
	queue_redraw()


func _draw() -> void:
	for segmento in segmentos:
		if not segmento.has("posicao_origem") or not segmento.has("posicao_destino"):
			continue
		var estado: String = str(segmento.get("estado", "futura"))
		var cor: Color = COR_FUTURA
		var largura: float = 2.0
		if estado == "disponivel":
			cor = COR_DISPONIVEL
			largura = 3.0
		elif estado == "percorrida":
			cor = COR_PERCORRIDA
			largura = 3.0
		draw_line(
			segmento["posicao_origem"] as Vector2,
			segmento["posicao_destino"] as Vector2,
			cor,
			largura,
			true
		)
