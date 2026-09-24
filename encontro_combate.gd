class_name EncontroCombate
extends RefCounted

var inimigo: InimigoCombate
var baralho: BaralhoCombate = BaralhoCombate.new()
var turno: int = 1


func iniciar(inimigo_novo: InimigoCombate, baralho_run: Array[String]) -> void:
	inimigo = inimigo_novo
	turno = 1
	baralho.preparar(baralho_run)

	if inimigo != null:
		inimigo.reiniciar(inimigo.vida_maxima)


func combate_terminou(jogador: JogadorCombate) -> bool:
	return (
		inimigo == null
		or inimigo.vida <= 0
		or jogador.estado.vida <= 0
	)


func executar_fase_inimiga(jogador: JogadorCombate) -> Dictionary:
	if combate_terminou(jogador):
		return {}

	var acao: Dictionary = inimigo.executar_intencao()
	if acao.is_empty():
		return {}

	var resultados_golpes: Array[Dictionary] = []

	if acao["tipo"] == "ataque":
		var danos: Array = acao["danos"]
		for dano in danos:
			resultados_golpes.append(jogador.estado.receber_golpe(int(dano)))

			if jogador.estado.vida <= 0:
				break

	acao["resultados_golpes"] = resultados_golpes
	return acao


func avancar_turno() -> void:
	turno += 1
