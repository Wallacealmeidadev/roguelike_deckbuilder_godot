extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	await _testar_recuperacao()
	await _testar_indisponibilidades()
	await _testar_aprimoramento()
	if falhas == 0:
		print("OK: ciclo de descanso")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _criar_jogo() -> Node:
	var cena: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	return jogo


func _abrir_descanso(jogo: Node, deck: Array[String] = [], vida: int = 40) -> Control:
	jogo.set("mapa_variante", 1)
	jogo.call("_iniciar_nova_run")
	await get_tree().process_frame
	if not deck.is_empty():
		jogo.set("baralho_run", deck)
	jogo.set("vida_jogador", vida)
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	jogo.call("_ao_pular_recompensa")
	jogo.call("_ao_selecionar_no_mapa", "descanso_inicial")
	await get_tree().process_frame
	return jogo.get_node("DescansoOverlay") as Control


func _testar_recuperacao() -> void:
	var jogo: Node = await _criar_jogo()
	var overlay: Control = await _abrir_descanso(jogo, [], 30)
	_verificar(overlay.visible, "o descanso deve abrir pelo destino do mapa")
	var recuperar: Button = overlay.get_node("Acoes/RecuperarPainel") as Button
	_verificar(not recuperar.disabled, "recuperar deve estar disponível com Vida perdida")
	recuperar.emit_signal("pressed")
	await get_tree().process_frame
	_verificar(int(jogo.get("vida_jogador")) == 38, "recuperar deve aplicar oito de Vida")
	_verificar((overlay.get_node("Resultado") as Control).visible, "recuperar deve mostrar resultado")
	_verificar(not (overlay.get_node("Subtitulo") as Label).visible, "resultado deve ocultar escolha de acao")
	_verificar((overlay.get_node("Resultado/Conteudo/Simbolo") as TextureRect).texture != null, "resultado deve mostrar simbolo")
	recuperar.emit_signal("pressed")
	_verificar(int(jogo.get("vida_jogador")) == 38, "clique repetido não deve curar novamente")
	(overlay.get_node("Continuar") as Button).emit_signal("pressed")
	await get_tree().process_frame
	_verificar((jogo.get_node("MapaOverlay") as Control).visible, "continuar deve retornar ao mapa")
	jogo.queue_free()


func _testar_aprimoramento() -> void:
	var jogo: Node = await _criar_jogo()
	var deck: Array[String] = ["golpe", "golpe"]
	jogo.set("baralho_run", deck)
	var overlay: Control = await _abrir_descanso(jogo, deck)
	var aprimorar: Button = overlay.get_node("Acoes/AprimorarPainel") as Button
	aprimorar.emit_signal("pressed")
	await get_tree().process_frame
	await get_tree().process_frame
	var selecao: Control = overlay.get_node("Selecao") as Control
	_verificar(selecao.visible, "aprimorar deve abrir a seleção")
	_verificar(not (overlay.get_node("Subtitulo") as Label).visible, "seleção não deve duplicar a instrução abaixo do cabeçalho")
	_verificar((selecao.get_node("CartasScroll/Cartas") as HBoxContainer).get_child_count() == 2, "duas cópias devem permanecer distinguíveis")
	var cartas: HBoxContainer = selecao.get_node("CartasScroll/Cartas") as HBoxContainer
	var scroll: ScrollContainer = selecao.get_node("CartasScroll") as ScrollContainer
	await get_tree().process_frame
	if cartas.get_combined_minimum_size().x <= scroll.size.x:
		_verificar(
			absf(cartas.get_global_rect().get_center().x - scroll.get_global_rect().get_center().x) <= 2.0,
			"lista de cartas deve ficar centralizada quando couber"
		)
	var primeira_carta: Button = cartas.get_child(0) as Button
	_verificar((primeira_carta.get_node("SelecaoLabel") as Label).visible, "copia deve ter identificacao fora da carta")
	_verificar(not str((primeira_carta.get_node("DescricaoBalao/BalaoTexto") as Label).text).contains("CÓPIA"), "tooltip nao deve repetir identificacao da copia")
	(cartas.get_child(1) as Button).emit_signal("pressed")
	await get_tree().process_frame
	var comparacao: Control = overlay.get_node("Comparacao") as Control
	_verificar(comparacao.has_node("Cartas/Atual"), "comparacao deve apresentar carta atual")
	_verificar(comparacao.has_node("Cartas/Melhorada"), "comparacao deve apresentar carta melhorada")
	_verificar((comparacao.get_node("Cartas/Melhorada") as VBoxContainer).get_child_count() == 2, "comparacao deve conter marcador e carta melhorada")
	_verificar(comparacao.visible, "selecionar uma cópia deve abrir a comparação")
	_verificar(jogo.get("baralho_run")[1] == "golpe", "a prévia não deve alterar o baralho")
	var carta_melhorada: Button = (comparacao.get_node("Cartas/Melhorada") as VBoxContainer).get_child(1) as Button
	var descricao_melhorada: Control = carta_melhorada.get_node("DescricaoDestaque") as Control
	_verificar(descricao_melhorada.visible, "comparacao deve mostrar uma camada de descricao destacada")
	_verificar(str(descricao_melhorada.get("text")).contains("[bgcolor="), "valor modificado deve receber marcador discreto")
	_verificar(
		str(descricao_melhorada.get("text")).find("Ganha 1 Combo") > str(descricao_melhorada.get("text")).find("[/bgcolor]"),
		"efeito nao modificado deve permanecer fora do marcador"
	)
	(comparacao.get_node("Confirmar") as Button).emit_signal("pressed")
	await get_tree().process_frame
	_verificar(jogo.get("baralho_run")[0] == "golpe", "a cópia não escolhida deve permanecer normal")
	_verificar(jogo.get("baralho_run")[1] == "golpe#aprimorado", "somente a cópia escolhida deve ser aprimorada")
	_verificar(
		(overlay.get_node("Resultado/Conteudo/Titulo") as Label).text == "GOLPE APRIMORADO",
		"resultado deve identificar a carta aprimorada"
	)
	_verificar(
		(overlay.get_node("Resultado/Conteudo/Texto") as Label).text == "Dano: 6 → 9",
		"resultado deve apresentar a mudança real da carta"
	)
	_verificar(
		not (overlay.get_node("Resultado/Conteudo/Estado") as Label).visible,
		"resultado de melhoria não deve repetir a contagem do baralho"
	)
	(comparacao.get_node("Confirmar") as Button).emit_signal("pressed")
	_verificar(jogo.get("baralho_run")[1] == "golpe#aprimorado", "confirmação repetida não deve duplicar a melhoria")
	jogo.queue_free()


func _testar_indisponibilidades() -> void:
	var jogo: Node = await _criar_jogo()
	var deck: Array[String] = ["golpe#aprimorado"]
	jogo.set("baralho_run", deck)
	var overlay: Control = await _abrir_descanso(jogo, deck)
	_verificar((overlay.get_node("Acoes/RecuperarPainel") as Button).disabled, "Vida cheia deve desabilitar recuperar")
	_verificar((overlay.get_node("Acoes/AprimorarPainel") as Button).disabled, "sem cartas elegíveis deve desabilitar aprimorar")
	jogo.queue_free()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
