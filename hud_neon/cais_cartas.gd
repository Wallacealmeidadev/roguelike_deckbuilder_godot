extends Control
## A moldura preserva os cantos; só o miolo se adapta à largura da mão.

var textura: AtlasTexture
var _arte: NinePatchRect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	textura = AtlasTexture.new()
	textura.atlas = preload("res://assets/ui/runtime/conceito/cais_longo.png")
	textura.region = Rect2(8, 216, 2008, 328)
	_arte = NinePatchRect.new()
	_arte.texture = textura
	_arte.patch_margin_left = 160
	_arte.patch_margin_right = 160
	_arte.patch_margin_top = 50
	_arte.patch_margin_bottom = 50
	_arte.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_arte)
	resized.connect(_ajustar)
	_ajustar()


func _ajustar() -> void:
	if _arte == null or size.y <= 0.0:
		return
	var fator: float = size.y / textura.get_height()
	_arte.scale = Vector2.ONE * fator
	_arte.size = size / fator
