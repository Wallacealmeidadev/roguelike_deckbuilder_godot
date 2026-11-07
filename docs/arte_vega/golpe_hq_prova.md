# Golpe — prova de direção de arte, 21/10/2026

O usuário aprovou fazer uma única prova de Golpe antes de expandir a linguagem às outras cartas e arenas. A composição da HUD e as mecânicas ficam preservadas. Esta imagem é candidata, não arte final aprovada.

## Arquivos e reprodução

- Candidata: `assets/ui/runtime/cartas/arte_golpe_vega_hq_prova.png`.
- Referência de identidade: `ui_hq_v1/assets/personagens/vega_combate_corpo_inteiro.png`.
- Arte anterior preservada: `assets/ui/runtime/cartas/arte_golpe_vega.png`.
- Capturas: `docs/evidencias_golpe_hq/`, geradas por `tests/capturar_prova_golpe_hq.gd`.
- Executar pela Godot 4.7.2: `--path . --script res://tests/capturar_prova_golpe_hq.gd --rendering-method gl_compatibility`.

O script instancia a cena real, cria uma mão de apresentação e troca somente a textura de Golpe nas instâncias daquela execução. Não altera o recurso original nem a seleção de arte do jogo normal. Compara repouso/foco em 1920×1080 e 1024×576; os recortes de carta vêm do quadro renderizado, sem ampliação artificial.

## Critério da prova

Contorno de tinta visível, sombras pretas recortadas, redução de renderização/brilho, silhueta legível em miniatura e identidade reconhecível de Vega. O rosto e o braço precisam sobreviver ao recorte real da carta. Textura de impressão e linhas de movimento são subordinadas à ação. Não estender às outras cartas nem declarar o estilo aprovado sem avaliação do usuário.

## Geração

Skill `imagegen`, ferramenta integrada; sem CLI/API externa. Nova composição usando a imagem de Vega como referência de identidade, não copiando a pose. O original da geração foi mantido em `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-978d9583-c42b-42c4-8986-c216b8ca7c55.png` e a candidata foi copiada para o projeto.

Prompt final:

```text
Use case: illustration-story.
Asset type: one square illustration for the existing GOLPE attack card in a cyberpunk deckbuilder. Art only, no card frame, text or UI.
Input image 1 is a CHARACTER IDENTITY reference, not a pose to copy. Depict exactly this Vega: short messy black bob above the neck, angular face, small cheek bandage, black sleeveless cropped top with tiny cyan chest chevron, two heavy industrial prosthetic arms with off-white/gray armor plates, black joints, red brackets and yellow-black hazard marks. Do not redesign her as a different woman.
Scene: a single decisive close-range mechanical punch in the docks. New composition: waist-up three-quarter side view, Vega on the left driving one arm horizontally toward the right, opposite fist tucked near her torso. Face and punching forearm both immediately identifiable. Fist takes roughly one quarter of image, not a giant fist obscuring everything. Clear shoulder-elbow-wrist connection, closed mechanical fist and believable boxing posture. No opponent necessary; the attack continues out of frame. Keep face, shoulder and fist within the central 85 percent so a small near-square card crop retains them.
Style/medium: a DRAWN, INKED PRINT COMIC PANEL, assertive brush-pen contour with varied line weight; broad connected solid black shadow masses; angular flat shadow shapes with only two value levels per material. Steel is matte flat cool gray with one hard white highlight, not rendered reflective metal. Small intentional areas of sparse coarse hatching/halftone in shadows. Face simplified with ink eyebrows and readable fierce expression. Preserve the character design while making the rendering more graphic and less detailed than the reference.
Background: simplified navy dock silhouette with only a few container edges; a flat desaturated warm cream diagonal shape behind the punch separates the arm from background. Four or five tapered ink speed strokes establish direction. Limited palette: ink-black, muted steel blue, warm off-white, skin, existing red/yellow machine accents and tiny cyan clothing accent. The strongest contrast belongs to the face and striking fist.
This must read at 110 pixels wide. Deliberate bold shapes and silhouette, not a cinematic illustration. No photorealism, 3D rendering, airbrushed shading, soft gradients, bloom, neon rim lights, lightning, glowing energy, particles, debris clouds, excessive scratches, elaborate background, ponytail, extra limbs, letters, logos, watermark or decorative border.
```
