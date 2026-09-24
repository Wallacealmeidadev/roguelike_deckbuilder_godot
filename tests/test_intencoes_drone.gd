extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	var combate: Node = cena_principal.instantiate()
	get_tree().root.add_child(combate)

	await get_tree().process_frame

	var drone: InimigoCombate = InimigoCombate.new(
		"drone_seguranca",
		DadosInimigos.obter("drone_seguranca")
	)
	(combate.get("encontro_combate") as EncontroCombate).inimigo = drone
	combate.call("_atualizar_interface")

	_verificar(
		combate.has_method("_executar_intencao_inimigo"),
		"o inimigo precisa executar a intenção anunciada"
	)
	_verificar(
		combate.has_method("_causar_dano_no_inimigo"),
		"o dano ao Drone precisa passar pela Barreira inimiga"
	)
	var alvo: Button = combate.get_node("Alvo") as Button
	var intencao_label: Label = combate.get_node("IntencaoLabel") as Label
	_verificar(
		intencao_label.text.contains("Rajada: 3 × 2"),
		"a primeira intenção precisa mostrar Rajada: 3 × 2"
	)

	if falhas == 0:
		combate.call("_executar_intencao_inimigo")
		_verificar(combate.get("vida_jogador") == 34, "Rajada deve causar dois golpes de 3")
		_verificar(combate.get("estado_inimigo").indice_intencao == 1, "Rajada deve avançar para Blindagem")
		combate.call("_atualizar_interface")
		_verificar(intencao_label.text.contains("Blindagem de emergência: +6"), "Blindagem precisa ser anunciada")

		combate.call("_executar_intencao_inimigo")
		_verificar(combate.get("vida_jogador") == 34, "Blindagem não deve causar dano")
		_verificar(combate.get("barreira_inimigo") == 6, "Blindagem deve conceder 6 de Barreira")
		_verificar(combate.get("estado_inimigo").indice_intencao == 2, "Blindagem deve avançar para Rajada")
		combate.call("_atualizar_interface")
		_verificar(alvo.text.contains("Barreira: 6"), "a Barreira do Drone precisa ficar visível")

		combate.call("_causar_dano_no_inimigo", 6)
		_verificar(combate.get("barreira_inimigo") == 0, "Golpe deve remover os 6 de Barreira")
		_verificar(combate.get("vida_inimigo") == 30, "Barreira deve impedir dano à Vida do Drone")

		combate.call("_executar_intencao_inimigo")
		_verificar(combate.get("vida_jogador") == 28, "a Rajada seguinte deve causar 6 de dano")
		_verificar(combate.get("estado_inimigo").indice_intencao == 3, "a segunda Rajada deve avançar para Sobrecarga")
		combate.call("_atualizar_interface")
		_verificar(intencao_label.text.contains("Sobrecarga: +2 por golpe"), "Sobrecarga precisa ser anunciada")

		combate.call("_executar_intencao_inimigo")
		_verificar(combate.get("estado_inimigo").bonus_preparado == 2, "Sobrecarga deve preparar bônus 2")
		_verificar(combate.get("estado_inimigo").indice_intencao == 4, "Sobrecarga deve avançar para Rajada")
		combate.call("_atualizar_interface")
		_verificar(intencao_label.text.contains("Rajada: 5 × 2"), "Rajada deve mostrar o bônus de Sobrecarga")

		combate.call("_executar_intencao_inimigo")
		_verificar(combate.get("vida_jogador") == 18, "Sobrecarga deve acrescentar 2 a cada golpe")
		_verificar(combate.get("estado_inimigo").bonus_preparado == 0, "Sobrecarga deve ser consumida após a Rajada")
		_verificar(combate.get("estado_inimigo").indice_intencao == 5, "a Rajada fortalecida deve avançar para Marca")
		combate.call("_atualizar_interface")
		_verificar(intencao_label.text.contains("Marcar: +1 por golpe"), "Marca precisa ser anunciada")

		combate.call("_executar_intencao_inimigo")
		_verificar(combate.get("estado_inimigo").bonus_preparado == 1, "Marca deve preparar bônus 1")
		_verificar(combate.get("estado_inimigo").indice_intencao == 0, "Marca deve voltar para Rajada")
		combate.call("_atualizar_interface")
		_verificar(intencao_label.text.contains("Rajada: 4 × 2"), "Rajada deve mostrar o bônus de Marca")

		combate.call("_executar_intencao_inimigo")
		_verificar(combate.get("vida_jogador") == 10, "Marca deve acrescentar 1 a cada golpe")
		_verificar(combate.get("estado_inimigo").bonus_preparado == 0, "Marca deve ser consumida após a Rajada")
		_verificar(combate.get("estado_inimigo").indice_intencao == 1, "o ciclo deve voltar à Blindagem")

	combate.queue_free()

	if falhas == 0:
		print("OK: ciclo Rajada e Blindagem")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
