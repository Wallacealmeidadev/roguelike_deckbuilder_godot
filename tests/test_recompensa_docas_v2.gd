extends Node

const DADOS_CARTAS: Script = preload("res://dados_cartas.gd")

var falhas: int = 0


func _ready() -> void:
	var oferta: OfertaRecompensa = OfertaRecompensa.new()
	for _indice in range(60):
		oferta.gerar_combate("comum")
		_verificar(oferta.opcoes.size() == 3, "comum oferece três cartas")
		for id_carta in oferta.opcoes:
			_verificar(str(DADOS_CARTAS.CARTAS[id_carta].get("raridade", "")) in ["comum", "incomum"], "comum nunca oferece rara")
		oferta.gerar_combate("elite")
		_verificar(oferta.opcoes.size() == 3, "elite oferece três cartas")
		var raras: int = 0
		for id_carta in oferta.opcoes:
			if str(DADOS_CARTAS.CARTAS[id_carta].get("raridade", "")) == "rara":
				raras += 1
		_verificar(raras == 1, "elite garante exatamente uma rara")
		_verificar(oferta.opcoes[0] != oferta.opcoes[1] and oferta.opcoes[1] != oferta.opcoes[2] and oferta.opcoes[0] != oferta.opcoes[2], "oferta não repete cartas")
	if falhas == 0:
		print("OK: pools de recompensa das Docas")
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
