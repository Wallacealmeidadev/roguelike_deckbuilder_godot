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

	print("VEGA SEGMENTADA: %d falhas" % falhas)
	get_tree().quit(1 if falhas else 0)
