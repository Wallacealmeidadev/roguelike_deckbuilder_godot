# Pintura HQ 01 — textura aplicada à prova 18

24/10/2026. Usuário aprovou ambos os braços do estudo 03 e autorizou seguir. Skill imagegen, ferramenta integrada, sem CLI. Entrada de geometria: `docs/arte_vega/vega_corpo_volume_poses_04.png`; referência de acabamento: `docs/arte_vega/vega_bracos_hq_estudo_03.png`.

Saída: `bracos_hq_01.png`, canvas 1774×887, SHA256 `53CB706E429D0C2D1DDE00236261FDFC4678A79440DE9CD92439113784931FAC`. Origem gerada: `exec-7cd45415-e420-4e20-bd25-8ef22def6184.png`. Somente regiões dos braços da guarda são consumidas; corpo/outras poses da saída não substituem fontes existentes.

## Integração

`vega_fiel.gd` mantém fonte/UV/registro e aplica `pintura_hq.gdshader` nos dois braços e conexão próxima. O material preserva os primeiros 3 pixels de borda da fonte e interpola até 7 pixels para a pintura nova. Isso evita importar fundo/pele de contornos que a geração ressintetizou. Preserva alguns detalhes originais nas bordas; não é cópia integral do estudo.

Captura isolada revelou também fundo claro preexistente sob o bíceps distante. Oito pontos do recorte inferior foram recolhidos em 3–7 pixels de origem para acompanhar o contorno pintado, sem mudar registros ou centros das juntas. H alterna somente material; R restaura HQ. V/A mantêm suas funções. Prova estática F6; F5/rig animado intactos.

## Verificação

Godot 4.7.2. Importação exit 0 com avisos conhecidos de 33 ObjectDB e 13 recursos em uso. Captura OpenGL exit 0/OK/stderr vazio, nove imagens em `docs/evidencias_vega_bracos_prancha_18/hq/`; ampliada e isolados inspecionadas. Comparação real H antes/depois: 20.529 pixels internos mudaram, zero diferenças de alfa/exterior. Teste da prova GL passou, zero falhas/stderr vazio; inclui UV/matrizes inalteradas por H, atalhos/reset, limpeza distante e verificações anteriores. Sem teste animado, suíte completa ou benchmark do material. Resultado aplicado ainda depende de avaliação visual.

## Prompt

Precise production texture edit. Image 1 is the EDIT TARGET, a 1774x887 three-pose character sheet. Image 2 is STYLE REFERENCE ONLY: use the FLAT DARK COMIC ARMS of the woman in its RIGHT panel. Output image1 in its same 2:1 aspect ratio and exact layout, preferably 1774x887. DO NOT output the screenshot or its panels.
Change ONLY the surface paint INSIDE BOTH mechanical arms of the LEFTMOST guard figure in image1, around source x160..487,y195..388. Preserve their exact source positions, silhouettes, thickness, plate boundaries, orientation of fists, all finger shapes, cyan rings, elbows, wrists and shoulders. Preserve ALL remaining image1 pixels as faithfully as possible, including the other two poses and all clothing/skin/face/background. This will be sampled by existing UV coordinates: no zooming, cropping, reframing, translating, rotating, changing arm pose or resizing any body part.
Repaint those two arms to match the approved right-hand figure in image2: broad flat interwoven charcoal tendon groups, strong clean black ink separations, hard-edged near-black shadows, muted flat grey light planes; eliminate glossy rounded gradients and tiny shining fiber highlights. Silver forearm and hand plates use 2-3 flat grey planes with sparse narrow edge accents, no chrome or airbrush gradients. Both hands use flat charcoal knuckle planes without white specular beads. Retain cyan/magenta trim in crisp thin flat colors. Keep mechanical design legible and closely match the dark restrained hand-drawn comic finish in image2. Do not add patterns, new shoulder caps, panels, anatomy or outlines outside the existing contours. This is repainting an existing texture in place, not drawing a new character.

