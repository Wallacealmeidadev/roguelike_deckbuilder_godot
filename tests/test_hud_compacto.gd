extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	_verificar(jogo.get("marcado_visual") == jogo.get_node("MarcadoVisual") and jogo.get("estado_especial_visual") == jogo.get_node("EstadoEspecialInimigo"), "indicadores especiais devem ser únicos, sem cópias ocultas por alvo")
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		jogo.call("_iniciar_combate_por_id", "carga", false)
		var jogador: JogadorCombate = jogo.get("jogador_combate") as JogadorCombate
		jogador.reliquias_run.assign(["juntas_retorno", "reservatorio_auxiliar", "mecanismo_recuo"])
		jogo.call("_atualizar_interface")
		await get_tree().process_frame
		await get_tree().process_frame
		var intencao: Control = jogo.get_node("IntencaoPainel") as Control
		for nome: String in ["IntencaoNomeVisualLabel", "IntencaoIcone", "IntencaoValorVisualLabel"]:
			_verificar(intencao.get_global_rect().encloses((jogo.get_node(nome) as Control).get_global_rect()), "o selo deve conter %s" % nome)
		var ids: Array[String] = DadosInimigos.identificadores()
		ids.append_array(DadosInimigos.identificadores_elite())
		for id_doca: String in DadosInimigos.DOCAS:
			ids.append(id_doca)
		var parceiro: InimigoCombate = InimigoCombate.new("drone_carga", DadosInimigos.obter("drone_carga"))
		for id: String in ids:
			var inimigo: InimigoCombate = InimigoCombate.new(id, DadosInimigos.obter(id))
			inimigo.aliados.append(weakref(parceiro))
			for indice: int in inimigo.ciclo.size():
				inimigo.indice_intencao = indice
				var leitura: Dictionary = jogo.call("_leitura_intencao", inimigo, inimigo.texto_intencao())
				for par: Array in [["tipo", "IntencaoNomeVisualLabel"], ["valor", "IntencaoValorVisualLabel"]]:
					var rotulo: Label = jogo.get_node(par[1]) as Label
					var largura: float = rotulo.get_theme_font("font").get_string_size(leitura[par[0]], HORIZONTAL_ALIGNMENT_LEFT, -1, rotulo.get_theme_font_size("font_size")).x
					_verificar(largura <= rotulo.size.x, "resumo %s deve caber sem cortar em %s" % [leitura, resolucao])
		for reliquia: Button in jogo.get_node("TopoCombate/TopoReliquias").get_children():
			_verificar(not reliquia.text.is_empty() and reliquia.icon != null, "relíquia precisa de ícone e identificação")
			jogo.call("_mostrar_inspecao_hud", reliquia)
			await get_tree().process_frame
			await get_tree().process_frame
			var inspecao: Control = jogo.get_node("HudInspecao") as Control
			_verificar(get_viewport().get_visible_rect().encloses(inspecao.get_global_rect()), "inspeção deve caber na tela")
			for bloqueio: Rect2 in jogo.call("_bloqueios_inspecao_hud"):
				_verificar(not inspecao.get_global_rect().intersects(bloqueio), "inspeção da relíquia não deve cobrir informação ou personagem: dica=%s bloqueio=%s tela=%s" % [inspecao.get_global_rect(), bloqueio, resolucao])
			jogo.get_node("HudInspecao").call("esconder")
		jogo.call("_iniciar_combate_por_id", "unidade_contencao_portuaria", false)
		jogo.call("_atualizar_interface")
		await get_tree().process_frame
		var titulo: Label = jogo.get_node("AlvoVisualLabel") as Label
		_verificar(titulo.get_theme_font("font").get_string_size(titulo.text, HORIZONTAL_ALIGNMENT_LEFT, -1, titulo.get_theme_font_size("font_size")).x <= titulo.size.x, "nome longo do elite precisa caber inteiro no cabeçalho")
	jogo.queue_free()
	print("HUD COMPACTO: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error(mensagem)
