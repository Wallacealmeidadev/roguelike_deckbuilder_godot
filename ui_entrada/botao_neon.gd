extends Button

const DURACAO: float = 0.16

var _tween_escala: Tween


func _ready() -> void:
	resized.connect(_ajustar_pivot)
	mouse_entered.connect(_atualizar_estado)
	mouse_exited.connect(_atualizar_estado)
	focus_entered.connect(_atualizar_estado)
	focus_exited.connect(_atualizar_estado)
	button_down.connect(_pressionar)
	button_up.connect(_atualizar_estado)
	call_deferred("_ajustar_pivot")


func _ajustar_pivot() -> void:
	pivot_offset = size * 0.5


func _pressionar() -> void:
	_animar_escala(0.98)


func _atualizar_estado() -> void:
	_animar_escala(1.015 if not disabled and (has_focus() or is_hovered()) else 1.0)


func _animar_escala(valor: float) -> void:
	if _tween_escala != null and _tween_escala.is_running():
		_tween_escala.kill()
	_tween_escala = create_tween()
	_tween_escala.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween_escala.tween_property(self, "scale", Vector2(valor, valor), DURACAO)
