extends Node

var falhas: int = 0


func _ready() -> void:
	var origem: Array[String] = DadosEncontros.identificadores_por_tipo("evento")
	var seletor: SeletorEncontros = SeletorEncontros.new(origem)
	origem.clear()
	_verificar(seletor.disponiveis.size() == 8, "o seletor deve copiar o pool")

	var sorteados: Array[String] = []
	for i in range(8):
		var id_evento: String = seletor.sortear_disponivel()
		_verificar(not id_evento.is_empty(), "deve sortear enquanto houver eventos")
		_verificar(not sorteados.has(id_evento), "não deve repetir evento")
		_verificar(seletor.registrar_encontrado(id_evento), "evento válido deve ser registrável")
		sorteados.append(id_evento)

	_verificar(seletor.sortear_disponivel().is_empty(), "pool esgotado deve retornar vazio")
	_verificar(not seletor.registrar_encontrado("ausente"), "id fora do pool não deve ser registrado")
	_verificar(not seletor.registrar_encontrado(sorteados[0]), "duplicata não deve ser registrada")

	seletor.reiniciar()
	_verificar(seletor.encontrados.is_empty(), "reiniciar deve liberar o histórico")
	_verificar(not seletor.sortear_disponivel().is_empty(), "deve sortear em nova run")

	if falhas == 0:
		print("OK: seletor de encontros")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
