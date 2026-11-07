# Vega v2 — referência candidata 02: expressão

21/10/2026. Edição localizada da referência 01. O usuário aprovou explicitamente os braços, mas apontou que a personagem parecia alegre/carismática em vez de rabugenta e protetora. A nova expressão ainda depende de sua avaliação.

Retorno posterior: o usuário aprovou a expressão (“perfeito”), apontando somente o cabelo como insatisfatório, e escolheu explorar um corte mais longo. A referência 03 altera apenas o cabelo; esta prancha 02 permanece preservada.

## Arquivos e escopo

- Revisão: `docs/arte_vega/vega_v2_referencia_02.png`.
- Alvo da edição e original preservado: `docs/arte_vega/vega_v2_referencia_01.png`.
- Fonte da ferramenta preservada: `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-d426ab31-c46d-442f-b618-81f749916fc6.png`.
- Skill `imagegen`, ferramenta integrada, edição com uma imagem de referência/alvo; sem CLI/API externa.

## Alteração solicitada

Retirar o sorriso das duas aparições do rosto, tornar o olhar desconfiado e as sobrancelhas mais tensas, com boca firme e leve leitura de cansaço. Manter humanidade e proteção, sem caricatura de raiva, dentes à mostra ou expressão de vilã. Preservar a identidade, pele, cabelo, corpo, roupa, pose, composição e, como restrição prioritária, o desenho dos braços aprovado pelo usuário.

## Verificação realizada

A referência local 01 foi inspecionada antes da edição e a saída integrada foi inspecionada visualmente. O retrato e o rosto da figura inteira perderam o sorriso; os braços e os estudos de repouso/combate mantêm visualmente seu desenho, disposição e componentes. Não foi feita comparação pixel a pixel nem declarada identidade binária entre regiões. Nenhum asset ativo, regra ou código do jogo foi alterado; nenhum teste de gameplay executado. O arquivo 01 permanece disponível para comparação.

## Prompt final

```text
Use case: identity-preserve / precise local expression edit.
Input image 1 is the EDIT TARGET, an existing original character reference sheet of Vega. Edit this sheet, do not generate a new design.
Primary request: change ONLY Vega's FACIAL EXPRESSION in BOTH appearances: the small face on the full-body figure at left and the large upper-right portrait. She currently looks cheerful, charming and smiling. Make her read as a GRUMPY PROTECTOR: guarded, impatient, stubborn, a little world-weary, ready to stand between someone vulnerable and trouble.
Specific expression: remove the smile and smirk entirely, close the mouth into a firm slightly downturned line while preserving her original lip shape. Lower and draw the inner brows mildly together, make the eyes watchful and slightly narrowed, relax the lifted smiling cheeks, use subtle short ink marks of tiredness below the eyes. A restrained stern expression with human warmth beneath it, not a villain's theatrical snarl. No teeth, grin, smugness, charming tilted smile, raised friendly brows or cartoon rage. She should look like 'I am not in the mood, but nobody is getting past me.'
Identity invariants: preserve exactly the same woman, age, skin tone, face proportions, broad nose, hair, hairline, eyes, head angles and gaze directions. Only modify the muscles/expression of her face.
CRITICAL PRESERVATION: The user LOVES THE ARMS. Preserve ALL prosthetic arms exactly as shown: both arms of the full-body figure, the two lower-right studies, their anatomy, muscle-fiber layout, plate shapes, proportions, fingers, cyan/magenta accents and the difference between REPOUSO and COMBATE. Do not redesign, enlarge, repaint or move them. Keep the body pose and open protective hand unchanged. Keep clothing, boots, body proportions, composition, background, labels VEGA / REPOUSO / COMBATE, image dimensions, ink style, colors, lighting and all other elements unchanged. Do not add scars, tattoos, accessories, weapons, new views or extra text. Keep changes localized to the two faces.
```
