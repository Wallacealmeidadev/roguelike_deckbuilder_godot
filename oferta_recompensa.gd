class_name OfertaRecompensa
extends RefCounted

const DADOS_CARTAS: Script = preload("res://dados_cartas.gd")

var opcoes: Array[String] = []


func gerar_combate(tipo: String) -> void:
	opcoes.clear()
	var nao_raras: Array[String] = DADOS_CARTAS.identificadores_por_raridade("comum")
	nao_raras.append_array(DADOS_CARTAS.identificadores_por_raridade("incomum"))
	nao_raras.shuffle()
	if tipo == "elite":
		var raras: Array[String] = DADOS_CARTAS.identificadores_por_raridade("rara")
		raras.shuffle()
		if not raras.is_empty():
			opcoes.append(raras[0])
	for id_carta in nao_raras:
		if opcoes.size() >= 3:
			break
		opcoes.append(id_carta)
	opcoes.shuffle()


func gerar(pool: Array[String], quantidade: int) -> void:
	opcoes.clear()

	var candidatos: Array[String] = pool.duplicate()
	candidatos.shuffle()

	for id_carta in candidatos:
		if opcoes.size() >= quantidade:
			break
		if not opcoes.has(id_carta):
			opcoes.append(id_carta)
