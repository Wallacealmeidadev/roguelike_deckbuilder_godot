extends Node

var falhas: int = 0


func _ready() -> void:
	var ids: Array[String] = DadosInimigos.identificadores()
	_verificar(ids.size() == 4, "o catálogo deve conter quatro inimigos")
	_verificar(ids.has("drone_seguranca"), "o Drone deve permanecer no catálogo")
	_verificar(ids.has("estivador_cibernetico"), "o Estivador deve estar no catálogo")
	_verificar(ids.has("torreta_contencao"), "a Torreta deve estar no catálogo")
	_verificar(ids.has("guarda_portuario"), "o Guarda deve estar no catálogo")

	var drone: Dictionary = DadosInimigos.obter("drone_seguranca")
	_verificar(drone["nome"] == "Drone de Segurança", "o Drone deve ter o nome aprovado")
	_verificar(drone["vida"] == 30, "o Drone deve manter 30 de Vida")
	_verificar(drone["intencoes"].size() == 6, "o Drone deve armazenar seis passos")

	var estivador: Dictionary = DadosInimigos.obter("estivador_cibernetico")
	_verificar(estivador["vida"] == 36, "o Estivador deve ter 36 de Vida")
	_verificar(estivador["intencoes"][2]["bonus_por_golpe"] == 4, "Preparar deve conceder 4")

	var torreta: Dictionary = DadosInimigos.obter("torreta_contencao")
	_verificar(torreta["vida"] == 24, "a Torreta deve ter 24 de Vida")
	_verificar(torreta["intencoes"][0]["danos"] == [2, 2, 2], "Supressão deve ter três golpes")

	var guarda: Dictionary = DadosInimigos.obter("guarda_portuario")
	_verificar(guarda["vida"] == 32, "o Guarda deve ter 32 de Vida")
	_verificar(guarda["intencoes"][1]["valor"] == 9, "Escudo deve conceder 9")

	var elites: Array[String] = DadosInimigos.identificadores_elite()
	_verificar(elites == ["unidade_contencao_portuaria"], "deve existir um elite")

	var elite: Dictionary = DadosInimigos.obter("unidade_contencao_portuaria")
	_verificar(
		elite["nome"] == "Unidade de Contenção Portuária",
		"o elite deve ter nome próprio"
	)
	_verificar(elite["vida"] == 44, "o elite deve começar com 44 de Vida")
	_verificar(elite["intencoes"].size() == 4, "o elite deve ter quatro intenções")
	_verificar(
		elite["intencoes"][0]["tipo"] == "preparacao",
		"o ciclo deve começar preparando"
	)
	_verificar(
		elite["intencoes"][1]["danos"] == [5, 5],
		"a Rajada deve ter dois danos-base de 5"
	)
	_verificar(
		elite["intencoes"][2]["valor"] == 8,
		"a Blindagem pesada deve conceder 8"
	)
	_verificar(
		elite["intencoes"][3]["danos"] == [8],
		"o Golpe de pistão deve causar 8"
	)
	_verificar(
		DadosInimigos.identificadores().size() == 4,
		"o identificador de elite não deve entrar no pool comum"
	)

	drone["vida"] = 999
	_verificar(DadosInimigos.obter("drone_seguranca")["vida"] == 30, "obter deve devolver cópia profunda")
	_verificar(DadosInimigos.obter("ausente").is_empty(), "identificador ausente deve retornar vazio")
	_verificar(not DadosInimigos.dados_validos({}), "configuração vazia deve ser inválida")
	_verificar(
		not DadosInimigos.dados_validos({"nome": "X", "vida": 1, "intencoes": []}),
		"ciclo vazio deve ser inválido"
	)
	_verificar(not DadosInimigos.dados_validos({
		"nome": "X",
		"vida": 1,
		"intencoes": [{"nome": "Erro", "tipo": "ataque", "danos": []}]
	}), "ataque sem golpes deve ser inválido")

	if falhas == 0:
		print("OK: catálogo de inimigos")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
