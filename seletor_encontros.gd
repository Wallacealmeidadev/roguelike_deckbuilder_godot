class_name SeletorEncontros
extends RefCounted

var disponiveis: Array[String] = []
var encontrados: Array[String] = []


func _init(ids_disponiveis: Array[String]) -> void:
	for id_encontro in ids_disponiveis:
		if not id_encontro.is_empty() and not disponiveis.has(id_encontro):
			disponiveis.append(id_encontro)


func sortear_disponivel() -> String:
	var candidatos: Array[String] = []
	for id_encontro in disponiveis:
		if not encontrados.has(id_encontro):
			candidatos.append(id_encontro)

	if candidatos.is_empty():
		return ""

	return candidatos.pick_random()


func registrar_encontrado(id_encontro: String) -> bool:
	if not disponiveis.has(id_encontro) or encontrados.has(id_encontro):
		return false

	encontrados.append(id_encontro)
	return true


func reiniciar() -> void:
	encontrados.clear()
