# Vega v2 — referência candidata 04: figurino de rua

21/10/2026. O usuário aprovou cabelo, braços e leitura confiante/rabugenta da referência 03, mas considerou que a roupa parecia de mecânica. Também demonstrou interesse em ver a transição dos braços de repouso para combate animada. Esta etapa testa somente figurino; não implementa a animação.

## Arquivos

Atualização posterior (21/10/2026): o usuário aprovou o figurino com “perfeito, tá bem melhor, agora sim podemos seguir”. As hipóteses e verificações abaixo registram a etapa de geração. A prova técnica posterior está em `vega_animada/braco_v2/preview.tscn`; a aprovação da prancha não se estende automaticamente às suas camadas derivadas ou à animação.

- Candidata: `docs/arte_vega/vega_v2_referencia_04.png`.
- Alvo preservado: `docs/arte_vega/vega_v2_referencia_03.png`.
- Original da ferramenta preservado: `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-3ec42669-c6cd-4b2e-80ba-9eeb13dcc26c.png`.
- Skill `imagegen`, ferramenta integrada, edição com uma imagem-alvo; sem CLI/API externa.

## Hipótese de roupa

Regata de tecido carvão, calça urbana sem bolsos de carga e camisa vinho/plum amarrada na cintura. Remover a gola alta e o fechamento diagonal de uniforme, preservando roupa prática e silhueta humana. Atualizar o trecho de roupa do retrato para corresponder. Não alterar cabelo, rosto, expressão, pose, botas nem os quatro desenhos dos braços. O novo figurino ainda aguarda avaliação.

## Verificação realizada

Alvo local inspecionado antes da edição; saída integrada inspecionada visualmente. Corpo inteiro e retrato mostram a nova regata; calça sem bolsos utilitários e camisa na cintura aparecem no corpo. Cabeça e braços mantêm visualmente identidade e componentes anteriores. Não foi feita comparação pixel a pixel. Assets ativos, código, regras e animações do jogo permanecem intactos; nenhum teste de gameplay foi executado.

## Sobre a transição dos braços

Repouso/combate continuam sendo estudos visuais, não uma animação validada. Hipótese para uma prova técnica posterior: deformar localmente os volumes dos feixes e deslocar placas por partes, preservando mão/juntas e os componentes aprovados. A prancha por si só não demonstra que a transição funciona, e duas imagens não formam automaticamente um rig compatível. Antes da integração, validar uma transformação reversível de um único braço, sem autoridade sobre custo, dano ou tempo de resolução do combate. Não prometer a transformação pronta nem redesenhar os braços para contornar dificuldades técnicas.

## Prompt final

```text
Use case: identity-preserve / precise local outfit edit.
Input image 1 is the EDIT TARGET, an original Vega character sheet. Change ONLY CLOTHING to make her look like a streetwise protective fighter rather than a mechanic/workshop employee. Preserve the existing sheet and character.
New outfit on full-body figure: replace the high-collared navy wrap work-jacket with a plain washed-charcoal sleeveless cotton tank/tee, broad shoulder straps and a low simple round neckline, relaxed practical fit, hem at waistband, no bare midriff. No standing collar, diagonal uniform closure, armor panels, logos or tool loops. Replace navy cargo/work trousers with plain dark graphite urban trousers, relaxed at thighs and tapered toward the same boots, normal fabric folds but NO thigh cargo pockets, utility flaps, knee patches or workwear panels. A small soft WINE/PLUM overshirt is casually tied around the waist by its sleeves, the two short uneven fabric tails lying at the hips/upper thighs; a personal streetwear accent, not a utility belt, apron, cape or elaborate martial-arts costume. Keep the existing boots, body build, leg contours and grounded stance. Garments are matte everyday cloth, not shiny leather or a military uniform.
Update ONLY the visible neckline/clothing in the upper-right portrait to match the plain charcoal sleeveless shirt. Preserve her shoulders and neck anatomy.
CRITICAL LOCKED ELEMENTS: keep the approved longer black shaggy hair EXACTLY as in the target in BOTH views. Preserve face identity, skin tone, head angles, gaze, confident grumpy-protector expression, firm unsmiling mouth and tense brows. Do not make her cheerful, younger, glamorous or more aggressive.
Keep ALL FOUR arm drawings EXACTLY: both prosthetic arms of the figure and the lower-right REPOUSO/COMBATE studies, their muscle fibers, shapes, joints, hands/fingers, graphite plates, cyan/magenta seams and differences of volume. Do not cover any of the arms with sleeves or cloth. Keep the pose and open protective hand gesture unchanged.
Preserve layout, background, labels VEGA / REPOUSO / COMBATE, dimensions, comic ink style, shadows and lighting. Do not add weapons, jewelry, tools, tattoos, scars, props, new views or new text. Only outfit regions may change; the character's approved face, hair and arms are not being redesigned.
```
