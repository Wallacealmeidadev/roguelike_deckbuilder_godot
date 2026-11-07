extends Node

var falhas: int = 0

func _ready() -> void:
	call_deferred("verificar")

func conferir(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error(mensagem)

func verificar() -> void:
	var recurso: PackedScene = load("res://prototipos/vega_2d/vega_animada_segmentada.tscn") as PackedScene
	conferir(recurso != null, "Cena segmentada nao carregou no contrato de compatibilidade")
	if recurso == null:
		get_tree().quit(1)
		return
	var vega: Control = recurso.instantiate() as Control
	get_tree().root.add_child(vega)
	get_tree().root.size = Vector2i(1024, 576)
	vega.size = Vector2(260.0, 420.0)
	await get_tree().process_frame
	conferir(vega.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Candidata intercepta input do alvo")
	conferir(vega.get_node_or_null("AnimationPlayer") != null, "Contrato nao possui AnimationPlayer")
	vega.reiniciar()
	vega.socar()
	conferir(vega.estado_animacao == "soco", "Contrato nao aceita socar()")
	await get_tree().create_timer(0.12).timeout
	vega.receber_dano()
	conferir(vega.estado_animacao == "dano", "Contrato nao aceita interrupcao por dano")
	await get_tree().create_timer(0.55).timeout
	conferir(vega.estado_animacao == "repouso", "Contrato nao retorna a repouso")
	vega.hide()
	await get_tree().process_frame
	conferir(not vega.is_processing(), "Candidata continua processando quando esta oculta")
	vega.show()
	vega.reiniciar()
	await get_tree().process_frame
	conferir(vega.estado_animacao == "repouso", "Candidata nao reinicia ao voltar ao campo")
	vega.queue_free()
	await get_tree().process_frame
	print("VEGA COMPATIBILIDADE: %d falhas" % falhas)
	get_tree().quit(1 if falhas else 0)
