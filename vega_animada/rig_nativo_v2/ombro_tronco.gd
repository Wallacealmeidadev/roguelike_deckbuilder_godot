class_name OmbroTroncoNativoV2
extends BracoNativoV2
## A pele é deformada pelo Skeleton2D na GPU, não por um solver em GDScript.

@onready var pele: Polygon2D = $Pele
@onready var pelve: Bone2D = $Skeleton2D/Pelve
@onready var tronco: Bone2D = $Skeleton2D/Pelve/Tronco
@onready var clavicula: Bone2D = $Skeleton2D/Pelve/Tronco/Clavicula
@onready var deltoide: Bone2D = $Skeleton2D/Pelve/Tronco/Clavicula/Deltoide
@onready var braco_original: BracoNativoV2 = $Skeleton2D/Pelve/Tronco/Clavicula/Deltoide/Braco


func _ready() -> void:
	# Um só AnimationPlayer escreve corpo e braço. O braço continua instanciado.
	braco_original.animacao.active = false
	super._ready()
