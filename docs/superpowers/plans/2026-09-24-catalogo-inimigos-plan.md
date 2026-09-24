# Catálogo e seleção de inimigos comuns — Plano de implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Substituir o Drone fixo por um catálogo com quatro inimigos comuns e sortear um inimigo diferente em cada combate da run atual.

**Architecture:** `DadosInimigos` declara e valida configurações imutáveis. `InimigoCombate` interpreta ciclos genéricos de ataque, defesa e preparação; `SeletorInimigos` controla o sorteio sem repetição; `EncontroCombate` aplica qualquer ataque genérico; `main.gd` apenas cria, entrega e apresenta o inimigo atual.

**Tech Stack:** Godot 4.7.2, GDScript tipado, cenas `.tscn`, testes headless executados como cenas.

**Spec:** `docs/superpowers/specs/2026-09-24-catalogo-inimigos-design.md`

## Global Constraints

- O catálogo contém exatamente o Drone de Segurança, Estivador Cibernético, Torreta de Contenção e Guarda Portuário.
- Cada combate sorteia um inimigo ainda não enfrentado na run; nenhuma intenção muda depois de anunciada.
- Os únicos tipos de intenção desta etapa são `ataque`, `defesa` e `preparacao`.
- O ciclo e os valores atuais do Drone devem permanecer funcionalmente iguais.
- Balanceamento final, novos estados, múltiplos inimigos, elite, chefe e mapa permanecem fora de escopo.
- Usar GDScript tipado e Godot 4.7.2; não adicionar dependências externas, autoloads ou Resources.
- O diretório não é um repositório Git no momento da escrita deste plano. Durante a execução, registrar checkpoints em `.superpowers/sdd/2026-09-24-catalogo-inimigos-plan/progress.md`; não simular commits inexistentes.

## File Structure

- Create `dados_inimigos.gd`: catálogo, cópia segura e validação das configurações.
- Create `seletor_inimigos.gd`: candidatos disponíveis, sorteio e histórico da run.
- Modify `inimigo_combate.gd`: executor genérico de ciclos configurados.
- Modify `encontro_combate.gd`: aplicação de qualquer ação de tipo `ataque`.
- Modify `main.gd`: criação do inimigo sorteado, textos genéricos e remoção das pontes presas ao Drone.
- Create `tests/test_catalogo_inimigos.gd` and `.tscn`: conteúdo, cópia e validação do catálogo.
- Create `tests/test_seletor_inimigos.gd` and `.tscn`: sorteio, confirmação, duplicatas e esgotamento.
- Modify `tests/test_inimigo_combate.gd`: interpretação genérica e preservação do Drone.
- Modify `tests/test_encontro_combate.gd`: fase inimiga baseada em `tipo == "ataque"`.
- Modify `tests/test_intencoes_drone.gd`, `tests/test_estados.gd`, `tests/test_ciclo_run.gd`, `tests/test_apresentacao_combate.gd`: integração sem nomes ou propriedades legadas.
- Create `tests/test_cartas_multiplos_inimigos.gd` and `.tscn`: seis cartas contra os quatro inimigos, escrito antes da generalização.
- Modify `docs/STATUS.md` and `docs/DECISOES.md`: estado observado, decisões e evidência.

## Review Focus

1. Uma lista de seleção com identificadores duplicados não deve dar peso extra nem permitir repetição; coberto na Task 2.
2. Alterar o dicionário devolvido por `DadosInimigos.obter()` não deve modificar o catálogo; coberto na Task 1.
3. Uma intenção inválida não deve apagar Barreira, consumir bônus nem avançar o ciclo; coberto na Task 3.
4. Preparação combinada com Enfraquecido deve anunciar e executar cada golpe corretamente; coberto na Task 3.
5. Um candidato com configuração inválida não deve ser registrado como enfrentado, e esgotar o pool não deve repetir; coberto na Task 4 e Task 2.

---

### Task 1: Catálogo validado de inimigos

**Files:**
- Create: `dados_inimigos.gd`
- Create: `tests/test_catalogo_inimigos.gd`
- Create: `tests/test_catalogo_inimigos.tscn`

**Interfaces:**
- Consumes: nenhum componente novo.
- Produces: `DadosInimigos.INIMIGOS: Dictionary`, `DadosInimigos.identificadores() -> Array[String]`, `DadosInimigos.dados_validos(dados: Dictionary) -> bool`, `DadosInimigos.obter(id_inimigo: String) -> Dictionary`.

- [ ] **Step 1: Confirmar a linha de base antes da primeira mudança**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
$falhas = @()
Get-ChildItem tests -Filter '*.tscn' | Sort-Object Name | ForEach-Object {
    & $godot --headless --path . --scene ("res://tests/" + $_.Name) --quit
    if ($LASTEXITCODE -ne 0) { $falhas += $_.Name }
}
if ($falhas.Count -gt 0) { throw "Falhas de base: $($falhas -join ', ')" }
```

Expected: os 14 testes existentes terminam com código 0.

- [ ] **Step 2: Criar o teste falho do catálogo**

Create `tests/test_catalogo_inimigos.gd`:

```gdscript
extends Node

var falhas: int = 0


func _ready() -> void:
	var ids: Array[String] = DadosInimigos.identificadores()
	_verificar(ids.size() == 4, "o catálogo deve conter quatro inimigos")
	_verificar(ids.has("drone_seguranca"), "o Drone deve permanecer no catálogo")
	_verificar(ids.has("estivador_cibernetico"), "o Estivador deve estar no catálogo")
	_verificar(ids.has("torreta_contencao"), "a Torreta deve estar no catálogo")
	_verificar(ids.has("guarda_portuario"), "o Guarda deve estar no catálogo")

	var drone: Dictionary = DadosInimigos.obter("drone_seguranca")
	_verificar(drone["nome"] == "Drone de Segurança", "o Drone deve ter o nome aprovado")
	_verificar(drone["vida"] == 30, "o Drone deve manter 30 de Vida")
	_verificar(drone["intencoes"].size() == 6, "o Drone deve armazenar seis passos antes de voltar à Rajada")

	var estivador: Dictionary = DadosInimigos.obter("estivador_cibernetico")
	_verificar(estivador["vida"] == 36, "o Estivador deve ter 36 de Vida")
	_verificar(estivador["intencoes"][2]["bonus_por_golpe"] == 4, "Preparar deve conceder 4")

	var torreta: Dictionary = DadosInimigos.obter("torreta_contencao")
	_verificar(torreta["vida"] == 24, "a Torreta deve ter 24 de Vida")
	_verificar(torreta["intencoes"][0]["danos"] == [2, 2, 2], "Supressão deve ter três golpes")

	var guarda: Dictionary = DadosInimigos.obter("guarda_portuario")
	_verificar(guarda["vida"] == 32, "o Guarda deve ter 32 de Vida")
	_verificar(guarda["intencoes"][1]["valor"] == 9, "Escudo deve conceder 9")

	drone["vida"] = 999
	_verificar(DadosInimigos.obter("drone_seguranca")["vida"] == 30, "obter deve devolver cópia profunda")
	_verificar(DadosInimigos.obter("ausente").is_empty(), "identificador ausente deve retornar vazio")
	_verificar(not DadosInimigos.dados_validos({}), "configuração vazia deve ser inválida")
	_verificar(not DadosInimigos.dados_validos({"nome": "X", "vida": 1, "intencoes": []}), "ciclo vazio deve ser inválido")
	_verificar(not DadosInimigos.dados_validos({
		"nome": "X", "vida": 1,
		"intencoes": [{"nome": "Erro", "tipo": "ataque", "danos": []}]
	}), "ataque sem golpes deve ser inválido")

	if falhas == 0:
		print("OK: catálogo de inimigos")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
```

Create `tests/test_catalogo_inimigos.tscn`:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://tests/test_catalogo_inimigos.gd" id="1"]

[node name="TestCatalogoInimigos" type="Node"]
script = ExtResource("1")
```

- [ ] **Step 3: Executar RED**

Run:

```powershell
& $godot --headless --path . --scene res://tests/test_catalogo_inimigos.tscn --quit
```

Expected: falha porque `DadosInimigos` ainda não existe.

- [ ] **Step 4: Implementar o catálogo mínimo completo**

Create `dados_inimigos.gd` with `class_name DadosInimigos`, the four exact entries from the approved spec, and these validation rules:

```gdscript
class_name DadosInimigos
extends RefCounted

const TIPOS_INTENCAO: Array[String] = ["ataque", "defesa", "preparacao"]
const INIMIGOS: Dictionary = {
	"drone_seguranca": {
		"nome": "Drone de Segurança", "vida": 30,
		"intencoes": [
			{"nome": "Rajada", "tipo": "ataque", "danos": [3, 3]},
			{"nome": "Blindagem de emergência", "tipo": "defesa", "valor": 6},
			{"nome": "Rajada", "tipo": "ataque", "danos": [3, 3]},
			{"nome": "Sobrecarga", "tipo": "preparacao", "bonus_por_golpe": 2},
			{"nome": "Rajada", "tipo": "ataque", "danos": [3, 3]},
			{"nome": "Marcar alvo", "tipo": "preparacao", "bonus_por_golpe": 1}
		]
	},
	"estivador_cibernetico": {
		"nome": "Estivador Cibernético", "vida": 36,
		"intencoes": [
			{"nome": "Pancada", "tipo": "ataque", "danos": [8]},
			{"nome": "Postura", "tipo": "defesa", "valor": 7},
			{"nome": "Preparar", "tipo": "preparacao", "bonus_por_golpe": 4},
			{"nome": "Pancada", "tipo": "ataque", "danos": [8]}
		]
	},
	"torreta_contencao": {
		"nome": "Torreta de Contenção", "vida": 24,
		"intencoes": [
			{"nome": "Supressão", "tipo": "ataque", "danos": [2, 2, 2]},
			{"nome": "Placas", "tipo": "defesa", "valor": 4},
			{"nome": "Calibrar", "tipo": "preparacao", "bonus_por_golpe": 1},
			{"nome": "Supressão", "tipo": "ataque", "danos": [2, 2, 2]}
		]
	},
	"guarda_portuario": {
		"nome": "Guarda Portuário", "vida": 32,
		"intencoes": [
			{"nome": "Investida", "tipo": "ataque", "danos": [6]},
			{"nome": "Escudo", "tipo": "defesa", "valor": 9},
			{"nome": "Golpe", "tipo": "ataque", "danos": [7]},
			{"nome": "Escudo", "tipo": "defesa", "valor": 9}
		]
	}
}


static func identificadores() -> Array[String]:
	var ids: Array[String] = []
	for id_inimigo in INIMIGOS.keys():
		ids.append(str(id_inimigo))
	return ids


static func obter(id_inimigo: String) -> Dictionary:
	if not INIMIGOS.has(id_inimigo):
		return {}
	var dados: Dictionary = INIMIGOS[id_inimigo]
	if not dados_validos(dados):
		return {}
	return dados.duplicate(true)


static func dados_validos(dados: Dictionary) -> bool:
	if str(dados.get("nome", "")).is_empty() or int(dados.get("vida", 0)) <= 0:
		return false
	var intencoes: Array = dados.get("intencoes", [])
	if intencoes.is_empty():
		return false
	for intencao_variant in intencoes:
		if not intencao_variant is Dictionary:
			return false
		var intencao: Dictionary = intencao_variant
		var tipo: String = str(intencao.get("tipo", ""))
		if str(intencao.get("nome", "")).is_empty() or not TIPOS_INTENCAO.has(tipo):
			return false
		if tipo == "ataque":
			var danos: Array = intencao.get("danos", [])
			if danos.is_empty():
				return false
			for dano in danos:
				if int(dano) <= 0:
					return false
		elif tipo == "defesa" and int(intencao.get("valor", 0)) <= 0:
			return false
		elif tipo == "preparacao" and int(intencao.get("bonus_por_golpe", 0)) <= 0:
			return false
	return true
```

- [ ] **Step 5: Importar a nova classe global e verificar GREEN**

Run:

```powershell
& $godot --headless --editor --path . --quit
& $godot --headless --path . --scene res://tests/test_catalogo_inimigos.tscn --quit
```

Expected: `OK: catálogo de inimigos`, código 0.

- [ ] **Step 6: Registrar checkpoint sem Git**

Create or append through `apply_patch` to `.superpowers/sdd/2026-09-24-catalogo-inimigos-plan/progress.md`:

```markdown
- Task 1 concluída: catálogo com quatro inimigos, cópia profunda e validação; teste focado verde.
```

### Task 2: Seletor sem repetição

**Files:**
- Create: `seletor_inimigos.gd`
- Create: `tests/test_seletor_inimigos.gd`
- Create: `tests/test_seletor_inimigos.tscn`

**Interfaces:**
- Consumes: `Array[String]` fornecido por `DadosInimigos.identificadores()`.
- Produces: `SeletorInimigos.new(ids: Array[String])`, `sortear_disponivel() -> String`, `registrar_enfrentado(id_inimigo: String) -> bool`, `reiniciar() -> void`, `enfrentados: Array[String]`.

- [ ] **Step 1: Escrever o teste falho do seletor**

Create `tests/test_seletor_inimigos.gd`:

```gdscript
extends Node

var falhas: int = 0


func _ready() -> void:
	var origem: Array[String] = ["a", "a", "b"]
	var seletor: SeletorInimigos = SeletorInimigos.new(origem)
	origem.clear()
	_verificar(seletor.disponiveis.size() == 2, "o seletor deve copiar e remover duplicatas")

	var primeiro: String = seletor.sortear_disponivel()
	_verificar(["a", "b"].has(primeiro), "o sorteio deve usar somente o pool")
	_verificar(seletor.enfrentados.is_empty(), "sortear não deve confirmar antes da criação")
	_verificar(seletor.registrar_enfrentado(primeiro), "um candidato válido deve ser registrável")
	_verificar(not seletor.registrar_enfrentado(primeiro), "o mesmo inimigo não deve ser registrado duas vezes")

	var segundo: String = seletor.sortear_disponivel()
	_verificar(not segundo.is_empty() and segundo != primeiro, "o segundo sorteio não deve repetir")
	_verificar(seletor.registrar_enfrentado(segundo), "o segundo candidato deve ser registrado")
	_verificar(seletor.sortear_disponivel().is_empty(), "pool esgotado deve retornar vazio")
	_verificar(not seletor.registrar_enfrentado("ausente"), "id fora do pool não deve ser registrado")

	seletor.reiniciar()
	_verificar(seletor.enfrentados.is_empty(), "reiniciar deve liberar o histórico")
	_verificar(not seletor.sortear_disponivel().is_empty(), "deve ser possível sortear em nova run")

	if falhas == 0:
		print("OK: seletor de inimigos")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
```

Create `tests/test_seletor_inimigos.tscn` with a `Node` root and `res://tests/test_seletor_inimigos.gd`, following the exact structure from Task 1.

- [ ] **Step 2: Executar RED**

Run:

```powershell
& $godot --headless --path . --scene res://tests/test_seletor_inimigos.tscn --quit
```

Expected: falha porque `SeletorInimigos` ainda não existe.

- [ ] **Step 3: Implementar o seletor mínimo**

Create `seletor_inimigos.gd`:

```gdscript
class_name SeletorInimigos
extends RefCounted

var disponiveis: Array[String] = []
var enfrentados: Array[String] = []


func _init(ids_disponiveis: Array[String]) -> void:
	for id_inimigo in ids_disponiveis:
		if not id_inimigo.is_empty() and not disponiveis.has(id_inimigo):
			disponiveis.append(id_inimigo)


func sortear_disponivel() -> String:
	var candidatos: Array[String] = []
	for id_inimigo in disponiveis:
		if not enfrentados.has(id_inimigo):
			candidatos.append(id_inimigo)
	if candidatos.is_empty():
		return ""
	return candidatos.pick_random()


func registrar_enfrentado(id_inimigo: String) -> bool:
	if not disponiveis.has(id_inimigo) or enfrentados.has(id_inimigo):
		return false
	enfrentados.append(id_inimigo)
	return true


func reiniciar() -> void:
	enfrentados.clear()
```

- [ ] **Step 4: Importar e verificar GREEN**

Run:

```powershell
& $godot --headless --editor --path . --quit
& $godot --headless --path . --scene res://tests/test_seletor_inimigos.tscn --quit
```

Expected: `OK: seletor de inimigos`, código 0.

- [ ] **Step 5: Registrar checkpoint**

Append to the progress ledger:

```markdown
- Task 2 concluída: seleção sem repetição, confirmação posterior e esgotamento seguro; teste focado verde.
```

### Task 3: Executor genérico de intenções e fase inimiga

**Files:**
- Modify: `inimigo_combate.gd`
- Modify: `encontro_combate.gd`
- Modify: `main.gd`
- Modify: `tests/test_inimigo_combate.gd`
- Modify: `tests/test_encontro_combate.gd`
- Modify: `tests/test_intencoes_drone.gd`
- Modify: `tests/test_estados.gd`
- Create: `tests/test_cartas_multiplos_inimigos.gd`
- Create: `tests/test_cartas_multiplos_inimigos.tscn`

**Interfaces:**
- Consumes: `InimigoCombate.new(id_inimigo: String, dados: Dictionary)` com dados validados por `DadosInimigos.obter()`.
- Produces: `identificador: String`, `nome: String`, `ciclo: Array[Dictionary]`, `indice_intencao: int`, `bonus_preparado: int`, `texto_intencao() -> String`, `executar_intencao() -> Dictionary`.
- Action result: ataque `{"tipo": "ataque", "nome": String, "danos": Array[int]}`; defesa/preparação `{"tipo": String, "nome": String, "valor": int}`.

- [ ] **Step 1: Reescrever primeiro o teste de `InimigoCombate` para a API desejada**

Replace the setup and assertions in `tests/test_inimigo_combate.gd` so it creates:

```gdscript
var inimigo: InimigoCombate = InimigoCombate.new(
	"drone_seguranca",
	DadosInimigos.obter("drone_seguranca")
)
_verificar(inimigo.nome == "Drone de Segurança", "o nome deve vir da configuração")
_verificar(inimigo.texto_intencao().contains("Rajada: 3 × 2"), "a primeira intenção deve ser anunciada")

var acao: Dictionary = inimigo.executar_intencao()
_verificar(acao["tipo"] == "ataque", "Rajada deve ser um ataque genérico")
_verificar(acao["danos"] == [3, 3], "Rajada deve manter dois golpes")
```

Continue through seven executed Drone actions: the six stored entries plus the Rajada reached after wrapping. Assert defense `valor == 6`, preparation values `2` and `1`, announced attacks `[5, 5]` and `[4, 4]`, and that after the wrapped Rajada the next announcement is Blindagem. Add these focused edge cases:

```gdscript
var preparado: InimigoCombate = InimigoCombate.new(
	"torreta_contencao",
	DadosInimigos.obter("torreta_contencao")
)
preparado.executar_intencao() # Supressão
preparado.executar_intencao() # Placas
preparado.executar_intencao() # Calibrar
preparado.enfraquecido = 2
_verificar(preparado.texto_intencao().contains("Supressão: 1 + 1 + 3"), "o anúncio deve considerar Enfraquecido por golpe")
acao = preparado.executar_intencao()
_verificar(acao["danos"] == [1, 1, 3], "a execução deve consumir Enfraquecido por golpe")
_verificar(preparado.bonus_preparado == 0, "o bônus deve ser consumido após o ataque completo")

var dados_invalidos: Dictionary = {
	"nome": "Inválido", "vida": 10,
	"intencoes": [{"nome": "Erro", "tipo": "desconhecida"}]
}
var invalido: InimigoCombate = InimigoCombate.new("invalido", dados_invalidos)
invalido.barreira = 5
invalido.bonus_preparado = 3
_verificar(invalido.executar_intencao().is_empty(), "intenção desconhecida deve retornar vazio")
_verificar(invalido.indice_intencao == 0, "intenção inválida não deve avançar")
_verificar(invalido.barreira == 5 and invalido.bonus_preparado == 3, "intenção inválida não deve mudar estado")
```

- [ ] **Step 2: Atualizar os testes de encontro e integração antes da implementação**

In `tests/test_encontro_combate.gd`, replace `InimigoCombate.new(30)` with the configured Drone and change expected action type from `rajada` to `ataque`. Replace direct mutation of `intencao` with `indice_intencao = 3`, then verify `encontro.iniciar()` resets the index to zero.

In `tests/test_intencoes_drone.gd` and `tests/test_estados.gd`:

- require `_executar_intencao_inimigo` instead of `_executar_intencao_drone`;
- call the new method;
- read `estado_inimigo.indice_intencao` and `estado_inimigo.bonus_preparado` instead of legacy Drone properties;
- keep all existing damage, Barrier, state and announcement assertions.

Also create `tests/test_cartas_multiplos_inimigos.gd` before changing production code:

```gdscript
extends Node

var falhas: int = 0
var resolucao: ResolucaoCartas = ResolucaoCartas.new()
var cartas: Dictionary


func _ready() -> void:
	var script_cartas: Script = load("res://dados_cartas.gd") as Script
	cartas = script_cartas.get_script_constant_map()["CARTAS"]
	for id_inimigo in DadosInimigos.identificadores():
		_testar_cartas(id_inimigo)
	if falhas == 0:
		print("OK: cartas contra quatro inimigos")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _novo_inimigo(id_inimigo: String) -> InimigoCombate:
	return InimigoCombate.new(id_inimigo, DadosInimigos.obter(id_inimigo))


func _testar_cartas(id_inimigo: String) -> void:
	var jogador: Combatente = Combatente.new(40)
	var inimigo: InimigoCombate = _novo_inimigo(id_inimigo)
	var vida_inicial: int = inimigo.vida
	var resultado: Dictionary = resolucao.resolver("golpe", cartas, jogador, inimigo, "inimigo", {"energia": 4, "combo": 0, "combo_maximo": 5})
	_verificar(resultado["valida"] and inimigo.vida == vida_inicial - 6, "%s deve receber Golpe" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	resultado = resolucao.resolver("protecao", cartas, jogador, jogador, "jogador", {"energia": 4, "combo": 0, "combo_maximo": 5})
	_verificar(resultado["valida"] and jogador.barreira == 5, "Proteção deve funcionar durante %s" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	vida_inicial = inimigo.vida
	resolucao.resolver("direto_hidraulico", cartas, jogador, inimigo, "inimigo", {"energia": 4, "combo": 0, "combo_maximo": 5})
	_verificar(inimigo.vida == vida_inicial - 4 and jogador.barreira == 2, "Direto deve funcionar contra %s" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	vida_inicial = inimigo.vida
	resultado = resolucao.resolver("quebra_chassi", cartas, jogador, inimigo, "inimigo", {"energia": 4, "combo": 3, "combo_maximo": 5})
	_verificar(inimigo.vida == maxi(0, vida_inicial - 14) and resultado["combo"] == 0, "Quebra-chassi deve funcionar contra %s" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	resolucao.resolver("brecha", cartas, jogador, inimigo, "inimigo", {"energia": 4, "combo": 0, "combo_maximo": 5})
	_verificar(inimigo.exposto == 2, "Brecha deve aplicar Exposto em %s" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	resolucao.resolver("pulso_debilitante", cartas, jogador, inimigo, "inimigo", {"energia": 4, "combo": 0, "combo_maximo": 5})
	_verificar(inimigo.enfraquecido == 2 and jogador.barreira == 3, "Pulso deve funcionar contra %s" % id_inimigo)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
```

Create `tests/test_cartas_multiplos_inimigos.tscn`:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://tests/test_cartas_multiplos_inimigos.gd" id="1"]

[node name="TestCartasMultiplosInimigos" type="Node"]
script = ExtResource("1")
```

This test must be present before changing the `InimigoCombate` constructor, so RED is caused by the missing generic API rather than by a fabricated assertion.

- [ ] **Step 3: Executar RED controlado**

Run:

```powershell
& $godot --headless --path . --scene res://tests/test_inimigo_combate.tscn --quit
& $godot --headless --path . --scene res://tests/test_encontro_combate.tscn --quit
& $godot --headless --path . --scene res://tests/test_cartas_multiplos_inimigos.tscn --quit
```

Expected: failures because the constructor and generic action types are not implemented.

- [ ] **Step 4: Substituir `InimigoCombate` pelo intérprete genérico**

Implement these rules in `inimigo_combate.gd`:

```gdscript
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
	for intencao in dados.get("intencoes", []):
		if intencao is Dictionary:
			var dados_intencao: Dictionary = intencao
			ciclo.append(dados_intencao.duplicate(true))


func reiniciar(vida_inicial: int) -> void:
	super(vida_inicial)
	indice_intencao = 0
	bonus_preparado = 0


func texto_intencao() -> String:
	var intencao: Dictionary = _intencao_atual()
	if not _intencao_valida(intencao):
		return "Intenção inválida"
	var nome_intencao: String = str(intencao["nome"])
	match str(intencao["tipo"]):
		"ataque":
			var danos: Array[int] = _danos_anunciados(intencao)
			if danos.size() == 1:
				return "%s: %d" % [nome_intencao, danos[0]]
			var todos_iguais: bool = true
			for valor in danos:
				if valor != danos[0]:
					todos_iguais = false
					break
			if todos_iguais:
				return "%s: %d × %d" % [nome_intencao, danos[0], danos.size()]
			var partes: PackedStringArray = []
			for valor in danos:
				partes.append(str(valor))
			return "%s: %s" % [nome_intencao, " + ".join(partes)]
		"defesa":
			return "%s: +%d" % [nome_intencao, int(intencao["valor"])]
		"preparacao":
			return "%s: +%d por golpe no próximo ataque" % [nome_intencao, int(intencao["bonus_por_golpe"])]
	return "Intenção inválida"


func executar_intencao() -> Dictionary:
	var intencao: Dictionary = _intencao_atual()
	if not _intencao_valida(intencao):
		return {}
	barreira = 0
	var tipo: String = str(intencao["tipo"])
	var resultado: Dictionary = {"tipo": tipo, "nome": str(intencao["nome"])}
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
```

Add private helpers `_intencao_atual()`, `_intencao_valida()`, and `_danos_anunciados()`. `_danos_anunciados()` must add `bonus_preparado` and subtract `PENALIDADE_ENFRAQUECIDO` only while `enfraquecido > indice_golpe`, without consuming charges. `_intencao_valida()` must enforce the same per-type positive values from `DadosInimigos.dados_validos()`.

- [ ] **Step 5: Generalizar `EncontroCombate`**

Replace the specific branch:

```gdscript
if acao["tipo"] == "ataque":
	for dano in acao["danos"]:
		var resultado: Dictionary = jogador.estado.receber_golpe(int(dano))
		resultados_golpes.append(resultado)
		if jogador.estado.vida <= 0:
			break
acao["resultados_golpes"] = resultados_golpes
return acao
```

Defense and preparation return an empty `resultados_golpes` list. Empty actions return immediately and never touch the player.

- [ ] **Step 6: Manter temporariamente o Drone configurado em `main.gd` e remover pontes específicas**

In `_iniciar_combate()`, instantiate the configured Drone through the global `DadosInimigos` class:

```gdscript
var dados_drone: Dictionary = DadosInimigos.obter("drone_seguranca")
encontro_combate.iniciar(
	InimigoCombate.new("drone_seguranca", dados_drone),
	baralho_run
)
```

Rename `_executar_intencao_drone()` to `_executar_intencao_inimigo()`, use `estado_inimigo.nome` in logs, and remove `intencao_drone`, `bonus_sobrecarga_inimigo`, `bonus_marca_inimigo` and `proxima_intencao_apos_rajada` from `main.gd` after their test consumers have been updated.

- [ ] **Step 7: Verificar GREEN focado e regressão**

Run:

```powershell
$focados = @('test_inimigo_combate.tscn','test_encontro_combate.tscn','test_intencoes_drone.tscn','test_estados.tscn')
foreach ($teste in $focados) {
    & $godot --headless --path . --scene ("res://tests/" + $teste) --quit
    if ($LASTEXITCODE -ne 0) { throw "Falhou: $teste" }
}
```

Expected: all four code 0; Drone damage and announcements remain equivalent.

- [ ] **Step 8: Registrar checkpoint**

```markdown
- Task 3 concluída: InimigoCombate interpreta ataque, defesa e preparação; EncontroCombate aplica ataques genéricos; ciclo do Drone preservado.
```

### Task 4: Sorteio integrado à run e interface genérica

**Files:**
- Modify: `main.gd`
- Modify: `tests/test_ciclo_run.gd`
- Modify: `tests/test_apresentacao_combate.gd`

**Interfaces:**
- Consumes: `DadosInimigos.identificadores()`, `DadosInimigos.obter()`, `SeletorInimigos` and configured `InimigoCombate`.
- Produces: `seletor_inimigos: SeletorInimigos`, `_criar_proximo_inimigo() -> InimigoCombate`, UI and action text based on `estado_inimigo.nome`.

- [ ] **Step 1: Escrever as falhas de integração da run**

In `tests/test_ciclo_run.gd`, after the first frame, capture:

```gdscript
var primeiro_inimigo: InimigoCombate = jogo.get("estado_inimigo") as InimigoCombate
var primeiro_id: String = primeiro_inimigo.identificador
_verificar(DadosInimigos.identificadores().has(primeiro_id), "o primeiro combate deve usar o catálogo")
```

After choosing the reward and starting combat two, assert:

```gdscript
var segundo_inimigo: InimigoCombate = jogo.get("estado_inimigo") as InimigoCombate
_verificar(segundo_inimigo.identificador != primeiro_id, "a run não deve repetir inimigo")
_verificar(jogo.get("seletor_inimigos").enfrentados.size() == 2, "dois encontros devem ser registrados")
_verificar(segundo_inimigo.vida == segundo_inimigo.vida_maxima, "o inimigo sorteado deve começar com Vida cheia")
_verificar(segundo_inimigo.indice_intencao == 0, "o novo inimigo deve começar na primeira intenção")
```

Remove assertions that force combat two to be a 30-Life Drone.

In `tests/test_apresentacao_combate.gd`, assert that `Alvo.text` contains `estado_inimigo.nome`. Temporarily replace `jogo.encontro_combate.inimigo` with a configured Estivador, call `_atualizar_interface()`, and assert `ESTIVADOR CIBERNÉTICO`, `Vida: 36`, and `Pancada: 8` appear in the target/intention labels.

Still before implementation, add this failure-path block to `tests/test_ciclo_run.gd` after the normal scene is freed:

```gdscript
var jogo_invalido: Node = cena_principal.instantiate()
get_tree().root.add_child(jogo_invalido)
await get_tree().process_frame
var seletor_invalido: SeletorInimigos = SeletorInimigos.new(["ausente"])
jogo_invalido.set("seletor_inimigos", seletor_invalido)
jogo_invalido.call("_iniciar_combate")
_verificar(seletor_invalido.enfrentados.is_empty(), "configuração inválida não deve ser registrada")
_verificar(
	(jogo_invalido.get_node("AcaoLabel") as Label).text.contains("Não foi possível"),
	"falha de criação deve ficar visível"
)
jogo_invalido.queue_free()
```

- [ ] **Step 2: Executar RED**

Run:

```powershell
& $godot --headless --path . --scene res://tests/test_ciclo_run.tscn --quit
& $godot --headless --path . --scene res://tests/test_apresentacao_combate.tscn --quit
```

Expected: failures because `seletor_inimigos` and dynamic names are absent.

- [ ] **Step 3: Integrar o seletor em `main.gd`**

Add:

```gdscript
var seletor_inimigos: SeletorInimigos = SeletorInimigos.new(
	DadosInimigos.identificadores()
)
```

At `_ready()`, call `seletor_inimigos.reiniciar()` immediately before `_preparar_baralho_inicial()`.

Add:

```gdscript
func _criar_proximo_inimigo() -> InimigoCombate:
	var id_inimigo: String = seletor_inimigos.sortear_disponivel()
	if id_inimigo.is_empty():
		return null
	var dados: Dictionary = DadosInimigos.obter(id_inimigo)
	if dados.is_empty():
		return null
	var inimigo: InimigoCombate = InimigoCombate.new(id_inimigo, dados)
	if inimigo.nome.is_empty() or inimigo.ciclo.is_empty():
		return null
	if not seletor_inimigos.registrar_enfrentado(id_inimigo):
		return null
	return inimigo
```

In `_iniciar_combate()`, obtain the object before starting the encounter. If it is null, set `encontro_combate.inimigo = null`, set `acao_label.text = "Não foi possível preparar o próximo inimigo."`, disable `alvo`, `jogador` and `botao_encerrar_turno`, and return before accessing `estado_inimigo`. Otherwise pass it to `encontro_combate.iniciar()`.

- [ ] **Step 4: Generalizar todos os textos visíveis e logs**

In `_atualizar_interface()`, replace both hardcoded `DRONE` strings with `estado_inimigo.nome.to_upper()`. In `_executar_intencao_inimigo()` and attack logs, replace `Drone` with `estado_inimigo.nome`.

Keep `main.tscn` placeholder text unchanged because `_ready()` replaces it before the first rendered frame.

- [ ] **Step 5: Verificar GREEN, incluindo a falha segura de criação**

Run:

```powershell
& $godot --headless --path . --scene res://tests/test_ciclo_run.tscn --quit
& $godot --headless --path . --scene res://tests/test_apresentacao_combate.tscn --quit
```

Expected: both tests code 0; invalid catalog ID is not registered.

- [ ] **Step 6: Registrar checkpoint**

```markdown
- Task 4 concluída: dois combates sorteiam inimigos distintos, a interface usa nome/intenção dinâmicos e falha de criação não contamina o histórico.
```

### Task 5: Compatibilidade das cartas, documentação e verificação final

**Files:**
- Verify: `tests/test_cartas_multiplos_inimigos.gd`
- Verify: `tests/test_cartas_multiplos_inimigos.tscn`
- Modify: `docs/STATUS.md`
- Modify: `docs/DECISOES.md`

**Interfaces:**
- Consumes: `DadosInimigos`, `InimigoCombate`, `ResolucaoCartas`, `DadosCartas.CARTAS` loaded from `dados_cartas.gd`.
- Produces: regression evidence that all six cards remain independent of enemy configuration.

- [ ] **Step 1: Conferir o teste de cartas escrito antes da Task 3**

The file `tests/test_cartas_multiplos_inimigos.gd`, created during Task 3 before production changes, must contain:

```gdscript
extends Node

var falhas: int = 0
var resolucao: ResolucaoCartas = ResolucaoCartas.new()
var cartas: Dictionary


func _ready() -> void:
	var script_cartas: Script = load("res://dados_cartas.gd") as Script
	cartas = script_cartas.get_script_constant_map()["CARTAS"]
	for id_inimigo in DadosInimigos.identificadores():
		_testar_cartas(id_inimigo)
	if falhas == 0:
		print("OK: cartas contra quatro inimigos")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _novo_inimigo(id_inimigo: String) -> InimigoCombate:
	return InimigoCombate.new(id_inimigo, DadosInimigos.obter(id_inimigo))


func _testar_cartas(id_inimigo: String) -> void:
	var jogador: Combatente = Combatente.new(40)
	var inimigo: InimigoCombate = _novo_inimigo(id_inimigo)
	var vida_inicial: int = inimigo.vida
	var resultado: Dictionary = resolucao.resolver("golpe", cartas, jogador, inimigo, "inimigo", {"energia": 4, "combo": 0, "combo_maximo": 5})
	_verificar(resultado["valida"] and inimigo.vida == vida_inicial - 6, "%s deve receber Golpe" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	resultado = resolucao.resolver("protecao", cartas, jogador, jogador, "jogador", {"energia": 4, "combo": 0, "combo_maximo": 5})
	_verificar(resultado["valida"] and jogador.barreira == 5, "Proteção deve funcionar durante %s" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	vida_inicial = inimigo.vida
	resultado = resolucao.resolver("direto_hidraulico", cartas, jogador, inimigo, "inimigo", {"energia": 4, "combo": 0, "combo_maximo": 5})
	_verificar(inimigo.vida == vida_inicial - 4 and jogador.barreira == 2, "Direto deve funcionar contra %s" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	vida_inicial = inimigo.vida
	resultado = resolucao.resolver("quebra_chassi", cartas, jogador, inimigo, "inimigo", {"energia": 4, "combo": 3, "combo_maximo": 5})
	_verificar(inimigo.vida == maxi(0, vida_inicial - 14) and resultado["combo"] == 0, "Quebra-chassi deve funcionar contra %s" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	resolucao.resolver("brecha", cartas, jogador, inimigo, "inimigo", {"energia": 4, "combo": 0, "combo_maximo": 5})
	_verificar(inimigo.exposto == 2, "Brecha deve aplicar Exposto em %s" % id_inimigo)

	jogador = Combatente.new(40)
	inimigo = _novo_inimigo(id_inimigo)
	resolucao.resolver("pulso_debilitante", cartas, jogador, inimigo, "inimigo", {"energia": 4, "combo": 0, "combo_maximo": 5})
	_verificar(inimigo.enfraquecido == 2 and jogador.barreira == 3, "Pulso deve funcionar contra %s" % id_inimigo)


func _verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error("FALHA: %s" % mensagem)
```

Its `tests/test_cartas_multiplos_inimigos.tscn` must use the same minimal Node scene structure from Task 1.

- [ ] **Step 2: Executar novamente o teste correto em GREEN**

Run:

```powershell
& $godot --headless --path . --scene res://tests/test_cartas_multiplos_inimigos.tscn --quit
```

Expected: `OK: cartas contra quatro inimigos`, código 0.

- [ ] **Step 3: Atualizar documentação factual**

In `docs/DECISOES.md`, add the approved direction:

```markdown
- O catálogo comum das Docas contém Drone de Segurança, Estivador Cibernético, Torreta de Contenção e Guarda Portuário. Os encontros sorteiam sem repetição na mesma run; intenções permanecem determinísticas e dirigidas por dados.
```

In `docs/STATUS.md`, record only observed facts: created files, four enemy values, random no-repeat selection, dynamic UI, test count, actual command results, and whether manual editor validation is still pending. Replace the “Próximo passo vigente” with manual validation of the four enemies, followed by the elite.

- [ ] **Step 4: Executar regressão completa fresca**

Run:

```powershell
$cenas = Get-ChildItem tests -Filter '*.tscn' | Sort-Object Name
$falhas = @()
foreach ($cena in $cenas) {
    & $godot --headless --path . --scene ("res://tests/" + $cena.Name) --quit
    if ($LASTEXITCODE -ne 0) { $falhas += $cena.Name }
}
if ($falhas.Count -gt 0) { throw "Falhas: $($falhas -join ', ')" }
& $godot --headless --editor --path . --quit
if ($LASTEXITCODE -ne 0) { throw 'Importação headless falhou' }
Write-Output ("VERIFICACAO_FINAL_OK=" + $cenas.Count)
```

Expected: 17 test scenes code 0 and editor import code 0.

- [ ] **Step 5: Revisar nomes presos ao Drone e registrar checkpoint final**

Run:

```powershell
rg -n "InimigoCombate\.new\(30\)|_executar_intencao_drone|intencao_drone|bonus_sobrecarga_inimigo|bonus_marca_inimigo|proxima_intencao_apos_rajada|DRONE" --glob '*.gd'
```

Expected: no production-code matches. Historical docs and the Drone catalog entry are allowed; test names may still mention Drone when specifically validating preservation of its cycle.

Append:

```markdown
- Task 5 concluída: seis cartas validadas contra quatro inimigos; documentação atualizada; regressão completa e importação headless verdes.
```

## Manual Validation Handoff

After automation is green, ask the user to run `main.tscn` repeatedly and verify:

1. the first and second combats show different enemy names;
2. each intention shown is exactly the action executed at end of turn;
3. Estivador announces a 12-damage Pancada after Preparar;
4. Torreta announces and executes three hits after Calibrar;
5. Guarda alternates its approved attacks and 9 Barrier defenses;
6. cards, rewards, persistent Life and run conclusion still behave as before.

Record this as user-reported visual validation in `docs/STATUS.md`; do not call balance final based on this check.
