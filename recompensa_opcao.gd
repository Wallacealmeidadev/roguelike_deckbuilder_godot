extends Button

const ESTILO_TOOLTIP: StyleBox = preload("res://ui_hq_v1/estilos/tooltip.tres")

var nome_label: Label
var balao: Panel
var balao_texto: Label


func _ready() -> void:
	nome_label = get_node_or_null("NomeLabel") as Label
	if nome_label == null:
		nome_label = Label.new()
		nome_label.name = "NomeLabel"
		add_child(nome_label)
	nome_label.position = Vector2(18.0, 25.0)
	nome_label.size = Vector2(maxf(size.x - 36.0, 120.0), 60.0)
	nome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nome_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	nome_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nome_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nome_label.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/Bangers-Regular.ttf"))
	nome_label.add_theme_font_size_override("font_size", 23)
	nome_label.add_theme_color_override("font_color", Color("#0a1013"))

	balao = get_node_or_null("DescricaoBalao") as Panel
	if balao == null:
		balao = Panel.new()
		balao.name = "DescricaoBalao"
		balao.position = Vector2(-20.0, -118.0)
		balao.size = Vector2(maxf(size.x + 40.0, 260.0), 110.0)
		balao.mouse_filter = Control.MOUSE_FILTER_IGNORE
		balao.z_index = 20
		add_child(balao)
		balao_texto = Label.new()
		balao_texto.name = "Texto"
		balao.add_child(balao_texto)
		balao_texto.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		balao_texto.offset_left = 12.0
		balao_texto.offset_top = 10.0
		balao_texto.offset_right = -12.0
		balao_texto.offset_bottom = -10.0
		balao_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		balao_texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		balao_texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		balao_texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		balao_texto = balao.get_node("Texto") as Label

	text = ""
	balao.hide()
	balao.add_theme_stylebox_override("panel", ESTILO_TOOLTIP)
	mouse_entered.connect(_mostrar_balao)
	mouse_exited.connect(_ocultar_balao)


func configurar_recompensa(nome: String, descricao: String) -> void:
	nome_label.text = nome
	balao_texto.text = descricao
	tooltip_text = descricao


func _mostrar_balao() -> void:
	balao.show()


func _ocultar_balao() -> void:
	balao.hide()
