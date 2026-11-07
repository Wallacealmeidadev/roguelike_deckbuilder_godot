# Arte de corpo inteiro da Vega e pipeline de articulacao Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Criar uma arte de corpo inteiro da Vega no Krita, aprovar primeiro a silhueta estatica e somente depois preparar e integrar pecas de bracos articulaveis na Godot.

**Architecture:** O PNG atual e `vega_animada/vega_playtest.tscn` permanecem como fallback ate a aprovacao manual. A primeira entrega produz uma imagem unica de corpo inteiro; depois dela, um arquivo `.kra` duplicado fornece uma base sem bracos e seis pecas transparentes em canvas comum. A candidata articulada sera testada em preview isolado, primeiro com um cotovelo e depois com o segundo braco, antes de qualquer troca no combate principal.

**Tech Stack:** Krita para o arquivo mestre e exportacoes RGBA; Godot `4.7.2.stable.official.ed1daf0bf`; renderer `GL Compatibility`; GDScript tipado; `Control`, `TextureRect`/`Sprite2D`, `Tween` ou `AnimationPlayer` apenas na apresentacao; testes de cena executados pelo `SceneTree`.

**Spec:** `docs/superpowers/specs/2026-10-04-vega-krita-asset-pipeline-design.md`

## Emenda de estrategia - 06/10/2026

O usuario forneceu `vega_rig_parts.zip` com assets rig-ready separados. Esta emenda substitui, para as tarefas de articulacao, a preparacao manual no Krita e a exigencia de canvas comum. Os PNGs de `docs/arte_vega/vega_animada/pecas_rig/` sao a fonte preservada; as copias carregadas pelo Godot ficam em `vega_animada/pecas_rig/`. `vega_referencia_corpo_inteiro.png` e apenas referencia visual. A/B permanecem nomes de asset e nao devem ser renomeados anatomicamente.

O novo resultado das tarefas 3 a 5 e um cutout rig isolado com `Skeleton2D`, `Bone2D`, `Sprite2D` e `AnimationPlayer`, usando pecas em dimensoes individuais, cotovelos como cobertura e idle curto. A candidata nao substitui `vega_animada/vega_playtest.tscn` ate aprovacao manual em 1024x576 e 1920x1080. A decisao de manter o runtime estatico, as regras e a API publica permanece.

## Global Constraints

- Preservar rosto, cabelo, jaqueta e linguagem dos bracos proteticos aprovados na ilustracao atual.
- Nao sobrescrever `ui_hq_v1/assets/personagens/vega_combate.png`; a nova imagem tera nome e arquivo mestre proprios.
- A primeira exportacao deve ser uma PNG RGBA unica, com corpo inteiro, pes apoiados no piso e pose em tres quartos.
- A aprovacao estatica em 1024x576 e 1920x1080 e um gate manual; capturas automatizadas nao a substituem.
- Manter `VegaAnimada`, `socar()`, `receber_dano()`, `reiniciar()` e `estado_animacao` compativeis com os chamadores existentes.
- As pecas articuladas podem usar dimensoes individuais; o rig e responsavel por posicionamento, escala e pivots relativos.
- Nao reutilizar o rig segmentado rejeitado nem cortar o atlas antigo para fabricar as novas pecas.
- Nao alterar regras, custos, dano, Energia, Vida, Barreira, Combo, turnos, mapa, run, HUD, cartas, arena ou input.
- A arte e todos os nos de apresentacao devem ignorar input; a caixa `Jogador` continua sendo a superficie de interacao.
- Se aparecer duplicacao, fresta, costura flutuante, escala divergente ou pe sem contato, interromper a integracao e manter o fallback.

## Review Focus

- **Fonte preservada:** a referencia original continua intacta e a nova PNG e a que a cena realmente carrega; a tarefa 1 verifica caminhos e a tarefa 2 verifica a referencia em runtime.
- **Silhueta:** torso unico, dois bracos legiveis, quadril/pernas proporcionais, pose em tres quartos e pes apoiados; a tarefa 1 tem checklist manual e gate do usuario.
- **Canvas e transparencia:** PNG estatico e pecas possuem alpha real, dimensoes coerentes e margem suficiente; a tarefa 3 testa recursos e dimensoes.
- **Pivots e costuras:** o cotovelo dobra sem buraco, sobreposicao aparente ou salto de escala; as tarefas 4 e 5 cobrem o primeiro e o segundo braco em preview isolado.
- **Contrato do combate:** a troca final nao duplica arte, nao intercepta input e preserva a API; a tarefa 6 executa regressao de composicao, input e regras antes da documentacao.

## File Map

Arquivos novos planejados:

- `docs/arte_vega/vega_corpo_inteiro_master.kra`: arquivo mestre da primeira pintura, fora do runtime.
- `docs/arte_vega/vega_corpo_inteiro_articulacao.kra`: copia do mestre usada somente para preparar camadas.
- `ui_hq_v1/assets/personagens/vega_combate_corpo_inteiro.png`: exportacao estatica aprovada.
- `vega_animada/pecas_corpo_inteiro/corpo_base.png`: corpo central e pernas sem os dois bracos.
- `vega_animada/pecas_corpo_inteiro/braco_dianteiro_superior.png`.
- `vega_animada/pecas_corpo_inteiro/braco_dianteiro_antebraco.png`.
- `vega_animada/pecas_corpo_inteiro/braco_dianteiro_punho.png`.
- `vega_animada/pecas_corpo_inteiro/braco_traseiro_superior.png`.
- `vega_animada/pecas_corpo_inteiro/braco_traseiro_antebraco.png`.
- `vega_animada/pecas_corpo_inteiro/braco_traseiro_punho.png`.
- `vega_animada/vega_corpo_inteiro_articulada.gd` e `.tscn`: candidata final sem uso no combate ate o gate final.
- `vega_animada/preview_vega_corpo_inteiro.tscn` e `.gd`: preview isolado dos gates estatico e articulado.
- `tests/test_vega_corpo_inteiro_pecas.gd` e `.tscn`: recursos, canvas, alpha e nomes das pecas.
- `tests/test_vega_corpo_inteiro_articulada.gd` e `.tscn`: hierarquia, API, poses, interrupcao e input.
- `tests/capturar_vega_corpo_inteiro.gd`: capturas Compatibility do preview e, depois, da integracao.

Arquivos existentes que podem ser modificados somente nos gates indicados:

- `vega_animada/vega_playtest.tscn`: apontar para a PNG estatica nova somente depois da aprovacao manual da silhueta, mantendo-o como fallback.
- `tests/test_vega_playtest.gd`: trocar a expectativa de textura apenas quando a integracao estatica for aprovada.
- `main.gd`: trocar exclusivamente a cena instanciada no campo no gate final, sem refatorar os chamadores.
- `tests/test_composicao_combate.gd` e `tests/verificar_vega_animada.gd`: atualizar o contrato da candidata somente no gate final.
- `docs/DECISOES.md` e `docs/STATUS.md`: registrar fatos observados, gates e resultados reais.

---

### Task 1: Criar e revisar o mestre estatico no Krita

**Files:**
- Create: `docs/arte_vega/vega_corpo_inteiro_master.kra`
- Reference only: `ui_hq_v1/assets/personagens/vega_combate.png`
- Evidence: `docs/evidencias_vega/arte_estatica_1024.png` e `arte_estatica_1920.png` somente apos exportacao

**Interfaces:**
- Consumes: a PNG atual como camada de referencia bloqueada.
- Produces: um `.kra` com grupos `Referencia`, `CorpoFinal`, `BracoDianteiro`, `BracoTraseiro` e `GuiasPivots`, alem da exportacao estatica que a tarefa 2 carregara.

- [ ] **Step 1: Abrir a referencia sem modifica-la**

Abrir `ui_hq_v1/assets/personagens/vega_combate.png` no Krita, salvar imediatamente uma copia como `docs/arte_vega/vega_corpo_inteiro_master.kra` e bloquear a camada `Referencia`. Nao salvar sobre o PNG de origem.

- [ ] **Step 2: Criar a estrutura de camadas do mestre**

Criar os cinco grupos nomeados exatamente `Referencia`, `CorpoFinal`, `BracoDianteiro`, `BracoTraseiro` e `GuiasPivots`. A camada `Referencia` deve permanecer visivel apenas como apoio de desenho; `GuiasPivots` nao participa de nenhuma exportacao.

- [ ] **Step 3: Estender o corpo inferior**

Desenhar quadril, pernas e pes em tres quartos, preservando o rosto, cabelo, jaqueta e bracos aprovados. A silhueta deve ter um torso unico, base aberta, pes apoiados e margem transparente ao redor, sem aumentar artificialmente a escala da personagem no campo.

- [ ] **Step 4: Exportar a primeira PNG sem iniciar a segmentacao**

Exportar `ui_hq_v1/assets/personagens/vega_combate_corpo_inteiro.png` como RGBA, com fundo transparente e a mesma escala de referencia. Nesta tarefa os grupos de braco continuam uma composicao visual unica; nao exportar pecas articuladas ainda.

- [ ] **Step 5: Fazer o gate visual manual**

Abrir a PNG no Krita e no preview atual em 1024x576 e 1920x1080. Conferir torso unico, proporcao de cabeca/quadril/pernas, dois bracos sem duplicacao, pes no piso e margem sem corte. Registrar no `STATUS.md` somente depois do relato do usuario: aprovado, rejeitado ou ajuste necessario.

**Resultado esperado:** existe um mestre `.kra` preservado, uma PNG RGBA de corpo inteiro e um relato manual separado da verificacao automatica. Se a silhueta for rejeitada, parar antes da tarefa 2 e ajustar somente o mestre.

---

### Task 2: Integrar a imagem unica aprovada sem alterar o jogo

**Files:**
- Modify: `vega_animada/vega_playtest.tscn` no recurso da textura `Visual/Arte`.
- Modify: `tests/test_vega_playtest.gd` somente para o caminho aprovado.
- Create: `vega_animada/preview_vega_corpo_inteiro.tscn` e `.gd` se o preview isolado atual nao puder carregar a textura sem `main.tscn`.
- Test: `tests/test_vega_playtest.tscn`.

**Interfaces:**
- Consumes: `ui_hq_v1/assets/personagens/vega_combate_corpo_inteiro.png` aprovado na tarefa 1.
- Produces: `VegaAnimada` estatico no campo com `Visual/Arte`, `Sombra`, `mouse_filter = IGNORE` e API provisoria preservada.

- [ ] **Step 1: Escrever a expectativa de recurso novo**

Atualizar o teste focado para exigir `arte.texture.resource_path == "res://ui_hq_v1/assets/personagens/vega_combate_corpo_inteiro.png"`, `Visual/Arte` visivel, `Sombra` presente e ausencia de `Modelo/Skeleton2D`. Manter as assercoes de repouso, soco, dano, reinicio e input.

- [ ] **Step 2: Executar o teste antes da troca**

Rodar:

```powershell
& 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --scene res://tests/test_vega_playtest.tscn --quit
```

Resultado esperado antes da troca: falha somente porque a cena ainda aponta para a textura provisoria antiga.

- [ ] **Step 3: Trocar apenas o recurso da cena provisoria**

Modificar o `ExtResource` de textura em `vega_playtest.tscn`; preservar offsets, sombra, wrapper `Visual`, script e caixa de alvo. Nao alterar `main.gd`, regras ou layout.

- [ ] **Step 4: Executar o teste focado e a importacao**

Rodar novamente o teste focado e a importacao headless do editor. Resultado esperado: `VEGA PLAYTEST: 0 falhas` e codigo de importacao 0, separando avisos conhecidos de teardown de falhas reais.

- [ ] **Step 5: Repetir o gate manual em janela real**

Abrir `main.tscn` nas duas resolucoes, observar repouso, ataque, dano e hover de Protecao. Confirmar que a sombra ancora sem parecer uma segunda base. Se rejeitada, retornar a referencia antiga no campo e registrar o motivo antes de continuar.

**Resultado esperado:** o combate usa a nova figura unica apenas depois da aprovacao estatica, sem mudanca de regra e com `vega_playtest.tscn` ainda disponivel como fallback.

---

### Task 3: Preparar a copia de articulacao e exportar recursos no mesmo canvas

**Files:**
- Create: `docs/arte_vega/vega_corpo_inteiro_articulacao.kra`.
- Create: `vega_animada/pecas_corpo_inteiro/corpo_base.png`.
- Create: `vega_animada/pecas_corpo_inteiro/braco_dianteiro_superior.png`.
- Create: `vega_animada/pecas_corpo_inteiro/braco_dianteiro_antebraco.png`.
- Create: `vega_animada/pecas_corpo_inteiro/braco_dianteiro_punho.png`.
- Create: `vega_animada/pecas_corpo_inteiro/braco_traseiro_superior.png`.
- Create: `vega_animada/pecas_corpo_inteiro/braco_traseiro_antebraco.png`.
- Create: `vega_animada/pecas_corpo_inteiro/braco_traseiro_punho.png`.
- Create: `tests/test_vega_corpo_inteiro_pecas.gd` e `.tscn`.

**Interfaces:**
- Consumes: `vega_rig_parts.zip` fornecido pelo usuario e sua referencia visual completa.
- Produces: PNGs RGBA preservadas em dimensoes individuais, nomes A/B estaveis e copias carregaveis pelo Godot em `vega_animada/pecas_rig/`.

- [ ] **Step 1: Duplicar o mestre somente apos o gate**

Copiar os assets do ZIP para `docs/arte_vega/vega_animada/pecas_rig/` e para a pasta de runtime `vega_animada/pecas_rig/`. Manter o `.kra` e a PNG estatica intactos; a referencia completa nao entra no runtime.

- [ ] **Step 2: Definir as areas de sobreposicao**

Usar os segmentos ja separados de cada lado. Mapear A/B visualmente na cena, sem renomear os PNGs. Usar os PNGs de cotovelo como cobertura das juntas quando necessario; os pivots ficam nos `Bone2D` da candidata.

- [ ] **Step 3: Exportar o corpo e os seis segmentos**

Preservar e importar os PNGs com transparencia real. As dimensoes podem variar entre pecas; o teste deve verificar alpha e textura carregavel, nao igualdade de canvas.

- [ ] **Step 4: Escrever o teste estrutural antes de montar o rig**

Criar `tests/test_vega_corpo_inteiro_pecas.tscn` com verificacoes para os 14 caminhos, textura carregavel, dimensao positiva e alpha utilizavel. O teste nao deve tentar inferir qualidade artistica por cor ou bounding box.

- [ ] **Step 5: Rodar o teste e inspecionar os PNGs a 100%**

Executar:

```powershell
& 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --scene res://tests/test_vega_corpo_inteiro_pecas.tscn --quit
```

Resultado esperado: `VEGA PECAS: 0 falhas`. Depois, compor manualmente `corpo_base` com os seis segmentos e rejeitar qualquer exportacao que mostre torso duplicado, contorno faltante ou fresta parada.

**Resultado esperado:** os recursos novos sao verificaveis e visualmente utilizaveis, sem depender de qualquer recorte do atlas rejeitado.

---

### Task 4: Criar a candidata com um unico cotovelo no preview isolado

**Files:**
- Create: `vega_animada/vega_corpo_inteiro_articulada.gd` e `.tscn`.
- Modify: `vega_animada/preview_vega_corpo_inteiro.gd` e `.tscn`.
- Create: `tests/test_vega_corpo_inteiro_articulada.gd` e `.tscn`.
- Create: `tests/capturar_vega_corpo_inteiro.gd`.

**Interfaces:**
- Consumes: `corpo_base.png` e os tres segmentos do `BracoDianteiro` da tarefa 3.
- Produces: `VegaCorpoInteiroArticulada` com `estado_animacao: String`, `socar() -> void`, `receber_dano() -> void` e `reiniciar() -> void`; o segundo braco permanece oculto nesta etapa tecnica.

- [ ] **Step 1: Escrever o teste estrutural RED**

Exigir a raiz `VegaCorpoInteiroArticulada`, `Visual/CorpoBase`, `Visual/BracoDianteiro/BracoSuperior`, `Antebraco` e `Punho`, texturas dos quatro recursos, `mouse_filter = IGNORE` e ausencia de `Modelo/Skeleton2D`. Antes da cena existir, o teste deve falhar por recurso/cena ausente.

- [ ] **Step 2: Criar a cena sem trocar `main.gd`**

Montar corpo base e um unico braco no preview. Os pivots de ombro e cotovelo devem ser propriedades da candidata, nao transformacoes aproximadas copiadas do rig antigo. Manter a mesma area de ancoragem do alvo e a mesma escala global da cena provisoria.

- [ ] **Step 3: Implementar a API tipada minima**

No script, preservar exatamente `var estado_animacao: String`, `func socar() -> void`, `func receber_dano() -> void` e `func reiniciar() -> void`. O script deve mover somente nos visuais; nao pode acessar nem alterar estado de combate.

- [ ] **Step 4: Adicionar as poses e a interrupcao**

Implementar repouso/guarda, antecipacao e extensao de soco, recuo de dano e retorno. `receber_dano()` durante `socar()` deve interromper a animacao vigente a partir da pose atual, sem teleportar para outra escala ou duplicar o cotovelo.

- [ ] **Step 5: Executar teste focado e preview Compatibility**

Rodar `test_vega_corpo_inteiro_articulada.tscn` em headless e gerar repouso, guarda, soco e dano em 1024x576 e 1920x1080 pelo preview isolado. Inspecionar a costura, pivot, escala e contato do corpo com o piso; nao integrar no combate se houver falha.

**Resultado esperado:** um cotovelo funcional e legivel em preview isolado, com o corpo central estatico e sem qualquer dependencia das regras do jogo.

---

### Task 5: Integrar o segundo braco e fechar o contrato da candidata

**Files:**
- Modify: `vega_animada/vega_corpo_inteiro_articulada.tscn` e `.gd`.
- Modify: `vega_animada/preview_vega_corpo_inteiro.tscn` e `.gd`.
- Modify: `tests/test_vega_corpo_inteiro_articulada.gd` e `.tscn`.
- Modify: `tests/capturar_vega_corpo_inteiro.gd`.

**Interfaces:**
- Consumes: a candidata de um cotovelo aprovada na tarefa 4 e os tres segmentos do `BracoTraseiro`.
- Produces: candidata com dois bracos visiveis, dois cotovelos independentes, API publica compativel e estados estaveis para o gate de combate da tarefa 6.

- [ ] **Step 1: Adicionar os tres segmentos traseiros**

Criar `Visual/BracoTraseiro/BracoSuperior`, `Antebraco` e `Punho`, carregando somente os PNGs traseiros novos. O corpo base deve continuar sendo a unica fonte do torso e das pernas.

- [ ] **Step 2: Definir a guarda e os pivots relativos**

Manter a pose em tres quartos: cabeca deslocada, ombros em profundidades diferentes, punhos fora do torso e pes no piso. O segundo braco nao pode ficar empilhado sobre o primeiro nem terminar escondido dentro da massa central.

- [ ] **Step 3: Exercitar ambos os lados no teste**

Adicionar assercoes de dois bracos visiveis, texturas corretas, separacao dos punhos, ausencia de sprites antigos e retorno de `soco`/`dano` a `repouso`. Verificar tambem que `receber_dano()` interrompe soco sem deixar a pose traseira parada em escala divergente.

- [ ] **Step 4: Regenerar e inspecionar as evidencias**

Capturar repouso, guarda, soco e dano/interrupcao nas duas resolucoes. A aprovacao deste gate exige que a silhueta continue parecendo um unico corpo e que nenhuma costura seja mascarada por sombra ou modulate.

**Resultado esperado:** a candidata completa funciona em preview isolado, mas ainda nao substitui a cena do combate.

---

### Task 6: Fazer a troca final controlada, regredir e documentar

**Files:**
- Modify: `main.gd`, somente o recurso da cena de `Jogador/VegaAnimada`.
- Modify: `tests/test_composicao_combate.gd` e `tests/verificar_vega_animada.gd`.
- Preserve: `vega_animada/vega_playtest.tscn` como fallback.
- Modify: `docs/DECISOES.md` e `docs/STATUS.md`.

**Interfaces:**
- Consumes: candidata completa e aprovada nas tarefas 4 e 5.
- Produces: campo de combate usando uma unica `VegaAnimada`, com `socar()`, `receber_dano()`, `reiniciar()` e input/regra preservados.

- [ ] **Step 1: Registrar o baseline antes da troca**

Executar e guardar a saida real de `test_vega_playtest.tscn`, `verificar_vega_animada.tscn`, `test_composicao_combate.tscn` e dos testes de interacao que cobrem alvo Vega. Nao iniciar a troca com uma regressao ja vermelha sem registra-la.

- [ ] **Step 2: Trocar somente a cena instanciada no combate**

Alterar em `main.gd` apenas o `preload`/recurso usado para `Jogador/VegaAnimada`, apontando para `vega_corpo_inteiro_articulada.tscn`. Nao duplicar os metodos chamados pelo combate e nao alterar a caixa `Jogador`.

- [ ] **Step 3: Atualizar o contrato de composicao**

Fazer os testes exigirem uma unica instancia visivel, ausencia de `VegaCampoRetrato`/`VegaCampoNome`, `mouse_filter = IGNORE`, sombra discreta e API publica. Manter as verificacoes de custo, dano, Barreira, alvo invalido, mapa oculto e reinicio.

- [ ] **Step 4: Executar a regressao focada**

Rodar:

```powershell
$godot = 'C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godot --headless --path . --scene res://tests/test_vega_corpo_inteiro_articulada.tscn --quit
& $godot --headless --path . --scene res://tests/verificar_vega_animada.tscn --quit
& $godot --headless --path . --scene res://tests/test_composicao_combate.tscn --quit
```

Resultado esperado: zero falhas em cada teste. Qualquer falha visual, de input ou de regra exige retorno ao fallback, nao relaxamento da assercao.

- [ ] **Step 5: Executar a suite e a importacao do editor**

Executar todos os `tests/test_*.tscn`, a importacao `--headless --editor --path . --quit` e `git diff --check`. Registrar codigos de saida e separar avisos conhecidos de falhas funcionais.

- [ ] **Step 6: Gerar capturas reais e fazer o gate manual final**

Gerar capturas Compatibility de repouso, soco, dano e hover de Protecao em 1024x576 e 1920x1080. Abrir `main.tscn` em janela real, observar cinco segundos de repouso, um ataque e um dano, e relatar se a Vega permanece unica, legivel e apoiada no piso.

- [ ] **Step 7: Atualizar a documentacao sem declarar mais do que foi observado**

Adicionar no topo de `docs/STATUS.md` um registro datado com arquivos, comandos, saidas, capturas, avisos e pendencia manual. Em `docs/DECISOES.md`, registrar se a candidata foi integrada ou se o fallback foi mantido. Somente o relato manual pode marcar a silhueta como aprovada visualmente.

**Resultado esperado:** a cena principal usa a candidata somente se todos os testes e gates visuais passarem; caso contrario, o jogo segue jogavel com `vega_playtest.tscn` e a pendencia fica documentada.

## Verification Matrix

| Criterio | Teste/evidencia | Resultado esperado |
|---|---|---|
| PNG original preservada | comparacao de caminho e `git diff` | `vega_combate.png` nao e sobrescrita |
| Corpo inteiro estatico | Krita + preview em 1024x576/1920x1080 | torso unico, dois bracos, pes no piso, sem duplicacao |
| Recursos segmentados | `test_vega_corpo_inteiro_pecas.tscn` + inspeção a 100% | sete PNGs carregam, tem alpha e canvas igual |
| Um cotovelo | `test_vega_corpo_inteiro_articulada.tscn` + capturas | costura fechada e pivot consistente |
| Dois bracos | mesmo teste + preview de guarda/soco/dano | ambos visiveis, sem torso duplicado ou fresta |
| API | `estado_animacao`, `socar`, `receber_dano`, `reiniciar` | chamadores existentes continuam validos |
| Input | composicao e teste de interacao | arte ignora input e `Jogador` continua clicavel |
| Regras | testes de combate/HUD | Energia, Vida, Barreira, dano, alvo e turno inalterados |
| Regressao | suite completa + importacao editor | todos os testes verdes; avisos residuais separados |
| Aprovacao final | playtest manual do usuario | somente entao declarar a arte visualmente aprovada |

## Self-review

- **Spec coverage:** o mestre e a primeira exportacao ficam na tarefa 1; a troca estatica e o fallback na tarefa 2; a duplicacao e as pecas na tarefa 3; o preview de um cotovelo na tarefa 4; o segundo braco e a candidata completa na tarefa 5; a integracao, regressao e documentacao na tarefa 6.
- **Step scan:** cada passo tem um arquivo ou acao concreta, um resultado verificavel e um gate explicito; nao ha instrucao para “ajustar ate ficar bom” sem criterio.
- **Type consistency:** a candidata publica `estado_animacao: String`, `socar() -> void`, `receber_dano() -> void` e `reiniciar() -> void` em todas as tarefas que a consomem.
- **Review focus:** fonte, silhueta, canvas, pivots/costuras e contrato de combate aparecem no topo e sao exercitados nas tarefas correspondentes.
- **Proportion:** o plano separa arte, exportacao, preview e integracao; nao introduz mudancas de regra nem uma nova arquitetura de combate.
