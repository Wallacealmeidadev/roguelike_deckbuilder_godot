extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _executar() -> void:
	var cena: PackedScene = load("res://ui_entrada/menu_principal.tscn") as PackedScene
	_verificar(cena != null, "a cena do menu deve existir")
	if cena == null:
		_terminar()
		return
	var menu: Control = cena.instantiate() as Control
	get_tree().root.add_child(menu)
	await get_tree().process_frame
	var nova_run: Button = menu.find_child("NovaRunButton", true, false) as Button
	var sair: Button = menu.find_child("SairButton", true, false) as Button
	_verificar(nova_run != null and sair != null, "menu deve ter NOVA RUN e SAIR")
	if nova_run != null and sair != null:
		_verificar(nova_run.text == "NOVA RUN", "acao principal deve ser NOVA RUN")
		_verificar(sair.text == "SAIR", "acao de sair deve ser real")
		_verificar(nova_run.custom_minimum_size.y >= 44.0 and sair.custom_minimum_size.y >= 44.0, "alvos devem ter pelo menos 44 px")
		_verificar(get_viewport().gui_get_focus_owner() == nova_run, "NOVA RUN deve receber foco inicial")
		var descer: InputEventAction = InputEventAction.new()
		descer.action = "ui_down"
		descer.pressed = true
		get_viewport().push_input(descer)
		await get_tree().process_frame
		_verificar(get_viewport().gui_get_focus_owner() == sair, "seta para baixo deve focar SAIR")
		var subir: InputEventAction = InputEventAction.new()
		subir.action = "ui_up"
		subir.pressed = true
		get_viewport().push_input(subir)
		await get_tree().process_frame
		_verificar(get_viewport().gui_get_focus_owner() == nova_run, "seta para cima deve voltar a NOVA RUN")
		nova_run.button_down.emit()
		await get_tree().create_timer(0.2).timeout
		_verificar(nova_run.scale.x <= 0.99, "pressionar deve contrair o botao brevemente")
		nova_run.button_up.emit()
		await get_tree().create_timer(0.2).timeout
		_verificar(nova_run.scale.x >= 1.0, "soltar deve restaurar a escala do botao")
		var pedidos: Array[int] = [0, 0]
		menu.connect("nova_run_solicitada", func() -> void: pedidos[0] += 1)
		menu.connect("sair_solicitado", func() -> void: pedidos[1] += 1)
		nova_run.pressed.emit()
		sair.pressed.emit()
		_verificar(pedidos == [1, 1], "botoes devem emitir intencoes separadas")
	menu.queue_free()
	_terminar()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)


func _terminar() -> void:
	print("MENU PRINCIPAL: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)
