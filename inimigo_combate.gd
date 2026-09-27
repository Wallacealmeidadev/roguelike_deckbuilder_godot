class_name InimigoCombate
extends Combatente

var identificador: String
var nome: String
var ciclo: Array[Dictionary] = []
var indice_intencao: int = 0
var bonus_preparado: int = 0


func _init(id_inimigo: String, dados: Dictionary) -> void:
	var vida_inicial: int = int(dados.get("vida", 0))
	super(vida_inicial)

	identificador = id_inimigo
	nome = str(dados.get("nome", ""))
	for intencao_variant in dados.get("intencoes", []):
		if intencao_variant is Dictionary:
			var intencao: Dictionary = intencao_variant
			ciclo.append(intencao.duplicate(true))


func reiniciar(vida_inicial: int) -> void:
	super(vida_inicial)
	indice_intencao = 0
	bonus_preparado = 0


func texto_intencao() -> String:
	var intencao: Dictionary = _intencao_atual()
	if not _intencao_valida(intencao):
		return "Intenção inválida"

	var nome_intencao: String = str(intencao["nome"])
	var tipo: String = str(intencao["tipo"])

	if tipo == "ataque":
		var danos: Array[int] = _danos_anunciados(intencao)
		if danos.size() == 1:
			return "%s: %d" % [nome_intencao, danos[0]]

		var todos_iguais: bool = true
		for dano in danos:
			if dano != danos[0]:
				todos_iguais = false
				break

		if todos_iguais:
			return "%s: %d × %d" % [nome_intencao, danos[0], danos.size()]

		var partes: PackedStringArray = []
		for dano in danos:
			partes.append(str(dano))
		return "%s: %s" % [nome_intencao, " + ".join(partes)]

	if tipo == "defesa":
		return "%s: +%d" % [nome_intencao, int(intencao["valor"])]

	return "%s: +%d por golpe no próximo ataque" % [
		nome_intencao,
		int(intencao["bonus_por_golpe"])
	]


func tipo_intencao_atual() -> String:
	var intencao: Dictionary = _intencao_atual()
	return str(intencao.get("tipo", ""))


func executar_intencao() -> Dictionary:
	var intencao: Dictionary = _intencao_atual()
	if not _intencao_valida(intencao):
		return {}

	# A Barreira anterior expira no início da ação válida do inimigo.
	barreira = 0

	var tipo: String = str(intencao["tipo"])
	var resultado: Dictionary = {
		"tipo": tipo,
		"nome": str(intencao["nome"])
	}

	if tipo == "ataque":
		var danos: Array[int] = []
		for dano_base in intencao["danos"]:
			danos.append(calcular_dano_de_ataque(int(dano_base) + bonus_preparado))
		bonus_preparado = 0
		resultado["danos"] = danos
	elif tipo == "defesa":
		var valor: int = int(intencao["valor"])
		aplicar_barreira(valor)
		resultado["valor"] = valor
	else:
		bonus_preparado = int(intencao["bonus_por_golpe"])
		resultado["valor"] = bonus_preparado

	indice_intencao = (indice_intencao + 1) % ciclo.size()
	return resultado


func _intencao_atual() -> Dictionary:
	if ciclo.is_empty() or indice_intencao < 0 or indice_intencao >= ciclo.size():
		return {}
	return ciclo[indice_intencao]


func _intencao_valida(intencao: Dictionary) -> bool:
	if str(intencao.get("nome", "")).is_empty():
		return false

	var tipo: String = str(intencao.get("tipo", ""))
	if tipo == "ataque":
		var danos: Array = intencao.get("danos", [])
		if danos.is_empty():
			return false
		for dano in danos:
			if int(dano) <= 0:
				return false
		return true

	if tipo == "defesa":
		return int(intencao.get("valor", 0)) > 0

	if tipo == "preparacao":
		return int(intencao.get("bonus_por_golpe", 0)) > 0

	return false


func _danos_anunciados(intencao: Dictionary) -> Array[int]:
	var danos: Array[int] = []
	var indice_golpe: int = 0

	for dano_base in intencao["danos"]:
		var dano: int = int(dano_base) + bonus_preparado
		if enfraquecido > indice_golpe:
			dano = maxi(0, dano - PENALIDADE_ENFRAQUECIDO)
		danos.append(dano)
		indice_golpe += 1

	return danos
