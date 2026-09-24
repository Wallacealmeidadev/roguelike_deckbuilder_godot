# Arquitetura genérica de combate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extrair progressivamente as regras comuns de `main.gd` para componentes genéricos de combate, preservando exatamente o comportamento atual do protótipo.

**Architecture:** `Combatente` será o modelo comum de Vida, Barreira e estados. `BaralhoCombate` cuidará das pilhas temporárias. `InimigoCombate` cuidará das intenções e do padrão de ações, sem mencionar Drone. `main.gd` permanecerá como orquestrador da interface, da run e das transições até a resolução de cartas ser extraída.

**Tech Stack:** Godot 4.7.2, GDScript tipado, `RefCounted` para modelos sem nó visual, cenas `.tscn` headless para testes.

**Spec:** `docs/superpowers/specs/2026-09-23-arquitetura-combatentes-design.md`

## Global Constraints

- Preservar o comportamento atual: dois combates, seis recompensas, Energia, Combo, Juntas, estados e ciclo determinístico do inimigo.
- Regras comuns usam papéis (`Combatente`, `Jogador`, `Inimigo`), nunca nomes de Vega ou Drone.
- Cada estado deve ter uma única fonte de verdade; adaptadores temporários apenas delegam.
- Modelos de regra não dependem de nós visuais, botões ou Labels.
- Usar GDScript tipado compatível com Godot 4.7.2.
- Não criar novos nós visuais na primeira etapa.
- Não alterar números, custos, composição do baralho, recompensas ou ciclo de intenções durante a refatoração.
- Este workspace não é um repositório Git; não criar commits fictícios. Cada tarefa registra seus arquivos e verificações no `STATUS.md` ao final do plano.

## Review Focus

- Golpe com Exposto e Barreira: o modificador deve ser aplicado antes da Barreira, e a carga deve ser consumida mesmo quando a Barreira absorve todo o dano. Teste: Task 1.
- Rajada com Enfraquecido parcial: cada golpe deve consumir sua própria carga, inclusive quando apenas o primeiro golpe ainda está enfraquecido. Teste: Task 1 e Task 4.
- Compra quando a pilha esvazia: o descarte deve ser embaralhado somente quando uma compra exigir, sem perder identificadores. Teste: Task 2.
- Morte durante uma Rajada: a resolução deve interromper os golpes observáveis depois da derrota, sem mudar a intenção já anunciada. Teste: Task 4.
- Recompensa e reinício: escolher Brecha ou Pulso deve manter a Vida e adicionar uma única carta ao baralho da run; iniciar combate deve limpar somente o estado temporário. Teste: Task 5.

---

### Task 1: Modelo genérico `Combatente`

**Files:**
- Create: `combatente.gd`
- Create: `tests/test_combatente.gd`
- Create: `tests/test_combatente.tscn`
- Modify: `docs/STATUS.md`

**Interfaces:**
- Produces `Combatente.new(vida_inicial: int)`.
- Produces `reiniciar(vida_inicial: int) -> void`.
- Produces `aplicar_barreira(valor: int) -> void`.
- Produces `aplicar_exposto(cargas: int) -> void`.
- Produces `aplicar_enfraquecido(cargas: int) -> void`.
- Produces `calcular_dano_de_ataque(dano_base: int) -> int`, consumindo Enfraquecido por golpe.
- Produces `calcular_dano_recebido(dano_base: int) -> int`, consumindo Exposto por golpe.
- Produces `receber_golpe(dano_base: int) -> Dictionary` com as chaves `dano`, `absorvido`, `dano_na_vida` e `vida`.

- [ ] **Step 1: Write the failing test**

Criar uma cena de teste que instancie `Combatente` e verifique:

```gdscript
var alvo: Combatente = Combatente.new(30)
alvo.aplicar_exposto(2)
alvo.aplicar_barreira(6)
var resultado: Dictionary = alvo.receber_golpe(4)
_verificar(resultado["dano"] == 6, "Exposto deve modificar o golpe antes da Barreira")
_verificar(resultado["absorvido"] == 6, "a Barreira deve absorver o dano modificado")
_verificar(alvo.exposto == 1, "Exposto deve consumir uma carga por golpe")

var atacante: Combatente = Combatente.new(10)
atacante.aplicar_enfraquecido(2)
_verificar(atacante.calcular_dano_de_ataque(3) == 1, "Enfraquecido deve reduzir o primeiro golpe")
_verificar(atacante.calcular_dano_de_ataque(3) == 1, "Enfraquecido deve reduzir o segundo golpe")
_verificar(atacante.calcular_dano_de_ataque(3) == 3, "o dano deve voltar ao normal após consumir as cargas")
```

Adicionar também dano mínimo zero, reinicialização e Vida máxima.

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path (Get-Location) --scene res://tests/test_combatente.tscn
```

Expected: falha porque `combatente.gd` ainda não existe.

- [ ] **Step 3: Write minimal implementation**

Criar `Combatente` como `RefCounted`. `receber_golpe()` deve calcular Exposto, descontar Barreira, reduzir Vida até zero e retornar o dicionário definido na interface. `calcular_dano_de_ataque()` deve reduzir Enfraquecido até o mínimo zero e consumir uma carga por chamada.

- [ ] **Step 4: Run test to verify it passes**

Run the same Godot command. Expected: `OK: Combatente genérico` e código 0.

- [ ] **Step 5: Record the result**

Adicionar em `STATUS.md` que o modelo foi criado e que o teste headless confirmou estados e Barreira sem alterar o combate principal.

### Task 2: Migrar Vida, Barreira e estados de `main.gd`

**Files:**
- Modify: `main.gd`
- Modify: `tests/test_estados.gd`
- Modify: `tests/test_intencoes_drone.gd`
- Modify: `tests/test_juntas_retorno.gd`
- Modify: `docs/STATUS.md`

**Interfaces:**
- Consumes `Combatente` da Task 1.
- Produces `estado_jogador: Combatente` e `estado_inimigo: Combatente` como únicas fontes de estado comum.
- Mantém temporariamente as propriedades legadas `vida_jogador`, `vida_inimigo`, `barreira`, `barreira_inimigo`, `exposto_inimigo` e `enfraquecido_inimigo`, delegando para os objetos, sem duplicar valores.

- [ ] **Step 1: Write the failing integration test**

Estender `test_combatente.gd` ou criar uma verificação em `test_estados.gd` que confirme que `main.gd` expõe `estado_jogador` e `estado_inimigo`, e que jogar um Golpe com Exposto usa o mesmo objeto que a interface atualiza.

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path (Get-Location) --scene res://tests/test_estados.tscn
```

Expected: falha porque `main.gd` ainda usa somente variáveis escalares.

- [ ] **Step 3: Write minimal implementation**

Adicionar os dois objetos e propriedades delegadoras. Migrar `_receber_dano()`, `_causar_dano_no_inimigo()`, `_calcular_dano_do_drone()` e `_calcular_dano_no_inimigo()` para chamar `Combatente`. Remover somente depois da migração as cópias escalares que não forem mais consumidoras.

- [ ] **Step 4: Run the focused and regression tests**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path (Get-Location) --scene res://tests/test_combatente.tscn
& $godot --headless --path (Get-Location) --scene res://tests/test_estados.tscn
& $godot --headless --path (Get-Location) --scene res://tests/test_juntas_retorno.tscn
& $godot --headless --path (Get-Location) --scene res://tests/test_intencoes_drone.tscn
```

Expected: todas terminam com código 0 e os valores observados do protótipo permanecem iguais.

- [ ] **Step 5: Record the result**

Registrar em `STATUS.md` a primeira migração para `Combatente`, distinguindo teste automatizado de validação manual.

### Task 3: Extrair `BaralhoCombate`

**Files:**
- Create: `baralho_combate.gd`
- Create: `tests/test_baralho_combate.gd`
- Create: `tests/test_baralho_combate.tscn`
- Modify: `main.gd`
- Modify: `tests/test_ciclo_run.gd`
- Modify: `docs/STATUS.md`

**Interfaces:**
- Produces `BaralhoCombate.new()`.
- Produces `preparar(baralho_run: Array[String]) -> void`.
- Produces `comprar_identificador() -> String`; retorna string vazia somente quando compra e descarte estão vazios.
- Produces `descartar_identificador(id_carta: String) -> void`.
- Produces `compra` e `descarte` como arrays tipados para leitura da interface.

- [ ] **Step 1: Write the failing test**

Testar preparação com uma cópia do baralho, compra até esvaziar, reembaralhamento do descarte, descarte de uma carta e caso de pilhas vazias. O teste deve afirmar que a lista original do baralho da run não é modificada.

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path (Get-Location) --scene res://tests/test_baralho_combate.tscn
```

Expected: falha porque `baralho_combate.gd` ainda não existe.

- [ ] **Step 3: Write minimal implementation**

Mover para o componente as operações atualmente feitas por `_preparar_pilhas_do_combate()`, `_comprar_cartas()` e `_descartar_carta()`. A mão visual continua em `main.gd`, que chama `comprar_identificador()` e cria os botões.

- [ ] **Step 4: Run the focused and run tests**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path (Get-Location) --scene res://tests/test_baralho_combate.tscn
& $godot --headless --path (Get-Location) --scene res://tests/test_ciclo_run.tscn
```

Expected: compra, descarte, reembaralhamento e recompensa permanecem iguais.

- [ ] **Step 5: Record the result**

Registrar a extração do baralho e os testes executados no `STATUS.md`.

### Task 4: Extrair o papel genérico `InimigoCombate`

**Files:**
- Create: `inimigo_combate.gd`
- Create: `tests/test_inimigo_combate.gd`
- Create: `tests/test_inimigo_combate.tscn`
- Modify: `main.gd`
- Modify: `tests/test_intencoes_drone.gd`
- Modify: `tests/test_ciclo_run.gd`
- Modify: `docs/STATUS.md`

**Interfaces:**
- Produces `InimigoCombate.new(vida_inicial: int)` como extensão de `Combatente`.
- Produces `reiniciar(vida_inicial: int) -> void`.
- Produces `texto_intencao() -> String`.
- Produces `executar_intencao() -> Dictionary`, com `tipo`, `danos` quando for ataque, e `valor` quando for Barreira/preparação.
- O padrão interno continua determinístico, mas não usa o nome Drone nos métodos ou no estado.

- [ ] **Step 1: Write the failing test**

Criar o ciclo genérico com as mesmas configurações atuais e afirmar:

```gdscript
var inimigo: InimigoCombate = InimigoCombate.new(30)
_verificar(inimigo.texto_intencao().contains("Rajada: 3 × 2"), "a intenção inicial deve ser anunciada")
var acao: Dictionary = inimigo.executar_intencao()
_verificar(acao["tipo"] == "rajada", "a primeira ação deve ser uma Rajada")
_verificar(acao["danos"] == [3, 3], "a Rajada deve conter dois golpes")
_verificar(inimigo.texto_intencao().contains("Blindagem"), "o próximo passo deve ser Blindagem")
```

Cobrir também Sobrecarga, Marca, anúncio dos valores `5 × 2` e `4 × 2`, e consumo dos bônus após a Rajada.

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path (Get-Location) --scene res://tests/test_inimigo_combate.tscn
```

Expected: falha porque `inimigo_combate.gd` ainda não existe.

- [ ] **Step 3: Write minimal implementation**

Mover o ciclo de intenções para o componente. `main.gd` executará a ação retornada e aplicará cada dano ao objeto do jogador, interrompendo a aplicação se a Vida chegar a zero. O texto da intenção será consumido pela atualização da interface.

- [ ] **Step 4: Run the focused and regression tests**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path (Get-Location) --scene res://tests/test_inimigo_combate.tscn
& $godot --headless --path (Get-Location) --scene res://tests/test_intencoes_drone.tscn
& $godot --headless --path (Get-Location) --scene res://tests/test_ciclo_run.tscn
```

Expected: o ciclo e os valores anunciados permanecem iguais, embora os métodos não tenham mais nomes de Drone.

- [ ] **Step 5: Record the result**

Registrar a extração do inimigo genérico e a preservação do ciclo no `STATUS.md`.

### Task 5: Preparar a fronteira de resolução de cartas

**Files:**
- Create: `resolucao_cartas.gd`
- Create: `tests/test_resolucao_cartas.gd`
- Create: `tests/test_resolucao_cartas.tscn`
- Modify: `main.gd`
- Modify: `tests/test_catalogo_cartas.gd`
- Modify: `tests/test_estados.gd`
- Modify: `docs/STATUS.md`

**Interfaces:**
- Produces `ResolucaoCartas` sem dependência de `Button`, `Label` ou cena.
- Recebe o identificador da carta, dados do catálogo, fonte `Combatente`, alvo `Combatente` e contexto de recursos.
- Retorna um resultado tipado por `Dictionary` com `valida`, `custo`, `dano`, `barreira`, `combo` e estados aplicados.
- A resolução de Combo e Juntas permanece fora de `Combatente` e deve continuar explicitamente ligada ao jogador/personagem.

- [ ] **Step 1: Write the failing test**

Testar que Golpe, Direto, Brecha, Pulso e Quebra-chassi produzem resultados equivalentes aos atuais sem criar botões ou alterar a mão visual.

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path (Get-Location) --scene res://tests/test_resolucao_cartas.tscn
```

Expected: falha porque `resolucao_cartas.gd` ainda não existe.

- [ ] **Step 3: Write minimal implementation**

Extrair apenas a validação e a resolução dos efeitos. A criação da carta, o descarte visual, a atualização da interface e a transição de vitória permanecem no `main.gd`.

- [ ] **Step 4: Run the full suite and editor import**

Run:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
$tests = @('test_combatente.tscn','test_baralho_combate.tscn','test_inimigo_combate.tscn','test_resolucao_cartas.tscn','test_catalogo_cartas.tscn','test_estados.tscn','test_juntas_retorno.tscn','test_intencoes_drone.tscn','test_ciclo_run.tscn')
foreach($test in $tests){ & $godot --headless --path (Get-Location) --scene ("res://tests/" + $test); if($LASTEXITCODE -ne 0){ exit $LASTEXITCODE } }
& $godot --headless --editor --path (Get-Location) --quit
exit $LASTEXITCODE
```

Expected: todos os testes e a importação terminam com código 0.

- [ ] **Step 5: Record the result**

Registrar a nova fronteira de resolução e a regressão completa no `STATUS.md`. Não marcar a arquitetura inteira como concluída se alguma etapa ainda estiver apenas planejada.

## Handoff

Este plano deve ser executado com `superpowers:executing-plans`, uma tarefa por vez, mantendo RED→GREEN e lendo a saída de cada comando. O método recomendado é execução nativa nesta conversa, porque as tarefas compartilham interfaces e o workspace não possui ferramenta de subagentes nem repositório Git para commits.
