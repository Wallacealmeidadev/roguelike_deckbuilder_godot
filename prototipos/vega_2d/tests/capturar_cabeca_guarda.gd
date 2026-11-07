extends SceneTree
## Evidência renderizada, sem editar texturas-fonte.

const CENA: PackedScene = preload("res://prototipos/vega_2d/corpo_articulado/guarda_montada/vega_guarda.tscn")


func _initialize() -> void:
	_capturar.call_deferred()


func _capturar() -> void:
	var depois: bool = "--depois" in OS.get_cmdline_user_args()
	var pasta: String = "res://docs/evidencias_vega_guarda_montada_17/cabeca_" + ("depois" if depois else "antes")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var tela := SubViewport.new()
	tela.size = Vector2i(650, 600)
	tela.world_2d = World2D.new()
	tela.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(tela)
	var fundo := Polygon2D.new()
	fundo.polygon = PackedVector2Array([Vector2.ZERO, Vector2(650, 0), Vector2(650, 600), Vector2(0, 600)])
	fundo.color = Color("465462")
	tela.add_child(fundo)
	var vega: VegaGuardaMontadaV1 = CENA.instantiate() as VegaGuardaMontadaV1
	vega.position = Vector2(-650, -200)
	vega.scale = Vector2.ONE * 3
	tela.add_child(vega)
	vega.proximo.hide()
	vega.distante.hide()
	var material_original: Material = vega.cabeca.material
	var erro: Error = OK
	for modo: String in ["montagem", "cabeca", "sem_material", "tronco", "atlas"]:
		vega.cabeca.visible = modo != "tronco"
		vega.tronco.visible = modo in ["montagem", "tronco"]
		vega.quadril.hide()
		vega.cabeca.material = null if modo in ["sem_material", "atlas"] else material_original
		if modo == "atlas":
			vega.cabeca.uv = PackedVector2Array([Vector2(450, 0), Vector2(755, 0), Vector2(755, 230), Vector2(450, 230)])
			vega.cabeca.polygon = vega.cabeca.uv.duplicate()
		await process_frame
		await RenderingServer.frame_post_draw
		erro = maxi(erro, tela.get_texture().get_image().save_png(pasta.path_join(modo + ".png"))) as Error
	print("Cabeça guarda / ", pasta, ": ", error_string(erro))
	tela.free()
	quit(erro)
