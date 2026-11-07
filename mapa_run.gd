class_name MapaRun
extends RefCounted

const TOTAL_PONTOS: int = 11
const PONTO_REENCONTRO: int = 7

const TIPO_COMBATE: String = "combate"
const TIPO_ELITE: String = "elite"
const TIPO_EVENTO: String = "evento"
const TIPO_DESCANSO: String = "descanso"
const TIPO_DESMANCHE: String = "desmanche"
const TIPO_CHEFE: String = "chefe"

var nos: Dictionary = {}
var conexoes: Dictionary = {}
var variante: int = 0
var seed: int = 0


func gerar(seed_nova: int = 0) -> void:
	nos.clear()
	conexoes.clear()
	seed = seed_nova
	variante = posmod(seed, 2)
	_gerar_estrutura()
	_preencher_conteudo()


func _gerar_estrutura() -> void:
	_adicionar_no("inicio", 1, TIPO_COMBATE, "Acesso das Docas", "")
	_adicionar_no("evento_cais", 2, TIPO_EVENTO, "Evento das Docas", "")
	_adicionar_no("combate_entrada", 3, TIPO_COMBATE, "Patrulha de serviço", "")
	_adicionar_no("descanso_1", 4, TIPO_DESCANSO, "Abrigo de manutenção", "")
	_adicionar_no("evento_meio", 5, TIPO_EVENTO, "Evento das Docas", "")
	_adicionar_no("elite_docas", 6, TIPO_ELITE, "Unidade de Contenção Portuária", "")
	_adicionar_no("desmanche_docas", 6, TIPO_DESMANCHE, "Desmanche", "")
	_adicionar_no("combate_reencontro", 7, TIPO_COMBATE, "Corredor de carga", "")
	_adicionar_no("evento_final", 8, TIPO_EVENTO, "Evento das Docas", "")
	_adicionar_no("descanso_2", 9, TIPO_DESCANSO, "Estrutura de manutenção", "")
	_adicionar_no("combate_final", 10, TIPO_COMBATE, "Última patrulha", "")
	_adicionar_no("lastro", 11, TIPO_CHEFE, "Boss provisório", "")
	for ponto in range(1, TOTAL_PONTOS):
		for origem in nos_no_ponto(ponto):
			_conectar_para_todos(origem, nos_no_ponto(ponto + 1))


func _preencher_conteudo() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed
	var encontros_escolhidos: Array[String] = []
	for indice in range(4):
		var pool: Array[String] = DadosEncontrosDocas.EARLY_POOL
		if indice == 2:
			pool = DadosEncontrosDocas.MID_POOL
		elif indice == 3:
			pool = DadosEncontrosDocas.LATE_POOL
		var disponiveis: Array[String] = []
		for id_encontro in pool:
			if not encontros_escolhidos.has(id_encontro):
				disponiveis.append(id_encontro)
		disponiveis.sort()
		var escolhido: String = disponiveis[rng.randi_range(0, disponiveis.size() - 1)]
		encontros_escolhidos.append(escolhido)
	var ids_eventos: Array[String] = []
	for id_evento in DadosEventos.EVENTOS.keys():
		ids_eventos.append(str(id_evento))
	ids_eventos.sort()
	_embaralhar(ids_eventos, rng)
	# Neste template os eventos têm combates/REST entre si. A restrição de
	# família só se aplica a eventos diretamente consecutivos no grafo.
	# Os três eventos deste template estão separados por combate/REST no grafo.
	# A regra de família só é aplicada quando dois eventos são diretamente consecutivos;
	# aqui, portanto, basta garantir IDs distintos. O seletor futuro pode reutilizar
	# esta mesma validação quando o mapa tiver eventos adjacentes.
	var eventos_escolhidos: Array[String] = ids_eventos.slice(0, 3)
	for indice in range(4):
		var id_no: String = ["inicio", "combate_entrada", "combate_reencontro", "combate_final"][indice]
		var id_encontro: String = encontros_escolhidos[indice]
		nos[id_no]["id_conteudo"] = id_encontro
		nos[id_no]["nome"] = DadosEncontrosDocas.nome(id_encontro)
	for indice in range(3):
		var id_no: String = ["evento_cais", "evento_meio", "evento_final"][indice]
		var id_evento: String = eventos_escolhidos[indice]
		var dados: Dictionary = DadosEventos.obter(id_evento)
		nos[id_no]["id_conteudo"] = id_evento
		nos[id_no]["nome"] = str(dados.get("nome", id_no))
		nos[id_no]["familia"] = str(dados.get("familia", ""))
	for id_no in ["descanso_1", "descanso_2"]:
		nos[id_no]["id_conteudo"] = "descanso"
	nos["elite_docas"]["id_conteudo"] = "unidade_contencao_portuaria"
	nos["desmanche_docas"]["id_conteudo"] = "desmanche"
	nos["lastro"]["id_conteudo"] = "unidade_contencao_portuaria"


func _embaralhar(lista: Array[String], rng: RandomNumberGenerator) -> void:
	for indice in range(lista.size() - 1, 0, -1):
		var outro: int = rng.randi_range(0, indice)
		var temporario: String = lista[indice]
		lista[indice] = lista[outro]
		lista[outro] = temporario


func total_pontos() -> int:
	return TOTAL_PONTOS


func ponto_do_reencontro() -> int:
	return PONTO_REENCONTRO


func obter_no(id_no: String) -> Dictionary:
	if not nos.has(id_no):
		return {}
	var dados: Dictionary = (nos[id_no] as Dictionary).duplicate(true)
	dados["destinos"] = destinos_de(id_no)
	return dados


func nos_no_ponto(ponto: int) -> Array[String]:
	var resultado: Array[String] = []
	for id_no_variant in nos.keys():
		var id_no: String = str(id_no_variant)
		var dados: Dictionary = nos[id_no]
		if int(dados.get("ponto", 0)) == ponto:
			resultado.append(id_no)
	return resultado


func nos_de_tipo(tipo: String) -> Array[String]:
	var resultado: Array[String] = []
	for id_no_variant in nos.keys():
		var id_no: String = str(id_no_variant)
		var dados: Dictionary = nos[id_no]
		if str(dados.get("tipo", "")) == tipo:
			resultado.append(id_no)
	return resultado


func ponto_do_no(id_no: String) -> int:
	return int(obter_no(id_no).get("ponto", 0))


func destinos_de(id_no: String) -> Array[String]:
	var resultado: Array[String] = []
	var destinos: Array = conexoes.get(id_no, [])
	for destino_variant in destinos:
		resultado.append(str(destino_variant))
	return resultado


func todos_os_caminhos_chegam_ao_chefe() -> bool:
	var inicio: Array[String] = nos_no_ponto(1)
	var chefes: Array[String] = nos_no_ponto(TOTAL_PONTOS)
	if inicio.size() != 1 or chefes.size() != 1:
		return false

	var visitados: Dictionary = {}
	var pendentes: Array[String] = [inicio[0]]
	while not pendentes.is_empty():
		var id_atual: String = pendentes.pop_back()
		if visitados.has(id_atual):
			continue
		if not nos.has(id_atual):
			return false

		visitados[id_atual] = true
		var destinos: Array[String] = destinos_de(id_atual)
		if destinos.is_empty():
			if not chefes.has(id_atual):
				return false
		else:
			for destino in destinos:
				pendentes.append(destino)

	for id_no_variant in nos.keys():
		if not visitados.has(str(id_no_variant)):
			return false
	return true


func eventos_consecutivos_validos() -> bool:
	for origem_variant in nos.keys():
		var origem: String = str(origem_variant)
		var dados_origem: Dictionary = nos[origem]
		if str(dados_origem.get("tipo", "")) != TIPO_EVENTO:
			continue
		for destino in destinos_de(origem):
			var dados_destino: Dictionary = nos.get(destino, {})
			if str(dados_destino.get("tipo", "")) == TIPO_EVENTO and str(dados_origem.get("familia", "")) == str(dados_destino.get("familia", "")):
				return false
	return true


func _adicionar_no(
	id_no: String,
	ponto: int,
	tipo: String,
	nome: String,
	id_conteudo: String
) -> void:
	nos[id_no] = {
		"id": id_no,
		"ponto": ponto,
		"bloco": 1 if ponto <= 3 else (2 if ponto <= 6 else (3 if ponto <= 10 else 4)),
		"tipo": tipo,
		"nome": nome,
		"id_conteudo": id_conteudo
	}
	conexoes[id_no] = []


func _conectar_para_todos(origem: String, destinos: Array[String]) -> void:
	if not nos.has(origem):
		return
	var conexoes_origem: Array[String] = []
	var conexoes_existentes: Array = conexoes.get(origem, [])
	for destino_existente in conexoes_existentes:
		conexoes_origem.append(str(destino_existente))
	for destino in destinos:
		if nos.has(destino) and not conexoes_origem.has(destino):
			conexoes_origem.append(destino)
	conexoes[origem] = conexoes_origem
