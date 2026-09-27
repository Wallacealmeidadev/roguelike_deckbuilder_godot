class_name MapaRun
extends RefCounted

const TOTAL_PONTOS: int = 7
const PONTO_REENCONTRO: int = 6

const TIPO_COMBATE: String = "combate"
const TIPO_ELITE: String = "elite"
const TIPO_EVENTO: String = "evento"
const TIPO_DESCANSO: String = "descanso"
const TIPO_CHEFE: String = "chefe"

var nos: Dictionary = {}
var conexoes: Dictionary = {}
var variante: int = 0


func gerar(variante_nova: int = 0) -> void:
	nos.clear()
	conexoes.clear()
	variante = variante_nova
	if variante < 0:
		variante = -variante
	variante %= 2

	_adicionar_no(
		"inicio",
		1,
		TIPO_COMBATE,
		"Acesso das Docas",
		"drone_seguranca"
	)
	_adicionar_no(
		"unidade_contencao_portuaria",
		3,
		TIPO_ELITE,
		"Unidade de Contenção Portuária",
		"unidade_contencao_portuaria"
	)
	_adicionar_no(
		"ultimo_acesso",
		6,
		TIPO_EVENTO,
		"Último acesso",
		"fiscalizacao_corporativa"
	)
	_adicionar_no(
		"lastro",
		7,
		TIPO_CHEFE,
		"Lastro",
		"lastro"
	)

	if variante == 0:
		_adicionar_no("desvio_evento", 2, TIPO_EVENTO, "Válvula de vapor", "valvula_vapor_contaminado")
		_adicionar_no("patrulha_inicial", 2, TIPO_COMBATE, "Patrulha de serviço", "guarda_portuario")
		_adicionar_no("carga_abandonada", 4, TIPO_EVENTO, "Carga abandonada", "carga_abandonada")
		_adicionar_no("corredor_carga", 4, TIPO_COMBATE, "Corredor de carga", "estivador_cibernetico")
		_adicionar_no("descanso_estrutura", 5, TIPO_DESCANSO, "Estrutura de manutenção", "descanso")
		_adicionar_no("fiscalizacao_final", 5, TIPO_EVENTO, "Fiscalização corporativa", "fiscalizacao_corporativa")
	else:
		_adicionar_no("descanso_inicial", 2, TIPO_DESCANSO, "Abrigo de manutenção", "descanso")
		_adicionar_no("operario_ferido", 2, TIPO_EVENTO, "Operário ferido", "operario_ferido")
		_adicionar_no("torreta_servico", 4, TIPO_COMBATE, "Torreta de serviço", "torreta_contencao")
		_adicionar_no("carga_abandonada_alternativa", 4, TIPO_EVENTO, "Carga abandonada", "carga_abandonada")
		_adicionar_no("patrulha_final", 5, TIPO_COMBATE, "Patrulha final", "drone_seguranca")
		_adicionar_no("valvula_final", 5, TIPO_EVENTO, "Válvula de vapor", "valvula_vapor_contaminado")

	_conectar_para_todos("inicio", nos_no_ponto(2))
	_conectar_para_todos(nos_no_ponto(2)[0], nos_no_ponto(3))
	_conectar_para_todos(nos_no_ponto(2)[1], nos_no_ponto(3))
	_conectar_para_todos(nos_no_ponto(3)[0], nos_no_ponto(4))
	for id_ponto_4 in nos_no_ponto(4):
		_conectar_para_todos(id_ponto_4, nos_no_ponto(5))
	_conectar_para_todos(nos_no_ponto(5)[0], nos_no_ponto(PONTO_REENCONTRO))
	_conectar_para_todos(nos_no_ponto(5)[1], nos_no_ponto(PONTO_REENCONTRO))
	_conectar_para_todos(nos_no_ponto(PONTO_REENCONTRO)[0], nos_no_ponto(TOTAL_PONTOS))


func total_pontos() -> int:
	return TOTAL_PONTOS


func ponto_do_reencontro() -> int:
	return PONTO_REENCONTRO


func obter_no(id_no: String) -> Dictionary:
	if not nos.has(id_no):
		return {}
	return (nos[id_no] as Dictionary).duplicate(true)


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
