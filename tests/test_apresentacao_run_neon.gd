extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
		get_tree().root.add_child(jogo)
		await get_tree().process_frame

		var mapa: Control = jogo.get_node("MapaOverlay") as Control
		_verificar(mapa.visible, "a run deve iniciar no mapa em %s" % resolucao)
		_verificar(jogo.has_node("MapaOverlay/MapaGrafo/GradeNeon"), "o grafo precisa de uma grade de rota neon")
		if jogo.has_node("MapaOverlay/MapaGrafo/GradeNeon"):
			var grade: Control = jogo.get_node("MapaOverlay/MapaGrafo/GradeNeon") as Control
			_verificar(grade.mouse_filter == Control.MOUSE_FILTER_IGNORE, "a grade nao pode capturar o clique do ponto")
			_verificar(int(grade.get("total_pontos")) == (jogo.get("mapa_run") as MapaRun).total_pontos(), "a grade deve refletir a extensao real da rota")
		var cabecalho: PanelContainer = jogo.get_node("MapaOverlay/MapaCabecalho") as PanelContainer
		_verificar(cabecalho.get_theme_stylebox("panel") is StyleBoxTexture, "o cabecalho precisa usar a moldura escura neon")
		_verificar((jogo.get_node("MapaOverlay/MapaCabecalho/MapaCabecalhoLinha/MapaRecursos/MapaVidaLabel") as Label).text == "40/40", "Vida no mapa deve vir da run")
		var inicio: Button = jogo.get_node("MapaOverlay/MapaGrafo/MapaPontos/MapaNo_inicio") as Button
		_verificar(not inicio.disabled, "inicio da run precisa continuar selecionavel")
		_verificar(inicio.get_theme_stylebox("normal") is StyleBoxFlat, "pontos devem ter placa escura com cor de estado")
		if inicio.get_theme_stylebox("normal") is StyleBoxFlat:
			var estilo: StyleBoxFlat = inicio.get_theme_stylebox("normal") as StyleBoxFlat
			_verificar(estilo.bg_color.get_luminance() < 0.18, "placa do ponto precisa ser escura")
		inicio.pressed.emit()
		_verificar(not mapa.visible, "selecionar o ponto deve manter a transicao para combate")
		jogo.set("vida_inimigo", 0)
		jogo.call("_resolver_vitoria")
		var recompensas: Control = jogo.get_node("Recompensas") as Control
		_verificar(recompensas.visible, "vitoria deve abrir a oferta real")
		_verificar(jogo.has_node("Recompensas/PlacaNeon"), "oferta precisa de uma placa neon atras das cartas")
		if jogo.has_node("Recompensas/PlacaNeon"):
			_verificar((jogo.get_node("Recompensas/PlacaNeon") as Control).mouse_filter == Control.MOUSE_FILTER_IGNORE, "placa nao pode cobrir as cartas")
		_verificar(jogo.has_node("ResultadoLabel/MolduraNeon"), "resultado precisa de moldura integrada")
		var pular: Button = jogo.get_node("Recompensas/RecompensaAcoes/Pular") as Button
		_verificar(pular.get_theme_stylebox("normal") is StyleBoxTexture, "acoes da oferta precisam do estilo neon")
		_verificar(get_viewport().get_visible_rect().encloses(pular.get_global_rect()), "pular precisa caber em %s" % resolucao)
		await get_tree().process_frame
		var consultar: Button = jogo.get_node("Recompensas/RecompensaAcoes/ConsultarBaralho") as Button
		for indice: int in 3:
			var carta: Button = jogo.get_node("Recompensas/RecompensaCartas/RecompensaOpcao%d" % (indice + 1)) as Button
			_verificar(not carta.get_global_rect().intersects(pular.get_global_rect()), "carta %d nao pode cobrir Pular em %s" % [indice + 1, resolucao])
			_verificar(not carta.get_global_rect().intersects(consultar.get_global_rect()), "carta %d nao pode cobrir Ver baralho em %s" % [indice + 1, resolucao])
		pular.pressed.emit()
		_verificar(mapa.visible, "pular deve voltar ao mapa sem alterar a regra")
		jogo.queue_free()
		await get_tree().process_frame

	if falhas == 0:
		print("OK: apresentacao neon do mapa e recompensa")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
