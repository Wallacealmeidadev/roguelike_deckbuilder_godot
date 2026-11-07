extends SceneTree
## Medidas de diagnóstico, sem alterar fontes ou cenas de referência.

const CENA: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/combo_fibras/vega_combo.tscn")
const NOVA: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/guarda_montada/vega_guarda.tscn")


func _initialize() -> void:
	_medir.call_deferred()


func _medir() -> void:
	var atriz: VegaComboFibrasV1 = CENA.instantiate() as VegaComboFibrasV1
	atriz.size = Vector2(650, 850)
	root.add_child(atriz)
	atriz.definir_combo_visual(0, true)
	atriz.inspecionar_presenca(false, 0)
	for braco: BracoRegistradoV1 in [atriz.braco_novo, atriz.novo_distante]:
		var t: Transform2D = atriz.modelo.global_transform.affine_inverse() * braco.global_transform
		print(braco.name, " / raiz no modelo ", t)
		print("angulos ", rad_to_deg(braco.ombro.rotation), " / ", rad_to_deg(braco.cotovelo.rotation), " / ", rad_to_deg(braco.punho.rotation))
		for osso: Bone2D in [braco.ombro, braco.cotovelo, braco.punho]:
			print(osso.name, " ", atriz.modelo.to_local(osso.global_position))
		for malha: Polygon2D in braco.segmentos:
			print(malha.name, " / escala ", malha.scale, " / z ", malha.z_index)
	var nova: VegaGuardaMontadaV1 = NOVA.instantiate() as VegaGuardaMontadaV1
	root.add_child(nova)
	print("Registro comum / ", nova.registro_bracos)
	print("Escalas resultantes / ", nova.proximo.transform.x.length(), " / ", nova.distante.transform.x.length())
	nova.free()
	atriz.free()
	quit()
