extends Node

var falhas: int = 0


func _ready() -> void:
	var mapa: MapaRun = MapaRun.new()
	mapa.gerar(42)
	_verificar(mapa.total_pontos() == 11, "template inicial deve ter onze nós percorridos")
	_verificar(mapa.nos_no_ponto(1).size() == 1, "há um único início")
	_verificar(mapa.nos_no_ponto(6).size() == 2, "o sexto ponto bifurca")
	_verificar(mapa.nos_no_ponto(7).size() == 1, "as rotas reconvergem no sétimo")
	var origem: String = mapa.nos_no_ponto(5)[0]
	var alternativas: Array[String] = mapa.destinos_de(origem)
	_verificar(alternativas.has("elite_docas") and alternativas.has("desmanche_docas"), "elite sempre tem alternativa no primeiro template")
	for alternativa in alternativas:
		_verificar(mapa.destinos_de(alternativa) == mapa.nos_no_ponto(7), "ambos os ramos retornam ao mesmo ponto")
	_verificar(mapa.obter_no("elite_docas").get("bloco") == 2, "nó conhece o bloco")
	_verificar(mapa.obter_no("elite_docas").get("destinos") == mapa.nos_no_ponto(7), "nó informa conexões")
	_verificar(mapa.todos_os_caminhos_chegam_ao_chefe(), "nenhum ramo termina antes do Boss")
	if falhas == 0:
		print("OK: modelo do mapa das Docas")
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
