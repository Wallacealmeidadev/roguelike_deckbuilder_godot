# Orquestração de Combate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extrair o estado temporário do jogador e o ciclo do encontro de `main.gd`, deixando o script da cena como orquestrador sem alterar o comportamento jogável atual.

**Architecture:** `JogadorCombate` passa a possuir o `Combatente` do jogador, Energia, Combo e o estado por turno de Juntas de Retorno. `EncontroCombate` passa a possuir o inimigo ativo, o `BaralhoCombate`, o turno e a execução da fase inimiga. `main.gd` mantém entrada, cena, interface, cartas visuais, recompensas e fluxo da run, delegando estado e regras temporárias aos dois componentes.

**Tech Stack:** Godot 4.7.2, GDScript tipado, cenas de teste headless, `RefCounted` para componentes sem dependência da árvore de nós.

**Spec:** `docs/superpowers/specs/2026-09-23-orquestracao-combate-design.md`

## Global Constraints

- Preservar Vida 40, Energia 4, compra 6, limite de mão 10 e Combo máximo 5.
- Preservar Juntas de Retorno: ao cruzar 2 Combo, ganhar 3 de Barreira uma vez por turno.
- Preservar o Drone atual, seu ciclo de intenções e todos os valores existentes.
- Não adicionar inimigos, elite, chefe, mapa, autoloads, sinais globais ou dependências externas.
- Nenhum componente de domínio pode depender de `Button`, `Label`, `main.tscn` ou outra cena.
- Manter propriedades legadas de `main.gd` somente como delegações enquanto os testes existentes ainda as consomem.
- Usar Godot 4.7.2 e GDScript tipado.
- O workspace não possui repositório Git; não inicializar um repositório e substituir passos de commit por checkpoints explícitos.

## Review Focus

- Vida preservada fora do intervalo `0..vida_maxima` deve ser limitada, sem criar Vida negativa ou acima do máximo; coberto na Task 1.
- Consumir Combo e voltar ao limiar no mesmo turno não pode reativar Juntas de Retorno; coberto na Task 1.
- Preparar um encontro não pode modificar o `baralho_run` recebido; coberto na Task 2.
- Uma Rajada letal deve parar assim que a Vida do jogador chegar a zero; coberto na Task 2.
- Executar a fase inimiga depois de vitória/derrota ou sem inimigo deve retornar vazio e não causar dano; coberto na Task 2.

---

### Task 1: Extrair `JogadorCombate`

**Files:**
- Create: `jogador_combate.gd`
- Create: `tests/test_jogador_combate.gd`
- Create: `tests/test_jogador_combate.tscn`

**Interfaces:**
- Consumes: `Combatente.new(vida_inicial)`, `Combatente.reiniciar()`, `Combatente.aplicar_barreira()`.
- Produces: `JogadorCombate.new(vida_inicial, energia_por_turno, combo_maximo)`, `iniciar_combate()`, `iniciar_turno()`, `encerrar_turno()` e `ganhar_combo()`.

- [ ] **Step 1: Criar o teste que descreve o ciclo do jogador**

Criar `tests/test_jogador_combate.gd`:

```gdscript
extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var jogador: JogadorCombate = JogadorCombate.new(40, 4, 5)
	_verificar(jogador.estado.vida == 40, "o jogador deve começar com 40 de Vida")
	_verificar(jogador.energia == 4, "o jogador deve começar com 4 de Energia")
	_verificar(jogador.combo == 0, "o jogador deve começar sem Combo")

	jogador.estado.vida = 27
	jogador.estado.barreira = 8
	jogador.combo = 4
	jogador.energia = 1
	jogador.juntas_retorno_ativada_no_turno = true
	jogador.iniciar_combate(27)
	_verificar(jogador.estado.vida == 27, "a Vida deve persistir entre encontros")
	_verificar(jogador.estado.vida_maxima == 40, "a Vida máxima deve permanecer 40")
	_verificar(jogador.estado.barreira == 0, "a Barreira deve reiniciar no novo combate")
	_verificar(jogador.energia == 4, "a Energia deve reiniciar no novo combate")
	_verificar(jogador.combo == 0, "o Combo deve reiniciar no novo combate")
	_verificar(not jogador.juntas_retorno_ativada_no_turno, "Juntas deve reiniciar no novo combate")

	jogador.iniciar_combate(999)
	_verificar(jogador.estado.vida == 40, "a Vida preservada deve respeitar o máximo")
	jogador.iniciar_combate(-5)
	_verificar(jogador.estado.vida == 0, "a Vida preservada não pode ficar negativa")
	jogador.iniciar_combate(40)

	_verificar(not jogador.ganhar_combo(3, 2), "Juntas não deve ativar em 1 Combo")
	_verificar(jogador.combo == 1, "o primeiro ganho deve produzir 1 Combo")
	_verificar(jogador.ganhar_combo(3, 2), "Juntas deve ativar ao cruzar 2 Combo")
	_verificar(jogador.combo == 2, "o segundo ganho deve produzir 2 Combo")
	_verificar(jogador.estado.barreira == 3, "Juntas deve conceder 3 de Barreira")
	_verificar(not jogador.ganhar_combo(3, 2), "Juntas não deve repetir no mesmo turno")

	jogador.combo = 0
	jogador.ganhar_combo(3, 2)
	jogador.ganhar_combo(3, 2)
	_verificar(jogador.estado.barreira == 3, "voltar ao limiar não deve reativar Juntas no mesmo turno")

	jogador.combo = 5
	jogador.ganhar_combo(3, 2)
	_verificar(jogador.combo == 5, "Combo não pode ultrapassar o máximo")

	jogador.encerrar_turno()
	_verificar(jogador.energia == 0, "encerrar o turno deve zerar Energia")
	_verificar(jogador.combo == 0, "encerrar o turno deve zerar Combo")

	jogador.estado.barreira = 7
	jogador.iniciar_turno()
	_verificar(jogador.estado.barreira == 0, "iniciar turno deve remover a Barreira anterior")
	_verificar(jogador.energia == 4, "iniciar turno deve restaurar Energia")
	_verificar(not jogador.juntas_retorno_ativada_no_turno, "Juntas deve poder ativar no novo turno")
	jogador.ganhar_combo(3, 2)
	_verificar(jogador.ganhar_combo(3, 2), "Juntas deve ativar novamente no turno seguinte")

	if falhas == 0:
		print("OK: JogadorCombate")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
```

Criar `tests/test_jogador_combate.tscn`:

```text
[gd_scene load_steps=2 format=3]

[ext_resource path="res://tests/test_jogador_combate.gd" type="Script" id="1_teste"]

[node name="TesteJogadorCombate" type="Node"]
script = ExtResource("1_teste")
```

- [ ] **Step 2: Executar o teste e confirmar RED**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path (Get-Location) --scene res://tests/test_jogador_combate.tscn
```

Expected: falha de parse por `JogadorCombate` ainda não existir.

- [ ] **Step 3: Implementar o estado do jogador**

Criar `jogador_combate.gd`:

```gdscript
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
```

- [ ] **Step 4: Executar o teste e confirmar GREEN**

Run: o mesmo comando do Step 2.  
Expected: `OK: JogadorCombate` e código 0.

- [ ] **Step 5: Registrar checkpoint da Task 1**

Confirmar que somente `jogador_combate.gd` e os dois arquivos de teste foram criados. Não integrar em `main.gd` ainda.

---

### Task 2: Extrair `EncontroCombate`

**Files:**
- Create: `encontro_combate.gd`
- Create: `tests/test_encontro_combate.gd`
- Create: `tests/test_encontro_combate.tscn`

**Interfaces:**
- Consumes: `JogadorCombate`, `InimigoCombate`, `BaralhoCombate`.
- Produces: `EncontroCombate.iniciar()`, `combate_terminou()`, `executar_fase_inimiga()` e `avancar_turno()`.

- [ ] **Step 1: Criar o teste do encontro sem cena**

Criar `tests/test_encontro_combate.gd`:

```gdscript
extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var jogador: JogadorCombate = JogadorCombate.new(40, 4, 5)
	var sem_inimigo: EncontroCombate = EncontroCombate.new()
	_verificar(sem_inimigo.combate_terminou(jogador), "um encontro sem inimigo não pode continuar")
	_verificar(sem_inimigo.executar_fase_inimiga(jogador).is_empty(), "sem inimigo não deve haver ação")

	var inimigo: InimigoCombate = InimigoCombate.new(30)
	inimigo.barreira = 9
	inimigo.exposto = 2
	inimigo.intencao = "sobrecarga"
	var baralho_run: Array[String] = ["golpe", "protecao"]
	var encontro: EncontroCombate = EncontroCombate.new()
	encontro.iniciar(inimigo, baralho_run)

	_verificar(encontro.inimigo == inimigo, "o encontro deve guardar o inimigo recebido")
	_verificar(encontro.turno == 1, "o encontro deve começar no turno 1")
	_verificar(inimigo.vida == 30, "o inimigo deve iniciar com Vida cheia")
	_verificar(inimigo.barreira == 0, "o inimigo deve reiniciar sua Barreira")
	_verificar(inimigo.exposto == 0, "o inimigo deve reiniciar seus estados")
	_verificar(inimigo.intencao == "rajada", "o inimigo deve reiniciar sua intenção")
	_verificar(encontro.baralho.compra.size() == 2, "o encontro deve copiar o baralho da run")

	baralho_run.append("quebra_chassi")
	_verificar(encontro.baralho.compra.size() == 2, "o encontro não deve compartilhar a lista da run")

	var acao: Dictionary = encontro.executar_fase_inimiga(jogador)
	_verificar(acao["tipo"] == "rajada", "a fase inimiga deve executar a intenção anunciada")
	_verificar(acao["resultados_golpes"].size() == 2, "a Rajada deve resolver dois golpes")
	_verificar(jogador.estado.vida == 34, "a Rajada deve causar 6 de dano total")

	encontro.avancar_turno()
	_verificar(encontro.turno == 2, "avançar deve incrementar o turno")

	inimigo.vida = 0
	_verificar(encontro.combate_terminou(jogador), "Vida zero do inimigo deve encerrar o encontro")
	inimigo.vida = 30
	jogador.estado.vida = 0
	_verificar(encontro.combate_terminou(jogador), "Vida zero do jogador deve encerrar o encontro")
	_verificar(encontro.executar_fase_inimiga(jogador).is_empty(), "a fase inimiga não deve agir após o fim")

	jogador.estado.vida = 2
	inimigo.reiniciar(30)
	acao = encontro.executar_fase_inimiga(jogador)
	_verificar(jogador.estado.vida == 0, "um golpe letal deve zerar a Vida")
	_verificar(acao["resultados_golpes"].size() == 1, "a Rajada deve parar após o golpe letal")

	if falhas == 0:
		print("OK: EncontroCombate")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return

	falhas += 1
	push_error("FALHA: %s" % mensagem)
```

Criar `tests/test_encontro_combate.tscn`:

```text
[gd_scene load_steps=2 format=3]

[ext_resource path="res://tests/test_encontro_combate.gd" type="Script" id="1_teste"]

[node name="TesteEncontroCombate" type="Node"]
script = ExtResource("1_teste")
```

- [ ] **Step 2: Executar o teste e confirmar RED**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path (Get-Location) --scene res://tests/test_encontro_combate.tscn
```

Expected: falha de parse por `EncontroCombate` ainda não existir.

- [ ] **Step 3: Implementar a composição e a fase inimiga**

Criar `encontro_combate.gd`:

```gdscript
class_name EncontroCombate
extends RefCounted

var inimigo: InimigoCombate
var baralho: BaralhoCombate = BaralhoCombate.new()
var turno: int = 1


func iniciar(inimigo_novo: InimigoCombate, baralho_run: Array[String]) -> void:
	inimigo = inimigo_novo
	turno = 1
	baralho.preparar(baralho_run)

	if inimigo != null:
		inimigo.reiniciar(inimigo.vida_maxima)


func combate_terminou(jogador: JogadorCombate) -> bool:
	return (
		inimigo == null
		or inimigo.vida <= 0
		or jogador.estado.vida <= 0
	)


func executar_fase_inimiga(jogador: JogadorCombate) -> Dictionary:
	if combate_terminou(jogador):
		return {}

	var acao: Dictionary = inimigo.executar_intencao()
	var resultados_golpes: Array[Dictionary] = []

	if acao["tipo"] == "rajada":
		var danos: Array = acao["danos"]
		for dano in danos:
			resultados_golpes.append(jogador.estado.receber_golpe(int(dano)))

			if jogador.estado.vida <= 0:
				break

	acao["resultados_golpes"] = resultados_golpes
	return acao


func avancar_turno() -> void:
	turno += 1
```

- [ ] **Step 4: Executar os testes de domínio**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path (Get-Location) --scene res://tests/test_jogador_combate.tscn
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $godot --headless --path (Get-Location) --scene res://tests/test_encontro_combate.tscn
```

Expected: `OK: JogadorCombate`, `OK: EncontroCombate` e código 0.

- [ ] **Step 5: Registrar checkpoint da Task 2**

Confirmar que os dois componentes funcionam sem instanciar `main.tscn` e sem acessar nós visuais.

---

### Task 3: Integrar os componentes em `main.gd`

**Files:**
- Modify: `main.gd`
- Modify: `tests/test_estados.gd`
- Modify: `tests/test_juntas_retorno.gd`
- Modify: `tests/test_ciclo_run.gd`

**Interfaces:**
- Consumes: `JogadorCombate` e `EncontroCombate` das Tasks 1 e 2.
- Produces: `main.gd` com `jogador_combate` e `encontro_combate` como fontes de estado; propriedades antigas passam a delegar.

- [ ] **Step 1: Adicionar expectativas de integração antes da mudança**

Em `tests/test_estados.gd`, após instanciar a cena, adicionar:

```gdscript
	var jogador_combate: JogadorCombate = jogo.get("jogador_combate") as JogadorCombate
	var encontro_combate: EncontroCombate = jogo.get("encontro_combate") as EncontroCombate
	_verificar(jogador_combate != null, "main deve orquestrar um JogadorCombate")
	_verificar(encontro_combate != null, "main deve orquestrar um EncontroCombate")
	_verificar(
		jogo.get("estado_jogador") == jogador_combate.estado,
		"o estado legado do jogador deve delegar para JogadorCombate"
	)
	_verificar(
		jogo.get("estado_inimigo") == encontro_combate.inimigo,
		"o estado legado do inimigo deve delegar para EncontroCombate"
	)
```

Em `tests/test_juntas_retorno.gd`, após o segundo ganho de Combo, adicionar:

```gdscript
		var jogador_combate: JogadorCombate = jogo.get("jogador_combate") as JogadorCombate
		_verificar(
			jogador_combate.juntas_retorno_ativada_no_turno,
			"a ativação da relíquia deve pertencer ao estado do jogador"
		)
```

Em `tests/test_ciclo_run.gd`, após iniciar o combate 2, adicionar:

```gdscript
		var encontro_combate: EncontroCombate = jogo.get("encontro_combate") as EncontroCombate
		_verificar(encontro_combate.turno == 1, "o novo encontro deve reiniciar seu próprio turno")
		_verificar(
			encontro_combate.baralho.compra.size() == 7,
			"o baralho temporário deve pertencer ao encontro"
		)
```

- [ ] **Step 2: Executar os três testes e confirmar RED**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
$tests = @('test_estados.tscn', 'test_juntas_retorno.tscn', 'test_ciclo_run.tscn')
foreach ($test in $tests) {
	& $godot --headless --path (Get-Location) --scene ("res://tests/" + $test)
	if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
```

Expected: o primeiro teste executado falha porque `main.gd` ainda não expõe os componentes.

- [ ] **Step 3: Substituir o estado direto por delegações**

Em `main.gd`, adicionar a constante:

```gdscript
const LIMIAR_JUNTAS_RETORNO: int = 2
```

Substituir as declarações diretas de jogador, inimigo, Energia, turno, Combo, ativação da relíquia e baralho temporário por:

```gdscript
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

var baralho_combate: BaralhoCombate:
	get:
		return encontro_combate.baralho
```

Manter `pilha_compra`, `pilha_descarte`, `exposto_inimigo`, `enfraquecido_inimigo` e as propriedades de intenção como delegações, trocando apenas sua fonte para os getters acima.

- [ ] **Step 4: Delegar início, fim de turno, Combo e condição de encerramento**

Substituir os corpos correspondentes em `main.gd`:

```gdscript
func _combate_terminou() -> bool:
	return encontro_combate.combate_terminou(jogador_combate)


func _iniciar_combate() -> void:
	var vida_jogador_preservada: int = jogador_combate.estado.vida
	jogador_combate.iniciar_combate(vida_jogador_preservada)

	energia = ENERGIA_POR_TURNO
	combo = 0
	aguardando_recompensa = false

	resultado_label.hide()
	botao_reiniciar.hide()
	recompensas.hide()

	_limpar_mao()
	encontro_combate.iniciar(
		InimigoCombate.new(VIDA_INIMIGO_INICIAL),
		baralho_run
	)
	_iniciar_turno()

	print("Combate %d de %d iniciado." % [
		combate_atual,
		TOTAL_COMBATES
	])


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


func _ganhar_combo() -> void:
	if jogador_combate.ganhar_combo(
		BARREIRA_JUNTAS_RETORNO,
		LIMIAR_JUNTAS_RETORNO
	):
		print("Juntas de Retorno concedeu %d de Barreira." % BARREIRA_JUNTAS_RETORNO)
```

Remover `_preparar_pilhas_do_combate()`, pois `EncontroCombate.iniciar()` passa a preparar o baralho temporário. Antes de remover, confirmar com `rg '_preparar_pilhas_do_combate' main.gd tests` que a função não possui outro consumidor.

Remover `_verificar_ativacao_juntas()`. Em `_jogar_carta()`, substituir a atualização de Combo por:

```gdscript
	energia -= int(resultado["custo"])

	if resultado["gera_combo"]:
		_ganhar_combo()
	else:
		combo = int(resultado["combo"])
```

Substituir o começo de `_ao_encerrar_turno()` e o avanço final por:

```gdscript
	_descartar_mao()
	jogador_combate.encerrar_turno()
	_registrar_acao("Vega encerrou o turno.")

	_executar_intencao_drone()

	if vida_jogador <= 0:
		_atualizar_interface()
		print("Você foi derrotado.")
		_mostrar_resultado()
		return

	encontro_combate.avancar_turno()
	_iniciar_turno()
```

- [ ] **Step 5: Delegar a fase inimiga ao encontro**

Substituir `_executar_intencao_drone()` por:

```gdscript
func _executar_intencao_drone() -> void:
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

	_registrar_acao("Drone executou %s." % intencao_anunciada)
```

Depois de confirmar com `rg '_receber_dano\(' main.gd tests` que não há consumidores, remover `_receber_dano()`. Manter temporariamente `_calcular_dano_no_inimigo()`, `_calcular_dano_do_drone()` e `_causar_dano_no_inimigo()` porque os testes de estados ainda verificam essas pontes.

- [ ] **Step 6: Executar os testes de integração**

Run: o comando do Step 2.  
Expected: os três testes terminam com código 0.

- [ ] **Step 7: Registrar checkpoint da Task 3**

Executar:

```powershell
rg -n 'var energia: int =|var combo: int =|var turno: int =|estado_jogador: Combatente =' main.gd
```

Expected: nenhuma declaração direta antiga; apenas propriedades delegadas aos novos componentes.

---

### Task 4: Regressão, importação e documentação

**Files:**
- Modify: `docs/STATUS.md`
- Modify: `docs/DECISOES.md`

**Interfaces:**
- Consumes: integração concluída nas Tasks 1–3.
- Produces: evidência verificável da extração e direção atualizada para o catálogo de inimigos.

- [ ] **Step 1: Executar toda a suíte headless**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
$tests = Get-ChildItem tests -Filter '*.tscn' | Sort-Object Name
$falhas = @()
foreach ($test in $tests) {
	& $godot --headless --path (Get-Location) --scene ('res://tests/' + $test.Name)
	if ($LASTEXITCODE -ne 0) { $falhas += $test.Name }
}
if ($falhas.Count -gt 0) {
	Write-Error ('Falharam: ' + ($falhas -join ', '))
	exit 1
}
Write-Output ('OK: ' + $tests.Count + ' testes')
```

Expected: 14 cenas de teste terminam com código 0.

- [ ] **Step 2: Importar o projeto no editor headless**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --editor --path (Get-Location) --quit
```

Expected: código 0, sem erro de parse ou recurso ausente.

- [ ] **Step 3: Atualizar `STATUS.md` com fatos observados**

No resumo inicial:

- registrar `JogadorCombate` e `EncontroCombate` no estado implementado;
- corrigir o próximo passo para “generalizar dados dos inimigos e escolher o encontro”; 
- registrar que `main.gd` delega estado temporário, mas continua responsável por cena, interface, run e recompensas.

Adicionar seção cronológica com:

```markdown
## Orquestração de jogador e encontro — 23/09/2026

Criados `jogador_combate.gd` e `encontro_combate.gd`. O primeiro concentra Vida/Barreira do jogador, Energia, Combo e ativação por turno de Juntas de Retorno. O segundo concentra inimigo ativo, baralho temporário, turno, condição de encerramento e resolução da fase inimiga.

`main.gd` passou a delegar esses estados e continua responsável por sinais, cartas visuais, atualização da interface, recompensas e fluxo da run. As propriedades legadas permanecem temporariamente como pontes para os testes e serão removidas quando não houver consumidores.

Verificação executada com Godot 4.7.2: 14 testes headless e importação do editor terminaram com código 0. A validação manual da cena principal permanece necessária.

Próximo passo: especificar o catálogo de três inimigos e a escolha do encontro antes de criar elite, chefe e mapa.
```

Só registrar “14 testes” se o Step 1 realmente mostrar esse total e código 0.

- [ ] **Step 4: Atualizar `DECISOES.md` sem reescrever o histórico**

Adicionar às alterações vigentes:

```markdown
- A reorganização para `main.gd` como orquestrador passa por `JogadorCombate` e `EncontroCombate` antes da expansão de inimigos. A etapa preserva regras e mantém pontes legadas somente durante a migração.
- A expansão seguirá: catálogo e escolha entre três inimigos comuns → validação das cartas → elite → chefe → mapa das Docas.
```

- [ ] **Step 5: Registrar checkpoint final**

Listar os arquivos alterados, os comandos executados e seus códigos de saída. Não declarar validação visual; pedir ao usuário que execute `main.tscn` no editor e confirme início do combate, Juntas de Retorno, encerramento de turno, recompensa e segundo combate.

## Handoff

Executar as Tasks 1–4 em ordem. A implementação deve parar ao primeiro RED inesperado e diagnosticar a causa antes de continuar. Como as Tasks 1–3 compartilham interfaces e o workspace não possui Git nem ferramenta de subagentes configurada, a execução nativa nesta conversa é a opção recomendada.
