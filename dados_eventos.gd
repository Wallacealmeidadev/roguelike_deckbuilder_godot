class_name DadosEventos
extends RefCounted

const EVENTOS: Dictionary = {
	"valvula_vapor_contaminado": {
		"evento_id": "valvula_vapor_contaminado",
		"nome": "Válvula de vapor contaminado",
		"descricao": "Uma válvula defeituosa libera vapor contaminado entre as docas.",
		"opcoes": [
			{
				"id": "desligar",
				"nome": "Desligar a válvula",
				"tipo": "combate_especial",
				"id_inimigo": "torreta_contencao",
				"texto": "A pressão desperta uma máquina de contenção."
			},
			{
				"id": "contornar",
				"nome": "Contornar a tubulação",
				"tipo": "concluido",
				"texto": "Vega encontra uma rota mais longa e evita o vapor.",
				"concluido": true
			}
		]
	},
	"carga_abandonada": {
		"evento_id": "carga_abandonada",
		"nome": "Carga abandonada",
		"descricao": "Uma carga sem proprietário visível foi deixada em um corredor de serviço.",
		"opcoes": [
			{
				"id": "vasculhar",
				"nome": "Vasculhar a carga",
				"tipo": "concluido",
				"texto": "Vega encontra um componente útil na carga abandonada.",
				"concluido": true
			},
			{
				"id": "seguir",
				"nome": "Seguir sem tocar",
				"tipo": "concluido",
				"texto": "Vega deixa a carga onde a encontrou.",
				"concluido": true
			}
		]
	},
	"operario_ferido": {
		"evento_id": "operario_ferido",
		"nome": "Operário ferido",
		"descricao": "Um operário pede ajuda antes que a fiscalização o encontre.",
		"opcoes": [
			{
				"id": "ajudar",
				"nome": "Ajudar o operário",
				"tipo": "vida",
				"vida_delta": -10,
				"texto": "Vega sacrifica 10 de Vida para tirar o operário do caminho.",
				"concluido": true
			},
			{
				"id": "ignorar",
				"nome": "Ignorar o pedido",
				"tipo": "consequencia",
				"texto": "O pedido fica para trás enquanto a fiscalização se aproxima.",
				"concluido": true
			}
		]
	},
	"ladrao_de_cartas": {
		"evento_id": "ladrao_de_cartas",
		"nome": "Ladrão de cartas",
		"descricao": "Um ladrão tenta levar uma carta do baralho de Vega.",
		"opcoes": [
			{
				"id": "entregar_carta",
				"nome": "Entregar uma carta",
				"tipo": "concluido",
				"texto": "Vega entrega uma carta para evitar uma briga.",
				"concluido": true
			},
			{
				"id": "enfrentar",
				"nome": "Enfrentar o ladrão",
				"tipo": "combate_especial",
				"id_inimigo": "guarda_portuario",
				"texto": "A confusão chama a atenção de um guarda portuário.",
				"concluido": false
			}
		]
	},
	"fiscalizacao_corporativa": {
		"evento_id": "fiscalizacao_corporativa",
		"nome": "Fiscalização corporativa",
		"descricao": "Uma equipe corporativa bloqueia a passagem e exige uma explicação.",
		"opcoes": [
			{
				"id": "cooperar",
				"nome": "Cooperar",
				"tipo": "concluido",
				"texto": "A equipe registra a passagem de Vega e libera o caminho.",
				"concluido": true
			},
			{
				"id": "se_esconder",
				"nome": "Se esconder",
				"tipo": "concluido",
				"texto": "Vega espera a equipe passar antes de continuar.",
				"concluido": true
			},
			{
				"id": "confrontar",
				"nome": "Confrontar a fiscalização",
				"tipo": "combate_especial",
				"id_inimigo": "guarda_portuario",
				"texto": "A fiscalização chama reforço para deter Vega.",
				"concluido": false
			}
		]
	}
}


static func obter(id_evento: String) -> Dictionary:
	if not EVENTOS.has(id_evento):
		return {}
	return EVENTOS[id_evento].duplicate(true)
