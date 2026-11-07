# Golpe — prova de impacto, 21/10/2026

O usuário considerou boa a linguagem gráfica da primeira prova, mas apontou o braço estranho e propôs evitar desenhar a personagem em toda carta. Autorizou a nova composição: somente punho mecânico e pulso curto atingindo uma chapa, com deformação localizada, sem eletricidade e sem desintegração. Depois aprovou a imagem resultante e autorizou sua aplicação.

Estado atual: arte integrada somente a Golpe em `botao_carta.gd` e ao recurso de referência de `carta.tscn`. O nome do arquivo mantém `_prova` para preservar seu caminho; a imagem está aprovada. Os outros ataques continuam usando `arte_golpe_vega.png` como arte provisória. A seleção central de arte atende mão, recompensas e descanso sem alterar seus efeitos.

## Arquivos

- Nova candidata: `assets/ui/runtime/cartas/arte_golpe_impacto_hq_prova.png`.
- Primeira prova preservada: `assets/ui/runtime/cartas/arte_golpe_vega_hq_prova.png`.
- Arte do jogo normal preservada: `assets/ui/runtime/cartas/arte_golpe_vega.png`.
- Evidências desta versão: `docs/evidencias_golpe_impacto_hq/`.
- Prévia: `tests/capturar_prova_golpe_hq.gd`, com argumento de usuário `--impacto`.

Godot 4.7.2: `--path . --script res://tests/capturar_prova_golpe_hq.gd --rendering-method gl_compatibility -- --impacto`. Sem esse argumento, a prévia continua mostrando a primeira prova. Ambas alteram somente a textura nas instâncias de Golpe daquela execução, não a seleção de arte do jogo normal nem as outras cartas que compartilham a arte antiga.

## Verificação executada

Godot `4.7.2.stable.official.ed1daf0bf`, OpenGL Compatibility: execução com código 0, 12 PNGs salvos com OK. Comparação com a arte ativa em repouso/foco, em 1920×1080 e 1024×576, mais quatro recortes do quadro real. Foram inspecionados os recortes da candidata nas duas resoluções e a cena completa em 1024. Sem erros de script/parse observados; persistiram os avisos conhecidos de RID, texturas, ObjectDB e recursos no encerramento. A suíte de regras não foi repetida porque esta prova não altera o combate. Testes e capturas não equivalem à aprovação artística.

## Geração e prompt final

Skill `imagegen`, ferramenta integrada, sem CLI. As referências foram usadas somente para traço/paleta e desenho industrial do punho. Original preservado em `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-2e8cd43a-f684-425a-b6a7-b449f36cd85f.png`; cópia da candidata no projeto.

```text
Use case: illustration-story.
Asset type: one square artwork for GOLPE, a basic physical attack card in a cyberpunk comic deckbuilder. Illustration only, no typography or border.
Reference image 1: INKING, FLAT COLOR AND PRINT COMIC STYLE reference only. Do NOT draw the woman or reuse the full-body composition.
Reference image 2: industrial prosthetic FIST DESIGN reference only: chunky matte off-white/gray armor, black joints, red brackets, yellow-black hazard accents. Do NOT draw the character.
Scene and subject: a single closed industrial mechanical fist and a SHORT WRIST enter from the left and strike a riveted blue-gray steel sheet on the right. Tight close-up, almost side-on three-quarter view. Show a coherent clenched fist: four curled fingers and one tucked thumb, a short cylindrical wrist aligned behind the fist. No elbow, shoulder, torso, head, skin or whole person. This is a simple mechanical punch, not a gun, drill, engine or hammer.
Composition: ONE clear diagonal gesture left-to-right, knuckles making visible contact with the panel just right of center. The steel sheet occupies the right third with a small localized inward dent at contact; it stays intact, not torn apart. Fist occupies the left/central half and has a bold readable silhouette. Keep fist and contact within central 80 percent so both survive a near-square card crop. Background is simple muted navy and a warm off-white flat wedge behind the punch. Three or four tapered black speed strokes follow the wrist toward contact. A compact off-white jagged COMIC IMPACT BURST with black edges marks contact, not a ball of light. No sparks needed.
Medium: bold brush-ink comic panel with heavy varied contour, large connected solid black shadow shapes, flat color fills, two value levels per material, very sparse coarse halftone in secondary shadows. Matte steel with single hard light planes, no reflective rendering. A small palette of ink-black, muted navy/steel blue, warm off-white, existing red and hazard yellow. Graphic, hand-drawn, clear at 85 pixels wide. Prioritize the fist and its contact point over mechanical detail.
Constraints: no character, no full arm, no anatomy study, no extra hands, no detached floating fingers, no sprawling background, no cinematic or 3D rendering, no airbrush gradients, no glossy chrome, no electricity or lightning, no glowing energy, no debris shower, no ruptured panel, no typography, sound-effect letters, logo, watermark, card frame or UI. The subject is an ordinary heavy PUNCH, not a finishing explosion.
```
