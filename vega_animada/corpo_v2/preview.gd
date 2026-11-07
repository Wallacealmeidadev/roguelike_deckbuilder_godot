extends Control

@onready var vega: VegaCorpoV2Prova = $Vega
@onready var referencia: TextureRect = $Referencia
@onready var estado: Label = $Estado
@onready var controles: HBoxContainer = $Controles


func _ready() -> void:
	resized.connect(_layout)
	($Controles/Combate as Button).toggled.connect(_alternar)
	($Controles/MaisUm as Button).pressed.connect(_ganhar.bind(1))
	($Controles/MaisTres as Button).pressed.connect(_ganhar.bind(3))
	($Controles/Maximo as Button).pressed.connect(_maximo)
	($Controles/Consumir as Button).pressed.connect(_consumir)
	($Controles/Reduzido as CheckButton).toggled.connect(vega.definir_movimento_reduzido)
	vega.apresentacao_alterada.connect(_atualizar)
	_layout()
	_atualizar()


func _layout() -> void:
	if not is_instance_valid(vega):
		return
	referencia.position = Vector2(28, 118)
	referencia.size = Vector2(size.x * .43, size.y - 264)
	var fator: float = minf((size.y - 174) / VegaCorpoV2Prova.TAMANHO.y, size.x * .43 / VegaCorpoV2Prova.TAMANHO.x)
	vega.scale = Vector2.ONE * fator
	vega.position = Vector2(size.x * .73 - 512 * fator, 108)
	($LegendaProva as Label).position = Vector2(size.x * .54, 82)
	estado.position = Vector2(28, size.y - 106)
	controles.position = Vector2(28, size.y - 52)
	controles.size = Vector2(size.x - 56, 36)
	($Rodape as ColorRect).position = Vector2(0, size.y - 64)
	($Rodape as ColorRect).size = Vector2(size.x, 64)


func _atualizar() -> void:
	var porcentagem: int = roundi(BracoV2Prova.tensao_por_combo(vega.combo) * 100)
	estado.text = "%s / COMBO %d / TENSÃO %d%%" % ["COMBATE" if vega.em_combate else "REPOUSO", vega.combo, porcentagem]
	($Controles/Combate as Button).set_pressed_no_signal(vega.em_combate)
	($Controles/Combate as Button).text = "Voltar ao repouso" if vega.em_combate else "Ativar combate"


func _alternar(ativo: bool) -> void:
	vega.definir_combate(ativo)


func _ganhar(valor: int) -> void:
	vega.definir_combate(true)
	vega.definir_combo(vega.combo + valor)


func _maximo() -> void:
	vega.definir_combate(true)
	vega.definir_combo(10)


func _consumir() -> void:
	vega.definir_combo(0)
