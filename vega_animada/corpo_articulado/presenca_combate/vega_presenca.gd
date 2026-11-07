class_name VegaPresencaCombateV1
extends VegaGolpesAlternadosV1
## Respiração/dano na mesma cadeia. Golpes da prova 13 não são reescritos.

const RESPIRO: StringName = &"guarda_respirando"
const FERIMENTO: StringName = &"reacao_corporal"
const TEMPOS_RESPIRO: Array[float] = [0.0, .6, 1.2, 1.8, 2.4]
const TEMPOS_DANO: Array[float] = [0.0, .10, .26]
const ONDA: Array[float] = [0.0, .5, 1.0, .5, 0.0]
const IMPACTO: Array[float] = [0.0, 1.0, 0.0]

@export_range(0.0, 2.0, .1) var amplitude_respiro: float = 1.0
var respiro_habilitado: bool = true
var presenca_pronta: bool = false


func _ready() -> void:
	super._ready()
	_criar_presenca()
	presenca_pronta = true
	retomar_guarda()


func _clipe_neutro(nome: StringName, duracao: float, repetir: bool) -> Animation:
	var clipe: Animation = modelo.animacao.get_animation(&"corpo_soco").duplicate(true) as Animation
	clipe.resource_name = str(nome)
	clipe.length = duracao
	clipe.loop_mode = Animation.LOOP_LINEAR if repetir else Animation.LOOP_NONE
	for trilha: int in range(clipe.get_track_count()):
		var valor: Variant = clipe.track_get_key_value(trilha, 0)
		for chave: int in range(clipe.track_get_key_count(trilha) - 1, -1, -1):
			clipe.track_remove_key(trilha, chave)
		clipe.track_insert_key(trilha, 0, valor)
	return clipe


func _canal(clipe: Animation, no: Node2D, propriedade: String, tempos: Array[float], valores: Array) -> void:
	var caminho := NodePath(str(modelo.get_path_to(no)) + ":" + propriedade)
	var trilha: int = clipe.find_track(caminho, Animation.TYPE_VALUE)
	if trilha < 0:
		trilha = clipe.add_track(Animation.TYPE_VALUE)
		clipe.track_set_path(trilha, caminho)
	clipe.track_set_interpolation_type(trilha, Animation.INTERPOLATION_CUBIC if clipe.loop_mode != Animation.LOOP_NONE else Animation.INTERPOLATION_LINEAR)
	for chave: int in range(clipe.track_get_key_count(trilha) - 1, -1, -1):
		clipe.track_remove_key(trilha, chave)
	for indice: int in range(tempos.size()):
		clipe.track_insert_key(trilha, tempos[indice], valores[indice])


func _giro(clipe: Animation, no: Node2D, delta: float, respirar: bool) -> void:
	var valores: Array[float] = []
	for peso: float in ONDA if respirar else IMPACTO:
		valores.append(no.rotation + deg_to_rad(delta) * peso * (amplitude_respiro if respirar else 1.0))
	_canal(clipe, no, "rotation", TEMPOS_RESPIRO if respirar else TEMPOS_DANO, valores)


func _deslocar(clipe: Animation, no: Node2D, delta: Vector2, respirar: bool) -> void:
	var valores: Array[Vector2] = []
	for peso: float in ONDA if respirar else IMPACTO:
		valores.append(no.position + delta * peso * (amplitude_respiro if respirar else 1.0))
	_canal(clipe, no, "position", TEMPOS_RESPIRO if respirar else TEMPOS_DANO, valores)


func _criar_presenca() -> void:
	var biblioteca: AnimationLibrary = modelo.animacao.get_animation_library(&"")
	var respirar: Animation = _clipe_neutro(RESPIRO, 2.4, true)
	_deslocar(respirar, modelo.pelve, Vector2(0, -1.5), true)
	_giro(respirar, abdomen, .3, true)
	_giro(respirar, modelo.tronco, .7, true)
	_giro(respirar, cabeca, -1.0, true)
	_giro(respirar, modelo.clavicula, -.35, true)
	_giro(respirar, modelo.deltoide, -.25, true)
	_giro(respirar, braco_novo.ombro, -.4, true)
	_giro(respirar, braco_novo.cotovelo, 1.0, true)
	_giro(respirar, braco_novo.punho, -.35, true)
	_giro(respirar, modelo.clavicula_distante, -.25, true)
	_giro(respirar, modelo.deltoide_distante, -.2, true)
	_giro(respirar, novo_distante.ombro, .55, true)
	_giro(respirar, novo_distante.cotovelo, -1.0, true)
	_giro(respirar, novo_distante.punho, .35, true)
	var dano: Animation = _clipe_neutro(FERIMENTO, .26, false)
	_deslocar(dano, modelo.pelve, Vector2(-4, 2), false)
	_deslocar(dano, modelo.joelho_tras, Vector2(-1, 1), false)
	_deslocar(dano, modelo.joelho_frente, Vector2(-1, 1), false)
	_giro(dano, modelo.pelve, -.5, false)
	_giro(dano, abdomen, -1.5, false)
	_giro(dano, modelo.tronco, -4.0, false)
	_giro(dano, cabeca, 1.5, false)
	_giro(dano, modelo.clavicula, 1.0, false)
	_giro(dano, modelo.deltoide, 1.5, false)
	_giro(dano, braco_novo.ombro, 5.0, false)
	_giro(dano, braco_novo.cotovelo, 1.0, false)
	_giro(dano, braco_novo.punho, -2.0, false)
	_giro(dano, modelo.clavicula_distante, -1.5, false)
	_giro(dano, modelo.deltoide_distante, 1.0, false)
	_giro(dano, novo_distante.ombro, 1.0, false)
	_giro(dano, novo_distante.cotovelo, -1.0, false)
	_giro(dano, novo_distante.punho, 2.0, false)
	biblioteca.add_animation(RESPIRO, respirar)
	biblioteca.add_animation(FERIMENTO, dano)
	modelo.animacao.clear_caches()


func retomar_guarda() -> void:
	if not presenca_pronta or not is_visible_in_tree():
		return
	_parar_feedback()
	if corpo_reduzido or not respiro_habilitado:
		pose_corpo(0)
		return
	estado_animacao = "guarda / respirando"
	modelo.animacao.play_with_capture(RESPIRO, .16, 0, 1, false, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)


func receber_dano() -> void:
	if not presenca_pronta or not is_visible_in_tree():
		return
	_parar_feedback()
	if corpo_reduzido:
		pose_corpo(0)
	else:
		modelo.animacao.play_with_capture(FERIMENTO, .1, 0, 1, false, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	estado_animacao = "dano / reduzido" if corpo_reduzido else "reação ao dano"
	_flash(Color(1, .58, .88), "dano")


func inspecionar_presenca(dano: bool, tempo: float) -> void:
	inspecionar(FERIMENTO if dano else RESPIRO, 0.0 if corpo_reduzido else tempo)
	estado_animacao = "dano pausado" if dano else "respiro pausado"


func _terminar_corpo(nome: StringName) -> void:
	if nome in [&"corpo_soco", CLIPE_DISTANTE, FERIMENTO]:
		retomar_guarda()


func definir_respiro(ativo: bool) -> void:
	respiro_habilitado = ativo
	if not modelo.animacao.is_playing() or modelo.animacao.current_animation == RESPIRO:
		retomar_guarda()


func reduzir_corpo(ativo: bool) -> void:
	_parar_feedback()
	super.reduzir_corpo(ativo)
	if presenca_pronta:
		retomar_guarda()


func reiniciar_sequencia() -> void:
	super.reiniciar_sequencia()
	if presenca_pronta:
		retomar_guarda()


func _flash(cor: Color, estado: String) -> void:
	super._flash(cor, estado)
	if corpo_reduzido:
		movimento.finished.connect(retomar_guarda)


func _sincronizar_visibilidade() -> void:
	super._sincronizar_visibilidade()
	if presenca_pronta and is_visible_in_tree():
		retomar_guarda()
