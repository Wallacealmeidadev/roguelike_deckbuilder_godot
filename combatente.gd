class_name Combatente
extends RefCounted

const BONUS_EXPOSTO: int = 2
const PENALIDADE_ENFRAQUECIDO: int = 2

var vida_maxima: int = 0
var vida: int = 0
var barreira: int = 0
var exposto: int = 0
var enfraquecido: int = 0


func _init(vida_inicial: int) -> void:
	reiniciar(vida_inicial)


func reiniciar(vida_inicial: int) -> void:
	vida_maxima = maxi(0, vida_inicial)
	vida = vida_maxima
	barreira = 0
	exposto = 0
	enfraquecido = 0


func aplicar_barreira(valor: int) -> void:
	barreira += maxi(0, valor)


func aplicar_exposto(cargas: int) -> void:
	exposto += maxi(0, cargas)


func aplicar_enfraquecido(cargas: int) -> void:
	enfraquecido += maxi(0, cargas)


func calcular_dano_de_ataque(dano_base: int) -> int:
	var dano: int = maxi(0, dano_base)

	if enfraquecido > 0:
		dano = maxi(0, dano - PENALIDADE_ENFRAQUECIDO)
		enfraquecido -= 1

	return dano


func calcular_dano_recebido(dano_base: int) -> int:
	var dano: int = maxi(0, dano_base)

	if exposto > 0:
		dano += BONUS_EXPOSTO
		exposto -= 1

	return dano


func receber_golpe(dano_base: int) -> Dictionary:
	var dano: int = calcular_dano_recebido(dano_base)
	var absorvido: int = mini(barreira, dano)
	barreira -= absorvido

	var dano_na_vida: int = dano - absorvido
	vida = maxi(0, vida - dano_na_vida)

	return {
		"dano": dano,
		"absorvido": absorvido,
		"dano_na_vida": dano_na_vida,
		"vida": vida
	}
