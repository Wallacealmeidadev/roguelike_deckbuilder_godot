extends Node

const SEGMENTOS: Array[String] = [
	"braco_superior_frente",
	"antebraco_frente",
	"punho_frente",
	"braco_superior_tras",
	"antebraco_tras",
	"punho_tras",
]

var falhas: int = 0

func _ready() -> void:
	call_deferred("verificar")

func conferir(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error(mensagem)

func verificar() -> void:
	for nome: String in SEGMENTOS:
		var caminho: String = "res://vega_animada/pecas_articuladas/%s.png" % nome
		var textura: Texture2D = load(caminho) as Texture2D
		conferir(textura != null, "Recurso segmentado ausente: %s" % caminho)
		if textura == null:
			continue
		conferir(textura.get_width() > 0 and textura.get_height() > 0, "Recurso segmentado vazio: %s" % caminho)
		var imagem: Image = textura.get_image()
		conferir(imagem != null, "Imagem segmentada ilegível: %s" % caminho)
	await verificar_cena_candidata()

	print("VEGA SEGMENTADA: %d falhas" % falhas)
	get_tree().quit(1 if falhas else 0)

func verificar_cena_candidata() -> void:
	var recurso: PackedScene = load("res://vega_animada/vega_animada_segmentada.tscn") as PackedScene
	conferir(recurso != null, "Cena candidata da Vega ausente")
	if recurso == null:
		return
	var vega: Control = recurso.instantiate() as Control
	conferir(vega != null, "Cena candidata não instancia como Control")
	if vega == null:
		return
	get_tree().root.add_child(vega)
	var skeleton: Skeleton2D = vega.get_node_or_null("Modelo/Skeleton2D") as Skeleton2D
	conferir(skeleton != null, "Skeleton2D ausente na candidata")
	var caminhos_ossos: Array[String] = [
		"Modelo/Skeleton2D/Tronco",
		"Modelo/Skeleton2D/Tronco/Cabeca",
		"Modelo/Skeleton2D/Tronco/BracoFrente",
		"Modelo/Skeleton2D/Tronco/BracoFrente/BracoSuperiorFrente",
		"Modelo/Skeleton2D/Tronco/BracoFrente/AntebracoFrente",
		"Modelo/Skeleton2D/Tronco/BracoFrente/AntebracoFrente/PunhoFrente",
		"Modelo/Skeleton2D/Tronco/BracoTras",
		"Modelo/Skeleton2D/Tronco/BracoTras/BracoSuperiorTras",
		"Modelo/Skeleton2D/Tronco/BracoTras/AntebracoTras",
		"Modelo/Skeleton2D/Tronco/BracoTras/AntebracoTras/PunhoTras",
		"Modelo/Skeleton2D/PernaFrente",
		"Modelo/Skeleton2D/PernaTras",
	]
	for caminho: String in caminhos_ossos:
		var osso: Bone2D = vega.get_node_or_null(caminho) as Bone2D
		conferir(osso != null, "Osso ausente: %s" % caminho)
		if osso != null:
			conferir(not is_zero_approx(osso.get_rest().determinant()), "Osso sem REST válido: %s" % caminho)
			conferir(not osso.get_autocalculate_length_and_angle(), "Osso depende de comprimento automático: %s" % caminho)
	conferir(vega.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Candidata intercepta input próprio")
	var caminhos_sprites: Array[String] = [
		"Modelo/Skeleton2D/Tronco/BracoFrente/BracoSuperiorFrente/Arte",
		"Modelo/Skeleton2D/Tronco/BracoFrente/AntebracoFrente/Arte",
		"Modelo/Skeleton2D/Tronco/BracoFrente/AntebracoFrente/PunhoFrente/Arte",
		"Modelo/Skeleton2D/Tronco/BracoTras/BracoSuperiorTras/Arte",
		"Modelo/Skeleton2D/Tronco/BracoTras/AntebracoTras/Arte",
		"Modelo/Skeleton2D/Tronco/BracoTras/AntebracoTras/PunhoTras/Arte",
	]
	for caminho: String in caminhos_sprites:
		var sprite: Sprite2D = vega.get_node_or_null(caminho) as Sprite2D
		conferir(sprite != null and sprite.texture != null, "Sprite segmentado ausente: %s" % caminho)
	var animation_player: AnimationPlayer = vega.get_node_or_null("AnimationPlayer") as AnimationPlayer
	conferir(animation_player != null, "AnimationPlayer ausente na candidata")
	if animation_player != null:
		for nome_animacao: String in ["repouso", "guarda", "soco", "dano", "reiniciar"]:
			conferir(animation_player.has_animation(nome_animacao), "Animação nomeada ausente: %s" % nome_animacao)
	for metodo: String in ["socar", "receber_dano", "reiniciar"]:
		conferir(vega.has_method(metodo), "API pública ausente: %s" % metodo)
	if animation_player != null and vega.has_method("socar") and vega.has_method("receber_dano") and vega.has_method("reiniciar"):
		vega.call("reiniciar")
		await get_tree().process_frame
		conferir(str(vega.get("estado_animacao")) == "repouso", "Reiniciar nao termina em repouso")
		vega.call("socar")
		conferir(str(vega.get("estado_animacao")) == "soco", "Socar nao entra na pose de soco")
		await get_tree().create_timer(0.12).timeout
		vega.call("receber_dano")
		conferir(str(vega.get("estado_animacao")) == "dano", "Dano nao interrompe o soco")
		await get_tree().create_timer(0.55).timeout
		conferir(str(vega.get("estado_animacao")) == "repouso", "Pose nao retorna ao repouso")
	vega.queue_free()

	var preview_recurso: PackedScene = load("res://vega_animada/preview_vega_segmentada.tscn") as PackedScene
	conferir(preview_recurso != null, "Preview isolado da Vega segmentada ausente")
	if preview_recurso != null:
		var preview: Control = preview_recurso.instantiate() as Control
		conferir(preview != null, "Preview segmentado nao instancia como Control")
		if preview != null:
			conferir(preview.get_node_or_null("VegaAnimada") != null, "Preview nao contem somente a candidata esperada")
			conferir(preview.get_node_or_null("Fundo") != null, "Preview nao possui fundo neutro")
			preview.queue_free()
