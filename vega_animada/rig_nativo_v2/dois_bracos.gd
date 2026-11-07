class_name DoisBracosNativoV2
extends OmbroTroncoNativoV2
## A segunda prótese compartilha o tronco, mas tem clavícula e guarda próprias.

@onready var clavicula_distante: Bone2D = $Skeleton2D/Pelve/Tronco/ClaviculaDistante
@onready var deltoide_distante: Bone2D = $Skeleton2D/Pelve/Tronco/ClaviculaDistante/DeltoideDistante
@onready var braco_distante: BracoNativoV2 = $Skeleton2D/Pelve/Tronco/ClaviculaDistante/DeltoideDistante/BracoDistante


func _ready() -> void:
	braco_distante.animacao.active = false
	super._ready()
