extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame

	_verificar(jogo.has_node("RecompensaElite"), "a cena deve ter a área do elite")
	_verificar(
		jogo.has_node("RecompensaElite/ReliquiasElite/RelquiaOpcao1"),
		"deve haver a primeira relíquia"
	)
	_verificar(
		jogo.has_node("RecompensaElite/ReliquiasElite/RelquiaOpcao2"),
		"deve haver a segunda relíquia"
	)
	_verificar(
		jogo.has_node("RecompensaElite/CartasRarasElite/CartaRaraOpcao1"),
		"deve haver a primeira carta rara"
	)
	_verificar(
		jogo.has_node("RecompensaElite/CartasRarasElite/CartaRaraOpcao2"),
		"deve haver a segunda carta rara"
	)
	_verificar(
		jogo.has_node("RecompensaElite/CartasRarasElite/CartaRaraOpcao3"),
		"deve haver a terceira carta rara"
	)
	if jogo.has_node("RecompensaElite"):
		_verificar(
			not jogo.get_node("RecompensaElite").visible,
			"a área deve começar escondida"
		)

	jogo.call("_mostrar_recompensa_elite")
	await get_tree().process_frame
	var recompensa_elite: Control = jogo.get_node("RecompensaElite") as Control
	_verificar(recompensa_elite.visible, "recompensa elite deve aparecer apos a vitoria")
	_verificar(recompensa_elite.get_node("TituloElite").visible, "titulo magenta da recompensa elite deve aparecer")
	_verificar(recompensa_elite.get_node("IndicadorEtapa").text.contains("RELIQUIA"), "etapa de reliquia deve ser explicita")
	var reliquia_1: Button = jogo.get_node("RecompensaElite/ReliquiasElite/RelquiaOpcao1") as Button
	_verificar(reliquia_1.focus_mode != Control.FOCUS_NONE, "reliquia deve aceitar foco de teclado")
	_verificar(reliquia_1.mouse_filter == Control.MOUSE_FILTER_STOP, "a opcao inteira deve ser clicavel")
	_verificar(reliquia_1.get_node("Painel/Conteudo/Icone").mouse_filter == Control.MOUSE_FILTER_IGNORE, "decoracao nao deve interceptar mouse")
	_verificar((reliquia_1.get_node("Painel/Conteudo/Efeito") as Label).text != "", "efeito essencial deve ficar visivel")
	var id_reliquia: String = (jogo.get("oferta_reliquias") as OfertaRecompensa).opcoes[0]
	reliquia_1.pressed.emit()
	await get_tree().process_frame
	_verificar(jogo.get("etapa_recompensa_elite") == "carta_rara", "escolher reliquia deve abrir cartas raras")
	_verificar((jogo.get("jogador_combate") as JogadorCombate).reliquias_run.has(id_reliquia), "reliquia escolhida deve ser adquirida")
	_verificar(recompensa_elite.get_node("IndicadorEtapa").text.contains("CARTA RARA"), "etapa rara deve ser explicita")
	_verificar(get_viewport().gui_get_focus_owner() == jogo.get_node("RecompensaElite/CartasRarasElite/CartaRaraOpcao1"), "foco deve passar para cartas raras")
	var tamanho_baralho: int = (jogo.get("baralho_run") as Array[String]).size()
	reliquia_1.pressed.emit()
	_verificar((jogo.get("baralho_run") as Array[String]).size() == tamanho_baralho, "clique tardio na reliquia nao pode escolher carta")
	var carta_rara: Button = jogo.get_node("RecompensaElite/CartasRarasElite/CartaRaraOpcao1") as Button
	_verificar(carta_rara.has_method("aplicar_visual"), "carta rara deve reutilizar o componente de carta")
	_verificar(carta_rara.has_node("DescricaoBalao"), "carta rara deve reutilizar tooltip de carta")
	jogo.queue_free()
	if falhas == 0:
		print("OK: interface da recompensa do elite")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
