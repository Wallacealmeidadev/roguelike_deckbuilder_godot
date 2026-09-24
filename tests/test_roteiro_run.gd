extends Node

var falhas: int = 0


func _ready() -> void:
	var esperado: Array[String] = [
		"combate_comum", "evento", "combate_comum", "evento",
		"elite", "evento", "combate_comum", "evento", "combate_comum"
	]
	var roteiro: RoteiroRun = RoteiroRun.new()
	roteiro.iniciar()

	for tipo in esperado:
		_verificar(roteiro.etapa_atual() == tipo, "etapa incorreta")
		_verificar(roteiro.tem_proxima_etapa() or tipo == esperado[-1], "estado de próxima etapa incorreto")
		_verificar(roteiro.avancar(), "etapa válida deve avançar")

	_verificar(roteiro.concluido(), "o roteiro pré-chefe deve terminar")
	_verificar(roteiro.etapa_atual().is_empty(), "etapa após o fim deve ser vazia")
	_verificar(not roteiro.avancar(), "roteiro concluído não deve avançar")

	roteiro.iniciar()
	_verificar(roteiro.indice_etapa == 0, "iniciar deve voltar ao primeiro índice")
	_verificar(roteiro.etapa_atual() == "combate_comum", "reinício deve voltar ao primeiro combate")

	if falhas == 0:
		print("OK: roteiro intercalado")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
