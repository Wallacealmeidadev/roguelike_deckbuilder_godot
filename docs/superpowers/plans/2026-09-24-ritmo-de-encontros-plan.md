# Ritmo intercalado de combates e eventos — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** substituir a sequência fixa de três combates por um roteiro que intercale cinco combates e quatro eventos narrativos antes do chefe.

**Architecture:** `DadosEncontros` será o catálogo único; `SeletorEncontros` controlará eventos sem repetição; `RoteiroRun` controlará apenas a ordem das categorias. `ResolucaoEventos` devolverá consequências estruturadas sem acessar a cena. `main.gd` ficará responsável por sinais, visibilidade e transições, reutilizando os componentes de combate existentes.

**Tech Stack:** Godot 4.7.2, GDScript tipado, cenas `.tscn`, testes headless por cena, sem dependências externas.

**Spec:** `docs/superpowers/specs/2026-09-24-ritmo-de-encontros-design.md`

## Global Constraints

- O roteiro antes do chefe é exatamente `combate comum → evento → combate comum → evento → elite → evento → combate comum → evento → combate comum`.
- O catálogo terá quatro combates comuns, um elite e cinco eventos narrativos.
- A Unidade de Contenção permanece na terceira posição de combate e não participa do sorteio comum.
- Eventos não recebem automaticamente a recompensa comum de combate.
- Um combate iniciado por evento retorna ao mesmo ponto do roteiro sem abrir recompensa comum automaticamente.
- Vida, baralho e relíquias persistem; mão, compra, descarte, Energia, Combo, Barreira e turno são reiniciados ao iniciar combate.
- O chefe não será implementado nesta etapa nem sorteado antes do estágio final reservado.
- Valores de eventos são provisórios e não constituem balanceamento final.
- `main.gd` orquestra a cena, mas não deve conter o catálogo completo nem regras narrativas por identificador.

## Review Focus

- Evento não avança duas vezes nem se repete na mesma run: testar nas Tasks 1, 2 e 5.
- Combate especial não abre recompensa comum e retorna ao evento: testar na Task 6.
- Combate, evento, recompensa e resultado não ficam visíveis simultaneamente: testar na Task 4.
- Opção inválida não altera Vida, baralho, relíquias ou roteiro: testar na Task 3.
- Elite permanece no terceiro combate mesmo com eventos sorteados: testar nas Tasks 2 e 5.

---

### Task 1: Catálogo de encontros e seleção sem repetição

**Files:**
- Create: `dados_encontros.gd`
- Create: `seletor_encontros.gd`
- Create: `tests/test_catalogo_encontros.gd`, `tests/test_catalogo_encontros.tscn`
- Create: `tests/test_seletor_encontros.gd`, `tests/test_seletor_encontros.tscn`

**Interfaces:**
- Produces `DadosEncontros.identificadores()`, `identificadores_por_tipo(tipo: String)`, `obter(id: String)`.
- Produces `SeletorEncontros.reiniciar()`, `sortear_disponivel() -> String` e `registrar_encontrado(id: String) -> bool`.

- [ ] **Step 1: Escrever o teste falho do catálogo**

O teste deve exigir dez entradas: quatro `combate`, uma `elite` e cinco `evento`. Também deve conferir referências de inimigo/evento e cópias profundas.

```gdscript
var ids: Array[String] = DadosEncontros.identificadores()
_verificar(ids.size() == 10, "o catálogo deve conter dez encontros")
_verificar(DadosEncontros.identificadores_por_tipo("combate").size() == 4, "quatro combates comuns")
_verificar(DadosEncontros.identificadores_por_tipo("evento").size() == 5, "cinco eventos")
_verificar(
	DadosEncontros.obter("unidade_contencao_portuaria")["tipo"] == "elite",
	"a Unidade deve ser elite"
)
_verificar(
	DadosEncontros.obter("valvula_vapor_contaminado")["evento_id"] == "valvula_vapor_contaminado",
	"a válvula deve apontar para seu evento"
)
```

- [ ] **Step 2: Executar RED**

Run: `Godot --headless --path . --scene tests/test_catalogo_encontros.tscn`.

Expected: FAIL porque `DadosEncontros` ainda não existe.

- [ ] **Step 3: Implementar o catálogo mínimo**

Criar `dados_encontros.gd` com `class_name DadosEncontros`, `TIPOS = ["combate", "elite", "evento"]` e estas dez entradas: `drone_seguranca`, `estivador_cibernetico`, `torreta_contencao`, `guarda_portuario`, `unidade_contencao_portuaria`, `valvula_vapor_contaminado`, `carga_abandonada`, `operario_ferido`, `ladrao_de_cartas` e `fiscalizacao_corporativa`.

Cada combate comum deve conter `tipo = "combate"` e `inimigo_id` correspondente; o elite deve conter `tipo = "elite"`; cada evento deve conter `tipo = "evento"`, `evento_id`, nome e descrição curta. `obter()` deve retornar `duplicate(true)`.

- [ ] **Step 4: Implementar e testar o seletor**

Criar `SeletorEncontros` seguindo `SeletorInimigos`: manter `disponiveis` e `encontrados`, sortear apenas candidatos ainda não registrados, rejeitar identificadores ausentes/duplicados e retornar `""` quando o pool acabar. O teste deve confirmar cinco eventos distintos, esgotamento seguro e reinício.

- [ ] **Step 5: Rodar e commitar**

Expected: `OK: catálogo de encontros`, `OK: seletor de encontros` e regressão atual verde.

Commit: `git add dados_encontros.gd seletor_encontros.gd tests/test_catalogo_encontros.gd tests/test_catalogo_encontros.tscn tests/test_seletor_encontros.gd tests/test_seletor_encontros.tscn; git commit -m "feat: add encounter catalog and selector"`.

### Task 2: Roteiro intercalado da run

**Files:**
- Create: `roteiro_run.gd`
- Create: `tests/test_roteiro_run.gd`, `tests/test_roteiro_run.tscn`

**Interfaces:**
- Produces `RoteiroRun.iniciar()`, `etapa_atual() -> String`, `indice_etapa`, `tem_proxima_etapa()`, `avancar() -> bool` e `concluido() -> bool`.

- [ ] **Step 1: Escrever o teste falho**

Exigir a sequência exata:

```gdscript
var esperado: Array[String] = [
	"combate_comum", "evento", "combate_comum", "evento",
	"elite", "evento", "combate_comum", "evento", "combate_comum"
]
var roteiro: RoteiroRun = RoteiroRun.new()
roteiro.iniciar()
for tipo in esperado:
	_verificar(roteiro.etapa_atual() == tipo, "etapa incorreta")
	roteiro.avancar()
_verificar(roteiro.concluido(), "o roteiro pré-chefe deve terminar")
```

- [ ] **Step 2: Executar RED**

Expected: FAIL porque `RoteiroRun` ainda não existe.

- [ ] **Step 3: Implementar o roteiro**

Usar `ETAPAS_PRE_CHEFE` com as nove categorias aprovadas. `iniciar()` define `indice_etapa = 0`; `etapa_atual()` retorna vazio depois do fim; `avancar()` nunca ultrapassa o tamanho; `concluido()` identifica o fim.

- [ ] **Step 4: Testar limites**

Confirmar que `iniciar()` após o fim volta à primeira etapa, que `avancar()` no fim retorna `false` e que o elite continua na terceira ocorrência de combate.

- [ ] **Step 5: Rodar regressão e commitar**

Commit: `git add roteiro_run.gd tests/test_roteiro_run.gd tests/test_roteiro_run.tscn; git commit -m "feat: add interleaved run route"`.

### Task 3: Dados e resolução de eventos

**Files:**
- Create: `dados_eventos.gd`
- Create: `resolucao_eventos.gd`
- Create: `tests/test_resolucao_eventos.gd`, `tests/test_resolucao_eventos.tscn`

**Interfaces:**
- Produces `DadosEventos.obter(id_evento: String) -> Dictionary` e `ResolucaoEventos.resolver(id_evento: String, id_opcao: String, jogador: JogadorCombate) -> Dictionary`.

- [ ] **Step 1: Escrever testes RED**

Cobrir `operario_ferido/ajudar` com `vida_delta = -10`, `valvula_vapor_contaminado/desligar` com `tipo = "combate_especial"`, e evento/opção inválidos sem mutação.

```gdscript
var jogador: JogadorCombate = JogadorCombate.new(40, 4, 5)
var ajuda: Dictionary = ResolucaoEventos.resolver("operario_ferido", "ajudar", jogador)
_verificar(ajuda["valida"], "ajudar deve ser válida")
_verificar(ajuda["vida_delta"] == -10, "ajudar custa 10 de Vida")

var valvula: Dictionary = ResolucaoEventos.resolver(
	"valvula_vapor_contaminado", "desligar", jogador
)
_verificar(valvula["tipo"] == "combate_especial", "válvula deve iniciar combate")

var invalida: Dictionary = ResolucaoEventos.resolver("operario_ferido", "ausente", jogador)
_verificar(not invalida["valida"], "opção inválida deve ser rejeitada")
_verificar(jogador.estado.vida == 40, "opção inválida não altera Vida")
```

- [ ] **Step 2: Executar RED**

Expected: FAIL porque os recursos ainda não existem.

- [ ] **Step 3: Criar `DadosEventos`**

Cadastrar cinco eventos e opções explícitas: válvula (`desligar`, `contornar`), carga (`vasculhar`, `seguir`), operário (`ajudar`, `ignorar`), ladrão (`entregar_carta`, `enfrentar`) e fiscalização (`cooperar`, `se_esconder`, `confrontar`). Retornar cópias profundas.

- [ ] **Step 4: Criar `ResolucaoEventos` puro**

Todo resultado deve conter `valida`, `tipo`, `texto`, `vida_delta`, `id_inimigo` e `concluido`. Implementar: operário/ajudar com `vida_delta = -10`; operário/ignorar como consequência textual; válvula/desligar como combate especial contra `torreta_contencao`; ladrão/enfrentar e fiscalização/confrontar como combate especial contra `guarda_portuario`; as demais opções como conclusão explícita sem mutação silenciosa.

Não acessar `Button`, `Label`, `main.tscn` nem alterar diretamente o jogador no resolvedor. `vida_delta` será aplicado pelo orquestrador.

- [ ] **Step 5: Rodar testes e commitar**

Expected: `OK: resolução de eventos` e regressão anterior verde.

Commit: `git add dados_eventos.gd resolucao_eventos.gd tests/test_resolucao_eventos.gd tests/test_resolucao_eventos.tscn; git commit -m "feat: add structured event resolution"`.

### Task 4: Painel de evento e exclusividade visual

**Files:**
- Modify: `main.tscn`
- Modify: `main.gd`
- Create: `tests/test_apresentacao_eventos.gd`, `tests/test_apresentacao_eventos.tscn`

**Interfaces:**
- Produces an `EventoOverlay` with `EventoTitulo`, `EventoTexto`, `EventoOpcoes/EventoOpcao1`, `EventoOpcao2`, `EventoOpcao3`, `EventoResultado` and `EventoContinuar`.
- Produces `_mostrar_evento(id_evento: String)` and `_ocultar_evento()` in `main.gd`.

- [ ] **Step 1: Escrever o teste RED da interface**

O teste deve confirmar que o overlay começa oculto, `_mostrar_evento("operario_ferido")` mostra título e duas opções, esconde `Recompensas` e `RecompensaElite`, desabilita cartas/alvos e que `_ocultar_evento()` restaura o estado de combate.

```gdscript
var jogo: Node = (load("res://main.tscn") as PackedScene).instantiate()
get_tree().root.add_child(jogo)
await get_tree().process_frame

_verificar(not jogo.get_node("EventoOverlay").visible, "overlay começa oculto")
jogo.call("_mostrar_evento", "operario_ferido")
_verificar(jogo.get_node("EventoOverlay").visible, "overlay aparece")
_verificar(not jogo.get_node("Recompensas").visible, "recompensa comum esconde")
_verificar(not jogo.get_node("RecompensaElite").visible, "recompensa do elite esconde")
_verificar(jogo.get_node("EventoOpcao1").visible, "primeira opção aparece")
_verificar(jogo.get_node("EventoOpcao3").visible == false, "terceira opção fica oculta")
jogo.call("_ocultar_evento")
_verificar(not jogo.get_node("EventoOverlay").visible, "overlay esconde")
jogo.queue_free()
```

- [ ] **Step 2: Executar RED**

Expected: FAIL porque o painel e os métodos ainda não existem.

- [ ] **Step 3: Criar a estrutura visual**

Adicionar um `Control` `EventoOverlay`, inicialmente invisível, com `z_index = 10`, fundo bloqueador e conteúdo central:

```text
EventoOverlay
├── Fundo
└── Conteudo
    ├── EventoTitulo
    ├── EventoTexto
    ├── EventoOpcoes
    │   ├── EventoOpcao1
    │   ├── EventoOpcao2
    │   └── EventoOpcao3
    ├── EventoResultado
    └── EventoContinuar
```

`EventoContinuar` começa oculto e os três botões terão tamanho mínimo 220 x 60.

- [ ] **Step 4: Implementar helpers de visibilidade**

Adicionar referências `@onready`. `_mostrar_evento()` deve carregar nome, texto e opções de `DadosEventos`, esconder recompensas e desabilitar controles de combate. `_ocultar_evento()` deve esconder o overlay e o botão de continuar. Conectar os botões por índice, como as recompensas atuais.

- [ ] **Step 5: Rodar teste e regressão visual**

Expected: `OK: apresentação de eventos`; o teste de apresentação existente continua verde.

- [ ] **Step 6: Commitar**

Commit: `git add main.tscn main.gd tests/test_apresentacao_eventos.gd tests/test_apresentacao_eventos.tscn; git commit -m "feat: add event encounter panel"`.

### Task 5: Integrar o roteiro ao fluxo da run

**Files:**
- Modify: `main.gd`
- Modify: `tests/test_ciclo_run.gd`
- Create: `tests/test_ciclo_encontros.gd`, `tests/test_ciclo_encontros.tscn`

**Interfaces:**
- Consumes `RoteiroRun`, `SeletorEncontros`, `DadosEncontros`, `DadosEventos` e o painel da Task 4.
- Produces `_iniciar_etapa_atual()`, `_avancar_roteiro()`, `_resolver_evento_atual()` e `etapa_evento_atual`.

- [ ] **Step 1: Escrever testes RED do fluxo**

Verificar: etapa 0 inicia combate comum; recompensa comum avança para evento; evento concluído avança para combate; elite aparece na terceira posição de combate; após a recompensa dupla do elite a etapa seguinte é evento; ao final das nove posições o jogo para antes do chefe reservado.

- [ ] **Step 2: Executar RED**

Expected: FAIL porque `main.gd` ainda usa `TOTAL_COMBATES = 3` como encerramento e inicia somente combates.

- [ ] **Step 3: Adicionar estado do roteiro sem remover pontes legadas**

Adicionar `roteiro_run`, `seletor_eventos`, `etapa_evento_atual` e `encontro_especial_pendente`. No `_ready()`, reiniciar seletores e iniciar o roteiro.

`_iniciar_etapa_atual()` deve selecionar combate comum, evento ou elite conforme `roteiro_run.etapa_atual()`. No fim do roteiro pré-chefe, mostrar estado explícito de pré-chefe sem afirmar vitória contra o boss.

- [ ] **Step 4: Adaptar recompensas e transições**

Trocar incrementos diretos de `combate_atual` em `_escolher_recompensa()` e `_ao_pular_recompensa()` por `_avancar_roteiro()`. Após a carta rara do elite, avançar para o evento seguinte em vez de concluir a run. A recompensa dupla continua obrigatória.

`_resolver_vitoria()` deve distinguir combate comum, elite e combate especial de evento. Somente o combate comum abre recompensa comum.

- [ ] **Step 5: Ligar opções de evento**

`_ao_clicar_evento(indice)` deve validar o índice e chamar `_resolver_evento_atual(id_opcao)`. O resolvedor retorna o texto e o tipo da consequência; o orquestrador aplica `vida_delta`, mostra `EventoResultado` e libera `EventoContinuar` quando não houver combate especial.

`_avancar_roteiro()` deve ocultar o evento, avançar uma única vez e iniciar a etapa seguinte.

- [ ] **Step 6: Implementar o estado de pré-chefe**

Quando as nove posições terminarem, usar uma mensagem explícita como `RUN PRÉ-CHEFE\nA rota até o chefe foi concluída.` e mostrar reinício. Não usar `RUN CONCLUÍDA` nem afirmar que o chefe foi derrotado.

- [ ] **Step 7: Rodar testes e commitar**

Expected: fluxo de nove posições PASS, cinco combates contados, elite na terceira posição de combate e todos os testes antigos verdes.

Commit: `git add main.gd tests/test_ciclo_run.gd tests/test_ciclo_encontros.gd tests/test_ciclo_encontros.tscn; git commit -m "feat: integrate interleaved encounter route"`.

### Task 6: Consequências com combate especial e retorno ao roteiro

**Files:**
- Modify: `main.gd`
- Modify: `tests/test_ciclo_encontros.gd`
- Modify: `tests/test_resolucao_eventos.gd`

**Interfaces:**
- Consumes resultado `tipo = "combate_especial"` e `id_inimigo`.
- Produces retorno ao evento após vitória especial e derrota normal quando a Vida chega a zero.

- [ ] **Step 1: Escrever teste RED**

Resolver `valvula_vapor_contaminado/desligar`, iniciar a Torreta, confirmar que a recompensa comum não aparece, zerar a Vida do inimigo e confirmar que o texto de consequência do evento volta a aparecer. Confirmar também que a derrota não avança o roteiro.

- [ ] **Step 2: Executar RED**

Expected: FAIL porque o resultado especial ainda é tratado como conclusão simples.

- [ ] **Step 3: Encaminhar combate especial**

Quando o resultado for `combate_especial`, guardar `encontro_especial_pendente` e `id_inimigo_especial`, iniciar o inimigo pelo catálogo existente e esconder o overlay. Não registrar o inimigo no seletor comum e não abrir recompensa comum.

- [ ] **Step 4: Retornar após vitória**

No caminho de vitória, verificar primeiro `encontro_especial_pendente`. Limpar o estado, mostrar a consequência e liberar `EventoContinuar`. No caminho de derrota, usar o resultado de derrota e limpar o estado para impedir retorno.

- [ ] **Step 5: Rodar regressão e commitar**

Expected: retorno e derrota PASS, sem alteração nas regras de cartas e recompensas comuns.

Commit: `git add main.gd tests/test_ciclo_encontros.gd tests/test_resolucao_eventos.gd; git commit -m "feat: support event-triggered combat return"`.

### Task 7: Validação, documentação e revisão final

**Files:**
- Modify: `docs/STATUS.md`
- Modify: `docs/DECISOES.md` only if a provisional consequence changes during testing

- [ ] **Step 1: Rodar a suíte completa**

Executar cada `tests/*.tscn` com Godot 4.7.2 em modo headless, importar o projeto com `--editor --quit`, executar `git diff --check` e confirmar ausência de `SCRIPT ERROR`, `ERROR:` e `FALHA:`.

- [ ] **Step 2: Atualizar o status com fatos observados**

Registrar arquivos criados, sequência implementada, distinção entre testes automatizados e validação manual, estado provisório das consequências e próximo passo do chefe/mapa.

- [ ] **Step 3: Fazer revisão de escopo**

Confirmar que não foram adicionados chefe, mapa visual, caminhos ramificados, arte final ou balanceamento definitivo. Confirmar que catálogo e resolução permanecem fora da `main.gd`.

- [ ] **Step 4: Commitar documentação**

Commit: `git add docs/STATUS.md docs/DECISOES.md; git commit -m "docs: record interleaved encounters"`.

## Self-review do plano

- A especificação foi coberta por Tasks 1–6: catálogo, seleção, roteiro, resolução, painel, integração e combate especial.
- O catálogo de dez entradas não é confundido com as nove posições pré-chefe; a diferença está explícita na Task 1 e na Task 2.
- O elite continua na terceira posição de combate; o roteiro não depende de nomes exibidos na interface.
- Os efeitos ainda não aprovados de recompensa da carga e remoção de carta não serão inventados nesta etapa; a fronteira de resolução os deixa explícitos como conclusões provisórias.
- A exclusividade visual é testada antes da integração completa para evitar a sobreposição observada na recompensa do elite.
- Cada componente criado possui teste focalizado e cada task termina com regressão ou commit.

## Critério de conclusão

O incremento está pronto para validação manual quando:

1. o roteiro executa nove posições na ordem aprovada;
2. cinco combates são contados antes do ponto reservado ao chefe;
3. quatro eventos são escolhidos sem repetição;
4. o elite continua sendo o terceiro combate;
5. eventos e combates não ficam visualmente ativos ao mesmo tempo;
6. consequências inválidas não alteram o estado da run;
7. combate especial retorna ao evento sem recompensa comum automática;
8. a suíte completa e a importação headless terminam com código 0;
9. o editor ainda será usado pelo usuário para validar leitura e ritmo visual.
