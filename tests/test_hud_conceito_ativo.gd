extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Control = (load("res://main.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	jogo.call("_ao_selecionar_no_mapa", "inicio")
	await get_tree().process_frame

	for par: Array in [
		["TopoCombate/ModuloJogador", "modulo_jogador.png"],
		["Alvo/ModuloInimigo", "modulo_inimigo.png"],
		["MaoDock/CaisIlustrado", "cais_longo.png"],
		["StatsJogadorPanel/ModuloBarreira", "medidor_barreira.png"],
		["StatsJogadorPanel/ModuloCombo", "medidor_combo.png"]
	]:
		var caminho: String = par[0]
		_verificar(jogo.has_node(caminho), "%s precisa usar o modulo ilustrado" % caminho)
		if jogo.has_node(caminho):
			var arte: Control = jogo.get_node(caminho) as Control
			var textura: AtlasTexture = arte.get("textura") as AtlasTexture if caminho.begins_with("MaoDock/") else (arte as TextureRect).texture as AtlasTexture
			_verificar(textura != null, "%s precisa preservar proporcao e recorte" % caminho)
			if caminho.begins_with("StatsJogadorPanel/"):
				_verificar(arte.mouse_filter != Control.MOUSE_FILTER_IGNORE and arte.focus_mode != Control.FOCUS_NONE, "%s precisa permitir inspeção por mouse e teclado" % caminho)
			else:
				_verificar(arte.mouse_filter == Control.MOUSE_FILTER_IGNORE, "%s nao pode bloquear input" % caminho)
			_verificar(str(textura.atlas.resource_path).ends_with(par[1]), "%s usa a arte errada" % caminho)

	for arquivo: String in ["modulo_jogador.png", "modulo_inimigo.png", "cais_longo.png", "medidor_barreira.png", "medidor_combo.png"]:
		var imagem: Image = (load("res://assets/ui/runtime/conceito/%s" % arquivo) as Texture2D).get_image()
		_verificar(imagem.get_pixel(0, 0).a < 0.01, "%s precisa de alpha real" % arquivo)

	var carta: Button = (load("res://carta.tscn") as PackedScene).instantiate() as Button
	get_tree().root.add_child(carta)
	await get_tree().process_frame
	var caminhos_cartas: Array[String] = []
	var caminhos_por_id: Dictionary[String, String] = {}
	for par: Array in [
		["golpe", "arte_golpe_impacto_hq_prova.png"],
		["direto_hidraulico", "arte_direto_hidraulico_hq.png"],
		["brecha", "arte_brecha_hq.png"],
		["golpe_ariete", "arte_golpe_ariete_hq.png"],
		["ruptura_pressao", "arte_ruptura_pressao_hq.png"],
		["protecao", "arte_protecao_bloqueio_hq_prova.png"],
		["pulso_debilitante", "arte_pulso_debilitante_hq.png"],
		["placa_reforcada", "arte_placa_reforcada_hq.png"],
		["quebra_chassi", "arte_quebra_chassi_ruptura_hq_prova.png"]
	]:
		var dados: Dictionary = preload("res://dados_cartas.gd").CARTAS[str(par[0])]
		carta.call("aplicar_visual", par[0], str(dados["tipo"]))
		var arte_carta: TextureRect = carta.get_node("Arte") as TextureRect
		_verificar(arte_carta.texture != null and arte_carta.texture.resource_path.ends_with(par[1]), "%s precisa usar sua própria arte HQ" % par[0])
		if arte_carta.texture != null:
			var caminho_arte: String = arte_carta.texture.resource_path
			_verificar(not caminhos_cartas.has(caminho_arte), "%s não deve reutilizar a arte de outra carta" % par[0])
			caminhos_cartas.append(caminho_arte)
			caminhos_por_id[str(par[0])] = caminho_arte
	_verificar(caminhos_cartas.size() == preload("res://dados_cartas.gd").CARTAS.size(), "todo o catálogo precisa ter arte própria")
	carta.queue_free()
	jogo.call("_limpar_mao")
	for id_carta: String in caminhos_por_id:
		jogo.call("_criar_carta_na_mao", id_carta + "#aprimorado")
		var mao_aprimorada: Control = jogo.get_node("Mao") as Control
		var carta_aprimorada: Node = mao_aprimorada.get_child(mao_aprimorada.get_child_count() - 1)
		var arte_aprimorada: Texture2D = (carta_aprimorada.get_node("Arte") as TextureRect).texture
		_verificar(arte_aprimorada != null and arte_aprimorada.resource_path == caminhos_por_id[id_carta], "%s aprimorada deve preservar a ilustração da carta base" % id_carta)

	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		await get_tree().process_frame
		jogo.call("_layout_hud_combate")
		var jogador: Control = jogo.get_node("TopoCombate/ModuloJogador") as Control if jogo.has_node("TopoCombate/ModuloJogador") else null
		var inimigo: Control = jogo.get_node("Alvo") as Control
		var mao: Control = jogo.get_node("Mao") as Control
		var dock: Control = jogo.get_node("MaoDock") as Control
		if jogador != null:
			_verificar(not jogador.get_global_rect().intersects(inimigo.get_global_rect()), "HUDs de jogador e inimigo nao podem se sobrepor em %s" % resolucao)
			var campo_vega: Control = jogo.get_node("Jogador") as Control
			_verificar(campo_vega.get_global_rect().position.y >= jogador.get_global_rect().end.y + 4.0, "Vega no campo nao pode nascer por tras do retrato em %s" % resolucao)
		_verificar(dock.get_global_rect().intersects(mao.get_global_rect()), "cartas precisam ocupar o cais em %s" % resolucao)

	jogo.call("_iniciar_combate_por_id", "dois_caranguejos", false)
	await get_tree().process_frame
	for botao: Button in jogo.get("alvos_multiplos"):
		if botao.visible:
			_verificar(botao.has_node("ModuloInimigo"), "cada alvo de encontro multiplo precisa da moldura ilustrada")

	jogo.queue_free()
	print("HUD CONCEITO: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
