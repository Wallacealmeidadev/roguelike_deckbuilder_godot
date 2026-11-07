extends "res://tests/test_gola_vega.gd"

const INTEGRADA: PackedScene = preload("res://vega_animada/corpo_articulado/integracao_tronco/vega_integracao.tscn")
const ANTERIOR: PackedScene = preload("res://vega_animada/corpo_articulado/acabamento_gola/vega_gola.tscn")
var pixels_pintura: int = 0
var pixels_fora: int = 0
var pixels_alfa: int = 0
var pixels_comparacao: int = 0
var pixels_sombra: Array[int] = []
var pontos_protegidos: int = 0
var quadros_seguidos: int = 0


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		if falhas <= 12:
			push_error("INTEGRAÇÃO TRONCO: " + mensagem)


func _executar() -> void:
	var nova: VegaIntegracaoTroncoV1 = INTEGRADA.instantiate() as VegaIntegracaoTroncoV1
	var base: VegaAcabamentoGolaV1 = ANTERIOR.instantiate() as VegaAcabamentoGolaV1
	for atriz: VegaCorpoArticuladoV1 in [base, nova]:
		atriz.size = Vector2(650, 850)
		root.add_child(atriz)
	var a: Polygon2D = nova.modelo.pele
	var b: Polygon2D = base.modelo.pele
	_verificar(a.polygon == b.polygon and a.uv == b.uv and a.polygons == b.polygons and a.texture == b.texture,
		"mesma superfície, UVs, fonte e silhueta")
	_verificar(nova.PINTURA.get_size() == b.texture.get_size(), "registro/dimensões do atlas")
	for indice: int in range(a.get_bone_count()):
		_verificar(a.get_bone_path(indice) == b.get_bone_path(indice)
			and a.get_bone_weights(indice) == b.get_bone_weights(indice), "pesos/ossos intactos")
	for par: Array in [[nova.braco_novo, base.braco_novo], [nova.novo_distante, base.novo_distante]]:
		for indice: int in range(3):
			var p: Polygon2D = par[0].segmentos[indice]
			var q: Polygon2D = par[1].segmentos[indice]
			_verificar(p.texture == q.texture and p.uv == q.uv and p.polygon == q.polygon
				and p.transform == q.transform, "próteses, mãos e proporções preservadas")
	_verificar_clipes(nova, base)
	for quadro: int in range(57):
		for atriz: VegaCorpoArticuladoV1 in [nova, base]:
			atriz.inspecionar(&"corpo_soco", quadro / 100.0)
		for indice: int in range(a.get_bone_count()):
			var osso_a: Bone2D = nova.modelo.esqueleto.get_node(a.get_bone_path(indice)) as Bone2D
			var osso_b: Bone2D = base.modelo.esqueleto.get_node(b.get_bone_path(indice)) as Bone2D
			_verificar(osso_a.global_transform.is_equal_approx(osso_b.global_transform), "mesmo esforço corporal")
		_verificar(nova.braco_novo.punho.global_transform.is_equal_approx(base.braco_novo.punho.global_transform)
			and nova.novo_distante.punho.global_transform.is_equal_approx(base.novo_distante.punho.global_transform), "mesmo movimento das mãos")
		nova.sincronizar_sombra()
		var segmento: Vector4 = nova.material_gola.get_shader_parameter(&"antebraco")
		_verificar(Vector2(segmento.x, segmento.y).distance_to(nova.braco_novo.cotovelo.get_global_transform_with_canvas().origin) < .001
			and Vector2(segmento.z, segmento.w).distance_to(nova.braco_novo.punho.get_global_transform_with_canvas().origin) < .001,
			"sombra lê a cadeia, sem estimar pose ou mover juntas")
		poses += 1
	nova.definir_integracao(-1)
	_verificar(nova.intensidade_integracao == 0 and nova.remendo_ombro.self_modulate.a == 1
		and float(nova.material_ombro.get_shader_parameter(&"integracao")) == 0, "A restaura pintura anterior sem alterar cobertura")
	nova.definir_integracao(1)
	_verificar(nova.remendo_ombro.self_modulate.a == 1 and float(nova.material_ombro.get_shader_parameter(&"integracao")) == 1,
		"ombro recebe novo RGB sem sumir ou mudar geometria")
	if DisplayServer.get_name() != "headless":
		await _testar_atlas(nova)
		await _testar_poses(nova, base)
		await _testar_seguimento(nova)
	nova.socar_corpo()
	nova.modelo.animacao.advance(.12)
	var punho: Transform2D = nova.braco_novo.punho.global_transform
	nova.definir_integracao(0)
	nova.definir_integracao(1)
	nova.socar_corpo()
	_verificar(punho.is_equal_approx(nova.braco_novo.punho.global_transform), "interrupção/A sem salto")
	nova.modelo.animacao.advance(.6)
	_verificar(nova.estado_animacao == "guarda", "retorno preservado")
	nova.reduzir_corpo(true)
	punho = nova.braco_novo.punho.global_transform
	nova.socar_corpo()
	_verificar(punho.is_equal_approx(nova.braco_novo.punho.global_transform) and not nova.modelo.animacao.is_playing(), "reduzido preservado")
	_testar_preview()
	nova.free()
	base.free()
	await process_frame
	print("Integração tronco: ", falhas, " falhas; ", poses, " poses; atlas RGB local/fora ", pixels_pintura, "/", pixels_fora,
		"; alfa alterado ", pixels_alfa, "; A/base divergente ", pixels_comparacao, "; pixels sombra por pose ", pixels_sombra,
		"; pontos protegidos ", pontos_protegidos, "; quadros seguidos automaticamente ", quadros_seguidos)
	quit(0 if falhas == 0 else 1)


func _testar_atlas(nova: VegaIntegracaoTroncoV1) -> void:
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
	nova.definir_sombra(0)
	var antes: Image = await _render_integracao(viewport, nova, 0)
	var depois: Image = await _render_integracao(viewport, nova, 1)
	var contorno := PackedVector2Array(nova.CONTORNO_TRONCO)
	for y: int in range(antes.get_height()):
		for x: int in range(antes.get_width()):
			var a: Color = antes.get_pixel(x, y)
			var b: Color = depois.get_pixel(x, y)
			if a.a != b.a:
				pixels_alfa += 1
			if a.a > 0 and a != b:
				if Geometry2D.is_point_in_polygon(Vector2(x + .5, y + .5), contorno):
					pixels_pintura += 1
				else:
					pixels_fora += 1
	_verificar(pixels_pintura > 15000 and pixels_fora == 0 and pixels_alfa == 0, "pintura ampla local; restante do atlas/alfa intactos")
	viewport.free()


func _testar_poses(nova: VegaIntegracaoTroncoV1, base: VegaAcabamentoGolaV1) -> void:
	var viewport: SubViewport = nova.composicao.get_node("Desenho") as SubViewport
	var viewport_base: SubViewport = base.composicao.get_node("Desenho") as SubViewport
	for indice: int in range(3):
		nova.pose_corpo(indice)
		base.pose_corpo(indice)
		var antes: Image = await _render_integracao(viewport, nova, 0)
		var referencia: Image = viewport_base.get_texture().get_image()
		nova.definir_sombra(0)
		var pintura: Image = await _render_integracao(viewport, nova, 1)
		nova.definir_sombra(.32)
		var contato: Image = await _render_integracao(viewport, nova, 1)
		var sombra: int = 0
		var clareados: int = 0
		for y: int in range(antes.get_height()):
			for x: int in range(antes.get_width()):
				var a: Color = antes.get_pixel(x, y)
				var r: Color = referencia.get_pixel(x, y)
				var p: Color = pintura.get_pixel(x, y)
				var c: Color = contato.get_pixel(x, y)
				if a.a != r.a or (a.a > 0 and a != r):
					pixels_comparacao += 1
				if a.a != c.a or p.a != c.a:
					pixels_alfa += 1
				if c.a > 0 and p != c:
					sombra += 1
					if c.r > p.r or c.g > p.g or c.b > p.b:
						clareados += 1
		pixels_sombra.append(sombra)
		_verificar(sombra > 50 and clareados == 0, "sombra aparece sobre receptor sem clarear ou criar halo")
		_verificar(pixels_alfa == 0 and pixels_comparacao == 0, "A reproduz base; pintura/contato preservam transparência")
		var pontos: PackedVector2Array = _deformar(nova.modelo)
		for uv: Vector2 in [Vector2(650, 80), Vector2(650, 120), Vector2(620, 380), Vector2(560, 500), Vector2(650, 800)]:
			var vertice: int = nova.modelo.pele.uv.find(uv)
			_verificar(vertice >= 0, "marco UV protegido existente")
			if vertice >= 0:
				var posicao: Vector2i = Vector2i(nova.modelo.to_global(pontos[vertice]).round())
				_verificar(contato.get_pixelv(posicao) == antes.get_pixelv(posicao), "face/parte inferior preservados")
				pontos_protegidos += 1
		for braco: BracoRegistradoV1 in [nova.braco_novo, nova.novo_distante]:
			for osso: Bone2D in [braco.ombro, braco.cotovelo, braco.punho]:
				var posicao: Vector2i = Vector2i(osso.global_position.round())
				_verificar(contato.get_pixelv(posicao) == pintura.get_pixelv(posicao), "sombra não recolore juntas ou pele do ombro")
				pontos_protegidos += 1


func _render_integracao(viewport: SubViewport, nova: VegaIntegracaoTroncoV1, intensidade: float) -> Image:
	nova.definir_integracao(intensidade)
	await process_frame
	await RenderingServer.frame_post_draw
	return viewport.get_texture().get_image()


func _testar_seguimento(nova: VegaIntegracaoTroncoV1) -> void:
	nova.pose_corpo(0)
	nova.socar_corpo()
	for quadro: int in range(18):
		await process_frame
		await RenderingServer.frame_post_draw
		# Não chamar sincronizar_sombra: verificar o callback de render real.
		var segmento: Vector4 = nova.material_gola.get_shader_parameter(&"antebraco")
		_verificar(Vector2(segmento.z, segmento.w).distance_to(nova.braco_novo.punho.get_global_transform_with_canvas().origin) < .001,
			"sombra segue o golpe automaticamente, sem um quadro de atraso")
		quadros_seguidos += 1


func _deformar(rig: ApoioCorporalNativoV2) -> PackedVector2Array:
	var matrizes: Array[Transform2D] = []
	for indice: int in range(rig.pele.get_bone_count()):
		var osso: Bone2D = rig.esqueleto.get_node(rig.pele.get_bone_path(indice)) as Bone2D
		matrizes.append(rig.esqueleto.global_transform.affine_inverse() * osso.global_transform * osso.get_skeleton_rest().affine_inverse())
	var resultado := PackedVector2Array()
	for indice: int in range(rig.pele.polygon.size()):
		var ponto := Vector2.ZERO
		for osso: int in range(matrizes.size()):
			ponto += (matrizes[osso] * rig.pele.polygon[indice]) * rig.pele.get_bone_weights(osso)[indice]
		resultado.append(ponto)
	return resultado


func _testar_preview() -> void:
	var cena: PackedScene = load("res://vega_animada/corpo_articulado/integracao_tronco/preview.tscn") as PackedScene
	var preview: Node2D = cena.instantiate() as Node2D
	root.add_child(preview)
	for tecla: Key in [KEY_1, KEY_2, KEY_3, KEY_A, KEY_A, KEY_S, KEY_S, KEY_Z, KEY_L, KEY_R, KEY_SPACE]:
		var evento := InputEventKey.new()
		evento.keycode = tecla
		evento.pressed = true
		preview._unhandled_key_input(evento)
	var candidata: VegaIntegracaoTroncoV1 = preview.candidata as VegaIntegracaoTroncoV1
	var anterior: VegaIntegracaoTroncoV1 = preview.anterior as VegaIntegracaoTroncoV1
	_verificar(candidata.intensidade_integracao == 1 and anterior.intensidade_integracao == 0, "A/B não altera lado anterior")
	_verificar(candidata.sombra_contato == .32 and preview.ampliado and candidata.corpo_reduzido, "S/Z/R e inspeção")
	preview.free()
