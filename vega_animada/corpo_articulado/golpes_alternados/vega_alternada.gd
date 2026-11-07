class_name VegaGolpesAlternadosV1
extends VegaIntegracaoTroncoV1
## Um AnimationPlayer, dois golpes. A prova 12 e seu soco próximo não mudam.

const CLIPE_DISTANTE: StringName = &"corpo_soco_distante"
var inspecao_distante: bool = false


func _ready() -> void:
	super._ready()
	_criar_golpe_distante()
	reiniciar_sequencia()


func _criar_golpe_distante() -> void:
	# A classe corporal já criou uma biblioteca privada. Não serializar novamente
	# os clipes aceitos: duplicate(true) quantiza seus tempos para float32.
	var biblioteca: AnimationLibrary = modelo.animacao.get_animation_library(&"")
	var clipe: Animation = biblioteca.get_animation(&"corpo_soco").duplicate(true) as Animation
	clipe.resource_name = str(CLIPE_DISTANTE)
	# Começar pela guarda integral; remover o gesto do soco próximo só nesta cópia.
	for trilha: int in range(clipe.get_track_count()):
		var guarda: Variant = clipe.track_get_key_value(trilha, 0)
		for chave: int in range(clipe.track_get_key_count(trilha)):
			clipe.track_set_key_value(trilha, chave, guarda)
	_trilha(clipe, modelo.pelve, "position", [Vector2(320, 410), Vector2(316, 416), Vector2(330, 412), Vector2(322, 412), Vector2(320, 410)])
	_graus(clipe, modelo.pelve, [0.0, -1.0, 1.5, .5, 0.0])
	_graus(clipe, abdomen, [0.0, -2.0, 2.0, 0.0, 0.0])
	_graus(clipe, modelo.tronco, [1.0, -3.0, 4.0, 1.0, 1.0])
	_graus(clipe, cabeca, [0.0, 6.0, -7.0, -.5, 0.0])
	_trilha(clipe, modelo.joelho_tras, "position", [Vector2(180, 620), Vector2(179, 623), Vector2(184, 620), Vector2(181, 621), Vector2(180, 620)])
	_trilha(clipe, modelo.joelho_frente, "position", [Vector2(560, 580), Vector2(559, 583), Vector2(566, 583), Vector2(561, 582), Vector2(560, 580)])
	_graus(clipe, modelo.clavicula_distante, [-1.0, 2.0, -6.0, -1.0, -1.0])
	_graus(clipe, modelo.deltoide_distante, [2.0, 3.0, -6.0, 2.0, 2.0])
	_graus(clipe, novo_distante.ombro, [135.0, 128.0, 170.0, 135.0, 135.0])
	_graus(clipe, novo_distante.cotovelo, [120.0, 120.0, 8.0, 120.0, 120.0])
	_graus(clipe, novo_distante.punho, [0.0, -2.0, 0.0, 0.0, 0.0])
	# Compensar só a inclinação corporal no braço que protege; não mudar sua mão.
	_graus(clipe, braco_novo.ombro, [75.0, 82.0, 68.5, 74.5, 75.0])
	biblioteca.add_animation(CLIPE_DISTANTE, clipe)
	modelo.animacao.clear_caches()


func _graus(clipe: Animation, no: Node2D, valores: Array[float]) -> void:
	var radianos: Array[float] = []
	for valor: float in valores:
		radianos.append(deg_to_rad(valor))
	_trilha(clipe, no, "rotation", radianos)


func inspecionar_golpe(distante: bool, indice: int) -> void:
	inspecao_distante = distante
	var pose: int = 0 if corpo_reduzido else clampi(indice, 0, 4)
	inspecionar(CLIPE_DISTANTE if distante else &"corpo_soco", TEMPOS[pose])
	estado_animacao = ["guarda", "preparo", "impacto", "retorno", "guarda"][pose]
	estado_animacao += " / " + ("distante" if distante else "próximo")
	guias_corpo.queue_redraw()


func socar_corpo() -> void:
	if not is_visible_in_tree():
		return
	_parar_feedback()
	ultimo_braco_distante = proximo_braco_distante
	proximo_braco_distante = not proximo_braco_distante
	inspecao_distante = ultimo_braco_distante
	var lado: String = "distante" if ultimo_braco_distante else "próximo"
	if corpo_reduzido:
		pose_corpo(0)
		estado_animacao = "golpe " + lado + " / reduzido"
		_flash(Color(.75, 1, 1), "corpo")
		return
	estado_animacao = "golpe " + lado
	modelo.animacao.play_with_capture(CLIPE_DISTANTE if ultimo_braco_distante else &"corpo_soco",
		.1, 0, 1, false, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)


func _terminar_corpo(nome: StringName) -> void:
	if nome in [&"corpo_soco", CLIPE_DISTANTE]:
		pose_corpo(0)


func reiniciar_sequencia() -> void:
	_parar_feedback()
	proximo_braco_distante = false
	ultimo_braco_distante = false
	inspecao_distante = false
	pose_corpo(0)
