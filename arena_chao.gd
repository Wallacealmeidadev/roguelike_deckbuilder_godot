extends Control
## Fundo de combate. A visibilidade continua sob controle do fluxo existente.
## O recorte preenche a janela sem deformar a arte nem capturar eventos da HUD.
const CENARIO: Texture2D = preload("res://hud_hq/cenarios/docas_dia.png")
const FILTRO_NOTURNO: Shader = preload("res://hud_neon/arena_noite.gdshader")
const PATIO: Texture2D = preload("res://assets/arenas/patio_conteineres.png")
const BOMBAS: Texture2D = preload("res://assets/arenas/estacao_bombeamento.png")

var id_arena: String = "cais"
var _fundo: TextureRect
var _anterior: TextureRect
var _transicao: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_anterior = _criar_fundo("ArenaAnterior")
	_anterior.hide()
	_fundo = _criar_fundo("CenarioDocas")
	_fundo.texture = CENARIO
	var material_noite: ShaderMaterial = ShaderMaterial.new()
	material_noite.shader = FILTRO_NOTURNO
	_fundo.material = material_noite


func _criar_fundo(nome: String) -> TextureRect:
	var fundo: TextureRect = TextureRect.new()
	fundo.name = nome
	fundo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fundo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return fundo


func definir_encontro(id_encontro: String, movimento_reduzido: bool = false) -> void:
	var destino: String = "cais"
	if id_encontro.contains("carga") or id_encontro.contains("caranguejo"):
		destino = "patio"
	elif id_encontro.contains("guindaste") or id_encontro.contains("contencao") or id_encontro.contains("reparador"):
		destino = "bombas"
	if destino == id_arena:
		return
	if _transicao != null and _transicao.is_valid():
		_transicao.kill()
	_anterior.texture = _fundo.texture
	_anterior.material = _fundo.material
	_anterior.show()
	id_arena = destino
	_fundo.texture = PATIO if destino == "patio" else BOMBAS if destino == "bombas" else CENARIO
	if destino == "cais":
		var material_noite: ShaderMaterial = ShaderMaterial.new()
		material_noite.shader = FILTRO_NOTURNO
		_fundo.material = material_noite
	else:
		_fundo.material = null
	_fundo.modulate.a = 1.0 if movimento_reduzido else 0.0
	if movimento_reduzido:
		_anterior.hide()
		return
	_transicao = create_tween()
	_transicao.tween_property(_fundo, "modulate:a", 1.0, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_transicao.tween_callback(_anterior.hide)
