class_name DescansoRun
extends RefCounted

const CURA_BASE: int = 8
const BONUS_APRIMORAMENTO: int = 3
const SUFIXO_APRIMORADO: String = "#aprimorado"


func vida_a_recuperar(vida_atual: int, vida_maxima: int) -> int:
	return maxi(0, mini(CURA_BASE, vida_maxima - vida_atual))


func id_base(id_carta: String) -> String:
	if id_carta.ends_with(SUFIXO_APRIMORADO):
		return id_carta.trim_suffix(SUFIXO_APRIMORADO)
	return id_carta


func esta_aprimorada(id_carta: String) -> bool:
	return id_carta.ends_with(SUFIXO_APRIMORADO)


func cartas_elegiveis(baralho_run: Array[String]) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	var ocorrencias: Dictionary = {}
	for indice in range(baralho_run.size()):
		var token: String = baralho_run[indice]
		var base: String = id_base(token)
		var ocorrencia: int = int(ocorrencias.get(base, 0)) + 1
		ocorrencias[base] = ocorrencia
		if esta_aprimorada(token) or base.is_empty():
			continue
		resultado.append({
			"indice": indice,
			"id": base,
			"token": token,
			"ocorrencia": ocorrencia
		})
	return resultado


func dados_aprimorados(id_carta: String, dados: Dictionary) -> Dictionary:
	var resultado: Dictionary = dados.duplicate(true)
	if int(resultado.get("valor", 0)) > 0:
		resultado["valor"] = int(resultado["valor"]) + BONUS_APRIMORAMENTO
	elif resultado.has("barreira"):
		resultado["barreira"] = int(resultado["barreira"]) + BONUS_APRIMORAMENTO
	return resultado


func aplicar_melhoria(baralho_run: Array[String], indice: int) -> bool:
	if indice < 0 or indice >= baralho_run.size():
		return false
	var token: String = baralho_run[indice]
	if token.is_empty() or esta_aprimorada(token):
		return false
	baralho_run[indice] = id_base(token) + SUFIXO_APRIMORADO
	return true
