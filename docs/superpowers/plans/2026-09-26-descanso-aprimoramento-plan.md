# Descanso e aprimoramento Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Integrar uma tela de descanso jogável ao mapa, com recuperação de `+8` limitada à Vida máxima e aprimoramento confirmado de uma cópia de carta não aprimorada.

**Architecture:** Manter `main.gd` como orquestrador do fluxo e criar `DescansoRun` como componente puro das regras de elegibilidade, cura e transformação de cópia. Criar um overlay próprio para a apresentação, emitindo intenções de UI para `main.gd`; a carta compartilhada receberá apenas o modo visual necessário para seleção/comparação sem reutilizar seleção de combate.

**Tech Stack:** Godot 4.7.2, GDScript tipado, cenas `.tscn`, `PanelContainer`, `ScrollContainer`, `HBoxContainer`/`VBoxContainer`, componentes de `ui_hq_v1`.

**Spec:** `docs/superpowers/specs/2026-09-26-descanso-aprimoramento-design.md`

## Global Constraints

- Preservar o mapa, combate, recompensas comum/elite, eventos e Brecha.
- Recuperar usa `+8` de Vida e nunca ultrapassa a Vida máxima.
- Toda cópia sem o sufixo interno `#aprimorado` é elegível.
- O aprimoramento soma `+3` ao primeiro efeito principal (`valor`, ou `barreira` quando não houver `valor`) e mantém efeitos secundários.
- A confirmação de uma ação de descanso ocorre uma única vez por nó.
- Usar Bangers em títulos/ações, Barlow em efeitos e estados HQ corrigidos em foco/hover.
- Validar em 1024×576, 1280×720 e 1920×1080 com Godot 4.7.2 Compatibility.

## Review Focus

- Quatro cópias iguais: somente o índice escolhido recebe `#aprimorado`; cobrir em `tests/test_descanso_run.gd`.
- Carta já aprimorada: não aparece na seleção nem pode ser confirmada novamente; cobrir no mesmo teste.
- Vida cheia e cura parcial: recuperação fica indisponível ou aplica somente o delta efetivo; cobrir no teste de fluxo.
- Clique rápido em Recuperar/Confirmar: apenas uma mutação e uma transição; cobrir em `tests/test_ciclo_descanso.gd`.
- Redução de viewport: seleção/comparação continuam dentro da área segura e com foco acessível; cobrir em `tests/test_apresentacao_descanso.gd`.

---

### Task 1: Regras puras de descanso e cópia aprimorada

**Files:**
- Create: `descanso_run.gd`
- Create: `tests/test_descanso_run.gd`
- Create: `tests/test_descanso_run.tscn`

**Interfaces:**
- Consumes: `baralho_run: Array[String]`, `CARTAS` de `dados_cartas.gd`, Vida atual/máxima.
- Produces: `DescansoRun.CURA_BASE`, `DescansoRun.BONUS_APRIMORAMENTO`, `vida_a_recuperar(vida_atual, vida_maxima) -> int`, `cartas_elegiveis(baralho_run) -> Array[Dictionary]`, `dados_aprimorados(id_carta, dados) -> Dictionary`, `aplicar_melhoria(baralho_run, indice) -> bool`.

- [ ] **Step 1: Write the failing tests** para `+8` limitado, Vida cheia, índices de cópias repetidas, carta já aprimorada excluída, cálculo antes/depois e mutação somente do índice confirmado.
- [ ] **Step 2: Run the focused scene** com Godot 4.7.2 e confirmar falha por ausência de `DescansoRun`.
- [ ] **Step 3: Implementar `descanso_run.gd`** como `RefCounted` puro; interpretar somente o sufixo `#aprimorado`, preservar tokens não escolhidos e duplicar os dicionários de dados antes de aplicar `+3`.
- [ ] **Step 4: Rodar `tests/test_descanso_run.tscn`** e confirmar que todas as regras puras passam.

### Task 2: Dados efetivos no baralho e na mão

**Files:**
- Modify: `main.gd` nas funções de criação de carta, resolução, consulta do baralho e preparação do combate.
- Modify: `baralho_combate.gd` somente se necessário para manter tokens de carta intactos.
- Modify: `tests/test_ciclo_run.gd` e/ou criar `tests/test_persistencia_aprimoramento.gd`.

**Interfaces:**
- Consumes: `DescansoRun` e tokens `id`/`id#aprimorado`.
- Produces: helpers tipados em `main.gd` para obter identificador-base e dados efetivos; o restante do combate continua recebendo strings.

- [ ] **Step 1: Escrever o teste de regressão** que coloca `golpe#aprimorado` no `baralho_run`, inicia o próximo combate, verifica a descrição/valor `9` na mão e confirma resolução com o valor aumentado.
- [ ] **Step 2: Executar o teste e confirmar RED** porque os acessos atuais usam o token completo como chave de `CARTAS`.
- [ ] **Step 3: Implementar helpers centralizados** para resolver o id-base e aplicar dados efetivos; usar esses helpers em `_criar_carta_na_mao`, `_jogar_carta`, `_mostrar_consulta_baralho` e textos de interface.
- [ ] **Step 4: Rodar o teste focado e a regressão de combate**; confirmar que tokens comuns, recompensas e cartas sem melhoria permanecem inalterados.

### Task 3: Componente visual do overlay de descanso

**Files:**
- Create: `descanso_overlay.gd`
- Create: `descanso_overlay.tscn`
- Modify: `main.tscn` para instanciar o overlay e fornecer fundo/tema compartilhados.
- Modify: `carta.tscn` e `botao_carta.gd` para o modo de seleção/comparação do descanso e identificação de cópia.
- Test: `tests/test_apresentacao_descanso.gd`, `tests/test_apresentacao_descanso.tscn`.

**Interfaces:**
- Consumes: dados dinâmicos enviados pelo `main.gd`; instâncias existentes de `carta.tscn`; estilos HQ de painel, botão, tooltip, ícones de Vida/Descanso/Força.
- Produces: sinais `recuperar_solicitado`, `aprimorar_solicitado`, `carta_selecionada(indice)`, `voltar_solicitado`, `confirmar_solicitado(indice)`, `continuar_solicitado`.

- [ ] **Step 1: Escrever testes de árvore e estados visuais** verificando cabeçalho, dois painéis, textos reais, símbolos separados, foco, containers, rolagem, comparação e botões inferiores.
- [ ] **Step 2: Rodar a cena de apresentação e confirmar RED** pela ausência do overlay/nós.
- [ ] **Step 3: Montar `descanso_overlay.tscn`** com quatro estados: inicial, seleção, comparação e resultado; usar margens internas reais e reservar símbolos provisórios do kit sem interceptar mouse.
- [ ] **Step 4: Implementar `descanso_overlay.gd`** para renderizar dados recebidos, emitir sinais sem alterar o baralho e restaurar foco ao voltar.
- [ ] **Step 5: Ajustar `carta.tscn`/`botao_carta.gd`** para um modo não-combate que não mostra `SELECIONADA`, não altera o grupo de combate, não escala vizinhas e exibe o número da cópia apenas na seleção.
- [ ] **Step 6: Rodar a apresentação nas três resoluções** e confirmar que títulos, efeitos, tooltips, comparação e `VOLTAR/CONFIRMAR/Continuar` permanecem dentro das áreas seguras.

### Task 4: Integração no mapa e proteção de uma ação

**Files:**
- Modify: `main.gd` em `_ao_selecionar_no_mapa`, `_avancar_roteiro`, limpeza de overlays e handlers de descanso.
- Modify: `main.tscn` somente para referências/conexões do overlay.
- Create: `tests/test_ciclo_descanso.gd`
- Create: `tests/test_ciclo_descanso.tscn`

**Interfaces:**
- Consumes: sinais do `DescansoOverlay`; `DescansoRun`; `mapa_ativo`, `mapa_no_atual`, `baralho_run`, `jogador_combate`.
- Produces: fluxo `mapa -> descanso -> ação ou seleção -> resultado -> mapa`, sem alterar `mapa_no_atual` ou avançar duas vezes.

- [ ] **Step 1: Escrever testes RED** para abrir o descanso pelo nó real, curar uma vez, bloquear a segunda ação, voltar da seleção sem mutar e confirmar uma melhoria.
- [ ] **Step 2: Executar o ciclo e confirmar RED** porque o mapa ainda mostra a mensagem provisória.
- [ ] **Step 3: Integrar abertura, handlers e retorno**; aplicar cura com `clampi`, substituir somente o token escolhido e desabilitar todas as ações após a resolução.
- [ ] **Step 4: Testar cliques rápidos e foco**; confirmar que `Continuar` não recebe o mesmo clique da escolha e que o foco segue para o próximo controle disponível.
- [ ] **Step 5: Rodar os testes de eventos, recompensas e combate** para garantir que o novo overlay não fica visível em outros estados.

### Task 5: Previews reais, captura e documentação

**Files:**
- Create: `preview_descanso.gd` e cenas auxiliares para estado inicial, seleção, comparação e resultado determinísticos.
- Modify: `docs/STATUS.md`.
- Modify: `docs/DECISOES.md` se a regra experimental `+3` precisar ser registrada como decisão de implementação.

- [ ] **Step 1: Criar previews que chamem o overlay pelo fluxo real** usando um baralho determinístico com cópias iguais e Vida parcial/cheia.
- [ ] **Step 2: Gerar e inspecionar capturas** em 1024×576, 1280×720 e 1920×1080 para inicial, seleção, comparação e resultado; repetir com foco de teclado.
- [ ] **Step 3: Executar a suíte completa** de `tests/*.tscn`, importação headless e `git diff --check`.
- [ ] **Step 4: Registrar no `STATUS.md`** arquivos, regras implementadas, comandos realmente executados, símbolos provisórios e qualquer lacuna visual restante.

