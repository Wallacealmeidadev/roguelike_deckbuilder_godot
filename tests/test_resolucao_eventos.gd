extends Node

var falhas: int = 0


func _ready() -> void:
	var jogador: JogadorCombate = JogadorCombate.new(40, 4)
	var custo: Dictionary = ResolucaoEventos.resolver("carga_descartada", "romper_lacre", jogador)
	_verificar(custo["valida"], "romper o lacre deve ser válido")
	_verificar(custo["vida_delta"] == -7, "romper o lacre custa 7 de Vida")
	_verificar(custo["concluido"], "custo sobrevivido deve concluir a opção")
	_verificar(jogador.estado.vida == 40, "resolvedor não deve mutar diretamente a Vida")

	var posto: Dictionary = ResolucaoEventos.resolver("posto_inspecao", "passar_forca", jogador)
	_verificar(posto["valida"], "passar à força deve ser válido")
	_verificar(posto["tipo"] == "combate_especial", "posto deve iniciar combate")
	_verificar(posto["id_inimigo"] == "guarda_portuario", "posto deve apontar para o guarda")
	_verificar(not posto["concluido"], "combate especial aguarda sua conclusão")

	var ninho: Dictionary = ResolucaoEventos.resolver("ninho_sob_cais", "destruir_ninho", jogador)
	_verificar(ninho["tipo"] == "combate_especial", "destruir o ninho deve iniciar combate")
	_verificar(ninho["id_inimigo"] == "torreta_contencao", "ninho deve apontar para a torreta")

	var deck: Dictionary = ResolucaoEventos.resolver("turno_encerrado", "desmontar_maquina", jogador)
	_verificar(deck["deck_acao"] == "remover", "evento deve declarar remoção de deck")
	_verificar((deck["flags_concedidas"] as Array).has("ajudou_estivadores"), "evento concede flag dos estivadores")

	var invalida: Dictionary = ResolucaoEventos.resolver("carga_descartada", "ausente", jogador)
	_verificar(not invalida["valida"], "opção inválida deve ser rejeitada")
	_verificar(invalida["tipo"] == "invalida", "resultado inválido deve ser identificado")
	_verificar(jogador.estado.vida == 40, "opção inválida não altera Vida")

	var ausente: Dictionary = ResolucaoEventos.resolver("ausente", "opcao", jogador)
	_verificar(not ausente["valida"], "evento ausente deve ser rejeitado")
	_verificar(ausente["concluido"], "evento ausente deve encerrar sem efeito")

	for chave in ["valida", "tipo", "texto", "vida_delta", "id_inimigo", "concluido", "recompensa", "deck_acao", "filtro_carta"]:
		_verificar(custo.has(chave), "resultado deve conter a chave %s" % chave)

	if falhas == 0:
		print("OK: resolução de eventos")
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
