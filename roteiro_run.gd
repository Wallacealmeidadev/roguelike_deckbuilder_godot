class_name RoteiroRun
extends RefCounted

const ETAPAS_PRE_CHEFE: Array[String] = [
	"combate_comum",
	"evento",
	"combate_comum",
	"evento",
	"elite",
	"evento",
	"combate_comum",
	"evento",
	"combate_comum"
]

var indice_etapa: int = -1


func iniciar() -> void:
	indice_etapa = 0


func etapa_atual() -> String:
	if indice_etapa < 0 or indice_etapa >= ETAPAS_PRE_CHEFE.size():
		return ""
	return ETAPAS_PRE_CHEFE[indice_etapa]


func tem_proxima_etapa() -> bool:
	return indice_etapa >= 0 and indice_etapa + 1 < ETAPAS_PRE_CHEFE.size()


func avancar() -> bool:
	if concluido():
		return false

	indice_etapa += 1
	return true


func concluido() -> bool:
	return indice_etapa >= ETAPAS_PRE_CHEFE.size()
