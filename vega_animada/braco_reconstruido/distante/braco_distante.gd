class_name BracoDistanteRegistradoV1
extends BracoRegistradoV1
## Vista interna própria; compartilha o método de registro, não a arte próxima.

const ARTE_INTERNA: Texture2D = preload("res://vega_animada/braco_reconstruido/distante/braco_interno_01.png")
# Medidos na fonte resultante, não herdados dos pixels do outro braço.
const FONTE_OMBRO := Vector2(535, 135)
const FONTE_COTOVELO := Vector2(500, 650)
const FONTE_PUNHO := Vector2(500, 1200)
const FONTE_PONTA := Vector2(510, 1460)
var fator_mao_interna: float = 1.0


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var esqueleto := Skeleton2D.new()
	esqueleto.name = "Skeleton2D"
	add_child(esqueleto)
	ombro = _osso(esqueleto, "Ombro", Vector2.ZERO, SUPERIOR)
	cotovelo = _osso(ombro, "Cotovelo", Vector2(SUPERIOR, 0), INFERIOR)
	punho = _osso(cotovelo, "Punho", Vector2(INFERIOR, 0), MAO)
	_parte(ombro, "SuperiorInterno", FONTE_OMBRO, FONTE_COTOVELO, SUPERIOR,
		PackedVector2Array([Vector2(300, 0), Vector2(750, 0), Vector2(750, 600),
		Vector2(615, 600), Vector2(615, 657), Vector2(580, 700),
		Vector2(500, 715), Vector2(425, 700), Vector2(395, 660),
		Vector2(395, 600), Vector2(300, 600)]), 4)
	_parte(cotovelo, "AntebracoInterno", FONTE_COTOVELO, FONTE_PUNHO, INFERIOR,
		PackedVector2Array([Vector2(300, 650), Vector2(750, 650),
		Vector2(750, 1200), Vector2(565, 1200), Vector2(550, 1210),
		Vector2(500, 1215), Vector2(445, 1210), Vector2(430, 1200),
		Vector2(300, 1200)]), 2)
	_parte(punho, "MaoPalmar", FONTE_PUNHO, FONTE_PONTA, MAO,
		PackedVector2Array([Vector2(300, 1200), Vector2(750, 1200),
		Vector2(750, 1536), Vector2(300, 1536)]), 1)
	# A mão mantém a densidade raster do antebraço, sem ampliar a luva.
	fator_mao_interna = (INFERIOR / FONTE_COTOVELO.distance_to(FONTE_PUNHO)) / (MAO / FONTE_PUNHO.distance_to(FONTE_PONTA))
	# A raiz distante já é refletida no rig. Só a base transversal da palma
	# corrige a orientação do polegar; não transforma dorso em palma por espelho.
	segmentos[2].scale = Vector2(fator_mao_interna, -fator_mao_interna)
	guias = Node2D.new()
	guias.name = "Marcos"
	guias.z_index = 10
	add_child(guias)
	guias.draw.connect(_desenhar_marcos)
	definir_pose(&"neutro")


func _parte(osso: Bone2D, nome: String, origem: Vector2, destino: Vector2,
		comprimento: float, uv: PackedVector2Array, camada: int) -> void:
	_segmento(osso, nome, origem, destino, comprimento, uv, camada)
	segmentos[-1].texture = ARTE_INTERNA
