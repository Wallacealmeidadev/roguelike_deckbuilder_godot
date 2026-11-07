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
	"ponto_da_queda": {
		"tipo": "evento",
		"evento_id": "ponto_da_queda",
		"nome": "O Ponto da Queda",
		"descricao": "A plataforma do acidente ainda guarda terminais e equipamento."
	},
	"turno_encerrado": {
		"tipo": "evento",
		"evento_id": "turno_encerrado",
		"nome": "Turno Encerrado",
		"descricao": "Trabalhadores paralisaram uma linha de carga."
	},
	"carga_descartada": {
		"tipo": "evento",
		"evento_id": "carga_descartada",
		"nome": "Carga Descartada",
		"descricao": "Um contêiner lacrado afunda entre cargas danificadas."
	},
	"caixa_preta": {
		"tipo": "evento",
		"evento_id": "caixa_preta",
		"nome": "Caixa-Preta",
		"descricao": "Um Drone de Carga destruído ainda possui registros."
	},
	"agua_morta": {
		"tipo": "evento",
		"evento_id": "agua_morta",
		"nome": "Água Morta",
		"descricao": "Uma tubulação despeja líquido contaminado na água."
	},
	"sobrevivente": {
		"tipo": "evento",
		"evento_id": "sobrevivente",
		"nome": "O Sobrevivente",
		"descricao": "Vega encontra o colega do acidente."
	},
	"posto_inspecao": {
		"tipo": "evento",
		"evento_id": "posto_inspecao",
		"nome": "Posto de Inspeção",
		"descricao": "Agentes controlam a circulação nas Docas."
	},
	"ninho_sob_cais": {
		"tipo": "evento",
		"evento_id": "ninho_sob_cais",
		"nome": "Ninho sob o Cais",
		"descricao": "Criaturas ocupam uma área sob as plataformas."
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
