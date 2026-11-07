extends Control

signal nova_run_solicitada
signal sair_solicitado

@onready var _painel: Control = %PainelPrincipal
@onready var _nova_run: Button = %NovaRunButton
@onready var _sair: Button = %SairButton


func _ready() -> void:
	_nova_run.pressed.connect(func() -> void: nova_run_solicitada.emit())
	_sair.pressed.connect(func() -> void: sair_solicitado.emit())
	_nova_run.focus_neighbor_bottom = _nova_run.get_path_to(_sair)
	_sair.focus_neighbor_top = _sair.get_path_to(_nova_run)
	_nova_run.focus_next = _nova_run.get_path_to(_sair)
	_sair.focus_previous = _sair.get_path_to(_nova_run)
	redimensionar()
	get_viewport().size_changed.connect(redimensionar)
	call_deferred("focar_acao_principal")


func redimensionar() -> void:
	var viewport: Vector2 = get_viewport_rect().size
	_painel.custom_minimum_size = Vector2(clampf(viewport.x * 0.83, 880.0, 1360.0), clampf(viewport.y * 0.79, 460.0, 760.0))


func focar_acao_principal() -> void:
	if is_inside_tree():
		_nova_run.grab_focus()
