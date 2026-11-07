class_name ResolucaoEventos
extends RefCounted


static func resolver(
	id_evento: String,
	id_opcao: String,
	jogador: JogadorCombate,
	flags_run: Array[String] = []
) -> Dictionary:
	var resultado: Dictionary = {
		"valida": false,
		"tipo": "invalida",
		"texto": "Essa escolha não está disponível.",
		"vida_delta": 0,
		"id_inimigo": "",
		"concluido": true,
		"flags_concedidas": [],
		"recompensa": {},
		"deck_acao": "",
		"filtro_carta": ""
	}

	if jogador == null:
		return resultado

	var evento: Dictionary = DadosEventos.obter(id_evento)
	if evento.is_empty():
		return resultado

	var opcoes: Array[Dictionary] = DadosEventos.opcoes_disponiveis(id_evento, flags_run)
	for opcao_variant in opcoes:
		var opcao: Dictionary = opcao_variant
		if opcao.get("id", "") != id_opcao:
			continue

		resultado["valida"] = true
		resultado["tipo"] = str(opcao.get("tipo", "concluido"))
		resultado["texto"] = str(opcao.get("texto", ""))
		resultado["vida_delta"] = int(opcao.get("vida_delta", 0))
		resultado["id_inimigo"] = str(opcao.get("id_inimigo", ""))
		resultado["concluido"] = bool(opcao.get("concluido", resultado["tipo"] != "combate_especial"))
		resultado["flags_concedidas"] = (opcao.get("flags_concedidas", []) as Array).duplicate()
		resultado["recompensa"] = (opcao.get("recompensa", {}) as Dictionary).duplicate(true)
		resultado["deck_acao"] = str(opcao.get("deck_acao", ""))
		resultado["filtro_carta"] = str(opcao.get("filtro_carta", ""))
		return resultado

	return resultado
