extends SceneTree
## Zoom nativo para ler contornos; não modifica a imagem de referência.

const ARTE: Texture2D = preload("res://docs/arte_vega/vega_corpo_volume_poses_04.png")

class Grade extends Node2D:
	var regiao: Rect2
	var zoom: float = 3
	var passo: int = 10
	const FONTE: Font = preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Regular.ttf")
	func _draw() -> void:
		for x: int in range(ceili(regiao.position.x / passo) * passo, int(regiao.end.x), passo):
			var local_x: float = 20 + (x - regiao.position.x) * zoom
			draw_line(Vector2(local_x, 20), Vector2(local_x, 760), Color(0, 1, 1, .25))
			draw_string(FONTE, Vector2(local_x, 16), str(x), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
		for y: int in range(ceili(regiao.position.y / passo) * passo, int(regiao.end.y), passo):
			var local_y: float = 20 + (y - regiao.position.y) * zoom
			draw_line(Vector2(20, local_y), Vector2(860, local_y), Color(0, 1, 1, .25))
			draw_string(FONTE, Vector2(2, local_y), str(y), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.BLACK)


func _initialize() -> void:
	_capturar.call_deferred()


func _capturar() -> void:
	var pasta: String = "res://docs/evidencias_vega_bracos_prancha_18"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(pasta))
	var tela := SubViewport.new()
	tela.size = Vector2i(900, 800)
	tela.world_2d = World2D.new()
	tela.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(tela)
	var sprite := Sprite2D.new()
	sprite.texture = ARTE
	sprite.centered = false
	sprite.region_enabled = true
	sprite.position = Vector2(20, 20)
	sprite.scale = Vector2.ONE * 3
	tela.add_child(sprite)
	var grade := Grade.new()
	tela.add_child(grade)
	var erro: Error = OK
	for nome: String in ["proximo", "distante", "mao_proxima", "mao_distante", "antebraco_distante"]:
		var regiao := Rect2(130, 190, 250, 220)
		var zoom: float = 3
		var passo: int = 10
		match nome:
			"distante": regiao = Rect2(350, 170, 170, 220)
			"mao_proxima": regiao = Rect2(290, 200, 75, 100)
			"mao_distante": regiao = Rect2(410, 185, 85, 100)
			"antebraco_distante": regiao = Rect2(395, 270, 95, 105)
		if nome not in ["proximo", "distante"]:
			zoom = 6
			passo = 5
		sprite.scale = Vector2.ONE * zoom
		sprite.region_rect = regiao
		grade.regiao = regiao
		grade.zoom = zoom
		grade.passo = passo
		grade.queue_redraw()
		for marcos: bool in [false, true]:
			grade.visible = marcos
			await process_frame
			await RenderingServer.frame_post_draw
			erro = maxi(erro, tela.get_texture().get_image().save_png(pasta.path_join(nome + ("_grade" if marcos else "") + ".png"))) as Error
	print("Recortes prancha: ", error_string(erro))
	tela.free()
	quit(erro)
