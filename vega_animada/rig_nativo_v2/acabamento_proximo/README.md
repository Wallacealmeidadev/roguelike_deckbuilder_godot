# Passe de acabamento — ombro/braço próximo, prova 01

Refinamento posterior autorizado: mangas mais curtas, miolo do punho limitado ao interior do aro e preenchimento dos cotovelos contido. Flag `refinar_juntas` para comparar mantendo a mesma animação. Detalhes e verificações em [JUNTAS.md](JUNTAS.md).

Atualização das uniões dos punhos: conectores sob os aros e miolos nas aberturas pintadas, preservando o movimento aprovado. Mesma entrada F6, flag `fechar_punhos` para comparar. Evidências/testes/limites em [SOQUETES.md](SOQUETES.md).

Atualização posterior à aprovação da pose: margem do bíceps distante completada e filtragem com mipmaps aplicada à personagem. Sem novos PNGs ou mudança de pose; comparação/limites/testes em [RECORTE_E_FILTRO.md](RECORTE_E_FILTRO.md).

## Atualização: vista interna e folga do lado distante

Correção posterior do polegar na vista dorsal: somente a mão próxima usa o recorte da revisão 02, enquanto a palma distante conserva a 01. Detalhes e prompt em [DEDAO.md](DEDAO.md).

Após o relato de mãos diferentes e punho entrando no ombro, a mesma prévia F6 recebeu vista interna própria do braço distante, punhos derivados juntos e abertura de 23° do cotovelo na guarda/preparo/retorno. F5 continua anterior. Detalhes, limites, testes, imagens e prompts completos em [FACE_INTERNA.md](FACE_INTERNA.md). O restante deste documento registra a primeira etapa próxima; suas afirmações de preservação de mãos/braço distante/poses descrevem aquela versão, não a revisão atual.

## Registro da primeira etapa

22/10/2026. Recorte autorizado após aprovação da guarda unificada 01: adaptar primeiro um conjunto ombro/braço ao rig existente e conferir guarda/extensão. Não é troca integral da personagem nem aprovação automática do acabamento derivado.

## Abrir e comparar

Abra `preview.tscn` nesta pasta e execute F6. A cena instancia o combate normal com `vega_prova.tscn` somente nessa cópia; pode jogar cartas, intercalar golpes e observar Combo. F5 continua usando a apresentação anterior. Não é um PNG inteiro sobreposto ao rig.

Exercício pequeno: no Inspector da raiz de `vega_prova.tscn`, desative `mostrar_ombro`, salve e rode o preview novamente. Compare a transição de pele durante guarda/soco; depois restaure `true`. O acabamento das próteses permanece igual nessa comparação. `mostrar_acabamento=false` na mesma raiz permite comparar a versão anterior completa; flags são de inicialização, não controles dinâmicos.

## O que muda

- `camadas_01.png`: atlas novo gerado pelo imagegen embutido, usando o atlas anterior como alvo e a guarda unificada aprovada como referência. Pintura de fibras/placas/junta e recorte de deltoide na célula antes ocupada pela mão aberta não usada. Arquivo 1774×887 RGBA, mesma resolução do atlas anterior; alfa do canto zero. Copiado sem edição de pixels.
- `vega_prova.gd/.tscn`: herda adaptador nativo. Troca textura/UV das duas malhas do braço próximo, cinco peças rígidas/junta e quatro núcleos de fechamento. Vértices, bases/deltas de Combo, placas, âncoras e ossos mantêm dimensões/poses. AtlasTexture novos são privados, não modificam recursos compartilhados.
- `ombro.gdshader`: pintura local da pele do deltoide, aplicada a faces selecionadas de uma cópia da mesma malha/pesos corporais. A máscara preserva alfa/contorno original e evita pintar tecido/colar. Mapeamento considera UV corporal existente (ponto + (300,0)); não é um sistema genérico de troca de personagens. Segue o skinning nativo, sem código atualizando ombro por frame.

Primeira captura do deltoide isolado aumentava o ombro. Essa proposta não foi mantida: a pintura final é recortada pela pele original. Não foi movido osso ou alongado braço para acomodar o desenho.

Braço distante, corpo-base/roupa/rosto e texturas das mãos continuam anteriores; só o miolo de fibras da mão próxima acompanha o atlas novo. Não afirmar unidade artística de toda a personagem nesta etapa. O atlas derivado não reproduz pixel a pixel a mestre, nem melhora por si só perspectiva ou participação corporal. Ainda há trabalho visual no restante; avaliar legibilidade e junções desta prova antes de replicar.

## Verificação executada

Godot 4.7.2. `tests/test_acabamento_proximo.tscn` passou headless e OpenGL com `--fixed-fps 60`, zero falhas/exit 0. Compara todos os ossos/comprimentos/poses com o original em 57 amostras para respiração, dois socos e dano, em Combo 0/10; malhas/deltas e pesos corporais idênticos, recursos originais intactos e mãos preservadas. Alternância, reduzido e reset conferidos.

Leitura GPU isolou a pintura do ombro e comparou seu alfa à pele original: 922 pixels pintados, zero fora da silhueta. Integração `test_vega_nativa_combate.tscn -- --acabamento` passou headless/OpenGL, cobrindo cartas reais/custos/dano/Combo, interrupção, retorno/reduzido/reset e UI em duas resoluções. Integração padrão e regressões combo_nativo/encaixes_nativo/apoio_corporal passaram headless/fixed-fps 60. Preview F6 lançado por cinco frames headless: combate iniciou, exit 0. Sem suíte completa.

Importação retornou 0. Teste isolado de acabamento encerrou sem avisos; main/editor/capturas continuam emitindo avisos anteriores de recursos/RID/fontes/ObjectDB no encerramento. Não foram resolvidos nesta etapa. `git diff --check` passou.

Capturador com `--alternar --acabamento`: 32 PNGs em `docs/evidencias_vega_acabamento_proximo_01/`, guarda/Combo e dois golpes em 1920×1080 e 1024×576. Inspecionadas guarda, impacto e golpe distante ampliados 1920 e guarda 1024; ombro corrigido dentro do contorno, figura inteira e HUD preservadas. Vídeo `ciclo_proximo.avi` gerado com cartas reais: 133 frames/30 FPS/1152×648, exit 0; não assistido integralmente. Avaliação artística pendente com o usuário.

## Proveniência / prompt

Skill imagegen, ferramenta embutida, sem CLI/API direta. Original preservado em `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-e53b1d51-1cc2-432f-8678-0c6e51785169.png`. Destino final: `vega_animada/rig_nativo_v2/acabamento_proximo/camadas_01.png`. Imagens-alvo/referência inspecionadas antes da chamada; arte anterior e mestre permanecem intactas.

Prompt integral:

```text
Use case: style-transfer / precise-object-edit.
Asset type: transparent 2D game atlas, a replacement finish for existing rig pieces, NOT an assembled arm illustration.
Image 1 is the EDIT TARGET: the existing wide 2-row atlas of separated cybernetic arm components. Image 2 is the approved unified Vega, the STYLE AND MATERIAL reference only.
Preserve Image 1's wide 2:1 canvas, all component positions, rotations, relative dimensions, contours and empty transparent gaps as closely as possible: upper-left dark braided muscle bundle, upper-middle dark braided muscle bundle, upper center-right cyan/magenta elbow ring, lower-left complete synthetic upper arm WITH shoulder collar and grey plate attached, and three separate rigid graphite plates across the lower row. These are rig parts with fixed joint anchors: DO NOT rearrange, assemble, rotate, change perspective, merge pieces, add anatomy to the existing arm parts, increase their bulk or make another character. In particular preserve the same upper-arm plate footprint and bundle silhouette so Combo's rigid plate mask stays useful.
Repaint their finish with the SAME comic ink and shading as Image 2: broad grouped fibers, intentional ink lines, muted graphite grey armor, coherent upper-left key light, two/three shadow-value groups and restrained cyan/magenta connectors. Remove excessive shiny micro-strand engraving and chrome glare. Keep the recognizable approved design, not industrial yellow armor or photoreal 3D.

ONE local content change: replace ONLY the unused OPEN HAND in the top-right cell with an isolated near HUMAN DELTOID CAP/shoulder cutout matching the warm skin and charcoal tank edge of Image 2. It is a small human shoulder cap, oval muscular deltoid tapering diagonally down-right into a thin cyan graphite prosthesis collar at its lower-right edge. No forearm or hand attached to this cap. Same master lighting, contact shadow just above the collar, small charcoal fabric edge at upper-right. Keep this cutout entirely inside the old open-hand cell, separate from all other pieces. Its role is to overlay only the human shoulder/skin-to-cyber-arm transition on the existing body.
All background truly transparent. No background, floor, shadow under pieces, labels, numbers, borders, extra pieces, watermark, swatches, full body or full assembled arm. This is a functional painted atlas, not a technical diagram.
```
