class_name DadosReliquias
extends RefCounted

const RELIQUIAS: Dictionary = {
	"juntas_retorno": {
		"nome": "Juntas de Retorno",
		"descricao": "Ao alcançar 2 Combo no turno, ganhe 3 de Barreira uma vez."
	},
	"reservatorio_auxiliar": {
		"nome": "Reservatório Auxiliar",
		"descricao": "No início de cada turno, ganhe 2 de Barreira."
	},
	"mecanismo_recuo": {
		"nome": "Mecanismo de Recuo",
		"descricao": "Uma vez por turno, após consumir Combo com Finalização, ganhe 2 de Barreira."
	}
}


static func obter(id_reliquia: String) -> Dictionary:
	if not RELIQUIAS.has(id_reliquia):
		return {}
	return RELIQUIAS[id_reliquia].duplicate(true)


static func identificadores_sem(ids_excluidos: Array[String]) -> Array[String]:
	var ids: Array[String] = []
	for id_reliquia in RELIQUIAS.keys():
		if not ids_excluidos.has(str(id_reliquia)):
			ids.append(str(id_reliquia))
	return ids
