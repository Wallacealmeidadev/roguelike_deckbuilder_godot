extends Control

signal personagem_confirmada(id_personagem: String)
signal voltar_solicitado

var vega_selecionada: bool = true

@onready var _painel: Control = %PainelSelecao
@onready var _confirmar: Button = %ConfirmarButton
@onready var _voltar: Button = %VoltarButton


func _ready() -> void:
	_confirmar.pressed.connect(func() -> void: personagem_confirmada.emit("vega"))
	_voltar.pressed.connect(func() -> void: voltar_solicitado.emit())
	_confirmar.focus_neighbor_left = _confirmar.get_path_to(_voltar)
	_voltar.focus_neighbor_right = _voltar.get_path_to(_confirmar)
	_confirmar.focus_next = _confirmar.get_path_to(_voltar)
	_voltar.focus_previous = _voltar.get_path_to(_confirmar)
	redimensionar()
	get_viewport().size_changed.connect(redimensionar)
	call_deferred("focar_acao_principal")


func redimensionar() -> void:
	var viewport: Vector2 = get_viewport_rect().size
	_painel.custom_minimum_size = Vector2(clampf(viewport.x * 0.89, 940.0, 1460.0), clampf(viewport.y * 0.85, 480.0, 820.0))


func focar_acao_principal() -> void:
	if is_inside_tree():
		_confirmar.grab_focus()
