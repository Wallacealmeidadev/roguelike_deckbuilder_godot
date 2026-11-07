class_name DadosEncontrosDocas
extends RefCounted

const ENCONTROS: Dictionary = {
	"carga": ["drone_carga"],
	"estivador": ["estivador_aumentado"],
	"caranguejo": ["caranguejo_sucata"],
	"sentinela": ["sentinela_inspecao"],
	"guindaste": ["guindaste_autonomo"],
	"estivador_reparador": ["estivador_aumentado", "drone_reparador"],
	"carga_reparador": ["drone_carga", "drone_reparador"],
	"dois_caranguejos": ["caranguejo_sucata", "caranguejo_sucata"],
	"sentinela_reparador": ["sentinela_inspecao", "drone_reparador"]
}

const EARLY_POOL: Array[String] = ["carga", "estivador", "caranguejo", "sentinela"]
const MID_POOL: Array[String] = ["carga", "estivador", "caranguejo", "sentinela", "guindaste", "carga_reparador", "dois_caranguejos"]
const LATE_POOL: Array[String] = ["guindaste", "estivador_reparador", "carga_reparador", "dois_caranguejos", "sentinela_reparador", "sentinela"]


static func obter(id_encontro: String) -> Array[String]:
	var ids: Array[String] = []
	if not ENCONTROS.has(id_encontro):
		return ids
	for id_inimigo in ENCONTROS[id_encontro]:
		ids.append(str(id_inimigo))
	return ids


static func nome(id_encontro: String) -> String:
	var partes: PackedStringArray = []
	for id_inimigo in obter(id_encontro):
		partes.append(str(DadosInimigos.obter(id_inimigo).get("nome", id_inimigo)))
	return " + ".join(partes)
