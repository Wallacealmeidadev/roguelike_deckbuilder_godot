class_name VegaAcabamentoProximo
extends VegaCombateNativo
## Variante visual isolada: acabamento e folga da guarda, sem alterar comprimentos/Combo.

const ATLAS: Texture2D = preload("res://vega_animada/rig_nativo_v2/acabamento_proximo/camadas_01.png")
const ORIGINAL: Texture2D = preload("res://vega_animada/braco_v2/camadas.png")
const ATLAS_INTERNO: Texture2D = preload("res://vega_animada/rig_nativo_v2/acabamento_proximo/camadas_internas_01.png")
const PUNHOS: Texture2D = preload("res://vega_animada/rig_nativo_v2/acabamento_proximo/punhos_pareados_01.png")
const PUNHO_DORSAL: Texture2D = preload("res://vega_animada/rig_nativo_v2/acabamento_proximo/punhos_pareados_02.png")
const ABERTURA_COTOVELO: float = -23.0 * PI / 180.0
const MARGEM_BICEPS: Vector2 = Vector2(12, 8)
const REGIAO_OMBRO: Rect2 = Rect2(180, 140, 100, 100)
const RECORTE_OMBRO: Rect2 = Rect2(1415, 78, 320, 340)

@export var mostrar_acabamento: bool = true
@export var mostrar_ombro: bool = true
@export var corrigir_braco_distante: bool = true
@export var suavizar_texturas: bool = true
@export var fechar_punhos: bool = true
@export var refinar_juntas: bool = true
var remendo_ombro: Polygon2D


func _ready() -> void:
	super._ready()
	if suavizar_texturas:
		# Linear sozinho não filtra bem a arte reduzida: usar níveis de mipmap.
		for parte: CanvasItem in [modelo, modelo.braco_original, modelo.braco_distante]:
			parte.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if corrigir_braco_distante:
		_aplicar_face_interna()
		_aplicar_punhos_pareados()
	if refinar_juntas:
		_refinar_cotovelos()
	if not mostrar_acabamento:
		return
	var proporcao: Vector2 = ATLAS.get_size() / ORIGINAL.get_size()
	# As duas primeiras malhas são do braço próximo. Geometria e Combo intactos.
	for indice: int in range(2):
		var malha: Polygon2D = modelo.malhas[indice]
		malha.texture = ATLAS
		var uv_novo: PackedVector2Array = malha.uv.duplicate()
		for i: int in uv_novo.size():
			uv_novo[i] *= proporcao
		malha.uv = uv_novo
	var braco: BracoNativoV2 = modelo.braco_original
	for nome: String in ["FibraJunta", "Junta", "PlacaA", "PlacaB", "PlacaC"]:
		_substituir_sprite(braco.cotovelo.get_node("Arte/" + nome) as Sprite2D, proporcao)
	for no: Polygon2D in [braco.ombro.get_node("NucleoOmbro"), braco.cotovelo.get_node("Arte/NucleoCotovelo"),
		braco.punho.get_node("NucleoPunho"), braco.punho.get_node("Mao/MioloLuva")]:
		no.texture = ATLAS
		var uv_novo: PackedVector2Array = no.uv.duplicate()
		for i: int in uv_novo.size():
			uv_novo[i] *= proporcao
		no.uv = uv_novo
	if mostrar_ombro:
		_preparar_ombro(proporcao)


func _substituir_sprite(sprite: Sprite2D, proporcao: Vector2, textura: Texture2D = ATLAS) -> void:
	var fonte: AtlasTexture = sprite.texture as AtlasTexture
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = textura
	atlas.region = Rect2(fonte.region.position * proporcao, fonte.region.size * proporcao)
	sprite.texture = atlas
	# Compensa apenas a resolução do arquivo; mesmas dimensões locais desenhadas.
	sprite.scale /= proporcao


func _ajustar_repouso(biblioteca: AnimationLibrary) -> void:
	if corrigir_braco_distante:
		# Respiração era compartilhada; editar somente uma cópia desta instância.
		var respirar: Animation = biblioteca.get_animation(&"respirar").duplicate(true) as Animation
		biblioteca.remove_animation(&"respirar")
		biblioteca.add_animation(&"respirar", respirar)
		for chave: int in respirar.track_get_key_count(9):
			respirar.track_set_key_value(9, chave, float(respirar.track_get_key_value(9, chave)) + ABERTURA_COTOVELO)
		for nome: StringName in [&"soco", &"soco_distante", &"dano"]:
			var clipe: Animation = biblioteca.get_animation(nome)
			for chave: int in range(1, clipe.track_get_key_count(9) - 1):
				# Só a dobra da guarda/preparo/retorno: extensão distante fica intacta.
				var angulo: float = clipe.track_get_key_value(9, chave)
				if angulo > PI / 2:
					clipe.track_set_key_value(9, chave, angulo + ABERTURA_COTOVELO)
	# Mesma guarda no reset/reduzido e nos dois extremos de todas as ações.
	super._ajustar_repouso(biblioteca)


func _aplicar_face_interna() -> void:
	var proporcao: Vector2 = ATLAS_INTERNO.get_size() / ORIGINAL.get_size()
	for indice: int in range(2, 4):
		var malha: Polygon2D = modelo.malhas[indice]
		malha.texture = ATLAS_INTERNO
		var uv_novo: PackedVector2Array = malha.uv.duplicate()
		for i: int in uv_novo.size():
			uv_novo[i] *= proporcao
		malha.uv = uv_novo
	_completar_borda_biceps(proporcao)
	var braco: BracoNativoV2 = modelo.braco_distante
	# Profundidade por sobreposição/projeção; não escurecer a palma como outra luva.
	braco.modulate = Color(.94, .96, 1, 1)
	for nome: String in ["FibraJunta", "Junta", "PlacaA", "PlacaB", "PlacaC"]:
		_substituir_sprite(braco.cotovelo.get_node("Arte/" + nome) as Sprite2D, proporcao, ATLAS_INTERNO)
	for no: Polygon2D in [braco.ombro.get_node("NucleoOmbro"), braco.cotovelo.get_node("Arte/NucleoCotovelo"), braco.punho.get_node("NucleoPunho")]:
		no.texture = ATLAS_INTERNO
		var uv_novo: PackedVector2Array = no.uv.duplicate()
		for i: int in uv_novo.size():
			uv_novo[i] *= proporcao
		no.uv = uv_novo


func _completar_borda_biceps(proporcao: Vector2) -> void:
	# A nova pintura ultrapassa o antigo Rect2(122,499,298,358).
	# Abrir só a borda da malha/UV; pontos interiores e pivôs não se deslocam.
	var malha: Polygon2D = modelo.malhas[2]
	var pontos: PackedVector2Array = modelo.bases[2].duplicate()
	var uv_novo: PackedVector2Array = malha.uv.duplicate()
	for i: int in pontos.size():
		var anterior: Vector2 = pontos[i]
		if is_zero_approx(anterior.x):
			pontos[i].x -= MARGEM_BICEPS.x
		elif is_equal_approx(anterior.x, 298):
			pontos[i].x += MARGEM_BICEPS.x
		if is_zero_approx(anterior.y):
			pontos[i].y -= MARGEM_BICEPS.y
		elif is_equal_approx(anterior.y, 358):
			pontos[i].y += MARGEM_BICEPS.y
		uv_novo[i] += (pontos[i] - anterior) * proporcao
	modelo.bases[2] = pontos
	malha.polygon = pontos
	malha.uv = uv_novo


func _aplicar_punhos_pareados() -> void:
	# Dois recortes do mesmo desenho, registrados pelo centro real do soquete.
	# A reflexão do braço distante já pertence ao rig: não refletir a palma de novo.
	var proporcao: Vector2 = PUNHOS.get_size() / Vector2(1774, 887)
	var recortes: Array[Rect2] = [Rect2(240, 60, 590, 820), Rect2(930, 60, 580, 820)]
	var soquetes: Array[Vector2] = [Vector2(305, 760), Vector2(283, 760)]
	for lado: int in range(2):
		var braco: BracoNativoV2 = modelo.braco_original if lado == 0 else modelo.braco_distante
		var mao: Sprite2D = braco.punho.get_node("Mao") as Sprite2D
		var textura: AtlasTexture = AtlasTexture.new()
		# Revisão 02 só no dorso: a palma permanece exatamente no recorte anterior.
		textura.atlas = PUNHO_DORSAL if lado == 0 else PUNHOS
		textura.region = Rect2(recortes[lado].position * proporcao, recortes[lado].size * proporcao)
		mao.texture = textura
		mao.rotation = PI / 2
		mao.scale = Vector2.ONE * .13 / proporcao
		mao.offset = -soquetes[lado] * proporcao
		mao.get_node("MioloLuva").hide()
		if fechar_punhos:
			_fechar_soquete(braco, lado)


func _fechar_soquete(braco: BracoNativoV2, lado: int) -> void:
	# Manga curta atrás do aro: acompanha o mesmo osso, sem compensação por frame.
	var manga: Polygon2D = Polygon2D.new()
	manga.name = "ConectorPunho"
	manga.z_index = -2
	manga.polygon = PackedVector2Array([
		Vector2(-12, -8), Vector2(10, -22), Vector2(22, -18),
		Vector2(23, -5), Vector2(-5, 9), Vector2(-12, 7)])
	if refinar_juntas:
		manga.polygon = PackedVector2Array([
			Vector2(-12, -6), Vector2(-10, -8), Vector2(-2, -11), Vector2(4, -12),
			Vector2(8, -11), Vector2(10, -8), Vector2(10, -4), Vector2(6, 0),
			Vector2(-2, 6), Vector2(-9, 8), Vector2(-12, 5)])
		# O núcleo antigo duplicava o volume da manga, projetando-se além do aro.
		braco.punho.get_node("NucleoPunho").hide()
	_texturizar_conector(manga, lado)
	braco.punho.add_child(manga)
	# O interior escuro do soquete é opaco no PNG. Uma peça só atrás não o cobre.
	# Este pequeno encaixe ocupa só a abertura, preservando a borda metálica/ciano.
	var encaixe: Polygon2D = Polygon2D.new()
	encaixe.name = "InteriorSoquete"
	encaixe.z_index = 1
	var pontos: PackedVector2Array = PackedVector2Array()
	for i: int in range(24):
		var angulo: float = TAU * i / 24
		pontos.append(Vector2(-7.7, .4) + Vector2(cos(angulo) * 3.6, sin(angulo) * 11.2))
	encaixe.polygon = pontos
	_texturizar_conector(encaixe, lado)
	braco.punho.add_child(encaixe)
	if refinar_juntas:
		_recortar_interior(encaixe, braco.punho.get_node("Mao") as Sprite2D)


func _recortar_interior(encaixe: Polygon2D, mao: Sprite2D) -> void:
	var atlas: AtlasTexture = mao.texture as AtlasTexture
	var inversa: Transform2D = mao.transform.affine_inverse()
	var material_recorte: ShaderMaterial = ShaderMaterial.new()
	material_recorte.shader = preload("res://vega_animada/rig_nativo_v2/acabamento_proximo/interior_aro.gdshader")
	material_recorte.set_shader_parameter("aro", atlas.atlas)
	material_recorte.set_shader_parameter("tamanho_aro", atlas.atlas.get_size())
	material_recorte.set_shader_parameter("origem_aro", atlas.region.position + inversa.origin - mao.offset)
	material_recorte.set_shader_parameter("eixo_x", inversa.x)
	material_recorte.set_shader_parameter("eixo_y", inversa.y)
	encaixe.material = material_recorte


func _refinar_cotovelos() -> void:
	for braco: BracoNativoV2 in [modelo.braco_original, modelo.braco_distante]:
		# Substitui o remendo retangular por miolo contido sob a junta existente.
		braco.cotovelo.get_node("Arte/FibraJunta").hide()
		var miolo: Polygon2D = braco.cotovelo.get_node("Arte/NucleoCotovelo") as Polygon2D
		var pontos: PackedVector2Array = PackedVector2Array()
		var uv_fibra: PackedVector2Array = PackedVector2Array()
		for i: int in range(24):
			var angulo: float = TAU * i / 24
			var local: Vector2 = Vector2(cos(angulo) * 41, sin(angulo) * 17)
			pontos.append(Vector2(8.5, 226) + local)
			uv_fibra.append(Vector2(230 + local.x * .45, 200 + local.y))
		miolo.polygon = pontos
		miolo.uv = uv_fibra
		miolo.color = Color(.82, .84, .88, 1)


func _texturizar_conector(peca: Polygon2D, lado: int) -> void:
	peca.texture = ATLAS if lado == 0 else ATLAS_INTERNO
	peca.color = Color(.9, .92, .96, 1)
	var uv_fibra: PackedVector2Array = PackedVector2Array()
	for ponto: Vector2 in peca.polygon:
		# Amostra opaca do feixe existente; fibra longitudinal, não prata sobre o aro.
		uv_fibra.append(Vector2(230 + ponto.y * 1.2, 200 + (ponto.x + 8) * 2.3))
	peca.uv = uv_fibra


func _preparar_ombro(proporcao: Vector2) -> void:
	# Mesmos vértices/pesos da pele: acompanha deltoide/clavícula na GPU.
	remendo_ombro = modelo.pele.duplicate() as Polygon2D
	remendo_ombro.name = "AcabamentoOmbroProximo"
	remendo_ombro.z_index = 1
	remendo_ombro.texture = ATLAS
	# A pintura nova nunca aumenta a silhueta nem cobre o tecido/colar original.
	var material_pele: ShaderMaterial = ShaderMaterial.new()
	material_pele.shader = preload("res://vega_animada/rig_nativo_v2/acabamento_proximo/ombro.gdshader")
	material_pele.set_shader_parameter("pele_original", modelo.pele.texture)
	material_pele.set_shader_parameter("tamanho_atlas", ATLAS.get_size())
	material_pele.set_shader_parameter("tamanho_pele", modelo.pele.texture.get_size())
	material_pele.set_shader_parameter("regiao", Vector4(REGIAO_OMBRO.position.x, REGIAO_OMBRO.position.y, REGIAO_OMBRO.size.x, REGIAO_OMBRO.size.y))
	var recorte: Rect2 = Rect2(RECORTE_OMBRO.position * proporcao, RECORTE_OMBRO.size * proporcao)
	material_pele.set_shader_parameter("recorte", Vector4(recorte.position.x, recorte.position.y, recorte.size.x, recorte.size.y))
	remendo_ombro.material = material_pele
	var uv_novo: PackedVector2Array = PackedVector2Array()
	for ponto: Vector2 in remendo_ombro.polygon:
		var local: Vector2 = (ponto - REGIAO_OMBRO.position) / REGIAO_OMBRO.size
		uv_novo.append((RECORTE_OMBRO.position + local * RECORTE_OMBRO.size) * proporcao)
	remendo_ombro.uv = uv_novo
	var faces: Array[PackedInt32Array] = []
	for face: PackedInt32Array in modelo.pele.polygons:
		var centro: Vector2 = Vector2.ZERO
		for indice: int in face:
			centro += modelo.pele.polygon[indice]
		centro /= face.size()
		if REGIAO_OMBRO.has_point(centro):
			faces.append(face)
	remendo_ombro.polygons = faces
	modelo.add_child(remendo_ombro)
