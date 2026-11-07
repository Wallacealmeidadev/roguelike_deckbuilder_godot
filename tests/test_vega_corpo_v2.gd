extends Node

const CORPO: Script = preload("res://vega_animada/corpo_v2/corpo_prova.gd")
var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("CORPO V2: %s" % mensagem)


func _executar() -> void:
	var vega: VegaCorpoV2Prova = CORPO.new() as VegaCorpoV2Prova
	add_child(vega)
	await get_tree().process_frame
	_verificar(vega.corpo.texture.get_size() == VegaCorpoV2Prova.TAMANHO, "dimensões do corpo-base correspondem à montagem")
	_verificar(vega.corpo.texture.get_image().get_pixel(0, 0).a == 0.0, "base tem alfa real")
	var corpo_inicial: Transform2D = vega.corpo.transform
	var frente_inicial: Transform2D = vega.braco_frente.transform
	var tras_inicial: Transform2D = vega.braco_tras.transform
	var mao_frente: Vector2 = vega.braco_frente.mao.global_position
	var mao_tras: Vector2 = vega.braco_tras.mao.global_position
	_verificar((frente_inicial * VegaCorpoV2Prova.JUNTA_LOCAL).is_equal_approx(VegaCorpoV2Prova.OMBRO_FRENTE), "encaixe frontal corresponde à âncora")
	_verificar((tras_inicial * VegaCorpoV2Prova.JUNTA_LOCAL).is_equal_approx(VegaCorpoV2Prova.OMBRO_TRAS), "encaixe traseiro corresponde à âncora")
	# Calibração visual independente: impede regressão para o topo do retângulo.
	var centro_visivel: Vector2 = Vector2(-40, 45)
	_verificar((frente_inicial * centro_visivel).distance_to(Vector2(345, 345)) < .1, "cabeça visível do braço frontal entra no soquete")
	_verificar((tras_inicial * centro_visivel).distance_to(Vector2(702, 390)) < .1, "cabeça visível do braço traseiro entra no soquete")
	vega.definir_combate(true, true)
	var base_frente: PackedVector2Array = vega.braco_frente.biceps.polygon
	var base_tras: PackedVector2Array = vega.braco_tras.biceps.polygon
	for valor: int in [0, 1, 5, 10, 11, 100]:
		vega.definir_combo(valor, true)
		_verificar(vega.combo == valor and vega.braco_tras.combo == valor, "contador é encaminhado aos dois braços")
		_verificar(is_equal_approx(vega.braco_frente.tensao_combo, BracoV2Prova.tensao_por_combo(valor)), "braço frontal preserva progressão aprovada")
		_verificar(is_equal_approx(vega.braco_frente.tensao_combo, vega.braco_tras.tensao_combo), "braços mantêm tensão igual")
		_verificar(vega.corpo.transform == corpo_inicial, "Combo não altera corpo ou pés")
		_verificar(vega.braco_frente.transform == frente_inicial and vega.braco_tras.transform == tras_inicial, "sem deriva dos encaixes")
		_verificar(vega.braco_frente.mao.global_position.is_equal_approx(mao_frente) and vega.braco_tras.mao.global_position.is_equal_approx(mao_tras), "mãos ficam ancoradas")
	vega.definir_combo(0, true)
	_verificar(vega.em_combate and vega.braco_frente.biceps.polygon == base_frente and vega.braco_tras.biceps.polygon == base_tras, "consumir restaura bases sem desativar combate")
	vega.definir_combate(false, true)
	vega.definir_combate(true)
	vega.definir_combo(5)
	for amostra: int in 4:
		await get_tree().create_timer(.03).timeout
		_verificar(is_equal_approx(vega.braco_frente.ativacao, vega.braco_tras.ativacao), "ativação sincronizada durante movimento")
		_verificar(is_equal_approx(vega.braco_frente.tensao_combo, vega.braco_tras.tensao_combo), "tensão sincronizada durante movimento")
	var antes: float = vega.braco_frente.tensao_combo
	vega.definir_combo(0)
	_verificar(is_equal_approx(vega.braco_frente.tensao_combo, antes), "consumo durante ganho não salta de pose")
	await get_tree().create_timer(.6).timeout
	_verificar(vega.em_combate and vega.combo == 0 and is_zero_approx(vega.braco_tras.tensao_combo), "último destino vence nos dois braços")
	vega.definir_combo(10)
	vega.definir_movimento_reduzido(true)
	for braco: BracoV2Prova in [vega.braco_frente, vega.braco_tras]:
		_verificar(not braco.animando and not braco.animando_combo and is_equal_approx(braco.tensao_combo, 1.0), "modo reduzido resolve os dois braços")
	vega.definir_combate(false)
	_verificar(not vega.em_combate and vega.combo == 0 and is_zero_approx(vega.braco_tras.ativacao), "sair limpa os dois braços")
	vega.queue_free()
	await get_tree().process_frame
	await _verificar_preview()
	print("VEGA CORPO V2: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar_preview() -> void:
	var preview: Control = (load("res://vega_animada/corpo_v2/preview.tscn") as PackedScene).instantiate() as Control
	add_child(preview)
	await get_tree().process_frame
	var vega: VegaCorpoV2Prova = preview.get_node("Vega") as VegaCorpoV2Prova
	for resolucao: Vector2 in [Vector2(1024, 576), Vector2(1920, 1080)]:
		preview.size = resolucao
		await get_tree().process_frame
		var viewport: Rect2 = Rect2(Vector2.ZERO, resolucao)
		var desenho: Rect2 = Rect2(vega.position, VegaCorpoV2Prova.TAMANHO * vega.scale)
		_verificar(viewport.encloses(desenho), "base completa cabe na prévia")
		var controles: HBoxContainer = preview.get_node("Controles") as HBoxContainer
		_verificar(desenho.end.y < controles.position.y, "botas não invadem controles")
		for controle: Control in controles.get_children():
			_verificar(viewport.encloses(controle.get_global_rect()), "controles permanecem acessíveis")
	(preview.get_node("Controles/Maximo") as Button).pressed.emit()
	_verificar(vega.combo == 10 and vega.em_combate, "botão 10 ativa os dois braços")
	(preview.get_node("Controles/MaisUm") as Button).pressed.emit()
	_verificar(vega.combo == 11 and (preview.get_node("Estado") as Label).text.contains("100%"), "11 cargas mantêm máximo visual e contador real")
	(preview.get_node("Controles/Consumir") as Button).pressed.emit()
	_verificar(vega.combo == 0 and vega.em_combate, "Consumir mantém modo de combate")
	(preview.get_node("Controles/Reduzido") as CheckButton).button_pressed = true
	(preview.get_node("Controles/Combate") as Button).button_pressed = false
	_verificar(not vega.em_combate and is_zero_approx(vega.braco_frente.ativacao), "repouso reduzido é imediato")
	preview.queue_free()
	await get_tree().process_frame
