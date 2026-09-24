extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var baralho: BaralhoCombate = BaralhoCombate.new()
	var original: Array[String] = ["golpe", "protecao", "quebra_chassi"]
	baralho.preparar(original)

	_verificar(baralho.compra.size() == 3, "preparar deve copiar o baralho para a pilha de compra")
	_verificar(baralho.descarte.is_empty(), "preparar deve começar com descarte vazio")

	var compradas: Array[String] = []
	for i in range(3):
		compradas.append(baralho.comprar_identificador())

	_verificar(compradas.size() == 3, "a compra deve retornar todas as cartas disponíveis")
	_verificar(baralho.compra.is_empty(), "a pilha de compra deve esvaziar após comprar tudo")
	_verificar(original == ["golpe", "protecao", "quebra_chassi"], "o baralho da run não pode ser alterado")

	baralho.descartar_identificador(compradas[0])
	_verificar(baralho.descarte == [compradas[0]], "descartar deve guardar o identificador")

	var recuperada: String = baralho.comprar_identificador()
	_verificar(recuperada == compradas[0], "comprar deve reembaralhar o descarte quando necessário")
	_verificar(baralho.compra.is_empty(), "a pilha deve continuar vazia após recuperar o único descarte")
	_verificar(baralho.descarte.is_empty(), "o descarte deve ser transferido para a compra")
	_verificar(baralho.comprar_identificador() == "", "compra vazia deve retornar string vazia")

	if falhas == 0:
		print("OK: BaralhoCombate")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
