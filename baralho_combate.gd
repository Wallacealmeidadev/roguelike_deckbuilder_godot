class_name BaralhoCombate
extends RefCounted

var compra: Array[String] = []
var descarte: Array[String] = []


func preparar(baralho_run: Array[String]) -> void:
	compra.clear()
	descarte.clear()
	compra.append_array(baralho_run)
	compra.shuffle()


func comprar_identificador() -> String:
	if compra.is_empty():
		if descarte.is_empty():
			return ""

		compra.append_array(descarte)
		descarte.clear()
		compra.shuffle()

	return compra.pop_back()


func descartar_identificador(id_carta: String) -> void:
	if id_carta.is_empty():
		return

	descarte.append(id_carta)
