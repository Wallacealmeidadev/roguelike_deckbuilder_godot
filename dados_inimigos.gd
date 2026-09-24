class_name DadosInimigos
extends RefCounted

const TIPOS_INTENCAO: Array[String] = ["ataque", "defesa", "preparacao"]

# Configurações compartilhadas; consumidores recebem sempre uma cópia profunda.
const INIMIGOS: Dictionary = {
	"drone_seguranca": {
		"nome": "Drone de Segurança",
		"vida": 30,
		"intencoes": [
			{"nome": "Rajada", "tipo": "ataque", "danos": [3, 3]},
			{"nome": "Blindagem de emergência", "tipo": "defesa", "valor": 6},
			{"nome": "Rajada", "tipo": "ataque", "danos": [3, 3]},
			{"nome": "Sobrecarga", "tipo": "preparacao", "bonus_por_golpe": 2},
			{"nome": "Rajada", "tipo": "ataque", "danos": [3, 3]},
			{"nome": "Marcar", "tipo": "preparacao", "bonus_por_golpe": 1}
		]
	},
	"estivador_cibernetico": {
		"nome": "Estivador Cibernético",
		"vida": 36,
		"intencoes": [
			{"nome": "Pancada", "tipo": "ataque", "danos": [8]},
			{"nome": "Postura", "tipo": "defesa", "valor": 7},
			{"nome": "Preparar", "tipo": "preparacao", "bonus_por_golpe": 4},
			{"nome": "Pancada", "tipo": "ataque", "danos": [8]}
		]
	},
	"torreta_contencao": {
		"nome": "Torreta de Contenção",
		"vida": 24,
		"intencoes": [
			{"nome": "Supressão", "tipo": "ataque", "danos": [2, 2, 2]},
			{"nome": "Placas", "tipo": "defesa", "valor": 4},
			{"nome": "Calibrar", "tipo": "preparacao", "bonus_por_golpe": 1},
			{"nome": "Supressão", "tipo": "ataque", "danos": [2, 2, 2]}
		]
	},
	"guarda_portuario": {
		"nome": "Guarda Portuário",
		"vida": 32,
		"intencoes": [
			{"nome": "Investida", "tipo": "ataque", "danos": [6]},
			{"nome": "Escudo", "tipo": "defesa", "valor": 9},
			{"nome": "Golpe", "tipo": "ataque", "danos": [7]},
			{"nome": "Escudo", "tipo": "defesa", "valor": 9}
		]
	}
}


static func identificadores() -> Array[String]:
	var ids: Array[String] = []
	for id_inimigo in INIMIGOS.keys():
		ids.append(str(id_inimigo))
	return ids


static func obter(id_inimigo: String) -> Dictionary:
	if not INIMIGOS.has(id_inimigo):
		return {}

	var dados: Dictionary = INIMIGOS[id_inimigo]
	if not dados_validos(dados):
		return {}

	return dados.duplicate(true)


static func dados_validos(dados: Dictionary) -> bool:
	if str(dados.get("nome", "")).is_empty():
		return false
	if int(dados.get("vida", 0)) <= 0:
		return false

	var intencoes: Array = dados.get("intencoes", [])
	if intencoes.is_empty():
		return false

	for intencao_variant in intencoes:
		if not (intencao_variant is Dictionary):
			return false

		var intencao: Dictionary = intencao_variant
		var tipo: String = str(intencao.get("tipo", ""))
		if str(intencao.get("nome", "")).is_empty():
			return false
		if not TIPOS_INTENCAO.has(tipo):
			return false

		if tipo == "ataque":
			var danos: Array = intencao.get("danos", [])
			if danos.is_empty():
				return false
			for dano in danos:
				if int(dano) <= 0:
					return false
		elif tipo == "defesa":
			if int(intencao.get("valor", 0)) <= 0:
				return false
		elif int(intencao.get("bonus_por_golpe", 0)) <= 0:
			return false

	return true
