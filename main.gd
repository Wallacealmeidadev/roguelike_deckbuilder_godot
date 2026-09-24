extends Node

const CENA_CARTA: PackedScene = preload("res://carta.tscn")
const DADOS_CARTAS: Script = preload("res://dados_cartas.gd")
const ENERGIA_POR_TURNO: int = 4
const COMPRA_POR_TURNO: int = 6
const LIMITE_MAO: int = 10
const COMBO_MAXIMO: int = 5
const BARREIRA_JUNTAS_RETORNO: int = 3
const LIMIAR_JUNTAS_RETORNO: int = 2
const TOTAL_COMBATES: int = 5
const ID_ELITE: String = "unidade_contencao_portuaria"
const QUANTIDADE_OPCOES_RECOMPENSA: int = 3
const RECOMPENSAS_DISPONIVEIS: Array[String] = [
	"golpe",
	"protecao",
	"direto_hidraulico",
	"quebra_chassi",
	"brecha",
	"pulso_debilitante"
]

# Cada identificador aponta para as regras daquele tipo de carta.
const CARTAS: Dictionary = DADOS_CARTAS.CARTAS

var jogador_combate: JogadorCombate = JogadorCombate.new(
	40,
	ENERGIA_POR_TURNO,
	COMBO_MAXIMO
)
var encontro_combate: EncontroCombate = EncontroCombate.new()

var estado_jogador: Combatente:
	get:
		return jogador_combate.estado

var estado_inimigo: InimigoCombate:
	get:
		return encontro_combate.inimigo

var vida_jogador: int:
	get:
		return jogador_combate.estado.vida
	set(valor):
		jogador_combate.estado.vida = valor

var vida_inimigo: int:
	get:
		return estado_inimigo.vida
	set(valor):
		estado_inimigo.vida = valor

var barreira: int:
	get:
		return jogador_combate.estado.barreira
	set(valor):
		jogador_combate.estado.barreira = valor

var barreira_inimigo: int:
	get:
		return estado_inimigo.barreira
	set(valor):
		estado_inimigo.barreira = valor

var energia: int:
	get:
		return jogador_combate.energia
	set(valor):
		jogador_combate.energia = valor

var turno: int:
	get:
		return encontro_combate.turno
	set(valor):
		encontro_combate.turno = valor

var combo: int:
	get:
		return jogador_combate.combo
	set(valor):
		jogador_combate.combo = valor

var juntas_retorno_ativada_no_turno: bool:
	get:
		return jogador_combate.juntas_retorno_ativada_no_turno
	set(valor):
		jogador_combate.juntas_retorno_ativada_no_turno = valor

var exposto_inimigo: int:
	get:
		return estado_inimigo.exposto
	set(valor):
		estado_inimigo.exposto = valor

var enfraquecido_inimigo: int:
	get:
		return estado_inimigo.enfraquecido
	set(valor):
		estado_inimigo.enfraquecido = valor
var combate_atual: int = 1
var aguardando_recompensa: bool = false
var aguardando_recompensa_elite: bool = false
var etapa_recompensa_elite: String = ""
var aguardando_evento: bool = false
var id_evento_atual: String = ""
var baralho_run: Array[String] = []
var oferta_recompensa: OfertaRecompensa = OfertaRecompensa.new()
var oferta_reliquias: OfertaRecompensa = OfertaRecompensa.new()
var oferta_cartas_raras: OfertaRecompensa = OfertaRecompensa.new()
var seletor_inimigos: SeletorInimigos = SeletorInimigos.new(
	DadosInimigos.identificadores()
)
var roteiro_run: RoteiroRun = RoteiroRun.new()
var seletor_eventos: SeletorEncontros = SeletorEncontros.new(
	DadosEncontros.identificadores_por_tipo("evento")
)
var etapa_evento_atual: String = ""
var encontro_especial_pendente: bool = false
var id_inimigo_especial: String = ""
var texto_evento_especial: String = ""

var baralho_combate: BaralhoCombate:
	get:
		return encontro_combate.baralho

var resolucao_cartas: ResolucaoCartas = ResolucaoCartas.new()

var pilha_compra: Array[String]:
	get:
		return baralho_combate.compra
	set(valor):
		baralho_combate.compra = valor

var pilha_descarte: Array[String]:
	get:
		return baralho_combate.descarte
	set(valor):
		baralho_combate.descarte = valor

var grupo_cartas: ButtonGroup = ButtonGroup.new()

@onready var mao: HBoxContainer = $Mao
@onready var alvo: Button = $Alvo
@onready var jogador: Button = $Jogador
@onready var energia_label: Label = $EnergiaLabel
@onready var vida_jogador_label: Label = $VidaJogadorLabel
@onready var barreira_label: Label = $BarreiraLabel
@onready var combo_label: Label = $ComboLabel
@onready var reliquia_label: Label = $ReliquiaLabel
@onready var pilhas_label: Label = $PilhasLabel
@onready var botao_encerrar_turno: Button = $EncerrarTurno
@onready var resultado_label: Label = $ResultadoLabel
@onready var botao_reiniciar: Button = $Reiniciar
@onready var recompensas: GridContainer = $Recompensas
@onready var recompensa_opcao_1: Button = $Recompensas/RecompensaOpcao1
@onready var recompensa_opcao_2: Button = $Recompensas/RecompensaOpcao2
@onready var recompensa_opcao_3: Button = $Recompensas/RecompensaOpcao3
@onready var botao_pular_recompensa: Button = $Recompensas/Pular
@onready var intencao_label: Label = $IntencaoLabel
@onready var estados_inimigo_label: Label = $EstadosInimigoLabel
@onready var acao_label: Label = $AcaoLabel
@onready var mao_status_label: Label = $MaoStatusLabel
@onready var recompensa_elite: VBoxContainer = $RecompensaElite
@onready var titulo_reliquias: Label = $RecompensaElite/TituloReliquias
@onready var reliquias_elite: HBoxContainer = $RecompensaElite/ReliquiasElite
@onready var reliquia_opcao_1: Button = $RecompensaElite/ReliquiasElite/RelquiaOpcao1
@onready var reliquia_opcao_2: Button = $RecompensaElite/ReliquiasElite/RelquiaOpcao2
@onready var titulo_cartas_raras: Label = $RecompensaElite/TituloCartasRaras
@onready var cartas_raras_elite: HBoxContainer = $RecompensaElite/CartasRarasElite
@onready var carta_rara_opcao_1: Button = $RecompensaElite/CartasRarasElite/CartaRaraOpcao1
@onready var carta_rara_opcao_2: Button = $RecompensaElite/CartasRarasElite/CartaRaraOpcao2
@onready var carta_rara_opcao_3: Button = $RecompensaElite/CartasRarasElite/CartaRaraOpcao3
@onready var evento_overlay: VBoxContainer = $EventoOverlay
@onready var evento_titulo: Label = $EventoOverlay/EventoTitulo
@onready var evento_texto: Label = $EventoOverlay/EventoTexto
@onready var evento_opcao_1: Button = $EventoOverlay/EventoOpcoes/EventoOpcao1
@onready var evento_opcao_2: Button = $EventoOverlay/EventoOpcoes/EventoOpcao2
@onready var evento_opcao_3: Button = $EventoOverlay/EventoOpcoes/EventoOpcao3
@onready var evento_resultado: Label = $EventoOverlay/EventoResultado
@onready var evento_continuar: Button = $EventoOverlay/EventoContinuar


func _ready() -> void:
	resultado_label.hide()
	botao_reiniciar.hide()
	recompensas.hide()
	_ocultar_recompensa_elite()
	evento_overlay.hide()

	botao_reiniciar.pressed.connect(_ao_reiniciar)
	recompensa_opcao_1.pressed.connect(_ao_clicar_recompensa.bind(0))
	recompensa_opcao_2.pressed.connect(_ao_clicar_recompensa.bind(1))
	recompensa_opcao_3.pressed.connect(_ao_clicar_recompensa.bind(2))
	botao_pular_recompensa.pressed.connect(_ao_pular_recompensa)
	reliquia_opcao_1.pressed.connect(_ao_selecionar_reliquia.bind(0))
	reliquia_opcao_2.pressed.connect(_ao_selecionar_reliquia.bind(1))
	carta_rara_opcao_1.pressed.connect(_ao_selecionar_carta_rara.bind(0))
	carta_rara_opcao_2.pressed.connect(_ao_selecionar_carta_rara.bind(1))
	carta_rara_opcao_3.pressed.connect(_ao_selecionar_carta_rara.bind(2))
	evento_opcao_1.pressed.connect(_ao_escolher_evento.bind(0))
	evento_opcao_2.pressed.connect(_ao_escolher_evento.bind(1))
	evento_opcao_3.pressed.connect(_ao_escolher_evento.bind(2))
	evento_continuar.pressed.connect(_ao_continuar_evento)

	grupo_cartas.allow_unpress = true

	alvo.pressed.connect(_ao_clicar_no_alvo)
	jogador.pressed.connect(_ao_clicar_no_jogador)
	botao_encerrar_turno.pressed.connect(_ao_encerrar_turno)

	seletor_inimigos.reiniciar()
	seletor_eventos.reiniciar()
	_preparar_baralho_inicial()
	roteiro_run.iniciar()
	_iniciar_etapa_atual()


func _combate_terminou() -> bool:
	return encontro_combate.combate_terminou(jogador_combate)


func _mostrar_resultado() -> void:
	aguardando_recompensa = false
	aguardando_recompensa_elite = false
	etapa_recompensa_elite = ""
	aguardando_evento = false
	id_evento_atual = ""
	encontro_especial_pendente = false
	id_inimigo_especial = ""
	texto_evento_especial = ""
	recompensas.hide()
	_ocultar_recompensa_elite()
	evento_overlay.hide()
	_definir_painel_combate_visivel(false)

	if vida_jogador <= 0:
		resultado_label.text = "DERROTA\nVega ficou sem Vida."
	else:
		resultado_label.text = "RUN CONCLUÍDA\nTrês combates vencidos!"

	resultado_label.show()
	botao_reiniciar.show()


func _ao_reiniciar() -> void:
	get_tree().reload_current_scene()


func _preparar_baralho_inicial() -> void:
	baralho_run.clear()

	for i in range(4):
		baralho_run.append("golpe")
		baralho_run.append("protecao")

	for i in range(2):
		baralho_run.append("direto_hidraulico")
		baralho_run.append("quebra_chassi")


func _iniciar_combate() -> void:
	var vida_jogador_preservada: int = jogador_combate.estado.vida
	jogador_combate.iniciar_combate(vida_jogador_preservada)
	aguardando_recompensa = false
	aguardando_recompensa_elite = false
	etapa_recompensa_elite = ""
	aguardando_evento = false
	id_evento_atual = ""

	resultado_label.hide()
	botao_reiniciar.hide()
	recompensas.hide()
	recompensa_elite.hide()
	evento_overlay.hide()
	_definir_painel_combate_visivel(true)

	_limpar_mao()
	var proximo_inimigo: InimigoCombate = _criar_proximo_inimigo()
	if proximo_inimigo == null:
		encontro_combate.inimigo = null
		_registrar_acao("Não foi possível preparar o próximo inimigo.")
		alvo.disabled = true
		jogador.disabled = true
		botao_encerrar_turno.disabled = true
		return

	encontro_combate.iniciar(proximo_inimigo, baralho_run)
	_iniciar_turno()

	print("Combate %d de %d iniciado." % [
		combate_atual,
		TOTAL_COMBATES
	])


func _iniciar_etapa_atual() -> void:
	var tipo_etapa: String = roteiro_run.etapa_atual()
	if tipo_etapa.is_empty():
		_mostrar_pre_chefe()
		return

	if tipo_etapa == "combate_comum":
		combate_atual = _contar_combates_ate_etapa_atual()
		var id_inimigo: String = seletor_inimigos.sortear_disponivel()
		if id_inimigo.is_empty():
			_registrar_acao("Não foi possível preparar um combate comum.")
			return
		_iniciar_combate_por_id(id_inimigo, true)
		return

	if tipo_etapa == "elite":
		combate_atual = _contar_combates_ate_etapa_atual()
		_iniciar_combate_por_id(ID_ELITE, false)
		return

	if tipo_etapa == "evento":
		etapa_evento_atual = seletor_eventos.sortear_disponivel()
		if etapa_evento_atual.is_empty():
			_registrar_acao("Não foi possível preparar um evento.")
			return
		if not seletor_eventos.registrar_encontrado(etapa_evento_atual):
			_registrar_acao("Não foi possível registrar o evento.")
			return
		_mostrar_evento(etapa_evento_atual)


func _contar_combates_ate_etapa_atual() -> int:
	var quantidade: int = 0
	for indice in range(roteiro_run.indice_etapa + 1):
		var tipo: String = RoteiroRun.ETAPAS_PRE_CHEFE[indice]
		if tipo == "combate_comum" or tipo == "elite":
			quantidade += 1
	return quantidade


func _iniciar_combate_por_id(id_inimigo: String, registrar_comum: bool) -> void:
	var vida_jogador_preservada: int = jogador_combate.estado.vida
	jogador_combate.iniciar_combate(vida_jogador_preservada)
	aguardando_recompensa = false
	aguardando_recompensa_elite = false
	etapa_recompensa_elite = ""
	aguardando_evento = false
	id_evento_atual = ""

	resultado_label.hide()
	botao_reiniciar.hide()
	recompensas.hide()
	_ocultar_recompensa_elite()
	evento_overlay.hide()
	_definir_painel_combate_visivel(true)
	_limpar_mao()

	var dados: Dictionary = DadosInimigos.obter(id_inimigo)
	if dados.is_empty():
		encontro_combate.inimigo = null
		_registrar_acao("Não foi possível preparar o inimigo.")
		_definir_painel_combate_visivel(false)
		return

	var inimigo: InimigoCombate = InimigoCombate.new(id_inimigo, dados)
	if inimigo.nome.is_empty() or inimigo.ciclo.is_empty():
		encontro_combate.inimigo = null
		_registrar_acao("Não foi possível preparar o inimigo.")
		_definir_painel_combate_visivel(false)
		return

	if registrar_comum and not seletor_inimigos.registrar_enfrentado(id_inimigo):
		encontro_combate.inimigo = null
		_registrar_acao("Não foi possível registrar o inimigo.")
		_definir_painel_combate_visivel(false)
		return

	encontro_combate.iniciar(inimigo, baralho_run)
	_iniciar_turno()

	print("Combate %d de %d iniciado." % [
		combate_atual,
		TOTAL_COMBATES
	])


func _criar_proximo_inimigo() -> InimigoCombate:
	var id_inimigo: String = ""
	if combate_atual == TOTAL_COMBATES:
		id_inimigo = ID_ELITE
	else:
		id_inimigo = seletor_inimigos.sortear_disponivel()

	if id_inimigo.is_empty():
		return null

	var dados: Dictionary = DadosInimigos.obter(id_inimigo)
	if dados.is_empty():
		return null

	var inimigo: InimigoCombate = InimigoCombate.new(id_inimigo, dados)
	if inimigo.nome.is_empty() or inimigo.ciclo.is_empty():
		return null

	if combate_atual != TOTAL_COMBATES and not seletor_inimigos.registrar_enfrentado(id_inimigo):
		return null

	return inimigo

func _limpar_mao() -> void:
	for no in mao.get_children():
		var carta: Button = no as Button

		if carta != null:
			carta.button_pressed = false
			carta.button_group = null

		mao.remove_child(no)
		no.queue_free()


func _resolver_vitoria() -> void:
	combo = 0

	if encontro_especial_pendente:
		_mostrar_resultado_evento_especial()
		return

	if roteiro_run.etapa_atual() == "elite":
		_mostrar_recompensa_elite()
		return

	_mostrar_recompensas()


func _mostrar_resultado_evento_especial() -> void:
	encontro_especial_pendente = false
	aguardando_evento = true
	evento_titulo.text = "Consequência do evento"
	evento_texto.text = "O confronto terminou."
	evento_resultado.text = texto_evento_especial
	evento_resultado.show()
	evento_continuar.show()
	for botao in [evento_opcao_1, evento_opcao_2, evento_opcao_3]:
		botao.hide()
	_definir_painel_combate_visivel(false)
	evento_overlay.show()
	_atualizar_interface()


func _avancar_roteiro() -> void:
	aguardando_recompensa = false
	aguardando_recompensa_elite = false
	etapa_recompensa_elite = ""
	recompensas.hide()
	_ocultar_recompensa_elite()

	if aguardando_evento:
		_ocultar_evento()

	if not roteiro_run.avancar():
		_mostrar_pre_chefe()
		return

	_iniciar_etapa_atual()


func _mostrar_pre_chefe() -> void:
	aguardando_recompensa = false
	aguardando_recompensa_elite = false
	aguardando_evento = false
	encontro_especial_pendente = false
	etapa_recompensa_elite = ""
	etapa_evento_atual = ""
	recompensas.hide()
	_ocultar_recompensa_elite()
	evento_overlay.hide()
	_definir_painel_combate_visivel(false)
	resultado_label.text = "RUN PRE-CHEFE\nA rota ate o chefe foi concluida."
	resultado_label.show()
	botao_reiniciar.show()


func _ocultar_recompensa_elite() -> void:
	recompensa_elite.hide()
	titulo_reliquias.hide()
	reliquias_elite.hide()
	titulo_cartas_raras.hide()
	cartas_raras_elite.hide()


func _definir_painel_combate_visivel(visivel: bool) -> void:
	mao.visible = visivel
	mao_status_label.visible = visivel
	alvo.visible = visivel
	jogador.visible = visivel
	intencao_label.visible = visivel
	estados_inimigo_label.visible = visivel
	botao_encerrar_turno.visible = visivel


func _mostrar_evento(id_evento: String) -> void:
	var dados: Dictionary = DadosEventos.obter(id_evento)
	if dados.is_empty():
		return

	aguardando_evento = true
	id_evento_atual = id_evento
	aguardando_recompensa = false
	aguardando_recompensa_elite = false
	etapa_recompensa_elite = ""
	recompensas.hide()
	_ocultar_recompensa_elite()
	resultado_label.hide()
	botao_reiniciar.hide()

	evento_titulo.text = str(dados["nome"])
	evento_texto.text = str(dados["descricao"])
	evento_resultado.hide()
	evento_continuar.hide()

	var botoes: Array[Button] = [evento_opcao_1, evento_opcao_2, evento_opcao_3]
	for botao in botoes:
		botao.hide()
		botao.disabled = false

	var opcoes: Array = dados.get("opcoes", [])
	for indice in range(mini(opcoes.size(), botoes.size())):
		var opcao: Dictionary = opcoes[indice]
		botoes[indice].text = str(opcao.get("nome", "Opção"))
		botoes[indice].show()

	_definir_painel_combate_visivel(false)
	evento_overlay.show()
	_atualizar_interface()


func _ocultar_evento() -> void:
	aguardando_evento = false
	id_evento_atual = ""
	evento_overlay.hide()
	_definir_painel_combate_visivel(true)
	_atualizar_interface()


func _ao_escolher_evento(indice: int) -> void:
	_resolver_evento_atual(indice)
	return

	if not aguardando_evento:
		return

	var dados: Dictionary = DadosEventos.obter(id_evento_atual)
	var opcoes: Array = dados.get("opcoes", [])
	if indice < 0 or indice >= opcoes.size():
		return

	var opcao: Dictionary = opcoes[indice]
	var resultado: Dictionary = ResolucaoEventos.resolver(
		id_evento_atual,
		str(opcao.get("id", "")),
		jogador_combate
	)
	if not resultado["valida"]:
		return

	for botao in [evento_opcao_1, evento_opcao_2, evento_opcao_3]:
		botao.hide()
	evento_resultado.text = str(resultado["texto"])
	evento_resultado.show()
	evento_continuar.show()


func _resolver_evento_atual(indice: int) -> void:
	if not aguardando_evento:
		return

	var dados: Dictionary = DadosEventos.obter(etapa_evento_atual)
	var opcoes: Array = dados.get("opcoes", [])
	if indice < 0 or indice >= opcoes.size():
		return

	var opcao: Dictionary = opcoes[indice]
	var resultado: Dictionary = ResolucaoEventos.resolver(
		etapa_evento_atual,
		str(opcao.get("id", "")),
		jogador_combate
	)
	if not resultado["valida"]:
		return

	var vida_delta: int = int(resultado["vida_delta"])
	if vida_delta != 0:
		jogador_combate.estado.vida = clampi(
			jogador_combate.estado.vida + vida_delta,
			0,
			jogador_combate.estado.vida_maxima
		)

	if resultado["tipo"] == "combate_especial":
		encontro_especial_pendente = true
		id_inimigo_especial = str(resultado["id_inimigo"])
		texto_evento_especial = str(resultado["texto"])
		_ocultar_evento()
		_iniciar_combate_por_id(id_inimigo_especial, false)
		return

	for botao in [evento_opcao_1, evento_opcao_2, evento_opcao_3]:
		botao.hide()
	evento_resultado.text = str(resultado["texto"])
	evento_resultado.show()
	evento_continuar.show()
	_atualizar_interface()


func _ao_continuar_evento() -> void:
	if not aguardando_evento:
		return
	_avancar_roteiro()


func _mostrar_recompensas() -> void:
	aguardando_recompensa = true
	oferta_recompensa.gerar(RECOMPENSAS_DISPONIVEIS, QUANTIDADE_OPCOES_RECOMPENSA)

	var botoes: Array[Button] = [
		recompensa_opcao_1,
		recompensa_opcao_2,
		recompensa_opcao_3
	]
	for indice in range(botoes.size()):
		var dados: Dictionary = CARTAS[oferta_recompensa.opcoes[indice]]
		botoes[indice].text = "Adicionar %s" % dados["nome"]
		botoes[indice].show()

	botao_pular_recompensa.show()

	resultado_label.text = "COMBATE %d VENCIDO\nEscolha uma carta" % combate_atual
	resultado_label.show()
	_definir_painel_combate_visivel(false)
	recompensas.show()
	botao_reiniciar.hide()

	print("Aguardando escolha de recompensa.")


func _mostrar_recompensa_elite() -> void:
	_definir_painel_combate_visivel(false)
	aguardando_recompensa_elite = true
	etapa_recompensa_elite = "reliquia"
	oferta_reliquias.gerar(
		DadosReliquias.identificadores_sem(jogador_combate.reliquias_run),
		2
	)
	oferta_cartas_raras.gerar(DADOS_CARTAS.identificadores_por_raridade("rara"), 3)

	resultado_label.text = "ELITE VENCIDO\nEscolha uma relíquia"
	resultado_label.show()
	recompensas.hide()
	recompensa_elite.show()
	titulo_reliquias.show()
	reliquias_elite.show()
	titulo_cartas_raras.hide()
	cartas_raras_elite.hide()
	_preencher_opcoes_reliquias()
	botao_reiniciar.hide()

	print("Aguardando escolha de relíquia do elite.")


func _preencher_opcoes_reliquias() -> void:
	if oferta_reliquias.opcoes.size() < 2:
		return

	reliquia_opcao_1.text = DadosReliquias.obter(oferta_reliquias.opcoes[0])["nome"]
	reliquia_opcao_2.text = DadosReliquias.obter(oferta_reliquias.opcoes[1])["nome"]
	reliquia_opcao_1.show()
	reliquia_opcao_2.show()


func _preencher_opcoes_cartas_raras() -> void:
	if oferta_cartas_raras.opcoes.size() < 3:
		return

	carta_rara_opcao_1.text = CARTAS[oferta_cartas_raras.opcoes[0]]["nome"]
	carta_rara_opcao_2.text = CARTAS[oferta_cartas_raras.opcoes[1]]["nome"]
	carta_rara_opcao_3.text = CARTAS[oferta_cartas_raras.opcoes[2]]["nome"]
	carta_rara_opcao_1.show()
	carta_rara_opcao_2.show()
	carta_rara_opcao_3.show()


func _ao_selecionar_reliquia(indice: int) -> void:
	if indice < 0 or indice >= oferta_reliquias.opcoes.size():
		return
	_escolher_recompensa_elite_reliquia(oferta_reliquias.opcoes[indice])


func _ao_selecionar_carta_rara(indice: int) -> void:
	if indice < 0 or indice >= oferta_cartas_raras.opcoes.size():
		return
	_escolher_recompensa_elite_carta(oferta_cartas_raras.opcoes[indice])


func _escolher_recompensa_elite_reliquia(id_reliquia: String) -> void:
	if not aguardando_recompensa_elite or etapa_recompensa_elite != "reliquia":
		return
	if not oferta_reliquias.opcoes.has(id_reliquia):
		return
	if not jogador_combate.adicionar_reliquia(id_reliquia):
		return

	etapa_recompensa_elite = "carta_rara"
	resultado_label.text = "RELÍQUIA ADICIONADA\nEscolha uma carta rara"
	titulo_reliquias.hide()
	reliquias_elite.hide()
	titulo_cartas_raras.show()
	cartas_raras_elite.show()
	_preencher_opcoes_cartas_raras()
	_atualizar_interface()


func _escolher_recompensa_elite_carta(id_carta: String) -> void:
	if not aguardando_recompensa_elite or etapa_recompensa_elite != "carta_rara":
		return
	if not oferta_cartas_raras.opcoes.has(id_carta):
		return

	baralho_run.append(id_carta)
	aguardando_recompensa_elite = false
	etapa_recompensa_elite = ""
	_ocultar_recompensa_elite()
	_avancar_roteiro()


func _ao_clicar_recompensa(indice: int) -> void:
	if not aguardando_recompensa:
		return

	if indice < 0 or indice >= oferta_recompensa.opcoes.size():
		return

	_escolher_recompensa(oferta_recompensa.opcoes[indice])


func _ao_pular_recompensa() -> void:
	if not aguardando_recompensa:
		return

	aguardando_recompensa = false
	print("Recompensa pulada.")
	_avancar_roteiro()


func _escolher_recompensa(id_carta: String) -> void:
	if not aguardando_recompensa:
		return

	if not CARTAS.has(id_carta) or not oferta_recompensa.opcoes.has(id_carta):
		print("Recompensa inválida: %s" % id_carta)
		return

	aguardando_recompensa = false
	baralho_run.append(id_carta)

	var dados: Dictionary = CARTAS[id_carta]
	print("%s adicionada ao baralho." % dados["nome"])

	_avancar_roteiro()


func _iniciar_turno() -> void:
	if _combate_terminou():
		return

	jogador_combate.iniciar_turno()
	_comprar_cartas(COMPRA_POR_TURNO)
	_atualizar_interface()

	if mao.get_child_count() >= LIMITE_MAO:
		_registrar_acao("Mão cheia: nenhuma carta nova foi comprada.")
	else:
		_registrar_acao("Turno %d iniciado." % turno)

	print("Início do turno %d" % turno)


func _comprar_cartas(quantidade: int) -> void:
	for i in range(quantidade):
		if mao.get_child_count() >= LIMITE_MAO:
			break

		var compra_estava_vazia: bool = baralho_combate.compra.is_empty()
		var id_carta: String = baralho_combate.comprar_identificador()

		if id_carta.is_empty():
			break

		if compra_estava_vazia:
			print("Descarte embaralhado: nova pilha de compra.")

		_criar_carta_na_mao(id_carta)


func _criar_carta_na_mao(id_carta: String) -> void:
	var dados: Dictionary = CARTAS[id_carta]
	var nova_carta: Button = CENA_CARTA.instantiate() as Button
	var valor: int = dados["valor"]
	var descricao: String = ""
	var eh_ataque: bool = dados.get("tipo", "ataque") == "ataque"

	if dados.get("finalizacao", false):
		var bonus_combo: int = dados["bonus_combo"]
		descricao = "Consuma todo o Combo.\nCause %d + %d por Combo de dano." % [
			valor,
			bonus_combo
		]
	elif eh_ataque and dados["alvo"] == "inimigo":
		descricao = "Cause %d de dano." % valor

		if dados.has("exposto"):
			descricao += "\nAplique Exposto %d." % dados["exposto"]

		if dados.has("barreira"):
			descricao += "\nGanhe %d de Barreira." % dados["barreira"]

		descricao += "\nGanhe 1 Combo."
	elif dados["alvo"] == "inimigo":
		descricao = "Aplique Enfraquecido %d." % dados["enfraquecido"]

		if dados.has("barreira"):
			descricao += "\nGanhe %d de Barreira." % dados["barreira"]
	else:
		descricao = "Ganhe %d de Barreira." % valor

	nova_carta.set("nome_carta", dados["nome"])
	nova_carta.set("custo", dados["custo"])
	nova_carta.set("descricao", descricao)
	nova_carta.set_meta("id_carta", id_carta)

	nova_carta.button_group = grupo_cartas
	nova_carta.button_pressed = false
	nova_carta.disabled = false

	mao.add_child(nova_carta)


func _ao_clicar_no_alvo() -> void:
	_jogar_carta("inimigo")


func _ao_clicar_no_jogador() -> void:
	_jogar_carta("jogador")


func _jogar_carta(destino: String) -> void:
	if _combate_terminou():
		return

	var selecionada: Button = grupo_cartas.get_pressed_button() as Button

	if selecionada == null:
		print("Selecione uma carta primeiro.")
		_registrar_acao("Selecione uma carta primeiro.")
		return

	var id_carta: String = str(selecionada.get_meta("id_carta"))
	var dados: Dictionary = CARTAS[id_carta]
	var custo: int = dados["custo"]
	var eh_ataque: bool = dados.get("tipo", "ataque") == "ataque"

	if dados["alvo"] != destino:
		print("Essa carta não pode ser usada nesse alvo.")
		_registrar_acao("Alvo inválido para %s." % dados["nome"])
		return

	if energia < custo:
		print("Energia insuficiente.")
		_registrar_acao("SEM ENERGIA para %s." % dados["nome"])
		return

	var combo_antes: int = combo
	var resultado: Dictionary = resolucao_cartas.resolver(
		id_carta,
		CARTAS,
		estado_jogador,
		estado_inimigo if destino == "inimigo" else estado_jogador,
		destino,
		{
			"energia": energia,
			"combo": combo,
			"combo_maximo": COMBO_MAXIMO
		}
	)

	if not resultado["valida"]:
		return

	energia -= int(resultado["custo"])

	if resultado["gera_combo"]:
		_ganhar_combo()
	else:
		combo = int(resultado["combo"])
		if resultado["consome_combo"]:
			jogador_combate.registrar_finalizacao(combo_antes)

	if eh_ataque and destino == "inimigo":
		print("%s: Barreira absorveu %d. Dano na Vida: %d." % [
			estado_inimigo.nome,
			resultado["absorvido"],
			resultado["dano_na_vida"]
		])
		print("Ataque causou %d de dano." % resultado["dano"])
		_registrar_acao("%s: %d de dano." % [dados["nome"], resultado["dano"]])
	elif resultado["barreira"] > 0:
		_registrar_acao("%s: +%d de Barreira." % [dados["nome"], resultado["barreira"]])
	else:
		var estados_aplicados: Dictionary = resultado["estados_aplicados"]
		if estados_aplicados.is_empty():
			_registrar_acao("%s resolvida." % dados["nome"])
		else:
			_registrar_acao("%s: estados aplicados." % dados["nome"])

	if _combate_terminou():
		combo = 0

	_descartar_carta(selecionada)
	_atualizar_interface()

	if vida_inimigo <= 0:
		print("Você venceu o combate %d!" % combate_atual)
		_resolver_vitoria()


func _ganhar_combo() -> void:
	if jogador_combate.ganhar_combo(
		BARREIRA_JUNTAS_RETORNO,
		LIMIAR_JUNTAS_RETORNO
	):
		print("Juntas de Retorno concedeu %d de Barreira." % BARREIRA_JUNTAS_RETORNO)


func _descartar_carta(carta: Button) -> void:
	var id_carta: String = str(carta.get_meta("id_carta"))
	baralho_combate.descartar_identificador(id_carta)

	carta.button_pressed = false
	carta.button_group = null

	# Sai da mão imediatamente; o objeto é destruído ao fim do frame.
	mao.remove_child(carta)
	carta.queue_free()


func _descartar_mao() -> void:
	for no in mao.get_children():
		var carta: Button = no as Button
		_descartar_carta(carta)


func _ao_encerrar_turno() -> void:
	if _combate_terminou():
		return

	_descartar_mao()
	jogador_combate.encerrar_turno()
	_registrar_acao("Vega encerrou o turno.")

	_executar_intencao_inimigo()

	if vida_jogador <= 0:
		_atualizar_interface()
		print("Você foi derrotado.")
		_mostrar_resultado()
		return

	encontro_combate.avancar_turno()
	_iniciar_turno()


func _calcular_dano_no_inimigo(dano_base: int) -> int:
	return estado_inimigo.calcular_dano_recebido(dano_base)


func _calcular_dano_do_inimigo(dano_base: int) -> int:
	return estado_inimigo.calcular_dano_de_ataque(dano_base)


func _executar_intencao_inimigo() -> void:
	if _combate_terminou():
		return

	var intencao_anunciada: String = estado_inimigo.texto_intencao()
	var acao: Dictionary = encontro_combate.executar_fase_inimiga(jogador_combate)

	if acao.is_empty():
		return

	var resultados_golpes: Array = acao["resultados_golpes"]
	for resultado in resultados_golpes:
		print("Barreira absorveu %d. Dano na Vida: %d." % [
			resultado["absorvido"],
			resultado["dano_na_vida"]
		])

	_registrar_acao("%s executou %s." % [estado_inimigo.nome, intencao_anunciada])


func _causar_dano_no_inimigo(dano: int) -> void:
	var resultado: Dictionary = estado_inimigo.receber_golpe(dano)
	var absorvido: int = resultado["absorvido"]
	var dano_na_vida: int = resultado["dano_na_vida"]

	print("%s: Barreira absorveu %d. Dano na Vida: %d." % [
		estado_inimigo.nome,
		absorvido,
		dano_na_vida
	])


func _registrar_acao(mensagem: String) -> void:
	acao_label.text = mensagem


func _atualizar_interface() -> void:
	combo_label.text = "Combo: %d/%d" % [combo, COMBO_MAXIMO]
	var nomes_reliquias: PackedStringArray = []
	for id_reliquia in jogador_combate.reliquias_run:
		var dados_reliquia: Dictionary = DadosReliquias.obter(id_reliquia)
		if not dados_reliquia.is_empty():
			nomes_reliquias.append(str(dados_reliquia["nome"]))
	reliquia_label.text = "Relíquias: %s" % ", ".join(nomes_reliquias)
	energia_label.text = "Energia: %d/%d" % [energia, ENERGIA_POR_TURNO]
	if energia <= 0:
		energia_label.text += "\nSEM ENERGIA"
	vida_jogador_label.text = "Vida: %d" % vida_jogador
	barreira_label.text = "Barreira: %d" % barreira
	var quantidade_mao: int = mao.get_child_count()
	mao_status_label.text = "Mão: %d/%d" % [quantidade_mao, LIMITE_MAO]
	if quantidade_mao >= LIMITE_MAO:
		mao_status_label.text += "\nMÃO CHEIA"
	pilhas_label.text = "Combate: %d/%d | Baralho: %d\nCompra: %d | Descarte: %d | Mão: %d" % [
		combate_atual,
		TOTAL_COMBATES,
		baralho_run.size(),
		pilha_compra.size(),
		pilha_descarte.size(),
		quantidade_mao
	]

	if vida_inimigo <= 0:
		alvo.text = "%s\nDerrotado" % estado_inimigo.nome.to_upper()
		intencao_label.text = "INTENÇÃO\n—"
		estados_inimigo_label.text = "ESTADOS\n—"
	else:
		alvo.text = "%s\nVida: %d\nBarreira: %d" % [
			estado_inimigo.nome.to_upper(),
			vida_inimigo,
			barreira_inimigo
		]
		intencao_label.text = "INTENÇÃO\n%s" % estado_inimigo.texto_intencao()

		var estados_texto: String = "ESTADOS"
		if exposto_inimigo > 0:
			estados_texto += "\nExposto: %d" % exposto_inimigo
		if enfraquecido_inimigo > 0:
			estados_texto += "\nEnfraquecido: %d" % enfraquecido_inimigo

		if exposto_inimigo <= 0 and enfraquecido_inimigo <= 0:
			estados_texto += "\nNenhum"
		estados_inimigo_label.text = estados_texto

	var terminou: bool = (
		_combate_terminou()
		or aguardando_recompensa
		or aguardando_recompensa_elite
		or aguardando_evento
	)
	alvo.disabled = terminou
	jogador.disabled = terminou
	botao_encerrar_turno.disabled = terminou

	for no in mao.get_children():
		var carta: Button = no as Button
		carta.disabled = terminou
