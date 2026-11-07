extends Node

var falhas: int = 0


func _ready() -> void:
	_verificar(
		DadosReliquias.RELIQUIAS.size() == 4,
		"o catálogo deve conter a relíquia provisória do evento"
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
		DadosReliquias.identificadores_sem(["juntas_retorno"]).size() == 3,
		"o filtro deve excluir relíquias já equipadas"
	)
	_verificar(
		DadosReliquias.obter("ausente").is_empty(),
		"relíquia ausente deve retornar vazio"
	)
	_verificar(
		not DadosReliquias.obter("reliquia_evento_agua_morta_provisorio").is_empty(),
		"hook da relíquia de Água Morta deve existir"
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
