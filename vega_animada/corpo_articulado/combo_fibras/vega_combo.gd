class_name VegaComboFibrasV1
extends VegaPresencaCombateV1
## Combo é estado visual independente. O AnimationPlayer mantém os ossos.

const FIBRA: Script = preload("res://vega_animada/corpo_articulado/combo_fibras/malha_fibra.gd")
const REGRA_TENSAO: Script = preload("res://vega_animada/braco_v2/braco_prova.gd")
signal tensao_visual_alterada(valor: float)

@export_range(0.0, .2, .01) var amplitude_biceps: float = .18
@export_range(0.0, .2, .01) var amplitude_antebraco: float = .14
var combo_visual: int = 0
var tensao_visual: float = 0.0
var alvo_tensao: float = 0.0
var fibras: Array[MalhaFibraComboV1] = []
var transicao_fibras: Tween
var fibras_prontas: bool = false


func _ready() -> void:
	super._ready()
	for braco: BracoRegistradoV1 in [braco_novo, novo_distante]:
		for indice: int in range(2):
			var fibra: MalhaFibraComboV1 = FIBRA.new() as MalhaFibraComboV1
			fibra.preparar(braco.segmentos[indice], braco.registros[indice],
				braco.SUPERIOR if indice == 0 else braco.INFERIOR, indice == 0,
				braco == novo_distante, amplitude_biceps if indice == 0 else amplitude_antebraco)
			fibras.append(fibra)
	fibras_prontas = true
	definir_combo_visual(0, true)


func definir_combo_visual(valor: int, imediato: bool = false) -> void:
	if not fibras_prontas:
		return
	combo_visual = maxi(0, valor) if is_visible_in_tree() else 0
	var alvo: float = REGRA_TENSAO.tensao_por_combo(combo_visual)
	if not imediato and is_equal_approx(alvo, alvo_tensao):
		return
	_parar_fibras()
	alvo_tensao = alvo
	if imediato or corpo_reduzido or is_equal_approx(tensao_visual, alvo):
		_aplicar_fibras(alvo)
		return
	transicao_fibras = create_tween()
	transicao_fibras.tween_method(_interpolar_fibras.bind(tensao_visual, alvo), 0.0, 1.0, REGRA_TENSAO.DURACAO_COMBO)
	transicao_fibras.finished.connect(_terminar_fibras)


func _interpolar_fibras(tempo: float, inicio: float, alvo: float) -> void:
	_aplicar_fibras(lerpf(inicio, alvo, REGRA_TENSAO.curva_transformacao(tempo)))


func _aplicar_fibras(valor: float) -> void:
	tensao_visual = clampf(valor, 0, 1)
	for fibra: MalhaFibraComboV1 in fibras:
		fibra.aplicar(tensao_visual)
	tensao_visual_alterada.emit(tensao_visual)


func _terminar_fibras() -> void:
	_aplicar_fibras(alvo_tensao)
	transicao_fibras = null


func _parar_fibras() -> void:
	if transicao_fibras != null and transicao_fibras.is_valid():
		transicao_fibras.kill()
	transicao_fibras = null


func reduzir_corpo(ativo: bool) -> void:
	super.reduzir_corpo(ativo)
	if ativo and fibras_prontas:
		definir_combo_visual(combo_visual, true)


func reiniciar_sequencia() -> void:
	super.reiniciar_sequencia()
	if fibras_prontas:
		definir_combo_visual(0, true)


func _sincronizar_visibilidade() -> void:
	super._sincronizar_visibilidade()
	if fibras_prontas and not is_visible_in_tree():
		definir_combo_visual(0, true)


func _exit_tree() -> void:
	_parar_fibras()
