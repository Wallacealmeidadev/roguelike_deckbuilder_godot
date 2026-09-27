extends Node

const CENA_CARTA: PackedScene = preload("res://carta.tscn")
const DADOS_CARTAS: Script = preload("res://dados_cartas.gd")
const DESCANSO_REGRAS: Script = preload("res://descanso_run.gd")
const ENERGIA_POR_TURNO: int = 4
const COMPRA_POR_TURNO: int = 6
const LIMITE_MAO: int = 10
const COMBO_MAXIMO: int = 5
const BARREIRA_JUNTAS_RETORNO: int = 3
const LIMIAR_JUNTAS_RETORNO: int = 2
const TOTAL_COMBATES: int = 5
const ID_ELITE: String = "unidade_contencao_portuaria"
const QUANTIDADE_OPCOES_RECOMPENSA: int = 3
const COR_MAPA_DESTINO: Color = Color("#17384a")
const COR_MAPA_ATUAL: Color = Color("#173e3d")
const COR_MAPA_BLOQUEADO: Color = Color("#151b24")
const COR_MAPA_BORDA: Color = Color("#426176")
const COR_MAPA_TEXTO: Color = Color("#e6f0f4")
const COR_MAPA_TEXTO_MUTED: Color = Color("#778692")
const ICONE_MAPA_COMBATE: Texture2D = preload("res://ui_hq_v1/componentes/icones/combate.tres")
const ICONE_MAPA_EVENTO: Texture2D = preload("res://ui_hq_v1/componentes/icones/evento.tres")
const ICONE_MAPA_ELITE: Texture2D = preload("res://ui_hq_v1/componentes/icones/elite.tres")
const ICONE_MAPA_DESCANSO: Texture2D = preload("res://ui_hq_v1/componentes/icones/descanso.tres")
const ICONE_MAPA_CHEFE: Texture2D = preload("res://ui_hq_v1/componentes/icones/chefe.tres")
const ICONE_INTENCAO_ATAQUE: Texture2D = preload("res://ui_hq_v1/componentes/icones/ataque.tres")
const ICONE_INTENCAO_DEFESA: Texture2D = preload("res://ui_hq_v1/componentes/icones/barreira.tres")
const ICONE_INTENCAO_PREPARACAO: Texture2D = preload("res://ui_hq_v1/componentes/icones/forca.tres")
const ESTILO_MAPA_NODE_NORMAL: StyleBox = preload("res://ui_hq_v1/estilos/botao_normal.tres")
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
		return estado_inimigo.vida if estado_inimigo != null else 0
	set(valor):
		if estado_inimigo != null:
			estado_inimigo.vida = valor

var barreira: int:
	get:
		return jogador_combate.estado.barreira
	set(valor):
		jogador_combate.estado.barreira = valor

var barreira_inimigo: int:
	get:
		return estado_inimigo.barreira if estado_inimigo != null else 0
	set(valor):
		if estado_inimigo != null:
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
		return estado_inimigo.exposto if estado_inimigo != null else 0
	set(valor):
		if estado_inimigo != null:
			estado_inimigo.exposto = valor

var enfraquecido_inimigo: int:
	get:
		return estado_inimigo.enfraquecido if estado_inimigo != null else 0
	set(valor):
		if estado_inimigo != null:
			estado_inimigo.enfraquecido = valor
var combate_atual: int = 0
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
var mapa_run: MapaRun = MapaRun.new()
var mapa_ativo: bool = false
var mapa_gerado: bool = false
var mapa_no_atual: String = ""
var mapa_no_em_andamento: String = ""
var mapa_pontos_concluidos: Array[String] = []
var mapa_pre_chefe_alcancado: bool = false
var mapa_variante: int = 0
var descanso_ativo: bool = false
var descanso_acao_resolvida: bool = false
var descanso_tela: String = ""
var descanso_elegiveis: Array[Dictionary] = []
var descanso_indice_selecionado: int = -1
var etapa_evento_atual: String = ""
var evento_escolha_resolvida: bool = false
var encontro_especial_pendente: bool = false
var id_inimigo_especial: String = ""
var texto_evento_especial: String = ""

var baralho_combate: BaralhoCombate:
	get:
		return encontro_combate.baralho

var resolucao_cartas: ResolucaoCartas = ResolucaoCartas.new()
var descanso_regras = DESCANSO_REGRAS.new()

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
var _animacao_hud: Tween
var foco_recompensa_anterior: Control

@onready var mao: Control = $Mao
@onready var arena_chao: Control = $ArenaChao
@onready var mao_dock: Panel = $MaoDock
@onready var energia_painel: Panel = $EnergiaPainel
@onready var alvo: Button = $Alvo
@onready var jogador: Button = $Jogador
@onready var turno_faixa: TextureRect = $TurnoFaixa
@onready var turno_numero_painel: Panel = $TurnoNumeroPainel
@onready var turno_label: Label = $TurnoLabel
@onready var turno_titulo_label: Label = $TurnoTituloLabel
@onready var turno_numero_label: Label = $TurnoNumeroLabel
@onready var energia_label: Label = $EnergiaLabel
@onready var energia_icone: TextureRect = $EnergiaIcone
@onready var energia_visual_label: Label = $EnergiaVisualLabel
@onready var vida_jogador_label: Label = $VidaJogadorLabel
@onready var vida_jogador_bar: ProgressBar = $VidaJogadorBar
@onready var vida_jogador_moldura: Panel = $VidaJogadorMoldura
@onready var vida_inimigo_label: Label = $VidaInimigoLabel
@onready var vida_inimigo_bar: ProgressBar = $VidaInimigoBar
@onready var vida_inimigo_moldura: Panel = $VidaInimigoMoldura
@onready var stats_jogador_painel: Panel = $StatsJogadorPanel
@onready var pilhas_painel: Panel = $PilhasPainel
@onready var barreira_label: Label = $BarreiraLabel
@onready var barreira_icone: TextureRect = $BarreiraIcone
@onready var combo_label: Label = $ComboLabel
@onready var combo_icone: TextureRect = $ComboIcone
@onready var reliquia_painel: Panel = $RelíquiaPainel
@onready var reliquia_label: Label = $ReliquiaLabel
@onready var pilhas_label: Label = $PilhasLabel
@onready var run_status_label: Label = $RunStatusLabel
@onready var compra_label: Label = $CompraLabel
@onready var compra_icone: TextureRect = $CompraIcone
@onready var compra_painel: Panel = $CompraPainel
@onready var descarte_label: Label = $DescarteLabel
@onready var descarte_icone: TextureRect = $DescarteIcone
@onready var descarte_painel: Panel = $DescartePainel
@onready var mao_icone: TextureRect = $MaoIcone
@onready var botao_encerrar_turno: Button = $EncerrarTurno
@onready var resultado_label: Label = $ResultadoLabel
@onready var botao_reiniciar: Button = $Reiniciar
@onready var recompensas: Control = $Recompensas
@onready var recompensa_cartas: HBoxContainer = $Recompensas/RecompensaCartas
@onready var recompensa_opcao_1: Button = $Recompensas/RecompensaOpcao1
@onready var recompensa_opcao_2: Button = $Recompensas/RecompensaOpcao2
@onready var recompensa_opcao_3: Button = $Recompensas/RecompensaOpcao3
@onready var botao_pular_recompensa: Button = $Recompensas/RecompensaAcoes/Pular
@onready var intencao_label: Label = $IntencaoLabel
@onready var intencao_icone: TextureRect = $IntencaoIcone
@onready var intencao_painel: Panel = $IntencaoPainel
@onready var intencao_visual_label: Label = $IntencaoVisualLabel
@onready var intencao_nome_visual_label: Label = $IntencaoNomeVisualLabel
@onready var intencao_valor_visual_label: Label = $IntencaoValorVisualLabel
@onready var estados_inimigo_label: Label = $EstadosInimigoLabel
@onready var estados_inimigo_painel: Panel = $EstadosInimigoPainel
@onready var estados_inimigo_visual_label: Label = $EstadosInimigoVisualLabel
@onready var estados_inimigo_barreira_icone: TextureRect = $EstadosInimigoBarreiraIcone
@onready var estados_inimigo_barreira_label: Label = $EstadosInimigoBarreiraLabel
@onready var estados_inimigo_exposto_icone: TextureRect = $EstadosInimigoExpostoIcone
@onready var estados_inimigo_exposto_label: Label = $EstadosInimigoExpostoLabel
@onready var estados_inimigo_enfraquecido_icone: TextureRect = $EstadosInimigoEnfraquecidoIcone
@onready var estados_inimigo_enfraquecido_label: Label = $EstadosInimigoEnfraquecidoLabel
@onready var alvo_visual_label: Label = $AlvoVisualLabel
@onready var acao_label: Label = $AcaoLabel
@onready var mao_status_label: Label = $MaoStatusLabel
@onready var recompensa_elite: VBoxContainer = $RecompensaElite
@onready var titulo_elite: Label = $RecompensaElite/TituloElite
@onready var indicador_etapa: Label = $RecompensaElite/IndicadorEtapa
@onready var titulo_reliquias: Label = $RecompensaElite/TituloReliquias
@onready var reliquias_elite: HBoxContainer = $RecompensaElite/ReliquiasElite
@onready var reliquia_opcao_1: Button = $RecompensaElite/ReliquiasElite/RelquiaOpcao1
@onready var reliquia_opcao_2: Button = $RecompensaElite/ReliquiasElite/RelquiaOpcao2
@onready var titulo_cartas_raras: Label = $RecompensaElite/TituloCartasRaras
@onready var cartas_raras_elite: HBoxContainer = $RecompensaElite/CartasRarasElite
@onready var carta_rara_opcao_1: Button = $RecompensaElite/CartasRarasElite/CartaRaraOpcao1
@onready var carta_rara_opcao_2: Button = $RecompensaElite/CartasRarasElite/CartaRaraOpcao2
@onready var carta_rara_opcao_3: Button = $RecompensaElite/CartasRarasElite/CartaRaraOpcao3
@onready var consultar_baralho_elite: Button = $RecompensaElite/RecompensaEliteAcoes/ConsultarBaralho
@onready var evento_overlay: Control = $EventoOverlay
@onready var evento_painel: Panel = $EventoPainel
@onready var evento_titulo: Label = $EventoOverlay/EventoTitulo
@onready var evento_faixa_nome: Label = $EventoOverlay/EventoFaixaNome/EventoFaixaNomeLabel
@onready var evento_texto: Label = $EventoOverlay/EventoTexto
@onready var evento_vida_label: Label = $EventoOverlay/EventoVidaLabel
@onready var evento_baralho_label: Label = $EventoOverlay/EventoBaralhoLabel
@onready var evento_opcao_1: Button = $EventoOverlay/EventoOpcoes/EventoOpcao1
@onready var evento_opcao_2: Button = $EventoOverlay/EventoOpcoes/EventoOpcao2
@onready var evento_opcao_3: Button = $EventoOverlay/EventoOpcoes/EventoOpcao3
@onready var evento_resultado: Label = $EventoOverlay/EventoResultado
@onready var evento_continuar: Button = $EventoOverlay/EventoContinuar
@onready var mapa_abrir: Button = $MapaAbrir
@onready var mapa_fundo: TextureRect = $MapaFundo
@onready var mapa_overlay: Control = $MapaOverlay
@onready var mapa_titulo: Label = $MapaOverlay/MapaCabecalho/MapaCabecalhoLinha/MapaTitulo
@onready var mapa_info: Label = $MapaOverlay/MapaInfo
@onready var mapa_distrito: Label = $MapaOverlay/MapaCabecalho/MapaCabecalhoLinha/MapaDistrito
@onready var mapa_vida_label: Label = $MapaOverlay/MapaCabecalho/MapaCabecalhoLinha/MapaRecursos/MapaVidaLabel
@onready var mapa_baralho_label: Label = $MapaOverlay/MapaCabecalho/MapaCabecalhoLinha/MapaRecursos/MapaBaralhoLabel
@onready var mapa_grafo: Control = $MapaOverlay/MapaGrafo
@onready var mapa_conexoes: Control = $MapaOverlay/MapaGrafo/MapaConexoes
@onready var mapa_pontos: Control = $MapaOverlay/MapaGrafo/MapaPontos
@onready var mapa_rotulos_pontos: Control = $MapaOverlay/MapaGrafo/MapaRotulosPontos
@onready var mapa_mensagem: Label = $MapaOverlay/MapaMensagem
@onready var mapa_detalhe: PanelContainer = $MapaOverlay/MapaDetalhe
@onready var mapa_detalhe_icone: TextureRect = $MapaOverlay/MapaDetalhe/MapaDetalheMargem/MapaDetalheConteudo/MapaDetalheLinha/MapaDetalheIcone
@onready var mapa_detalhe_titulo: Label = $MapaOverlay/MapaDetalhe/MapaDetalheMargem/MapaDetalheConteudo/MapaDetalheLinha/MapaDetalheTextos/MapaDetalheTitulo
@onready var mapa_detalhe_tipo: Label = $MapaOverlay/MapaDetalhe/MapaDetalheMargem/MapaDetalheConteudo/MapaDetalheLinha/MapaDetalheTextos/MapaDetalheTipo
@onready var mapa_detalhe_estado: Label = $MapaOverlay/MapaDetalhe/MapaDetalheMargem/MapaDetalheConteudo/MapaDetalheEstado
@onready var mapa_voltar: Button = $MapaOverlay/MapaVoltar
@onready var descanso_overlay: Control = $DescansoOverlay
@onready var recompensa_painel: Panel = $RecompensaPainel
@onready var consultar_baralho: Button = $Recompensas/RecompensaAcoes/ConsultarBaralho
@onready var baralho_overlay: Panel = $BaralhoOverlay
@onready var baralho_resumo: Label = $BaralhoOverlay/BaralhoResumo
@onready var baralho_fechar: Button = $BaralhoOverlay/BaralhoFechar
@onready var baralho_scrim: ColorRect = $BaralhoScrim


func _ready() -> void:
	resultado_label.hide()
	botao_reiniciar.hide()
	recompensas.hide()
	recompensa_painel.hide()
	_preparar_cartas_de_recompensa()
	_ocultar_recompensa_elite()
	evento_overlay.hide()
	evento_painel.hide()
	consultar_baralho.hide()
	baralho_overlay.hide()
	baralho_scrim.hide()
	mapa_fundo.hide()
	mapa_overlay.hide()
	mapa_abrir.hide()
	descanso_overlay.hide()

	botao_reiniciar.pressed.connect(_ao_reiniciar)
	recompensa_opcao_1.pressed.connect(_ao_clicar_recompensa.bind(0))
	recompensa_opcao_2.pressed.connect(_ao_clicar_recompensa.bind(1))
	recompensa_opcao_3.pressed.connect(_ao_clicar_recompensa.bind(2))
	botao_pular_recompensa.pressed.connect(_ao_pular_recompensa)
	consultar_baralho.pressed.connect(_mostrar_consulta_baralho)
	consultar_baralho_elite.pressed.connect(_mostrar_consulta_baralho)
	baralho_fechar.pressed.connect(_fechar_consulta_baralho)
	reliquia_opcao_1.pressed.connect(_ao_selecionar_reliquia.bind(0))
	reliquia_opcao_2.pressed.connect(_ao_selecionar_reliquia.bind(1))
	carta_rara_opcao_1.pressed.connect(_ao_selecionar_carta_rara.bind(0))
	carta_rara_opcao_2.pressed.connect(_ao_selecionar_carta_rara.bind(1))
	carta_rara_opcao_3.pressed.connect(_ao_selecionar_carta_rara.bind(2))
	evento_opcao_1.pressed.connect(_ao_escolher_evento.bind(0))
	evento_opcao_2.pressed.connect(_ao_escolher_evento.bind(1))
	evento_opcao_3.pressed.connect(_ao_escolher_evento.bind(2))
	evento_continuar.pressed.connect(_ao_continuar_evento)
	mapa_abrir.pressed.connect(_abrir_mapa)
	mapa_voltar.pressed.connect(_sair_do_mapa)
	descanso_overlay.recuperar_solicitado.connect(_ao_recuperar_descanso)
	descanso_overlay.aprimorar_solicitado.connect(_ao_aprimorar_descanso)
	descanso_overlay.carta_selecionada.connect(_ao_selecionar_carta_descanso)
	descanso_overlay.voltar_solicitado.connect(_ao_voltar_descanso)
	descanso_overlay.confirmar_solicitado.connect(_ao_confirmar_descanso)
	descanso_overlay.continuar_solicitado.connect(_ao_continuar_descanso)

	grupo_cartas.allow_unpress = true
	get_viewport().size_changed.connect(_redimensionar_cartas_da_mao)
	mapa_grafo.resized.connect(_reorganizar_mapa_visual)
	_redimensionar_tipografia_combate()

	alvo.pressed.connect(_ao_clicar_no_alvo)
	jogador.pressed.connect(_ao_clicar_no_jogador)
	botao_encerrar_turno.pressed.connect(_ao_encerrar_turno)
	_conectar_destaques_hud()

	seletor_inimigos.reiniciar()
	seletor_eventos.reiniciar()
	_iniciar_nova_run()


func _iniciar_nova_run() -> void:
	"""Reseta uma tentativa e gera sua topologia uma única vez."""
	seletor_inimigos.reiniciar()
	seletor_eventos.reiniciar()
	_preparar_baralho_inicial()
	roteiro_run.iniciar()
	jogador_combate.estado.reiniciar(jogador_combate.estado.vida_maxima)
	jogador_combate.energia = ENERGIA_POR_TURNO
	jogador_combate.combo = 0
	jogador_combate.reliquias_run.clear()
	jogador_combate.reliquias_run.append("juntas_retorno")
	encontro_combate.inimigo = null
	baralho_combate.compra.clear()
	baralho_combate.descarte.clear()
	_limpar_mao()
	descanso_ativo = false
	descanso_acao_resolvida = false
	descanso_tela = ""
	aguardando_recompensa = false
	aguardando_recompensa_elite = false
	etapa_recompensa_elite = ""
	aguardando_evento = false
	evento_escolha_resolvida = false
	encontro_especial_pendente = false
	id_evento_atual = ""
	etapa_evento_atual = ""
	mapa_pre_chefe_alcancado = false
	combate_atual = 0
	mapa_pontos_concluidos.clear()
	mapa_no_atual = ""
	mapa_no_em_andamento = ""
	mapa_run.gerar(mapa_variante)
	mapa_gerado = true
	mapa_ativo = true
	mapa_abrir.hide()
	resultado_label.hide()
	botao_reiniciar.hide()
	consultar_baralho.hide()
	consultar_baralho_elite.hide()
	baralho_overlay.hide()
	baralho_scrim.hide()
	_mostrar_mapa("Escolha o ponto inicial da rota.")


func _conectar_destaques_hud() -> void:
	for controle in [alvo, jogador, botao_encerrar_turno]:
		controle.mouse_entered.connect(_atualizar_destaque_hud.bind(controle))
		controle.mouse_exited.connect(_atualizar_destaque_hud.bind(controle))
		controle.focus_entered.connect(_atualizar_destaque_hud.bind(controle))
		controle.focus_exited.connect(_atualizar_destaque_hud.bind(controle))
		_atualizar_destaque_hud(controle)


func _atualizar_destaque_hud(controle: Button) -> void:
	var destaque: Panel = controle.get_node_or_null("Interacao") as Panel
	if destaque == null:
		return
	destaque.visible = not controle.disabled and (controle.is_hovered() or controle.has_focus())


func _preparar_cartas_de_recompensa() -> void:
	var nomes: Array[String] = [
		"RecompensaOpcao1",
		"RecompensaOpcao2",
		"RecompensaOpcao3"
	]
	for indice in range(nomes.size()):
		var antigo: Node = recompensa_cartas.get_node_or_null(nomes[indice])
		if antigo != null:
			recompensa_cartas.remove_child(antigo)
			antigo.queue_free()
		var carta: Button = CENA_CARTA.instantiate() as Button
		carta.name = nomes[indice]
		recompensa_cartas.add_child(carta)
		recompensa_cartas.move_child(carta, indice)

	recompensa_opcao_1 = recompensa_cartas.get_node("RecompensaOpcao1") as Button
	recompensa_opcao_2 = recompensa_cartas.get_node("RecompensaOpcao2") as Button
	recompensa_opcao_3 = recompensa_cartas.get_node("RecompensaOpcao3") as Button


func _combate_terminou() -> bool:
	return encontro_combate.combate_terminou(jogador_combate)


func _mostrar_resultado() -> void:
	descanso_ativo = false
	descanso_tela = ""
	descanso_overlay.hide()
	mapa_ativo = false
	mapa_no_em_andamento = ""
	aguardando_recompensa = false
	aguardando_recompensa_elite = false
	etapa_recompensa_elite = ""
	aguardando_evento = false
	id_evento_atual = ""
	encontro_especial_pendente = false
	id_inimigo_especial = ""
	texto_evento_especial = ""
	recompensas.hide()
	consultar_baralho.hide()
	baralho_overlay.hide()
	_ocultar_recompensa_elite()
	evento_overlay.hide()
	mapa_fundo.hide()
	mapa_overlay.hide()
	mapa_abrir.hide()
	_definir_painel_combate_visivel(false)
	_definir_status_combate_visivel(false)

	if vida_jogador <= 0:
		resultado_label.text = "DERROTA\nVega ficou sem Vida."
	else:
		resultado_label.text = "RUN CONCLUÍDA\nTrês combates vencidos!"

	resultado_label.show()
	botao_reiniciar.show()


func _ao_reiniciar() -> void:
	get_tree().reload_current_scene()


func _preparar_baralho_inicial() -> void:
	# Substitui a instância para não limpar um Array externo atribuído por um preview/teste.
	baralho_run = []

	for i in range(4):
		baralho_run.append("golpe")
		baralho_run.append("protecao")

	for i in range(2):
		baralho_run.append("direto_hidraulico")
		baralho_run.append("quebra_chassi")


func _dados_carta_token(token: String) -> Dictionary:
	var id_base: String = descanso_regras.id_base(token)
	if not CARTAS.has(id_base):
		return {}
	var dados: Dictionary = CARTAS[id_base].duplicate(true)
	if descanso_regras.esta_aprimorada(token):
		return descanso_regras.dados_aprimorados(id_base, dados)
	return dados


func _catalogo_com_token(token: String) -> Dictionary:
	var id_base: String = descanso_regras.id_base(token)
	var catalogo: Dictionary = CARTAS.duplicate(true)
	var dados: Dictionary = _dados_carta_token(token)
	if not dados.is_empty():
		catalogo[id_base] = dados
	return catalogo


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
	consultar_baralho.hide()
	baralho_overlay.hide()
	recompensa_painel.hide()
	recompensa_elite.hide()
	evento_overlay.hide()
	evento_painel.hide()
	_definir_painel_combate_visivel(true)
	_definir_status_combate_visivel(true)

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
	descanso_ativo = false
	descanso_tela = ""
	descanso_overlay.hide()
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
	consultar_baralho.hide()
	baralho_overlay.hide()
	recompensa_painel.hide()
	_ocultar_recompensa_elite()
	evento_overlay.hide()
	evento_painel.hide()
	mapa_fundo.hide()
	mapa_overlay.hide()
	mapa_abrir.hide()
	_definir_painel_combate_visivel(true)
	_definir_status_combate_visivel(true)
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

	if mapa_gerado:
		print("Combate %d iniciado no ponto %d." % [combate_atual, _ponto_mapa_em_execucao()])
	else:
		print("Combate %d de %d iniciado." % [combate_atual, TOTAL_COMBATES])


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
	if aguardando_recompensa or aguardando_recompensa_elite or aguardando_evento:
		return

	if encontro_especial_pendente:
		_mostrar_resultado_evento_especial()
		return

	if mapa_gerado:
		var id_no: String = mapa_no_em_andamento if not mapa_no_em_andamento.is_empty() else mapa_no_atual
		var no_atual: Dictionary = mapa_run.obter_no(id_no)
		if str(no_atual.get("tipo", "")) == MapaRun.TIPO_ELITE:
			_mostrar_recompensa_elite()
		else:
			_mostrar_recompensas()
		return

	if roteiro_run.etapa_atual() == "elite":
		_mostrar_recompensa_elite()
		return

	_mostrar_recompensas()


func _mostrar_resultado_evento_especial() -> void:
	encontro_especial_pendente = false
	aguardando_evento = true
	evento_escolha_resolvida = true
	evento_titulo.text = "EVENTO RESOLVIDO"
	evento_faixa_nome.text = "CONFRONTO RESOLVIDO"
	evento_texto.text = "O confronto terminou."
	evento_texto.hide()
	evento_resultado.text = texto_evento_especial
	evento_resultado.show()
	evento_continuar.show()
	for botao in [evento_opcao_1, evento_opcao_2, evento_opcao_3]:
		botao.hide()
	_definir_painel_combate_visivel(false)
	_definir_status_combate_visivel(false)
	evento_overlay.show()
	evento_painel.hide()
	_transicionar_para_overlay(evento_overlay)
	_atualizar_interface()


func _avancar_roteiro() -> void:
	aguardando_recompensa = false
	aguardando_recompensa_elite = false
	etapa_recompensa_elite = ""
	recompensas.hide()
	consultar_baralho.hide()
	baralho_overlay.hide()
	_ocultar_recompensa_elite()

	if aguardando_evento:
		_ocultar_evento()

	if mapa_gerado:
		_concluir_no_mapa_atual()
		_mostrar_mapa()
		return

	if not roteiro_run.avancar():
		_mostrar_pre_chefe()
		return

	_iniciar_etapa_atual()


func _mostrar_pre_chefe() -> void:
	descanso_ativo = false
	descanso_tela = ""
	descanso_overlay.hide()
	aguardando_recompensa = false
	aguardando_recompensa_elite = false
	aguardando_evento = false
	encontro_especial_pendente = false
	etapa_recompensa_elite = ""
	etapa_evento_atual = ""
	recompensas.hide()
	consultar_baralho.hide()
	baralho_overlay.hide()
	recompensa_painel.hide()
	_ocultar_recompensa_elite()
	evento_overlay.hide()
	evento_painel.hide()
	evento_painel.hide()
	recompensa_painel.hide()
	mapa_fundo.hide()
	mapa_overlay.hide()
	_definir_painel_combate_visivel(false)
	_definir_status_combate_visivel(false)
	resultado_label.text = "RUN PRE-CHEFE\nA rota ate o chefe foi concluida."
	resultado_label.show()
	botao_reiniciar.show()
	mapa_abrir.show()


func _ocultar_recompensa_elite() -> void:
	recompensa_elite.hide()
	consultar_baralho_elite.hide()
	titulo_reliquias.hide()
	reliquias_elite.hide()
	titulo_cartas_raras.hide()
	cartas_raras_elite.hide()


func _definir_painel_combate_visivel(visivel: bool) -> void:
	for no in [
		turno_faixa,
		turno_numero_painel,
		turno_titulo_label,
		turno_numero_label,
		arena_chao,
		mao_dock,
		energia_painel,
		mao,
		mao_status_label,
		mao_icone,
		alvo,
		vida_inimigo_bar,
		vida_inimigo_moldura,
		$VidaInimigoIcone,
		vida_inimigo_label,
		jogador,
		vida_jogador_bar,
		vida_jogador_moldura,
		$VidaJogadorIcone,
		barreira_icone,
		combo_icone,
		reliquia_painel,
		intencao_icone,
		intencao_painel,
		intencao_nome_visual_label,
		intencao_valor_visual_label,
		estados_inimigo_painel,
		estados_inimigo_visual_label,
		alvo_visual_label,
		botao_encerrar_turno
	]:
		no.visible = visivel


func _definir_status_combate_visivel(visivel: bool) -> void:
	for no in [
		pilhas_painel,
		stats_jogador_painel,
		run_status_label,
		energia_icone,
		energia_visual_label,
		vida_jogador_label,
		barreira_label,
		combo_label,
		reliquia_painel,
		reliquia_label,
		acao_label,
			compra_label,
			compra_icone,
			compra_painel,
			descarte_label,
			descarte_icone,
			descarte_painel
		]:
		no.visible = visivel


func _abrir_mapa() -> void:
	if mapa_ativo:
		return

	if not mapa_gerado:
		mapa_run.gerar(mapa_variante)
		mapa_gerado = true
		mapa_pontos_concluidos.clear()
		mapa_no_atual = ""
		mapa_no_em_andamento = ""

	mapa_ativo = true
	var nos_iniciais: Array[String] = mapa_run.nos_no_ponto(1)
	if nos_iniciais.is_empty():
		mapa_ativo = false
		_registrar_acao("Nao foi possivel preparar o mapa.")
		return

	mapa_abrir.hide()
	_mostrar_mapa()


func _sair_do_mapa() -> void:
	if mapa_no_em_andamento != "":
		return
	mapa_ativo = false
	mapa_fundo.hide()
	mapa_overlay.hide()
	mapa_abrir.show()
	resultado_label.text = "MAPA DAS DOCAS\nRetome a rota para continuar."
	resultado_label.show()
	botao_reiniciar.hide()


func _limpar_pontos_do_mapa() -> void:
	for no in mapa_pontos.get_children():
		mapa_pontos.remove_child(no)
		no.queue_free()
	for rotulo in mapa_rotulos_pontos.get_children():
		mapa_rotulos_pontos.remove_child(rotulo)
		rotulo.queue_free()


func _destinos_disponiveis_mapa() -> Array[String]:
	var destinos: Array[String] = []
	if mapa_no_em_andamento != "":
		return destinos
	if mapa_no_atual.is_empty():
		return mapa_run.nos_no_ponto(1)
	for id_destino in mapa_run.destinos_de(mapa_no_atual):
		if mapa_pre_chefe_alcancado and id_destino == "lastro":
			continue
		if not mapa_pontos_concluidos.has(id_destino):
			destinos.append(id_destino)
	return destinos


func _concluir_no_mapa_atual() -> bool:
	if mapa_no_em_andamento.is_empty():
		return false
	var id_concluido: String = mapa_no_em_andamento
	if not mapa_pontos_concluidos.has(id_concluido):
		mapa_pontos_concluidos.append(id_concluido)
	mapa_no_atual = id_concluido
	mapa_no_em_andamento = ""
	return true


func _mostrar_mapa(mensagem: String = "Escolha um destino conectado ao ponto atual.") -> void:
	if not mapa_ativo:
		return
	_montar_mapa_visual(mensagem)
	return

	descanso_ativo = false
	descanso_tela = ""
	descanso_elegiveis.clear()
	descanso_indice_selecionado = -1
	descanso_overlay.hide()
	resultado_label.hide()
	botao_reiniciar.hide()
	recompensas.hide()
	recompensa_painel.hide()
	consultar_baralho.hide()
	consultar_baralho_elite.hide()
	baralho_overlay.hide()
	baralho_scrim.hide()
	_ocultar_recompensa_elite()
	evento_overlay.hide()
	evento_painel.hide()
	mapa_fundo.show()
	mapa_overlay.move_to_front()
	_definir_painel_combate_visivel(false)
	_definir_status_combate_visivel(false)
	_limpar_pontos_do_mapa()

	mapa_titulo.text = "MAPA DAS DOCAS"
	var id_referencia: String = mapa_no_atual
	var texto_ponto: String = "INÍCIO DA ROTA"
	if not id_referencia.is_empty():
		texto_ponto = "PONTO %d/%d" % [
			mapa_run.ponto_do_no(id_referencia),
			mapa_run.total_pontos()
		]
	mapa_info.text = "%s | Variante: %d" % [
		texto_ponto,
		mapa_run.variante
	]
	mapa_mensagem.text = "ATUAL = sua posicao    DESTINOS = disponiveis    CONCLUÍDO = já resolvido\n%s" % mensagem

	var destinos: Array[String] = _destinos_disponiveis_mapa()
	for ponto in range(1, mapa_run.total_pontos() + 1):
		var linha: HBoxContainer = HBoxContainer.new()
		linha.add_theme_constant_override("separation", 8)
		linha.alignment = BoxContainer.ALIGNMENT_CENTER
		var ponto_label: Label = Label.new()
		ponto_label.custom_minimum_size = Vector2(45, 0)
		ponto_label.text = "P%d" % ponto
		linha.add_child(ponto_label)

		for id_no in mapa_run.nos_no_ponto(ponto):
			var dados: Dictionary = mapa_run.obter_no(id_no)
			var botao: Button = Button.new()
			botao.custom_minimum_size = Vector2(230, 58)
			botao.add_theme_font_size_override("font_size", 14)
			botao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			botao.set_meta("id_no", id_no)
			botao.text = "%s\n%s" % [
				str(dados.get("tipo", "")).to_upper(),
				str(dados.get("nome", id_no))
			]
			if id_no == mapa_no_atual:
				botao.text = "ATUAL\n%s" % str(dados.get("nome", id_no))
				botao.disabled = true
				botao.add_theme_stylebox_override(
					"disabled",
					_criar_estilo_mapa(COR_MAPA_ATUAL, Color("#65d6c7"))
				)
				botao.add_theme_color_override("font_disabled_color", COR_MAPA_TEXTO)
			elif mapa_pontos_concluidos.has(id_no):
				botao.text = "CONCLUÍDO\n%s" % str(dados.get("nome", id_no))
				botao.disabled = true
				botao.add_theme_stylebox_override(
					"disabled",
					_criar_estilo_mapa(COR_MAPA_BLOQUEADO, COR_MAPA_BORDA)
				)
				botao.add_theme_color_override("font_disabled_color", COR_MAPA_TEXTO_MUTED)
			elif mapa_pre_chefe_alcancado and id_no == "lastro":
				botao.text = "RESERVADO\n%s" % str(dados.get("nome", id_no))
				botao.disabled = true
				botao.add_theme_stylebox_override(
					"disabled",
					_criar_estilo_mapa(COR_MAPA_BLOQUEADO, Color("#8f5e70"))
				)
				botao.add_theme_color_override("font_disabled_color", COR_MAPA_TEXTO_MUTED)
			else:
				var disponivel: bool = destinos.has(id_no) and mapa_no_em_andamento.is_empty()
				botao.disabled = not disponivel
				var cor_tipo: Color = _cor_do_tipo_mapa(str(dados.get("tipo", "")))
				if disponivel:
					botao.add_theme_stylebox_override(
						"normal",
						_criar_estilo_mapa(COR_MAPA_DESTINO, cor_tipo)
					)
					botao.add_theme_stylebox_override(
						"hover",
						_criar_estilo_mapa(Color("#244d63"), cor_tipo)
					)
					botao.add_theme_stylebox_override(
						"pressed",
						_criar_estilo_mapa(Color("#102a39"), cor_tipo)
					)
					botao.add_theme_color_override("font_color", COR_MAPA_TEXTO)
				else:
					botao.add_theme_stylebox_override(
						"disabled",
						_criar_estilo_mapa(COR_MAPA_BLOQUEADO, COR_MAPA_BORDA)
					)
					botao.add_theme_color_override("font_disabled_color", COR_MAPA_TEXTO_MUTED)
			botao.pressed.connect(_ao_selecionar_no_mapa.bind(id_no))
			linha.add_child(botao)

		mapa_pontos.add_child(linha)

	# A rota agora e o fluxo principal; nao existe uma acao valida para
	# abandonar o mapa sem resolver o no atual. O controle legado permanece
	# conectado para previews antigos, mas nao participa da tela jogavel.
	mapa_voltar.hide()
	mapa_overlay.show()


func _montar_mapa_visual(mensagem: String) -> void:
	descanso_ativo = false
	descanso_tela = ""
	descanso_elegiveis.clear()
	descanso_indice_selecionado = -1
	descanso_overlay.hide()
	resultado_label.hide()
	botao_reiniciar.hide()
	recompensas.hide()
	recompensa_painel.hide()
	consultar_baralho.hide()
	consultar_baralho_elite.hide()
	baralho_overlay.hide()
	baralho_scrim.hide()
	_ocultar_recompensa_elite()
	evento_overlay.hide()
	evento_painel.hide()
	mapa_fundo.show()
	mapa_overlay.move_to_front()
	mapa_detalhe.hide()
	_definir_painel_combate_visivel(false)
	_definir_status_combate_visivel(false)
	_limpar_pontos_do_mapa()

	mapa_titulo.text = "DOCAS"
	mapa_distrito.text = "MAPA DAS DOCAS"
	mapa_vida_label.text = "%d/%d" % [vida_jogador, estado_jogador.vida_maxima]
	mapa_baralho_label.text = str(baralho_run.size())
	var texto_ponto: String = "INÍCIO DA ROTA"
	if not mapa_no_atual.is_empty():
		texto_ponto = "PONTO %d/%d" % [mapa_run.ponto_do_no(mapa_no_atual), mapa_run.total_pontos()]
	mapa_info.text = texto_ponto
	mapa_mensagem.text = "ATUAL = sua posição    DESTINOS = disponíveis    ✓ = concluído\n%s" % mensagem

	var destinos: Array[String] = _destinos_disponiveis_mapa()
	var posicoes: Dictionary = _calcular_posicoes_mapa()
	var estados_linhas: Dictionary = {}
	for origem_variant in mapa_run.nos.keys():
		var origem: String = str(origem_variant)
		for destino in mapa_run.destinos_de(origem):
			estados_linhas["%s>%s" % [origem, destino]] = _estado_da_linha_mapa(destino, destinos)

	for ponto in range(1, mapa_run.total_pontos() + 1):
		for id_no in mapa_run.nos_no_ponto(ponto):
			var dados: Dictionary = mapa_run.obter_no(id_no)
			var estado: String = _estado_do_no_mapa(id_no, destinos)
			var botao: Button = _criar_no_visual_mapa(id_no, dados, estado)
			botao.position = posicoes.get(id_no, Vector2.ZERO) - botao.size * 0.5
			mapa_pontos.add_child(botao)
	_montar_rotulos_pontos_mapa(posicoes)

	mapa_conexoes.configurar(mapa_run.conexoes, posicoes, estados_linhas)
	_reorganizar_mapa_visual()
	mapa_voltar.hide()
	mapa_overlay.show()
	call_deferred("_reorganizar_mapa_visual")


func _montar_rotulos_pontos_mapa(posicoes: Dictionary) -> void:
	for rotulo_variant in mapa_rotulos_pontos.get_children():
		var rotulo_antigo: Node = rotulo_variant as Node
		mapa_rotulos_pontos.remove_child(rotulo_antigo)
		rotulo_antigo.queue_free()
	var area: Vector2 = mapa_grafo.size
	for ponto in range(1, mapa_run.total_pontos() + 1):
		var ids: Array[String] = mapa_run.nos_no_ponto(ponto)
		if ids.is_empty():
			continue
		var centro: Vector2 = posicoes.get(ids[0], Vector2.ZERO)
		var rotulo: Label = Label.new()
		rotulo.name = "MapaPontoLabel%d" % ponto
		rotulo.position = Vector2(centro.x - 30.0, area.y - 28.0)
		rotulo.size = Vector2(60.0, 22.0)
		rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rotulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rotulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		rotulo.add_theme_font_size_override("font_size", 13)
		rotulo.add_theme_color_override("font_color", COR_MAPA_TEXTO_MUTED)
		rotulo.text = "P%d" % ponto
		mapa_rotulos_pontos.add_child(rotulo)


func _criar_no_visual_mapa(id_no: String, dados: Dictionary, estado: String) -> Button:
	var botao: Button = Button.new()
	botao.name = "MapaNo_%s" % id_no
	botao.custom_minimum_size = Vector2(88, 88)
	botao.size = Vector2(88, 88)
	botao.focus_mode = Control.FOCUS_ALL
	botao.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	botao.text = ""
	botao.tooltip_text = "%s\n%s" % [str(dados.get("nome", id_no)), _texto_tipo_mapa(str(dados.get("tipo", "")))]
	botao.set_meta("id_no", id_no)
	botao.set_meta("estado_mapa", estado)
	botao.disabled = estado in ["indisponivel", "atual", "concluido", "reservado"]
	var tipo: String = str(dados.get("tipo", ""))
	var cor_tipo: Color = _cor_do_tipo_mapa(tipo)
	for estado_visual in ["normal", "hover", "focus", "pressed", "hover_pressed", "disabled"]:
		botao.add_theme_stylebox_override(estado_visual, ESTILO_MAPA_NODE_NORMAL)
	if estado == "disponivel":
		botao.modulate = Color.WHITE
	elif estado == "atual":
		botao.modulate = Color("#b4fff0")
	elif estado == "concluido":
		botao.modulate = Color("#65737b")
	elif estado == "reservado":
		botao.modulate = Color("#9c647b")
	else:
		botao.modulate = Color("#52606a")

	var icone: TextureRect = TextureRect.new()
	icone.name = "Icone"
	icone.set_anchors_preset(Control.PRESET_FULL_RECT)
	icone.offset_left = 16.0
	icone.offset_top = 9.0
	icone.offset_right = -16.0
	icone.offset_bottom = -23.0
	icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone.texture = _icone_do_tipo_mapa(tipo)
	icone.modulate = Color.WHITE if estado in ["disponivel", "atual"] else Color(0.78, 0.84, 0.87, 1)
	botao.add_child(icone)

	var marcador: Label = Label.new()
	marcador.name = "Marcador"
	marcador.set_anchors_preset(Control.PRESET_FULL_RECT)
	marcador.offset_left = 5.0
	marcador.offset_top = 66.0
	marcador.offset_right = -5.0
	marcador.offset_bottom = -3.0
	marcador.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marcador.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marcador.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marcador.add_theme_font_size_override("font_size", 11)
	marcador.add_theme_color_override("font_color", Color("#68e8f4") if estado == "disponivel" else cor_tipo)
	marcador.text = _texto_estado_mapa(estado)
	botao.add_child(marcador)

	var interacao: Panel = Panel.new()
	interacao.name = "Interacao"
	interacao.set_anchors_preset(Control.PRESET_FULL_RECT)
	interacao.offset_left = 4.0
	interacao.offset_top = 4.0
	interacao.offset_right = -4.0
	interacao.offset_bottom = -4.0
	interacao.mouse_filter = Control.MOUSE_FILTER_IGNORE
	interacao.z_index = 4
	interacao.add_theme_stylebox_override("panel", _criar_estilo_interacao_mapa())
	interacao.visible = false
	botao.add_child(interacao)

	botao.pressed.connect(_ao_selecionar_no_mapa.bind(id_no))
	botao.mouse_entered.connect(_mostrar_detalhes_mapa.bind(id_no))
	botao.focus_entered.connect(_mostrar_detalhes_mapa.bind(id_no))
	botao.mouse_entered.connect(_atualizar_interacao_mapa.bind(botao, interacao))
	botao.mouse_exited.connect(_atualizar_interacao_mapa.bind(botao, interacao))
	botao.focus_entered.connect(_atualizar_interacao_mapa.bind(botao, interacao))
	botao.focus_exited.connect(_atualizar_interacao_mapa.bind(botao, interacao))
	botao.mouse_exited.connect(_esconder_detalhes_mapa.bind(id_no, botao))
	botao.focus_exited.connect(_esconder_detalhes_mapa.bind(id_no, botao))
	return botao


func _criar_estilo_interacao_mapa() -> StyleBoxFlat:
	var estilo: StyleBoxFlat = StyleBoxFlat.new()
	estilo.bg_color = Color(0, 0, 0, 0)
	estilo.border_color = Color("#27d9ef")
	estilo.set_border_width_all(2)
	return estilo


func _atualizar_interacao_mapa(botao: Button, interacao: Panel) -> void:
	interacao.visible = not botao.disabled and (
		botao.is_hovered() or botao.has_focus() or bool(botao.get_meta("preview_hover", false))
	)


func _calcular_posicoes_mapa() -> Dictionary:
	var area: Vector2 = mapa_grafo.size
	if area.x <= 0.0 or area.y <= 0.0:
		area = Vector2(1024, 350)
	var resultado: Dictionary = {}
	for ponto in range(1, mapa_run.total_pontos() + 1):
		var ids: Array[String] = mapa_run.nos_no_ponto(ponto)
		for indice in range(ids.size()):
			var x: float = lerp(52.0, area.x - 52.0, float(ponto - 1) / float(mapa_run.total_pontos() - 1))
			var y: float = area.y * 0.5
			if ids.size() > 1:
				y += -70.0 if indice == 0 else 70.0
			resultado[ids[indice]] = Vector2(x, y)
	return resultado


func _reorganizar_mapa_visual() -> void:
	if mapa_grafo == null or mapa_pontos == null:
		return
	var posicoes: Dictionary = _calcular_posicoes_mapa()
	for filho_variant in mapa_pontos.get_children():
		var no: Control = filho_variant as Control
		if no == null or not no.has_meta("id_no"):
			continue
		var id_no: String = str(no.get_meta("id_no"))
		no.position = posicoes.get(id_no, Vector2.ZERO) - no.size * 0.5
	var area: Vector2 = mapa_grafo.size
	for ponto in range(1, mapa_run.total_pontos() + 1):
		var ids: Array[String] = mapa_run.nos_no_ponto(ponto)
		if ids.is_empty():
			continue
		var rotulo: Label = mapa_rotulos_pontos.get_node_or_null("MapaPontoLabel%d" % ponto) as Label
		if rotulo == null:
			continue
		var centro: Vector2 = posicoes.get(ids[0], Vector2.ZERO)
		rotulo.position = Vector2(centro.x - 30.0, area.y - 28.0)
	mapa_conexoes.atualizar_posicoes(posicoes)


func _estado_do_no_mapa(id_no: String, destinos: Array[String]) -> String:
	if id_no == mapa_no_atual:
		return "atual"
	if mapa_pontos_concluidos.has(id_no):
		return "concluido"
	if mapa_pre_chefe_alcancado and id_no == "lastro":
		return "reservado"
	if destinos.has(id_no) and mapa_no_em_andamento.is_empty():
		return "disponivel"
	return "indisponivel"


func _estado_da_linha_mapa(destino: String, destinos: Array[String]) -> String:
	if mapa_pontos_concluidos.has(destino):
		return "percorrida"
	if destinos.has(destino):
		return "disponivel"
	return "futura"


func _mostrar_detalhes_mapa(id_no: String) -> void:
	var dados: Dictionary = mapa_run.obter_no(id_no)
	if dados.is_empty():
		return
	var tipo: String = str(dados.get("tipo", ""))
	mapa_detalhe_icone.texture = _icone_do_tipo_mapa(tipo)
	mapa_detalhe_titulo.text = str(dados.get("nome", id_no))
	mapa_detalhe_tipo.text = _texto_tipo_mapa(tipo)
	mapa_detalhe_estado.text = _texto_estado_mapa(_estado_do_no_mapa(id_no, _destinos_disponiveis_mapa()))
	mapa_detalhe.show()


func _esconder_detalhes_mapa(_id_no: String, botao: Button) -> void:
	if not botao.has_focus() and not botao.is_hovered():
		mapa_detalhe.hide()


func _texto_tipo_mapa(tipo: String) -> String:
	if tipo == MapaRun.TIPO_COMBATE:
		return "COMBATE"
	if tipo == MapaRun.TIPO_EVENTO:
		return "EVENTO"
	if tipo == MapaRun.TIPO_ELITE:
		return "ELITE"
	if tipo == MapaRun.TIPO_DESCANSO:
		return "DESCANSO"
	if tipo == MapaRun.TIPO_CHEFE:
		return "CHEFE"
	return "ENCONTRO"


func _texto_estado_mapa(estado: String) -> String:
	if estado == "atual":
		return "ATUAL"
	if estado == "concluido":
		return "✓ CONCLUÍDO"
	if estado == "disponivel":
		return "IR"
	if estado == "reservado":
		return "RESERVADO"
	return ""


func _icone_do_tipo_mapa(tipo: String) -> Texture2D:
	if tipo == MapaRun.TIPO_COMBATE:
		return ICONE_MAPA_COMBATE
	if tipo == MapaRun.TIPO_EVENTO:
		return ICONE_MAPA_EVENTO
	if tipo == MapaRun.TIPO_ELITE:
		return ICONE_MAPA_ELITE
	if tipo == MapaRun.TIPO_DESCANSO:
		return ICONE_MAPA_DESCANSO
	return ICONE_MAPA_CHEFE


func _preparar_item_descanso(item: Dictionary, dados: Dictionary) -> Dictionary:
	var copia: Dictionary = item.duplicate(true)
	copia["dados"] = dados.duplicate(true)
	copia["descricao"] = _descricao_recompensa(dados)
	copia["tooltip"] = _tooltip_recompensa(dados)
	return copia


func _mostrar_descanso() -> void:
	if not mapa_ativo or descanso_ativo:
		return
	descanso_ativo = true
	descanso_acao_resolvida = false
	descanso_tela = "inicio"
	descanso_indice_selecionado = -1
	descanso_elegiveis.clear()
	for item in descanso_regras.cartas_elegiveis(baralho_run):
		var id_carta: String = str(item.get("id", ""))
		if CARTAS.has(id_carta):
			descanso_elegiveis.append(_preparar_item_descanso(item, _dados_carta_token(str(item.get("token", id_carta)))))
	var cura: int = descanso_regras.vida_a_recuperar(vida_jogador, jogador_combate.estado.vida_maxima)
	mapa_fundo.hide()
	mapa_overlay.hide()
	mapa_abrir.hide()
	recompensas.hide()
	recompensa_painel.hide()
	_ocultar_recompensa_elite()
	evento_overlay.hide()
	evento_painel.hide()
	baralho_overlay.hide()
	baralho_scrim.hide()
	consultar_baralho.hide()
	consultar_baralho_elite.hide()
	resultado_label.hide()
	botao_reiniciar.hide()
	_definir_painel_combate_visivel(false)
	_definir_status_combate_visivel(false)
	descanso_overlay.call("mostrar_resumo", vida_jogador, jogador_combate.estado.vida_maxima, baralho_run.size(), cura, descanso_elegiveis)
	descanso_overlay.show()


func _ao_recuperar_descanso() -> void:
	if not descanso_ativo or descanso_acao_resolvida:
		return
	var cura: int = descanso_regras.vida_a_recuperar(vida_jogador, jogador_combate.estado.vida_maxima)
	if cura <= 0:
		return
	vida_jogador = mini(jogador_combate.estado.vida_maxima, vida_jogador + cura)
	descanso_acao_resolvida = true
	descanso_tela = "resultado"
	descanso_overlay.call("atualizar_resumo", vida_jogador, baralho_run.size())
	descanso_overlay.call(
		"mostrar_resultado",
		"RECUPERAR",
		"+%d Vida." % cura,
		vida_jogador,
		jogador_combate.estado.vida_maxima,
		"VIDA %d/%d" % [vida_jogador, jogador_combate.estado.vida_maxima]
	)


func _ao_aprimorar_descanso() -> void:
	if not descanso_ativo or descanso_acao_resolvida or descanso_elegiveis.is_empty():
		return
	descanso_tela = "selecao"
	descanso_overlay.call("mostrar_selecao", descanso_elegiveis)


func _item_elegivel_descanso(indice: int) -> Dictionary:
	for item in descanso_elegiveis:
		if int(item.get("indice", -1)) == indice:
			return item
	return {}


func _ao_selecionar_carta_descanso(indice: int) -> void:
	if not descanso_ativo or descanso_acao_resolvida or descanso_tela != "selecao":
		return
	var item: Dictionary = _item_elegivel_descanso(indice)
	if item.is_empty():
		return
	descanso_indice_selecionado = indice
	var id_carta: String = str(item.get("id", ""))
	var dados_antes: Dictionary = item.get("dados", {}) as Dictionary
	var dados_depois: Dictionary = descanso_regras.dados_aprimorados(id_carta, dados_antes)
	var antes: Dictionary = _preparar_item_descanso(item, dados_antes)
	var depois: Dictionary = _preparar_item_descanso(item, dados_depois)
	depois["melhoria"] = _resumo_melhoria_descanso(dados_antes, dados_depois)
	descanso_tela = "comparacao"
	descanso_overlay.call("mostrar_comparacao", antes, depois)


func _ao_voltar_descanso() -> void:
	if not descanso_ativo or descanso_acao_resolvida:
		return
	if descanso_tela == "comparacao":
		descanso_tela = "selecao"
		descanso_overlay.call("mostrar_selecao", descanso_elegiveis)
	elif descanso_tela == "selecao":
		descanso_tela = "inicio"
		var cura: int = descanso_regras.vida_a_recuperar(vida_jogador, jogador_combate.estado.vida_maxima)
		descanso_overlay.call("mostrar_resumo", vida_jogador, jogador_combate.estado.vida_maxima, baralho_run.size(), cura, descanso_elegiveis)


func _ao_confirmar_descanso(indice: int) -> void:
	if not descanso_ativo or descanso_acao_resolvida or descanso_tela != "comparacao":
		return
	if indice != descanso_indice_selecionado:
		return
	var item: Dictionary = _item_elegivel_descanso(indice)
	if item.is_empty():
		return
	var id_carta: String = str(item.get("id", ""))
	var dados_antes: Dictionary = item.get("dados", {}) as Dictionary
	var dados_depois: Dictionary = descanso_regras.dados_aprimorados(id_carta, dados_antes)
	if not descanso_regras.aplicar_melhoria(baralho_run, indice):
		return
	descanso_acao_resolvida = true
	descanso_tela = "resultado"
	descanso_overlay.call("atualizar_resumo", vida_jogador, baralho_run.size())
	descanso_overlay.call(
		"mostrar_resultado",
		"%s APRIMORADO" % str(dados_antes.get("nome", id_carta)).to_upper(),
		_resumo_melhoria_descanso(dados_antes, dados_depois),
		vida_jogador,
		jogador_combate.estado.vida_maxima,
		""
	)


func _ao_continuar_descanso() -> void:
	if not descanso_ativo or not descanso_acao_resolvida:
		return
	descanso_ativo = false
	descanso_tela = ""
	descanso_elegiveis.clear()
	descanso_indice_selecionado = -1
	descanso_overlay.hide()
	_concluir_no_mapa_atual()
	_mostrar_mapa("Descanso concluído. Escolha o próximo destino.")


func _ao_selecionar_no_mapa(id_no: String) -> void:
	if not mapa_ativo or not mapa_no_em_andamento.is_empty():
		return
	if not _destinos_disponiveis_mapa().has(id_no):
		return

	mapa_no_em_andamento = id_no
	var dados: Dictionary = mapa_run.obter_no(id_no)
	var tipo: String = str(dados.get("tipo", ""))
	var id_conteudo: String = str(dados.get("id_conteudo", ""))
	mapa_overlay.hide()

	if tipo == MapaRun.TIPO_COMBATE or tipo == MapaRun.TIPO_ELITE:
		combate_atual += 1
		_iniciar_combate_por_id(id_conteudo, false)
		return

	if tipo == MapaRun.TIPO_EVENTO:
		mapa_fundo.hide()
		etapa_evento_atual = id_conteudo
		_mostrar_evento(etapa_evento_atual)
		return

	if tipo == MapaRun.TIPO_DESCANSO:
		_mostrar_descanso()
		return

	if tipo == MapaRun.TIPO_CHEFE:
		mapa_pre_chefe_alcancado = true
		mapa_no_em_andamento = ""
		mapa_ativo = false
		mapa_fundo.hide()
		mapa_abrir.hide()
		resultado_label.text = "RUN PRE-CHEFE\nLastro ainda nao foi implementado."
		resultado_label.show()
		botao_reiniciar.show()


func _criar_estilo_mapa(cor_fundo: Color, cor_borda: Color) -> StyleBoxFlat:
	var estilo: StyleBoxFlat = StyleBoxFlat.new()
	estilo.bg_color = cor_fundo
	estilo.border_color = cor_borda
	estilo.set_border_width_all(1)
	estilo.set_corner_radius_all(6)
	estilo.content_margin_left = 12.0
	estilo.content_margin_right = 12.0
	estilo.content_margin_top = 8.0
	estilo.content_margin_bottom = 8.0
	return estilo


func _cor_do_tipo_mapa(tipo: String) -> Color:
	if tipo == MapaRun.TIPO_ELITE:
		return Color("#d68cff")
	if tipo == MapaRun.TIPO_CHEFE:
		return Color("#ff8b8b")
	if tipo == MapaRun.TIPO_DESCANSO:
		return Color("#72d7a0")
	if tipo == MapaRun.TIPO_EVENTO:
		return Color("#e5c16d")
	return Color("#67bde8")


func _mostrar_evento(id_evento: String) -> void:
	descanso_ativo = false
	descanso_tela = ""
	descanso_overlay.hide()
	var dados: Dictionary = DadosEventos.obter(id_evento)
	if dados.is_empty():
		return

	aguardando_evento = true
	evento_escolha_resolvida = false
	id_evento_atual = id_evento
	etapa_evento_atual = id_evento
	aguardando_recompensa = false
	aguardando_recompensa_elite = false
	etapa_recompensa_elite = ""
	recompensas.hide()
	recompensa_painel.hide()
	_ocultar_recompensa_elite()
	resultado_label.hide()
	botao_reiniciar.hide()

	evento_titulo.text = "ENCONTRO"
	evento_faixa_nome.text = str(dados["nome"])
	evento_texto.text = str(dados["descricao"])
	evento_texto.show()
	evento_resultado.hide()
	evento_continuar.hide()

	var botoes: Array[Button] = [evento_opcao_1, evento_opcao_2, evento_opcao_3]
	for botao in botoes:
		botao.hide()
		botao.disabled = false

	var opcoes: Array = dados.get("opcoes", [])
	for indice in range(mini(opcoes.size(), botoes.size())):
		var opcao: Dictionary = opcoes[indice]
		botoes[indice].call(
			"configurar_evento",
			str(opcao.get("nome", "Opção")),
			_resumo_opcao_evento(opcao),
			"combate" if str(opcao.get("tipo", "")) == "combate_especial" else ""
		)
		botoes[indice].show()

	_definir_painel_combate_visivel(false)
	_definir_status_combate_visivel(false)
	evento_overlay.show()
	evento_painel.hide()
	_transicionar_para_overlay(evento_overlay)
	_atualizar_interface()


func _ocultar_evento() -> void:
	aguardando_evento = false
	evento_escolha_resolvida = false
	id_evento_atual = ""
	evento_overlay.hide()
	evento_painel.hide()
	_definir_painel_combate_visivel(true)
	_definir_status_combate_visivel(true)
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
	if not aguardando_evento or evento_escolha_resolvida:
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
		evento_escolha_resolvida = true
		encontro_especial_pendente = true
		combate_atual += 1
		id_inimigo_especial = str(resultado["id_inimigo"])
		texto_evento_especial = str(resultado["texto"])
		_ocultar_evento()
		_iniciar_combate_por_id(id_inimigo_especial, false)
		return

	for botao in [evento_opcao_1, evento_opcao_2, evento_opcao_3]:
		botao.disabled = true
		botao.hide()
	evento_escolha_resolvida = true
	evento_texto.hide()
	evento_resultado.text = str(resultado["texto"])
	evento_resultado.show()
	evento_continuar.show()
	_atualizar_interface()


func _ao_continuar_evento() -> void:
	if not aguardando_evento or not evento_escolha_resolvida:
		return
	_avancar_roteiro()


func _resumo_opcao_evento(opcao: Dictionary) -> String:
	var tipo: String = str(opcao.get("tipo", "concluido"))
	if tipo == "vida":
		var delta: int = int(opcao.get("vida_delta", 0))
		if delta < 0:
			return "Custo: %d Vida." % abs(delta)
		if delta > 0:
			return "Recupera %d Vida." % delta
	if tipo == "combate_especial":
		return "Combate"
	return ""


func _mostrar_recompensas() -> void:
	if not mapa_no_em_andamento.is_empty() and not mapa_gerado:
		return
	aguardando_recompensa = true
	oferta_recompensa.gerar(RECOMPENSAS_DISPONIVEIS, QUANTIDADE_OPCOES_RECOMPENSA)

	var botoes: Array[Button] = [
		recompensa_opcao_1,
		recompensa_opcao_2,
		recompensa_opcao_3
	]
	for indice in range(botoes.size()):
		var dados: Dictionary = CARTAS[oferta_recompensa.opcoes[indice]]
		botoes[indice].set("nome_carta", dados["nome"])
		botoes[indice].set("custo", dados["custo"])
		botoes[indice].set("descricao", _descricao_recompensa(dados))
		botoes[indice].call("aplicar_visual", oferta_recompensa.opcoes[indice], dados.get("tipo", "ataque"))
		botoes[indice].call("configurar_escala", _escala_recompensa())
		botoes[indice].call("configurar_recompensa", _tooltip_recompensa(dados))
		botoes[indice].show()

	botao_pular_recompensa.show()

	resultado_label.text = "VITÓRIA\nEscolha uma carta"
	resultado_label.show()
	_definir_painel_combate_visivel(false)
	_definir_status_combate_visivel(false)
	recompensas.show()
	recompensa_painel.hide()
	consultar_baralho.show()
	_transicionar_para_overlay(recompensas)
	botao_reiniciar.hide()

	print("Aguardando escolha de recompensa.")


func _escala_recompensa() -> float:
	return clampf(get_viewport().get_visible_rect().size.x / 880.0, 1.35, 2.05)


func _mostrar_consulta_baralho() -> void:
	if not aguardando_recompensa and not aguardando_recompensa_elite:
		return
	foco_recompensa_anterior = get_viewport().gui_get_focus_owner() as Control
	if foco_recompensa_anterior == null or not _foco_pertence_a_oferta(foco_recompensa_anterior):
		foco_recompensa_anterior = recompensa_opcao_1 if aguardando_recompensa else (reliquia_opcao_1 if etapa_recompensa_elite == "reliquia" else carta_rara_opcao_1)
	for controle in _controles_da_oferta_atual():
		controle.disabled = true
	recompensas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	recompensa_elite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var contagem: Dictionary = {}
	for id_carta in baralho_run:
		var id_base: String = descanso_regras.id_base(id_carta)
		contagem[id_base] = int(contagem.get(id_base, 0)) + 1
	var linhas: PackedStringArray = ["%d cartas no baralho" % baralho_run.size()]
	for id_carta in contagem.keys():
		linhas.append("%s x%d" % [str(CARTAS[id_carta]["nome"]), contagem[id_carta]])
	baralho_resumo.text = "\n".join(linhas)
	baralho_scrim.show()
	baralho_overlay.show()


func _fechar_consulta_baralho() -> void:
	baralho_overlay.hide()
	baralho_scrim.hide()
	recompensas.mouse_filter = Control.MOUSE_FILTER_PASS
	recompensa_elite.mouse_filter = Control.MOUSE_FILTER_PASS
	for controle in _controles_da_oferta_atual():
		controle.disabled = false
	if is_instance_valid(foco_recompensa_anterior):
		foco_recompensa_anterior.grab_focus()


func _foco_pertence_a_oferta(foco: Control) -> bool:
	if aguardando_recompensa_elite:
		return recompensa_elite.is_ancestor_of(foco)
	return recompensa_cartas.is_ancestor_of(foco)


func _controles_da_oferta_atual() -> Array[Button]:
	if aguardando_recompensa_elite:
		if etapa_recompensa_elite == "reliquia":
			return [reliquia_opcao_1, reliquia_opcao_2, consultar_baralho_elite]
		return [carta_rara_opcao_1, carta_rara_opcao_2, carta_rara_opcao_3, consultar_baralho_elite]
	return [recompensa_opcao_1, recompensa_opcao_2, recompensa_opcao_3, botao_pular_recompensa, consultar_baralho]


func _mostrar_recompensa_elite() -> void:
	if not mapa_no_em_andamento.is_empty() and aguardando_recompensa_elite:
		return
	_definir_painel_combate_visivel(false)
	_definir_status_combate_visivel(false)
	aguardando_recompensa_elite = true
	etapa_recompensa_elite = "reliquia"
	oferta_reliquias.gerar(
		DadosReliquias.identificadores_sem(jogador_combate.reliquias_run),
		2
	)
	oferta_cartas_raras.gerar(DADOS_CARTAS.identificadores_por_raridade("rara"), 3)

	resultado_label.text = "ELITE VENCIDO\nEscolha uma relíquia"
	resultado_label.hide()
	recompensas.hide()
	# A recompensa elite usa somente o fundo HQ; a moldura larga pertence ao fluxo comum.
	recompensa_painel.hide()
	recompensa_elite.show()
	recompensa_elite.mouse_filter = Control.MOUSE_FILTER_PASS
	consultar_baralho_elite.show()
	indicador_etapa.text = "RELIQUIA  •  1/2"
	titulo_reliquias.show()
	reliquias_elite.show()
	titulo_cartas_raras.hide()
	cartas_raras_elite.hide()
	_preencher_opcoes_reliquias()
	_transicionar_para_overlay(recompensa_elite)
	reliquia_opcao_1.grab_focus()
	botao_reiniciar.hide()

	print("Aguardando escolha de relíquia do elite.")


func _preencher_opcoes_reliquias() -> void:
	if oferta_reliquias.opcoes.size() < 2:
		return

	var dados_1: Dictionary = DadosReliquias.obter(oferta_reliquias.opcoes[0])
	var dados_2: Dictionary = DadosReliquias.obter(oferta_reliquias.opcoes[1])
	reliquia_opcao_1.call("configurar_recompensa", dados_1)
	reliquia_opcao_2.call("configurar_recompensa", dados_2)
	reliquia_opcao_1.show()
	reliquia_opcao_2.show()


func _preencher_opcoes_cartas_raras() -> void:
	if oferta_cartas_raras.opcoes.size() < 3:
		return

	var cartas: Array[Button] = [carta_rara_opcao_1, carta_rara_opcao_2, carta_rara_opcao_3]
	for indice in range(cartas.size()):
		var id_carta: String = oferta_cartas_raras.opcoes[indice]
		var dados: Dictionary = CARTAS[id_carta]
		var carta: Button = cartas[indice]
		carta.set("nome_carta", dados["nome"])
		carta.set("custo", dados["custo"])
		carta.set("descricao", _descricao_recompensa(dados))
		carta.call("aplicar_visual", id_carta, dados.get("tipo", "ataque"))
		carta.call("configurar_escala", _escala_recompensa())
		carta.call("configurar_recompensa", _tooltip_recompensa(dados))
		var raridade_pill: Control = carta.get_node_or_null("RaridadePill") as Control
		if raridade_pill != null:
			raridade_pill.show()
		carta.show()


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

	reliquia_opcao_1.disabled = true
	reliquia_opcao_2.disabled = true
	etapa_recompensa_elite = "carta_rara"
	resultado_label.hide()
	titulo_reliquias.hide()
	reliquias_elite.hide()
	titulo_cartas_raras.show()
	cartas_raras_elite.show()
	indicador_etapa.text = "CARTA RARA  •  2/2"
	_preencher_opcoes_cartas_raras()
	carta_rara_opcao_1.grab_focus()
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


func _resumo_melhoria_descanso(dados_antes: Dictionary, dados_depois: Dictionary) -> String:
	if dados_antes.has("valor") and dados_depois.has("valor"):
		var valor_antes: int = int(dados_antes.get("valor", 0))
		var valor_depois: int = int(dados_depois.get("valor", 0))
		if valor_antes != valor_depois:
			var rotulo_valor: String = "Dano" if str(dados_antes.get("tipo", "ataque")) == "ataque" else "Valor"
			if dados_antes.get("finalizacao", false):
				rotulo_valor = "Dano base"
			return "%s: %d → %d" % [rotulo_valor, valor_antes, valor_depois]
	if dados_antes.has("barreira") and dados_depois.has("barreira"):
		var barreira_antes: int = int(dados_antes.get("barreira", 0))
		var barreira_depois: int = int(dados_depois.get("barreira", 0))
		if barreira_antes != barreira_depois:
			return "Barreira: %d → %d" % [barreira_antes, barreira_depois]
	return "Efeito principal aprimorado."


func _descricao_recompensa(dados: Dictionary) -> String:
	if dados.get("finalizacao", false):
		return "Consome todo o Combo.\n%d + %d por Combo de dano." % [dados["valor"], dados["bonus_combo"]]
	if dados.get("tipo", "ataque") == "ataque":
		var linhas_ataque: PackedStringArray = ["%d de dano." % dados["valor"]]
		if dados.has("exposto"):
			linhas_ataque.append("Aplica Exposto %d." % dados["exposto"])
		if dados.has("barreira"):
			linhas_ataque.append("Ganha %d de Barreira." % dados["barreira"])
		linhas_ataque.append("Ganha 1 Combo.")
		return "\n".join(linhas_ataque)
	if dados.has("enfraquecido"):
		var linhas_habilidade: PackedStringArray = ["Aplica Enfraquecido %d." % dados["enfraquecido"]]
		if dados.get("barreira", 0) > 0:
			linhas_habilidade.append("Ganha %d de Barreira." % dados["barreira"])
		return "\n".join(linhas_habilidade)
	return "Ganha %d de Barreira." % dados.get("barreira", dados.get("valor", 0))


func _tooltip_recompensa(dados: Dictionary) -> String:
	var linhas: PackedStringArray = []
	if dados.get("finalizacao", false):
		linhas.append("Finalização: consome todo o Combo.")
	if dados.has("exposto"):
		linhas.append("Exposto: os próximos golpes recebem dano adicional.")
	if dados.has("enfraquecido"):
		linhas.append("Enfraquecido: reduz os próximos golpes inimigos.")
	if dados.has("barreira"):
		linhas.append("Barreira: absorve dano até ser consumida.")
	if linhas.is_empty() and dados.get("tipo", "ataque") == "habilidade":
		linhas.append("Barreira: absorve dano até ser consumida.")
	if linhas.is_empty() and dados.get("tipo", "ataque") == "ataque":
		linhas.append("Combo: ataques acumulam Combo.")
	return "\n".join(linhas)


func _transicionar_para_overlay(overlay: Control) -> void:
	overlay.pivot_offset = overlay.size * 0.5
	overlay.modulate.a = 0.0
	overlay.scale = Vector2(0.98, 0.98)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(overlay, "modulate:a", 1.0, 0.22)
	tween.parallel().tween_property(overlay, "scale", Vector2.ONE, 0.22)


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
	_animar_faixa_turno()

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
	var id_base: String = descanso_regras.id_base(id_carta)
	var dados: Dictionary = _dados_carta_token(id_carta)
	if dados.is_empty():
		return
	var nova_carta: Button = CENA_CARTA.instantiate() as Button
	var valor: int = dados["valor"]
	var descricao: String = ""
	var eh_ataque: bool = dados.get("tipo", "ataque") == "ataque"

	if dados.get("finalizacao", false):
		var bonus_combo: int = dados["bonus_combo"]
		descricao = "Consome todo Combo.\n%d + %d/Combo dano." % [
			valor,
			bonus_combo
		]
	elif eh_ataque and dados["alvo"] == "inimigo":
		descricao = "%d dano" % valor

		if dados.has("exposto"):
			descricao += " · Exposto %d" % dados["exposto"]

		if dados.has("barreira"):
			descricao += "\n+%d Barreira" % dados["barreira"]

		descricao += "\n+1 Combo"
	elif dados["alvo"] == "inimigo":
		descricao = "Enfraquecido %d" % dados["enfraquecido"]

		if dados.has("barreira"):
			descricao += "\n+%d Barreira" % dados["barreira"]
	else:
		descricao = "+%d Barreira" % valor

	nova_carta.set("nome_carta", dados["nome"])
	nova_carta.set("custo", dados["custo"])
	nova_carta.set("descricao", descricao)
	nova_carta.set_meta("id_carta", id_carta)

	nova_carta.button_group = grupo_cartas
	nova_carta.button_pressed = false
	nova_carta.disabled = false

	mao.add_child(nova_carta)
	nova_carta.call("configurar_escala", _escala_mao_atual(), true)
	nova_carta.call("aplicar_visual", id_base, str(dados.get("tipo", "ataque")))
	var centro: float = float(mao.get_child_count() - 1) * 0.5
	var deslocamento: float = float(mao.get_child_count() - 1) - centro
	var rotacao: float = deslocamento * 0.014 if mao.get_child_count() <= 6 else 0.0
	nova_carta.rotation = rotacao
	if mao.get_child_count() > 6:
		for no in mao.get_children():
			(no as Control).rotation = 0.0
	nova_carta.call("animar_entrada", float(mao.get_child_count() - 1) * 0.035)
	call_deferred("_redimensionar_cartas_da_mao")
	call_deferred("_normalizar_rotacao_mao")


func _escala_interface() -> float:
	var tamanho: Vector2 = get_viewport().get_visible_rect().size
	return minf(tamanho.x / 1280.0, tamanho.y / 720.0)


func _escala_mao_atual() -> float:
	# A legibilidade da carta continua constante. Quando a mão cresce, a
	# contenção é resolvida pela separação entre cartas, não pela redução da
	# arte, do custo ou da descrição.
	return _escala_interface()


func _separacao_mao_atual(escala: float) -> float:
	var quantidade: int = maxi(1, mao.get_child_count())
	if quantidade <= 1:
		return 3.0 * escala
	var largura_disponivel: float = mao.size.x
	if largura_disponivel <= 0.0:
		largura_disponivel = get_viewport().get_visible_rect().size.x * 0.73
	var largura_cartas: float = float(quantidade) * 150.0 * escala
	var separacao: float = (largura_disponivel - largura_cartas) / float(quantidade - 1)
	# Cada carta conserva uma faixa clicável, inclusive nas mãos de dez cartas.
	return minf(3.0 * escala, maxf(separacao, -(150.0 * escala - 48.0)))


func _redimensionar_cartas_da_mao() -> void:
	var escala: float = _escala_mao_atual()
	mao.add_theme_constant_override("separation", roundi(_separacao_mao_atual(escala)))
	for no in mao.get_children():
		var carta: Button = no as Button
		carta.call("configurar_escala", escala, true)
		if mao.get_child_count() > 6:
			carta.rotation = 0.0
	mao.call_deferred("layout_cartas")
	_redimensionar_tipografia_combate()


func _normalizar_rotacao_mao() -> void:
	if mao.get_child_count() <= 6:
		return
	for no in mao.get_children():
		var carta: Button = no as Button
		carta.rotation = 0.0
		carta.call("normalizar_apresentacao_mao")


func _redimensionar_tipografia_combate() -> void:
	var escala: float = _escala_interface()
	var tamanhos: Dictionary = {
		"TurnoTituloLabel": 25,
		"TurnoNumeroLabel": 16,
		"AcaoLabel": 18,
		"RunStatusLabel": 17,
		"IntencaoVisualLabel": 16,
		"IntencaoNomeVisualLabel": 18,
		"IntencaoValorVisualLabel": 17,
		"EstadosInimigoVisualLabel": 15,
		"EstadosInimigoBarreiraLabel": 16,
		"EstadosInimigoExpostoLabel": 16,
		"EstadosInimigoEnfraquecidoLabel": 16,
		"AlvoVisualLabel": 17,
		"VidaJogadorLabel": 18,
		"VidaInimigoLabel": 18,
		"BarreiraLabel": 16,
		"ComboLabel": 16,
		"MaoStatusLabel": 18,
		"EnergiaVisualLabel": 21,
		"CompraLabel": 18,
		"DescarteLabel": 18,
		"Jogador": 25,
		"EncerrarTurno": 23
	}
	for nome: String in tamanhos:
		var controle: Control = get_node(nome) as Control
		controle.add_theme_font_size_override("font_size", roundi(float(tamanhos[nome]) * escala))


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

	var token_carta: String = str(selecionada.get_meta("id_carta"))
	var id_carta: String = descanso_regras.id_base(token_carta)
	var dados: Dictionary = _dados_carta_token(token_carta)
	if dados.is_empty():
		return
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
		_catalogo_com_token(token_carta),
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

	if estado_inimigo == null:
		alvo.text = "SEM ENCONTRO"
		alvo_visual_label.text = "SEM ENCONTRO"
		vida_inimigo_bar.max_value = 1
		vida_inimigo_bar.value = 0
		vida_inimigo_label.text = "—"
		intencao_label.text = "INTENÇÃO\n—"
		estados_inimigo_label.text = "ESTADOS\n—"
		estados_inimigo_visual_label.text = "SEM ENCONTRO"
	elif vida_inimigo <= 0:
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
		if int(resultado["dano_na_vida"]) > 0:
			_animar_flash_dano(jogador)

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
	if dano_na_vida > 0:
		_animar_flash_dano(alvo)


func _animar_faixa_turno() -> void:
	if not turno_faixa.visible:
		return
	turno_faixa.pivot_offset = turno_faixa.size * 0.5
	turno_faixa.scale = Vector2.ONE * 0.97
	turno_faixa.modulate.a = 0.82
	if _animacao_hud != null:
		_animacao_hud.kill()
	_animacao_hud = create_tween()
	_animacao_hud.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_animacao_hud.parallel().tween_property(turno_faixa, "scale", Vector2.ONE, 0.22)
	_animacao_hud.parallel().tween_property(turno_faixa, "modulate:a", 1.0, 0.22)


func _animar_flash_dano(alvo_visual: Control) -> void:
	if not is_instance_valid(alvo_visual):
		return
	var tween: Tween = create_tween()
	alvo_visual.modulate = Color(1.0, 0.52, 0.52, 1.0)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(alvo_visual, "modulate", Color.WHITE, 0.16)


func _registrar_acao(mensagem: String) -> void:
	acao_label.text = mensagem


func _ponto_mapa_em_execucao() -> int:
	var id_referencia: String = mapa_no_em_andamento if not mapa_no_em_andamento.is_empty() else mapa_no_atual
	return mapa_run.ponto_do_no(id_referencia)


func _atualizar_estados_inimigo_visuais() -> void:
	var encontro_valido: bool = estado_inimigo != null and vida_inimigo > 0
	var barreira_ativa: bool = encontro_valido and barreira_inimigo > 0
	var exposto_ativo: bool = encontro_valido and exposto_inimigo > 0
	var enfraquecido_ativo: bool = encontro_valido and enfraquecido_inimigo > 0
	estados_inimigo_barreira_icone.visible = barreira_ativa
	estados_inimigo_barreira_label.visible = barreira_ativa
	estados_inimigo_barreira_label.text = str(barreira_inimigo)
	estados_inimigo_exposto_icone.visible = exposto_ativo
	estados_inimigo_exposto_label.visible = exposto_ativo
	estados_inimigo_exposto_label.text = str(exposto_inimigo)
	estados_inimigo_enfraquecido_icone.visible = enfraquecido_ativo
	estados_inimigo_enfraquecido_label.visible = enfraquecido_ativo
	estados_inimigo_enfraquecido_label.text = str(enfraquecido_inimigo)
	var tem_estados: bool = barreira_ativa or exposto_ativo or enfraquecido_ativo
	estados_inimigo_painel.visible = tem_estados
	estados_inimigo_visual_label.visible = false
	estados_inimigo_visual_label.text = ""


func _atualizar_icone_intencao() -> void:
	if estado_inimigo == null or vida_inimigo <= 0:
		intencao_icone.visible = false
		return
	intencao_icone.visible = true
	match estado_inimigo.tipo_intencao_atual():
		"defesa":
			intencao_icone.texture = ICONE_INTENCAO_DEFESA
		"preparacao":
			intencao_icone.texture = ICONE_INTENCAO_PREPARACAO
		_:
			intencao_icone.texture = ICONE_INTENCAO_ATAQUE


func _atualizar_intencao_visual(texto: String) -> void:
	var separador: int = texto.find(": ")
	if separador < 0:
		intencao_nome_visual_label.text = "INTENCAO"
		intencao_valor_visual_label.text = texto
		return
	intencao_nome_visual_label.text = texto.substr(0, separador).to_upper()
	intencao_valor_visual_label.text = texto.substr(separador + 2)


func _atualizar_interface() -> void:
	evento_vida_label.text = "%d/%d" % [jogador_combate.estado.vida, jogador_combate.estado.vida_maxima]
	evento_baralho_label.text = str(baralho_run.size())
	turno_label.text = "SEU TURNO\nTURNO %d" % turno
	turno_titulo_label.text = "SEU TURNO"
	turno_numero_label.text = "TURNO %d" % turno
	combo_label.text = "%d/%d" % [combo, COMBO_MAXIMO]
	var nomes_reliquias: PackedStringArray = []
	for id_reliquia in jogador_combate.reliquias_run:
		var dados_reliquia: Dictionary = DadosReliquias.obter(id_reliquia)
		if not dados_reliquia.is_empty():
			nomes_reliquias.append(str(dados_reliquia["nome"]))
	reliquia_label.text = "Relíquias: %s" % ", ".join(nomes_reliquias)
	energia_label.text = "Energia: %d/%d" % [energia, ENERGIA_POR_TURNO]
	if energia <= 0:
		energia_label.text += "\nSEM ENERGIA"
	energia_visual_label.text = "%d/%d" % [energia, ENERGIA_POR_TURNO]
	if energia <= 0:
		energia_visual_label.text += "\nSEM ENERGIA"
	vida_jogador_bar.max_value = jogador_combate.estado.vida_maxima
	vida_jogador_bar.value = vida_jogador
	vida_jogador_label.text = "%d/%d" % [
		vida_jogador,
		jogador_combate.estado.vida_maxima
	]
	barreira_label.text = str(barreira)
	var quantidade_mao: int = mao.get_child_count()
	mao_status_label.text = "Mão %d/%d" % [quantidade_mao, LIMITE_MAO]
	if quantidade_mao >= LIMITE_MAO:
		mao_status_label.text += " · MÃO CHEIA"
	var progresso_run: String
	if mapa_gerado:
		progresso_run = "Combate: %d | Ponto: %d/%d" % [
			combate_atual,
			_ponto_mapa_em_execucao(),
			mapa_run.total_pontos()
		]
	else:
		progresso_run = "Combate: %d/%d" % [combate_atual, TOTAL_COMBATES]
	pilhas_label.text = "%s | Baralho: %d\nCompra: %d | Descarte: %d | Mão: %d" % [
		progresso_run,
		baralho_run.size(),
		pilha_compra.size(),
		pilha_descarte.size(),
		quantidade_mao
	]
	if mapa_gerado:
		run_status_label.text = "COMBATE %d\nPONTO %d/%d\nBARALHO %d" % [
			combate_atual,
			_ponto_mapa_em_execucao(),
			mapa_run.total_pontos(),
			baralho_run.size()
		]
	else:
		run_status_label.text = "COMBATE %d/%d\nBARALHO %d" % [
			combate_atual,
			TOTAL_COMBATES,
			baralho_run.size()
		]
	compra_label.text = "COMPRA %d" % pilha_compra.size()
	descarte_label.text = "DESCARTE %d" % pilha_descarte.size()
	intencao_visual_label.text = "INTENÇÃO\n—"
	_atualizar_intencao_visual("—")
	estados_inimigo_visual_label.text = "ESTADOS\n—"

	if estado_inimigo == null:
		alvo.text = "SEM ENCONTRO"
		alvo_visual_label.text = "SEM ENCONTRO"
		vida_inimigo_bar.max_value = 1
		vida_inimigo_bar.value = 0
		vida_inimigo_label.text = "—"
		intencao_label.text = "INTENÇÃO\n—"
		estados_inimigo_label.text = "ESTADOS\n—"
		estados_inimigo_visual_label.text = "SEM ENCONTRO"
	elif vida_inimigo <= 0:
		alvo.text = "%s\nDerrotado" % estado_inimigo.nome.to_upper()
		alvo_visual_label.text = estado_inimigo.nome.to_upper()
		vida_inimigo_bar.max_value = estado_inimigo.vida_maxima
		vida_inimigo_bar.value = 0
		vida_inimigo_label.text = "DERROTADO"
		intencao_label.text = "INTENÇÃO\n—"
		estados_inimigo_label.text = "ESTADOS\n—"
	else:
		alvo.text = "%s\nVida: %d\nBarreira: %d" % [
			estado_inimigo.nome.to_upper(),
			vida_inimigo,
			barreira_inimigo
		]
		alvo_visual_label.text = estado_inimigo.nome.to_upper()
		vida_inimigo_bar.max_value = estado_inimigo.vida_maxima
		vida_inimigo_bar.value = vida_inimigo
		vida_inimigo_label.text = "%d/%d" % [
			vida_inimigo,
			estado_inimigo.vida_maxima
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
		var estados_visuais: String = "BARREIRA %d" % barreira_inimigo
		if exposto_inimigo > 0:
			estados_visuais += " · EXPOSTO %d" % exposto_inimigo
		if enfraquecido_inimigo > 0:
			estados_visuais += " · ENFRAQ. %d" % enfraquecido_inimigo
		if exposto_inimigo <= 0 and enfraquecido_inimigo <= 0:
			estados_visuais += " · SEM ESTADOS"
		estados_inimigo_visual_label.text = estados_visuais
		intencao_visual_label.text = "INTENÇÃO\n%s" % estado_inimigo.texto_intencao()
		_atualizar_intencao_visual(estado_inimigo.texto_intencao())

	_atualizar_icone_intencao()
	_atualizar_estados_inimigo_visuais()
	var terminou: bool = (
		_combate_terminou()
		or aguardando_recompensa
		or aguardando_recompensa_elite
		or aguardando_evento
	)
	alvo.disabled = terminou
	jogador.disabled = terminou
	botao_encerrar_turno.disabled = terminou
	_atualizar_destaque_hud(alvo)
	_atualizar_destaque_hud(jogador)
	_atualizar_destaque_hud(botao_encerrar_turno)

	for no in mao.get_children():
		var carta: Button = no as Button
		carta.disabled = terminou
	_redimensionar_cartas_da_mao()
