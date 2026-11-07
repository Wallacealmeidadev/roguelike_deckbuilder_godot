class_name VegaCorpoArticuladoV1
extends VegaGuardaDistanteV1
## Prova mecânica do corpo, sem trocar a pintura ou as peças aprovadas.

const TEMPOS: Array[float] = [0.0, .10, .20, .36, .56]
const COLUNA_ANTIGA: String = "Skeleton2D/Pelve/Tronco"
const COLUNA_NOVA: String = "Skeleton2D/Pelve/Abdomen/Tronco"
var abdomen: Bone2D
var cabeca: Bone2D
var ossos_pele: Array[Bone2D] = []
var vertices_antes := PackedVector2Array()
var pesos_antes: Array[PackedFloat32Array] = []
var corpo_reduzido: bool = false
var guias_corpo: Node2D


func _ready() -> void:
	super._ready()
	_preparar_corpo()
	_preparar_clipe()
	guias_corpo = Node2D.new()
	guias_corpo.name = "GuiasCorpo"
	guias_corpo.z_index = 100
	modelo.add_child(guias_corpo)
	guias_corpo.draw.connect(_desenhar_corpo)
	modelo.animacao.animation_finished.connect(_terminar_corpo)
	pose_corpo(0)


func _osso_corporal(pai: Bone2D, nome: String, origem: Vector2, comprimento: float) -> Bone2D:
	var osso := Bone2D.new()
	osso.name = nome
	osso.position = origem
	osso.rest = osso.transform
	osso.auto_calculate_length_and_angle = false
	osso.length = comprimento
	pai.add_child(osso)
	return osso


func _matrizes_corpo() -> Array[Transform2D]:
	var matrizes: Array[Transform2D] = []
	for osso: Bone2D in ossos_pele:
		var atual: Transform2D = modelo.esqueleto.global_transform.affine_inverse() * osso.global_transform
		matrizes.append(atual * osso.get_skeleton_rest().affine_inverse())
	return matrizes


func _preparar_corpo() -> void:
	vertices_antes = modelo.pele.polygon.duplicate()
	for indice: int in range(modelo.pele.get_bone_count()):
		ossos_pele.append(modelo.esqueleto.get_node(modelo.pele.get_bone_path(indice)) as Bone2D)
		pesos_antes.append(modelo.pele.get_bone_weights(indice).duplicate())
	var matrizes_antes: Array[Transform2D] = _matrizes_corpo()
	# Rest global dos ossos existentes permanece igual: -30 + -50 = -80.
	abdomen = _osso_corporal(modelo.pelve, "Abdomen", Vector2(0, -30), 50)
	modelo.tronco.reparent(abdomen, true)
	modelo.tronco.rest = Transform2D(0, Vector2(0, -50))
	cabeca = _osso_corporal(modelo.tronco, "Cabeca", Vector2(25, -155), 85)
	ossos_pele.append(abdomen)
	ossos_pele.append(cabeca)
	var pesos: Array[PackedFloat32Array] = []
	for anterior: PackedFloat32Array in pesos_antes:
		pesos.append(anterior.duplicate())
	for novo: int in range(2):
		var vazio := PackedFloat32Array()
		vazio.resize(vertices_antes.size())
		pesos.append(vazio)
	for indice: int in range(vertices_antes.size()):
		# UV identifica a região desenhada mesmo após o rebind do ombro 06.
		var fonte: Vector2 = modelo.pele.uv[indice] - Vector2(300, 0)
		var faixa: float = smoothstep(285, 350, fonte.y) * (1 - smoothstep(400, 470, fonte.y)) * .75
		for doador: int in [0, 1]:
			var peso: float = pesos[doador][indice] * faixa
			pesos[doador][indice] -= peso
			pesos[9][indice] += peso
		var pescoco: float = 1 - smoothstep(130, 205, fonte.y)
		# Rampa lateral contínua também na transparência, sem salto na linha 120.
		pescoco *= smoothstep(150, 220, fonte.x) * (1 - smoothstep(450, 530, fonte.x))
		var transferencia: float = pesos[1][indice] * pescoco
		pesos[1][indice] -= transferencia
		pesos[10][indice] = transferencia
		_limitar_pesos(pesos, indice)
	var matrizes_novas: Array[Transform2D] = _matrizes_corpo()
	var pontos: PackedVector2Array = vertices_antes.duplicate()
	for indice: int in range(pontos.size()):
		var antes: Transform2D = _mistura(matrizes_antes, pesos_antes, indice)
		var depois: Transform2D = _mistura(matrizes_novas, pesos, indice)
		pontos[indice] = depois.affine_inverse() * (antes * pontos[indice])
	for malha: Polygon2D in [modelo.pele, remendo_ombro]:
		malha.polygon = pontos.duplicate()
		malha.clear_bones()
		for indice: int in range(ossos_pele.size()):
			malha.add_bone(modelo.esqueleto.get_path_to(ossos_pele[indice]), pesos[indice])
	# Os exports e as referências onready continuam coerentes após reparent.
	modelo.caminho_ombro = NodePath(str(modelo.caminho_ombro).replace(COLUNA_ANTIGA, COLUNA_NOVA))
	modelo.caminho_cotovelo = NodePath(str(modelo.caminho_cotovelo).replace(COLUNA_ANTIGA, COLUNA_NOVA))
	modelo.caminho_punho = NodePath(str(modelo.caminho_punho).replace(COLUNA_ANTIGA, COLUNA_NOVA))


func _limitar_pesos(pesos: Array[PackedFloat32Array], vertice: int) -> void:
	var ordem: Array[int] = []
	for indice: int in range(pesos.size()):
		if pesos[indice][vertice] > .000001:
			ordem.append(indice)
	if ordem.size() <= 4:
		return
	ordem.sort_custom(func(a: int, b: int) -> bool: return pesos[a][vertice] > pesos[b][vertice])
	for indice: int in range(4, ordem.size()):
		pesos[ordem[indice]][vertice] = 0
	var soma: float = 0
	for conjunto: PackedFloat32Array in pesos:
		soma += conjunto[vertice]
	for indice: int in range(pesos.size()):
		pesos[indice][vertice] /= soma


func _trilha(clipe: Animation, no: Node2D, propriedade: String, valores: Array) -> void:
	var caminho := NodePath(str(modelo.get_path_to(no)) + ":" + propriedade)
	var trilha: int = clipe.find_track(caminho, Animation.TYPE_VALUE)
	if trilha < 0:
		trilha = clipe.add_track(Animation.TYPE_VALUE)
		clipe.track_set_path(trilha, caminho)
	clipe.track_set_interpolation_type(trilha, Animation.INTERPOLATION_LINEAR)
	for chave: int in range(clipe.track_get_key_count(trilha) - 1, -1, -1):
		clipe.track_remove_key(trilha, chave)
	for indice: int in range(valores.size()):
		clipe.track_insert_key(trilha, TEMPOS[indice] if valores.size() > 1 else 0.0, valores[indice])


func _preparar_clipe() -> void:
	var biblioteca: AnimationLibrary = modelo.animacao.get_animation_library(&"").duplicate(true) as AnimationLibrary
	for nome: StringName in biblioteca.get_animation_list():
		var clipe: Animation = biblioteca.get_animation(nome)
		for trilha: int in range(clipe.get_track_count()):
			clipe.track_set_path(trilha, NodePath(str(clipe.track_get_path(trilha)).replace(COLUNA_ANTIGA, COLUNA_NOVA)))
		_trilha(clipe, abdomen, "rotation", [0.0])
		_trilha(clipe, cabeca, "rotation", [0.0])
		_trilha(clipe, modelo.pelve, "rotation", [0.0])
		_trilha(clipe, novo_distante.ombro, "rotation", [deg_to_rad(ombro_distante_guarda)])
		_trilha(clipe, novo_distante.cotovelo, "rotation", [deg_to_rad(cotovelo_distante_guarda)])
		_trilha(clipe, novo_distante.punho, "rotation", [0.0])
	var soco: Animation = biblioteca.get_animation(&"soco").duplicate(true) as Animation
	soco.resource_name = "corpo_soco"
	_trilha(soco, modelo.pelve, "position", [Vector2(320, 410), Vector2(314, 417), Vector2(332, 413), Vector2(322, 412), Vector2(320, 410)])
	_trilha(soco, modelo.pelve, "rotation", [0.0, deg_to_rad(-2), deg_to_rad(2), deg_to_rad(.5), 0.0])
	_trilha(soco, abdomen, "rotation", [0.0, deg_to_rad(-3), deg_to_rad(3), 0.0, 0.0])
	_trilha(soco, modelo.tronco, "rotation", [deg_to_rad(1), deg_to_rad(-4), deg_to_rad(5), deg_to_rad(1), deg_to_rad(1)])
	_trilha(soco, cabeca, "rotation", [0.0, deg_to_rad(8), deg_to_rad(-9), deg_to_rad(-.5), 0.0])
	_trilha(soco, modelo.joelho_tras, "position", [Vector2(180, 620), Vector2(178, 623), Vector2(183, 619), Vector2(181, 621), Vector2(180, 620)])
	_trilha(soco, modelo.joelho_frente, "position", [Vector2(560, 580), Vector2(559, 584), Vector2(568, 584), Vector2(561, 582), Vector2(560, 580)])
	# A guarda distante sobe no impacto para liberar a passagem do soco próximo.
	# Só gira a inserção; não fecha a dobra, desloca a mão ou alonga o braço.
	_trilha(soco, novo_distante.ombro, "rotation", [deg_to_rad(135), deg_to_rad(135), deg_to_rad(185), deg_to_rad(135), deg_to_rad(135)])
	# Compensar os giros corporais adicionais mantém a direção do braço aceito.
	var proximo: int = soco.find_track(NodePath(str(modelo.get_path_to(braco_novo.ombro)) + ":rotation"), Animation.TYPE_VALUE)
	var compensacoes: Array[float] = [0.0, 7.0, -5.0, -.5, 0.0]
	for chave: int in range(compensacoes.size()):
		soco.track_set_key_value(proximo, chave, float(soco.track_get_key_value(proximo, chave)) + deg_to_rad(compensacoes[chave]))
	biblioteca.add_animation(&"corpo_soco", soco)
	modelo.animacao.remove_animation_library(&"")
	modelo.animacao.add_animation_library(&"", biblioteca)
	modelo.animacao.clear_caches()


func pose_corpo(indice: int) -> void:
	var pose: int = 0 if corpo_reduzido else clampi(indice, 0, 4)
	inspecionar(&"corpo_soco", TEMPOS[pose])
	estado_animacao = ["guarda", "preparo", "impacto", "retorno", "guarda"][pose]
	if is_instance_valid(guias_corpo):
		guias_corpo.queue_redraw()


func socar_corpo() -> void:
	_parar_feedback()
	if corpo_reduzido:
		pose_corpo(0)
		estado_animacao = "golpe / reduzido"
		_flash(Color(.75, 1, 1), "corpo")
		return
	estado_animacao = "soco corporal"
	modelo.animacao.play_with_capture(&"corpo_soco", .1, 0, 1, false, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)


func _terminar_corpo(nome: StringName) -> void:
	if nome == &"corpo_soco":
		pose_corpo(0)


func reduzir_corpo(ativo: bool) -> void:
	corpo_reduzido = ativo
	pose_corpo(0)


func _process(_delta: float) -> void:
	if is_instance_valid(guias_corpo) and novo_distante.mostrar_marcos:
		guias_corpo.queue_redraw()
		braco_novo.guias.queue_redraw()
		novo_distante.guias.queue_redraw()


func _desenhar_corpo() -> void:
	if not novo_distante.mostrar_marcos:
		return
	var pontos := PackedVector2Array()
	for osso: Bone2D in [modelo.pelve, abdomen, modelo.tronco, cabeca]:
		var ponto: Vector2 = modelo.to_local(osso.global_position)
		pontos.append(ponto)
		guias_corpo.draw_circle(ponto, 4, Color("efce75"))
	guias_corpo.draw_polyline(pontos, Color("efce75"), 1.5, true)
	for par: Array in [[modelo.joelho_tras, modelo.sola_tras], [modelo.joelho_frente, modelo.sola_frente]]:
		guias_corpo.draw_line(modelo.to_local(par[0].global_position), modelo.to_local(par[1].global_position), Color("69d6e3"), 1, true)
