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

	for caminho: String in ["TopoCombate/ModuloJogador", "Alvo/ModuloInimigo", "StatsJogadorPanel/ModuloBarreira", "StatsJogadorPanel/ModuloCombo", "EnergiaPainel/ModuloEnergia", "MaoDock/CaisIlustrado"]:
		_verificar(jogo.has_node(caminho), "%s precisa compor a nova HUD de combate" % caminho)
		if jogo.has_node(caminho):
			var controle: Control = jogo.get_node(caminho) as Control
			if caminho.begins_with("StatsJogadorPanel/"):
				_verificar(controle.mouse_filter != Control.MOUSE_FILTER_IGNORE and controle.focus_mode != Control.FOCUS_NONE, "%s precisa permitir inspeção por mouse e teclado" % caminho)
			else:
				_verificar(controle.mouse_filter == Control.MOUSE_FILTER_IGNORE, "%s não pode bloquear a interação" % caminho)
	var nucleo: TextureRect = jogo.get_node("EnergiaPainel/ModuloEnergia") as TextureRect
	_verificar(nucleo.texture is AtlasTexture, "a Energia deve preservar proporcao da arte")
	var imagem: Image = (load("res://assets/ui/runtime/conceito/modulo_energia.png") as Texture2D).get_image()
	_verificar(imagem.get_pixel(0, 0).a < 0.01, "o recurso precisa ter alpha real, sem fundo quadriculado")

	if jogo.has_node("EnergiaPainel/MolduraNeon") and jogo.has_node("StatsJogadorPanel/MolduraNeon"):
		var energia_visual: Control = jogo.get_node("EnergiaPainel/MolduraNeon") as Control
		var recursos_visuais: Control = jogo.get_node("StatsJogadorPanel/MolduraNeon") as Control
		jogo.set("energia", 2)
		jogo.set("barreira", 7)
		jogo.set("combo", 8)
		jogo.call("_atualizar_interface")
		_verificar(int(energia_visual.get("energia_atual")) == 2, "segmentos de Energia precisam acompanhar a carga real")
		_verificar(int(energia_visual.get("energia_maxima")) == 4, "segmentos de Energia precisam usar o limite do turno")
		_verificar(int(recursos_visuais.get("barreira_atual")) == 7, "escudo da HUD precisa acompanhar a Barreira real")
		_verificar(int(recursos_visuais.get("combo_atual")) == 8, "segmentos de Combo precisam acompanhar valor acima de seis sem trunca-lo")
		_verificar((jogo.get_node("ComboLabel") as Label).text == "8", "leitura numerica de Combo nao pode ter teto visual")

	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		await get_tree().process_frame
		jogo.call("_layout_hud_combate")
		var mao: Control = jogo.get_node("Mao") as Control
		var botao: Control = jogo.get_node("EncerrarTurno") as Control
		var energia: Control = jogo.get_node("EnergiaPainel") as Control
		_verificar(not mao.get_global_rect().intersects(botao.get_global_rect()), "fim de turno precisa ficar fora da area da mao em %s" % resolucao)
		_verificar(not mao.get_global_rect().intersects(energia.get_global_rect()), "energia precisa ficar fora da area da mao em %s" % resolucao)
		_verificar(jogo.get_global_rect().encloses(botao.get_global_rect()), "fim de turno precisa caber em %s" % resolucao)

	jogo.queue_free()
	if falhas == 0:
		print("OK: HUD neon ligada ao combate")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
