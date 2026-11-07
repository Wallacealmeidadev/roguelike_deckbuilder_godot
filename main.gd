extends Node

const APRESENTACAO_NEON: Script = preload("res://hud_neon/apresentacao_combate.gd")
const APRESENTACAO_RUN: Script = preload("res://hud_neon/apresentacao_run.gd")
var reliquias_exibidas: Array[String] = []
var movimento_reduzido: bool = false
var mira_carta: Control
var mira_por_teclado: bool = false

var vega_animada: Control
@export var cena_apresentacao_vega: PackedScene = preload("res://vega_animada/rig_nativo_v2/vega_combate.tscn")
var feedback_combate: Node

const CENA_CARTA: PackedScene = preload("res://carta.tscn")
const DADOS_CARTAS: Script = preload("res://dados_cartas.gd")
const DESCANSO_REGRAS: Script = preload("res://descanso_run.gd")
const ENERGIA_POR_TURNO: int = 4
const COMPRA_POR_TURNO: int = 6
const LIMITE_MAO: int = 10
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
const ICONE_R2_ATAQUE: Texture2D = preload("res://ui_hq_v1/componentes/icones/ataque.tres")
const ICONE_R2_BARRERA: Texture2D = preload("res://ui_hq_v1/componentes/icones/barreira.tres")
const ICONE_R2_RELIQUIA: Texture2D = preload("res://ui_hq_v1/componentes/icones/reliquia.tres")
const DRONE_CAMPO: Texture2D = preload("res://ui_hq_v1/assets/personagens/drone_combate.png")
const ICONE_INTENCAO_ATAQUE: Texture2D = preload("res://hud_hq/icones/ataque.svg")
const ICONE_INTENCAO_DEFESA: Texture2D = preload("res://hud_hq/barreira.svg")
const ICONE_INTENCAO_PREPARACAO: Texture2D = preload("res://hud_hq/icones/preparacao.svg")
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
	ENERGIA_POR_TURNO
)
var run_state: RunState = RunState.new()
var encontro_combate: EncontroCombate = EncontroCombate.new()
var alvos_multiplos: Array[Button] = []
var marcado_visual: Label
var estado_especial_visual: Label

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
		run_state.registrar_vida(valor)

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
var baralho_run: Array[String]:
	get:
		return run_state.deck
	set(valor):
		run_state.deck = valor
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
var mapa_run: MapaRun:
	get:
		return run_state.mapa
var mapa_ativo: bool = false
var mapa_gerado: bool = false
var mapa_no_atual: String:
	get:
		return run_state.no_atual
	set(valor):
		run_state.no_atual = valor
var mapa_no_em_andamento: String:
	get:
		return run_state.no_em_andamento
	set(valor):
		run_state.no_em_andamento = valor
var mapa_pontos_concluidos: Array[String]:
	get:
		return run_state.concluidos
	set(valor):
		run_state.concluidos = valor
var mapa_pre_chefe_alcancado: bool = false
var mapa_variante: int = -1
var descanso_ativo: bool = false
var descanso_acao_resolvida: bool = false
var desmanche_acao_resolvida: bool = false
var descanso_tela: String = ""
var descanso_elegiveis: Array[Dictionary] = []
var descanso_indice_selecionado: int = -1
var etapa_evento_atual: String = ""
var evento_escolha_resolvida: bool = false
var encontro_especial_pendente: bool = false
var id_inimigo_especial: String = ""
var texto_evento_especial: String = ""
var desmanche_contexto: String = "mapa"
var evento_deck_pendente: Dictionary = {}
var resultado_evento_especial: Dictionary = {}

var baralho_combate: BaralhoCombate:
	get:
		return encontro_combate.baralho

var resolucao_cartas: ResolucaoCartas = ResolucaoCartas.new()
var descanso_regras = DESCANSO_REGRAS.new()
var desmanche_regras: DesmancheRun = DesmancheRun.new()
var desmanche_overlay: DesmancheOverlay

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
var _animacao_dano: Tween
var _animacoes_flash: Dictionary = {}
var _dano_feedback_posicao_base: Vector2
var _dano_feedback_posicao_pronta: bool = false
var foco_recompensa_anterior: Control
var _consulta_baralho_combate: bool = false

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
@onready var topo_vida_preenchimento: TextureRect = $TopoVidaPreenchimento
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
@onready var reliquia_icone: TextureRect = $ReliquiaIcone
@onready var reliquia_label: Label = $ReliquiaLabel
@onready var pilhas_label: Label = $PilhasLabel
@onready var run_status_label: Label = $RunStatusLabel
@onready var rota_icone: TextureRect = $RotaIcone
@onready var topo_combate: Panel = $TopoCombate
@onready var topo_vida: Label = $TopoCombate/TopoVida
@onready var topo_vida_moldura: TextureRect = $TopoVidaMoldura
@onready var topo_reliquias: HBoxContainer = $TopoCombate/TopoReliquias
@onready var topo_relicario: Panel = $TopoCombate/TopoRelicario
@onready var topo_baralho: Button = $TopoCombate/TopoBaralho
@onready var topo_rota: Button = $TopoCombate/TopoRota
@onready var topo_configuracoes: Button = $TopoCombate/TopoConfiguracoes
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
@onready var hud_inspecao: PanelContainer = $HudInspecao
@onready var dano_feedback_label: Label = $DanoFeedbackLabel
@onready var consultar_baralho: Button = $Recompensas/RecompensaAcoes/ConsultarBaralho
@onready var baralho_overlay: Panel = $BaralhoOverlay
@onready var baralho_resumo: Label = $BaralhoOverlay/BaralhoResumo
@onready var baralho_fechar: Button = $BaralhoOverlay/BaralhoFechar
@onready var baralho_scrim: ColorRect = $BaralhoScrim
@onready var baralho_titulo: Label = $BaralhoOverlay/BaralhoTitulo
@onready var baralho_lista: GridContainer = $BaralhoOverlay/ListaScroll/ListaCartas
@onready var baralho_vazio: Label = $BaralhoOverlay/BaralhoVazio
@onready var configuracoes_scrim: ColorRect = $ConfiguracoesScrim
@onready var configuracoes_overlay: Panel = $ConfiguracoesOverlay
@onready var configuracoes_som: Button = $ConfiguracoesOverlay/Som
@onready var configuracoes_tela: Button = $ConfiguracoesOverlay/Tela
@onready var configuracoes_movimento: Button = $ConfiguracoesOverlay/Movimento
@onready var configuracoes_fechar: Button = $ConfiguracoesOverlay/Fechar


func _ready() -> void:
	APRESENTACAO_NEON.preparar(self)
	mira_carta = preload("res://hud_neon/mira_carta.gd").new() as Control
	mira_carta.name = "MiraCarta"
	add_child(mira_carta)
	mira_carta.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	feedback_combate = preload("res://hud_neon/feedback_combate.gd").new()
	feedback_combate.name = "FeedbackRecursosNeon"
	add_child(feedback_combate)
	feedback_combate.preparar(self)
	APRESENTACAO_RUN.preparar(self)
	vega_animada = cena_apresentacao_vega.instantiate() as Control
	jogador.add_child(vega_animada)
	vega_animada.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	desmanche_overlay = DesmancheOverlay.new()
	desmanche_overlay.name = "DesmancheOverlay"
	add_child(desmanche_overlay)
	desmanche_overlay.remover_solicitado.connect(_ao_remover_desmanche)
	desmanche_overlay.recalibrar_solicitado.connect(_ao_recalibrar_desmanche)
	desmanche_overlay.continuar_solicitado.connect(_ao_continuar_desmanche)
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
	topo_baralho.pressed.connect(_mostrar_consulta_baralho)
	baralho_scrim.gui_input.connect(_ao_clicar_fora_consulta)
	compra_painel.gui_input.connect(_ao_ativar_pilha.bind("compra"))
	descarte_painel.gui_input.connect(_ao_ativar_pilha.bind("descarte"))
	for painel_pilha in [compra_painel, descarte_painel]:
		painel_pilha.mouse_entered.connect(_atualizar_destaque_pilha.bind(painel_pilha))
		painel_pilha.mouse_exited.connect(_atualizar_destaque_pilha.bind(painel_pilha))
		painel_pilha.focus_entered.connect(_atualizar_destaque_pilha.bind(painel_pilha))
		painel_pilha.focus_exited.connect(_atualizar_destaque_pilha.bind(painel_pilha))
	topo_rota.pressed.connect(_mostrar_inspecao_hud.bind(topo_rota))
	topo_configuracoes.pressed.connect(_abrir_configuracoes)
	configuracoes_som.pressed.connect(_alternar_som)
	configuracoes_tela.pressed.connect(_alternar_tela_cheia)
	configuracoes_movimento.pressed.connect(_alternar_movimento)
	configuracoes_fechar.pressed.connect(_fechar_configuracoes)
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
	get_window().size_changed.connect(_sincronizar_viewport_com_janela)
	_sincronizar_viewport_com_janela()
	get_viewport().size_changed.connect(_redimensionar_cartas_da_mao)
	get_viewport().size_changed.connect(_layout_hud_combate)
	mapa_grafo.resized.connect(_reorganizar_mapa_visual)
	get_viewport().size_changed.connect(_reposicionar_inspecao_hud)
	_redimensionar_tipografia_combate()

	alvo.pressed.connect(_ao_clicar_no_alvo)
	(alvo.get_node("DroneCampoSprite") as TextureRect).gui_input.connect(_ao_clicar_sprite_drone.bind(alvo))
	_criar_alvos_multiplos()
	_layout_hud_combate()
	jogador.pressed.connect(_ao_clicar_no_jogador)
	botao_encerrar_turno.pressed.connect(_ao_encerrar_turno)
	_conectar_destaques_hud()
	_conectar_inspecoes_hud()
	hud_inspecao.hide()
	dano_feedback_label.hide()
	configuracoes_overlay.hide()
	configuracoes_scrim.hide()
	call_deferred("_capturar_posicao_feedback_dano")

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
	encontro_combate.inimigos.clear()
	baralho_combate.compra.clear()
	baralho_combate.descarte.clear()
	_limpar_mao()
	descanso_ativo = false
	descanso_acao_resolvida = false
	desmanche_acao_resolvida = false
	desmanche_overlay.hide()
	descanso_tela = ""
	aguardando_recompensa = false
	aguardando_recompensa_elite = false
	etapa_recompensa_elite = ""
	aguardando_evento = false
	evento_escolha_resolvida = false
	encontro_especial_pendente = false
	desmanche_contexto = "mapa"
	evento_deck_pendente.clear()
	resultado_evento_especial.clear()
	id_evento_atual = ""
	etapa_evento_atual = ""
	mapa_pre_chefe_alcancado = false
	combate_atual = 0
	mapa_pontos_concluidos.clear()
	mapa_no_atual = ""
	mapa_no_em_andamento = ""
	var seed_nova: int = mapa_variante if mapa_variante >= 0 else randi()
	run_state.iniciar(seed_nova, jogador_combate.estado.vida_maxima, baralho_run, jogador_combate.reliquias_run)
	jogador_combate.reliquias_run = run_state.reliquias
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
	if controle.has_node("HoverHQ"):
		controle.get_node("HoverHQ").atualizar()
	var destaque: Panel = controle.get_node_or_null("Interacao") as Panel
	if destaque == null:
		return
	if controle == alvo or controle == jogador or controle.is_in_group("alvo_multiplo"):
		if grupo_cartas.get_pressed_button() != null:
			destaque.hide()
			return
	# A Vega animada ocupa uma caixa de layout maior que a silhueta. O hover
	# dessa caixa nao deve desenhar uma moldura enorme nem competir com a arte.
	# O realce neon e a mira comunicam foco/alvo sem desenhar caixas de layout.
	destaque.hide()


func _atualizar_alvos_carta_selecionada() -> void:
	_atualizar_destaque_hud(alvo)
	_atualizar_destaque_hud(jogador)
	for botao_multiplo in alvos_multiplos:
		_atualizar_destaque_hud(botao_multiplo)
	_atualizar_mira_carta(get_viewport().get_mouse_position())


func _process(_delta: float) -> void:
	_atualizar_mira_carta(get_viewport().get_mouse_position())


func _atualizar_mira_carta(ponteiro: Vector2) -> void:
	if mira_carta == null:
		return
	mira_carta.hide()
	if not topo_combate.visible or baralho_overlay.visible or configuracoes_overlay.visible or _combate_terminou():
		return
	var carta: Button = grupo_cartas.get_pressed_button() as Button
	if carta == null or not carta.is_visible_in_tree():
		return
	var dados: Dictionary = _dados_carta_token(str(carta.get_meta("id_carta", "")))
	if dados.is_empty():
		return
	var candidatos: Array[Button] = []
	if str(dados["alvo"]) == "jogador":
		candidatos.append(jogador)
	elif encontro_combate.inimigos.size() > 1:
		candidatos.assign(alvos_multiplos)
	else:
		candidatos.append(alvo)
	var escolhido: Control = null
	var raio: float = 0.0
	if energia >= int(dados["custo"]):
		for candidato: Button in candidatos:
			if not candidato.is_visible_in_tree() or candidato.disabled:
				continue
			var sprite: Control = candidato.get_node_or_null("DroneCampoSprite") as Control
			var area_corpo: Rect2 = sprite.get_global_rect() if sprite != null else candidato.get_global_rect()
			var apontado: bool = candidato.has_focus() if mira_por_teclado else candidato.get_global_rect().has_point(ponteiro) or area_corpo.has_point(ponteiro)
			if apontado:
				escolhido = candidato
				raio = clampf(minf(area_corpo.size.x, area_corpo.size.y) * 0.23, 28.0, 64.0)
				break
	var inicio: Vector2 = carta.get_global_transform() * Vector2(carta.size.x * 0.5, 6.0)
	var fim: Vector2 = _ponto_impacto_carta(escolhido) if escolhido != null else ponteiro
	if escolhido == null and fim.distance_to(inicio) < 60.0:
		fim = inicio + Vector2(0.0, -65.0)
	var cor: Color = Color("22e8f5") if str(dados["alvo"]) == "jogador" else Color("f322b5")
	mira_carta.call("apontar", inicio, fim, escolhido != null, cor, raio)
	if hud_inspecao.visible and (hud_inspecao.controle_atual == alvo or hud_inspecao.controle_atual in alvos_multiplos):
		hud_inspecao.esconder()


func _conectar_inspecoes_hud() -> void:
	for controle in [
		alvo,
		intencao_painel,
		energia_painel,
		barreira_icone,
		combo_icone,
		stats_jogador_painel.get_node("ModuloBarreira"),
		stats_jogador_painel.get_node("ModuloCombo"),
		reliquia_painel,
		topo_rota,
		topo_baralho,
		topo_configuracoes,
		compra_painel,
		descarte_painel
	]:
		controle.focus_mode = Control.FOCUS_ALL
		controle.mouse_filter = Control.MOUSE_FILTER_STOP
		controle.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		controle.mouse_entered.connect(_ao_entrar_inspecao_hud.bind(controle))
		controle.mouse_exited.connect(_ao_sair_inspecao_hud.bind(controle))
		controle.focus_entered.connect(_ao_entrar_inspecao_hud.bind(controle))
		controle.focus_exited.connect(_ao_sair_inspecao_hud.bind(controle))


func _ao_entrar_inspecao_hud(controle: Control) -> void:
	_mostrar_inspecao_hud(controle)


func _ao_sair_inspecao_hud(controle: Control) -> void:
	if controle.has_focus() or controle.get_global_rect().has_point(controle.get_global_mouse_position()):
		return
	hud_inspecao.esconder(controle)


func _mostrar_inspecao_hud(controle: Control) -> void:
	if controle == null or not controle.is_visible_in_tree() or baralho_overlay.visible or configuracoes_overlay.visible:
		hud_inspecao.esconder()
		return
	var mensagem: String = _texto_inspecao_hud(controle)
	if mensagem.is_empty():
		hud_inspecao.esconder()
		return
	var compacto: bool = get_viewport().get_visible_rect().size.x < 1400.0
	var texto: Label = hud_inspecao.get_node("Texto") as Label
	texto.custom_minimum_size.x = 160.0 if compacto else 260.0
	texto.add_theme_font_size_override("font_size", 13 if compacto else 16)
	hud_inspecao.mostrar(controle, mensagem, _bloqueios_inspecao_hud())


func _reposicionar_inspecao_hud() -> void:
	if hud_inspecao == null or not hud_inspecao.visible:
		return
	hud_inspecao.reposicionar(_bloqueios_inspecao_hud())


func _bloqueios_inspecao_hud() -> Array[Rect2]:
	var bloqueios: Array[Rect2] = []
	var protegidos: Array[Control] = [mao, alvo, jogador, energia_painel, compra_painel, descarte_painel, botao_encerrar_turno, stats_jogador_painel, topo_combate.get_node("ModuloJogador") as Control, topo_baralho, topo_rota, topo_configuracoes, turno_faixa, alvo.get_node("DroneCampoSprite") as Control]
	for botao: Button in alvos_multiplos:
		protegidos.append(botao)
		protegidos.append(botao.get_node("DroneCampoSprite") as Control)
	for controle: Control in protegidos:
		if controle.is_visible_in_tree():
			bloqueios.append(controle.get_global_rect())
	return bloqueios


func _eh_icone_reliquia_topo(controle: Control) -> bool:
	return controle != null and controle.is_in_group("icone_reliquia_topo")


func _texto_inspecao_hud(controle: Control) -> String:
	if controle != null and controle.is_in_group("alvo_multiplo"):
		var indice: int = int(controle.get_meta("indice_inimigo", -1))
		if indice >= 0 and indice < encontro_combate.inimigos.size():
			var individual: InimigoCombate = encontro_combate.inimigos[indice]
			var detalhes: String = "%s\nVida: %d/%d\nBarreira: %d\nIntenção: %s" % [individual.nome.to_upper(), individual.vida, individual.vida_maxima, individual.barreira, individual.texto_intencao() if individual.vida > 0 else "—"]
			if individual.frenesi:
				detalhes += "\nFRENESI"
			if individual.recalibrando:
				detalhes += "\nRECALIBRANDO: recebe +50% de dano"
			if individual.exposto > 0:
				detalhes += "\nExposto: %d" % individual.exposto
			if individual.enfraquecido > 0:
				detalhes += "\nEnfraquecido: %d" % individual.enfraquecido
			return detalhes
		return ""
	if controle == jogador:
		return ""
	if controle == alvo:
		if estado_inimigo == null:
			return "SEM ENCONTRO"
		return "%s\nVida: %d/%d\nIntenção: %s" % [
			estado_inimigo.nome.to_upper(),
			vida_inimigo,
			estado_inimigo.vida_maxima,
			estado_inimigo.texto_intencao()
		]
	if controle == intencao_painel:
		if estado_inimigo == null or vida_inimigo <= 0:
			return "INTENÇÃO\nNenhuma ação anunciada."
		return "INTENÇÃO\n%s\nA ação é resolvida ao encerrar o turno." % estado_inimigo.texto_intencao()
	if controle == energia_painel:
		return "ENERGIA\n%d/%d disponíveis neste turno." % [energia, ENERGIA_POR_TURNO]
	if controle == barreira_icone or controle == stats_jogador_painel.get_node("ModuloBarreira"):
		return "BARREIRA %d\nAbsorve dano antes da Vida." % barreira
	if controle == combo_icone or controle == stats_jogador_painel.get_node("ModuloCombo"):
		return "COMBO %d\nCartas com ganho declarado aumentam Combo. Finalizações consomem tudo; no fim do turno, zera." % combo
	if _eh_icone_reliquia_topo(controle):
		var id_reliquia: String = str(controle.get_meta("id_reliquia", ""))
		var dados: Dictionary = DadosReliquias.obter(id_reliquia)
		if dados.is_empty():
			return ""
		return "RELÍQUIA\n%s\n%s" % [dados["nome"], dados["descricao"]]
	if controle == topo_baralho:
		return "BARALHO\nConsulte todas as cartas da run."
	if controle == topo_configuracoes:
		return "CONFIGURAÇÕES\nSom, tela e opções da partida."
	if controle == topo_rota:
		return "ROTA DAS DOCAS\nPONTO %d/%d · COMBATE %d\nMapa navegável entre encontros." % [
			_ponto_mapa_em_execucao(), mapa_run.total_pontos(), combate_atual
		]
	if controle == compra_painel:
		return "COMPRA\n%d carta(s) na pilha de compra." % pilha_compra.size()
	if controle == descarte_painel:
		return "DESCARTE\n%d carta(s) aguardando embaralhamento." % pilha_descarte.size()
	return ""


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
		resultado_label.text = "RUN CONCLUÍDA\nA rota das Docas foi concluída."
	APRESENTACAO_RUN.atualizar_resultado(self, vida_jogador > 0)

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

	var ids_encontro: Array[String] = DadosEncontrosDocas.obter(id_inimigo)
	if ids_encontro.is_empty():
		ids_encontro.append(id_inimigo)
	var novos_inimigos: Array[InimigoCombate] = []
	for id_individual in ids_encontro:
		var dados_individual: Dictionary = DadosInimigos.obter(id_individual)
		if dados_individual.is_empty():
			break
		novos_inimigos.append(InimigoCombate.new(id_individual, dados_individual))
	if novos_inimigos.size() != ids_encontro.size():
		encontro_combate.inimigo = null
		encontro_combate.inimigos.clear()
		_registrar_acao("Não foi possível preparar o inimigo.")
		_definir_painel_combate_visivel(false)
		return

	if novos_inimigos[0].nome.is_empty() or novos_inimigos[0].ciclo.is_empty():
		encontro_combate.inimigo = null
		encontro_combate.inimigos.clear()
		_registrar_acao("Não foi possível preparar o inimigo.")
		_definir_painel_combate_visivel(false)
		return

	if registrar_comum and not seletor_inimigos.registrar_enfrentado(id_inimigo):
		encontro_combate.inimigo = null
		_registrar_acao("Não foi possível registrar o inimigo.")
		_definir_painel_combate_visivel(false)
		return

	encontro_combate.iniciar_multiplos(novos_inimigos, baralho_run)
	arena_chao.call("definir_encontro", id_inimigo, movimento_reduzido)
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
	run_state.registrar_vida(vida_jogador)
	if aguardando_recompensa or aguardando_recompensa_elite or aguardando_evento:
		return

	if encontro_especial_pendente:
		_mostrar_resultado_evento_especial()
		return

	if mapa_gerado:
		var id_no: String = mapa_no_em_andamento if not mapa_no_em_andamento.is_empty() else mapa_no_atual
		var no_atual: Dictionary = mapa_run.obter_no(id_no)
		if str(no_atual.get("tipo", "")) == MapaRun.TIPO_CHEFE:
			_concluir_no_mapa_atual()
			mapa_ativo = false
			mapa_pre_chefe_alcancado = true
			_definir_painel_combate_visivel(false)
			_definir_status_combate_visivel(false)
			resultado_label.text = "RUN CONCLUÍDA\nBoss provisório vencido"
			APRESENTACAO_RUN.atualizar_resultado(self, true, true)
			resultado_label.show()
			botao_reiniciar.show()
		else:
			_mostrar_recompensas()
		return

	if roteiro_run.etapa_atual() == "elite":
		_mostrar_recompensa_elite()
		return

	_mostrar_recompensas()


func _mostrar_resultado_evento_especial() -> void:
	encontro_especial_pendente = false
	var resultado: Dictionary = resultado_evento_especial.duplicate(true)
	resultado_evento_especial.clear()
	run_state.registrar_evento_resolvido(str(resultado.get("id_evento", id_evento_atual)))
	var texto_resultado: String = str(resultado.get("texto", texto_evento_especial))
	for flag in resultado.get("flags_concedidas", []):
		run_state.adicionar_flag(str(flag))
	var recompensa_texto: String = _aplicar_recompensa_evento(resultado.get("recompensa", {}))
	if not recompensa_texto.is_empty():
		texto_resultado += "\n" + recompensa_texto
	aguardando_evento = true
	evento_escolha_resolvida = true
	evento_titulo.text = "EVENTO RESOLVIDO"
	evento_faixa_nome.text = "CONFRONTO RESOLVIDO"
	evento_texto.text = "O confronto terminou."
	evento_texto.hide()
	evento_resultado.text = texto_resultado
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
	if mira_carta != null:
		mira_carta.hide()
	for carta_consumida: Node in get_tree().get_nodes_in_group("carta_consumida"):
		if carta_consumida.get_parent() == self:
			(carta_consumida as Control).hide()
			carta_consumida.queue_free()
	feedback_combate.reiniciar()
	if is_instance_valid(vega_animada):
		vega_animada.reiniciar()
	for no in [
		arena_chao,
		mao_dock,
		energia_painel,
		mao,
		alvo,
		vida_inimigo_bar,
		vida_inimigo_label,
		jogador,
		vida_jogador_bar,
		topo_vida_moldura,
		topo_vida_preenchimento,
		barreira_icone,
		combo_icone,
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
	if _animacao_dano != null and _animacao_dano.is_valid():
		_animacao_dano.kill()
	dano_feedback_label.hide()
	topo_combate.visible = visivel
	_sincronizar_viewport_com_janela()
	for botao_multiplo in alvos_multiplos:
		botao_multiplo.visible = visivel and encontro_combate.inimigos.size() > 1
	if marcado_visual != null:
		marcado_visual.visible = visivel and _jogador_marcado()
	if estado_especial_visual != null and not visivel:
		estado_especial_visual.hide()
	mao_status_label.visible = visivel and mao.get_child_count() >= LIMITE_MAO
	hud_inspecao.esconder()
	if not visivel:
		_ocultar_faixa_turno()


func _definir_status_combate_visivel(visivel: bool) -> void:
	for no in [
		pilhas_painel,
		stats_jogador_painel,
		energia_icone,
		energia_visual_label,
		barreira_label,
		combo_label,
		compra_label,
		compra_icone,
		compra_painel,
		descarte_label,
		descarte_icone,
		descarte_painel
	]:
		no.visible = visivel
	# Os módulos ilustrados substituem os três ícones soltos do shell anterior.
	energia_icone.hide()
	barreira_icone.hide()
	combo_icone.hide()


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
	return run_state.destinos_disponiveis()


func _concluir_no_mapa_atual() -> bool:
	run_state.registrar_vida(vida_jogador)
	return run_state.concluir_no()


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
	APRESENTACAO_RUN.atualizar_mapa(self, mapa_run.total_pontos())

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
	APRESENTACAO_RUN.estilizar_no_mapa(botao, tipo, estado)

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
	if tipo == MapaRun.TIPO_DESMANCHE:
		return "DESMANCHE"
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
	if tipo == MapaRun.TIPO_DESMANCHE:
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
	(descanso_overlay.get_node("Acoes/AprimorarPainel") as Button).hide()
	if cura <= 0:
		descanso_acao_resolvida = true
		descanso_tela = "resultado"
		descanso_overlay.call("mostrar_resultado", "DESCANSO", "Vida já está cheia.", vida_jogador, jogador_combate.estado.vida_maxima, "")
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
	if mapa_gerado and str(mapa_run.obter_no(mapa_no_em_andamento).get("tipo", "")) == MapaRun.TIPO_DESCANSO:
		return
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


func _mostrar_desmanche() -> void:
	desmanche_contexto = "mapa"
	desmanche_acao_resolvida = false
	mapa_fundo.hide()
	mapa_overlay.hide()
	_definir_painel_combate_visivel(false)
	_definir_status_combate_visivel(false)
	desmanche_overlay.mostrar(baralho_run)
	if not desmanche_overlay.possui_acao_valida():
		desmanche_acao_resolvida = true
		print("Desmanche sem ação válida: deck com uma única carta já recalibrada.")


func _mostrar_desmanche_evento(acao: String, filtro: String) -> void:
	desmanche_contexto = "evento"
	desmanche_acao_resolvida = false
	evento_overlay.hide()
	evento_painel.hide()
	mapa_fundo.hide()
	mapa_overlay.hide()
	_definir_painel_combate_visivel(false)
	_definir_status_combate_visivel(false)
	desmanche_overlay.mostrar(baralho_run, acao, filtro)
	if not desmanche_overlay.possui_acao_valida():
		desmanche_acao_resolvida = true
		desmanche_overlay.mostrar_resultado("Nenhuma carta elegível para esta ação. O evento pode ser concluído com segurança.")


func _ao_remover_desmanche(indice: int) -> void:
	if desmanche_acao_resolvida or (desmanche_contexto == "mapa" and mapa_no_em_andamento != "desmanche_docas"):
		return
	if not desmanche_regras.remover(baralho_run, indice):
		return
	desmanche_acao_resolvida = true
	desmanche_overlay.mostrar_resultado("Uma carta foi removida do baralho desta run.")


func _ao_recalibrar_desmanche(indice: int) -> void:
	if desmanche_acao_resolvida or (desmanche_contexto == "mapa" and mapa_no_em_andamento != "desmanche_docas"):
		return
	if not desmanche_regras.recalibrar(baralho_run, indice):
		return
	desmanche_acao_resolvida = true
	desmanche_overlay.mostrar_resultado("Carta recalibrada para esta run.")


func _ao_continuar_desmanche() -> void:
	if not desmanche_acao_resolvida:
		return
	desmanche_overlay.hide()
	if desmanche_contexto == "evento":
		desmanche_contexto = "mapa"
		var resultado: Dictionary = evento_deck_pendente.duplicate(true)
		evento_deck_pendente.clear()
		evento_overlay.show()
		evento_painel.hide()
		_finalizar_evento_sem_combate(resultado, "A alteração foi aplicada ao baralho da run.")
		return
	_concluir_no_mapa_atual()
	_mostrar_mapa("Desmanche concluído. Escolha o próximo destino.")


func _ao_selecionar_no_mapa(id_no: String) -> void:
	if not mapa_ativo or not mapa_no_em_andamento.is_empty():
		return
	if not run_state.iniciar_no(id_no):
		return
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
	if tipo == MapaRun.TIPO_DESMANCHE:
		_mostrar_desmanche()
		return

	if tipo == MapaRun.TIPO_CHEFE:
		combate_atual += 1
		_iniciar_combate_por_id(id_conteudo, false)
		return


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
	if run_state.evento_ja_resolvido(id_evento):
		return
	if mapa_gerado and not mapa_no_em_andamento.is_empty() and run_state.concluidos.has(mapa_no_em_andamento):
		return
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

	var opcoes: Array[Dictionary] = DadosEventos.opcoes_disponiveis(id_evento, run_state.flags)
	for indice in range(mini(opcoes.size(), botoes.size())):
		var opcao: Dictionary = opcoes[indice]
		botoes[indice].call(
			"configurar_evento",
			str(opcao.get("nome", "Opção")),
			_resumo_opcao_evento(opcao),
			"combate" if str(opcao.get("tipo", "")) == "combate_especial" else ""
		)
		botoes[indice].disabled = not _evento_opcao_tem_acao(opcao)
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

	var opcoes: Array[Dictionary] = DadosEventos.opcoes_disponiveis(etapa_evento_atual, run_state.flags)
	if indice < 0 or indice >= opcoes.size():
		return

	var opcao: Dictionary = opcoes[indice]
	var resultado: Dictionary = ResolucaoEventos.resolver(
		etapa_evento_atual,
		str(opcao.get("id", "")),
		jogador_combate,
		run_state.flags
	)
	if not resultado["valida"]:
		return

	var vida_delta: int = int(resultado["vida_delta"])
	if vida_delta != 0:
		vida_jogador = clampi(
			vida_jogador + vida_delta,
			0,
			jogador_combate.estado.vida_maxima
		)
		if vida_jogador <= 0:
			_mostrar_resultado()
			return
	if resultado["tipo"] == "combate_especial":
		evento_escolha_resolvida = true
		encontro_especial_pendente = true
		resultado_evento_especial = resultado.duplicate(true)
		resultado_evento_especial["id_evento"] = etapa_evento_atual
		combate_atual += 1
		id_inimigo_especial = str(resultado["id_inimigo"])
		texto_evento_especial = str(resultado["texto"])
		_ocultar_evento()
		_iniciar_combate_por_id(id_inimigo_especial, false)
		return

	if not str(resultado.get("deck_acao", "")).is_empty():
		evento_deck_pendente = resultado.duplicate(true)
		evento_deck_pendente["id_evento"] = etapa_evento_atual
		_mostrar_desmanche_evento(
			str(resultado.get("deck_acao", "")),
			str(resultado.get("filtro_carta", ""))
		)
		return

	_finalizar_evento_sem_combate(resultado)


func _ao_continuar_evento() -> void:
	if not aguardando_evento or not evento_escolha_resolvida:
		return
	_avancar_roteiro()


func _evento_opcao_tem_acao(opcao: Dictionary) -> bool:
	var acao_deck: String = str(opcao.get("deck_acao", ""))
	if acao_deck.is_empty():
		return true
	var filtro: String = str(opcao.get("filtro_carta", ""))
	var elegiveis: Array[Dictionary] = descanso_regras.cartas_elegiveis(baralho_run, filtro)
	if acao_deck == "remover":
		return baralho_run.size() > 1 and _quantidade_cartas_com_filtro(filtro) > 0
	if acao_deck == "recalibrar":
		return not elegiveis.is_empty()
	return false


func _quantidade_cartas_com_filtro(filtro: String) -> int:
	if filtro.is_empty():
		return baralho_run.size()
	var quantidade: int = 0
	for token in baralho_run:
		var dados: Dictionary = DADOS_CARTAS.CARTAS.get(descanso_regras.id_base(token), {})
		if filtro == "vega_exclusiva" and str(dados.get("personagem", "")) == "vega" and bool(dados.get("exclusiva", false)):
			quantidade += 1
	return quantidade


func _aplicar_recompensa_evento(recompensa: Dictionary) -> String:
	if recompensa.is_empty():
		return ""
	var tipo: String = str(recompensa.get("tipo", ""))
	var id_reliquia: String = str(recompensa.get("id_reliquia", ""))
	if tipo == "reliquia_global":
		var disponiveis: Array[String] = DadosReliquias.identificadores_sem(jogador_combate.reliquias_run)
		if disponiveis.is_empty():
			return "Nenhuma relíquia nova disponível."
		id_reliquia = disponiveis[0]
	if id_reliquia.is_empty() or not DadosReliquias.RELIQUIAS.has(id_reliquia):
		return "Recompensa de relíquia ainda não implementada."
	if jogador_combate.reliquias_run.has(id_reliquia):
		return "Relíquia já obtida nesta run."
	jogador_combate.adicionar_reliquia(id_reliquia)
	run_state.reliquias = jogador_combate.reliquias_run.duplicate()
	var dados: Dictionary = DadosReliquias.obter(id_reliquia)
	return "Relíquia obtida: %s." % str(dados.get("nome", id_reliquia))


func _finalizar_evento_sem_combate(resultado: Dictionary, texto_extra: String = "") -> void:
	var id_evento_resolvido: String = str(resultado.get("id_evento", id_evento_atual))
	for flag in resultado.get("flags_concedidas", []):
		run_state.adicionar_flag(str(flag))
	run_state.registrar_evento_resolvido(id_evento_resolvido)
	var texto: String = str(resultado.get("texto", ""))
	var recompensa_texto: String = _aplicar_recompensa_evento(resultado.get("recompensa", {}))
	if not recompensa_texto.is_empty():
		texto += "\n" + recompensa_texto
	if not texto_extra.is_empty():
		texto += "\n" + texto_extra
	for botao in [evento_opcao_1, evento_opcao_2, evento_opcao_3]:
		botao.disabled = true
		botao.hide()
	evento_escolha_resolvida = true
	evento_texto.hide()
	evento_resultado.text = texto
	evento_resultado.show()
	evento_continuar.show()
	evento_overlay.show()
	evento_painel.hide()
	_atualizar_interface()


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
	if tipo == "deck_remover":
		return "Escolha uma carta para remover."
	if tipo == "deck_recalibrar":
		return "Escolha uma carta para recalibrar."
	return ""


func _mostrar_recompensas() -> void:
	if not mapa_no_em_andamento.is_empty() and not mapa_gerado:
		return
	aguardando_recompensa = true
	var tipo_no: String = str(mapa_run.obter_no(mapa_no_em_andamento).get("tipo", "")) if mapa_gerado else "combate"
	oferta_recompensa.gerar_combate(tipo_no)

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
	# O canvas ja cresce com a janela: dobrar esse ganho fazia as cartas
	# invadirem as acoes da recompensa em 1920x1080.
	var area: Vector2 = get_viewport().get_visible_rect().size
	return clampf(minf(area.x / 880.0, area.y / 500.0), 1.35, 1.55)


func _mostrar_consulta_baralho() -> void:
	_consulta_baralho_combate = topo_combate.visible and not aguardando_recompensa and not aguardando_recompensa_elite and not _combate_terminou()
	if not aguardando_recompensa and not aguardando_recompensa_elite and not _consulta_baralho_combate:
		return
	hud_inspecao.esconder()
	foco_recompensa_anterior = get_viewport().gui_get_focus_owner() as Control
	if _consulta_baralho_combate:
		foco_recompensa_anterior = topo_baralho
	elif foco_recompensa_anterior == null or not _foco_pertence_a_oferta(foco_recompensa_anterior):
		foco_recompensa_anterior = recompensa_opcao_1 if aguardando_recompensa else (reliquia_opcao_1 if etapa_recompensa_elite == "reliquia" else carta_rara_opcao_1)
	if not _consulta_baralho_combate:
		for controle in _controles_da_oferta_atual():
			controle.disabled = true
		recompensas.mouse_filter = Control.MOUSE_FILTER_IGNORE
		recompensa_elite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	baralho_resumo.text = "%d cartas na run" % baralho_run.size()
	_preencher_consulta_cartas(baralho_run)
	baralho_titulo.text = "BARALHO DA RUN"
	baralho_scrim.show()
	baralho_overlay.show()
	baralho_fechar.grab_focus()


func _mostrar_consulta_pilha(origem: String) -> void:
	if origem != "compra" and origem != "descarte":
		return
	if not topo_combate.visible or _combate_terminou() or baralho_overlay.visible:
		return
	_consulta_baralho_combate = true
	hud_inspecao.esconder()
	foco_recompensa_anterior = compra_painel if origem == "compra" else descarte_painel
	var cartas: Array[String] = pilha_compra if origem == "compra" else pilha_descarte
	baralho_titulo.text = "PILHA DE COMPRA" if origem == "compra" else "PILHA DE DESCARTE"
	baralho_resumo.text = "%d carta(s) neste combate" % cartas.size()
	_preencher_consulta_cartas(cartas)
	baralho_scrim.show()
	baralho_overlay.show()
	baralho_fechar.grab_focus()


func _preencher_consulta_cartas(cartas: Array[String]) -> void:
	baralho_vazio.visible = cartas.is_empty()
	for filho in baralho_lista.get_children():
		baralho_lista.remove_child(filho)
		filho.queue_free()
	baralho_lista.columns = 5 if get_viewport().get_visible_rect().size.x >= 1440.0 else 3
	for id_carta in cartas:
		var dados: Dictionary = _dados_carta_token(id_carta)
		if dados.is_empty():
			continue
		var carta: Button = CENA_CARTA.instantiate() as Button
		carta.set_meta("id_carta", id_carta)
		carta.set("nome_carta", str(dados["nome"]))
		carta.set("custo", int(dados["custo"]))
		carta.set("descricao", _descricao_recompensa(dados))
		baralho_lista.add_child(carta)
		carta.call("configurar_escala", 0.82)
		carta.call("aplicar_visual", descanso_regras.id_base(id_carta), str(dados.get("tipo", "ataque")))
		carta.call("configurar_recompensa", _tooltip_recompensa(dados))


func _ao_ativar_pilha(evento: InputEvent, origem: String) -> void:
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
		_mostrar_consulta_pilha(origem)
	elif evento is InputEventKey and evento.pressed and (evento.keycode == KEY_ENTER or evento.keycode == KEY_SPACE):
		_mostrar_consulta_pilha(origem)


func _atualizar_destaque_pilha(painel: Panel) -> void:
	(painel.get_node("Interacao") as Panel).visible = painel.visible and (painel.has_focus() or painel.get_global_rect().has_point(get_viewport().get_mouse_position()))


func _ao_clicar_fora_consulta(evento: InputEvent) -> void:
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
		_fechar_consulta_baralho()


func _fechar_consulta_baralho() -> void:
	baralho_overlay.hide()
	baralho_scrim.hide()
	if not _consulta_baralho_combate:
		recompensas.mouse_filter = Control.MOUSE_FILTER_PASS
		recompensa_elite.mouse_filter = Control.MOUSE_FILTER_PASS
		for controle in _controles_da_oferta_atual():
			controle.disabled = false
	_consulta_baralho_combate = false
	if is_instance_valid(foco_recompensa_anterior):
		foco_recompensa_anterior.grab_focus()


func _abrir_configuracoes() -> void:
	if not topo_combate.visible or baralho_overlay.visible:
		return
	hud_inspecao.esconder()
	_atualizar_configuracoes()
	configuracoes_scrim.show()
	configuracoes_overlay.show()
	configuracoes_fechar.grab_focus()


func _fechar_configuracoes() -> void:
	configuracoes_overlay.hide()
	configuracoes_scrim.hide()
	if topo_configuracoes.visible:
		topo_configuracoes.grab_focus()


func _atualizar_configuracoes() -> void:
	var indice_master: int = AudioServer.get_bus_index("Master")
	var som_ligado: bool = indice_master >= 0 and not AudioServer.is_bus_mute(indice_master)
	configuracoes_som.text = "SOM: %s" % ("LIGADO" if som_ligado else "DESLIGADO")
	var tela_cheia: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	configuracoes_tela.text = "TELA: %s" % ("CHEIA" if tela_cheia else "JANELA")
	configuracoes_movimento.text = "MOVIMENTO: %s" % ("REDUZIDO" if movimento_reduzido else "SUAVE")


func _alternar_movimento() -> void:
	movimento_reduzido = not movimento_reduzido
	_atualizar_configuracoes()
	APRESENTACAO_NEON.atualizar_barras(self, not movimento_reduzido)
	if is_instance_valid(vega_animada):
		vega_animada.atualizar_estado(combo, topo_combate.visible, movimento_reduzido)


func _alternar_som() -> void:
	var indice_master: int = AudioServer.get_bus_index("Master")
	if indice_master < 0:
		return
	AudioServer.set_bus_mute(indice_master, not AudioServer.is_bus_mute(indice_master))
	_atualizar_configuracoes()


func _alternar_tela_cheia() -> void:
	var tela_cheia: bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if tela_cheia else DisplayServer.WINDOW_MODE_FULLSCREEN)
	_atualizar_configuracoes()


func _unhandled_key_input(evento: InputEvent) -> void:
	if not evento.is_action_pressed("ui_cancel"):
		return
	if configuracoes_overlay.visible:
		_fechar_configuracoes()
		get_viewport().set_input_as_handled()
	elif baralho_overlay.visible and _consulta_baralho_combate:
		_fechar_consulta_baralho()
		get_viewport().set_input_as_handled()
	else:
		var carta_selecionada: Button = grupo_cartas.get_pressed_button() as Button
		if carta_selecionada != null:
			carta_selecionada.button_pressed = false
			_atualizar_alvos_carta_selecionada()
			get_viewport().set_input_as_handled()


func _input(evento: InputEvent) -> void:
	if evento is InputEventMouseMotion or evento is InputEventMouseButton:
		mira_por_teclado = false
	elif evento is InputEventKey and evento.pressed:
		mira_por_teclado = true
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_RIGHT and evento.pressed:
		if not topo_combate.visible or configuracoes_overlay.visible or baralho_overlay.visible:
			return
		var carta: Button = grupo_cartas.get_pressed_button() as Button
		if carta != null:
			carta.button_pressed = false
			_atualizar_alvos_carta_selecionada()
			get_viewport().set_input_as_handled()


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
		if dados.get("ganha_combo", 0) > 0:
			linhas_ataque.append("Ganha %d Combo." % int(dados["ganha_combo"]))
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
	if dados.get("ganha_combo", 0) > 0:
		linhas.append("Combo: ganha %d ao resolver." % int(dados["ganha_combo"]))
	if linhas.is_empty() and dados.get("tipo", "ataque") == "ataque":
		linhas.append("Ataque direto. Barreira absorve dano antes da Vida.")
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

		var ganho_combo: int = int(dados.get("ganha_combo", 0))
		if ganho_combo > 0:
			descricao += "\n+%d Combo" % ganho_combo
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
	nova_carta.toggled.connect(_atualizar_alvos_carta_selecionada.unbind(1))
	nova_carta.call("animar_entrada", float(mao.get_child_count() - 1) * 0.035)
	call_deferred("_redimensionar_cartas_da_mao")


func _escala_interface() -> float:
	var tamanho: Vector2 = get_viewport().get_visible_rect().size
	return minf(tamanho.x / 1280.0, tamanho.y / 720.0)


func _sincronizar_viewport_com_janela() -> void:
	var tamanho: Vector2i = get_window().size
	if tamanho.x >= 640 and tamanho.y >= 360 and topo_combate.visible:
		get_window().content_scale_size = tamanho
	else:
		get_window().content_scale_size = Vector2i(1152, 648)


func _escala_mao_atual() -> float:
	# A legibilidade da carta continua constante. Quando a mão cresce, a
	# contenção é resolvida pela separação entre cartas, não pela redução da
	# arte, do custo ou da descrição.
	return clampf(_escala_interface() * 0.88, 0.75, 1.08)


func _redimensionar_cartas_da_mao() -> void:
	var escala: float = _escala_mao_atual()
	for no in mao.get_children():
		var carta: Button = no as Button
		carta.call("configurar_escala", escala, true)
	mao.call_deferred("layout_cartas")
	_redimensionar_tipografia_combate()


func _fixar_retangulo_hud(controle: Control, area: Rect2) -> void:
	controle.anchor_left = 0.0
	controle.anchor_top = 0.0
	controle.anchor_right = 0.0
	controle.anchor_bottom = 0.0
	controle.offset_left = area.position.x
	controle.offset_top = area.position.y
	controle.offset_right = area.end.x
	controle.offset_bottom = area.end.y


func _layout_hud_combate() -> void:
	var viewport: Vector2 = get_viewport().get_visible_rect().size
	if viewport.x <= 0.0 or viewport.y <= 0.0:
		return
	var escala: float = clampf(minf(viewport.x / 1280.0, viewport.y / 720.0), 0.8, 1.5)
	var margem: float = 14.0 * escala
	var largura_jogador_hud: float = minf(viewport.x * 0.36, 610.0)
	var altura_jogador_hud: float = largura_jogador_hud / 3.10
	var largura_inimigo_hud: float = minf(viewport.x * 0.44, 650.0)
	var altura_inimigo_hud: float = largura_inimigo_hud / 3.75
	var x_inimigo_hud: float = viewport.x - largura_inimigo_hud - margem
	var y_topo: float = margem * 0.65
	var y_inimigo_hud: float = y_topo + altura_jogador_hud * 0.68
	var tamanho_energia: float = clampf(120.0 * escala, 96.0, 156.0)
	var x_energia: float = margem + 8.0
	var largura_pilha: float = 78.0 * escala
	var altura_pilha: float = 50.0 * escala
	var x_pilhas: float = x_energia + tamanho_energia + 7.0
	var empilhar_recursos: bool = viewport.x < 1400.0
	var largura_turno: float = 180.0 if empilhar_recursos else 260.0
	var altura_turno: float = 60.0 if empilhar_recursos else 82.0
	var intervalo_cais: float = 12.0 * escala
	var x_cais: float = x_pilhas + largura_pilha + intervalo_cais
	var largura_cais: float = viewport.x - largura_turno - margem - intervalo_cais - x_cais
	var altura_cais: float = clampf(viewport.y * 0.26, 160.0, 280.0)
	var y_cais: float = viewport.y - altura_cais - 10.0
	var x_jogador: float = viewport.x * 0.13
	var largura: float = clampf(viewport.x * 0.22, 225.0, 300.0)
	_fixar_retangulo_hud(topo_combate, Rect2(0.0, 0.0, viewport.x, altura_jogador_hud + y_topo + 8.0))
	var modulo_jogador: Control = topo_combate.get_node("ModuloJogador") as Control
	_fixar_retangulo_hud(modulo_jogador, Rect2(margem, y_topo, largura_jogador_hud, altura_jogador_hud))
	_fixar_retangulo_hud(topo_combate.get_node("TopoRetrato") as Control, Rect2(margem + largura_jogador_hud * 0.04, y_topo + altura_jogador_hud * 0.09, largura_jogador_hud * 0.25, altura_jogador_hud * 0.81))
	_fixar_retangulo_hud(topo_combate.get_node("TopoNome") as Control, Rect2(margem + largura_jogador_hud * 0.35, y_topo + altura_jogador_hud * 0.10, largura_jogador_hud * 0.40, altura_jogador_hud * 0.25))
	var area_vida_vega: Rect2 = Rect2(margem + largura_jogador_hud * 0.342, y_topo + altura_jogador_hud * 0.351, largura_jogador_hud * 0.615, altura_jogador_hud * 0.225)
	_fixar_retangulo_hud(topo_combate.get_node("BarraVidaIntegrada") as Control, area_vida_vega)
	_fixar_retangulo_hud(topo_vida, Rect2(area_vida_vega.position + area_vida_vega.size * Vector2(0.70, 0.16), area_vida_vega.size * Vector2(0.285, 0.70)))
	_fixar_retangulo_hud(topo_combate.get_node("TopoCoracao") as Control, Rect2(margem + largura_jogador_hud * 0.34, y_topo + altura_jogador_hud * 0.39, largura_jogador_hud * 0.065, altura_jogador_hud * 0.24))
	var area_reliquias: Rect2 = Rect2(margem + largura_jogador_hud * 0.34, y_topo + altura_jogador_hud * 0.64, largura_jogador_hud * 0.60, altura_jogador_hud * 0.23)
	_fixar_retangulo_hud(topo_relicario, area_reliquias)
	_fixar_retangulo_hud(topo_reliquias, area_reliquias)
	topo_reliquias.alignment = BoxContainer.ALIGNMENT_BEGIN
	var colunas_reliquias: int = maxi(4, topo_reliquias.get_child_count())
	var intervalo_reliquias: int = roundi(largura_jogador_hud * 0.009)
	topo_reliquias.add_theme_constant_override("separation", intervalo_reliquias)
	for icone: Button in topo_reliquias.get_children():
		icone.custom_minimum_size = Vector2((area_reliquias.size.x - float(intervalo_reliquias * (colunas_reliquias - 1))) / float(colunas_reliquias), area_reliquias.size.y)
		icone.add_theme_constant_override("icon_max_width", roundi(area_reliquias.size.y * 0.48))
		icone.add_theme_font_size_override("font_size", 9 if empilhar_recursos else 12)
		icone.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var botao_util: float = clampf(58.0 * escala, 43.0, 68.0)
	var x_util: float = viewport.x - margem - 3.0 * botao_util - 16.0
	var y_util: float = y_topo + 10.0 * escala
	_fixar_retangulo_hud(topo_baralho, Rect2(x_util, y_util, botao_util, botao_util))
	_fixar_retangulo_hud(topo_rota, Rect2(x_util + botao_util + 7.0, y_util, botao_util, botao_util))
	_fixar_retangulo_hud(topo_configuracoes, Rect2(x_util + 2.0 * (botao_util + 7.0), y_util, botao_util, botao_util))
	topo_vida_moldura.hide()
	topo_vida_preenchimento.hide()
	_fixar_retangulo_hud(vida_jogador_bar, Rect2(margem + largura_jogador_hud * 0.43, y_topo + altura_jogador_hud * 0.49, largura_jogador_hud * 0.32, maxf(8.0, altura_jogador_hud * 0.07)))
	topo_vida.add_theme_font_size_override("font_size", roundi(clampf(17.0 * escala, 16.0, 28.0)))
	var faixa_y: float = y_topo + 10.0 * escala
	var faixa_x: float = viewport.x * 0.5 - 110.0
	_fixar_retangulo_hud(turno_faixa, Rect2(faixa_x, faixa_y, 220.0, 65.0))
	_fixar_retangulo_hud(turno_titulo_label, Rect2(faixa_x + 10.0, faixa_y + 4.0, 200.0, 30.0))
	_fixar_retangulo_hud(turno_numero_painel, Rect2(faixa_x + 10.0, faixa_y + 40.0, 200.0, 24.0))
	_fixar_retangulo_hud(turno_numero_label, Rect2(faixa_x + 10.0, faixa_y + 40.0, 200.0, 24.0))
	_fixar_retangulo_hud(acao_label, Rect2(viewport.x * 0.40, viewport.y * 0.36, viewport.x * 0.20, 1.0))
	turno_titulo_label.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Bold.ttf"))
	var tamanho_consulta: Vector2 = Vector2(clampf(viewport.x * 0.60, 600.0, 880.0), clampf(viewport.y * 0.74, 420.0, 620.0))
	_fixar_retangulo_hud(baralho_overlay, Rect2((viewport - tamanho_consulta) * 0.5, tamanho_consulta))
	var altura_vega: float = clampf(viewport.y * 0.38, 215.0, 410.0)
	var chao_vega: float = viewport.y * 0.61
	_fixar_retangulo_hud(jogador, Rect2(x_jogador, chao_vega - altura_vega, largura, altura_vega))
	_fixar_retangulo_hud(alvo, Rect2(x_inimigo_hud, y_inimigo_hud, largura_inimigo_hud, altura_inimigo_hud))
	_fixar_retangulo_hud(alvo.get_node("RetratoInimigo") as Control, Rect2(largura_inimigo_hud * 0.035, altura_inimigo_hud * 0.10, largura_inimigo_hud * 0.24, altura_inimigo_hud * 0.79))
	var altura_sprite_inimigo: float = minf(clampf(viewport.y * 0.28, 130.0, 290.0), (chao_vega - y_inimigo_hud - altura_inimigo_hud - 8.0 * escala) / 1.1)
	_fixar_retangulo_hud(alvo.get_node("DroneCampoSprite") as Control, Rect2(largura_inimigo_hud * 0.36, chao_vega - altura_sprite_inimigo * 1.1 - y_inimigo_hud, altura_sprite_inimigo * 0.86, altura_sprite_inimigo))
	_fixar_retangulo_hud(alvo_visual_label, Rect2(x_inimigo_hud + largura_inimigo_hud * 0.32, y_inimigo_hud + altura_inimigo_hud * 0.16, largura_inimigo_hud * 0.44, altura_inimigo_hud * 0.17))
	_ajustar_titulo_hud(alvo_visual_label, 15 if empilhar_recursos else 20, 11)
	_fixar_retangulo_hud(intencao_painel, Rect2(x_inimigo_hud + largura_inimigo_hud * 0.79, y_inimigo_hud + altura_inimigo_hud * 0.17, largura_inimigo_hud * 0.18, altura_inimigo_hud * 0.70))
	_fixar_retangulo_hud(intencao_nome_visual_label, Rect2(x_inimigo_hud + largura_inimigo_hud * 0.80, y_inimigo_hud + altura_inimigo_hud * 0.25, largura_inimigo_hud * 0.17, altura_inimigo_hud * 0.14))
	intencao_nome_visual_label.add_theme_font_size_override("font_size", 11 if empilhar_recursos else 14)
	_fixar_retangulo_hud(intencao_icone, Rect2(x_inimigo_hud + largura_inimigo_hud * 0.85, y_inimigo_hud + altura_inimigo_hud * 0.40, largura_inimigo_hud * 0.07, altura_inimigo_hud * 0.21))
	_fixar_retangulo_hud(intencao_valor_visual_label, Rect2(x_inimigo_hud + largura_inimigo_hud * 0.80, y_inimigo_hud + altura_inimigo_hud * 0.61, largura_inimigo_hud * 0.17, altura_inimigo_hud * 0.23))
	_fixar_retangulo_hud(vida_inimigo_bar, Rect2(x_inimigo_hud + largura_inimigo_hud * 0.345, y_inimigo_hud + altura_inimigo_hud * 0.555, largura_inimigo_hud * 0.29, maxf(8.0, altura_inimigo_hud * 0.09)))
	_fixar_retangulo_hud(vida_inimigo_label, Rect2(x_inimigo_hud + largura_inimigo_hud * 0.65, y_inimigo_hud + altura_inimigo_hud * 0.51, largura_inimigo_hud * 0.12, altura_inimigo_hud * 0.18))
	var y_estados: float = y_inimigo_hud + altura_inimigo_hud * 0.76
	var x_estados: float = x_inimigo_hud + largura_inimigo_hud * 0.34
	var altura_estado: float = altura_inimigo_hud * 0.16
	var passo_estado: float = largura_inimigo_hud * 0.14
	_fixar_retangulo_hud(estados_inimigo_painel, Rect2(x_estados, y_estados, largura_inimigo_hud * 0.43, altura_estado))
	var icones_estado: Array[Control] = [estados_inimigo_barreira_icone, estados_inimigo_exposto_icone, estados_inimigo_enfraquecido_icone]
	var numeros_estado: Array[Label] = [estados_inimigo_barreira_label, estados_inimigo_exposto_label, estados_inimigo_enfraquecido_label]
	for indice: int in icones_estado.size():
		_fixar_retangulo_hud(icones_estado[indice], Rect2(x_estados + passo_estado * indice, y_estados, altura_estado, altura_estado))
		_fixar_retangulo_hud(numeros_estado[indice], Rect2(x_estados + passo_estado * indice + altura_estado, y_estados, passo_estado - altura_estado, altura_estado))
		numeros_estado[indice].add_theme_font_size_override("font_size", 11 if empilhar_recursos else 15)
	var painel_inimigo_y: float = y_inimigo_hud
	var stats_y: float = minf(chao_vega + 7.0, y_cais - (104.0 if empilhar_recursos else 106.0) - 8.0)
	var stats_x: float = margem + 4.0
	var stats_largura: float = x_cais - stats_x - intervalo_cais
	var area_barreira: Rect2 = Rect2(0.0, 0.0, 166.0, 70.0) if empilhar_recursos else Rect2(0.0, 0.0, 238.0, 103.0)
	var area_combo: Rect2 = Rect2(0.0, area_barreira.size.y - 8.0, stats_largura, stats_largura / 5.34)
	var stats_altura: float = area_combo.end.y
	_fixar_retangulo_hud(stats_jogador_painel, Rect2(stats_x, stats_y, stats_largura, stats_altura))
	_fixar_retangulo_hud(stats_jogador_painel.get_node("ModuloBarreira") as Control, area_barreira)
	_fixar_retangulo_hud(stats_jogador_painel.get_node("ModuloCombo") as Control, area_combo)
	_fixar_retangulo_hud(barreira_icone, Rect2(stats_x + area_barreira.size.x * 0.278, stats_y + area_barreira.size.y * 0.255, area_barreira.size.x * 0.084, area_barreira.size.y * 0.22))
	_fixar_retangulo_hud(barreira_label, Rect2(stats_x + area_barreira.size.x * 0.205, stats_y + area_barreira.size.y * 0.48, area_barreira.size.x * 0.23, area_barreira.size.y * 0.29))
	_fixar_retangulo_hud(combo_label, Rect2(stats_x + area_combo.position.x + area_combo.size.x * 0.075, stats_y + area_combo.position.y + area_combo.size.y * 0.43, area_combo.size.x * 0.18, area_combo.size.y * 0.32))
	barreira_label.add_theme_font_size_override("font_size", 17 if empilhar_recursos else 24)
	combo_label.add_theme_font_size_override("font_size", 12 if empilhar_recursos else 20)
	var legenda_combo: Label = stats_jogador_painel.get_node("LegendaComboNeon") as Label
	_fixar_retangulo_hud(legenda_combo, Rect2(area_combo.position + Vector2(area_combo.size.x * 0.075, area_combo.size.y * 0.19), Vector2(area_combo.size.x * 0.18, area_combo.size.y * 0.20)))
	legenda_combo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	legenda_combo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	legenda_combo.add_theme_font_size_override("font_size", 8 if empilhar_recursos else 10)
	legenda_combo.add_theme_color_override("font_color", Color("c9e4ef"))
	if marcado_visual != null:
		_fixar_retangulo_hud(marcado_visual, Rect2(margem + largura_jogador_hud * 0.59, y_topo + altura_jogador_hud * 0.21, largura_jogador_hud * 0.33, altura_jogador_hud * 0.13))
		marcado_visual.add_theme_font_size_override("font_size", 9 if empilhar_recursos else 12)
		marcado_visual.z_index = topo_combate.z_index + 3
	if estado_especial_visual != null:
		_fixar_retangulo_hud(estado_especial_visual, Rect2(x_estados, y_inimigo_hud + altura_inimigo_hud * 0.35, largura_inimigo_hud * 0.43, altura_inimigo_hud * 0.16))
		estado_especial_visual.add_theme_font_size_override("font_size", 10 if empilhar_recursos else 13)
	var vivos: int = encontro_combate.inimigos_vivos().size()
	for indice in alvos_multiplos.size():
		var largura_multipla: float = clampf(viewport.x * 0.29, 295.0, 500.0)
		var altura_multipla: float = largura_multipla / 3.75
		var x_multiplo: float = x_inimigo_hud if vivos == 1 else viewport.x * (0.39 if viewport.x < 1400.0 else 0.43) + float(indice) * viewport.x * (0.31 if viewport.x < 1400.0 else 0.29)
		var botao_multiplo: Button = alvos_multiplos[indice]
		_fixar_retangulo_hud(botao_multiplo, Rect2(x_multiplo, painel_inimigo_y, largura_multipla, altura_multipla))
		_fixar_retangulo_hud(botao_multiplo.get_node("ModuloInimigo") as Control, Rect2(Vector2.ZERO, botao_multiplo.size))
		_fixar_retangulo_hud(botao_multiplo.get_node("RetratoInimigo") as Control, Rect2(largura_multipla * 0.04, altura_multipla * 0.08, largura_multipla * 0.23, altura_multipla * 0.82))
		_ajustar_sprite_drone(botao_multiplo, largura_multipla, viewport.y)
		var nome_multiplo: Label = botao_multiplo.get_node("Nome") as Label
		_fixar_retangulo_hud(nome_multiplo, Rect2(largura_multipla * 0.31, altura_multipla * 0.10, largura_multipla * 0.43, altura_multipla * 0.25))
		_ajustar_titulo_hud(nome_multiplo, 12 if empilhar_recursos else 16, 9)
		var intencao_multipla: Label = botao_multiplo.get_node("Intencao") as Label
		_fixar_retangulo_hud(intencao_multipla, Rect2(largura_multipla * 0.80, altura_multipla * 0.25, largura_multipla * 0.17, altura_multipla * 0.14))
		intencao_multipla.add_theme_font_size_override("font_size", 9 if empilhar_recursos else 11)
		var valor_multiplo: Label = botao_multiplo.get_node("IntencaoValor") as Label
		_fixar_retangulo_hud(valor_multiplo, Rect2(largura_multipla * 0.80, altura_multipla * 0.58, largura_multipla * 0.17, altura_multipla * 0.26))
		valor_multiplo.add_theme_font_size_override("font_size", 12 if viewport.x < 1400.0 else 16)
		var estados_multiplos: Label = botao_multiplo.get_node("BarreiraLabel") as Label
		_fixar_retangulo_hud(estados_multiplos, Rect2(largura_multipla * 0.33, altura_multipla * 0.77, largura_multipla * 0.44, altura_multipla * 0.18))
		estados_multiplos.add_theme_font_size_override("font_size", 9 if viewport.x < 1400.0 else 12)
		_fixar_retangulo_hud(botao_multiplo.get_node("VidaBar") as Control, Rect2(largura_multipla * 0.345, altura_multipla * 0.565, largura_multipla * 0.29, 7.0))
		_fixar_retangulo_hud(botao_multiplo.get_node("VidaLabel") as Control, Rect2(largura_multipla * 0.65, altura_multipla * 0.51, largura_multipla * 0.12, altura_multipla * 0.18))
		_fixar_retangulo_hud(botao_multiplo.get_node("IntencaoIcone") as Control, Rect2(largura_multipla * 0.85, altura_multipla * 0.40, largura_multipla * 0.07, altura_multipla * 0.21))
	var base_y: float = viewport.y
	_fixar_retangulo_hud(mao_dock, Rect2(x_cais, y_cais, largura_cais, altura_cais))
	_fixar_retangulo_hud(mao_dock.get_node("CaisIlustrado") as Control, Rect2(Vector2.ZERO, mao_dock.size))
	_fixar_retangulo_hud(mao, Rect2(x_cais, y_cais - 38.0 * escala, largura_cais, base_y - y_cais + 38.0 * escala))
	var y_energia: float = base_y - tamanho_energia - 12.0
	_fixar_retangulo_hud(energia_painel, Rect2(x_energia, y_energia, tamanho_energia, tamanho_energia))
	_fixar_retangulo_hud(energia_painel.get_node("ModuloEnergia") as Control, Rect2(Vector2.ZERO, energia_painel.size))
	_fixar_retangulo_hud(energia_visual_label, Rect2(x_energia + tamanho_energia * 0.18, y_energia + tamanho_energia * 0.24, tamanho_energia * 0.64, tamanho_energia * 0.30))
	energia_visual_label.add_theme_font_size_override("font_size", 22 if empilhar_recursos else 32)
	var y_compra: float = base_y - 2.0 * altura_pilha - 13.0
	_fixar_retangulo_hud(compra_painel, Rect2(x_pilhas, y_compra, largura_pilha, altura_pilha))
	_fixar_retangulo_hud(compra_icone, Rect2(x_pilhas + 8.0, y_compra + 16.0 * escala, 27.0 * escala, 27.0 * escala))
	_fixar_retangulo_hud(compra_label, Rect2(x_pilhas + 42.0 * escala, y_compra + 15.0 * escala, 28.0 * escala, 27.0 * escala))
	var y_descarte: float = y_compra + altura_pilha + 5.0
	_fixar_retangulo_hud(descarte_painel, Rect2(x_pilhas, y_descarte, largura_pilha, altura_pilha))
	_fixar_retangulo_hud(descarte_icone, Rect2(x_pilhas + 8.0, y_descarte + 16.0 * escala, 27.0 * escala, 27.0 * escala))
	_fixar_retangulo_hud(descarte_label, Rect2(x_pilhas + 42.0 * escala, y_descarte + 15.0 * escala, 28.0 * escala, 27.0 * escala))
	_fixar_retangulo_hud(mao_status_label, Rect2(viewport.x - largura_turno - margem, base_y - altura_turno - 53.0, largura_turno, 30.0))
	mao_status_label.add_theme_font_size_override("font_size", 13 if empilhar_recursos else 16)
	_fixar_retangulo_hud(botao_encerrar_turno, Rect2(viewport.x - largura_turno - margem, base_y - altura_turno - 15.0, largura_turno, altura_turno))
	_fixar_retangulo_hud(botao_encerrar_turno.get_node("BotaoIlustrado") as Control, Rect2(Vector2.ZERO, botao_encerrar_turno.size))
	botao_encerrar_turno.text = "ENCERRAR TURNO"
	botao_encerrar_turno.add_theme_font_size_override("font_size", 16 if empilhar_recursos else 22)


func _ajustar_titulo_hud(rotulo: Label, tamanho: int, minimo: int) -> void:
	var fonte: Font = rotulo.get_theme_font("font")
	while tamanho > minimo and fonte.get_string_size(rotulo.text, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho).x > rotulo.size.x:
		tamanho -= 1
	rotulo.add_theme_font_size_override("font_size", tamanho)


func _ajustar_sprite_drone(botao: Button, largura_painel: float, altura_viewport: float) -> void:
	var sprite: TextureRect = botao.get_node("DroneCampoSprite") as TextureRect
	var altura_sprite: float = clampf(altura_viewport * 0.28, 155.0, 290.0)
	var largura_sprite: float = altura_sprite * 0.82
	_fixar_retangulo_hud(sprite, Rect2((largura_painel - largura_sprite) * 0.5, altura_viewport * 0.61 - altura_sprite * 1.1 - botao.position.y, largura_sprite, altura_sprite))


func _ao_clicar_sprite_drone(evento: InputEvent, botao: Button) -> void:
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed and botao.visible and not botao.disabled:
		botao.pressed.emit()


func _redimensionar_tipografia_combate() -> void:
	var escala: float = clampf(_escala_interface(), 0.85, 1.15)
	var tamanhos: Dictionary = {
		"TurnoTituloLabel": 25,
		"TurnoNumeroLabel": 16,
		"AcaoLabel": 18,
		"RunStatusLabel": 17,
		"IntencaoVisualLabel": 16,
		"IntencaoValorVisualLabel": 17,
		"EstadosInimigoVisualLabel": 15,
		"VidaJogadorLabel": 18,
		"VidaInimigoLabel": 18,
		"CompraLabel": 18,
		"DescarteLabel": 18,
		"Jogador": 25,
		"EncerrarTurno": 23
	}
	for nome: String in tamanhos:
		var controle: Control = get_node(nome) as Control
		controle.add_theme_font_size_override("font_size", roundi(float(tamanhos[nome]) * escala))


func _criar_alvos_multiplos() -> void:
	for indice in range(2):
		var botao: Button = Button.new()
		botao.name = "AlvoMultiplo%d" % (indice + 1)
		botao.add_to_group("alvo_multiplo")
		botao.set_meta("indice_inimigo", indice)
		botao.anchor_left = 0.50 + float(indice) * 0.23
		botao.anchor_right = 0.71 + float(indice) * 0.23
		botao.anchor_top = 0.235
		botao.anchor_bottom = 0.55
		botao.focus_mode = Control.FOCUS_ALL
		botao.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		botao.add_theme_color_override("font_color", Color("#f5f7fa"))
		botao.add_theme_color_override("font_hover_color", Color("#f5f7fa"))
		botao.add_theme_color_override("font_focus_color", Color("#f5f7fa"))
		botao.add_theme_font_size_override("font_size", 14)
		botao.add_theme_stylebox_override("normal", alvo.get_theme_stylebox("normal"))
		botao.add_theme_stylebox_override("hover", alvo.get_theme_stylebox("hover"))
		botao.add_theme_stylebox_override("focus", alvo.get_theme_stylebox("focus"))
		botao.add_theme_stylebox_override("disabled", alvo.get_theme_stylebox("disabled"))
		var sprite_drone: TextureRect = TextureRect.new()
		sprite_drone.name = "DroneCampoSprite"
		sprite_drone.texture = DRONE_CAMPO
		sprite_drone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite_drone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sprite_drone.mouse_filter = Control.MOUSE_FILTER_STOP
		sprite_drone.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		sprite_drone.gui_input.connect(_ao_clicar_sprite_drone.bind(botao))
		botao.add_child(sprite_drone)
		var interacao: Panel = Panel.new()
		interacao.name = "Interacao"
		interacao.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		interacao.mouse_filter = Control.MOUSE_FILTER_IGNORE
		interacao.z_index = 4
		interacao.add_theme_stylebox_override("panel", (alvo.get_node("Interacao") as Panel).get_theme_stylebox("panel"))
		interacao.hide()
		botao.add_child(interacao)
		var conteudo: Label = Label.new()
		conteudo.name = "Conteudo"
		conteudo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		conteudo.offset_left = 7.0
		conteudo.offset_right = -7.0
		conteudo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		conteudo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		conteudo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		conteudo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		conteudo.z_index = 5
		conteudo.add_theme_color_override("font_color", Color("#f5f7fa"))
		conteudo.add_theme_font_size_override("font_size", 17)
		botao.add_child(conteudo)
		conteudo.hide()
		_criar_visual_vida_alvo_multiplo(botao)
		botao.pressed.connect(_jogar_carta.bind("inimigo", indice))
		botao.mouse_entered.connect(_atualizar_destaque_hud.bind(botao))
		botao.mouse_exited.connect(_atualizar_destaque_hud.bind(botao))
		botao.focus_entered.connect(_atualizar_destaque_hud.bind(botao))
		botao.focus_exited.connect(_atualizar_destaque_hud.bind(botao))
		botao.mouse_entered.connect(_ao_entrar_inspecao_hud.bind(botao))
		botao.mouse_exited.connect(_ao_sair_inspecao_hud.bind(botao))
		botao.focus_entered.connect(_ao_entrar_inspecao_hud.bind(botao))
		botao.focus_exited.connect(_ao_sair_inspecao_hud.bind(botao))
		botao.hide()
		add_child(botao)
		APRESENTACAO_NEON.estilizar_alvo_multiplo(botao)
		APRESENTACAO_NEON.preparar_barra_vida_inimigo(botao.get_node("VidaBar") as ProgressBar)
		alvos_multiplos.append(botao)
func _criar_visual_vida_alvo_multiplo(botao: Button) -> void:
	var barra: ProgressBar = ProgressBar.new()
	barra.name = "VidaBar"
	barra.anchor_left = 0.08
	barra.anchor_right = 0.92
	barra.anchor_top = 0.31
	barra.anchor_bottom = 0.36
	barra.offset_left = 0.0
	barra.offset_right = 0.0
	barra.offset_top = 0.0
	barra.offset_bottom = 0.0
	barra.show_percentage = false
	barra.mouse_filter = Control.MOUSE_FILTER_IGNORE
	barra.z_index = 6
	var trilho: StyleBox = vida_inimigo_bar.get_theme_stylebox("background")
	var preenchimento: StyleBox = vida_inimigo_bar.get_theme_stylebox("fill")
	if trilho != null:
		barra.add_theme_stylebox_override("background", trilho)
	if preenchimento != null:
		barra.add_theme_stylebox_override("fill", preenchimento)
	botao.add_child(barra)

	var vida_label: Label = Label.new()
	vida_label.name = "VidaLabel"
	vida_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	vida_label.anchor_left = 0.08
	vida_label.anchor_right = 0.92
	vida_label.anchor_top = 0.36
	vida_label.anchor_bottom = 0.48
	vida_label.offset_left = 0.0
	vida_label.offset_right = 0.0
	vida_label.offset_top = 0.0
	vida_label.offset_bottom = 0.0
	vida_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vida_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vida_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vida_label.z_index = 7
	vida_label.add_theme_color_override("font_color", Color("#f5f7fa"))
	vida_label.add_theme_color_override("font_shadow_color", Color("#07111a"))
	vida_label.add_theme_constant_override("shadow_offset_x", 1)
	vida_label.add_theme_constant_override("shadow_offset_y", 1)
	vida_label.add_theme_font_size_override("font_size", 15)
	botao.add_child(vida_label)

	var barreira_label: Label = Label.new()
	barreira_label.name = "BarreiraLabel"
	barreira_label.anchor_left = 0.08
	barreira_label.anchor_right = 0.92
	barreira_label.anchor_top = 1.01
	barreira_label.anchor_bottom = 1.19
	barreira_label.offset_left = 0.0
	barreira_label.offset_right = 0.0
	barreira_label.offset_top = 0.0
	barreira_label.offset_bottom = 0.0
	barreira_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	barreira_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	barreira_label.clip_text = true
	barreira_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	barreira_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	barreira_label.z_index = 7
	barreira_label.add_theme_color_override("font_color", Color("#50e6e0"))
	barreira_label.add_theme_font_size_override("font_size", 14)
	botao.add_child(barreira_label)

	var nome_label: Label = Label.new()
	nome_label.name = "Nome"
	nome_label.anchor_left = 0.05
	nome_label.anchor_right = 0.95
	nome_label.anchor_top = 0.17
	nome_label.anchor_bottom = 0.30
	nome_label.offset_left = 0.0
	nome_label.offset_right = 0.0
	nome_label.offset_top = 0.0
	nome_label.offset_bottom = 0.0
	nome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nome_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	nome_label.clip_text = true
	nome_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nome_label.z_index = 7
	nome_label.add_theme_color_override("font_color", Color("#f5f7fa"))
	nome_label.add_theme_font_size_override("font_size", 16)
	botao.add_child(nome_label)

	var intencao_label: Label = Label.new()
	intencao_label.name = "Intencao"
	intencao_label.anchor_left = 0.06
	intencao_label.anchor_right = 0.94
	intencao_label.anchor_top = 0.46
	intencao_label.anchor_bottom = 0.86
	intencao_label.offset_left = 0.0
	intencao_label.offset_right = 0.0
	intencao_label.offset_top = 0.0
	intencao_label.offset_bottom = 0.0
	intencao_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intencao_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	intencao_label.clip_text = true
	intencao_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	intencao_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intencao_label.z_index = 7
	intencao_label.add_theme_color_override("font_color", Color("#f5f7fa"))
	intencao_label.add_theme_font_size_override("font_size", 13)
	botao.add_child(intencao_label)
	var valor_intencao: Label = Label.new()
	valor_intencao.name = "IntencaoValor"
	valor_intencao.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	valor_intencao.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	valor_intencao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	valor_intencao.max_lines_visible = 2
	valor_intencao.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	valor_intencao.mouse_filter = Control.MOUSE_FILTER_IGNORE
	valor_intencao.z_index = 8
	valor_intencao.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Bold.ttf"))
	botao.add_child(valor_intencao)
	var icone_intencao: TextureRect = TextureRect.new()
	icone_intencao.name = "IntencaoIcone"
	icone_intencao.anchor_left = 0.80
	icone_intencao.anchor_right = 0.94
	icone_intencao.anchor_top = 0.63
	icone_intencao.anchor_bottom = 0.79
	icone_intencao.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone_intencao.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone_intencao.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icone_intencao.z_index = 8
	botao.add_child(icone_intencao)


	# São indicadores únicos do encontro, não uma cópia por alvo múltiplo.
	if marcado_visual != null:
		return
	marcado_visual = Label.new()
	marcado_visual.name = "MarcadoVisual"
	marcado_visual.anchor_left = 0.11
	marcado_visual.anchor_right = 0.34
	marcado_visual.anchor_top = 0.56
	marcado_visual.anchor_bottom = 0.61
	marcado_visual.add_theme_color_override("font_color", Color("#f5d26b"))
	marcado_visual.add_theme_font_size_override("font_size", 15)
	marcado_visual.text = "MARCA · DISPARO +6"
	marcado_visual.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Bold.ttf"))
	marcado_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marcado_visual.hide()
	add_child(marcado_visual)
	estado_especial_visual = Label.new()
	estado_especial_visual.name = "EstadoEspecialInimigo"
	estado_especial_visual.anchor_left = 0.68
	estado_especial_visual.anchor_right = 0.94
	estado_especial_visual.anchor_top = 0.57
	estado_especial_visual.anchor_bottom = 0.61
	estado_especial_visual.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	estado_especial_visual.add_theme_color_override("font_color", Color("#f5d26b"))
	estado_especial_visual.add_theme_font_size_override("font_size", 16)
	estado_especial_visual.add_theme_font_override("font", preload("res://ui_hq_v1/fontes/BarlowSemiCondensed-Bold.ttf"))
	estado_especial_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	estado_especial_visual.hide()
	add_child(estado_especial_visual)


func _jogador_marcado() -> bool:
	for combatente in encontro_combate.inimigos_vivos():
		if combatente.identificador == "sentinela_inspecao" and combatente.marcado:
			return true
	return false


func _ao_clicar_no_alvo() -> void:
	_jogar_carta("inimigo", 0)


func _ao_clicar_no_jogador() -> void:
	_jogar_carta("jogador")


func _jogar_carta(destino: String, indice_alvo: int = 0) -> void:
	if _combate_terminou():
		return
	var inimigo_escolhido: InimigoCombate = null
	if destino == "inimigo":
		if indice_alvo < 0 or indice_alvo >= encontro_combate.inimigos.size():
			return
		inimigo_escolhido = encontro_combate.inimigos[indice_alvo]
		if inimigo_escolhido.vida <= 0:
			_registrar_acao("Esse alvo já foi derrotado.")
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
		inimigo_escolhido if destino == "inimigo" else estado_jogador,
		destino,
		{
			"energia": energia,
			"combo": combo
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
			if combo_antes > 0:
				feedback_combate.consumir_combo()

	if eh_ataque and destino == "inimigo":
		if is_instance_valid(vega_animada):
			vega_animada.socar()
		var alvo_de_cena: Control = alvo
		if encontro_combate.inimigos.size() > 1 and indice_alvo < alvos_multiplos.size():
			alvo_de_cena = alvos_multiplos[indice_alvo]
		_mostrar_impacto_carta(alvo_de_cena, int(resultado["dano_na_vida"]), int(resultado["absorvido"]))
		print("%s: Barreira absorveu %d. Dano na Vida: %d." % [
			inimigo_escolhido.nome,
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

	_descartar_carta(selecionada, not _combate_terminou())
	_atualizar_alvos_carta_selecionada()
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
	elif encontro_combate.inimigos_vivos().is_empty():
		print("Você venceu o combate %d!" % combate_atual)
		_resolver_vitoria()


func _ganhar_combo() -> void:
	if jogador_combate.ganhar_combo(
		BARREIRA_JUNTAS_RETORNO,
		LIMIAR_JUNTAS_RETORNO
	):
		print("Juntas de Retorno concedeu %d de Barreira." % BARREIRA_JUNTAS_RETORNO)


func _descartar_carta(carta: Button, animar: bool = false) -> void:
	var id_carta: String = str(carta.get_meta("id_carta"))
	baralho_combate.descartar_identificador(id_carta)

	carta.set_pressed_no_signal(false)
	carta.button_group = null

	# O descarte é imediato; a carta recolhe na própria mão sem viajar pelo campo.
	if animar and carta.is_visible_in_tree() and topo_combate.visible:
		carta.reparent(self, true)
		carta.name = "CartaConsumida"
		carta.add_to_group("carta_consumida")
		carta.call("animar_consumo", movimento_reduzido)
	else:
		mao.remove_child(carta)
		carta.queue_free()


func _ponto_impacto_carta(destino_visual: Control) -> Vector2:
	var sprite: Control = destino_visual.get_node_or_null("DroneCampoSprite") as Control
	if sprite != null and sprite.visible:
		return sprite.get_global_rect().get_center()
	return destino_visual.get_global_rect().get_center()


func _mostrar_impacto_carta(alvo_visual: Control, dano_na_vida: int, absorvido: int) -> void:
	if not topo_combate.visible or not is_instance_valid(alvo_visual) or not alvo_visual.is_visible_in_tree():
		return
	if dano_na_vida > 0:
		_animar_flash_dano(alvo_visual)
		var corpo: Control = alvo_visual.get_node_or_null("DroneCampoSprite") as Control
		if corpo != null:
			corpo.call("reagir", "dano")
	_mostrar_feedback_dano(dano_na_vida, absorvido, alvo_visual)


func _descartar_mao() -> void:
	for no in mao.get_children():
		var carta: Button = no as Button
		_descartar_carta(carta)


func _ao_encerrar_turno() -> void:
	if _combate_terminou():
		return
	botao_encerrar_turno.get_node("RealceNeon").call("confirmar")

	_descartar_mao()
	jogador_combate.encerrar_turno()
	feedback_combate.observar(energia, barreira, combo, false)
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
	var barreira_antes: int = barreira
	var acoes: Array[Dictionary] = encontro_combate.executar_fase_inimiga_multiplos(jogador_combate)
	var absorvido_total: int = barreira_antes - barreira
	feedback_combate.absorver_barreira(absorvido_total, barreira_antes > 0 and barreira == 0)
	for acao in acoes:
		var inimigo_da_acao: InimigoCombate = acao["inimigo"] as InimigoCombate
		var indice_visual: int = encontro_combate.inimigos.find(inimigo_da_acao)
		var placa_visual: Control = alvos_multiplos[indice_visual] if encontro_combate.inimigos.size() > 1 and indice_visual >= 0 else alvo
		var corpo_visual: Control = placa_visual.get_node("DroneCampoSprite") as Control
		corpo_visual.call("reagir", "ataque" if not (acao["resultados_golpes"] as Array).is_empty() else "suporte")
		for resultado in acao["resultados_golpes"]:
			if int(resultado["dano_na_vida"]) > 0:
				if is_instance_valid(vega_animada):
					vega_animada.receber_dano()
				_animar_flash_dano(jogador)
			_mostrar_feedback_dano(int(resultado["dano_na_vida"]), int(resultado["absorvido"]), jogador)
		_registrar_acao("%s executou %s." % [(acao["inimigo"] as InimigoCombate).nome, acao["nome"]])


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
	_mostrar_feedback_dano(dano_na_vida, absorvido, alvo)


func _mostrar_feedback_dano(dano_na_vida: int, absorvido: int, alvo_visual: Control = null) -> void:
	if dano_na_vida <= 0 and absorvido <= 0:
		return
	if not _dano_feedback_posicao_pronta:
		_capturar_posicao_feedback_dano()
	var linhas: PackedStringArray = []
	if dano_na_vida > 0:
		linhas.append("-%d" % dano_na_vida)
	if absorvido > 0:
		linhas.append("-%d Barreira" % absorvido)
	dano_feedback_label.text = "\n".join(linhas)
	dano_feedback_label.add_theme_color_override("font_color", Color("f322b5") if dano_na_vida > 0 else Color("22e8f5"))
	dano_feedback_label.show()
	dano_feedback_label.modulate = Color.WHITE
	var posicao_inicial: Vector2 = _dano_feedback_posicao_base
	if is_instance_valid(alvo_visual):
		var sprite: Control = alvo_visual.get_node_or_null("DroneCampoSprite") as Control
		if sprite != null and sprite.visible:
			var area_sprite: Rect2 = sprite.get_global_rect()
			var pai_feedback: Control = dano_feedback_label.get_parent() as Control
			var ponto_local: Vector2 = pai_feedback.get_global_transform().affine_inverse() * Vector2(area_sprite.get_center().x, area_sprite.position.y + area_sprite.size.y * 0.13)
			posicao_inicial = ponto_local - Vector2(dano_feedback_label.size.x * 0.5, 0.0)
		else:
			var altura: float = alvo_visual.size.y * 0.28 if alvo_visual == jogador else -56.0
			posicao_inicial = alvo_visual.position + Vector2((alvo_visual.size.x - dano_feedback_label.size.x) * 0.5, altura)
	if _animacao_dano != null and _animacao_dano.is_valid():
		_animacao_dano.kill()
	dano_feedback_label.position = posicao_inicial
	_animacao_dano = create_tween()
	_animacao_dano.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_animacao_dano.parallel().tween_property(
		dano_feedback_label,
		"position",
		posicao_inicial + Vector2(0.0, -18.0),
		0.42
	)
	_animacao_dano.parallel().tween_property(dano_feedback_label, "modulate:a", 0.0, 0.42)
	_animacao_dano.tween_callback(dano_feedback_label.hide)


func _capturar_posicao_feedback_dano() -> void:
	_dano_feedback_posicao_base = dano_feedback_label.position
	_dano_feedback_posicao_pronta = true


func _animar_faixa_turno() -> void:
	turno_faixa.show()
	turno_numero_painel.show()
	turno_titulo_label.show()
	turno_numero_label.show()
	turno_faixa.pivot_offset = turno_faixa.size * 0.5
	turno_faixa.scale = Vector2.ONE * 0.97
	turno_faixa.modulate.a = 0.82
	if _animacao_hud != null:
		_animacao_hud.kill()
	_animacao_hud = create_tween()
	_animacao_hud.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_animacao_hud.parallel().tween_property(turno_faixa, "scale", Vector2.ONE, 0.22)
	_animacao_hud.parallel().tween_property(turno_faixa, "modulate:a", 1.0, 0.22)
	_animacao_hud.tween_interval(0.5)
	_animacao_hud.tween_callback(_ocultar_faixa_turno)


func _ocultar_faixa_turno() -> void:
	turno_faixa.hide()
	turno_numero_painel.hide()
	turno_titulo_label.hide()
	turno_numero_label.hide()
	turno_faixa.scale = Vector2.ONE
	turno_faixa.modulate.a = 1.0


func _animar_flash_dano(alvo_visual: Control) -> void:
	if not is_instance_valid(alvo_visual):
		return
	var chave: int = alvo_visual.get_instance_id()
	if _animacoes_flash.has(chave):
		var anterior: Tween = _animacoes_flash[chave]
		if anterior != null and anterior.is_valid():
			anterior.kill()
	var tween: Tween = create_tween()
	alvo_visual.modulate = Color(1.0, 0.40, 0.78, 1.0)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(alvo_visual, "modulate", Color.WHITE, 0.16)
	_animacoes_flash[chave] = tween


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
		"defesa", "defesa_aliado", "cura_aliado":
			intencao_icone.texture = ICONE_INTENCAO_DEFESA
		"preparacao", "marcar", "travar", "recalibrar":
			intencao_icone.texture = ICONE_INTENCAO_PREPARACAO
		_:
			intencao_icone.texture = ICONE_INTENCAO_ATAQUE


func _atualizar_intencao_visual(texto: String) -> void:
	intencao_nome_visual_label.visible = topo_combate.visible and encontro_combate.inimigos.size() <= 1
	var leitura: Dictionary = _leitura_intencao(estado_inimigo, texto)
	intencao_nome_visual_label.text = leitura["tipo"]
	intencao_valor_visual_label.text = leitura["valor"]


func _leitura_intencao(inimigo: InimigoCombate, texto: String) -> Dictionary:
	if inimigo == null or inimigo.vida <= 0:
		return {"tipo": "", "valor": "—"}
	var tipos: Dictionary = {"ataque": "ATACA", "defesa": "DEFENDE", "preparacao": "PREPARA", "defesa_aliado": "PROTEGE", "cura_aliado": "CURA", "marcar": "MARCA", "travar": "TRAVA", "recalibrar": "RECALIBRA"}
	var tipo: String = inimigo.tipo_intencao_atual()
	var separador: int = texto.find(": ")
	var valor: String = texto.substr(separador + 2) if separador >= 0 else "—"
	# O resumo é só apresentação; nome completo e condições permanecem na inspeção.
	valor = valor.split(" · ")[0].split(" por ")[0]
	if tipo == "marcar":
		valor = "ALVO"
	elif tipo == "travar":
		valor = "—"
	elif tipo == "recalibrar":
		valor = "+50%"
	elif tipo == "preparacao":
		valor += "/golpe"
	return {"tipo": tipos.get(tipo, "AÇÃO"), "valor": valor}


func _atualizar_interface() -> void:
	evento_vida_label.text = "%d/%d" % [jogador_combate.estado.vida, jogador_combate.estado.vida_maxima]
	evento_baralho_label.text = str(baralho_run.size())
	turno_label.text = "SEU TURNO\nTURNO %d" % turno
	turno_titulo_label.text = "SEU TURNO"
	turno_numero_label.text = "TURNO %d" % turno
	combo_label.text = str(combo)
	var nomes_reliquias: PackedStringArray = []
	for id_reliquia in jogador_combate.reliquias_run:
		var dados_reliquia: Dictionary = DadosReliquias.obter(id_reliquia)
		if not dados_reliquia.is_empty():
			nomes_reliquias.append(str(dados_reliquia["nome"]))
	reliquia_label.text = "Relíquias: %s" % ", ".join(nomes_reliquias)
	topo_vida.text = "%d / %d" % [vida_jogador, jogador_combate.estado.vida_maxima]
	topo_baralho.text = str(baralho_run.size())
	topo_baralho.tooltip_text = ""
	_atualizar_reliquias_topo()
	energia_label.text = "Energia: %d/%d" % [energia, ENERGIA_POR_TURNO]
	if energia <= 0:
		energia_label.text += "\nSEM ENERGIA"
	energia_visual_label.text = "%d/%d" % [energia, ENERGIA_POR_TURNO]
	feedback_combate.observar(energia, barreira, combo)
	if is_instance_valid(vega_animada):
		vega_animada.atualizar_estado(combo, topo_combate.visible, movimento_reduzido)
	APRESENTACAO_NEON.atualizar(self, energia, ENERGIA_POR_TURNO, barreira, combo, not movimento_reduzido)
	vida_jogador_bar.max_value = jogador_combate.estado.vida_maxima
	vida_jogador_bar.value = vida_jogador
	topo_vida_preenchimento.anchor_right = 0.22 + 0.20 * clampf(float(vida_jogador) / float(maxi(1, jogador_combate.estado.vida_maxima)), 0.0, 1.0)
	topo_vida_preenchimento.visible = false
	topo_vida_moldura.visible = false
	vida_jogador_label.text = "%d/%d" % [
		vida_jogador,
		jogador_combate.estado.vida_maxima
	]
	barreira_label.text = str(barreira)
	var barreira_ativa: bool = topo_combate.visible
	barreira_icone.visible = barreira_ativa
	barreira_label.visible = barreira_ativa
	combo_icone.visible = true
	combo_label.visible = true
	var quantidade_mao: int = mao.get_child_count()
	mao_status_label.text = "%d/%d" % [quantidade_mao, LIMITE_MAO]
	mao_status_label.visible = quantidade_mao >= LIMITE_MAO and topo_combate.visible
	if quantidade_mao >= LIMITE_MAO:
		mao_status_label.text = "MÃO CHEIA · %d/%d" % [quantidade_mao, LIMITE_MAO]
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
	compra_label.text = str(pilha_compra.size())
	descarte_label.text = str(pilha_descarte.size())
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
	var encontro_multiplo: bool = encontro_combate.inimigos.size() > 1 and topo_combate.visible
	for no_individual in [alvo, alvo_visual_label, vida_inimigo_bar, vida_inimigo_label, intencao_icone, intencao_painel, intencao_nome_visual_label, intencao_valor_visual_label, estados_inimigo_painel, estados_inimigo_barreira_icone, estados_inimigo_barreira_label, estados_inimigo_exposto_icone, estados_inimigo_exposto_label, estados_inimigo_enfraquecido_icone, estados_inimigo_enfraquecido_label]:
		if encontro_multiplo:
			no_individual.hide()
	for indice in alvos_multiplos.size():
		var botao_multiplo: Button = alvos_multiplos[indice]
		botao_multiplo.visible = encontro_multiplo and indice < encontro_combate.inimigos.size()
		if not botao_multiplo.visible:
			continue
		var individual: InimigoCombate = encontro_combate.inimigos[indice]
		var texto_intencao: String = individual.texto_intencao().replace(": ", "\n") if individual.vida > 0 else "DERROTADO"
		if individual.identificador == "drone_reparador" and individual.aliado_suporte() != null:
			texto_intencao = texto_intencao.replace(individual.aliado_suporte().nome, "\n%s" % individual.aliado_suporte().nome)
		var vida_maxima_visual: int = maxi(1, individual.vida_maxima)
		var vida_visual: int = clampi(individual.vida, 0, vida_maxima_visual)
		var barra_vida: ProgressBar = botao_multiplo.get_node("VidaBar") as ProgressBar
		barra_vida.max_value = vida_maxima_visual
		barra_vida.value = vida_visual
		var leitura_vida: Label = botao_multiplo.get_node("VidaLabel") as Label
		leitura_vida.text = "%d/%d" % [vida_visual, vida_maxima_visual]
		var leitura_barreira: Label = botao_multiplo.get_node("BarreiraLabel") as Label
		var estados_compactos: PackedStringArray = []
		if individual.barreira > 0:
			estados_compactos.append("BARREIRA %d" % individual.barreira)
		if individual.frenesi:
			estados_compactos.append("FRENESI")
		if individual.recalibrando:
			estados_compactos.append("+50% DANO")
		if individual.exposto > 0:
			estados_compactos.append("EXP. %d" % individual.exposto)
		if individual.enfraquecido > 0:
			estados_compactos.append("ENF. %d" % individual.enfraquecido)
		leitura_barreira.visible = individual.vida > 0 and not estados_compactos.is_empty()
		leitura_barreira.text = " · ".join(estados_compactos)
		var nome_alvo: Label = botao_multiplo.get_node("Nome") as Label
		nome_alvo.text = individual.nome.to_upper()
		var intencao_alvo: Label = botao_multiplo.get_node("Intencao") as Label
		var texto_alvo: String = texto_intencao
		if individual.frenesi:
			texto_alvo += "\nFRENESI"
		if individual.recalibrando:
			texto_alvo += "\nRECALIBRANDO +50%"
		if individual.exposto > 0:
			texto_alvo += "\nEXPOSTO %d" % individual.exposto
		if individual.enfraquecido > 0:
			texto_alvo += "\nENFRAQ. %d" % individual.enfraquecido
		var leitura: Dictionary = _leitura_intencao(individual, individual.texto_intencao())
		intencao_alvo.text = leitura["tipo"]
		(botao_multiplo.get_node("IntencaoValor") as Label).text = leitura["valor"]
		var icone_intencao_alvo: TextureRect = botao_multiplo.get_node("IntencaoIcone") as TextureRect
		var tipo_intencao: String = individual.tipo_intencao_atual()
		if tipo_intencao in ["defesa", "defesa_aliado", "cura_aliado"]:
			icone_intencao_alvo.texture = ICONE_INTENCAO_DEFESA
		elif tipo_intencao in ["preparacao", "marcar", "travar", "recalibrar"]:
			icone_intencao_alvo.texture = ICONE_INTENCAO_PREPARACAO
		else:
			icone_intencao_alvo.texture = ICONE_INTENCAO_ATAQUE
		icone_intencao_alvo.visible = individual.vida > 0
		(botao_multiplo.get_node("Conteudo") as Label).text = "%s\n%s" % [individual.nome.to_upper(), texto_alvo]
		botao_multiplo.disabled = individual.vida <= 0
		if individual.vida <= 0:
			botao_multiplo.hide()
		_atualizar_destaque_hud(botao_multiplo)
	if marcado_visual != null:
		marcado_visual.visible = topo_combate.visible and _jogador_marcado()
	if estado_especial_visual != null:
		estado_especial_visual.hide()
		if not encontro_multiplo and estado_inimigo != null and estado_inimigo.vida > 0 and topo_combate.visible:
			if estado_inimigo.recalibrando:
				estado_especial_visual.text = "RECEBE +50% DANO"
				estado_especial_visual.show()
			elif estado_inimigo.frenesi:
				estado_especial_visual.text = "FRENESI"
				estado_especial_visual.show()
			elif estado_inimigo.identificador == "estivador_aumentado" and estado_inimigo.indice_intencao == 1:
				estado_especial_visual.text = "PRÓX. ATAQUE +2"
				estado_especial_visual.show()
	if hud_inspecao.visible and is_instance_valid(hud_inspecao.controle_atual):
		_mostrar_inspecao_hud(hud_inspecao.controle_atual)
	var terminou: bool = (
		_combate_terminou()
		or aguardando_recompensa
		or aguardando_recompensa_elite
		or aguardando_evento
	)
	alvo.disabled = terminou
	for botao_multiplo in alvos_multiplos:
		if encontro_multiplo:
			botao_multiplo.disabled = terminou or encontro_combate.inimigos[int(botao_multiplo.get_meta("indice_inimigo"))].vida <= 0
		else:
			botao_multiplo.disabled = true
		_atualizar_destaque_hud(botao_multiplo)
	jogador.disabled = terminou
	botao_encerrar_turno.disabled = terminou
	_atualizar_destaque_hud(alvo)
	_atualizar_destaque_hud(jogador)
	_atualizar_destaque_hud(botao_encerrar_turno)

	for no in mao.get_children():
		var carta: Button = no as Button
		carta.disabled = terminou
	APRESENTACAO_NEON.atualizar_barras(self, not movimento_reduzido)
	energia_icone.hide()
	barreira_icone.visible = stats_jogador_painel.visible
	combo_icone.hide()
	_layout_hud_combate()
	_redimensionar_cartas_da_mao()
	if hud_inspecao.visible and is_instance_valid(hud_inspecao.controle_atual):
		_mostrar_inspecao_hud(hud_inspecao.controle_atual)


func _atualizar_reliquias_topo() -> void:
	if reliquias_exibidas == jogador_combate.reliquias_run:
		topo_reliquias.visible = topo_combate.visible and topo_reliquias.get_child_count() > 0
		return
	if is_instance_valid(hud_inspecao.controle_atual) and _eh_icone_reliquia_topo(hud_inspecao.controle_atual):
		hud_inspecao.esconder()
	reliquias_exibidas.assign(jogador_combate.reliquias_run)
	for filho in topo_reliquias.get_children():
		filho.free()

	for indice in jogador_combate.reliquias_run.size():
		var id_reliquia: String = jogador_combate.reliquias_run[indice]
		var dados: Dictionary = DadosReliquias.obter(id_reliquia)
		if dados.is_empty():
			continue
		var botao: Button = Button.new()
		botao.name = "ReliquiaIcone_%d" % indice
		botao.add_to_group("icone_reliquia_topo")
		botao.set_meta("id_reliquia", id_reliquia)
		botao.set_meta("nome_reliquia", str(dados["nome"]))
		botao.icon = APRESENTACAO_NEON.icone_reliquia(id_reliquia)
		botao.text = APRESENTACAO_NEON.nome_curto_reliquia(id_reliquia)
		botao.expand_icon = true
		botao.custom_minimum_size = Vector2(36.0, 36.0)
		botao.flat = true
		botao.focus_mode = Control.FOCUS_ALL
		botao.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		botao.tooltip_text = ""
		var normal: StyleBoxFlat = StyleBoxFlat.new()
		normal.bg_color = Color(0.0, 0.0, 0.0, 0.0)
		var foco: StyleBoxFlat = StyleBoxFlat.new()
		foco.bg_color = Color("#173e3d")
		foco.border_width_left = 1
		foco.border_width_top = 1
		foco.border_width_right = 1
		foco.border_width_bottom = 1
		foco.border_color = Color("#40e4df")
		foco.corner_radius_top_left = 3
		foco.corner_radius_top_right = 3
		foco.corner_radius_bottom_left = 3
		foco.corner_radius_bottom_right = 3
		botao.add_theme_stylebox_override("normal", normal)
		botao.add_theme_stylebox_override("hover", foco)
		botao.add_theme_stylebox_override("focus", foco)
		botao.add_theme_stylebox_override("pressed", foco)
		botao.mouse_entered.connect(_ao_entrar_inspecao_hud.bind(botao))
		botao.mouse_exited.connect(_ao_sair_inspecao_hud.bind(botao))
		botao.focus_entered.connect(_ao_entrar_inspecao_hud.bind(botao))
		botao.focus_exited.connect(_ao_sair_inspecao_hud.bind(botao))
		topo_reliquias.add_child(botao)
		APRESENTACAO_NEON.estilizar_reliquia(botao)
	topo_reliquias.visible = topo_combate.visible and topo_reliquias.get_child_count() > 0
