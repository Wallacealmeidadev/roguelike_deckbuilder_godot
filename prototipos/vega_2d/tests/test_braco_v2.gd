extends Node

const BRACO: Script = preload("res://vega_animada/braco_v2/braco_prova.gd")
var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)


func _executar() -> void:
	var braco: BracoV2Prova = BRACO.new() as BracoV2Prova
	add_child(braco)
	await get_tree().process_frame
	var imagem: Image = braco.ATLAS.get_image()
	_verificar(imagem.get_pixel(0, 0).a < .01, "atlas precisa de transparência real")
	_verificar(braco.limites_fontes.size() == 8, "oito peças precisam ser reconhecidas")
	for limite: Rect2i in braco.limites_fontes:
		print("CAMADA %s" % limite)
		_verificar(limite.size.x > 12 and limite.size.y > 12, "camada não pode ser vazia")
	var mao_inicial: Transform2D = braco.mao.transform
	var cotovelo_inicial: Transform2D = braco.cotovelo.transform
	var repouso: PackedVector2Array = braco.biceps.polygon
	var uv_inicial: PackedVector2Array = braco.biceps.uv
	var escalas: Array[Vector2] = []
	var placas_iniciais: Array[Vector2] = []
	for placa: Sprite2D in braco.placas:
		escalas.append(placa.scale)
		placas_iniciais.append(placa.position)
	for valor: float in [0.0, .25, .5, .75, 1.0]:
		braco.definir_ativacao(valor)
		_verificar(braco.mao.transform.is_equal_approx(mao_inicial), "mão/pulso não podem crescer ou sair da âncora")
		_verificar(braco.cotovelo.transform.is_equal_approx(cotovelo_inicial), "cotovelo não pode deformar")
		_verificar(braco.biceps.uv == uv_inicial, "UVs permanecem estáveis durante a deformação")
		for indice: int in [0, 1, repouso.size() - 2, repouso.size() - 1]:
			_verificar(braco.biceps.polygon[indice].is_equal_approx(repouso[indice]), "extremidades dos feixes precisam permanecer ancoradas")
		for indice: int in braco.placas.size():
			_verificar(braco.placas[indice].scale.is_equal_approx(escalas[indice]), "placas se deslocam sem mudar de tamanho")
	var meio: int = BracoV2Prova.FAIXAS
	_verificar(braco.biceps.polygon[meio].x < repouso[meio].x - 20, "bíceps precisa engrossar de forma mensurável")
	_verificar(braco.placas[1].position.x > placas_iniciais[1].x + 15, "placa central deve abrir espaço para o feixe")
	braco.definir_ativacao(0)
	_verificar(braco.biceps.polygon == repouso, "retorno manual não pode acumular deriva")
	var anterior: float = 0.0
	for indice: int in 101:
		var valor: float = BracoV2Prova.curva_transformacao(indice / 100.0)
		_verificar(valor >= anterior and valor >= 0 and valor <= 1, "curva precisa ser monotônica, sem overshoot")
		anterior = valor
	braco.definir_combate(true)
	await get_tree().create_timer(.18).timeout
	_verificar(braco.ativacao > 0 and braco.ativacao < 1, "transição real precisa passar por estados intermediários")
	var tween_original: Tween = braco.get("_animacao") as Tween
	braco.definir_combate(true)
	_verificar(braco.get("_animacao") == tween_original, "repetir destino não reinicia a transição")
	var antes_inverter: float = braco.ativacao
	braco.definir_combate(false)
	_verificar(is_equal_approx(braco.ativacao, antes_inverter), "inversão deve partir do valor atual, sem salto")
	await get_tree().create_timer(.6).timeout
	_verificar(is_zero_approx(braco.ativacao) and not braco.animando, "retorno animado termina no repouso")
	_verificar(braco.biceps.polygon == repouso, "retorno animado restaura a geometria")
	braco.definir_combate(true)
	await get_tree().create_timer(.15).timeout
	braco.definir_movimento_reduzido(true)
	_verificar(is_equal_approx(braco.ativacao, 1.0) and not braco.animando, "ativar movimento reduzido resolve o destino sem deslocamento contínuo")
	braco.definir_combate(false)
	_verificar(is_zero_approx(braco.ativacao), "alternativa reduzida deve voltar imediatamente")
	braco.definir_ativacao(2)
	_verificar(is_equal_approx(braco.ativacao, 1.0), "controle manual limita acima de um")
	braco.definir_ativacao(-1)
	_verificar(is_zero_approx(braco.ativacao), "controle manual limita abaixo de zero")
	braco.queue_free()
	await get_tree().process_frame
	await _verificar_preview()
	print("BRAÇO V2: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar_preview() -> void:
	var preview: Control = (load("res://prototipos/vega_2d/braco_v2/preview.tscn") as PackedScene).instantiate() as Control
	add_child(preview)
	await get_tree().process_frame
	var braco: BracoV2Prova = preview.get_node("Braco") as BracoV2Prova
	var controle: HSlider = preview.get_node("Ativacao") as HSlider
	var alternar: Button = preview.get_node("Alternar") as Button
	var ciclo: Button = preview.get_node("Ciclo") as Button
	var timer: Timer = preview.get_node("CicloTimer") as Timer
	var reduzido: CheckButton = preview.get_node("Reduzido") as CheckButton
	for resolucao: Vector2 in [Vector2(1024, 576), Vector2(1920, 1080)]:
		preview.size = resolucao
		await get_tree().process_frame
		for nome: String in ["Alternar", "Ciclo", "Reduzido", "Ativacao", "Estado", "LegendaCombo", "ControlesCombo"]:
			var elemento: Control = preview.get_node(nome) as Control
			_verificar(Rect2(Vector2.ZERO, resolucao).encloses(elemento.get_rect()), "controle precisa caber no viewport: %s" % nome)
		var painel_combo: HBoxContainer = preview.get_node("ControlesCombo") as HBoxContainer
		_verificar(painel_combo.get_rect().end.x < controle.position.x, "Combo não pode invadir slider da transformação")
		for botao: Control in painel_combo.get_children():
			_verificar(painel_combo.get_global_rect().encloses(botao.get_global_rect()), "controles de Combo cabem no painel")
		var mao_abaixo: Vector2 = braco.position + (braco.mao.position + braco.mao.texture.get_size() * braco.mao.scale * .5) * braco.scale
		_verificar(mao_abaixo.y < (preview.get_node("Estado") as Label).position.y, "mão não pode invadir o estado/slider")
	controle.value = 50
	_verificar(is_equal_approx(braco.ativacao, .5), "slider controla a pose real")
	ciclo.pressed.emit()
	_verificar(not timer.is_stopped(), "botão inicia ciclo")
	await get_tree().create_timer(.6).timeout
	_verificar(is_equal_approx(braco.destino, 1.0), "ciclo chega à ativação")
	controle.value = 25
	_verificar(timer.is_stopped() and is_equal_approx(braco.ativacao, .25), "intervenção manual interrompe o ciclo")
	reduzido.button_pressed = true
	alternar.button_pressed = true
	_verificar(is_equal_approx(braco.ativacao, 1.0) and not braco.animando, "botões oferecem pose reduzida imediata")
	alternar.button_pressed = false
	_verificar(is_zero_approx(braco.ativacao), "botão reduzido restaura repouso")
	reduzido.button_pressed = false
	ciclo.pressed.emit()
	await get_tree().create_timer(2.25).timeout
	_verificar(timer.is_stopped() and is_zero_approx(braco.ativacao) and not braco.animando, "ciclo completo termina em repouso, sem timer residual")
	(preview.get_node("ControlesCombo/MaisUm") as Button).pressed.emit()
	_verificar(braco.combo == 1 and alternar.button_pressed and is_equal_approx(braco.destino, 1.0), "+1 ativa combate e adiciona carga na simulação")
	(preview.get_node("ControlesCombo/MaisTres") as Button).pressed.emit()
	_verificar(braco.combo == 4, "+3 soma ao contador da simulação")
	(preview.get_node("ControlesCombo/Alto") as Button).pressed.emit()
	_verificar(braco.combo == 10, "botão 10 testa o máximo visual")
	_verificar((preview.get_node("ControlesCombo/Valor") as Label).text == "COMBO 10 / 100%", "10 cargas exibem 100% sem esperar animação")
	(preview.get_node("ControlesCombo/Consumir") as Button).pressed.emit()
	_verificar(braco.combo == 0 and is_equal_approx(braco.destino, 1.0), "consumir mantém destino de combate")
	_verificar((preview.get_node("ControlesCombo/Valor") as Label).text == "COMBO 0 / 0%", "texto mostra valor real sem esperar animação")
	preview.queue_free()
	await get_tree().process_frame
