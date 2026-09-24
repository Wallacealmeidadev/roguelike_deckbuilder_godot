extends Node

var falhas: int = 0


func _ready() -> void:
	var origem: Array[String] = ["a", "a", "b"]
	var seletor: SeletorInimigos = SeletorInimigos.new(origem)
	origem.clear()
	_verificar(seletor.disponiveis.size() == 2, "o seletor deve copiar e remover duplicatas")

	var primeiro: String = seletor.sortear_disponivel()
	_verificar(["a", "b"].has(primeiro), "o sorteio deve usar somente o pool")
	_verificar(seletor.enfrentados.is_empty(), "sortear não deve confirmar antes da criação")
	_verificar(seletor.registrar_enfrentado(primeiro), "um candidato válido deve ser registrável")
	_verificar(not seletor.registrar_enfrentado(primeiro), "o mesmo inimigo não deve ser registrado duas vezes")

	var segundo: String = seletor.sortear_disponivel()
	_verificar(not segundo.is_empty() and segundo != primeiro, "o segundo sorteio não deve repetir")
	_verificar(seletor.registrar_enfrentado(segundo), "o segundo candidato deve ser registrado")
	_verificar(seletor.sortear_disponivel().is_empty(), "pool esgotado deve retornar vazio")
	_verificar(not seletor.registrar_enfrentado("ausente"), "id fora do pool não deve ser registrado")

	seletor.reiniciar()
	_verificar(seletor.enfrentados.is_empty(), "reiniciar deve liberar o histórico")
	_verificar(not seletor.sortear_disponivel().is_empty(), "deve ser possível sortear em nova run")

	if falhas == 0:
		print("OK: seletor de inimigos")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
