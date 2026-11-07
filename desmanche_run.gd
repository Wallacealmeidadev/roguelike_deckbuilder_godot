class_name DesmancheRun
extends RefCounted

var melhoria: DescansoRun = DescansoRun.new()


func remover(deck: Array[String], indice: int) -> bool:
	if deck.size() <= 1 or indice < 0 or indice >= deck.size():
		return false
	deck.remove_at(indice)
	return true


func recalibrar(deck: Array[String], indice: int) -> bool:
	return melhoria.aplicar_melhoria(deck, indice)
