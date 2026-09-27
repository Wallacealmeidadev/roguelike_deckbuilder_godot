extends Button

@onready var icone: TextureRect = $Painel/Conteudo/Icone
@onready var nome_label: Label = $Painel/Conteudo/Nome
@onready var efeito_label: Label = $Painel/Conteudo/Efeito


func _ready() -> void:
	flat = true
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_ao_entrar)
	mouse_exited.connect(_ao_sair)
	focus_entered.connect(_ao_focar)
	focus_exited.connect(_ao_desfocar)


func configurar_recompensa(dados: Dictionary) -> void:
	nome_label.text = str(dados.get("nome", "Relíquia"))
	efeito_label.text = str(dados.get("descricao", "Relíquia ativa durante a run."))


func _ao_entrar() -> void:
	_atualizar_estado(true)


func _ao_sair() -> void:
	_atualizar_estado(has_focus())


func _ao_focar() -> void:
	_atualizar_estado(true)


func _ao_desfocar() -> void:
	_atualizar_estado(is_hovered())


func _atualizar_estado(ativo: bool) -> void:
	var estilo: StyleBoxFlat = $Painel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	estilo.border_color = Color("#16d9f2") if ativo else Color("#f5f7fa")
	$Painel.add_theme_stylebox_override("panel", estilo)
	$Painel.modulate = Color("#ffffff")
	# O destaque troca somente a moldura; a área reservada pelo HBox permanece estável.
	$Painel.scale = Vector2.ONE
	$Painel.z_index = 2 if ativo else 0
