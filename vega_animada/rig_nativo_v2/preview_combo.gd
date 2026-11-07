extends "res://vega_animada/rig_nativo_v2/preview_dois_bracos.gd"

@onready var controle_combo: HSlider = $Rodape/Combo/Valor


func _ready() -> void:
	super._ready()
	controle_combo.value_changed.connect(_combo)
	for valor: int in [0, 5, 10]:
		($Rodape/Combo.get_node("Carga%d" % valor) as Button).pressed.connect(_combo.bind(float(valor)))
	(braco as ComboNativoV2).tensao_alterada.connect(func(_valor: float) -> void: _atualizar_estado())
	_atualizar_estado()


func _layout() -> void:
	super._layout()
	if not is_instance_valid(braco):
		return
	var fator: float = maxf(.1, minf((size.y - 270) / 860.0, size.x * .43 / 730.0))
	contexto.scale = Vector2.ONE * fator
	contexto.position = Vector2(size.x * .26 - 365 * fator, 112)
	var painel: Control = $ZoomPanel
	painel.size.y = maxf(100, size.y - 310)
	var fator_zoom: float = minf(painel.size.x / 640, painel.size.y / 480)
	zoom.scale = Vector2.ONE * fator_zoom
	zoom.position = Vector2((painel.size.x - 730 * fator_zoom) * .5, 0)


func _combo(valor: float, imediato: bool = false) -> void:
	controle_combo.set_value_no_signal(valor)
	for rig: BracoNativoV2 in [braco, zoom]:
		(rig as ComboNativoV2).definir_combo(int(valor), imediato)
	_atualizar_estado()


func _atualizar_estado() -> void:
	var rig: ComboNativoV2 = braco as ComboNativoV2
	estado.text = "Combo %d / tensão %.0f%% | Ossos, mãos e juntas fixos | Pose: %s" % [rig.combo, rig.tensao_combo * 100, rig.pose_atual]
