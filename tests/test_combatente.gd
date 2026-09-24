extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var alvo: Combatente = Combatente.new(30)
	alvo.aplicar_exposto(2)
	alvo.aplicar_barreira(6)

	var resultado: Dictionary = alvo.receber_golpe(4)
	_verificar(resultado["dano"] == 6, "Exposto deve modificar o golpe antes da Barreira")
	_verificar(resultado["absorvido"] == 6, "a Barreira deve absorver o dano modificado")
	_verificar(resultado["dano_na_vida"] == 0, "a Barreira deve impedir dano à Vida")
	_verificar(alvo.exposto == 1, "Exposto deve consumir uma carga por golpe")
	_verificar(alvo.vida == 30, "a Vida deve permanecer quando a Barreira absorve tudo")

	resultado = alvo.receber_golpe(4)
	_verificar(resultado["dano"] == 6, "Exposto deve modificar o segundo golpe")
	_verificar(alvo.exposto == 0, "Exposto deve terminar depois de duas cargas")
	_verificar(alvo.barreira == 0, "a Barreira deve ser consumida")
	_verificar(alvo.vida == 24, "o excedente deve atingir a Vida")

	var atacante: Combatente = Combatente.new(10)
	atacante.aplicar_enfraquecido(2)
	_verificar(atacante.calcular_dano_de_ataque(3) == 1, "Enfraquecido deve reduzir o primeiro golpe")
	_verificar(atacante.calcular_dano_de_ataque(3) == 1, "Enfraquecido deve reduzir o segundo golpe")
	_verificar(atacante.calcular_dano_de_ataque(3) == 3, "o dano deve voltar ao normal após consumir as cargas")

	atacante.aplicar_enfraquecido(1)
	_verificar(atacante.calcular_dano_de_ataque(1) == 0, "o dano reduzido não pode ficar negativo")

	alvo.aplicar_barreira(8)
	alvo.aplicar_exposto(4)
	alvo.reiniciar(40)
	_verificar(alvo.vida == 40, "reiniciar deve restaurar a Vida inicial")
	_verificar(alvo.vida_maxima == 40, "reiniciar deve atualizar a Vida máxima")
	_verificar(alvo.barreira == 0, "reiniciar deve limpar a Barreira")
	_verificar(alvo.exposto == 0, "reiniciar deve limpar Exposto")
	_verificar(alvo.enfraquecido == 0, "reiniciar deve limpar Enfraquecido")

	if falhas == 0:
		print("OK: Combatente genérico")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
