extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.call("_mostrar_recompensa_elite")
	await get_tree().process_frame
	_verificar(not (jogo.get_node("ResultadoLabel") as Control).visible, "resultado legado nao deve sobrepor recompensa elite")
	_verificar(not (jogo.get_node("RecompensaPainel") as Control).visible, "moldura horizontal compartilhada nao deve aparecer no elite")
	var titulo: Control = jogo.get_node("RecompensaElite/TituloElite") as Control
	var reliquias: Control = jogo.get_node("RecompensaElite/ReliquiasElite") as Control
	var acoes: Control = jogo.get_node("RecompensaElite/RecompensaEliteAcoes") as Control
	_verificar(absf(reliquias.get_global_rect().get_center().x - titulo.get_global_rect().get_center().x) < 2.0, "grupo de reliquias deve compartilhar o eixo do titulo")
	_verificar(absf(acoes.get_global_rect().get_center().x - titulo.get_global_rect().get_center().x) < 2.0, "acao do elite deve compartilhar o eixo do titulo")
	var opcoes: Array[Button] = [
		jogo.get_node("RecompensaElite/ReliquiasElite/RelquiaOpcao1") as Button,
		jogo.get_node("RecompensaElite/ReliquiasElite/RelquiaOpcao2") as Button
	]
	var reliquia_1: Button = opcoes[0]
	for opcao in opcoes:
		_verificar(opcao.visible, "as duas reliquias devem aparecer")
		_verificar(opcao.get_node("Painel/Conteudo/Icone").mouse_filter == Control.MOUSE_FILTER_IGNORE, "icone nao deve bloquear clique")
		_verificar(opcao.get_node("Painel/Conteudo/Efeito").text != "", "efeito da reliquia precisa ser legivel")
		_verificar(opcao.get_global_rect().size.x > 180.0, "painel da reliquia deve ter area de leitura")
		var painel: PanelContainer = opcao.get_node("Painel") as PanelContainer
		var estilo: StyleBoxFlat = painel.get_theme_stylebox("panel") as StyleBoxFlat
		_verificar(estilo != null and estilo.corner_radius_top_left == 0 and estilo.corner_radius_top_right == 0, "reliquia deve usar moldura HQ sem cantos arredondados")
		if not opcao.has_focus():
			_verificar(estilo != null and estilo.border_color.r > 0.9 and estilo.border_color.g > 0.9 and estilo.border_color.b > 0.9, "moldura neutra da reliquia deve ser branca")
	_verificar(jogo.get_node("RecompensaElite/CartasRarasElite").visible == false, "cartas raras nao aparecem na primeira etapa")
	var rara: Button = jogo.get_node("RecompensaElite/CartasRarasElite/CartaRaraOpcao1") as Button
	_verificar(rara.focus_mode != Control.FOCUS_NONE, "carta rara deve aceitar teclado")
	_verificar(rara.get_node("DescricaoBalao") is PanelContainer, "carta rara deve usar tooltip PanelContainer")
	_verificar(jogo.get_node("RecompensaElite/RecompensaEliteAcoes/ConsultarBaralho") != null, "elite deve permitir consultar baralho")
	var consultar: Button = jogo.get_node("RecompensaElite/RecompensaEliteAcoes/ConsultarBaralho") as Button
	reliquia_1.grab_focus()
	consultar.pressed.emit()
	await get_tree().process_frame
	_verificar((jogo.get_node("BaralhoOverlay") as Control).visible, "consulta do baralho deve funcionar no elite")
	_verificar(reliquia_1.disabled, "consulta deve bloquear a relíquia")
	(jogo.get_node("BaralhoOverlay/BaralhoFechar") as Button).pressed.emit()
	await get_tree().process_frame
	_verificar(get_viewport().gui_get_focus_owner() == reliquia_1, "fechar consulta deve restaurar foco da etapa elite")
	reliquia_1.pressed.emit()
	await get_tree().process_frame
	_verificar((rara.get_node("Arte") as TextureRect).texture != null, "carta rara deve receber arte compartilhada")
	var raridade: Control = rara.get_node("RaridadePill") as Control
	_verificar(raridade.visible, "raridade deve ter area propria e visivel")
	_verificar(raridade.get_node("RaridadeLabel").text == "RARA", "marcador de raridade deve preservar o texto")
	_verificar(raridade.get_global_rect().encloses((raridade.get_node("RaridadeLabel") as Control).get_global_rect()), "texto de raridade deve respeitar a margem interna")
	var cartas_raras: Control = jogo.get_node("RecompensaElite/CartasRarasElite") as Control
	_verificar(absf(cartas_raras.get_global_rect().get_center().x - titulo.get_global_rect().get_center().x) < 2.0, "grupo de cartas raras deve compartilhar o eixo do titulo")
	jogo.queue_free()
	if falhas == 0:
		print("OK: apresentacao da recompensa elite")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
