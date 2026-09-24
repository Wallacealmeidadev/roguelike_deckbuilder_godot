extends Node

var falhas: int = 0


func _ready() -> void:
	var inimigo: InimigoCombate = InimigoCombate.new(
		"drone_seguranca",
		DadosInimigos.obter("drone_seguranca")
	)
	_verificar(inimigo.nome == "Drone de Segurança", "o nome deve vir da configuração")
	_verificar(inimigo.texto_intencao().contains("Rajada: 3 × 2"), "a intenção inicial deve ser anunciada")

	var acao: Dictionary = inimigo.executar_intencao()
	_verificar(acao["tipo"] == "ataque", "Rajada deve ser um ataque genérico")
	_verificar(acao["danos"] == [3, 3], "Rajada deve conter dois golpes")
	_verificar(inimigo.texto_intencao().contains("Blindagem"), "Rajada deve anunciar Blindagem")

	acao = inimigo.executar_intencao()
	_verificar(acao["tipo"] == "defesa", "Blindagem deve ser uma defesa genérica")
	_verificar(acao["valor"] == 6 and inimigo.barreira == 6, "Blindagem deve conceder 6")
	_verificar(inimigo.texto_intencao().contains("Rajada: 3 × 2"), "Blindagem deve anunciar Rajada")

	acao = inimigo.executar_intencao()
	_verificar(acao["danos"] == [3, 3], "a Rajada após Blindagem deve manter o dano base")
	_verificar(inimigo.texto_intencao().contains("Sobrecarga"), "a segunda Rajada deve anunciar Sobrecarga")

	acao = inimigo.executar_intencao()
	_verificar(acao["tipo"] == "preparacao" and acao["valor"] == 2, "Sobrecarga deve preparar 2")
	_verificar(inimigo.texto_intencao().contains("Rajada: 5 × 2"), "o anúncio deve incluir Sobrecarga")

	acao = inimigo.executar_intencao()
	_verificar(acao["danos"] == [5, 5], "Sobrecarga deve fortalecer os dois golpes")
	_verificar(inimigo.bonus_preparado == 0, "o bônus deve ser consumido pelo ataque")
	_verificar(inimigo.texto_intencao().contains("Marcar"), "o ataque fortalecido deve anunciar Marca")

	acao = inimigo.executar_intencao()
	_verificar(acao["tipo"] == "preparacao" and acao["valor"] == 1, "Marca deve preparar 1")
	_verificar(inimigo.texto_intencao().contains("Rajada: 4 × 2"), "o anúncio deve incluir Marca")

	acao = inimigo.executar_intencao()
	_verificar(acao["danos"] == [4, 4], "Marca deve fortalecer os dois golpes")
	_verificar(inimigo.texto_intencao().contains("Blindagem"), "o ciclo deve voltar à Blindagem")

	var preparado: InimigoCombate = InimigoCombate.new(
		"torreta_contencao",
		DadosInimigos.obter("torreta_contencao")
	)
	preparado.executar_intencao()
	preparado.executar_intencao()
	preparado.executar_intencao()
	preparado.enfraquecido = 2
	_verificar(
		preparado.texto_intencao().contains("Supressão: 1 + 1 + 3"),
		"o anúncio deve considerar Enfraquecido por golpe"
	)
	acao = preparado.executar_intencao()
	_verificar(acao["danos"] == [1, 1, 3], "a execução deve consumir Enfraquecido por golpe")
	_verificar(preparado.enfraquecido == 0, "as duas cargas devem ser consumidas")
	_verificar(preparado.bonus_preparado == 0, "o bônus deve terminar após o ataque completo")

	var elite: InimigoCombate = InimigoCombate.new(
		"unidade_contencao_portuaria",
		DadosInimigos.obter("unidade_contencao_portuaria")
	)
	acao = elite.executar_intencao()
	_verificar(acao["tipo"] == "preparacao", "o elite deve preparar primeiro")
	_verificar(
		elite.texto_intencao().contains("7 × 2"),
		"a Rajada do elite deve anunciar 7 por golpe"
	)
	acao = elite.executar_intencao()
	_verificar(acao["danos"] == [7, 7], "o bônus deve ser aplicado aos dois golpes")
	_verificar(elite.bonus_preparado == 0, "o bônus deve ser consumido após a Rajada")

	var dados_invalidos: Dictionary = {
		"nome": "Inválido",
		"vida": 10,
		"intencoes": [{"nome": "Erro", "tipo": "desconhecida"}]
	}
	var invalido: InimigoCombate = InimigoCombate.new("invalido", dados_invalidos)
	invalido.barreira = 5
	invalido.bonus_preparado = 3
	_verificar(invalido.executar_intencao().is_empty(), "intenção desconhecida deve retornar vazio")
	_verificar(invalido.indice_intencao == 0, "intenção inválida não deve avançar")
	_verificar(
		invalido.barreira == 5 and invalido.bonus_preparado == 3,
		"intenção inválida não deve mudar estado"
	)

	if falhas == 0:
		print("OK: InimigoCombate genérico")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
