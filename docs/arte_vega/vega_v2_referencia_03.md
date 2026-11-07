# Vega v2 — referência candidata 03: cabelo mais longo

21/10/2026. O usuário aprovou a revisão de expressão e apontou somente o cabelo como insatisfatório. Escolheu testar um corte mais longo. Esta revisão modifica apenas o cabelo da prancha 02, preservando as demais partes aprovadas.

Retorno posterior: cabelo aprovado com entusiasmo; braços e expressão reafirmados. A roupa foi apontada como próxima revisão por parecer de mecânica. A prancha 04 testa somente o figurino, preservando cabeça e braços desta referência.

## Arquivos e edição

- Candidata: `docs/arte_vega/vega_v2_referencia_03.png`.
- Alvo preservado: `docs/arte_vega/vega_v2_referencia_02.png`.
- Original da ferramenta preservado: `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-3924b4c1-2fd7-46a6-8601-56c6a868c641.png`.
- Skill `imagegen`, ferramenta integrada, edição localizada com uma imagem de referência/alvo; sem CLI/API externa.

A interpretação proposta é um corte preto na altura do queixo/início do pescoço, em camadas desalinhadas, mechas mais soltas e franja lateral, repetido no corpo inteiro e no retrato. Comprimento e acabamento desta candidata ainda aguardam avaliação; não foi feita uma alteração silenciosa do cânone de cabelo curto para cabelo até a cintura. A escolha do usuário por explorar maior comprimento orienta esta revisão.

## Verificação realizada

Alvo local 02 inspecionado antes da edição; saída integrada inspecionada visualmente. O novo cabelo é mais comprido nas duas vistas. Expressão sem sorriso, identidade facial, roupa, pose e os quatro desenhos dos braços mantêm visualmente a referência anterior. Não foi feita comparação pixel a pixel. Nenhum asset ativo, código ou regra foi alterado; nenhum teste de gameplay executado. Pranchas 01/02 e fontes anteriores foram preservadas.

## Prompt final

```text
Use case: identity-preserve / precise local hairstyle edit.
Input image 1 is the EDIT TARGET: an existing original character sheet for Vega. Edit the existing sheet, do not generate another character or redesign her.
Primary request: change ONLY THE HAIR in both appearances (full-body figure on the left and large portrait upper-right) to a LONGER CUT.
New hairstyle: natural black, a rough layered shaggy bob ending around the jawline and upper neck, clearly longer than the current short cropped curls. Heavy loose textured locks with a slight natural wave, uneven ends, an off-center part and an irregular side-swept fringe. A practical grown-out, slightly unruly cut, not a pristine salon bob, glamorous waves, a pixie, shaved side, mohawk, ponytail or brightly dyed hair. Keep both eyes and the stern eyebrows visible: fringe frames the face without concealing its expression. Same haircut and length in both views; allow hair to extend only into the immediate adjacent background/neck region as needed.
CRITICAL INVARIANTS: The face and expression have now been approved. Preserve exactly the same identity, skin tone, broad nose, face proportions, eyes, lowered tense brows, firm unsmiling mouth, guarded grumpy-protector expression, age, head angle and gaze. No smile, softening, charm, makeup or new scars/accessories.
The arms have also been approved: preserve both prosthetic arms on the full figure and both lower-right REPOUSO/COMBATE arm studies, all muscle fibers, graphite plates, cyan/magenta seams, joints, hand proportions and fingers. Do not move or repaint them.
Preserve clothing, boots, human body, pose, open protective hand gesture, background, composition, labels VEGA / REPOUSO / COMBATE, image dimensions, ink contours, shading, colors and lighting unchanged. Do not add views or text, do not modify anything below the heads. Changes must be localized to hair and the small background area immediately required by its new silhouette.
```
