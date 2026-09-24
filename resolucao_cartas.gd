class_name ResolucaoCartas
extends RefCounted


func resolver(
	id_carta: String,
	catalogo: Dictionary,
	fonte: Combatente,
	alvo: Combatente,
	destino: String,
	contexto: Dictionary
) -> Dictionary:
	var combo_atual: int = int(contexto.get("combo", 0))
	var resultado: Dictionary = {
		"valida": false,
		"custo": 0,
		"dano": 0,
		"barreira": 0,
		"combo": combo_atual,
		"gera_combo": false,
		"consome_combo": false,
		"estados_aplicados": {}
	}

	if not catalogo.has(id_carta):
		return resultado

	var dados: Dictionary = catalogo[id_carta]
	var custo: int = int(dados["custo"])
	resultado["custo"] = custo

	if dados["alvo"] != destino:
		return resultado

	var energia: int = int(contexto.get("energia", 0))
	if energia < custo:
		return resultado

	resultado["valida"] = true
	var eh_ataque: bool = dados.get("tipo", "ataque") == "ataque"

	if destino == "inimigo" and eh_ataque:
		var dano: int = int(dados["valor"])
		var finalizacao: bool = dados.get("finalizacao", false)

		if finalizacao:
			dano += combo_atual * int(dados["bonus_combo"])
			resultado["combo"] = 0
			resultado["consome_combo"] = true
		else:
			var combo_maximo: int = int(contexto.get("combo_maximo", 5))
			resultado["combo"] = mini(combo_maximo, combo_atual + 1)
			resultado["gera_combo"] = true

		var recebimento: Dictionary = alvo.receber_golpe(dano)
		resultado["dano"] = dano
		resultado["absorvido"] = recebimento["absorvido"]
		resultado["dano_na_vida"] = recebimento["dano_na_vida"]

		if dados.has("barreira"):
			var barreira_ataque: int = int(dados["barreira"])
			fonte.aplicar_barreira(barreira_ataque)
			resultado["barreira"] = barreira_ataque

		if dados.has("exposto") and alvo.vida > 0:
			var exposto: int = int(dados["exposto"])
			alvo.aplicar_exposto(exposto)
			resultado["estados_aplicados"]["exposto"] = exposto

		return resultado

	if destino == "inimigo":
		var enfraquecido: int = int(dados["enfraquecido"])
		alvo.aplicar_enfraquecido(enfraquecido)
		resultado["estados_aplicados"]["enfraquecido"] = enfraquecido

		if dados.has("barreira"):
			var barreira_habilidade: int = int(dados["barreira"])
			fonte.aplicar_barreira(barreira_habilidade)
			resultado["barreira"] = barreira_habilidade
	else:
		var barreira_jogador: int = int(dados["valor"])
		fonte.aplicar_barreira(barreira_jogador)
		resultado["barreira"] = barreira_jogador

	return resultado
