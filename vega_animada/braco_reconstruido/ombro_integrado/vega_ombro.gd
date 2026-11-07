class_name VegaOmbroIntegradoV1
extends VegaMovimentoBracoV1
## Pele participa da rotação da prótese. Metal rígido e trajetória preservados.

const REGIAO_PESOS := Rect2(170, 145, 110, 110)
@export_range(0.0, .5, .01) var participacao_deltoide: float = .28
@export_range(0.0, .5, .01) var reforco_pele: float = .30
var vertices_ajustados: int = 0
var pesos_originais: Array[PackedFloat32Array] = []
var vertices_originais := PackedVector2Array()


func _ready() -> void:
	super._ready()
	# Capturar o vínculo na guarda aprovada antes de trocar pesos/rotações.
	inspecionar(&"respirar", 0)
	_repesar_ombro()
	_distribuir_rotacao()
	reiniciar()


func _repesar_ombro() -> void:
	var pele: Polygon2D = modelo.pele
	vertices_originais = pele.polygon.duplicate()
	var novos: Array[PackedFloat32Array] = []
	var clavicula: int = -1
	var deltoide: int = -1
	var matrizes: Array[Transform2D] = []
	for indice: int in range(pele.get_bone_count()):
		pesos_originais.append(pele.get_bone_weights(indice).duplicate())
		novos.append(pesos_originais[indice].duplicate())
		var caminho: NodePath = pele.get_bone_path(indice)
		var osso: Bone2D = modelo.esqueleto.get_node(caminho) as Bone2D
		if osso == modelo.clavicula:
			clavicula = indice
		elif osso == modelo.deltoide:
			deltoide = indice
		var atual: Transform2D = modelo.esqueleto.global_transform.affine_inverse() * osso.global_transform
		matrizes.append(atual * osso.get_skeleton_rest().affine_inverse())
	assert(clavicula >= 0 and deltoide >= 0, "Pesos próximos precisam de clavícula e deltoide")
	var pontos: PackedVector2Array = vertices_originais.duplicate()
	for indice: int in range(pontos.size()):
		var ponto: Vector2 = vertices_originais[indice]
		if not REGIAO_PESOS.has_point(ponto):
			continue
		var raio: float = ((ponto - Vector2(220, 198)) / Vector2(55, 55)).length()
		var mascara: float = 1.0 - smoothstep(.35, 1.0, raio)
		var transferencia: float = minf(novos[clavicula][indice], reforco_pele * mascara)
		if transferencia <= .00001:
			continue
		novos[clavicula][indice] -= transferencia
		novos[deltoide][indice] += transferencia
		# Rebind local: trocar pesos não pode modificar a silhueta da guarda.
		var antes: Transform2D = _mistura(matrizes, pesos_originais, indice)
		var depois: Transform2D = _mistura(matrizes, novos, indice)
		pontos[indice] = depois.affine_inverse() * (antes * ponto)
		vertices_ajustados += 1
	for malha: Polygon2D in [pele, remendo_ombro]:
		malha.polygon = pontos.duplicate()
		for indice: int in range(novos.size()):
			malha.set_bone_weights(indice, novos[indice])


func _mistura(matrizes: Array[Transform2D], pesos: Array[PackedFloat32Array], vertice: int) -> Transform2D:
	var x := Vector2.ZERO
	var y := Vector2.ZERO
	var origem := Vector2.ZERO
	for indice: int in range(matrizes.size()):
		x += matrizes[indice].x * pesos[indice][vertice]
		y += matrizes[indice].y * pesos[indice][vertice]
		origem += matrizes[indice].origin * pesos[indice][vertice]
	return Transform2D(x, y, origem)


func _distribuir_rotacao() -> void:
	var biblioteca: AnimationLibrary = modelo.animacao.get_animation_library(&"").duplicate(true) as AnimationLibrary
	var caminho_deltoide := NodePath(str(modelo.get_path_to(modelo.deltoide)) + ":rotation")
	var caminho_braco := NodePath(str(modelo.get_path_to(braco_novo.ombro)) + ":rotation")
	var guarda: float = deg_to_rad(angulo_ombro)
	for nome: StringName in biblioteca.get_animation_list():
		var clipe: Animation = biblioteca.get_animation(nome)
		var deltoide: int = clipe.find_track(caminho_deltoide, Animation.TYPE_VALUE)
		var braco: int = clipe.find_track(caminho_braco, Animation.TYPE_VALUE)
		if deltoide < 0 or braco < 0:
			continue
		assert(clipe.track_get_key_count(deltoide) == clipe.track_get_key_count(braco))
		for chave: int in range(clipe.track_get_key_count(braco)):
			assert(is_equal_approx(clipe.track_get_key_time(deltoide, chave), clipe.track_get_key_time(braco, chave)))
			var rotacao: float = float(clipe.track_get_key_value(braco, chave))
			var acrescimo: float = (rotacao - guarda) * participacao_deltoide
			clipe.track_set_key_value(deltoide, chave, float(clipe.track_get_key_value(deltoide, chave)) + acrescimo)
			clipe.track_set_key_value(braco, chave, rotacao - acrescimo)
	modelo.animacao.remove_animation_library(&"")
	modelo.animacao.add_animation_library(&"", biblioteca)
	modelo.animacao.clear_caches()
