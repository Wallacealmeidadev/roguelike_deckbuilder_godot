extends RefCounted

# Dados compartilhados por todas as cópias de carta da run.
const CARTAS: Dictionary = {
	"golpe": {
		"nome": "GOLPE",
		"custo": 1,
		"valor": 6,
		"alvo": "inimigo",
		"tipo": "ataque",
		"raridade": "comum"
	},
	"protecao": {
		"nome": "PROTEÇÃO",
		"custo": 1,
		"valor": 5,
		"alvo": "jogador",
		"tipo": "habilidade",
		"raridade": "comum"
	},
	"direto_hidraulico": {
		"nome": "DIRETO HIDRÁULICO",
		"custo": 1,
		"valor": 4,
		"barreira": 2,
		"alvo": "inimigo",
		"tipo": "ataque",
		"raridade": "comum"
	},
	"quebra_chassi": {
		"nome": "QUEBRA-CHASSI",
		"custo": 1,
		"valor": 5,
		"alvo": "inimigo",
		"tipo": "ataque",
		"finalizacao": true,
		"bonus_combo": 3,
		"raridade": "comum"
	},
	"brecha": {
		"nome": "BRECHA",
		"custo": 1,
		"valor": 4,
		"alvo": "inimigo",
		"tipo": "ataque",
		"exposto": 2,
		"raridade": "comum"
	},
	"pulso_debilitante": {
		"nome": "PULSO DEBILITANTE",
		"custo": 1,
		"valor": 0,
		"barreira": 3,
		"alvo": "inimigo",
		"tipo": "habilidade",
		"enfraquecido": 2,
		"raridade": "comum"
	},
	"golpe_ariete": {
		"nome": "GOLPE DE ARÍETE",
		"custo": 2,
		"valor": 12,
		"alvo": "inimigo",
		"tipo": "ataque",
		"raridade": "rara"
	},
	"ruptura_pressao": {
		"nome": "RUPTURA DE PRESSÃO",
		"custo": 1,
		"valor": 4,
		"alvo": "inimigo",
		"tipo": "ataque",
		"exposto": 2,
		"raridade": "rara"
	},
	"placa_reforcada": {
		"nome": "PLACA REFORÇADA",
		"custo": 1,
		"valor": 8,
		"alvo": "jogador",
		"tipo": "habilidade",
		"raridade": "rara"
	}
}


static func identificadores_por_raridade(raridade: String) -> Array[String]:
	var ids: Array[String] = []
	for id_carta in CARTAS.keys():
		if str(CARTAS[id_carta].get("raridade", "comum")) == raridade:
			ids.append(str(id_carta))
	return ids
