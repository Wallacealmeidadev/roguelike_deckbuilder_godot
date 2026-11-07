class_name ApoioCorporalNativoV2
extends ComboNativoV2
## A pelve participa do soco; pesos dos tornozelos/botas ficam no apoio fixo.

@onready var joelho_tras: Bone2D = $Skeleton2D/JoelhoTras
@onready var joelho_frente: Bone2D = $Skeleton2D/JoelhoFrente
@onready var apoios: Bone2D = $Skeleton2D/Apoios
@onready var sola_tras: Marker2D = $Skeleton2D/Apoios/SolaTras
@onready var sola_frente: Marker2D = $Skeleton2D/Apoios/SolaFrente
