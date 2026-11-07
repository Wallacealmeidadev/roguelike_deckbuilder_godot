class_name VegaEncaixeBracoV1
extends VegaAcabamentoProximo
## Somente apresentação estática, com a nova prótese presa ao deltoide existente.
## Não conectar esta prova às cartas antes de validar os encaixes e o movimento.

const NOVO_BRACO: Script = preload("res://vega_animada/braco_reconstruido/braco_registrado.gd")
# Abrir a dobra entre bíceps e antebraço (60° internos), não apenas afastar
# a guarda do peito. Ombro acompanha a postura sem deslocar a inserção.
@export_range(60, 120, 1) var angulo_ombro: float = 75
@export_range(-165, -100, 1) var angulo_cotovelo: float = -120
@export_range(.6, 1.0, .01) var fator_mao: float = .76
@export var inverter_lado_mao: bool = true
var braco_novo: BracoRegistradoV1
var comparar_anterior: bool = false


func _ready() -> void:
	super._ready()
	braco_novo = NOVO_BRACO.new() as BracoRegistradoV1
	braco_novo.name = "BracoReconstruido"
	braco_novo.z_index = modelo.braco_original.z_index
	modelo.deltoide.add_child(braco_novo)
	# Herda o encaixe do ombro, não a escala/rotação de sprites da montagem antiga.
	braco_novo.transform = modelo.braco_original.transform
	ajustar_mao()
	aplicar_guarda()


func ajustar_mao() -> void:
	# O osso e a raiz continuam no mesmo lugar. Reflexão só no eixo transversal:
	# troca o lado do polegar, sem apontar os dedos de volta para o antebraço.
	var mao: Polygon2D = braco_novo.segmentos[2]
	mao.scale = Vector2(fator_mao, -fator_mao if inverter_lado_mao else fator_mao)
	braco_novo.guias.queue_redraw()


func aplicar_guarda() -> void:
	# Respiração já contém a guarda corporal aceita e a vista distante corrigida.
	# Aqui ela é apenas amostrada e pausada: nenhum escritor por frame.
	modelo.animacao.clear_caches()
	modelo.animacao.play(&"respirar", 0)
	modelo.animacao.seek(0, true)
	modelo.animacao.pause()
	braco_novo.ombro.rotation = deg_to_rad(angulo_ombro)
	braco_novo.cotovelo.rotation = deg_to_rad(angulo_cotovelo)
	braco_novo.punho.rotation = 0
	braco_novo.guias.queue_redraw()
	comparar(comparar_anterior)


func comparar(anterior: bool) -> void:
	comparar_anterior = anterior
	modelo.braco_original.visible = anterior
	braco_novo.visible = not anterior


func mostrar_marcos(ativo: bool) -> void:
	braco_novo.mostrar_marcos = ativo
