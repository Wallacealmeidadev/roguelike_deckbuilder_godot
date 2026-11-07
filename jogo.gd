extends Control

const CENA_MENU: PackedScene = preload("res://ui_entrada/menu_principal.tscn")
const CENA_SELECAO: PackedScene = preload("res://ui_entrada/selecao_personagem.tscn")
const CENA_RUN: PackedScene = preload("res://main.tscn")
const DURACAO_TRANSICAO: float = 0.16

var estado_atual: String = "MENU"
var em_transicao: bool = false

@onready var _tela_atual: Control = $TelaAtual


func _ready() -> void:
	var menu: Control = _instanciar_tela("MENU")
	_tela_atual.add_child(menu)


func _ao_nova_run_solicitada() -> void:
	if estado_atual != "MENU" or em_transicao:
		return
	_transicionar_para("SELECAO")


func _ao_voltar_solicitado() -> void:
	if estado_atual != "SELECAO" or em_transicao:
		return
	_transicionar_para("MENU")


func _ao_personagem_confirmada(id_personagem: String) -> void:
	if estado_atual != "SELECAO" or em_transicao:
		return
	if id_personagem != "vega":
		push_warning("Personagem indisponível: %s" % id_personagem)
		return
	_transicionar_para("RUN")


func _ao_sair_solicitado() -> void:
	if estado_atual == "MENU" and not em_transicao:
		get_tree().quit()


func _transicionar_para(proximo_estado: String) -> void:
	em_transicao = true
	var tela_anterior: Control = _tela_atual.get_child(0) as Control
	var saida: Tween = create_tween()
	saida.tween_property(tela_anterior, "modulate:a", 0.0, DURACAO_TRANSICAO)
	await saida.finished
	if not is_inside_tree():
		return
	_tela_atual.remove_child(tela_anterior)
	tela_anterior.queue_free()
	var nova_tela: Control = _instanciar_tela(proximo_estado)
	nova_tela.modulate.a = 0.0
	_tela_atual.add_child(nova_tela)
	estado_atual = proximo_estado
	if proximo_estado == "RUN":
		call_deferred("_focar_primeiro_ponto_do_mapa", nova_tela)
	var entrada: Tween = create_tween()
	entrada.tween_property(nova_tela, "modulate:a", 1.0, DURACAO_TRANSICAO)
	await entrada.finished
	if is_inside_tree():
		em_transicao = false


func _instanciar_tela(estado: String) -> Control:
	var cena: PackedScene = CENA_MENU
	if estado == "SELECAO":
		cena = CENA_SELECAO
	elif estado == "RUN":
		cena = CENA_RUN
	var tela: Control = cena.instantiate() as Control
	if estado == "MENU":
		tela.connect("nova_run_solicitada", _ao_nova_run_solicitada)
		tela.connect("sair_solicitado", _ao_sair_solicitado)
	elif estado == "SELECAO":
		tela.connect("personagem_confirmada", _ao_personagem_confirmada)
		tela.connect("voltar_solicitado", _ao_voltar_solicitado)
	return tela


func _focar_primeiro_ponto_do_mapa(run: Control) -> void:
	if not is_instance_valid(run) or not run.is_inside_tree():
		return
	var pontos: Node = run.get_node_or_null("MapaOverlay/MapaGrafo/MapaPontos")
	if pontos == null:
		return
	for filho: Node in pontos.get_children():
		var botao: Button = filho as Button
		if botao != null and botao.visible and not botao.disabled:
			botao.grab_focus()
			return
