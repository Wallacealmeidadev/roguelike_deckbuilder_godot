extends Button

@onready var acao_label: Label = $Conteudo/Linha/Textos/Acao
@onready var detalhe_label: Label = $Conteudo/Linha/Textos/Detalhe
@onready var tipo_icone: TextureRect = $Conteudo/Linha/TipoIcone
@onready var interacao: Panel = $Interacao
@onready var seta: TextureRect = $Conteudo/Linha/Seta

const ICONE_SETA: Texture2D = preload("res://ui_hq_v1/componentes/icones/seta.tres")
const ICONE_COMBATE: Texture2D = preload("res://ui_hq_v1/componentes/icones/combate.tres")


func configurar_evento(nome: String, detalhe: String, tipo: String = "") -> void:
	acao_label.text = nome
	detalhe_label.text = detalhe
	detalhe_label.visible = not detalhe.is_empty()
	tipo_icone.visible = tipo == "combate"
	tipo_icone.texture = ICONE_COMBATE
	seta.texture = ICONE_SETA
	tooltip_text = ""
	_atualizar_cores()


func _ready() -> void:
	mouse_entered.connect(_atualizar_cores)
	mouse_exited.connect(_atualizar_cores)
	focus_entered.connect(_atualizar_cores)
	focus_exited.connect(_atualizar_cores)
	_atualizar_cores()


func _atualizar_cores() -> void:
	var ativo: bool = is_hovered() or has_focus()
	interacao.visible = ativo
	acao_label.add_theme_color_override("font_color", Color("#73e7ff") if ativo else Color("#f5f7fa"))
	detalhe_label.add_theme_color_override("font_color", Color("#c4f6ff") if ativo else Color("#a9b9c7"))
