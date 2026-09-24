extends Node

var falhas: int = 0


func _ready() -> void:
	var ids: Array[String] = DadosEncontros.identificadores()
	_verificar(ids.size() == 10, "o catálogo deve conter dez encontros")
	_verificar(
		DadosEncontros.identificadores_por_tipo("combate").size() == 4,
		"quatro combates comuns"
	)
	_verificar(
		DadosEncontros.identificadores_por_tipo("elite").size() == 1,
		"um elite"
	)
	_verificar(
		DadosEncontros.identificadores_por_tipo("evento").size() == 5,
		"cinco eventos"
	)
	_verificar(
		DadosEncontros.obter("unidade_contencao_portuaria")["tipo"] == "elite",
		"a Unidade deve ser elite"
	)
	_verificar(
		not str(DadosEncontros.obter("drone_seguranca")["descricao"]).is_empty(),
		"combate comum deve ter descrição"
	)
	_verificar(
		DadosEncontros.obter("valvula_vapor_contaminado")["evento_id"] == "valvula_vapor_contaminado",
		"a válvula deve apontar para seu evento"
	)

	var copia: Dictionary = DadosEncontros.obter("valvula_vapor_contaminado")
	copia["nome"] = "Alterado no teste"
	var original: Dictionary = DadosEncontros.obter("valvula_vapor_contaminado")
	_verificar(
		original["nome"] != copia["nome"],
		"obter deve devolver uma cópia independente"
	)
	_verificar(DadosEncontros.obter("ausente").is_empty(), "id ausente deve retornar vazio")

	if falhas == 0:
		print("OK: catálogo de encontros")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
