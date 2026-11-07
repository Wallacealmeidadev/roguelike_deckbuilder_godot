extends Control
## Laboratório de apresentação; não instancia main.tscn nem estado da run.

@onready var braco: BracoV2Prova = $Braco
@onready var referencia: TextureRect = $Referencia
@onready var estado: Label = $Estado
@onready var alternar: Button = $Alternar
@onready var reduzido: CheckButton = $Reduzido
@onready var controle: HSlider = $Ativacao
@onready var ciclo_timer: Timer = $CicloTimer
var _fase_ciclo: int = -1


func _ready() -> void:
	resized.connect(_layout)
	alternar.toggled.connect(_alternar)
	($Ciclo as Button).pressed.connect(reproduzir_ciclo)
	reduzido.toggled.connect(_reduzir)
	controle.value_changed.connect(_mover_controle)
	ciclo_timer.timeout.connect(_passo_ciclo)
	braco.ativacao_alterada.connect(_atualizar_estado)
	braco.combo_alterado.connect(_atualizar_combo)
	($ControlesCombo/MaisUm as Button).pressed.connect(_ganhar_combo.bind(1))
	($ControlesCombo/MaisTres as Button).pressed.connect(_ganhar_combo.bind(3))
	($ControlesCombo/Alto as Button).pressed.connect(_simular_combo.bind(10))
	($ControlesCombo/Consumir as Button).pressed.connect(_consumir_combo)
	_layout()
	_atualizar_estado(0.0)
	_atualizar_combo(0)
	if "--ciclo" in OS.get_cmdline_user_args():
		call_deferred("reproduzir_ciclo")


func _layout() -> void:
	var largura: float = size.x
	var altura: float = size.y
	if not is_instance_valid(braco):
		return
	referencia.position = Vector2(28, 128)
	referencia.size = Vector2(largura * .43, altura - 275)
	($LegendaReferencia as Label).position = Vector2(32, 104)
	($LegendaProva as Label).position = Vector2(largura * .54, 104)
	var fator: float = minf((altura - 290) / BracoV2Prova.ALTURA, largura * .35 / 280)
	braco.position = Vector2(largura * .73, 138)
	braco.scale = Vector2.ONE * maxf(fator, .1)
	estado.position = Vector2(largura * .54, altura - 138)
	controle.position = Vector2(largura * .54, altura - 99)
	controle.size = Vector2(largura * .4, 28)
	($Rodape as ColorRect).position = Vector2(0, altura - 62)
	($Rodape as ColorRect).size = Vector2(largura, 62)
	alternar.position = Vector2(28, altura - 52)
	alternar.size = Vector2(168, 42)
	($Ciclo as Button).position = Vector2(208, altura - 52)
	($Ciclo as Button).size = Vector2(176, 42)
	reduzido.position = Vector2(404, altura - 52)
	reduzido.size = Vector2(234, 42)
	($LegendaCombo as Label).position = Vector2(28, altura - 136)
	($ControlesCombo as HBoxContainer).position = Vector2(28, altura - 101)
	($ControlesCombo as HBoxContainer).size = Vector2(largura * .48 - 28, 30)


func _alternar(ativo: bool) -> void:
	_parar_ciclo()
	braco.definir_combate(ativo)


func _reduzir(ativo: bool) -> void:
	_parar_ciclo()
	braco.definir_movimento_reduzido(ativo)


func _mover_controle(valor: float) -> void:
	_parar_ciclo()
	braco.definir_ativacao(valor / 100.0)
	alternar.set_pressed_no_signal(valor >= 50.0)


func _atualizar_estado(valor: float) -> void:
	controle.set_value_no_signal(valor * 100.0)
	var nome_estado: String = "REPOUSO" if is_zero_approx(valor) else "COMBATE" if is_equal_approx(valor, 1.0) else "TRANSIÇÃO"
	estado.text = "%s  /  %d%%" % [nome_estado, roundi(valor * 100)]
	alternar.text = "Voltar ao repouso" if braco.destino >= .5 else "Ativar combate"


func _parar_ciclo() -> void:
	ciclo_timer.stop()
	_fase_ciclo = -1


func reproduzir_ciclo() -> void:
	_parar_ciclo()
	_fase_ciclo = 0
	alternar.set_pressed_no_signal(false)
	braco.definir_combate(false)
	ciclo_timer.start(.5)


func _passo_ciclo() -> void:
	_fase_ciclo += 1
	if _fase_ciclo == 1:
		alternar.set_pressed_no_signal(true)
		braco.definir_combate(true)
		ciclo_timer.start(1.0)
	elif _fase_ciclo == 2:
		alternar.set_pressed_no_signal(false)
		braco.definir_combate(false)
		ciclo_timer.start(.5)
	else:
		_parar_ciclo()


func _ganhar_combo(quantidade: int) -> void:
	_simular_combo(braco.combo + quantidade)


func _simular_combo(valor: int) -> void:
	_parar_ciclo()
	alternar.set_pressed_no_signal(true)
	braco.definir_combate(true)
	braco.definir_combo(valor)


func _consumir_combo() -> void:
	_parar_ciclo()
	braco.definir_combo(0)


func _atualizar_combo(valor: int) -> void:
	($ControlesCombo/Valor as Label).text = "COMBO %d / %d%%" % [valor, roundi(BracoV2Prova.tensao_por_combo(valor) * 100.0)]
