extends Node

const CENA_PATH: String = "res://vega_animada/vega_corpo_inteiro_articulada.tscn"
const CAMINHOS_BONES: Array[String] = [
	"Visual/Skeleton2D/Torso",
	"Visual/Skeleton2D/Torso/Cabeca",
	"Visual/Skeleton2D/Torso/OmbroA/BracoSuperiorA",
	"Visual/Skeleton2D/Torso/OmbroA/BracoSuperiorA/CotoveloA",
	"Visual/Skeleton2D/Torso/OmbroA/BracoSuperiorA/CotoveloA/AntebracoA",
	"Visual/Skeleton2D/Torso/OmbroA/BracoSuperiorA/CotoveloA/AntebracoA/PunhoA",
	"Visual/Skeleton2D/Torso/OmbroB/BracoSuperiorB",
	"Visual/Skeleton2D/Torso/OmbroB/BracoSuperiorB/CotoveloB",
	"Visual/Skeleton2D/Torso/OmbroB/BracoSuperiorB/CotoveloB/AntebracoB",
	"Visual/Skeleton2D/Torso/OmbroB/BracoSuperiorB/CotoveloB/AntebracoB/PunhoB",
	"Visual/Skeleton2D/PernaA",
	"Visual/Skeleton2D/PernaA/PernaAInferior",
	"Visual/Skeleton2D/PernaB",
	"Visual/Skeleton2D/PernaB/PernaBInferior",
]

var falhas: int = 0


func _ready() -> void:
	call_deferred("_verificar")


func _conferir(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error(mensagem)


func _verificar() -> void:
	var cena: PackedScene = load(CENA_PATH) as PackedScene
	_conferir(cena != null, "Candidata articulada ausente: %s" % CENA_PATH)
	if cena == null:
		print("VEGA ARTICULADA: %d falhas" % falhas)
		get_tree().quit(1)
		return
	var vega: Node = cena.instantiate()
	add_child(vega)
	_conferir(vega is Control, "Raiz da candidata nao e Control")
	if vega is Control:
		var controle: Control = vega as Control
		controle.size = Vector2(1024.0, 576.0)
		_conferir(controle.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Candidata articulada intercepta input")
		await get_tree().process_frame
	for caminho: String in CAMINHOS_BONES:
		_conferir(vega.get_node_or_null(caminho) is Bone2D, "Bone ausente: %s" % caminho)
	var animation_player: AnimationPlayer = vega.get_node_or_null("AnimationPlayer") as AnimationPlayer
	_conferir(animation_player != null, "AnimationPlayer ausente")
	if animation_player != null:
		_conferir(animation_player.has_animation("idle"), "AnimationPlayer nao possui idle")
		_conferir(not animation_player.is_playing(), "Idle deve ficar desligado durante o passe de pose neutra")
	var skeleton: Skeleton2D = vega.get_node_or_null("Visual/Skeleton2D") as Skeleton2D
	_conferir(skeleton != null, "Skeleton2D ausente")
	var torso: Bone2D = vega.get_node_or_null("Visual/Skeleton2D/Torso") as Bone2D
	var ombro_a: Bone2D = vega.get_node_or_null("Visual/Skeleton2D/Torso/OmbroA") as Bone2D
	var ombro_b: Bone2D = vega.get_node_or_null("Visual/Skeleton2D/Torso/OmbroB") as Bone2D
	var cotovelo_a: Bone2D = vega.get_node_or_null("Visual/Skeleton2D/Torso/OmbroA/BracoSuperiorA/CotoveloA") as Bone2D
	var cotovelo_b: Bone2D = vega.get_node_or_null("Visual/Skeleton2D/Torso/OmbroB/BracoSuperiorB/CotoveloB") as Bone2D
	var antebraco_a: Bone2D = vega.get_node_or_null("Visual/Skeleton2D/Torso/OmbroA/BracoSuperiorA/CotoveloA/AntebracoA") as Bone2D
	var antebraco_b: Bone2D = vega.get_node_or_null("Visual/Skeleton2D/Torso/OmbroB/BracoSuperiorB/CotoveloB/AntebracoB") as Bone2D
	var punho_a: Bone2D = vega.get_node_or_null("Visual/Skeleton2D/Torso/OmbroA/BracoSuperiorA/CotoveloA/AntebracoA/PunhoA") as Bone2D
	var punho_b: Bone2D = vega.get_node_or_null("Visual/Skeleton2D/Torso/OmbroB/BracoSuperiorB/CotoveloB/AntebracoB/PunhoB") as Bone2D
	_conferir(torso != null and torso.position == Vector2.ZERO, "Torso nao esta fixo como referencia da pose")
	if ombro_a != null and ombro_b != null:
		_conferir(ombro_a.position.x <= 190.0 and ombro_b.position.x >= 430.0, "Pivos dos ombros continuam proximos demais do torso")
		_conferir(absf(ombro_a.position.y - ombro_b.position.y) >= 3.0, "Ombros continuam perfeitamente simetricos em altura")
		_conferir(absf(ombro_a.rotation) >= 0.06 and absf(ombro_b.rotation) >= 0.06 and ombro_a.rotation * ombro_b.rotation < 0.0, "Ombros nao abrem os bracos de forma assimetrica")
	if cotovelo_a != null and cotovelo_b != null:
		_conferir(absf(cotovelo_a.rotation) >= 0.04 and absf(cotovelo_b.rotation) >= 0.04 and cotovelo_a.rotation * cotovelo_b.rotation < 0.0, "Cotovelos continuam retos ou simetricos")
	if antebraco_a != null and antebraco_b != null:
		_conferir(absf(antebraco_a.rotation) >= 0.02 and absf(antebraco_b.rotation) >= 0.02 and antebraco_a.rotation * antebraco_b.rotation < 0.0, "Antebracos nao receberam pequena orientacao de encaixe")
	if punho_a != null and punho_b != null:
		_conferir(absf(punho_a.rotation - punho_b.rotation) >= 0.04, "Punhos continuam com a mesma rotacao")
	var perna_a: Sprite2D = vega.get_node_or_null("Visual/Skeleton2D/PernaA/Arte") as Sprite2D
	var perna_b: Sprite2D = vega.get_node_or_null("Visual/Skeleton2D/PernaB/Arte") as Sprite2D
	_conferir(perna_a != null and perna_a.visible, "Perna A ausente ou invisivel")
	_conferir(perna_b != null and perna_b.visible, "Perna B ausente ou invisivel")
	if perna_a != null and perna_b != null:
		print("POSICOES PERNAS: A=%s B=%s" % [perna_a.global_position, perna_b.global_position])
		_conferir(absf(perna_a.global_position.x - perna_b.global_position.x) > 40.0, "Pernas reconstruidas no mesmo eixo")
	var perna_bone_a: Bone2D = vega.get_node_or_null("Visual/Skeleton2D/PernaA") as Bone2D
	var perna_bone_b: Bone2D = vega.get_node_or_null("Visual/Skeleton2D/PernaB") as Bone2D
	if perna_bone_a != null and perna_bone_b != null:
		_conferir(absf(perna_bone_a.position.y - perna_bone_b.position.y) >= 3.0, "Pes continuam no mesmo plano vertical")
		_conferir(absf(perna_bone_a.rotation) + absf(perna_bone_b.rotation) >= 0.04, "Pernas continuam sem assimetria de apoio")
	for metodo: String in ["socar", "receber_dano", "reiniciar"]:
		_conferir(vega.has_method(metodo), "API ausente: %s" % metodo)
	if vega.has_method("reiniciar"):
		vega.reiniciar()
		_conferir(vega.get("estado_animacao") == "repouso", "reiniciar nao retorna a repouso")
	print("VEGA ARTICULADA: %d falhas" % falhas)
	get_tree().quit(1 if falhas > 0 else 0)
