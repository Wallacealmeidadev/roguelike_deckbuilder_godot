extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.set("vida_jogador", 30)
	jogo.call("_mostrar_descanso")
	var descanso: Control = jogo.get_node("DescansoOverlay") as Control
	_verificar(descanso.visible, "descanso precisa abrir na run")
	var faixa: PanelContainer = descanso.get_node("FaixaTitulo") as PanelContainer
	var estilo_faixa: StyleBoxTexture = faixa.get_theme_stylebox("panel") as StyleBoxTexture
	_verificar(estilo_faixa != null and estilo_faixa.texture.resource_path.begins_with("res://hud_neon/"), "titulo do descanso precisa da faixa neon")
	var recuperar: Button = descanso.get_node("Acoes/RecuperarPainel") as Button
	var estilo_recuperar: StyleBoxTexture = recuperar.get_theme_stylebox("normal") as StyleBoxTexture
	_verificar(estilo_recuperar != null and estilo_recuperar.texture.resource_path.begins_with("res://hud_neon/"), "acao de recuperar precisa de placa neon")
	var detalhe: PanelContainer = descanso.get_node("Acoes/RecuperarPainel/Conteudo/Informacao") as PanelContainer
	var estilo_detalhe: StyleBoxFlat = detalhe.get_theme_stylebox("panel") as StyleBoxFlat
	_verificar(estilo_detalhe != null and estilo_detalhe.bg_color.get_luminance() < 0.18, "efeito do descanso precisa de fundo escuro")
	recuperar.pressed.emit()
	_verificar(int(jogo.get("vida_jogador")) == 38, "recuperar precisa conservar a cura real de oito")
	_verificar((descanso.get_node("Resultado") as Control).visible, "resultado do descanso deve aparecer")
	var estilo_continuar: StyleBoxTexture = (descanso.get_node("Continuar") as Button).get_theme_stylebox("normal") as StyleBoxTexture
	_verificar(estilo_continuar != null and estilo_continuar.texture.resource_path.begins_with("res://hud_neon/"), "continuar no descanso precisa do tema neon")

	jogo.set("vida_jogador", 0)
	jogo.call("_mostrar_resultado")
	var resultado: Label = jogo.get_node("ResultadoLabel") as Label
	_verificar(resultado.visible and resultado.text.contains("DERROTA"), "derrota precisa continuar explicita")
	var estilo_reiniciar: StyleBoxTexture = (jogo.get_node("Reiniciar") as Button).get_theme_stylebox("normal") as StyleBoxTexture
	_verificar(estilo_reiniciar != null and estilo_reiniciar.texture.resource_path.begins_with("res://hud_neon/"), "reinicio deve usar botao neon")
	jogo.set("vida_jogador", 1)
	jogo.call("_mostrar_resultado")
	_verificar(not resultado.text.contains("Três combates"), "sucesso nao pode anunciar a estrutura legada de tres combates")
	jogo.set("mapa_no_em_andamento", "lastro")
	jogo.call("_resolver_vitoria")
	_verificar(resultado.text == "RUN CONCLUÍDA\nBoss provisório vencido", "titulo final deve caber na moldura")
	_verificar(jogo.has_node("ResultadoLabel/NotaProvisorio"), "tela final deve identificar Lastro como pendente")
	if jogo.has_node("ResultadoLabel/NotaProvisorio"):
		var nota: Label = jogo.get_node("ResultadoLabel/NotaProvisorio") as Label
		_verificar(nota.visible and nota.text.contains("Lastro"), "nota do chefe provisório precisa estar visivel")
		_verificar(get_viewport().get_visible_rect().encloses(nota.get_global_rect()), "nota do chefe precisa caber na janela")
	jogo.queue_free()
	if falhas == 0:
		print("OK: descanso e resultados com apresentacao neon")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
