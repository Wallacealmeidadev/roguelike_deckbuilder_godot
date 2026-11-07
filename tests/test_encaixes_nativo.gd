extends Node

var falhas: int = 0
const BASE: String = "Skeleton2D/Ombro"
const PECA: String = "res://vega_animada/rig_nativo_v2/braco_encaixado.tscn"
const PECA_DISTANTE: String = "res://vega_animada/rig_nativo_v2/braco_distante.tscn"


func _ready() -> void:
	call_deferred("_executar")


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		if falhas <= 10:
			push_error("ENCAIXES: " + mensagem)


func _executar() -> void:
	var rig: DoisBracosNativoV2 = (load("res://vega_animada/rig_nativo_v2/dois_bracos.tscn") as PackedScene).instantiate() as DoisBracosNativoV2
	add_child(rig)
	var anterior: BracoNativoV2 = (load("res://vega_animada/rig_nativo_v2/braco_nativo.tscn") as PackedScene).instantiate() as BracoNativoV2
	add_child(anterior)
	anterior.visible = false
	await get_tree().process_frame
	var maos: Array[Sprite2D] = []
	var transformacoes: Array[Transform2D] = []
	for braco: BracoNativoV2 in [rig.braco_original, rig.braco_distante]:
		var distante: bool = braco == rig.braco_distante
		_verificar(braco.scene_file_path == (PECA_DISTANTE if distante else PECA), "cada lado usa sua variante visual")
		_verificar(braco.cotovelo.position == anterior.cotovelo.position and braco.punho.position == anterior.punho.position,
			"corrigir arte nao muda comprimentos dos ossos")
		var mao: Sprite2D = braco.punho.get_node("Mao") as Sprite2D
		var mao_anterior: Sprite2D = anterior.punho.get_node("Mao") as Sprite2D
		_verificar(mao.scale.abs() == mao_anterior.scale.abs() and mao.offset == mao_anterior.offset,
			"mao mantem tamanho e referencia do recorte")
		if distante:
			var proxima: Sprite2D = rig.braco_original.punho.get_node("Mao") as Sprite2D
			var reflexao: Transform2D = Transform2D(Vector2.RIGHT, Vector2.UP, Vector2.ZERO)
			_verificar(mao.transform.is_equal_approx(reflexao * proxima.transform),
				"mao distante reflete so o lado transversal, mantendo eixo e encaixe")
			# Dois marcos do desenho: ponta dos dedos e lado do polegar, relativos ao cuff.
			for marco: Vector2 in [Vector2(140, -198), Vector2(210, -68)]:
				var a: Vector2 = proxima.transform * marco
				var b: Vector2 = mao.transform * marco
				_verificar(absf(a.x - b.x) < .001 and absf(a.y + b.y) < .001,
					"dedos continuam para frente; polegar troca de lado em torno do cuff")
		else:
			_verificar(mao.rotation == mao_anterior.rotation and mao.scale == mao_anterior.scale,
				"orientacao da mao proxima preservada")
		_verificar(mao.position == Vector2(-8, 0), "cuff assentado oito pixels dentro do antebraco")
		maos.append(mao)
		transformacoes.append(mao.transform)
		var nucleos: Array[Polygon2D] = _nucleos(braco)
		for nucleo: Polygon2D in nucleos:
			_verificar(nucleo.polygon.size() == 24 and nucleo.uv.size() == 24, "encaixe tem contorno fechado com UV explicito")
			var imagem: Image = nucleo.texture.get_image()
			for uv: Vector2 in nucleo.uv:
				_verificar(imagem.get_pixel(int(uv.x), int(uv.y)).a > .95, "miolo usa fibra opaca, nao outro recorte vazado")
			var camada: int = 0
			var ancestral: Node = nucleo
			while ancestral != rig:
				if ancestral is CanvasItem:
					camada += (ancestral as CanvasItem).z_index
				ancestral = ancestral.get_parent()
			_verificar(camada + rig.z_index > 0, "nucleo aparece acima do fundo")
			if braco == rig.braco_distante:
				_verificar(camada < 0, "nucleo distante nao invade frente do tronco")
		_verificar(nucleos[1].z_index < (nucleos[1].get_parent().get_node("Junta") as Sprite2D).z_index,
			"miolo do cotovelo nao cobre aro metalico")
		_verificar(nucleos[3].get_parent() == mao and nucleos[3].z_index > 0, "fibra da abertura pintada acompanha a mao por cima do recorte")
	for passo: int in 57:
		rig.inspecionar_tempo(float(passo) / 100)
		for indice: int in 2:
			var braco: BracoNativoV2 = rig.braco_original if indice == 0 else rig.braco_distante
			var nucleos: Array[Polygon2D] = _nucleos(braco)
			_verificar(Geometry2D.is_point_in_polygon(nucleos[0].to_local(braco.ombro.global_position), nucleos[0].polygon),
				"nucleo do ombro cobre ancora durante rotacao")
			_verificar(Geometry2D.is_point_in_polygon(nucleos[1].to_local(braco.cotovelo.global_position), nucleos[1].polygon),
				"nucleo do cotovelo acompanha pivo sem abrir")
			_verificar(Geometry2D.is_point_in_polygon(nucleos[2].to_local(braco.punho.global_position), nucleos[2].polygon),
				"nucleo do punho cobre ancora inclusive na guarda")
			_verificar(Geometry2D.is_point_in_polygon(Vector2.ZERO, nucleos[3].polygon), "miolo cobre centro da abertura da luva")
			_verificar(maos[indice].transform == transformacoes[indice], "encaixe nao recebe compensacao oscilante por frame")
	rig.queue_free()
	anterior.queue_free()
	await get_tree().process_frame
	print("TEST ENCAIXES NATIVO: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _nucleos(braco: BracoNativoV2) -> Array[Polygon2D]:
	return [braco.get_node(BASE + "/NucleoOmbro") as Polygon2D,
		braco.get_node(BASE + "/Cotovelo/Arte/NucleoCotovelo") as Polygon2D,
		braco.punho.get_node("NucleoPunho") as Polygon2D,
		braco.punho.get_node("Mao/MioloLuva") as Polygon2D]
