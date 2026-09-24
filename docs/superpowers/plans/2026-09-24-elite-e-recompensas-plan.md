# Elite e Recompensas da Terceira Batalha Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expandir a run para três combates, adicionar a Unidade de Contenção Portuária como elite e entregar uma relíquia e uma carta rara após sua vitória.

**Architecture:** O elite será apenas mais uma configuração do catálogo de inimigos e usará `InimigoCombate` e `EncontroCombate` sem regras especiais em `main.gd`. Cartas raras e relíquias terão catálogos próprios; `JogadorCombate` manterá as relíquias da run e seus gatilhos, enquanto `main.gd` ficará responsável por transições e apresentação. A recompensa do elite reutilizará o componente de ofertas distintas e terá duas etapas explícitas.

**Tech Stack:** Godot 4.7.2, GDScript tipado, cenas `.tscn`, testes headless em GDScript, PowerShell e Git.

**Spec:** `docs/superpowers/specs/2026-09-24-elite-e-recompensas-design.md`

## Global Constraints

- O elite será o terceiro combate da run, depois de dois combates comuns.
- As intenções serão determinísticas e o dano anunciado incluirá os bônus preparados e Enfraquecido.
- Os valores são provisórios para testar leitura, ritmo e dificuldade; não são balanceamento final.
- A vitória contra o elite exigirá uma relíquia e uma carta rara; não haverá skip nessa tela.
- O projeto continuará usando Godot 4.7.2 e GDScript tipado.
- Não criar subclasses específicas para a Unidade de Contenção, nem introduzir múltiplos inimigos, estados novos, cura, roubo de cartas ou descarte forçado.
- Não remover todas as pontes legadas de `main.gd` nesta etapa.

## Review Focus

- Elite iniciado no terceiro combate, sem ser registrado como um comum nem repetir a seleção comum: cobrir em `test_ciclo_run.gd`.
- Bônus de Pressurizar anunciado como `7 × 2` e consumido somente depois do ataque completo: cobrir em `tests/test_inimigo_combate.gd`.
- Oferta do elite com pools distintos, sem duplicatas e sem concluir a run antes da segunda escolha: cobrir em `test_recompensa_elite.gd`.
- Relíquia escolhida persistindo entre combates e não sendo oferecida novamente como duplicata: cobrir em `test_recompensa_elite.gd` e `test_jogador_combate.gd`.
- Carta rara sendo resolvida pelo mesmo `ResolucaoCartas`, inclusive Exposto e Barreira: cobrir em `test_catalogo_cartas.gd` e `test_resolucao_cartas.gd`.

---

### Task 1: Catalogar a Unidade de Contenção Portuária

**Files:**
- Modify: `dados_inimigos.gd`
- Modify: `tests/test_catalogo_inimigos.gd`
- Modify: `tests/test_inimigo_combate.gd`

**Interfaces:**
- Consumes: `DadosInimigos.obter()`, `DadosInimigos.identificadores()`, `InimigoCombate` e os três tipos de intenção atuais.
- Produces: `DadosInimigos.identificadores_elite() -> Array[String]`; `DadosInimigos.obter("unidade_contencao_portuaria") -> Dictionary`.

- [ ] **Step 1: Escrever os testes que falham para o catálogo do elite**

Adicionar ao teste do catálogo:

```gdscript
	var elites: Array[String] = DadosInimigos.identificadores_elite()
	_verificar(elites == ["unidade_contencao_portuaria"], "deve existir um elite")

	var elite: Dictionary = DadosInimigos.obter("unidade_contencao_portuaria")
	_verificar(elite["nome"] == "Unidade de Contenção Portuária", "o elite deve ter nome próprio")
	_verificar(elite["vida"] == 44, "o elite deve começar com 44 de Vida")
	_verificar(elite["intencoes"].size() == 4, "o elite deve ter quatro intenções")
	_verificar(elite["intencoes"][0]["tipo"] == "preparacao", "o ciclo deve começar preparando")
	_verificar(elite["intencoes"][1]["danos"] == [5, 5], "a Rajada deve ter dois danos-base de 5")
	_verificar(elite["intencoes"][2]["valor"] == 8, "a Blindagem pesada deve conceder 8")
	_verificar(elite["intencoes"][3]["danos"] == [8], "o Golpe de pistão deve causar 8")
	_verificar(
		DadosInimigos.identificadores().size() == 4,
		"o identificador de elite não deve entrar no pool comum"
	)
```

Adicionar ao teste de intenção:

```gdscript
	var elite: InimigoCombate = InimigoCombate.new(
		"unidade_contencao_portuaria",
		DadosInimigos.obter("unidade_contencao_portuaria")
	)
	var preparar: Dictionary = elite.executar_intencao()
	_verificar(preparar["tipo"] == "preparacao", "o elite deve preparar primeiro")
	_verificar(elite.texto_intencao().contains("7 × 2"), "a Rajada deve anunciar 7 por golpe")
	var rajada: Dictionary = elite.executar_intencao()
	_verificar(rajada["danos"] == [7, 7], "o bônus deve ser aplicado aos dois golpes")
	_verificar(elite.bonus_preparado == 0, "o bônus deve ser consumido após a Rajada")
```

- [ ] **Step 2: Executar os testes e confirmar RED**

Run: `& 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --scene res://tests/test_catalogo_inimigos.tscn`

Expected: FAIL porque `identificadores_elite()` e a configuração do elite ainda não existem.

- [ ] **Step 3: Adicionar o catálogo separado de elite**

Manter os quatro inimigos em `INIMIGOS` para que `identificadores()` continue representando o pool comum. Adicionar um dicionário `ELITES` e estes métodos:

```gdscript
const ELITES: Dictionary = {
	"unidade_contencao_portuaria": {
		"nome": "Unidade de Contenção Portuária",
		"vida": 44,
		"intencoes": [
			{"nome": "Pressurizar", "tipo": "preparacao", "bonus_por_golpe": 2},
			{"nome": "Rajada de contenção", "tipo": "ataque", "danos": [5, 5]},
			{"nome": "Blindagem pesada", "tipo": "defesa", "valor": 8},
			{"nome": "Golpe de pistão", "tipo": "ataque", "danos": [8]}
		]
	}
}

static func identificadores_elite() -> Array[String]:
	return ["unidade_contencao_portuaria"]
```

Fazer `obter()` consultar `INIMIGOS` e depois `ELITES`, sempre retornando `duplicate(true)`. Manter `dados_validos()` como validador comum para ambos os catálogos.

- [ ] **Step 4: Executar os testes e confirmar GREEN**

Run: os dois testes headless de catálogo e intenção usados acima.

Expected: PASS, incluindo o ciclo existente do Drone e o anúncio `7 × 2` do elite.

- [ ] **Step 5: Commitar o catálogo do elite**

```powershell
git add dados_inimigos.gd tests/test_catalogo_inimigos.gd tests/test_inimigo_combate.gd
git commit -m "feat: add port containment elite catalog"
```

### Task 2: Adicionar o catálogo de cartas raras

**Files:**
- Modify: `dados_cartas.gd`
- Modify: `tests/test_catalogo_cartas.gd`
- Modify: `tests/test_resolucao_cartas.gd`

**Interfaces:**
- Consumes: `DADOS_CARTAS.CARTAS` e `ResolucaoCartas.resolver()`.
- Produces: `DADOS_CARTAS.identificadores_por_raridade(raridade: String) -> Array[String]`; três cartas raras resolvíveis pelo sistema atual.

- [ ] **Step 1: Escrever os testes RED para raridade e efeitos**

Adicionar ao catálogo:

```gdscript
	var raras: Array[String] = script_catalogo.identificadores_por_raridade("rara")
	_verificar(raras.size() == 3, "o catálogo deve ter três cartas raras")
	_verificar(raras.has("golpe_ariete"), "Golpe de Aríete deve ser raro")
	_verificar(raras.has("ruptura_pressao"), "Ruptura de Pressão deve ser rara")
	_verificar(raras.has("placa_reforcada"), "Placa Reforçada deve ser rara")
	_verificar(cartas["golpe"]["raridade"] == "comum", "cartas atuais devem ser comuns")
	_verificar(cartas["golpe_ariete"]["valor"] == 12, "Golpe de Aríete deve causar 12")
	_verificar(cartas["ruptura_pressao"]["exposto"] == 2, "Ruptura deve aplicar Exposto 2")
	_verificar(cartas["placa_reforcada"]["valor"] == 8, "Placa deve conceder Barreira 8")
```

Adicionar ao teste do resolvedor chamadas que confirmem dano, Exposto e Barreira sem criar regras especiais para raridade:

```gdscript
	var alvo: Combatente = Combatente.new(30)
	var fonte: Combatente = Combatente.new(40)
	var resultado: Dictionary = ResolucaoCartas.resolver(
		"ruptura_pressao", cartas, fonte, alvo, "inimigo", {}
	)
	_verificar(resultado["valido"], "Ruptura deve ser resolvível")
	_verificar(alvo.exposto == 2, "Ruptura deve aplicar Exposto")
```

- [ ] **Step 2: Executar e confirmar RED**

Run: os testes de catálogo e resolução em modo headless.

Expected: FAIL porque a função de filtro e os três identificadores ainda não existem.

- [ ] **Step 3: Adicionar metadados e cartas raras**

Adicionar `"raridade": "comum"` às seis cartas atuais e estas entradas:

```gdscript
	"golpe_ariete": {
		"nome": "GOLPE DE ARÍETE",
		"custo": 2,
		"valor": 12,
		"alvo": "inimigo",
		"tipo": "ataque",
		"raridade": "rara"
	},
	"ruptura_pressao": {
		"nome": "RUPTURA DE PRESSÃO",
		"custo": 1,
		"valor": 4,
		"alvo": "inimigo",
		"tipo": "ataque",
		"exposto": 2,
		"raridade": "rara"
	},
	"placa_reforcada": {
		"nome": "PLACA REFORÇADA",
		"custo": 1,
		"valor": 8,
		"alvo": "jogador",
		"tipo": "habilidade",
		"raridade": "rara"
	}
```

Adicionar:

```gdscript
static func identificadores_por_raridade(raridade: String) -> Array[String]:
	var ids: Array[String] = []
	for id_carta in CARTAS.keys():
		if str(CARTAS[id_carta].get("raridade", "comum")) == raridade:
			ids.append(str(id_carta))
	return ids
```

- [ ] **Step 4: Executar os testes e confirmar GREEN**

Run: testes de catálogo e resolução.

Expected: PASS, com as seis cartas existentes preservadas e as três raras usando a mesma resolução.

- [ ] **Step 5: Commitar o catálogo raro**

```powershell
git add dados_cartas.gd tests/test_catalogo_cartas.gd tests/test_resolucao_cartas.gd
git commit -m "feat: add rare card catalog"
```

### Task 3: Criar catálogo e estado de relíquias

**Files:**
- Create: `dados_reliquias.gd`
- Modify: `jogador_combate.gd`
- Modify: `tests/test_jogador_combate.gd`
- Create: `tests/test_catalogo_reliquias.gd`
- Create: `tests/test_catalogo_reliquias.tscn`

**Interfaces:**
- Consumes: estado atual de `JogadorCombate`, Combo, início de turno e resolução de Finalização.
- Produces: `DadosReliquias.obter(id: String) -> Dictionary`; `DadosReliquias.identificadores_sem(ids_excluidos: Array[String]) -> Array[String]`; `JogadorCombate.reliquias_run`; `adicionar_reliquia(id: String) -> bool`; `possui_reliquia(id: String) -> bool`; `registrar_finalizacao(combo_consumido: int) -> bool`.

- [ ] **Step 1: Escrever os testes RED do catálogo e dos gatilhos**

O teste do catálogo deverá verificar os três identificadores (`juntas_retorno`, `reservatorio_auxiliar`, `mecanismo_recuo`) e suas regras. O teste do jogador deverá verificar:

```gdscript
	var jogador: JogadorCombate = JogadorCombate.new(40, 4, 5)
	_verificar(jogador.possui_reliquia("juntas_retorno"), "Juntas deve começar equipada")
	_verificar(jogador.adicionar_reliquia("reservatorio_auxiliar"), "relíquia nova deve ser adicionada")
	_verificar(jogador.adicionar_reliquia("mecanismo_recuo"), "segunda relíquia deve ser adicionada")
	_verificar(not jogador.adicionar_reliquia("reservatorio_auxiliar"), "relíquia duplicada deve ser rejeitada")

	jogador.iniciar_turno()
	_verificar(jogador.estado.barreira == 2, "Reservatório deve conceder 2 de Barreira")

	jogador.combo = 2
	_verificar(jogador.registrar_finalizacao(2), "Mecanismo deve ativar após consumir Combo")
	_verificar(jogador.estado.barreira == 4, "Mecanismo deve conceder 2 de Barreira")
	_verificar(not jogador.registrar_finalizacao(1), "Mecanismo deve ativar uma vez por turno")
```

Criar `tests/test_catalogo_reliquias.tscn` com o mesmo formato dos testes existentes:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://tests/test_catalogo_reliquias.gd" id="1"]

[node name="TestCatalogoReliquias" type="Node"]
script = ExtResource("1")
```

- [ ] **Step 2: Executar e confirmar RED**

Run: `tests/test_catalogo_reliquias.tscn` e o teste existente de `JogadorCombate`.

Expected: FAIL porque o catálogo e os métodos de relíquias ainda não existem.

- [ ] **Step 3: Implementar o catálogo de relíquias**

Criar `dados_reliquias.gd` com dados e consulta por cópia profunda:

```gdscript
class_name DadosReliquias
extends RefCounted

const RELIQUIAS: Dictionary = {
	"juntas_retorno": {
		"nome": "Juntas de Retorno",
		"descricao": "Ao alcançar 2 Combo no turno, ganhe 3 de Barreira uma vez."
	},
	"reservatorio_auxiliar": {
		"nome": "Reservatório Auxiliar",
		"descricao": "No início de cada turno, ganhe 2 de Barreira."
	},
	"mecanismo_recuo": {
		"nome": "Mecanismo de Recuo",
		"descricao": "Uma vez por turno, após consumir Combo com Finalização, ganhe 2 de Barreira."
	}
}

static func obter(id_reliquia: String) -> Dictionary:
	if not RELIQUIAS.has(id_reliquia):
		return {}
	return RELIQUIAS[id_reliquia].duplicate(true)

static func identificadores_sem(ids_excluidos: Array[String]) -> Array[String]:
	var ids: Array[String] = []
	for id_reliquia in RELIQUIAS.keys():
		if not ids_excluidos.has(str(id_reliquia)):
			ids.append(str(id_reliquia))
	return ids
```

- [ ] **Step 4: Integrar relíquias em `JogadorCombate` sem acessar a cena**

Inicializar `reliquias_run` com `["juntas_retorno"]`, resetar somente os marcadores temporários no início do combate e do turno, e adicionar as interfaces:

```gdscript
var reliquias_run: Array[String] = ["juntas_retorno"]
var mecanismo_recuo_ativado_no_turno: bool = false

func possui_reliquia(id_reliquia: String) -> bool:
	return reliquias_run.has(id_reliquia)

func adicionar_reliquia(id_reliquia: String) -> bool:
	if not DadosReliquias.RELIQUIAS.has(id_reliquia) or possui_reliquia(id_reliquia):
		return false
	reliquias_run.append(id_reliquia)
	return true

func registrar_finalizacao(combo_consumido: int) -> bool:
	if combo_consumido <= 0 or not possui_reliquia("mecanismo_recuo"):
		return false
	if mecanismo_recuo_ativado_no_turno:
		return false
	estado.aplicar_barreira(2)
	mecanismo_recuo_ativado_no_turno = true
	return true
```

Fazer `iniciar_turno()` zerar `mecanismo_recuo_ativado_no_turno` e aplicar 2 de Barreira se `reservatorio_auxiliar` estiver equipado. Fazer `ganhar_combo()` continuar preservando a assinatura atual, mas ativar Juntas somente quando `possui_reliquia("juntas_retorno")` for verdadeiro.

- [ ] **Step 5: Executar os testes e confirmar GREEN**

Run: teste do catálogo, teste de `JogadorCombate`, teste de Juntas de Retorno e regressão dos testes de estados.

Expected: PASS; a relíquia inicial mantém o comportamento anterior e as duas novas relíquias ativam somente nos gatilhos definidos.

- [ ] **Step 6: Commitar o sistema de relíquias**

```powershell
git add dados_reliquias.gd jogador_combate.gd tests/test_catalogo_reliquias.gd tests/test_catalogo_reliquias.tscn tests/test_jogador_combate.gd
git commit -m "feat: add relic catalog and player relic state"
```

### Task 4: Preparar a interface da recompensa do elite

**Files:**
- Modify: `main.tscn`
- Create: `tests/test_recompensa_elite.gd`
- Create: `tests/test_recompensa_elite.tscn`

**Interfaces:**
- Consumes: os nós existentes de recompensa comum e o catálogo de relíquias/cartas raras.
- Produces: `RecompensaElite`, `RecompensaElite/ReliquiasElite/RelquiaOpcao1`, `RecompensaElite/ReliquiasElite/RelquiaOpcao2`, `RecompensaElite/CartasRarasElite/CartaRaraOpcao1`, `RecompensaElite/CartasRarasElite/CartaRaraOpcao2`, `RecompensaElite/CartasRarasElite/CartaRaraOpcao3`, todos ocultos durante o combate.

- [ ] **Step 1: Escrever o teste RED da árvore de cena**

Adicionar verificações:

```gdscript
	_verificar(jogo.has_node("RecompensaElite"), "a cena deve ter a área do elite")
	_verificar(jogo.has_node("RecompensaElite/ReliquiasElite/RelquiaOpcao1"), "deve haver a primeira relíquia")
	_verificar(jogo.has_node("RecompensaElite/ReliquiasElite/RelquiaOpcao2"), "deve haver a segunda relíquia")
	_verificar(jogo.has_node("RecompensaElite/CartasRarasElite/CartaRaraOpcao1"), "deve haver a primeira carta rara")
	_verificar(jogo.has_node("RecompensaElite/CartasRarasElite/CartaRaraOpcao2"), "deve haver a segunda carta rara")
	_verificar(jogo.has_node("RecompensaElite/CartasRarasElite/CartaRaraOpcao3"), "deve haver a terceira carta rara")
	_verificar(not jogo.get_node("RecompensaElite").visible, "a área deve começar escondida")
```

Criar `tests/test_recompensa_elite.tscn` com:

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://tests/test_recompensa_elite.gd" id="1"]

[node name="TestRecompensaElite" type="Node"]
script = ExtResource("1")
```

- [ ] **Step 2: Executar e confirmar RED**

Run: `tests/test_recompensa_elite.tscn`.

Expected: FAIL pela ausência da nova árvore de recompensa.

- [ ] **Step 3: Criar os nós sem alterar a recompensa comum**

Adicionar em `main.tscn` um `VBoxContainer` chamado `RecompensaElite`, com um `Label` de título, um `HBoxContainer` `ReliquiasElite` com dois `Button`, um `Label` de título e um `HBoxContainer` `CartasRarasElite` com três `Button`. Posicionar a área no mesmo bloco central usado pela recompensa comum e deixá-la oculta por padrão.

Adicionar em `main.gd`, junto dos outros `@onready`, as referências:

```gdscript
@onready var recompensa_elite: VBoxContainer = $RecompensaElite
@onready var reliquia_opcao_1: Button = $RecompensaElite/ReliquiasElite/RelquiaOpcao1
@onready var reliquia_opcao_2: Button = $RecompensaElite/ReliquiasElite/RelquiaOpcao2
@onready var carta_rara_opcao_1: Button = $RecompensaElite/CartasRarasElite/CartaRaraOpcao1
@onready var carta_rara_opcao_2: Button = $RecompensaElite/CartasRarasElite/CartaRaraOpcao2
@onready var carta_rara_opcao_3: Button = $RecompensaElite/CartasRarasElite/CartaRaraOpcao3
@onready var cartas_raras_elite: HBoxContainer = $RecompensaElite/CartasRarasElite
```

- [ ] **Step 4: Executar e confirmar GREEN**

Run: o teste da árvore e `tests/test_apresentacao_combate.tscn`.

Expected: PASS; a nova área não altera o layout do combate nem aparece durante a partida.

- [ ] **Step 5: Commitar a estrutura visual**

```powershell
git add main.tscn tests/test_recompensa_elite.gd tests/test_recompensa_elite.tscn
git commit -m "feat: add elite reward interface"
```

### Task 5: Integrar o elite e a recompensa dupla na run

**Files:**
- Modify: `main.gd`
- Modify: `tests/test_ciclo_run.gd`
- Modify: `tests/test_recompensa_pular.gd`
- Modify: `tests/test_recompensa_elite.gd`

**Interfaces:**
- Consumes: `DadosInimigos.identificadores_elite()`, `DADOS_CARTAS.identificadores_por_raridade()`, `OfertaRecompensa`, `JogadorCombate` e os nós criados na Task 4.
- Produces: run com `TOTAL_COMBATES = 3`; `_mostrar_recompensa_elite()`; `_ao_selecionar_reliquia(indice: int)`; `_ao_selecionar_carta_rara(indice: int)`; `_escolher_recompensa_elite_reliquia(id_reliquia: String)`; `_escolher_recompensa_elite_carta(id_carta: String)`.

- [ ] **Step 1: Estender o teste de ciclo para três combates e escrever o teste RED da oferta dupla**

O teste deverá confirmar, após a escolha da recompensa comum do combate 2:

```gdscript
	_verificar(jogo.get("combate_atual") == 3, "a segunda recompensa deve iniciar o terceiro combate")
	var elite: InimigoCombate = jogo.get("estado_inimigo") as InimigoCombate
	_verificar(elite.identificador == "unidade_contencao_portuaria", "o terceiro combate deve usar o elite")
	_verificar(
		(jogo.get("seletor_inimigos") as SeletorInimigos).enfrentados.size() == 2,
		"o elite não deve entrar no histórico de comuns"
	)

	jogo.set("vida_inimigo", 0)
	jogo.call("_resolver_vitoria")
	_verificar(jogo.get("aguardando_recompensa_elite"), "a vitória do elite deve abrir recompensa dupla")
	_verificar(jogo.get("oferta_reliquias").opcoes.size() == 2, "devem existir duas relíquias")
	_verificar(jogo.get("oferta_cartas_raras").opcoes.size() == 3, "devem existir três cartas raras")
	_verificar(not jogo.get_node("RecompensaElite/CartasRarasElite").visible, "cartas raras devem esperar a relíquia")
```

Adicionar depois as verificações de escolha:

```gdscript
	var id_reliquia: String = jogo.get("oferta_reliquias").opcoes[0]
	jogo.call("_escolher_recompensa_elite_reliquia", id_reliquia)
	_verificar(
		(jogo.get("jogador_combate") as JogadorCombate).reliquias_run.has(id_reliquia),
		"a relíquia deve persistir na run"
	)
	_verificar(jogo.get_node("RecompensaElite/CartasRarasElite").visible, "a escolha deve abrir cartas raras")

	var tamanho_baralho: int = jogo.get("baralho_run").size()
	var id_rara: String = jogo.get("oferta_cartas_raras").opcoes[0]
	jogo.call("_escolher_recompensa_elite_carta", id_rara)
	_verificar(jogo.get("baralho_run").size() == tamanho_baralho + 1, "a carta rara deve entrar no baralho")
	_verificar(not jogo.get("aguardando_recompensa_elite"), "as duas escolhas devem encerrar a espera")
	_verificar((jogo.get_node("Reiniciar") as Button).visible, "a run deve concluir após a carta rara")
```

- [ ] **Step 2: Executar e confirmar RED**

Run: `tests/test_ciclo_run.tscn`, `tests/test_recompensa_elite.tscn` e `tests/test_recompensa_pular.tscn`.

Expected: FAIL porque a run ainda termina no segundo combate e os métodos de recompensa do elite não existem.

- [ ] **Step 3: Alterar a seleção do combate sem misturar o elite ao pool comum**

Em `main.gd`:

```gdscript
const TOTAL_COMBATES: int = 3
const ID_ELITE: String = "unidade_contencao_portuaria"

var aguardando_recompensa_elite: bool = false
var etapa_recompensa_elite: String = ""
var oferta_reliquias: OfertaRecompensa = OfertaRecompensa.new()
var oferta_cartas_raras: OfertaRecompensa = OfertaRecompensa.new()
```

No início de `_iniciar_combate()`, usar `DadosInimigos.obter(ID_ELITE)` somente quando `combate_atual == TOTAL_COMBATES`; nos dois primeiros combates, manter `SeletorInimigos` e `DadosInimigos.identificadores()`. Não chamar `registrar_enfrentado()` para o elite.

- [ ] **Step 4: Implementar a oferta em duas fases**

Adicionar em `_resolver_vitoria()` o terceiro caminho:

```gdscript
func _resolver_vitoria() -> void:
	combo = 0

	if combate_atual < TOTAL_COMBATES:
		_mostrar_recompensas()
	else:
		_mostrar_recompensa_elite()
```

Implementar a preparação:

```gdscript
func _mostrar_recompensa_elite() -> void:
	aguardando_recompensa_elite = true
	etapa_recompensa_elite = "reliquia"
	oferta_reliquias.gerar(
		DadosReliquias.identificadores_sem(jogador_combate.reliquias_run),
		2
	)
	oferta_cartas_raras.gerar(
		DADOS_CARTAS.identificadores_por_raridade("rara"),
		3
	)
	resultado_label.text = "ELITE VENCIDO\nEscolha uma relíquia"
	resultado_label.show()
	recompensa_elite.show()
	recompensas.hide()
	cartas_raras_elite.hide()
	_preencher_opcoes_reliquias()
```

`DadosReliquias.identificadores_sem(ids_excluidos: Array[String]) -> Array[String]` retorna somente relíquias válidas que não estejam equipadas.

Conectar os botões no `_ready()`:

```gdscript
reliquia_opcao_1.pressed.connect(_ao_selecionar_reliquia.bind(0))
reliquia_opcao_2.pressed.connect(_ao_selecionar_reliquia.bind(1))
carta_rara_opcao_1.pressed.connect(_ao_selecionar_carta_rara.bind(0))
carta_rara_opcao_2.pressed.connect(_ao_selecionar_carta_rara.bind(1))
carta_rara_opcao_3.pressed.connect(_ao_selecionar_carta_rara.bind(2))
```

Adicionar também estes métodos de apresentação em `main.gd`:

```gdscript
func _preencher_opcoes_reliquias() -> void:
	reliquia_opcao_1.text = DadosReliquias.obter(oferta_reliquias.opcoes[0])["nome"]
	reliquia_opcao_2.text = DadosReliquias.obter(oferta_reliquias.opcoes[1])["nome"]
	reliquia_opcao_1.show()
	reliquia_opcao_2.show()


func _preencher_opcoes_cartas_raras() -> void:
	carta_rara_opcao_1.text = CARTAS[oferta_cartas_raras.opcoes[0]]["nome"]
	carta_rara_opcao_2.text = CARTAS[oferta_cartas_raras.opcoes[1]]["nome"]
	carta_rara_opcao_3.text = CARTAS[oferta_cartas_raras.opcoes[2]]["nome"]
	carta_rara_opcao_1.show()
	carta_rara_opcao_2.show()
	carta_rara_opcao_3.show()


func _ocultar_recompensa_elite() -> void:
	recompensa_elite.hide()
	cartas_raras_elite.hide()
```

Declarar também `@onready var cartas_raras_elite: HBoxContainer = $RecompensaElite/CartasRarasElite` para que as duas fases possam ser mostradas separadamente.

Implementar as duas escolhas, bloqueando chamadas fora da fase correspondente:

```gdscript
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

	etapa_recompensa_elite = "carta_rara"
	resultado_label.text = "RELÍQUIA ADICIONADA\nEscolha uma carta rara"
	cartas_raras_elite.show()
	_preencher_opcoes_cartas_raras()


func _escolher_recompensa_elite_carta(id_carta: String) -> void:
	if not aguardando_recompensa_elite or etapa_recompensa_elite != "carta_rara":
		return
	if not oferta_cartas_raras.opcoes.has(id_carta):
		return

	baralho_run.append(id_carta)
	aguardando_recompensa_elite = false
	etapa_recompensa_elite = ""
	_ocultar_recompensa_elite()
	_mostrar_resultado()
```

Usar `jogador_combate.reliquias_run` como fonte única do estado. Conectar os cinco botões no `_ready()`, atualizar o texto com os catálogos e esconder a área ao iniciar qualquer combate ou reiniciar a cena. A função `_mostrar_resultado()` deverá ocultar a recompensa elite e manter o texto `RUN CONCLUÍDA`.

- [ ] **Step 5: Atualizar apresentação e compatibilidade do fluxo**

Atualizar `ReliquiaLabel` para listar os nomes das relíquias equipadas, sem remover `Juntas de Retorno`. Fazer `_atualizar_interface()` bloquear cartas, alvo e encerramento enquanto `aguardando_recompensa_elite` for verdadeiro. Manter o botão `Pular` funcionando somente na recompensa comum.

No início de `_jogar_carta()`, salvar `var combo_antes: int = combo`. Depois de uma resolução válida, quando `resultado["consome_combo"]` for verdadeiro, chamar `jogador_combate.registrar_finalizacao(combo_antes)` antes de descartar a carta. Isso permite que `Mecanismo de Recuo` reaja ao Combo realmente consumido sem colocar sua regra no controlador.

- [ ] **Step 6: Executar os testes e confirmar GREEN**

Run: todos os testes de ciclo, recompensa, cartas, relíquias, estados, intenções e apresentação.

Expected: PASS; a run passa por dois comuns, chega ao elite, exige as duas escolhas e conclui apenas depois da carta rara. Os testes de skip comum continuam passando.

- [ ] **Step 7: Commitar a integração da run**

```powershell
git add main.gd tests/test_ciclo_run.gd tests/test_recompensa_pular.gd tests/test_recompensa_elite.gd
git commit -m "feat: add elite battle and dual reward flow"
```

### Task 6: Regressão completa, validação headless e documentação

**Files:**
- Modify: `docs/STATUS.md`
- Modify: `docs/DECISOES.md` somente se algum comportamento aprovado precisar ser esclarecido durante a implementação

**Interfaces:**
- Consumes: todos os componentes e testes das Tasks 1–5.
- Produces: evidência verificável do elite e da recompensa dupla, sem registrar validação manual que ainda não ocorreu.

- [ ] **Step 1: Executar cada teste da pasta `tests`**

Run:

```powershell
Get-ChildItem tests -Filter *.tscn | ForEach-Object {
	& 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --scene (Resolve-Path $_.FullName).Path
	if ($LASTEXITCODE -ne 0) { throw "Falha em $($_.Name)" }
}
```

Expected: todos os testes terminam com código 0; registrar os nomes e resultados reais.

- [ ] **Step 2: Importar o projeto em modo headless**

Run:

```powershell
& 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --quit
if ($LASTEXITCODE -ne 0) { throw "Falha na importação headless" }
```

Expected: código 0 sem erro de parse ou recurso ausente.

- [ ] **Step 3: Validar manualmente no editor**

Executar `main.tscn` e confirmar, nesta ordem:

1. dois inimigos comuns diferentes nos dois primeiros combates;
2. Unidade de Contenção no terceiro combate;
3. intenção `Preparar: +2 por golpe` e depois `Rajada: 7 × 2`;
4. seleção de uma relíquia e mudança clara para a tela de cartas raras;
5. seleção de uma carta rara e conclusão da run;
6. relíquia equipada aparecendo na interface;
7. tentativa de clicar nos controles durante a recompensa sem executar combate.

Registrar como relato do usuário somente o que for observado no editor.

- [ ] **Step 4: Atualizar `STATUS.md`**

Adicionar uma seção cronológica com data 24/09/2026 contendo apenas:

- elite implementado, nome, Vida e ciclo;
- run ampliada para três combates;
- duas etapas obrigatórias de recompensa;
- cartas raras e relíquias adicionadas;
- arquivos criados e testes realmente executados;
- resultado da validação visual, separado da validação automatizada;
- próximo passo: encontros não-combate das Docas, se o usuário confirmar o comportamento.

Atualizar o resumo inicial e `Atividade atual` somente depois que os testes e a validação manual forem conhecidos. Não remover os registros históricos anteriores.

- [ ] **Step 5: Commitar documentação e verificação**

```powershell
git add docs/STATUS.md docs/DECISOES.md
git commit -m "docs: record elite and dual rewards validation"
```

## Resultado esperado

Ao terminar o plano, a run terá três combates: dois inimigos comuns escolhidos sem repetição e a Unidade de Contenção Portuária como elite fixo. A vitória do elite abrirá duas relíquias, exigirá uma escolha, depois abrirá três cartas raras, exigirá uma segunda escolha e só então exibirá a conclusão. A mesma resolução de cartas continuará funcionando contra todos os cinco inimigos, sem colocar o ciclo ou as regras das recompensas dentro de `main.gd`.
