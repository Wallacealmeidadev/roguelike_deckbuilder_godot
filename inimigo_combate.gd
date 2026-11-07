class_name InimigoCombate
extends Combatente

var identificador: String
var nome: String
var ciclo: Array[Dictionary] = []
var indice_intencao: int = 0
var bonus_preparado: int = 0
var frenesi: bool = false
var marcado: bool = false
var recalibrando: bool = false
var aliados: Array[WeakRef] = []


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
	frenesi = false
	marcado = false
	recalibrando = false


func receber_golpe(dano_base: int) -> Dictionary:
	var resultado: Dictionary = super(dano_base)
	if identificador == "estivador_aumentado" and vida > 0 and vida <= 17:
		frenesi = true
		bonus_preparado = 0
	if vida <= 0 and OS.is_debug_build():
		print("[BESTIARIO] %s derrotado" % nome)
	return resultado


func calcular_dano_recebido(dano_base: int) -> int:
	var dano: int = maxi(0, dano_base)
	if recalibrando:
		dano = ceili(float(dano) * 1.5)
	return super(dano)


func aliado_suporte() -> InimigoCombate:
	var escolhido: InimigoCombate = null
	for referencia in aliados:
		var candidato: InimigoCombate = referencia.get_ref() as InimigoCombate
		if candidato == null or candidato == self or candidato.vida <= 0:
			continue
		if escolhido == null or candidato.vida * escolhido.vida_maxima < escolhido.vida * candidato.vida_maxima:
			escolhido = candidato
	return escolhido


func texto_intencao() -> String:
	var intencao: Dictionary = _intencao_atual()
	if not _intencao_valida(intencao):
		return "Intenção inválida"

	var nome_intencao: String = str(intencao["nome"])
	var tipo: String = str(intencao["tipo"])
	if tipo == "defesa_aliado" or tipo == "cura_aliado":
		var suporte: InimigoCombate = aliado_suporte()
		if suporte == null:
			return "Pulso Elétrico: 5"
		return "%s %s: +%d" % [nome_intencao, suporte.nome, int(intencao["valor"])]
	if tipo == "marcar":
		return "%s: MARCAR" % nome_intencao
	if tipo == "recalibrar":
		return "RECALIBRANDO: recebe +50% dano"
	if tipo == "travar":
		return "TRAVANDO ALVO: sem dano"

	if tipo == "ataque":
		var danos: Array[int] = _danos_anunciados(intencao)
		if intencao.has("prepara"):
			return "%s: %d · prepara +%d" % [nome_intencao, danos[0], int(intencao["prepara"])]
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
	if identificador == "drone_reparador" and aliado_suporte() == null:
		return "ataque"
	var intencao: Dictionary = _intencao_atual()
	return str(intencao.get("tipo", ""))


func executar_intencao() -> Dictionary:
	if vida <= 0:
		return {}
	var intencao: Dictionary = _intencao_atual()
	if not _intencao_valida(intencao):
		return {}

	# A Barreira anterior expira no início da ação válida do inimigo.
	barreira = 0
	recalibrando = false

	var tipo: String = str(intencao["tipo"])
	var resultado: Dictionary = {
		"tipo": tipo,
		"nome": str(intencao["nome"])
	}
	if identificador == "drone_reparador" and aliado_suporte() == null:
		resultado["tipo"] = "ataque"
		resultado["nome"] = "Pulso Elétrico"
		resultado["danos"] = [calcular_dano_de_ataque(5)]
		indice_intencao = (indice_intencao + 1) % ciclo.size()
		return resultado

	if tipo == "ataque":
		var danos: Array[int] = []
		for dano_base in intencao["danos"]:
			var bonus_marca: int = 6 if identificador == "sentinela_inspecao" and marcado else 0
			danos.append(calcular_dano_de_ataque(int(dano_base) + bonus_preparado + bonus_marca))
		bonus_preparado = 0
		if identificador == "sentinela_inspecao":
			marcado = false
		if intencao.has("prepara"):
			bonus_preparado = int(intencao["prepara"])
		resultado["danos"] = danos
	elif tipo == "defesa":
		var valor: int = int(intencao["valor"])
		aplicar_barreira(valor)
		resultado["valor"] = valor
	elif tipo == "preparacao":
		bonus_preparado = int(intencao["bonus_por_golpe"])
		resultado["valor"] = bonus_preparado
	elif tipo == "defesa_aliado" or tipo == "cura_aliado":
		var suporte: InimigoCombate = aliado_suporte()
		if suporte == null:
			resultado["tipo"] = "ataque"
			resultado["nome"] = "Pulso Elétrico"
			resultado["danos"] = [calcular_dano_de_ataque(5)]
		else:
			resultado["alvo"] = suporte
			resultado["valor"] = int(intencao["valor"])
			if tipo == "defesa_aliado":
				suporte.aplicar_barreira(int(intencao["valor"]))
			else:
				var vida_antes: int = suporte.vida
				suporte.vida = mini(suporte.vida_maxima, suporte.vida + int(intencao["valor"]))
				resultado["cura_real"] = suporte.vida - vida_antes
	elif tipo == "marcar":
		marcado = true
	elif tipo == "recalibrar":
		recalibrando = true

	indice_intencao = (indice_intencao + 1) % ciclo.size()
	return resultado


func _intencao_atual() -> Dictionary:
	if identificador == "estivador_aumentado" and frenesi:
		return {"nome": "FRENESI — Golpes Desesperados", "tipo": "ataque", "danos": [5, 5]}
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
	if tipo == "marcar" or tipo == "recalibrar" or tipo == "travar":
		return true
	if tipo == "defesa_aliado" or tipo == "cura_aliado":
		return int(intencao.get("valor", 0)) > 0

	return false


func _danos_anunciados(intencao: Dictionary) -> Array[int]:
	var danos: Array[int] = []
	var indice_golpe: int = 0

	for dano_base in intencao["danos"]:
		var dano: int = int(dano_base) + bonus_preparado
		if identificador == "sentinela_inspecao" and marcado:
			dano += 6
		if enfraquecido > indice_golpe:
			dano = maxi(0, dano - PENALIDADE_ENFRAQUECIDO)
		danos.append(dano)
		indice_golpe += 1

	return danos
