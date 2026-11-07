extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame

	var mapa: MapaRun = jogo.get("mapa_run") as MapaRun
	var overlay: Control = jogo.get_node("MapaOverlay") as Control
	var fundo: TextureRect = jogo.get_node("MapaFundo") as TextureRect
	var pontos: Control = jogo.get_node("MapaOverlay/MapaGrafo/MapaPontos") as Control
	var id_atual: String = str(jogo.get("mapa_no_atual"))
	var destinos: Array[String] = mapa.nos_no_ponto(1)

	_verificar(overlay.visible, "o mapa deve aparecer no início da run")
	_verificar(fundo.visible, "o mapa deve cobrir visualmente a tela de combate")
	_verificar(not (jogo.get_node("PilhasLabel") as Label).visible, "as pilhas devem sumir no mapa")
	_verificar(not (jogo.get_node("AcaoLabel") as Label).visible, "a última ação deve sumir no mapa")
	_verificar(id_atual.is_empty(), "nenhum ponto deve estar atual antes do primeiro encontro")
	_verificar(destinos.size() == 1, "somente o primeiro ponto deve estar disponível")
	_verificar(_contar_habilitados(pontos) == 1, "somente o primeiro botão deve estar habilitado")

	var id_bloqueado: String = mapa.nos_no_ponto(3)[0]
	jogo.call("_ao_selecionar_no_mapa", id_bloqueado)
	_verificar(str(jogo.get("mapa_no_em_andamento")).is_empty(), "nó não conectado não deve iniciar")

	var botao_inicial: Button = _botao_por_id(pontos, destinos[0])
	_verificar(botao_inicial != null, "o destino inicial deve possuir um botão real")
	if botao_inicial != null:
		botao_inicial.pressed.emit()
	_verificar(str(jogo.get("mapa_no_em_andamento")) == destinos[0], "o ponto inicial deve entrar em andamento")
	_verificar(str(jogo.get("mapa_no_atual")).is_empty(), "o ponto só vira atual após ser concluído")
	jogo.call("_abrir_mapa")
	_verificar(not overlay.visible, "o mapa não deve reabrir por cima de um encontro")

	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	jogo.call("_ao_pular_recompensa")
	_verificar(overlay.visible, "o mapa deve voltar após a consequência do encontro")
	_verificar(str(jogo.get("mapa_no_atual")) == destinos[0], "o primeiro ponto deve virar atual após a conclusão")
	_verificar(_contar_habilitados(pontos) == 1, "o segundo ponto conectado deve ficar disponível")

	var mapa_gerado_antes: bool = bool(jogo.get("mapa_gerado"))
	jogo.call("_abrir_mapa")
	await get_tree().process_frame
	_verificar(mapa_gerado_antes and bool(jogo.get("mapa_gerado")), "reabrir o mapa nao deve gerar outra rota")
	_verificar(str(jogo.get("mapa_no_atual")) == destinos[0], "reabrir o mapa deve preservar a posicao atual")
	_verificar(_contar_habilitados(pontos) == 1, "reabrir o mapa deve preservar o destino conectado")

	jogo.queue_free()

	if falhas == 0:
		print("OK: navegação do mapa principal")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _contar_habilitados(pontos: Control) -> int:
	var total: int = 0
	for botao_variant in pontos.get_children():
		var botao: Button = botao_variant as Button
		if botao != null and botao.has_meta("id_no") and not botao.disabled:
			total += 1
	return total


func _botao_por_id(pontos: Control, id_no: String) -> Button:
	for filho_variant in pontos.get_children():
		var botao: Button = filho_variant as Button
		if botao != null and str(botao.get_meta("id_no", "")) == id_no:
			return botao
	return null


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
