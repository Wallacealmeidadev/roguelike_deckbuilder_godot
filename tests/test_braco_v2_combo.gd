extends Node

const BRACO: Script = preload("res://vega_animada/braco_v2/braco_prova.gd")
var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA COMBO: %s" % mensagem)


func _executar() -> void:
	var braco: BracoV2Prova = BRACO.new() as BracoV2Prova
	add_child(braco)
	await get_tree().process_frame
	braco.definir_combate(true, true)
	var base: PackedVector2Array = braco.biceps.polygon
	var base_antebraco: PackedVector2Array = braco.antebraco.polygon
	var uv: PackedVector2Array = braco.biceps.uv
	var uv_antebraco: PackedVector2Array = braco.antebraco.uv
	var mao: Transform2D = braco.mao.transform
	var cotovelo: Transform2D = braco.cotovelo.transform
	var escalas: Array[Vector2] = []
	var placas_base: Array[Vector2] = []
	for placa: Sprite2D in braco.placas:
		escalas.append(placa.scale)
		placas_base.append(placa.position)
	var anterior: float = 0.0
	for valor: int in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 100, 1000000, 9223372036854775807]:
		braco.definir_combo(valor, true)
		var esperado: float = float(valor) / 10.0 if valor < 10 else 1.0
		_verificar(is_equal_approx(braco.tensao_combo, esperado), "cada Combo acrescenta 10 pontos percentuais até 10 cargas")
		_verificar(braco.combo == valor, "contador visual não impõe teto mecânico")
		_verificar(braco.tensao_combo >= anterior and braco.tensao_combo <= 1.0, "tensão cresce com saturação, sem overflow")
		anterior = braco.tensao_combo
		_verificar(braco.mao.transform == mao and braco.cotovelo.transform == cotovelo, "mão e cotovelo permanecem rígidos e ancorados")
		_verificar(braco.biceps.uv == uv and braco.antebraco.uv == uv_antebraco, "as duas malhas preservam UVs")
		for malha: Polygon2D in [braco.biceps, braco.antebraco]:
			var pontos: PackedVector2Array = malha.polygon
			var referencia: PackedVector2Array = base if malha == braco.biceps else base_antebraco
			for indice: int in [0, 1, pontos.size() - 2, pontos.size() - 1]:
				_verificar(pontos[indice].is_equal_approx(referencia[indice]), "juntas não deformam com Combo")
			for linha: int in BracoV2Prova.FAIXAS + 1:
				var esquerda: Vector2 = pontos[linha * 2]
				var direita: Vector2 = pontos[linha * 2 + 1]
				_verificar(esquerda.is_finite() and direita.is_finite() and esquerda.x < direita.x, "sem vértices inválidos ou faces invertidas")
				if linha > 0:
					_verificar(esquerda.y > pontos[(linha - 1) * 2].y, "faixas não se cruzam longitudinalmente")
		for indice: int in braco.placas.size():
			_verificar(braco.placas[indice].scale == escalas[indice], "placas não escalam com Combo")
			_verificar(braco.placas[indice].position.x <= placas_base[indice].x + 8.01, "abertura das placas é limitada")
		var deslocamento: float = base[BracoV2Prova.FAIXAS].x - braco.biceps.polygon[BracoV2Prova.FAIXAS].x
		_verificar(is_equal_approx(deslocamento, 145.0 * .5 * braco.contracao_combo_biceps * esperado), "crescimento físico também segue os dez passos iguais")
	var meio: int = BracoV2Prova.FAIXAS
	_verificar(base[meio].x - braco.biceps.polygon[meio].x > 10.0, "contração máxima precisa ser mensurável")
	_verificar(base[meio].x - braco.biceps.polygon[meio].x <= 145.0 * .5 * braco.contracao_combo_biceps + .001, "contração respeita amplitude máxima")
	braco.definir_combo(0, true)
	_verificar(braco.biceps.polygon == base and braco.antebraco.polygon == base_antebraco, "zeragem restaura exatamente a base aprovada de combate")
	_verificar(is_equal_approx(braco.ativacao, 1.0), "zerar Combo não desativa combate")
	braco.definir_combo(3)
	await get_tree().create_timer(.08).timeout
	_verificar(braco.tensao_combo > 0 and braco.tensao_combo < .3, "ganho passa por valores intermediários")
	var animacao: Tween = braco.get("_animacao_combo") as Tween
	braco.definir_combo(3)
	_verificar(braco.get("_animacao_combo") == animacao, "mesmo destino não reinicia animação")
	var antes: float = braco.tensao_combo
	braco.definir_combo(0)
	_verificar(is_equal_approx(antes, braco.tensao_combo), "consumo durante ganho não salta de pose")
	for valor: int in [1, 3, 0, 100, 0, 3]:
		antes = braco.tensao_combo
		braco.definir_combo(valor)
		_verificar(is_equal_approx(antes, braco.tensao_combo), "rajada de destinos começa do valor atual")
		await get_tree().create_timer(.03).timeout
	await get_tree().create_timer(.3).timeout
	_verificar(is_equal_approx(braco.tensao_combo, .3) and not braco.animando_combo, "vence apenas o último destino, sem Tween antigo sobrescrever")
	braco.definir_combo(10)
	await get_tree().create_timer(.08).timeout
	var animacao_maxima: Tween = braco.get("_animacao_combo") as Tween
	braco.definir_combo(11)
	_verificar(braco.combo == 11 and braco.get("_animacao_combo") == animacao_maxima, "acima de 10 o contador cresce sem reiniciar movimento para o mesmo máximo")
	await get_tree().create_timer(.3).timeout
	var maximo_visual: PackedVector2Array = braco.biceps.polygon
	braco.definir_combo(100)
	_verificar(braco.combo == 100 and braco.biceps.polygon == maximo_visual and not braco.animando_combo, "100 preserva exatamente a pose de 10")
	braco.definir_combate(false)
	await get_tree().create_timer(.6).timeout
	_verificar(braco.combo == 0 and is_zero_approx(braco.tensao_combo) and is_zero_approx(braco.ativacao), "sair resolve ambas as camadas")
	braco.definir_combo(100)
	_verificar(braco.combo == 0 and is_zero_approx(braco.tensao_combo), "fora do combate não retém tensão escondida")
	braco.definir_combate(true)
	braco.definir_combo(100)
	await get_tree().create_timer(.08).timeout
	_verificar(braco.animando and braco.animando_combo, "ativação e Combo podem animar juntos")
	braco.definir_movimento_reduzido(true)
	_verificar(not braco.animando and not braco.animando_combo and is_equal_approx(braco.ativacao, 1.0), "movimento reduzido resolve as duas animações")
	_verificar(is_equal_approx(braco.tensao_combo, BracoV2Prova.tensao_por_combo(100)), "alternativa reduzida conserva pose correta")
	braco.definir_combo(-5)
	_verificar(braco.combo == 0 and braco.biceps.polygon == base, "negativos são sanitizados sem alterar a base")
	braco.definir_combo(100)
	braco.definir_ativacao(0)
	braco.definir_ativacao(1)
	_verificar(braco.combo == 0 and braco.biceps.polygon == base, "slider de repouso também limpa tensão")
	braco.queue_free()
	await get_tree().process_frame
	print("BRAÇO V2 COMBO: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)
