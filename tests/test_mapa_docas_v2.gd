extends Node

var falhas: int = 0


func _ready() -> void:
	var mapa: MapaRun = MapaRun.new()
	mapa.gerar(42)
	var caminhos: Array[Array] = []
	_percorrer(mapa, mapa.nos_no_ponto(1)[0], [], caminhos)
	_verificar(mapa.total_pontos() == 11, "uma rota deve ter onze pontos")
	_verificar(caminhos.size() == 2, "o template deve ter duas rotas curtas")
	for caminho in caminhos:
		_verificar(caminho.size() == 11, "cada rota deve percorrer onze nós")
		var tipos: Array[String] = []
		for id_no in caminho:
			tipos.append(str(mapa.obter_no(str(id_no)).get("tipo", "")))
		_verificar(tipos.count(MapaRun.TIPO_COMBATE) == 4, "cada rota deve ter quatro combates comuns")
		_verificar(tipos.count(MapaRun.TIPO_EVENTO) == 3, "cada rota deve ter três eventos")
		_verificar(tipos.count(MapaRun.TIPO_DESCANSO) == 2, "cada rota deve ter dois descansos")
		_verificar(tipos.count(MapaRun.TIPO_CHEFE) == 1, "cada rota deve chegar ao Boss")
		_verificar(tipos.count(MapaRun.TIPO_ELITE) + tipos.count("desmanche") == 1, "o ramo deve ser Elite ou Desmanche")
		for indice in range(tipos.size() - 1):
			_verificar(not (tipos[indice] == MapaRun.TIPO_DESCANSO and tipos[indice + 1] == MapaRun.TIPO_DESCANSO), "descansos não devem ser consecutivos")
	_verificar(mapa.todos_os_caminhos_chegam_ao_chefe(), "todos os ramos devem chegar ao Boss")
	var repetido: MapaRun = MapaRun.new()
	repetido.gerar(42)
	var outro: MapaRun = MapaRun.new()
	outro.gerar(43)
	var mudou: bool = false
	var eventos: Array[String] = []
	for id_no in mapa.nos.keys():
		var dados: Dictionary = mapa.obter_no(str(id_no))
		_verificar(dados == repetido.obter_no(str(id_no)), "mesma seed deve repetir estrutura e conteúdo")
		if dados.get("id_conteudo") != outro.obter_no(str(id_no)).get("id_conteudo"):
			mudou = true
		if dados.get("tipo") == MapaRun.TIPO_EVENTO:
			var id_evento: String = str(dados.get("id_conteudo", ""))
			_verificar(not eventos.has(id_evento), "evento não deve repetir na run")
			eventos.append(id_evento)
			_verificar(not str(dados.get("familia", "")).is_empty(), "evento deve ter família")
	_verificar(mudou, "seeds diferentes devem variar conteúdo")
	var encontrou_repeticao_de_familia: bool = false
	for seed_teste in range(100):
		var candidato: MapaRun = MapaRun.new()
		candidato.gerar(seed_teste)
		var familias: Array[String] = []
		for evento_no in ["evento_cais", "evento_meio", "evento_final"]:
			familias.append(str(candidato.obter_no(evento_no).get("familia", "")))
		if familias[0] == familias[1] or familias[1] == familias[2] or familias[0] == familias[2]:
			encontrou_repeticao_de_familia = true
			break
	_verificar(encontrou_repeticao_de_familia, "famílias podem se repetir quando os eventos não são consecutivos")
	var rng_esperado: RandomNumberGenerator = RandomNumberGenerator.new()
	for seed_teste in range(20):
		rng_esperado.seed = seed_teste
		var encontros_esperados: Array[String] = []
		for indice in range(4):
			var pool: Array[String] = DadosEncontrosDocas.EARLY_POOL
			if indice == 2:
				pool = DadosEncontrosDocas.MID_POOL
			elif indice == 3:
				pool = DadosEncontrosDocas.LATE_POOL
			var disponiveis: Array[String] = []
			for id_encontro in pool:
				if not encontros_esperados.has(id_encontro):
					disponiveis.append(id_encontro)
			disponiveis.sort()
			encontros_esperados.append(disponiveis[rng_esperado.randi_range(0, disponiveis.size() - 1)])
		var eventos_esperados: Array[String] = []
		for id_evento in DadosEventos.EVENTOS.keys():
			eventos_esperados.append(str(id_evento))
		eventos_esperados.sort()
		mapa._embaralhar(eventos_esperados, rng_esperado)
		var candidato_ordenado: MapaRun = MapaRun.new()
		candidato_ordenado.gerar(seed_teste)
		for indice in range(3):
			var no_evento: String = ["evento_cais", "evento_meio", "evento_final"][indice]
			_verificar(str(candidato_ordenado.obter_no(no_evento).get("id_conteudo", "")) == eventos_esperados[indice], "família não deve filtrar eventos separados por outros nós")
	if falhas == 0:
		print("OK: estrutura das Docas v2")
	get_tree().quit(0 if falhas == 0 else 1)


func _percorrer(mapa: MapaRun, atual: String, prefixo: Array[String], caminhos: Array[Array]) -> void:
	var caminho: Array[String] = prefixo.duplicate()
	caminho.append(atual)
	var destinos: Array[String] = mapa.destinos_de(atual)
	if destinos.is_empty():
		caminhos.append(caminho)
		return
	for destino in destinos:
		_percorrer(mapa, destino, caminho, caminhos)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
