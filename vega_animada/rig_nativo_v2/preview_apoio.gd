extends "res://vega_animada/rig_nativo_v2/preview_combo.gd"


func _layout() -> void:
	super._layout()
	if not is_instance_valid(zoom):
		return
	# Detalhe inferior com enquadramento fixo: nenhuma câmera segue o golpe.
	var painel: Control = $ZoomPanel
	var fator: float = minf(painel.size.x / 730, painel.size.y / 580)
	zoom.scale = Vector2.ONE * fator
	zoom.position = Vector2((painel.size.x - 730 * fator) * .5, -280 * fator)


func _desenhar_ossos() -> void:
	if not is_instance_valid(ossos) or not ossos.button_pressed:
		return
	# Só as cadeias de apoio; não desenhar braços fora do recorte do zoom.
	for base: BracoNativoV2 in [braco, zoom]:
		var rig: ApoioCorporalNativoV2 = base as ApoioCorporalNativoV2
		for cadeia: Array in [[rig.pelve, rig.joelho_tras, rig.sola_tras], [rig.pelve, rig.joelho_frente, rig.sola_frente]]:
			var pontos: PackedVector2Array = PackedVector2Array()
			for no: Node2D in cadeia:
				pontos.append(sobreposicao.to_local(no.global_position))
			sobreposicao.draw_polyline(pontos, Color(1, .7, .2), 2, true)
			for ponto: Vector2 in pontos:
				sobreposicao.draw_circle(ponto, 4, Color(.25, 1, .85))


func _atualizar_estado() -> void:
	var rig: ApoioCorporalNativoV2 = braco as ApoioCorporalNativoV2
	estado.text = "Combo %d | Quadril e joelhos participam / solas fixas | Pose: %s" % [rig.combo, rig.pose_atual]
