extends Node

var falhas: int = 0


func _ready() -> void:
	var script_estado: Script = load("res://run_state.gd") as Script
	_verificar(script_estado != null, "RunState deve existir")
	if script_estado == null:
		get_tree().quit(1)
		return
	var estado: RefCounted = script_estado.new()
	var deck: Array[String] = ["golpe", "golpe#aprimorado"]
	var reliquias: Array[String] = ["juntas_retorno"]
	estado.call("iniciar", 42, 40, deck, reliquias)
	_verificar(int(estado.get("vida_atual")) == 40, "Vida inicia cheia")
	_verificar((estado.get("deck") as Array[String]) == deck, "tokens melhorados persistem")
	var mapa: MapaRun = estado.get("mapa") as MapaRun
	var inicio: String = mapa.nos_no_ponto(1)[0]
	_verificar(not bool(estado.call("iniciar_no", "elite_docas")), "não pode saltar para nó desconectado")
	_verificar(bool(estado.call("iniciar_no", inicio)), "primeiro nó pode iniciar")
	_verificar(not bool(estado.call("iniciar_no", inicio)), "não pode iniciar um segundo nó enquanto há um em andamento")
	_verificar(bool(estado.call("concluir_no")), "nó em andamento pode concluir")
	_verificar((estado.get("concluidos") as Array[String]).has(inicio), "conclusão deve persistir")
	_verificar(not bool(estado.call("iniciar_no", inicio)), "nó concluído não pode ser repetido")
	estado.call("registrar_vida", 27)
	estado.call("adicionar_flag", "viu_relatorios_ataques")
	_verificar(int(estado.get("vida_atual")) == 27, "Vida remanescente deve persistir")
	_verificar(bool(estado.call("possui_flag", "viu_relatorios_ataques")), "flag deve persistir")
	deck.append("protecao")
	_verificar((estado.get("deck") as Array[String]).size() == 2, "estado deve copiar deck de entrada")
	if falhas == 0:
		print("OK: estado persistente da run")
	get_tree().quit(0 if falhas == 0 else 1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
