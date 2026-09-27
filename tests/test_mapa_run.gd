extends Node

var falhas: int = 0


func _ready() -> void:
	var mapa: MapaRun = MapaRun.new()
	mapa.gerar(0)

	_verificar(mapa.total_pontos() == 7, "o modelo inicial deve ter sete pontos")
	_verificar(mapa.nos_no_ponto(1).size() == 1, "o primeiro ponto deve ter um no")
	_verificar(
		mapa.obter_no(mapa.nos_no_ponto(1)[0])["tipo"] == MapaRun.TIPO_COMBATE,
		"o primeiro ponto deve ser um encontro de combate"
	)
	_verificar(mapa.nos_no_ponto(3).size() == 1, "o terceiro ponto deve ter um no")
	_verificar(
		mapa.obter_no(mapa.nos_no_ponto(3)[0])["tipo"] == MapaRun.TIPO_ELITE,
		"o terceiro ponto deve ser o elite"
	)
	_verificar(mapa.nos_no_ponto(7).size() == 1, "o ultimo ponto deve ter um no")
	_verificar(
		mapa.obter_no(mapa.nos_no_ponto(7)[0])["tipo"] == MapaRun.TIPO_CHEFE,
		"o ultimo ponto deve ser o chefe"
	)

	_verificar(mapa.nos_no_ponto(2).size() == 2, "o segundo ponto deve ramificar")
	_verificar(mapa.nos_no_ponto(4).size() == 2, "o quarto ponto deve ramificar")
	_verificar(mapa.nos_no_ponto(5).size() == 2, "o quinto ponto deve ramificar")
	_verificar(mapa.nos_no_ponto(6).size() == 1, "o sexto ponto deve reencontrar os caminhos")
	_verificar(
		mapa.ponto_do_reencontro() == 6,
		"o reencontro deve acontecer antes do chefe"
	)
	var id_elite: String = mapa.nos_no_ponto(3)[0]
	for id_ponto_2 in mapa.nos_no_ponto(2):
		_verificar(
			mapa.destinos_de(id_ponto_2) == [id_elite],
			"cada ramo inicial deve levar ao elite"
		)
	var id_reencontro: String = mapa.nos_no_ponto(6)[0]
	for id_ponto_5 in mapa.nos_no_ponto(5):
		_verificar(
			mapa.destinos_de(id_ponto_5) == [id_reencontro],
			"cada ramo posterior deve reencontrar o caminho"
		)
	var id_chefe: String = mapa.nos_no_ponto(7)[0]
	_verificar(
		mapa.destinos_de(id_reencontro) == [id_chefe],
		"o reencontro deve levar ao chefe"
	)
	_verificar(
		mapa.todos_os_caminhos_chegam_ao_chefe(),
		"todos os caminhos devem chegar ao chefe"
	)

	var mapa_alternativo: MapaRun = MapaRun.new()
	mapa_alternativo.gerar(1)
	var descansos_a: Array[String] = mapa.nos_de_tipo(MapaRun.TIPO_DESCANSO)
	var descansos_b: Array[String] = mapa_alternativo.nos_de_tipo(MapaRun.TIPO_DESCANSO)
	_verificar(descansos_a.size() == 1, "cada mapa deve ter um descanso")
	_verificar(descansos_b.size() == 1, "a variante deve ter um descanso")
	_verificar(
		mapa.ponto_do_no(descansos_a[0]) != mapa_alternativo.ponto_do_no(descansos_b[0]),
		"as variantes devem permitir descansos em pontos diferentes"
	)

	if falhas == 0:
		print("OK: estrutura do mapa")
		get_tree().quit(0)
	else:
		get_tree().quit(1)
	mapa.gerar(0)
	_imprimir_mapa(mapa)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
		
func _imprimir_mapa(mapa: MapaRun) -> void:
	print("--- MAPA VARIANTE %d ---" % mapa.variante)

	for ponto in range(1, mapa.total_pontos() + 1):
		for id_no in mapa.nos_no_ponto(ponto):
			var dados: Dictionary = mapa.obter_no(id_no)
			print(
				"P%d | %s | %s | destinos: %s" % [
					ponto,
					dados["tipo"],
					dados["nome"],
					str(mapa.destinos_de(id_no))
				]
			)
