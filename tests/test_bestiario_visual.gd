extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var resolucao: Vector2i = Vector2i(1024, 576)
	var argumentos: PackedStringArray = OS.get_cmdline_user_args()
	var captura: String = ""
	var cenario: String = "dupla"
	for indice in range(argumentos.size()):
		if argumentos[indice] == "--capture" and indice + 1 < argumentos.size():
			captura = argumentos[indice + 1]
		if argumentos[indice] == "--size" and indice + 1 < argumentos.size():
			var partes: PackedStringArray = argumentos[indice + 1].split("x")
			if partes.size() == 2:
				resolucao = Vector2i(int(partes[0]), int(partes[1]))
		if argumentos[indice] == "--scenario" and indice + 1 < argumentos.size():
			cenario = argumentos[indice + 1]
	DisplayServer.window_set_size(resolucao)
	get_window().size = resolucao
	var jogo: Node = (load("res://main.tscn") as PackedScene).instantiate()
	add_child(jogo)
	await get_tree().process_frame
	var id_encontro: String = "carga_reparador"
	if cenario == "sentinela":
		id_encontro = "sentinela_inspecao"
	elif cenario == "guindaste":
		id_encontro = "guindaste_autonomo"
	jogo.call("_iniciar_combate_por_id", id_encontro, false)
	await get_tree().process_frame
	var encontro: EncontroCombate = jogo.get("encontro_combate") as EncontroCombate
	if cenario == "sentinela":
		jogo.call("_executar_intencao_inimigo")
		jogo.call("_atualizar_interface")
		_verificar((jogo.get_node("MarcadoVisual") as Label).visible, "Marcado aparece no jogador")
		_verificar((jogo.get_node("IntencaoValorVisualLabel") as Label).text.contains("14"), "intenção mostra 14")
	elif cenario == "guindaste":
		for turno in range(3):
			jogo.call("_executar_intencao_inimigo")
		jogo.call("_atualizar_interface")
		_verificar((jogo.get_node("EstadoEspecialInimigo") as Label).visible, "Recalibrando visível")
		_verificar(encontro.inimigo.exposto == 0, "Recalibrando não vira Exposto")
	if cenario != "dupla":
		await get_tree().create_timer(1.0).timeout
		if not captura.is_empty():
			var erro_cenario: Error = get_viewport().get_texture().get_image().save_png(captura)
			_verificar(erro_cenario == OK, "captura gravada")
		if falhas == 0:
			print("OK: %s visual em %dx%d" % [cenario, resolucao.x, resolucao.y])
		get_tree().quit(0 if falhas == 0 else 1)
		return
	_verificar(encontro.inimigos.size() == 2, "cena instancia os dois inimigos")
	var alvo_a: Button = jogo.get_node("AlvoMultiplo1") as Button
	var alvo_b: Button = jogo.get_node("AlvoMultiplo2") as Button
	_verificar(alvo_a.visible and alvo_b.visible, "os dois alvos aparecem")
	_verificar(alvo_a.size.x > 100 and alvo_b.size.x > 100, "alvos têm área de clique")
	_verificar(alvo_a.get_global_rect().end.x < alvo_b.get_global_rect().position.x, "alvos não se sobrepõem")
	_verificar(alvo_b.get_global_rect().end.x <= get_viewport().get_visible_rect().end.x, "alvos cabem na viewport")
	_verificar((alvo_a.get_node("Intencao") as Label).text == "DEFENDE" and str(jogo.call("_texto_inspecao_hud", alvo_a)).contains("Blindagem"), "defesa resumida e nome completo inspecionável")
	_verificar((alvo_b.get_node("Intencao") as Label).text == "PROTEGE" and str(jogo.call("_texto_inspecao_hud", alvo_b)).contains("Reforço"), "suporte resumido e nome completo inspecionável")
	for alvo_visual: Button in [alvo_a, alvo_b]:
		var valor_intencao: Label = alvo_visual.get_node("IntencaoValor") as Label
		_verificar(not valor_intencao.text.is_empty(), "cada intenção precisa mostrar seu valor")
		_verificar(not valor_intencao.get_global_rect().intersects((alvo_visual.get_node("VidaBar") as Control).get_global_rect()), "valor da intenção não deve cobrir a barra de Vida")
	_verificar(alvo_a.get_node_or_null("VidaBar") is ProgressBar, "primeiro alvo tem barra de Vida")
	_verificar(alvo_b.get_node_or_null("VidaBar") is ProgressBar, "segundo alvo tem barra de Vida")
	_verificar(alvo_a.get_node_or_null("VidaLabel") is Label, "primeiro alvo tem leitura de Vida")
	_verificar(alvo_b.get_node_or_null("VidaLabel") is Label, "segundo alvo tem leitura de Vida")
	var barra_a: ProgressBar = alvo_a.get_node_or_null("VidaBar") as ProgressBar
	var barra_b: ProgressBar = alvo_b.get_node_or_null("VidaBar") as ProgressBar
	var leitura_a: Label = alvo_a.get_node_or_null("VidaLabel") as Label
	var leitura_b: Label = alvo_b.get_node_or_null("VidaLabel") as Label
	if barra_a != null and barra_b != null and leitura_a != null and leitura_b != null:
		_verificar(barra_a.value == 26.0, "barra do primeiro começa em 26")
		_verificar(barra_b.value == 18.0, "barra do segundo começa em 18")
		_verificar(leitura_a.text == "26/26", "leitura do primeiro começa em 26/26")
		_verificar(leitura_b.text == "18/18", "leitura do segundo começa em 18/18")
		encontro.inimigos[0].vida = 999
		jogo.call("_atualizar_interface")
		_verificar(barra_a.value == 26.0 and leitura_a.text == "26/26", "Vida acima do máximo é limitada na barra")
		encontro.inimigos[0].vida = -4
		jogo.call("_atualizar_interface")
		_verificar(barra_a.value == 0.0 and leitura_a.text == "0/26", "Vida negativa é limitada a zero")
		encontro.inimigos[0].vida = 26
		encontro.inimigos[0].barreira = 7
		jogo.call("_atualizar_interface")
		var leitura_barreira: Label = alvo_a.get_node("BarreiraLabel") as Label
		_verificar(leitura_barreira.visible and leitura_barreira.text == "BARREIRA 7", "Barreira ativa fica separada da Vida")
		encontro.inimigos[1].vida = 10
		jogo.call("_atualizar_interface")
		_verificar(barra_b.value == 10.0 and leitura_b.text == "10/18", "barra acompanha dano direto")
		encontro.inimigos[1].vida = 18
		jogo.call("_atualizar_interface")
		_verificar(barra_b.value == 18.0 and leitura_b.text == "18/18", "barra acompanha recuperação")
		encontro.inimigos[0].barreira = 0
	var mao: Control = jogo.get_node("Mao") as Control
	# A fixture de seleção não deve depender do embaralhamento da mão inicial.
	jogo.call("_criar_carta_na_mao", "golpe")
	var carta_ataque: Button = mao.get_child(mao.get_child_count() - 1) as Button
	carta_ataque.button_pressed = true
	jogo.call("_jogar_carta", "inimigo", 1)
	_verificar(encontro.inimigos[0].vida == 26 and encontro.inimigos[1].vida == 12, "carta atinge só o segundo alvo")
	jogo.call("_atualizar_interface")
	_verificar(barra_a.value == 26.0, "barra do primeiro não muda")
	_verificar(barra_b.value == 12.0, "barra do segundo acompanha o dano")
	await get_tree().create_timer(1.0).timeout
	if not captura.is_empty():
		var erro: Error = get_viewport().get_texture().get_image().save_png(captura)
		_verificar(erro == OK, "captura gravada")
	for indice_alvo in range(2):
		encontro.inimigos[indice_alvo].vida = 1
		jogo.call("_criar_carta_na_mao", "golpe")
		var ultimo_golpe: Button = (mao.get_child(mao.get_child_count() - 1) as Button)
		ultimo_golpe.button_pressed = true
		jogo.call("_jogar_carta", "inimigo", indice_alvo)
		if indice_alvo == 0:
			_verificar(not (jogo.get_node("Recompensas") as Control).visible, "primeira morte não abre recompensa")
		else:
			_verificar((jogo.get_node("Recompensas") as Control).visible, "segunda morte abre recompensa")
	jogo.call("_atualizar_interface")
	_verificar(barra_a.value == 0.0 and (alvo_a.get_node("VidaLabel") as Label).text == "0/26", "primeiro alvo mostra Vida zerada")
	_verificar(barra_b.value == 0.0 and (alvo_b.get_node("VidaLabel") as Label).text == "0/18", "segundo alvo mostra Vida zerada")
	if falhas == 0:
		print("OK: árvore visual do bestiário em %dx%d" % [resolucao.x, resolucao.y])
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
