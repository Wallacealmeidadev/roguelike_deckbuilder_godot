class_name OfertaRecompensa
extends RefCounted

var opcoes: Array[String] = []


func gerar(pool: Array[String], quantidade: int) -> void:
	opcoes.clear()

	var candidatos: Array[String] = pool.duplicate()
	candidatos.shuffle()

	for id_carta in candidatos:
		if opcoes.size() >= quantidade:
			break
		if not opcoes.has(id_carta):
			opcoes.append(id_carta)
