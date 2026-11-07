# Vega Rig Segmentado Implementation Plan

> For agentic workers: execute this plan task by task, using `superpowers:test-driven-development` before implementation code and `superpowers:verification-before-completion` before claiming completion.

**Goal:** Criar e validar uma versão candidata da Vega com braço superior, antebraço e punho independentes nos dois lados, usando `Skeleton2D`, `Bone2D` e `AnimationPlayer`, preservando o contrato chamado pelo combate e sem alterar regras, input ou progressão.

**Architecture:** A cena atual permanece como fallback. A candidata será criada em paralelo, com seis PNGs transparentes de segmentos, uma hierarquia nativa de ossos e um script próprio que mantém `estado_animacao`, `socar()`, `receber_dano()` e `reiniciar()`. Um preview isolado será a primeira superfície de inspeção; somente após os testes, capturas e aprovação manual a instância de combate será trocada de forma controlada.

**Tech Stack:** Godot 4.7.2, renderer GL Compatibility, GDScript tipado, `Control`, `Node2D`, `Sprite2D`, `Skeleton2D`, `Bone2D`, `AnimationPlayer`, PNG com transparência e cenas de teste executadas pelo SceneTree.

**Spec:** `docs/superpowers/specs/2026-10-03-vega-rig-segmentado-design.md`

## Global Constraints

- Preservar `vega_animada/vega_animada.tscn` e `vega_animada/vega_animada.gd` até a aprovação da candidata.
- Não alterar `main.gd` além da troca final e explícita do recurso da cena, se a candidata for aprovada.
- Preservar a API pública `estado_animacao`, `socar()`, `receber_dano()` e `reiniciar()`.
- A arte deve ignorar input próprio para que o botão-pai `Jogador` continue recebendo hover, foco e clique.
- Não alterar custo, dano, alvo, Energia, Vida, Barreira, Combo, turnos, run, mapa, arena ou HUD.
- Usar GDScript tipado e manter a distinção entre regra, estado de animação e apresentação.
- Não usar IK, física, ragdoll, animação procedural ou ferramenta externa de animação nesta primeira versão.
- Não declarar uma captura automatizada como aprovação visual manual; o playtest em 1024×576 e 1920×1080 continua sendo um gate separado.
- Se a separação dos braços produzir buracos, duplicação ou contornos quebrados, interromper a troca de cena e registrar o bloqueio em vez de mascará-lo com escala global.

## Review Focus

- **Arte:** cada lado possui três segmentos transparentes e a união do cotovelo não mostra buraco, braço duplicado ou torso repetido.
- **Rig:** os pivôs ficam nas articulações correspondentes; a guarda é em três quartos, com punhos fora do torso e base aberta.
- **Interrupção:** soco seguido de dano parte da pose vigente e retorna à guarda sem salto para uma pose incorreta.
- **Integração:** a candidata não intercepta input nem cria uma segunda camada de arte no campo.
- **Escala:** a silhueta permanece contida e legível em 1024×576 e 1920×1080 sem aumentar a escala global atual por compensação.

## File Map

Arquivos e recursos a criar:

- `vega_animada/pecas_articuladas/braco_superior_frente.png`
- `vega_animada/pecas_articuladas/antebraco_frente.png`
- `vega_animada/pecas_articuladas/punho_frente.png`
- `vega_animada/pecas_articuladas/braco_superior_tras.png`
- `vega_animada/pecas_articuladas/antebraco_tras.png`
- `vega_animada/pecas_articuladas/punho_tras.png`
- `vega_animada/vega_animada_segmentada.gd`
- `vega_animada/vega_animada_segmentada.tscn`
- `vega_animada/preview_vega_segmentada.gd`
- `vega_animada/preview_vega_segmentada.tscn`
- `tests/test_vega_segmentada.gd`
- `tests/test_vega_segmentada.tscn`
- `tests/capturar_vega_segmentada.gd`

Arquivos existentes a ajustar somente nos gates indicados:

- `tests/verificar_vega_animada.gd`: preservar o contrato legado e adicionar a regressão da candidata quando ela entrar no combate.
- `tests/test_composicao_combate.gd`: exigir uma única `VegaAnimada` visível depois da troca final, sem aceitar retrato estático ou segunda instância.
- `main.gd`: trocar apenas o `preload` da cena candidata no gate final; manter chamadas e fluxo atuais.
- `docs/DECISOES.md`: registrar a decisão de integração ou retorno ao fallback.
- `docs/STATUS.md`: registrar estado observado, verificações reais, evidências e próximo passo.

## Task 1: Preparar a arte segmentada e o contrato de recursos

**Files:** criar `vega_animada/pecas_articuladas/*.png` e `tests/test_vega_segmentada.gd`/`.tscn`.

1. Antes de editar o rig, conferir novamente o atlas `vega_animada/pecas.png` e selecionar a origem de cada lado. Preparar os seis PNGs transparentes em editor de imagem, preservando os contornos mecânicos e removendo qualquer duplicação de torso ou braço completo.
2. Manter dimensões e transparência reais de cada recorte; não inventar dimensões fixas no teste. O teste deve verificar somente carregamento, tamanho positivo, canal alfa utilizável e existência dos seis caminhos.
3. Escrever o teste primeiro com asserções claras para os seis recursos. Antes dos arquivos existirem, o resultado esperado é uma falha de recurso; depois da exportação, o teste deve terminar sem falhas.
4. Inspecionar cada PNG a 100% e em composição lado a lado com torso/cabeça. Se não for possível obter uma articulação limpa a partir do atlas, parar aqui e registrar que é necessária uma intervenção artística local; não construir o rig sobre recortes quebrados.
5. Verificar:
   - `& $godot --headless --path . --scene res://tests/test_vega_segmentada.tscn --quit`
   - resultado esperado após os arquivos: `VEGA SEGMENTADA: 0 falhas`.
6. Salvar uma captura ou folha de inspeção somente se os segmentos forem visualmente utilizáveis; ela não substitui a captura do preview.

**Commit checkpoint:** `assets: add segmented Vega arm pieces`.

## Task 2: Criar a cena candidata com a hierarquia de ossos

**Files:** criar `vega_animada/vega_animada_segmentada.tscn` e `vega_animada/vega_animada_segmentada.gd`; ampliar `tests/test_vega_segmentada.gd`.

1. Criar um `Control` raiz instanciável com o mesmo comportamento de layout da cena atual, mantendo a escala global limitada ao contrato vigente.
2. Criar `Modelo/Skeleton2D` e os ossos essenciais: tronco, cabeça, braço frontal, braço traseiro, perna frontal e perna traseira. Cada braço deve ter ossos nomeados para superior, antebraço e punho, ou uma cadeia equivalente documentada no script.
3. Colocar `Sprite2D` independentes como filhos dos ossos corretos. Os seis sprites dos braços devem carregar somente os PNGs novos; nenhum sprite de braço completo do atlas pode permanecer empilhado na candidata.
4. Reaproveitar torso, cabeça e pernas da arte atual apenas quando isso não introduzir duplicação. Manter `mouse_filter = IGNORE` em todos os elementos de apresentação.
5. Preservar nós ou referências compatíveis que o script precise para atualizar a pose, mas não criar pivôs falsos que escondam a ausência de segmentos.
6. Escrever o teste estrutural antes de considerar a tarefa concluída. Ele deve verificar `Skeleton2D`, ossos dos dois lados, seis sprites independentes, texturas corretas, ausência dos antigos sprites de antebraço e `mouse_filter` não interativo.
7. Verificar:
   - `& $godot --headless --path . --scene res://tests/test_vega_segmentada.tscn --quit`
   - resultado esperado: árvore candidata carregada, ossos essenciais presentes e `VEGA SEGMENTADA: 0 falhas`.

**Commit checkpoint:** `vega: create segmented skeleton candidate`.

## Task 3: Implementar a API de animação e as poses nomeadas

**Files:** ajustar `vega_animada/vega_animada_segmentada.gd` e `.tscn`; ampliar `tests/test_vega_segmentada.gd`.

1. Definir o estado tipado da animação e preservar a leitura externa de `estado_animacao` usada pelo teste e pelo combate.
2. Adicionar `AnimationPlayer` com as animações nomeadas `repouso`, `guarda`, `soco`, `dano` e `reiniciar`.
3. Fazer `repouso` e `guarda` compartilharem a mesma pose-base em três quartos: cabeça deslocada em relação ao torso, ombros em profundidades diferentes, cotovelos abertos, punhos fora da massa do torso e pés separados no piso.
4. Fazer `soco` usar antecipação, extensão do braço frontal e retorno. A animação deve deixar o antebraço e o punho visualmente independentes do braço superior.
5. Fazer `dano` recuar a partir da pose atual. Se o soco estiver tocando, a chamada de dano deve interromper a reprodução vigente de maneira determinística e recuperar a guarda sem reposicionar o modelo por um salto visível.
6. Fazer `reiniciar()` restaurar a pose-base e limpar tweens/animações pendentes de forma idempotente.
7. Manter a arte sem lógica de combate: nenhum método pode alterar Vida, Energia, Barreira, Combo, custo, dano ou alvo.
8. Testar primeiro as transições e depois a geometria. O teste deve chamar `socar()`, aguardar a conclusão, chamar `receber_dano()`, verificar a recuperação e exercitar a interrupção soco→dano.
9. Verificar:
   - `& $godot --headless --path . --scene res://tests/test_vega_segmentada.tscn --quit`
   - resultado esperado: estados válidos, métodos públicos presentes, animações reproduzíveis e `VEGA SEGMENTADA: 0 falhas`.

**Commit checkpoint:** `vega: animate segmented arm poses`.

## Task 4: Criar o preview isolado e as evidências de apresentação

**Files:** criar `vega_animada/preview_vega_segmentada.tscn`, `.gd` e `tests/capturar_vega_segmentada.gd`.

1. Montar uma cena de preview que carregue somente a candidata, um fundo neutro e rótulos mínimos de estado; não carregar `main.tscn`, HUD, arena ou regras.
2. Expor estados determinísticos para guarda, repouso, soco, dano e interrupção de soco por dano. O preview deve aguardar a estabilização da maior animação antes de capturar.
3. Gerar capturas Compatibility em 1024×576 e 1920×1080 sob `docs/evidencias_vega_segmentada/`, com nomes que identifiquem estado e resolução.
4. Inspecionar as capturas e os PNGs em conjunto. O gate visual deve observar especialmente a costura do cotovelo, a separação dos punhos, a cabeça deslocada, a base dos pés e a ausência de qualquer segundo corpo.
5. Se a inspeção encontrar uma falha de arte ou pivô, corrigir somente a candidata/recortes e repetir as capturas; não trocar a cena de combate ainda.
6. Verificar o script de captura com o executável detectado:
   - `& 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe' --path . --editor --quit`
   - depois executar o modo de captura definido em `tests/capturar_vega_segmentada.gd`.
7. Resultado esperado: capturas geradas sem erro funcional e inspeção visual registrada separadamente dos testes headless.

**Commit checkpoint:** `vega: add isolated segmented rig preview`.

## Task 5: Comparar a candidata com o contrato do combate sem trocar a cena

**Files:** ajustar `tests/verificar_vega_animada.gd` ou criar uma regressão de compatibilidade dedicada; não alterar `main.gd` ainda.

1. Instanciar a candidata em um teste de contrato e confirmar que ela pode ocupar a mesma caixa de layout usada por `Jogador/VegaAnimada`.
2. Confirmar a escala global, a posição sobre o piso, a ausência de input próprio e a inexistência de nós legados duplicados.
3. Exercitar as chamadas que `main.gd` faz hoje: `reiniciar()` ao iniciar, `socar()` após ataque válido e `receber_dano()` somente quando dano chega à Vida.
4. Confirmar que o teste de Proteção ainda altera somente Barreira/Energia do jogo e que a candidata não intercepta o clique no alvo Vega.
5. Executar o teste focado legado e o novo teste:
   - `& $godot --headless --path . --scene res://tests/verificar_vega_animada.tscn --quit`
   - `& $godot --headless --path . --scene res://tests/test_vega_segmentada.tscn --quit`
6. Resultado esperado: o rig atual e a candidata continuam verdes em paralelo, sem alteração de regra.

**Commit checkpoint:** `tests: verify segmented Vega combat contract`.

## Task 6: Fazer a troca controlada no combate

**Files:** alterar somente a linha de preload de `main.gd` em `_ready()` e ajustar regressões necessárias em `tests/test_composicao_combate.gd`/`tests/verificar_vega_animada.gd`.

1. Registrar antes da troca o resultado verde da cena atual, incluindo composição, input, custo, dano, Barreira e animações.
2. Alterar `preload("res://vega_animada/vega_animada.tscn")` para a cena candidata. Não refatorar os chamadores nem duplicar os métodos.
3. Executar a composição real em `main.tscn` e confirmar que existe somente `Jogador/VegaAnimada`, sem `VegaCampoRetrato`, `VegaCampoNome` ou segunda instância da personagem.
4. Rodar o teste de composição e o teste focado da Vega. Qualquer falha de regra, input ou layout deve reverter a troca para o fallback enquanto a candidata é corrigida.
5. Regenerar capturas de repouso, soco e dano do combate em 1024×576 e 1920×1080, sob `docs/evidencias_vega/`, e inspecionar comparativamente com as evidências anteriores.
6. Resultado esperado: a cena principal usa a candidata, os chamadores antigos continuam funcionando e nenhum sistema de combate muda.

**Commit checkpoint:** `vega: integrate segmented rig into combat`.

## Task 7: Regressão completa, documentação e gate manual

**Files:** atualizar `docs/DECISOES.md` e `docs/STATUS.md`; preservar evidências.

1. Executar o teste focado da candidata, a composição do combate, os testes de HUD/interação que cobrem o alvo Vega e a suíte completa `tests/test_*.tscn`.
2. Executar a importação do editor em modo headless:
   - `& $godot --headless --editor --path . --quit`
3. Executar `git diff --check`.
4. Registrar apenas resultados realmente observados: comandos, códigos de saída, mensagens de falha, avisos residuais e caminhos das capturas.
5. Atualizar `docs/DECISOES.md` com a decisão de manter a cena segmentada integrada ou retornar ao fallback. Se a aprovação manual ainda não ocorreu, registrar a integração como candidata validada automaticamente, não como arte final aprovada.
6. Adicionar no topo de `docs/STATUS.md` um relato datado que separe:
   - estado observado no código;
   - regra de design preservada;
   - capturas e testes executados;
   - pendência de playtest manual em 1024×576 e 1920×1080;
   - próximo exercício curto para o usuário no editor.
7. Gate manual final: abrir `main.tscn` nas duas resoluções, observar repouso/respiração, soco, dano e hover de Proteção sobre Vega. Só depois desse relato a implementação poderá ser chamada de visualmente aprovada.

**Commit checkpoint:** `docs: record segmented Vega rig verification`.

## Verification Matrix

| Critério | Teste/Evidência | Resultado esperado |
|---|---|---|
| Seis recursos segmentados | `test_vega_segmentada.tscn` + inspeção dos PNGs | arquivos carregam, têm alpha e não duplicam torso/braço |
| Ossos e pivôs | `test_vega_segmentada.tscn` | `Skeleton2D`, cadeias dos dois braços e pivôs presentes |
| API de animação | teste focado da candidata | `estado_animacao`, `socar`, `receber_dano`, `reiniciar` preservados |
| Interrupção | teste focado + captura de dano durante soco | retorno determinístico sem salto incorreto |
| Input | teste de contrato/composição | arte ignora input e Jogador continua clicável |
| Regras | testes existentes de interação/HUD | Energia, Barreira, dano, alvo e turno inalterados |
| Escalas | preview e combate 1024×576/1920×1080 | silhueta contida, legível e sem segunda camada |
| Regressão | suíte completa + importação editor | todos os testes passam; avisos conhecidos separados de falhas |

## Self-review

- **Spec coverage:** todas as seções da especificação têm uma tarefa: arte (1), rig (2), animação (3), preview (4), compatibilidade (5), migração (6), verificação/documentação (7).
- **Step scan:** cada tarefa tem arquivos, ordem, teste e resultado esperado; não há instrução de implementação vaga como “ajustar até ficar bom”.
- **Type consistency:** o plano exige scripts tipados e mantém os nomes públicos atuais; qualquer nome interno novo será validado pelo teste estrutural antes de integração.
- **Review focus:** cada ponto crítico aparece em uma tarefa e na matriz final; a aprovação manual permanece explícita.
- **Proportion:** a preparação de arte é um gate próprio para evitar construir código sobre recortes quebrados; a troca no combate só ocorre depois da validação isolada.
