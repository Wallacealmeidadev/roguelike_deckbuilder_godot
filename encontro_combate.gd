class_name EncontroCombate
extends RefCounted

var inimigos: Array[InimigoCombate] = []
var _inimigo: InimigoCombate
var inimigo: InimigoCombate:
	get:
		return _inimigo
	set(valor):
		_inimigo = valor
		if valor == null:
			inimigos.clear()
		elif inimigos.is_empty() or inimigos[0] != valor:
			inimigos.clear()
			inimigos.append(valor)
var baralho: BaralhoCombate = BaralhoCombate.new()
var turno: int = 1


func iniciar(inimigo_novo: InimigoCombate, baralho_run: Array[String]) -> void:
	var lista: Array[InimigoCombate] = []
	if inimigo_novo != null:
		lista.append(inimigo_novo)
	iniciar_multiplos(lista, baralho_run)


func iniciar_multiplos(novos_inimigos: Array[InimigoCombate], baralho_run: Array[String]) -> void:
	inimigos = novos_inimigos.duplicate()
	inimigo = inimigos[0] if not inimigos.is_empty() else null
	turno = 1
	baralho.preparar(baralho_run)
	for combatente in inimigos:
		combatente.reiniciar(combatente.vida_maxima)
		combatente.aliados.clear()
		for candidato in inimigos:
			if candidato != combatente:
				combatente.aliados.append(weakref(candidato))


func inimigos_vivos() -> Array[InimigoCombate]:
	var vivos: Array[InimigoCombate] = []
	for combatente in inimigos:
		if combatente.vida > 0:
			vivos.append(combatente)
	return vivos


func combate_terminou(jogador: JogadorCombate) -> bool:
	return inimigo == null or inimigos_vivos().is_empty() or jogador.estado.vida <= 0


func executar_fase_inimiga(jogador: JogadorCombate) -> Dictionary:
	var acoes: Array[Dictionary] = executar_fase_inimiga_multiplos(jogador)
	return acoes[0] if not acoes.is_empty() else {}


func executar_fase_inimiga_multiplos(jogador: JogadorCombate) -> Array[Dictionary]:
	var acoes: Array[Dictionary] = []
	if combate_terminou(jogador):
		return acoes
	for combatente in inimigos_vivos():
		if jogador.estado.vida <= 0:
			break
		var acao: Dictionary = combatente.executar_intencao()
		if acao.is_empty():
			continue
		acao["inimigo"] = combatente
		acao["resultados_golpes"] = _resolver_golpes(acao, jogador)
		if OS.is_debug_build():
			var alvo_nome: String = "Vega"
			var barreira_alvo: int = jogador.estado.barreira
			if acao["tipo"] == "defesa":
				alvo_nome = combatente.nome
				barreira_alvo = combatente.barreira
			if acao.has("alvo"):
				alvo_nome = (acao["alvo"] as InimigoCombate).nome
				barreira_alvo = (acao["alvo"] as InimigoCombate).barreira
			print("[BESTIARIO] %s: %s | alvo=%s | dano=%s | barreira_alvo=%d | cura=%d | estado=%s" % [
				combatente.nome, acao["nome"], alvo_nome,
				str(acao.get("danos", [])), barreira_alvo,
				int(acao.get("cura_real", 0)),
				"marcado" if combatente.marcado else ("recalibrando" if combatente.recalibrando else "—")
			])
		acoes.append(acao)
	return acoes


func _resolver_golpes(acao: Dictionary, jogador: JogadorCombate) -> Array[Dictionary]:
	var resultados_golpes: Array[Dictionary] = []
	if acao["tipo"] == "ataque":
		var danos: Array = acao["danos"]
		for dano in danos:
			resultados_golpes.append(jogador.estado.receber_golpe(int(dano)))
			if jogador.estado.vida <= 0:
				break
	return resultados_golpes


func avancar_turno() -> void:
	turno += 1
