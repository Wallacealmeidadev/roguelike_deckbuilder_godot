class_name RunState
extends RefCounted

var seed: int = 0
var mapa: MapaRun = MapaRun.new()
var vida_atual: int = 0
var vida_maxima: int = 0
var deck: Array[String] = []
var reliquias: Array[String] = []
var flags: Array[String] = []
var eventos_resolvidos: Array[String] = []
var no_atual: String = ""
var no_em_andamento: String = ""
var concluidos: Array[String] = []


func iniciar(nova_seed: int, nova_vida_maxima: int, deck_inicial: Array[String], reliquias_iniciais: Array[String]) -> void:
	seed = nova_seed
	mapa.gerar(seed)
	vida_maxima = maxi(1, nova_vida_maxima)
	vida_atual = vida_maxima
	deck = deck_inicial.duplicate()
	reliquias = reliquias_iniciais.duplicate()
	flags.clear()
	eventos_resolvidos.clear()
	no_atual = ""
	no_em_andamento = ""
	concluidos.clear()
	if OS.is_debug_build():
		var resumo: PackedStringArray = []
		for ponto in range(1, mapa.total_pontos() + 1):
			for id_no in mapa.nos_no_ponto(ponto):
				var dados: Dictionary = mapa.obter_no(id_no)
				resumo.append("%d:%s=%s" % [ponto, str(dados.get("tipo", "")), str(dados.get("id_conteudo", ""))])
		print("RUN seed=%d estrutura/conteúdo: %s" % [seed, " | ".join(resumo)])


func destinos_disponiveis() -> Array[String]:
	var destinos: Array[String] = []
	if not no_em_andamento.is_empty():
		return destinos
	var candidatos: Array[String] = mapa.nos_no_ponto(1) if no_atual.is_empty() else mapa.destinos_de(no_atual)
	for id_no in candidatos:
		if not concluidos.has(id_no):
			destinos.append(id_no)
	return destinos


func iniciar_no(id_no: String) -> bool:
	if not destinos_disponiveis().has(id_no):
		return false
	no_em_andamento = id_no
	if OS.is_debug_build():
		print("RUN entrou no nó %s: %s" % [id_no, str(mapa.obter_no(id_no))])
	return true


func concluir_no() -> bool:
	if no_em_andamento.is_empty():
		return false
	if not concluidos.has(no_em_andamento):
		concluidos.append(no_em_andamento)
	no_atual = no_em_andamento
	no_em_andamento = ""
	if OS.is_debug_build():
		print("RUN concluiu %s (Vida %d/%d; deck %d)" % [no_atual, vida_atual, vida_maxima, deck.size()])
	return true


func registrar_vida(valor: int) -> void:
	vida_atual = clampi(valor, 0, vida_maxima)


func adicionar_flag(id_flag: String) -> void:
	if not id_flag.is_empty() and not flags.has(id_flag):
		flags.append(id_flag)
		if OS.is_debug_build():
			print("RUN flag %s" % id_flag)


func possui_flag(id_flag: String) -> bool:
	return flags.has(id_flag)


func registrar_evento_resolvido(id_evento: String) -> void:
	if not id_evento.is_empty() and not eventos_resolvidos.has(id_evento):
		eventos_resolvidos.append(id_evento)


func evento_ja_resolvido(id_evento: String) -> bool:
	return eventos_resolvidos.has(id_evento)
