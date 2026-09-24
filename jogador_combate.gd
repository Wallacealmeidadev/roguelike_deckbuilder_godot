class_name JogadorCombate
extends RefCounted

var estado: Combatente
var energia: int
var energia_maxima: int
var combo: int = 0
var combo_maximo: int
var juntas_retorno_ativada_no_turno: bool = false


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


func iniciar_turno() -> void:
	estado.barreira = 0
	energia = energia_maxima
	juntas_retorno_ativada_no_turno = false


func encerrar_turno() -> void:
	energia = 0
	combo = 0


func ganhar_combo(barreira_reliquia: int, limiar_reliquia: int) -> bool:
	var combo_anterior: int = combo
	combo = mini(combo_maximo, combo + 1)

	if (
		combo_anterior < limiar_reliquia
		and combo >= limiar_reliquia
		and not juntas_retorno_ativada_no_turno
	):
		estado.aplicar_barreira(barreira_reliquia)
		juntas_retorno_ativada_no_turno = true
		return true

	return false
