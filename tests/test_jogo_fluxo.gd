extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	_verificar(str(ProjectSettings.get_setting("application/run/main_scene")) == "res://jogo.tscn", "projeto deve abrir jogo.tscn")
	var cena: PackedScene = load("res://jogo.tscn") as PackedScene
	_verificar(cena != null, "cena raiz deve existir")
	if cena == null:
		_terminar()
		return
	var jogo: Control = cena.instantiate() as Control
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	_verificar(str(jogo.get("estado_atual")) == "MENU", "entrada deve ser MENU")
	_verificar(jogo.find_child("MenuPrincipal", true, false) != null, "menu deve aparecer")
	_verificar(jogo.find_child("Main", true, false) == null, "run nao pode existir no menu")
	var menu: Control = jogo.find_child("MenuPrincipal", true, false) as Control
	if menu == null:
		jogo.queue_free()
		_terminar()
		return
	(menu.find_child("NovaRunButton", true, false) as Button).pressed.emit()
	await get_tree().create_timer(0.4).timeout
	_verificar(str(jogo.get("estado_atual")) == "SELECAO", "NOVA RUN deve abrir selecao")
	var selecao: Control = jogo.find_child("SelecaoPersonagem", true, false) as Control
	_verificar(selecao != null, "selecao deve aparecer")
	_verificar(jogo.find_child("Main", true, false) == null, "run nao pode existir na selecao")
	if selecao == null:
		jogo.queue_free()
		_terminar()
		return
	(selecao.find_child("VoltarButton", true, false) as Button).pressed.emit()
	await get_tree().create_timer(0.4).timeout
	_verificar(str(jogo.get("estado_atual")) == "MENU", "VOLTAR deve retornar ao menu")
	_verificar(jogo.find_child("Main", true, false) == null, "VOLTAR nao deve criar run")
	menu = jogo.find_child("MenuPrincipal", true, false) as Control
	(menu.find_child("NovaRunButton", true, false) as Button).pressed.emit()
	await get_tree().create_timer(0.4).timeout
	selecao = jogo.find_child("SelecaoPersonagem", true, false) as Control
	jogo.call("_ao_personagem_confirmada", "invalido")
	_verificar(str(jogo.get("estado_atual")) == "SELECAO", "id invalido deve ser recusado")
	_verificar(jogo.find_child("Main", true, false) == null, "id invalido nao deve criar run")
	(selecao.find_child("ConfirmarButton", true, false) as Button).pressed.emit()
	jogo.call("_ao_personagem_confirmada", "vega")
	await get_tree().create_timer(0.4).timeout
	_verificar(str(jogo.get("estado_atual")) == "RUN", "confirmar Vega deve iniciar run")
	var run: Node = jogo.find_child("Main", true, false)
	_verificar(run != null, "run deve ser instanciada")
	if run != null:
		_verificar((run.get_node("MapaOverlay") as Control).visible, "mapa existente deve aparecer")
		var foco_mapa: Control = get_viewport().gui_get_focus_owner()
		_verificar(foco_mapa != null and run.is_ancestor_of(foco_mapa) and foco_mapa is Button, "primeiro ponto do mapa deve receber foco")
	var total_runs: int = 0
	for filho: Node in jogo.get_node("TelaAtual").get_children():
		if filho.name == "Main":
			total_runs += 1
	_verificar(total_runs == 1, "cliques repetidos nao podem duplicar run")
	jogo.queue_free()
	_terminar()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)


func _terminar() -> void:
	print("FLUXO INICIAL: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)
