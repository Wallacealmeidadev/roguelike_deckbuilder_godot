extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("verificar")


func conferir(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error(mensagem)


func verificar() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	# Fixture do modelo anterior, preservada para comparação com o rig nativo.
	jogo.cena_apresentacao_vega = preload("res://prototipos/vega_2d/combate_v2/vega_combate.tscn")
	get_tree().root.add_child(jogo)
	get_tree().root.size = Vector2i(1024, 576)
	await get_tree().process_frame
	jogo._iniciar_combate_por_id("drone_carga", false)
	await get_tree().process_frame

	var vega: Control = jogo.jogador.get_node_or_null("VegaAnimada") as Control
	conferir(vega != null, "Vega nao aparece no campo")
	if vega != null:
		var visual: Control = vega.get_node_or_null("Visual") as Control
		var modelo: ModeloVegaCombateV2 = vega.get_node_or_null("Visual/Modelo") as ModeloVegaCombateV2
		var sombra: Panel = vega.get_node_or_null("Sombra") as Panel
		conferir(visual != null and modelo != null, "Vega nao usa contenedor e modelo v2")
		conferir(sombra != null and sombra.visible, "Vega nao tem contato visual com o piso")
		conferir(vega.get_node_or_null("Modelo/Skeleton2D") == null, "Rig segmentado continua no combate")
		conferir(vega.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Arte intercepta clique no jogador")
		conferir(not vega.has_node("Visual/Arte"), "Ilustracao antiga nao pode permanecer sob a Vega nova")
		if modelo != null:
			conferir(modelo.corpo.texture.resource_path == "res://vega_animada/combate_v2/base_e_punhos_01.png", "Corpo v2 nao foi integrado")
			conferir(modelo.braco_ataque != null and modelo.braco_guarda != null, "Falta um braco articulado")
		conferir(vega.estado_animacao == "repouso", "Vega nao inicia em repouso")
		var repouso: PackedVector2Array = modelo.corpo.polygon
		await get_tree().create_timer(1.5).timeout
		conferir(modelo.corpo.polygon != repouso, "repouso deve mostrar respiração localizada")
		conferir(visual.position.is_zero_approx(), "respiração não deve levantar os pés do piso")
		vega.socar()
		conferir(vega.estado_animacao == "soco", "Feedback de ataque nao inicia")
		vega.receber_dano()
		conferir(vega.estado_animacao == "dano", "Feedback de dano nao interrompe ataque")
		await get_tree().create_timer(0.11).timeout
		conferir(visual.modulate.b > 0.78 and visual.modulate.g < 0.78, "feedback de dano da Vega precisa acompanhar o magenta da HUD")
		vega.reiniciar()
		conferir(vega.estado_animacao == "repouso", "Vega nao reinicia em repouso")
	conferir(not jogo.has_node("Jogador/VegaCampoRetrato"), "Retrato legado duplicado voltou ao campo")

	jogo.queue_free()
	await get_tree().process_frame
	print("VEGA PLAYTEST: %d falhas" % falhas)
	get_tree().quit(1 if falhas else 0)
