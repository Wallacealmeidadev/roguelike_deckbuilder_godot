class_name SeletorInimigos
extends RefCounted

var disponiveis: Array[String] = []
var enfrentados: Array[String] = []


func _init(ids_disponiveis: Array[String]) -> void:
	for id_inimigo in ids_disponiveis:
		if not id_inimigo.is_empty() and not disponiveis.has(id_inimigo):
			disponiveis.append(id_inimigo)


func sortear_disponivel() -> String:
	var candidatos: Array[String] = []
	for id_inimigo in disponiveis:
		if not enfrentados.has(id_inimigo):
			candidatos.append(id_inimigo)

	if candidatos.is_empty():
		return ""

	return candidatos.pick_random()


func registrar_enfrentado(id_inimigo: String) -> bool:
	if not disponiveis.has(id_inimigo) or enfrentados.has(id_inimigo):
		return false

	enfrentados.append(id_inimigo)
	return true


func reiniciar() -> void:
	enfrentados.clear()
