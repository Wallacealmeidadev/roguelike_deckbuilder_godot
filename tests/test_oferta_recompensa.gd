extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var pool: Array[String] = [
		"golpe",
		"protecao",
		"direto_hidraulico",
		"quebra_chassi",
		"brecha",
		"pulso_debilitante"
	]
	var oferta: OfertaRecompensa = OfertaRecompensa.new()
	oferta.gerar(pool, 3)

	_verificar(oferta.opcoes.size() == 3, "a oferta deve conter três opções")
	for id_carta in oferta.opcoes:
		_verificar(pool.has(id_carta), "toda opção deve vir do pool de recompensas")
	_verificar(
		oferta.opcoes[0] != oferta.opcoes[1]
			and oferta.opcoes[0] != oferta.opcoes[2]
			and oferta.opcoes[1] != oferta.opcoes[2],
		"a oferta não deve repetir cartas"
	)

	var pool_original: Array[String] = pool.duplicate()
	oferta.gerar(pool, 3)
	_verificar(pool == pool_original, "sortear uma oferta não pode alterar o pool")
	_verificar(oferta.opcoes.size() == 3, "uma nova oferta deve substituir a anterior")

	if falhas == 0:
		print("OK: OfertaRecompensa")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
