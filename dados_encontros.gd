class_name DadosEncontros
extends RefCounted

const TIPOS: Array[String] = ["combate", "elite", "evento"]

const ENCONTROS: Dictionary = {
	"drone_seguranca": {
		"tipo": "combate",
		"nome": "Drone de Segurança",
		"descricao": "Um drone de segurança patrulha os acessos das Docas.",
		"inimigo_id": "drone_seguranca"
	},
	"estivador_cibernetico": {
		"tipo": "combate",
		"nome": "Estivador Cibernético",
		"descricao": "Um estivador reforçado protege uma área de carga.",
		"inimigo_id": "estivador_cibernetico"
	},
	"torreta_contencao": {
		"tipo": "combate",
		"nome": "Torreta de Contenção",
		"descricao": "Uma torreta industrial bloqueia uma passagem de serviço.",
		"inimigo_id": "torreta_contencao"
	},
	"guarda_portuario": {
		"tipo": "combate",
		"nome": "Guarda Portuário",
		"descricao": "Um guarda corporativo fiscaliza o fluxo de trabalhadores.",
		"inimigo_id": "guarda_portuario"
	},
	"unidade_contencao_portuaria": {
		"tipo": "elite",
		"nome": "Unidade de Contenção Portuária",
		"descricao": "Uma máquina de infraestrutura pressurizada protege a doca.",
		"inimigo_id": "unidade_contencao_portuaria"
	},
	"valvula_vapor_contaminado": {
		"tipo": "evento",
		"evento_id": "valvula_vapor_contaminado",
		"nome": "Válvula de vapor contaminado",
		"descricao": "Uma válvula defeituosa libera vapor contaminado entre as docas."
	},
	"carga_abandonada": {
		"tipo": "evento",
		"evento_id": "carga_abandonada",
		"nome": "Carga abandonada",
		"descricao": "Uma carga sem proprietário visível foi deixada em um corredor de serviço."
	},
	"operario_ferido": {
		"tipo": "evento",
		"evento_id": "operario_ferido",
		"nome": "Operário ferido",
		"descricao": "Um operário pede ajuda antes que a fiscalização o encontre."
	},
	"ladrao_de_cartas": {
		"tipo": "evento",
		"evento_id": "ladrao_de_cartas",
		"nome": "Ladrão de cartas",
		"descricao": "Um ladrão tenta levar uma carta do baralho de Vega."
	},
	"fiscalizacao_corporativa": {
		"tipo": "evento",
		"evento_id": "fiscalizacao_corporativa",
		"nome": "Fiscalização corporativa",
		"descricao": "Uma equipe corporativa bloqueia a passagem e exige uma explicação."
	}
}


static func identificadores() -> Array[String]:
	var ids: Array[String] = []
	for id_encontro in ENCONTROS.keys():
		ids.append(str(id_encontro))
	return ids


static func identificadores_por_tipo(tipo: String) -> Array[String]:
	var ids: Array[String] = []
	if not TIPOS.has(tipo):
		return ids

	for id_encontro in ENCONTROS.keys():
		var dados: Dictionary = ENCONTROS[id_encontro]
		if dados.get("tipo", "") == tipo:
			ids.append(str(id_encontro))
	return ids


static func obter(id: String) -> Dictionary:
	if not ENCONTROS.has(id):
		return {}
	return ENCONTROS[id].duplicate(true)
