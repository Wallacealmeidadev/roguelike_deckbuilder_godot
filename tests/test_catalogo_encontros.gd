extends Node

var falhas: int = 0


func _ready() -> void:
	var ids: Array[String] = DadosEncontros.identificadores()
	_verificar(ids.size() == 13, "o catálogo deve conter treze encontros")
	_verificar(
		DadosEncontros.identificadores_por_tipo("combate").size() == 4,
		"quatro combates comuns"
	)
	_verificar(
		DadosEncontros.identificadores_por_tipo("elite").size() == 1,
		"um elite"
	)
	_verificar(
		DadosEncontros.identificadores_por_tipo("evento").size() == 8,
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
	DadosEncontros.obter("ponto_da_queda")["evento_id"] == "ponto_da_queda",
		"a válvula deve apontar para seu evento"
	)

	var copia: Dictionary = DadosEncontros.obter("ponto_da_queda")
	copia["nome"] = "Alterado no teste"
	var original: Dictionary = DadosEncontros.obter("ponto_da_queda")
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
