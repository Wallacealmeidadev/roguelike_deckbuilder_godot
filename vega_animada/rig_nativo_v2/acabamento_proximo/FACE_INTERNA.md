# Braço distante: face interna, punhos pareados e folga — 22/10/2026

Revisão posterior: [DEDAO.md](DEDAO.md) registra o polegar recolhido na mão dorsal; somente esse recorte passou à revisão 02. A palma continua na 01. Capturas desta primeira revisão foram preservadas, com novas imagens na pasta de evidências 02.

## Estado observado, regra e hipótese

Relato do usuário: diferença entre as mãos, mão distante entrando no ombro e suspeita de todas as peças voltadas para o lado oposto. Inspeção confirmou que só a mão distante tinha vista palmar própria; o braço inteiro ainda reutilizava o atlas externo espelhado, com tonalidade mais escura. A etapa anterior repintava somente o lado próximo. Não foi constatada inversão matemática de todos os ossos.

Regra: conservar identidade e guarda de luta aprovadas, dorso próximo/palma distante, comprimentos fixos, expansão só das fibras e alternância imediata por carta válida. A referência unificada continua mestre de estilo, não substituto do rig.

Hipótese de correção: uma face interna específica, punhos derivados juntos e menor dobra do cotovelo distante podem resolver a leitura contraditória sem refletir novamente o esqueleto. Capturas e testes sustentam a folga, não provam anatomia/perspectiva perfeita ou aprovação artística.

## Aplicação na prévia

Mesma entrada: abrir `preview.tscn` desta pasta e F6. F5/main e provas históricas continuam anteriores.

- `camadas_internas_01.png`: atlas interno do braço distante, 1774×887 RGBA. Biceps de fibras, bordas internas das placas e outra face do conector; mantém registro, eixos, encaixes e geometria do rig. Duas malhas distantes, cinco sprites de junta/placas e três núcleos usam a textura nova. Não é simplesmente inverter UV/escala de todas as peças.
- `punhos_pareados_01.png`: dorso e palma produzidos juntos, 1774×887 RGBA. Recortes registrados pelo centro de cada soquete; mesmo fator local .13 e reflexão/projeção .92 já existente no braço distante. Ambos mantêm posição (-8,0), eixo do antebraço e material seletivo comum; núcleos antigos das luvas ficam ocultos. Recortes/offsets compensam a composição real gerada, não posições ideais presumidas.
- Guarda distante: cotovelo local abre 23° (168° → 145°), preservando a amplitude discreta da respiração. Mesma correção em preparo/retorno e na guarda enquanto o outro braço ataca ou recebe dano. Extensão do soco distante permanece -7°. Demais ossos, comprimentos, tempos (560 ms soco / 2.4 s respiração), captura interruptível, apoio e Combo preservados.
- Biblioteca da respiração é duplicada antes da correção; recursos compartilhados/base não mudam. Retorno/reset/reduzido têm a mesma guarda corrigida. Tom do braço distante passa de (.82,.87,.94) para (.94,.96,1), mantendo profundidade por sobreposição/projeção sem fazer a palma parecer outro material.
- A aplicação anterior de ombro/braço próximo continua. Flag `corrigir_braco_distante` permite comparar com aquela etapa; `mostrar_acabamento` controla o acabamento próximo, não essa nova flag.

Limite: vista interna/palma são desenhos 2D fixos seguindo os ossos. Não há rotação longitudinal 3D ou troca de vistas durante o soco. A pose e o acabamento ainda precisam de avaliação no jogo; não afirmar que todas as junções/perspectivas ficaram finais.

## Verificação realmente executada

Godot 4.7.2.stable.official.ed1daf0bf, GL Compatibility.

- `test_acabamento_proximo`: headless e OpenGL/fixed-fps 60, zero falhas/exit 0. Compara todos os ossos em 57 amostras por clipe (respiração, dois socos, dano), Combo 0/10; a única mudança local de osso permitida é a dobra declarada do cotovelo distante. Tempos, extensão, apoio, geometria/perfis de expansão, pesos da pele e transformações das placas preservados. Verifica recursos antigos não contaminados, sequência/reduzido/reset.
- GPU: pintura do ombro continua com 922 pixels, zero fora da silhueta original. Punho distante isolado comparado com a pele quente do corpo em 0/.6/1.2/1.8/2.4 s: máximo de zero pixels sobrepostos. É amostragem da guarda, não teste contínuo de colisão 3D. Distância punho/ombro também conferida em 57 amostras por ação.
- `test_vega_nativa_combate -- --acabamento`: headless e OpenGL, zero falhas/exit 0. Cartas reais, custos/dano/Combo, ataques alternados, interrupção, defesa/inválida, dano recebido, reduzido, reset/mapa, chão/UI em duas resoluções. Teste padrão sem variante passou headless.
- `test_combo_nativo`, `test_encaixes_nativo`, `test_apoio_corporal`: headless/fixed-fps 60, zero falhas/exit 0.
- Captura OpenGL com `--acabamento --alternar --face-interna`: 32 PNGs em `docs/evidencias_vega_face_interna_01/`, 1920×1080 e 1024×576. Novo `test_acabamento_proximo -- --capturar` salvou seis imagens ampliadas (guarda e impactos, Combo 0/10). Inspecionados guarda/impactos dos dois lados 1920, guarda 1024 e ampliadas guarda 0/impacto distante 10. Não houve revisão de vídeo ou suíte completa.
- Importação exit 0. Teste isolado OpenGL encerrou sem avisos. Main/editor/capturas ainda emitem avisos conhecidos de recursos/RID/fontes/ObjectDB no encerramento; não resolvidos nesta etapa.

Exercício pequeno: em `vega_prova.tscn`, desmarcar `corrigir_braco_distante`, salvar e executar `preview.tscn` com F6 para comparar a guarda antiga. Reativar depois. Não mudar comprimento dos ossos para avaliar a arte.

## Proveniência

Skill imagegen, ferramenta embutida, sem CLI/API direta. Imagens de entrada vistas antes de gerar. Copiados os PNGs integrais, sem edição externa de pixels; alfa do canto zero conferido com leitura de imagem. Fontes anteriores e mestre preservadas.

Atlas interno original: `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-00c1cb60-ac31-4cc4-a20e-2de4b19ef068.png`.
Destino: `vega_animada/rig_nativo_v2/acabamento_proximo/camadas_internas_01.png`.

Punhos original: `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-9ca6efc9-b8a2-40f3-8cf8-fceabc17a409.png`.
Destino: `vega_animada/rig_nativo_v2/acabamento_proximo/punhos_pareados_01.png`.

### Prompt integral — atlas interno

```text
Use case: precise-object-edit.
Asset type: transparent 2D game rig component atlas, alternate INNER-facing view of the same synthetic arm.
Image 1 is the edit target and FIXED LAYOUT template (1774x887, 2:1). Image 2 is the approved Vega comic style/material reference, especially her viewer-right arm with palm facing us.
Preserve the canvas aspect, component bounding boxes, longitudinal directions and all joint endpoints in Image 1. Change ONLY the view of the prosthesis parts from outer armor to inner/flexor face, as if rotating the cylindrical arm pieces around their long axes, NOT rotating or reflecting their 2D positions. Each piece remains disconnected on transparency.
Bottom-left upper arm: same cyan shoulder collar, same braid silhouette and endpoints, but inner biceps face visible. Replace broad outer silver plate with braided dark synthetic muscle, leaving only a narrow graphite armor rim at the outer edge. Upper middle forearm bundle: inner flexor face, broad grouped dark braids. Top-left filler bundle remains a fully opaque usable braid sample with same shape. Middle-right elbow ring: same position/ellipse/attachment points, now inner face with dark graphite bridge and restrained cyan seam; no giant hollow opening. Bottom row three separate armor pieces: show their slim beveled INNER edges, dark graphite, narrow highlights, not the broad bright outer plate faces. Keep each inside its original cell with connection endpoints intact. The top-right human shoulder cap remains unchanged.
Match Image 2's deliberate comic ink, muted graphite, grouped fibers, two/three shadow values, warm upper-left light, restrained cyan and magenta seams. This is the same model of prosthesis from the opposite surface, not another arm design.
Constraints: do not assemble parts, do not add hands or body or arrows or labels or text. No scene, no floor, no white/checkerboard background. Actual transparent background. Avoid chrome, noisy microstrands, photorealism, bright white armor. Preserve atlas registration and all transparent margins as closely as possible.
```

### Prompt integral — punhos pareados

```text
Use case: stylized-concept.
Asset type: one transparent paired-fist sprite atlas for Vega's existing 2D fighting rig. Two orthographic-ish matching views of a closed cybernetic fist, not human anatomy, not open hands.
Input 1: approved Vega STYLE and hand-model reference. Input 2: current palm texture as MODEL reference only; too much detail, simplify to Input 1 style. Input 3: current body/dorsal fist for model reference only, do not draw any body.
Composition: wide 2:1 canvas, two equally sized square cells side by side. LEFT cell: dorsal/back-of-hand view of her NEAR closed fist. RIGHT cell: PALMAR/front-of-palm view of her FAR closed fist. Show the SAME hand design/proportions, same total fist width, same cuff width, same wrist-to-knuckle length. Both upright: four curled knuckles at top, wrist connection at bottom, wrist axis straight vertical, no tilt, no perspective foreshortening. Palm view curled fingertips and thumb visible against padded graphite palm; NOT a back plate on palm. Dorsal view a single graphite back plate, articulated four knuckles, thumb crossing outside fingers. Right view thumb on image-left, left view thumb on image-left as in reference guard; no extra fingers.
Registration: each fist centered horizontally in its own half; knuckles at 18% cell height, cuff socket center at 82% cell height, overall silhouette occupies 62% cell width. Matching open dark cuff connection at bottom, with only a short sleeve, not a forearm. Generous clear transparent margins between and around both pieces; no overlapping.
Style: SAME thick purposeful black comic ink as Input 1, restrained large graphite plate highlights, broad synthetic braid groups at side edges, simple dark palm pads, tiny cyan wrist seam and a small magenta connector. Coherent upper-left illumination on BOTH views. Matte muted grey, not white/chrome; identical rendering detail and scale across both fists. This is one matching pair, not different gloves.
Constraints: true transparent background; only the TWO closed fists/cuffs, no arms, face, character, scenery, shadows on ground, labels, lines, numbers, text, border or checkerboard. No giant sleeve rings, no photorealism, no fine crosshatch microtexture, no extra parts.
```

