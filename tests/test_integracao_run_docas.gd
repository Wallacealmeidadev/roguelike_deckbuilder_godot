extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var jogo: Node = (load("res://main.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	var estado: RunState = jogo.get("run_state") as RunState
	_verificar(estado != null, "tela principal deve ter RunState")
	if estado != null:
		_verificar(estado.mapa.total_pontos() == 11, "run principal deve usar novo mapa")
		var inicio: String = estado.mapa.nos_no_ponto(1)[0]
		jogo.call("_ao_selecionar_no_mapa", inicio)
		_verificar(estado.no_em_andamento == inicio, "entrar no nó deve atualizar RunState")
		jogo.call("_abrir_mapa")
		_verificar(estado.no_em_andamento == inicio, "reabrir mapa não perde encontro")
		jogo.set("vida_jogador", 31)
		jogo.set("vida_inimigo", 0)
		jogo.call("_resolver_vitoria")
		_verificar(not estado.concluidos.has(inicio), "vitória antes da recompensa não conclui nó")
		jogo.call("_ao_pular_recompensa")
		_verificar(estado.concluidos.has(inicio), "pular recompensa conclui nó")
		_verificar(estado.vida_atual == 31, "Vida remanescente persiste no mapa")
		_verificar(estado.destinos_disponiveis() == estado.mapa.destinos_de(inicio), "só conexão seguinte fica acessível")
	jogo.queue_free()
	if falhas == 0:
		print("OK: integração inicial da run")
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
