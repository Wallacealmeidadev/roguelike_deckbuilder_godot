class_name VegaMovimentoBracoV1
extends VegaEncaixeBracoV1
## Variante de um braço: um AnimationPlayer escreve corpo e prótese.
## A cena estática, recursos compartilhados e F5 permanecem anteriores.


func _ready() -> void:
	super._ready()
	_adaptar_clipes()
	_ativo = true
	reiniciar()


func _adaptar_clipes() -> void:
	var biblioteca: AnimationLibrary = modelo.animacao.get_animation_library(&"").duplicate(true) as AnimationLibrary
	var antiga: String = str(modelo.get_path_to(modelo.braco_original)) + "/"
	var nova: String = str(modelo.get_path_to(braco_novo)) + "/"
	var guarda: Array[float] = [deg_to_rad(angulo_ombro), deg_to_rad(angulo_cotovelo), 0.0]
	for nome: StringName in biblioteca.get_animation_list():
		var clipe: Animation = biblioteca.get_animation(nome)
		for trilha: int in range(clipe.get_track_count()):
			var caminho: String = str(clipe.track_get_path(trilha))
			if not caminho.begins_with(antiga):
				continue
			var parte: int = 2 if "/Punho:" in caminho else (1 if "/Cotovelo:" in caminho else 0)
			var inicio: float = float(clipe.track_get_key_value(trilha, 0))
			clipe.track_set_path(trilha, NodePath(caminho.replace(antiga, nova)))
			for chave: int in range(clipe.track_get_key_count(trilha)):
				var valor: float = float(clipe.track_get_key_value(trilha, chave))
				var tempo: float = clipe.track_get_key_time(trilha, chave)
				var adaptado: float = guarda[parte]
				if nome == &"extensao":
					adaptado = valor
				elif nome == &"soco":
					if parte == 0:
						# Mesmo impacto e tempos originais; preparo pequeno para trás.
						adaptado = valor if is_equal_approx(tempo, .2) else guarda[0]
						if is_equal_approx(tempo, .1):
							adaptado += absf(valor - inicio)
					elif parte == 1:
						adaptado = clampf(valor - inicio + guarda[1], guarda[1], deg_to_rad(7))
					else:
						adaptado = valor
				elif nome in [&"respirar", &"dano", &"soco_distante"]:
					adaptado += valor - inicio
					if parte == 1:
						adaptado = maxf(adaptado, guarda[1])
				clipe.track_set_key_value(trilha, chave, adaptado)
	modelo.animacao.remove_animation_library(&"")
	modelo.animacao.add_animation_library(&"", biblioteca)
	modelo.animacao.clear_caches()


func socar() -> void:
	# Só o braço próximo está sendo validado; não alternar com a arte antiga.
	proximo_braco_distante = false
	super.socar()
	proximo_braco_distante = false


func inspecionar(nome: StringName, segundos: float) -> void:
	if not modelo.animacao.has_animation(nome):
		return
	_parar_feedback()
	estado_animacao = str(nome)
	modelo.animacao.clear_caches()
	modelo.animacao.play(nome, 0)
	modelo.animacao.seek(clampf(segundos, 0, modelo.animacao.get_animation(nome).length), true)
	modelo.animacao.pause()
	braco_novo.guias.queue_redraw()


func definir_reduzido(ativo: bool) -> void:
	atualizar_estado(0, true, ativo)


func _process(_delta: float) -> void:
	if braco_novo.mostrar_marcos:
		braco_novo.guias.queue_redraw()
