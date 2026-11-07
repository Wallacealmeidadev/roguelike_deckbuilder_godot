class_name DadosInimigos
extends RefCounted

const TIPOS_INTENCAO: Array[String] = ["ataque", "defesa", "preparacao", "marcar", "recalibrar", "travar", "defesa_aliado", "cura_aliado"]

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

const ELITES: Dictionary = {
	"unidade_contencao_portuaria": {
		"nome": "Unidade de Contenção Portuária",
		"vida": 44,
		"intencoes": [
			{"nome": "Pressurizar", "tipo": "preparacao", "bonus_por_golpe": 2},
			{"nome": "Rajada de contenção", "tipo": "ataque", "danos": [5, 5]},
			{"nome": "Blindagem pesada", "tipo": "defesa", "valor": 8},
			{"nome": "Golpe de pistão", "tipo": "ataque", "danos": [8]}
		]
	}
}

const DOCAS: Dictionary = {
	"drone_carga": {"nome": "Drone de Carga", "vida": 26, "intencoes": [
		{"nome": "Blindagem de Carga", "tipo": "defesa", "valor": 7},
		{"nome": "Investida Hidráulica", "tipo": "ataque", "danos": [10]},
		{"nome": "Braço Mecânico", "tipo": "ataque", "danos": [6]}]},
	"estivador_aumentado": {"nome": "Estivador Aumentado", "vida": 34, "intencoes": [
		{"nome": "Soco Protético", "tipo": "ataque", "danos": [7]},
		{"nome": "Ombro de Carga", "tipo": "ataque", "danos": [5], "prepara": 2}]},
	"drone_reparador": {"nome": "Drone Reparador", "vida": 18, "intencoes": [
		{"nome": "Reforço Estrutural", "tipo": "defesa_aliado", "valor": 6},
		{"nome": "Pulso Elétrico", "tipo": "ataque", "danos": [4]},
		{"nome": "Reparo de Emergência", "tipo": "cura_aliado", "valor": 5}]},
	"sentinela_inspecao": {"nome": "Sentinela de Inspeção", "vida": 25, "intencoes": [
		{"nome": "Aquisição de Alvo", "tipo": "marcar"},
		{"nome": "Disparo Direcionado", "tipo": "ataque", "danos": [8]},
		{"nome": "Disparo de Supressão", "tipo": "ataque", "danos": [6]}]},
	"caranguejo_sucata": {"nome": "Caranguejo de Sucata", "vida": 22, "intencoes": [
		{"nome": "Garras", "tipo": "ataque", "danos": [3, 3, 3]},
		{"nome": "Casco de Sucata", "tipo": "defesa", "valor": 8},
		{"nome": "Mordida Mecânica", "tipo": "ataque", "danos": [7]}]},
	"guindaste_autonomo": {"nome": "Guindaste Autônomo", "vida": 38, "intencoes": [
		{"nome": "Travando Alvo", "tipo": "travar"},
		{"nome": "Impacto de Contêiner", "tipo": "ataque", "danos": [18]},
		{"nome": "Recalibrando", "tipo": "recalibrar"}]}
}


static func identificadores() -> Array[String]:
	var ids: Array[String] = []
	for id_inimigo in INIMIGOS.keys():
		ids.append(str(id_inimigo))
	return ids


static func identificadores_elite() -> Array[String]:
	var ids: Array[String] = []
	for id_inimigo in ELITES.keys():
		ids.append(str(id_inimigo))
	return ids


static func obter(id_inimigo: String) -> Dictionary:
	var catalogo: Dictionary = INIMIGOS
	if not catalogo.has(id_inimigo):
		catalogo = ELITES
	if not catalogo.has(id_inimigo):
		catalogo = DOCAS
	if not catalogo.has(id_inimigo):
		return {}

	var dados: Dictionary = catalogo[id_inimigo]
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
		elif tipo == "defesa" or tipo == "defesa_aliado" or tipo == "cura_aliado":
			if int(intencao.get("valor", 0)) <= 0:
				return false
		elif tipo == "preparacao" and int(intencao.get("bonus_por_golpe", 0)) <= 0:
			return false

	return true
