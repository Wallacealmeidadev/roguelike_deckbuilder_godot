extends Node

var falhas: int = 0


func _ready() -> void:
	_verificar(
		DadosReliquias.RELIQUIAS.size() == 3,
		"o catálogo deve conter a relíquia inicial e duas recompensas"
	)
	_verificar(
		DadosReliquias.obter("juntas_retorno")["nome"] == "Juntas de Retorno",
		"o catálogo deve conter Juntas de Retorno"
	)
	_verificar(
		DadosReliquias.obter("reservatorio_auxiliar")["nome"] == "Reservatório Auxiliar",
		"o catálogo deve conter Reservatório Auxiliar"
	)
	_verificar(
		DadosReliquias.obter("mecanismo_recuo")["nome"] == "Mecanismo de Recuo",
		"o catálogo deve conter Mecanismo de Recuo"
	)
	_verificar(
		DadosReliquias.identificadores_sem(["juntas_retorno"]).size() == 2,
		"o filtro deve excluir relíquias já equipadas"
	)
	_verificar(
		DadosReliquias.obter("ausente").is_empty(),
		"relíquia ausente deve retornar vazio"
	)

	if falhas == 0:
		print("OK: catálogo de relíquias")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
