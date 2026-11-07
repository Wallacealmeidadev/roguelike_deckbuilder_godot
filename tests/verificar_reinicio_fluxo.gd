extends SceneTree


func _initialize() -> void:
	call_deferred("_verificar")


func _verificar() -> void:
	var jogo: Control = (load("res://jogo.tscn") as PackedScene).instantiate() as Control
	root.add_child(jogo)
	current_scene = jogo
	await process_frame
	(jogo.find_child("NovaRunButton", true, false) as Button).pressed.emit()
	await create_timer(0.4).timeout
	(jogo.find_child("ConfirmarButton", true, false) as Button).pressed.emit()
	await create_timer(0.4).timeout
	var run: Node = jogo.find_child("Main", true, false)
	if run == null:
		push_error("Run nao iniciou antes do reinicio")
		quit(1)
		return
	run.call("_ao_reiniciar")
	await process_frame
	await process_frame
	var nova_raiz: Control = current_scene as Control
	if nova_raiz == null or nova_raiz.name != "Jogo" or str(nova_raiz.get("estado_atual")) != "MENU" or nova_raiz.find_child("Main", true, false) != null:
		push_error("Reiniciar deve recarregar jogo.tscn no MENU, sem run")
		quit(1)
		return
	print("REINICIO FLUXO: menu restaurado sem run")
	quit(0)
