extends Node

var falhas: int = 0


func _ready() -> void:
	var script_regras: Script = load("res://desmanche_run.gd") as Script
	_verificar(script_regras != null, "regras do Desmanche devem existir")
	if script_regras == null:
		get_tree().quit(1)
		return
	var regras: RefCounted = script_regras.new()
	var deck: Array[String] = ["golpe", "golpe", "protecao"]
	_verificar(bool(regras.call("remover", deck, 1)), "deve remover uma cópia por índice")
	_verificar(deck == ["golpe", "protecao"], "a outra cópia permanece")
	_verificar(bool(regras.call("recalibrar", deck, 0)), "deve recalibrar uma cópia")
	_verificar(deck == ["golpe#aprimorado", "protecao"], "só a cópia escolhida melhora")
	_verificar(not bool(regras.call("recalibrar", deck, 0)), "não deve recalibrar duas vezes")
	_verificar(not bool(regras.call("remover", deck, -1)), "índice inválido não remove")
	_verificar(bool(regras.call("remover", deck, 1)), "permite remover até restar uma")
	_verificar(not bool(regras.call("remover", deck, 0)), "não deixa deck vazio")
	if falhas == 0:
		print("OK: serviços do Desmanche")
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
