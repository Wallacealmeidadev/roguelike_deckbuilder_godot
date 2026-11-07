# Vega v2 — prova isolada de transformação

21/10/2026. Godot 4.7.2.stable.official.ed1daf0bf. Não é o sprite final nem um rig completo.

Atualização de avaliação: o usuário aprovou a transformação básica e autorizou continuar com a resposta aos stacks de Combo. Essa extensão agora existe apenas nesta prévia, ainda não foi avaliada pelo usuário e não está conectada ao estado real de combate. O registro original de avaliação pendente abaixo descreve o momento anterior à aprovação da base.

## Versão atual: dez passos iguais de tensão — 21/10/2026

Avaliação posterior: usuário aprovou esta progressão linear e autorizou continuar. A montagem corporal posterior está em `vega_animada/corpo_v2/preview.tscn` e ainda não foi aprovada. As verificações e ressalvas abaixo registram a produção desta prova; o braço continua preservado.

Por sugestão do usuário, substituída a curva assintótica por `clamp(Combo, 0, 10) / 10.0`: 1 Combo = 10%, 2 = 20%, 5 = 50%, 10 ou mais = 100% da **amplitude adicional de tensão**, não do tamanho inteiro do braço. O contador continua sem teto; somente a apresentação satura em 10. O valor e a porcentagem-alvo aparecem juntos, imediatamente. Não é porcentagem interpolada de cada frame.

Use `+1`, `+3`, `10` e `Consumir` na prévia F6. O botão 10 coloca diretamente no máximo. Para conferir a fronteira, pressione 10 e depois +1: o contador sobe para 11, mas o braço mantém a mesma pose. Mantidos amplitudes, expansão básica de combate, 200 ms, curva de interpolação existente, interrupção e movimento reduzido. A skill `animate` foi usada para preservar esse comportamento temporal; linearidade aqui se refere à relação Combo/tensão, não a substituir a suavização do movimento por velocidade constante.

Verificação desta revisão: `test_braco_v2_combo`, `test_braco_v2` e `test_jogador_combate` passaram, exit 0. O primeiro exige todos os passos 0–12, 100, 1 milhão e int64 máximo, geometria proporcional em passos iguais, igualdade exata da pose 10/100 e ausência de reinício ao mudar 10→11 durante a animação. Mantidos testes de âncoras, UVs, interrupção, retorno e movimento reduzido. A prévia confere botão 10 e rótulos de porcentagem; layout testado nas duas resoluções. Sem suíte completa ou teste de gameplay pelo usuário.

Dezoito capturas novas em `docs/evidencias_braco_v2_combo_linear/`, preservando evidências anteriores. Inspecionadas Combo 5 em 1024×576 e Combo 10/11 em 1920×1080. [Vídeo linear](../../docs/evidencias_braco_v2_combo_linear/ciclo_linear.avi): 179 frames, 30 FPS, 1152×648; sequência 0→1→2→5→9→10→11→0→repouso. Capturador `tests/capturar_braco_v2_combo.gd` agora grava esta versão. Resultado visual ainda aguarda avaliação. `git diff --check` passou.

Exercício opcional, sem mudar a relação escolhida: comparar apenas `contracao_combo_antebraco` 0.14 versus 0.10 com Combo 5 e 10; depois restaurar se preferir.

## Histórico: primeira extensão de tensão por Combo — 21/10/2026

Use os botões `+1`, `+3`, `100` e `Consumir`. Ganhar cargas na simulação ativa o modo de combate, se necessário. Consumir zera a tensão, mas mantém a base de combate. Sair do combate ou levar o slider ao repouso limpa as cargas simuladas. O botão `100` define um valor alto para comparar a saturação, não um limite de jogo.

Conceito: duas camadas independentes de estado compõem uma única geometria. A ativação original continua com seus parâmetros aprovados; `tensao_combo` acrescenta contração lateral suave dos feixes e pequena abertura rígida das placas. Não há flexão da articulação nem novo asset. O contador é atualizado imediatamente e não depende do fim da animação.

Escolha técnica candidata: tensão = `Combo / (Combo + 3)`, calculada em float para evitar overflow da soma com inteiros extremos. Combo 3 produz metade da tensão visual; valores altos se aproximam do máximo. Essa curva não impõe teto ao recurso. A amplitude adicional máxima da malha é 0.18 no bíceps e 0.14 no antebraço, multiplicada pela ativação de combate e pelo perfil que zera nas juntas. Abertura adicional das placas: até 8/8/4 px locais, sem escala. Amplitudes e curva continuam ajustáveis após avaliação; não são balanceamento.

A skill `animate` orientou indicação de estado com resposta frequente e contida: Tween nativo de 200 ms, mesma curva ease-in-out da base, sem pulsação contínua ou bounce. Alterar Combo retargeta do valor atual e mata apenas o Tween de tensão anterior; o Tween de ativação permanece independente. Repetir o mesmo destino não reinicia movimento. Movimento reduzido resolve os dois destinos imediatamente. Não há conservação física de velocidade nem garantia de integração corporal.

Verificação desta extensão na Godot 4.7.2: `test_braco_v2_combo` e `test_braco_v2` com 0 falhas. Cobre 0/1/3/100/1 milhão/máximo de int64, amplitude limitada, UVs e âncoras das duas malhas, faces não invertidas, placas sem escala, retorno exato à base, consumo durante ganho, rajada de destinos, animações simultâneas, repetição, limpeza ao sair/slider, negativos e movimento reduzido. Os controles e a composição são conferidos em 1024×576 e 1920×1080. `test_vega_playtest`, `test_hud_conceito_ativo`, `test_jogador_combate` e `test_resolucao_cartas` também passaram com exit 0. Os dois primeiros mantêm mensagens de objetos/recursos em uso ao encerrar; não corrigidas aqui. Sem suíte completa.

Doze capturas novas, preservando a evidência anterior, em `docs/evidencias_braco_v2_combo/`; inspecionadas base/100 em 1920×1080 e Combo 3 em 1024×576. [Vídeo do Combo](../../docs/evidencias_braco_v2_combo/ciclo_combo.avi) gravado na cena real: 122 frames, 30 FPS, 1152×648, sequência 0 → 1 → 3 → 100 → 0 → repouso, encerramento normal. Gravação e testes não substituem avaliação da sensação. Capturador reproduzível: `tests/capturar_braco_v2_combo.gd`; argumento `--filmar-combo` para a sequência animada. `git diff --check` passou.

Exercício pequeno: altere somente `contracao_combo_antebraco` de 0.14 para 0.10 em `braco_prova.gd`, execute F6 e compare Combo 0/3/100. O que avaliar: intensidade sem aparência de borracha, placas acompanhando o volume e consumir durante ganho sem salto.

## Ver e operar

Abra `vega_animada/braco_v2/preview.tscn` e execute a cena com **F6**, não o projeto inteiro. Compare a referência à esquerda com a reconstrução à direita. “Reproduzir ciclo” faz repouso → combate → repouso; “Ativar combate” permite inverter durante a transição. O slider expõe qualquer pose intermediária. “Movimento reduzido” resolve o destino imediatamente. Controles nativos também aceitam foco por teclado; não há hover animado.

Vídeo real da cena: [ciclo.avi](../../docs/evidencias_braco_v2/ciclo.avi), 3 segundos, 90 frames, 30 FPS, 1152×648 (viewport proporcional do projeto). Capturas PNG de repouso, 50%, combate, retorno e movimento reduzido em 1024×576 e 1920×1080 na mesma pasta. O vídeo foi gravado com a Godot; log de gravação não equivale a aprovação do ritmo pelo usuário.

## Conceito e limites

- Observado: o usuário aprovou o figurino 04 depois de estabilizar braços, rosto e cabelo. A prancha continua preservada.
- Regra: corpo humano com braços protéticos; expansão de musculatura artificial em combate. Animação não decide dano, Combo, custo, alvo ou resolução de cartas.
- Hipótese em teste: deformação lateral localizada dos feixes com pontas fixas, placas movidas rigidamente e mão/cotovelo ancorados. Avaliar se isso transmite força e mantém a identidade antes de integrar ao corpo.

Esta reconstrução não é um recorte pixel a pixel da prancha: as camadas são uma derivação gerada. Textura, perspectiva do cotovelo e proporção dos volumes ainda precisam de avaliação artística. Sem flexão do cotovelo/dedos, soco, roupa, segundo braço, animação de corpo ou integração ao combate. Não reutiliza as peças industriais da Vega antiga.

## Implementação

`braco_prova.gd` contém apresentação e `preview.gd` somente operação do laboratório. Não instancia main, estado da run nem resolutor de cartas. Não altera a cena principal.

A skill `animate` orientou a finalidade (indicação visual de estado, demonstração ocasional), a reversão do valor atual e a alternativa reduzida. Implementação nativa: dois Polygon2D com 32 faixas e UVs estáveis, Sprite2D para placas/juntas, Tween de 0,5 s no percurso completo, curva cubic-bezier(0.77, 0, 0.175, 1). Percursos parciais reduzem a duração proporcionalmente, com piso de 0,1 s. Sem bounce; repetição do mesmo destino não reinicia a transição. A inversão não salta de pose, mas não conserva velocidade como uma mola física.

A expansão chega a 45% no centro do bíceps e 38% no centro do antebraço da malha, caindo a zero nas extremidades. Não significa aumento idêntico de todo o contorno visível. Placas abrem 16/22/10 px no sistema local e giram sem escalar. Um trecho de fibra atrás do anel cobre a ligação do cotovelo.

Recortes do atlas são explícitos: o arquivo gerado tem margens desiguais, poeira de alfa quase zero e uma ponta próxima da divisão de filas. Usar get_used_rect cegamente separava as peças. O contorno da placa superior é recortado por geometria em runtime; sua célula trouxe fibras indevidas. PNG-fonte não foi retocado por scripts.

## Verificação executada

- `tests/test_braco_v2.tscn`: 0 falhas; UVs e âncoras, escala rígida de placas, crescimento, retorno sem deriva, curva monotônica, inversão em andamento, repetição do destino, alternativa reduzida, clamp do slider, controles da cena e interrupção do ciclo. Confere controles e separação entre mão/legenda nas duas resoluções.
- `test_vega_playtest` e `test_hud_conceito_ativo`: ambos 0 falhas, exit 0. Os dois ainda reportam objetos/recursos em uso no encerramento; não foram corrigidos nesta prova.
- Dez capturas OpenGL Compatibility na RTX 3060, salvamento OK; inspecionados repouso/combate e composição pequena. Sem teste de gameplay pelo usuário, sem suíte completa e sem aprovação artística inferida dos testes.
- Importação final headless: exit 0, sem erro de parsing, com mensagens de RID/recursos em uso ao encerrar. Novo teste repetido depois da importação: 0 falhas, inclusive o término do ciclo completo. `git diff --check` passou.

Conferência de sensação: execute o ciclo, inverta no meio e use o slider perto de 25/50/75%. Procure placas se soltando, volume de “borracha” e mão crescendo. Para exercício pequeno, altere apenas `expansao_antebraco` de 0.38 para 0.30 no script e compare; depois restaure se preferir o original.

## Fonte e geração das camadas

Skill `imagegen`, ferramenta integrada (sem CLI/API externa), uma imagem de referência local inspecionada: `docs/arte_vega/vega_v2_referencia_04.png`. Saída transparente 1774×887 salva no projeto em `vega_animada/braco_v2/camadas.png`. O alfa real foi verificado. Original preservado:

`C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-297d8b78-8538-46f8-8790-b2595faaba08.png`.

Prompt final enviado:

```text
Use case: precise-object-edit / background-extraction.
Asset type: production 2D cutout animation PARTS ATLAS, transparent PNG, wide landscape 2:1 canvas, a strict uniform grid of FOUR COLUMNS and TWO ROWS (8 equal square cells). No drawn cell borders, labels, writing, background, shadows on the canvas, or assembled character.
Input image 1 is the APPROVED character design reference. Use ONLY the lower arm study labeled REPOUSO (the LEFT of the two isolated arm studies). Preserve its exact graphite/dark-blue armor, black braided synthetic muscle fibers, cyan seams, small magenta latch and articulated proportional hand. This is asset preparation, not a redesign.

Separate that ONE arm into EIGHT non-overlapping pieces, one piece centered inside each equal cell, with generous fully transparent padding and no pixel crossing a cell boundary. All parts retain the SAME front-three-quarter view and anatomy, arranged proximal end up, distal end down; do not mirror. Each piece is large and readable in its cell. Where armor is removed, finish the black fiber surface underneath so the part can be animated without holes.

ROW 1, left to right:
1. UPPER ARM muscle core only, an elongated bundle of dark braided synthetic fibers from shoulder socket to elbow. NO gray armor plate, no skin, no elbow ring, no hand.
2. FOREARM muscle core only, the elongated dark braided fiber bundle from elbow to wrist, narrowing at both ends. NO outer armor plates, no elbow ring, no wrist or hand.
3. ELBOW locking collar alone: the original short cyan-edged dark-blue elliptical ring with its small magenta side latch. Hollow central opening genuinely transparent. NO adjacent muscle or arm.
4. WRIST CUFF AND COMPLETE HAND together as one rigid cutout, preserving the original relaxed downward hand pose, five articulated fingers, dark graphite plates and cyan details. No forearm muscle.

ROW 2, left to right:
5. The UPPER ARM outer armor plate with its small cyan shoulder-edge cap, isolated from the muscle core. Preserve its shape and highlight planes.
6. The largest, uppermost swept-back FOREARM outer graphite armor plate alone.
7. The middle swept-back FOREARM outer graphite armor plate alone.
8. The lowest swept-back FOREARM outer graphite armor plate alone, stopping before the wrist cuff.
Do not merge any of these pieces or repeat whole arms in cells. Do not invent extra machines, skin, large fists, pipes, white metal or yellow hazard stripes. Keep the reference's comic ink line weight, flat shaded dark materials and limited cyan/magenta accents. The purpose is to reassemble the SAME APPROVED ARM and deform only muscle cores while moving rigid plates independently. All empty canvas must have true alpha transparency; no checkerboard baked into the image.
```

## APIs oficiais consultadas

[Polygon2D e UVs](https://docs.godotengine.org/en/4.7/classes/class_polygon2d.html), [Image e limites de alfa](https://docs.godotengine.org/en/4.7/classes/class_image.html), [Movie Maker e gravação nativa](https://docs.godotengine.org/en/4.7/tutorials/animation/creating_movies.html).

