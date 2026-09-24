extends RefCounted

# Dados compartilhados por todas as cópias de carta da run.
const CARTAS: Dictionary = {
	"golpe": {
		"nome": "GOLPE",
		"custo": 1,
		"valor": 6,
		"alvo": "inimigo",
		"tipo": "ataque"
	},
	"protecao": {
		"nome": "PROTEÇÃO",
		"custo": 1,
		"valor": 5,
		"alvo": "jogador",
		"tipo": "habilidade"
	},
	"direto_hidraulico": {
		"nome": "DIRETO HIDRÁULICO",
		"custo": 1,
		"valor": 4,
		"barreira": 2,
		"alvo": "inimigo",
		"tipo": "ataque"
	},
	"quebra_chassi": {
		"nome": "QUEBRA-CHASSI",
		"custo": 1,
		"valor": 5,
		"alvo": "inimigo",
		"tipo": "ataque",
		"finalizacao": true,
		"bonus_combo": 3
	},
	"brecha": {
		"nome": "BRECHA",
		"custo": 1,
		"valor": 4,
		"alvo": "inimigo",
		"tipo": "ataque",
		"exposto": 2
	},
	"pulso_debilitante": {
		"nome": "PULSO DEBILITANTE",
		"custo": 1,
		"valor": 0,
		"barreira": 3,
		"alvo": "inimigo",
		"tipo": "habilidade",
		"enfraquecido": 2
	}
}
