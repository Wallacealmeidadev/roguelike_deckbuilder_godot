extends SceneTree

const MOVIMENTO: PackedScene = preload("res://prototipos/vega_2d/braco_reconstruido/vega_movimento.tscn")
const ESTATICA: PackedScene = preload("res://prototipos/vega_2d/braco_reconstruido/vega_encaixe.tscn")
const SOBREPOSICAO: Script = preload("res://prototipos/vega_2d/tests/test_encaixe_braco_corpo.gd")
var falhas: int = 0
var amostras_gpu: int = 0
var quadros: int = 0


func _initialize() -> void:
	_executar.call_deferred()


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		if falhas <= 12:
			push_error("MOVIMENTO RECONSTRUÍDO: " + mensagem)


func _executar() -> void:
	var referencia: VegaEncaixeBracoV1 = ESTATICA.instantiate() as VegaEncaixeBracoV1
	referencia.size = Vector2(650, 850)
	root.add_child(referencia)
	var atriz: VegaMovimentoBracoV1 = MOVIMENTO.instantiate() as VegaMovimentoBracoV1
	atriz.size = referencia.size
	root.add_child(atriz)
	var braco: BracoRegistradoV1 = atriz.braco_novo
	var fonte: Image = braco.ARTE.get_image()
	var solas: Array[Vector2] = [atriz.modelo.sola_tras.global_position, atriz.modelo.sola_frente.global_position]
	# Trilha corporal/far mantém tempos, curvas e valores da apresentação anterior.
	for nome: StringName in [&"soco", &"respirar", &"dano"]:
		var original: Animation = referencia.modelo.animacao.get_animation(nome)
		var novo: Animation = atriz.modelo.animacao.get_animation(nome)
		_verificar(original != novo and is_equal_approx(original.length, novo.length), "recurso privado e duração preservada")
		for trilha: int in range(original.get_track_count()):
			if trilha in [3, 4, 5]:
				_verificar("BracoReconstruido/" in str(novo.track_get_path(trilha)), "player escreve na nova cadeia")
				continue
			_verificar(original.track_get_path(trilha) == novo.track_get_path(trilha)
				and original.track_get_interpolation_type(trilha) == novo.track_get_interpolation_type(trilha), "corpo mantém destino/curva")
			for chave: int in range(original.track_get_key_count(trilha)):
				_verificar(original.track_get_key_value(trilha, chave) == novo.track_get_key_value(trilha, chave)
					and original.track_get_key_time(trilha, chave) == novo.track_get_key_time(trilha, chave), "corpo/distante mantêm chaves")
	atriz.inspecionar(&"respirar", 0)
	_verificar(braco.punho.global_transform.is_equal_approx(referencia.braco_novo.punho.global_transform), "respiração começa na guarda aprovada")
	for nome: StringName in [&"soco", &"dano", &"respirar"]:
		var duracao: float = atriz.modelo.animacao.get_animation(nome).length
		var passos: int = 48 if nome == &"respirar" else roundi(duracao * 100)
		for quadro: int in range(passos + 1):
			atriz.inspecionar(nome, duracao * quadro / passos)
			quadros += 1
			_verificar(braco.cotovelo.rotation >= deg_to_rad(-120) - .0001, "não voltar à dobra sobreposta")
			_verificar(braco.transform == atriz.modelo.braco_original.transform, "raiz continua presa ao deltoide")
			_verificar(is_equal_approx(braco.cotovelo.position.x, braco.SUPERIOR)
				and is_equal_approx(braco.punho.position.x, braco.INFERIOR), "sem alongamento de ossos")
			_verificar(braco.segmentos[2].scale.is_equal_approx(Vector2(.76, -.76)), "mão aprovada não muda")
			_verificar(not atriz.modelo.braco_original.visible, "não sobrepor braço antigo")
			_verificar(solas[0].distance_to(atriz.modelo.sola_tras.global_position) < .001
				and solas[1].distance_to(atriz.modelo.sola_frente.global_position) < .001, "apoios fixos")
			var intersecao: Vector2i = SOBREPOSICAO._sobreposicao_central(braco, fonte, rad_to_deg(braco.cotovelo.rotation))
			_verificar(intersecao.x == 0, "faixa central pintada não intersecta bíceps")
			if DisplayServer.get_name() != "headless":
				await RenderingServer.frame_post_draw
				_verificar_gpu(atriz)
		if nome != &"respirar":
			_verificar(braco.punho.global_transform.is_equal_approx(referencia.braco_novo.punho.global_transform), "ação termina na guarda aprovada")
	# A cadeia não depende de escrita manual por frame para reproduzir.
	atriz.reiniciar()
	atriz.socar()
	atriz.modelo.animacao.advance(.12)
	var antes: Transform2D = braco.punho.global_transform
	atriz.socar()
	_verificar(braco.punho.global_transform.is_equal_approx(antes), "novo comando não teleporta imediatamente ao quadro zero")
	atriz.receber_dano()
	_verificar(atriz.estado_animacao == "dano", "dano interrompe o soco")
	atriz.modelo.animacao.advance(.30)
	_verificar(atriz.estado_animacao == "repouso" and atriz.modelo.animacao.current_animation == &"respirar", "retorno automático após dano")
	atriz.socar()
	atriz.modelo.animacao.advance(.60)
	_verificar(atriz.estado_animacao == "repouso", "retorno automático após soco")
	atriz.socar()
	atriz.modelo.animacao.advance(.15)
	atriz.reiniciar()
	_verificar(braco.punho.global_transform.is_equal_approx(referencia.braco_novo.punho.global_transform), "reset restaura guarda sem deriva")
	atriz.definir_reduzido(true)
	antes = braco.punho.global_transform
	atriz.socar()
	atriz.modelo.animacao.advance(.2)
	_verificar(braco.punho.global_transform.is_equal_approx(antes) and not atriz.modelo.animacao.is_playing(), "reduzido mantém postura; feedback só de cor")
	atriz.definir_reduzido(false)
	_verificar(atriz.modelo.animacao.current_animation == &"respirar" and atriz.modelo.animacao.is_playing(), "retomar respiração após reduzido")
	for tentativa: int in range(3):
		atriz.socar()
		_verificar(not atriz.ultimo_braco_distante, "prova usa apenas o braço adaptado")
	# Inspecionar não altera as chaves da cena estática que compartilha a origem.
	referencia.aplicar_guarda()
	_verificar(is_equal_approx(referencia.braco_novo.cotovelo.rotation, deg_to_rad(-120))
		and referencia.modelo.animacao.get_animation(&"soco").track_get_path(3) != atriz.modelo.animacao.get_animation(&"soco").track_get_path(3), "referência estática isolada")
	var laboratorio: Node2D = (load("res://prototipos/vega_2d/braco_reconstruido/preview_movimento.tscn") as PackedScene).instantiate() as Node2D
	root.add_child(laboratorio)
	var demonstracao: VegaMovimentoBracoV1 = laboratorio.get("atriz") as VegaMovimentoBracoV1
	var tecla := InputEventKey.new()
	tecla.pressed = true
	tecla.keycode = KEY_L
	laboratorio.call("_unhandled_key_input", tecla)
	_verificar(is_equal_approx(demonstracao.modelo.animacao.speed_scale, .25), "L aplica câmera lenta 4x")
	tecla.keycode = KEY_SPACE
	laboratorio.call("_unhandled_key_input", tecla)
	_verificar(demonstracao.estado_animacao == "soco", "Espaço aciona o soco")
	tecla.keycode = KEY_D
	laboratorio.call("_unhandled_key_input", tecla)
	_verificar(demonstracao.estado_animacao == "dano", "D aciona interrupção")
	tecla.keycode = KEY_R
	laboratorio.call("_unhandled_key_input", tecla)
	_verificar(demonstracao.modelo.movimento_reduzido, "R ativa movimento reduzido")
	tecla.keycode = KEY_G
	laboratorio.call("_unhandled_key_input", tecla)
	_verificar(demonstracao.estado_animacao == "repouso", "G restaura guarda")
	laboratorio.free()
	atriz.free()
	referencia.free()
	await process_frame
	print("Movimento reconstruído: ", falhas, " falhas; ", quadros, " poses; ", amostras_gpu, " amostras GPU")
	quit(0 if falhas == 0 else 1)


func _verificar_gpu(atriz: VegaMovimentoBracoV1) -> void:
	var braco: BracoRegistradoV1 = atriz.braco_novo
	var viewport: SubViewport = atriz.composicao.get_node("Desenho") as SubViewport
	var render: Image = viewport.get_texture().get_image()
	var pontos: Array[Vector2] = [braco.cotovelo.global_position, braco.punho.global_position,
		braco.segmentos[2].to_global(braco.registros[2] * Vector2(520, 1350))]
	for passo: int in range(-10, 11, 2):
		pontos.append(braco.global_position + Vector2(0, passo))
	for x: int in [0, 2, 4, 6]:
		for y: int in [-3, 0, 3]:
			pontos.append(braco.punho.to_global(Vector2(x, y)))
	for ponto: Vector2 in pontos:
		_verificar(render.get_pixelv(Vector2i(ponto.round())).a > .9, "GPU: ombro, cotovelo, punho e mão continuam ocupados")
		amostras_gpu += 1
