class_name JogadorCombate
extends RefCounted

var estado: Combatente
var energia: int
var energia_maxima: int
var combo: int = 0
var combo_maximo: int
var juntas_retorno_ativada_no_turno: bool = false
var reliquias_run: Array[String] = ["juntas_retorno"]
var mecanismo_recuo_ativado_no_turno: bool = false


func _init(
	vida_inicial: int,
	energia_por_turno: int,
	limite_combo: int
) -> void:
	estado = Combatente.new(vida_inicial)
	energia_maxima = maxi(0, energia_por_turno)
	energia = energia_maxima
	combo_maximo = maxi(0, limite_combo)


func iniciar_combate(vida_preservada: int) -> void:
	estado.reiniciar(estado.vida_maxima)
	estado.vida = clampi(vida_preservada, 0, estado.vida_maxima)
	energia = energia_maxima
	combo = 0
	juntas_retorno_ativada_no_turno = false
	mecanismo_recuo_ativado_no_turno = false


func iniciar_turno() -> void:
	estado.barreira = 0
	energia = energia_maxima
	juntas_retorno_ativada_no_turno = false
	mecanismo_recuo_ativado_no_turno = false

	if possui_reliquia("reservatorio_auxiliar"):
		estado.aplicar_barreira(2)


func encerrar_turno() -> void:
	energia = 0
	combo = 0


func possui_reliquia(id_reliquia: String) -> bool:
	return reliquias_run.has(id_reliquia)


func adicionar_reliquia(id_reliquia: String) -> bool:
	if not DadosReliquias.RELIQUIAS.has(id_reliquia) or possui_reliquia(id_reliquia):
		return false
	reliquias_run.append(id_reliquia)
	return true


func registrar_finalizacao(combo_consumido: int) -> bool:
	if combo_consumido <= 0:
		return false
	if not possui_reliquia("mecanismo_recuo"):
		return false
	if mecanismo_recuo_ativado_no_turno:
		return false

	estado.aplicar_barreira(2)
	mecanismo_recuo_ativado_no_turno = true
	return true


func ganhar_combo(barreira_reliquia: int, limiar_reliquia: int) -> bool:
	var combo_anterior: int = combo
	combo = mini(combo_maximo, combo + 1)

	if (
		possui_reliquia("juntas_retorno")
		and
		combo_anterior < limiar_reliquia
		and combo >= limiar_reliquia
		and not juntas_retorno_ativada_no_turno
	):
		estado.aplicar_barreira(barreira_reliquia)
		juntas_retorno_ativada_no_turno = true
		return true

	return false
