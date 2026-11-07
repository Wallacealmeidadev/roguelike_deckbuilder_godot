# Ajustes Pontuais de Combate — Plano de Implementação

> **For agentic workers:** implement task-by-task with TDD and verify each task before moving on.

**Goal:** Remover a geração automática de Combo por Ataques e dar uma barra de Vida independente a cada alvo em encontros múltiplos.

**Architecture:** A resolução de cartas passará a ler somente uma declaração explícita de Combo no dado da carta; Finalização continua consumindo Combo sem alteração. Os alvos dinâmicos de duplas reutilizarão os StyleBox/fontes dos controles de Vida existentes, mantendo regra e estado em Combatente/EncontroCombate e apenas refletindo os valores em main.gd.

**Tech Stack:** Godot 4.7.2, GDScript tipado, cenas headless e capturas GL Compatibility.

**Spec:** C:\Users\Wallace\.codex\attachments\884d185b-ee20-489c-86a5-94c6fa3e4667\Pasted text.txt

## Global Constraints

- Não alterar bestiário, encontros, mapa, eventos, Desmanche, recompensas, relíquias ou RunState.
- Não alterar Finalização nem cartas além da declaração explícita de Combo necessária.
- Preservar seleção individual, Barreira, intenção e mão.
- Validar em 1024×576 e 1920×1080.

## Review Focus

- Ataques sem declaração explícita não alteram Combo; coberto em test_resolucao_cartas.
- Ataques com Combo explícito continuam gerando; Direto Hidráulico recebe combo: 1.
- Barra do alvo A não muda quando B recebe dano; coberto em test_bestiario_visual.
- Cura, Barreira, morte e clamp atualizam a barra correta; coberto em test_bestiario_docas e cena visual.
- Encontro solo e dupla preservam apresentação; suíte completa e capturas.

### Task 1: Regra explícita de Combo

**Files:** Modify resolucao_cartas.gd, dados_cartas.gd, tests/test_resolucao_cartas.gd.

- [ ] Adicionar asserções vermelhas: Golpe com Combo 0/2 mantém o valor; Direto Hidráulico com 0 chega a 1.
- [ ] Executar tests/test_resolucao_cartas.tscn e confirmar falha na regra antiga.
- [ ] Declarar ganha_combo: 1 somente em Direto Hidráulico.
- [ ] Calcular Combo apenas quando dados.has("ganha_combo"); remover o incremento implícito para todo Ataque.
- [ ] Reexecutar o teste e depois a suíte.

### Task 2: Barra de Vida individual nos alvos múltiplos

**Files:** Modify main.gd, tests/test_bestiario_docas.gd, tests/test_bestiario_visual.gd.

- [ ] Adicionar testes para nós VidaBar, VidaLabel e BarreiraLabel, valores independentes e clamp após dano/cura/morte.
- [ ] Executar a cena visual e confirmar falha por ausência de barra.
- [ ] Criar os controles filhos ao instanciar cada alvo, copiando estilos do alvo único e preenchendo a área do alvo.
- [ ] Atualizar os controles em _atualizar_interface() com Vida clampada, Vida máxima e Barreira separada; mostrar 0/vida_maxima na morte.
- [ ] Reexecutar teste visual nas duas resoluções e inspecionar capturas.

### Task 3: Documentação e verificação

**Files:** Modify docs/GAME_DESIGN.md, docs/DECISOES.md, docs/STATUS.md.

- [ ] Remover a afirmação antiga de que todo Ataque gera Combo.
- [ ] Registrar a regra explícita e as capturas.
- [ ] Executar importação headless, git diff --check e suíte completa.

