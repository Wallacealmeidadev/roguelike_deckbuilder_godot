extends SceneTree

const NOVA: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/acabamento_gola/vega_gola.tscn")
const BASE: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/vega_corpo.tscn")
var falhas: int = 0
var poses: int = 0
var pixels_locais: int = 0
var pixels_externos: int = 0
var alfas_diferentes: int = 0
var poses_gpu: int = 0
var pixels_base_diferentes: int = 0


func _initialize() -> void:
	_executar.call_deferred()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		if falhas <= 12:
			push_error("GOLA: " + mensagem)


func _executar() -> void:
	var nova: VegaAcabamentoGolaV1 = NOVA.instantiate() as VegaAcabamentoGolaV1
	var base: VegaCorpoArticuladoV1 = BASE.instantiate() as VegaCorpoArticuladoV1
	for atriz: VegaCorpoArticuladoV1 in [base, nova]:
		atriz.size = Vector2(650, 850)
		root.add_child(atriz)
	var a: Polygon2D = nova.modelo.pele
	var b: Polygon2D = base.modelo.pele
	_verificar(a.polygon == b.polygon and a.uv == b.uv and a.polygons == b.polygons and a.texture == b.texture,
		"malha, UV, faces e fonte corporal originais")
	_verificar(nova.RETOQUE.get_size() == b.texture.get_size(), "atlas no mesmo registro/dimensões")
	_verificar(b.material == null and a.material == nova.material_gola, "material privado, base preservada")
	for indice: int in range(a.get_bone_count()):
		_verificar(a.get_bone_path(indice) == b.get_bone_path(indice)
			and a.get_bone_weights(indice) == b.get_bone_weights(indice), "mesmos pesos e ossos")
	for par: Array in [[nova.braco_novo, base.braco_novo], [nova.novo_distante, base.novo_distante]]:
		for indice: int in range(3):
			var p: Polygon2D = par[0].segmentos[indice]
			var q: Polygon2D = par[1].segmentos[indice]
			var mesmo_material: bool = p.material == q.material
			if p.material is ShaderMaterial and q.material is ShaderMaterial:
				mesmo_material = (p.material as ShaderMaterial).shader == (q.material as ShaderMaterial).shader
			_verificar(p.texture == q.texture and p.uv == q.uv and p.polygon == q.polygon
				and p.transform == q.transform and mesmo_material,
				"próteses, mãos e seus materiais preservados")
	_verificar_clipes(nova, base)
	for quadro: int in range(57):
		for atriz: VegaCorpoArticuladoV1 in [base, nova]:
			atriz.inspecionar(&"corpo_soco", quadro / 100.0)
		for indice: int in range(a.get_bone_count()):
			var osso_a: Bone2D = nova.modelo.esqueleto.get_node(a.get_bone_path(indice)) as Bone2D
			var osso_b: Bone2D = base.modelo.esqueleto.get_node(b.get_bone_path(indice)) as Bone2D
			_verificar(osso_a.global_transform.is_equal_approx(osso_b.global_transform), "mesmo movimento corporal")
		_verificar(nova.braco_novo.punho.global_transform.is_equal_approx(base.braco_novo.punho.global_transform)
			and nova.novo_distante.punho.global_transform.is_equal_approx(base.novo_distante.punho.global_transform),
			"mesmo movimento das mãos")
		poses += 1
	var punho: Transform2D = nova.braco_novo.punho.global_transform
	nova.definir_acabamento(-2)
	_verificar(nova.intensidade_gola == 0, "comparação A desliga pintura")
	nova.definir_acabamento(2)
	_verificar(nova.intensidade_gola == 1 and nova.braco_novo.punho.global_transform.is_equal_approx(punho),
		"comparação não reposiciona o rig")
	if DisplayServer.get_name() != "headless":
		await _verificar_gpu(nova, base)
	nova.socar_corpo()
	nova.modelo.animacao.advance(.12)
	punho = nova.braco_novo.punho.global_transform
	nova.socar_corpo()
	_verificar(punho.is_equal_approx(nova.braco_novo.punho.global_transform), "interrupção preservada")
	nova.modelo.animacao.advance(.6)
	_verificar(nova.estado_animacao == "guarda", "retorno preservado")
	nova.reduzir_corpo(true)
	punho = nova.braco_novo.punho.global_transform
	nova.socar_corpo()
	_verificar(punho.is_equal_approx(nova.braco_novo.punho.global_transform)
		and not nova.modelo.animacao.is_playing(), "reduzido preservado")
	_verificar_preview()
	nova.free()
	base.free()
	await process_frame
	print("Gola: ", falhas, " falhas; ", poses, " poses; atlas RGB local ", pixels_locais,
		" / externo ", pixels_externos, "; alfa alterado ", alfas_diferentes, "; poses GPU ", poses_gpu,
		"; A/base RGB divergente ", pixels_base_diferentes)
	quit(0 if falhas == 0 else 1)


func _verificar_clipes(nova: VegaCorpoArticuladoV1, base: VegaCorpoArticuladoV1) -> void:
	for nome: StringName in base.modelo.animacao.get_animation_list():
		var a: Animation = nova.modelo.animacao.get_animation(nome)
		var b: Animation = base.modelo.animacao.get_animation(nome)
		_verificar(a.length == b.length and a.loop_mode == b.loop_mode and a.get_track_count() == b.get_track_count(), "mesmos clipes")
		for trilha: int in range(b.get_track_count()):
			_verificar(a.track_get_path(trilha) == b.track_get_path(trilha)
				and a.track_get_key_count(trilha) == b.track_get_key_count(trilha), "mesmas trilhas")
			for chave: int in range(b.track_get_key_count(trilha)):
				_verificar(a.track_get_key_time(trilha, chave) == b.track_get_key_time(trilha, chave)
					and a.track_get_key_value(trilha, chave) == b.track_get_key_value(trilha, chave), "mesmas chaves e tempos")


func _verificar_gpu(nova: VegaAcabamentoGolaV1, base: VegaCorpoArticuladoV1) -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(nova.modelo.pele.texture.get_size())
	viewport.transparent_bg = true
	viewport.world_2d = World2D.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var sprite := Sprite2D.new()
	sprite.texture = nova.modelo.pele.texture
	sprite.position = Vector2(viewport.size) * .5
	sprite.material = nova.material_gola
	viewport.add_child(sprite)
	var antes: Image = await _renderizar(viewport, nova, 0)
	var depois: Image = await _renderizar(viewport, nova, 1)
	for y: int in range(antes.get_height()):
		for x: int in range(antes.get_width()):
			var a: Color = antes.get_pixel(x, y)
			var b: Color = depois.get_pixel(x, y)
			if a.a != b.a:
				alfas_diferentes += 1
			if a.a > 0 and a != b:
				if Geometry2D.is_point_in_polygon(Vector2(x + .5, y + .5), PackedVector2Array(nova.CONTORNO)):
					pixels_locais += 1
				else:
					pixels_externos += 1
	_verificar(pixels_locais > 500 and pixels_externos == 0 and alfas_diferentes == 0,
		"GPU: somente RGB dentro do pescoço/gola; face, roupa, alfa e demais sprites intactos")
	viewport.free()
	var desenho: SubViewport = nova.composicao.get_node("Desenho") as SubViewport
	var desenho_base: SubViewport = base.composicao.get_node("Desenho") as SubViewport
	for indice: int in range(3):
		nova.pose_corpo(indice)
		base.pose_corpo(indice)
		antes = await _renderizar(desenho, nova, 0)
		var referencia: Image = desenho_base.get_texture().get_image()
		depois = await _renderizar(desenho, nova, 1)
		var alterados: int = 0
		for y: int in range(antes.get_height()):
			for x: int in range(antes.get_width()):
				var a: Color = antes.get_pixel(x, y)
				var b: Color = depois.get_pixel(x, y)
				var c: Color = referencia.get_pixel(x, y)
				if a.a != c.a or (a.a > 0 and a != c):
					pixels_base_diferentes += 1
				if a.a != b.a:
					alfas_diferentes += 1
				if a.a > 0 and a != b:
					alterados += 1
		_verificar(alterados > 100 and alfas_diferentes == 0, "GPU: retoque presente nas três poses sem abrir buracos")
		poses_gpu += 1
	_verificar(pixels_base_diferentes == 0, "GPU: desligar acabamento reproduz a base sem material, inclusive cor/transparência")


func _renderizar(viewport: SubViewport, nova: VegaAcabamentoGolaV1, intensidade: float) -> Image:
	nova.definir_acabamento(intensidade)
	await process_frame
	await RenderingServer.frame_post_draw
	return viewport.get_texture().get_image()


func _verificar_preview() -> void:
	var cena: PackedScene = load("res://prototipos/vega_2d/corpo_articulado/acabamento_gola/preview.tscn") as PackedScene
	var preview: Node2D = cena.instantiate() as Node2D
	root.add_child(preview)
	for tecla: Key in [KEY_1, KEY_2, KEY_3, KEY_A, KEY_A, KEY_Z, KEY_Z, KEY_L, KEY_O, KEY_R, KEY_SPACE]:
		var evento := InputEventKey.new()
		evento.keycode = tecla
		evento.pressed = true
		preview._unhandled_key_input(evento)
	_verificar(preview.candidata.intensidade_gola == 1 and preview.anterior.intensidade_gola == 0,
		"A/B independente; antes permanece original")
	_verificar(preview.ampliado and preview.candidata.corpo_reduzido, "atalhos de inspeção/reduzido")
	preview.free()
