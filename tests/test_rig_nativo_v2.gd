extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar")


func _verificar(condicao: bool, texto: String) -> void:
	if not condicao:
		falhas += 1
		push_error("RIG NATIVO: " + texto)


func _executar() -> void:
	var prova: Control = (load("res://vega_animada/rig_nativo_v2/preview.tscn") as PackedScene).instantiate() as Control
	get_tree().root.add_child(prova)
	await get_tree().process_frame
	var rig: BracoNativoV2 = prova.braco
	_verificar(rig.esqueleto.get_bone_count() == 3, "tres Bone2D registrados no Skeleton2D")
	_verificar(rig.esqueleto.get_modification_stack() == null, "prova nao usa solver IK")
	_verificar(not rig.has_method("apontar_para"), "rig nao reutiliza o solver procedural")
	for nome: StringName in [&"repouso", &"guarda", &"extensao", &"soco"]:
		var animacao: Animation = rig.animacao.get_animation(nome)
		_verificar(animacao != null, "poses precisam existir no recurso editavel")
		for trilha: int in animacao.get_track_count():
			_verificar(str(animacao.track_get_path(trilha)).ends_with(":rotation"), "somente rotacoes podem ser animadas nesta prova")
	var referencia_mao: Transform2D = (rig.punho.get_node("Mao") as Sprite2D).transform
	for nome: StringName in [&"repouso", &"guarda", &"extensao"]:
		rig.definir_pose(nome, true)
		_verificar(not rig.animacao.is_playing() and rig.pose_atual == nome, "pose estatica precisa ficar parada")
		_conferir_juntas(rig, referencia_mao)
	rig.definir_pose(&"repouso", true)
	_verificar(is_equal_approx(rig.ombro.rotation, deg_to_rad(110)) and is_equal_approx(rig.cotovelo.rotation, deg_to_rad(-75)), "repouso segue chaves editaveis")
	rig.definir_pose(&"extensao", true)
	_verificar(is_equal_approx(rig.ombro.rotation, deg_to_rad(-8)) and is_equal_approx(rig.cotovelo.rotation, deg_to_rad(7)), "extensao segue chaves editaveis")
	for passo: int in 57:
		rig.inspecionar_tempo(float(passo) / 100.0)
		_conferir_juntas(rig, referencia_mao)
	rig.definir_pose(&"repouso", true)
	rig.definir_pose(&"guarda")
	rig.animacao.advance(.08)
	var antes: Vector2 = Vector2(rig.ombro.rotation, rig.cotovelo.rotation)
	rig.reproduzir_soco()
	rig.animacao.advance(0)
	_verificar(antes.is_equal_approx(Vector2(rig.ombro.rotation, rig.cotovelo.rotation)), "captura nativa retoma pose atual sem teleporte")
	rig.animacao.advance(.6)
	_verificar(rig.pose_atual == &"repouso" and not rig.animacao.is_playing(), "ciclo termina em repouso sem loop")
	rig.reproduzir_soco()
	rig.animacao.advance(.15)
	rig.definir_movimento_reduzido(true)
	_verificar(not rig.animacao.is_playing() and rig.pose_atual == &"repouso", "reduzido interrompe ciclo")
	rig.reproduzir_soco()
	_verificar(not rig.animacao.is_playing(), "reduzido nao reproduz soco amplo")
	rig.definir_pose(&"guarda")
	_verificar(not rig.animacao.is_playing() and is_equal_approx(rig.cotovelo.rotation, deg_to_rad(-160)), "reduzido permite comparar pose estatica")
	(prova.get_node("Rodape/Controles/Guarda") as Button).pressed.emit()
	_verificar(prova.zoom.pose_atual == &"guarda", "botao controla tambem o braco ampliado")
	(prova.get_node("Rodape/Controles/Reduzido") as CheckButton).button_pressed = true
	_verificar(rig.movimento_reduzido and prova.zoom.movimento_reduzido, "controle reduzido alcanca as duas instancias")
	(prova.get_node("Rodape/LinhaTempo") as HSlider).value = .2
	_verificar(rig.pose_atual == &"inspecao" and prova.zoom.pose_atual == &"inspecao", "linha de tempo permite inspecionar as duas instancias")
	for resolucao: Vector2i in [Vector2i(1024, 576), Vector2i(1920, 1080)]:
		get_window().size = resolucao
		get_window().content_scale_size = resolucao
		await get_tree().process_frame
		prova.call("_layout")
		var limites: Rect2 = prova.get_global_rect()
		_verificar(limites.encloses((prova.get_node("Rodape/Controles/Reduzido") as Control).get_global_rect()), "controles cabem na janela")
		var rig_zoom: BracoNativoV2 = prova.zoom
		for pose: StringName in [&"repouso", &"guarda", &"extensao"]:
			rig_zoom.definir_pose(pose, true)
			var sprite: Sprite2D = rig_zoom.punho.get_node("Mao") as Sprite2D
			var area: Rect2 = sprite.get_rect()
			for canto: Vector2 in [area.position, area.position + Vector2(area.size.x, 0), area.end, area.position + Vector2(0, area.size.y)]:
				var global: Vector2 = sprite.to_global(canto)
				_verificar(limites.has_point(global), "mao ampliada completa cabe na janela em " + str(pose))
				_verificar(global.y > 112, "mao ampliada nao invade cabecalho em " + str(pose))
	_verificar((prova.get_node("OssosOverlay") as Node2D).z_index > 0, "marcadores precisam aparecer acima do fundo")
	prova.queue_free()
	await get_tree().process_frame
	print("RIG NATIVO: %d falhas" % falhas)
	get_tree().quit(0 if falhas == 0 else 1)


func _conferir_juntas(rig: BracoNativoV2, referencia_mao: Transform2D) -> void:
	var escala: float = rig.global_transform.x.length()
	_verificar(absf(rig.ombro.global_position.distance_to(rig.cotovelo.global_position) - rig.ombro.get_length() * escala) < .01, "osso superior nao muda comprimento")
	_verificar(absf(rig.cotovelo.global_position.distance_to(rig.punho.global_position) - rig.cotovelo.get_length() * escala) < .01, "antebraco nao muda comprimento")
	var mao: Sprite2D = rig.punho.get_node("Mao") as Sprite2D
	_verificar(mao.transform.is_equal_approx(referencia_mao), "mao nao muda tamanho ou ancora entre poses")
	for osso: Bone2D in [rig.ombro, rig.cotovelo, rig.punho]:
		_verificar(osso.scale == Vector2.ONE, "ossos nao sao escalados para alcancar pose")
