extends "res://vega_animada/rig_nativo_v2/preview.gd"


func _desenhar_ossos() -> void:
	super._desenhar_ossos()
	if not is_instance_valid(ossos) or not ossos.button_pressed:
		return
	for rig: BracoNativoV2 in [braco, zoom]:
		var corpo: DoisBracosNativoV2 = rig as DoisBracosNativoV2
		var pontos: PackedVector2Array = PackedVector2Array()
		for osso: Bone2D in [corpo.tronco, corpo.clavicula_distante, corpo.deltoide_distante,
				corpo.braco_distante.cotovelo, corpo.braco_distante.punho]:
			pontos.append(sobreposicao.to_local(osso.global_position))
		sobreposicao.draw_polyline(pontos, Color(.6, .65, 1, .9), 2, true)
		for ponto: Vector2 in pontos:
			sobreposicao.draw_circle(ponto, 4, Color(.6, .65, 1))


func _atualizar_estado() -> void:
	estado.text = "Pose: %s | Dois braços / guarda assimétrica | Pés fixos | Sem Combo nesta prova" % braco.pose_atual
