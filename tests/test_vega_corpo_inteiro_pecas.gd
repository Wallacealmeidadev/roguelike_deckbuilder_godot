extends Node

const CAMINHOS: Array[String] = [
	"res://vega_animada/pecas_rig/vega_head.png",
	"res://vega_animada/pecas_rig/vega_torso.png",
	"res://vega_animada/pecas_rig/vega_braco_A_superior.png",
	"res://vega_animada/pecas_rig/vega_braco_A_cotovelo.png",
	"res://vega_animada/pecas_rig/vega_braco_A_antebraco.png",
	"res://vega_animada/pecas_rig/vega_braco_A_punho.png",
	"res://vega_animada/pecas_rig/vega_braco_B_superior.png",
	"res://vega_animada/pecas_rig/vega_braco_B_cotovelo.png",
	"res://vega_animada/pecas_rig/vega_braco_B_antebraco.png",
	"res://vega_animada/pecas_rig/vega_braco_B_punho.png",
	"res://vega_animada/pecas_rig/vega_perna_A_superior.png",
	"res://vega_animada/pecas_rig/vega_perna_A_inferior_bota.png",
	"res://vega_animada/pecas_rig/vega_perna_B_superior.png",
	"res://vega_animada/pecas_rig/vega_perna_B_inferior_bota.png",
]

var falhas: int = 0


func _ready() -> void:
	call_deferred("_verificar")


func _conferir(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error(mensagem)


func _imagem_tem_alpha_util(imagem: Image) -> bool:
	if imagem == null or imagem.is_empty():
		return false
	var cantos_transparentes: int = 0
	for ponto: Vector2i in [Vector2i(0, 0), Vector2i(imagem.get_width() - 1, 0), Vector2i(0, imagem.get_height() - 1), Vector2i(imagem.get_width() - 1, imagem.get_height() - 1)]:
		if imagem.get_pixelv(ponto).a <= 0.01:
			cantos_transparentes += 1
	var possui_arte: bool = false
	for y: int in range(0, imagem.get_height(), 32):
		for x: int in range(0, imagem.get_width(), 32):
			if imagem.get_pixel(x, y).a > 0.01:
				possui_arte = true
				break
		if possui_arte:
			break
	return cantos_transparentes == 4 and possui_arte


func _verificar() -> void:
	for caminho: String in CAMINHOS:
		var textura: Texture2D = load(caminho) as Texture2D
		_conferir(textura != null, "Peca ausente ou invalida: %s" % caminho)
		if textura == null:
			continue
		_conferir(textura.get_width() > 0 and textura.get_height() > 0, "Peca sem dimensao: %s" % caminho)
		var imagem: Image = textura.get_image()
		_conferir(_imagem_tem_alpha_util(imagem), "Peca sem transparencia utilizavel: %s" % caminho)
	print("VEGA PECAS: %d falhas" % falhas)
	get_tree().quit(1 if falhas > 0 else 0)
