# Referência localizada: pescoço e gola 01

22/10/2026 — candidata de acabamento artístico, **não aplicada ao jogo**.

Retorno posterior do usuário em 22/10/2026: “parece bom”. Feedback favorável à direção localizada do pescoço/clavículas/gola. Não estender aos detalhes regenerados de face/cabelo/próteses ou ao halo, nem considerar registro/movimento aprovados. Próxima aplicação exige derivar só a região necessária e conferir as três poses na variante; nada foi aplicado apenas por esse comentário.

## Recorte

Após aceitar a participação corporal da prova 10, o usuário concordou em começar o acabamento por uma região pequena. Selecionada a transição humana entre mandíbula, pescoço, clavículas, gola e ombro.

Observado: a prova mecânica usa a pintura anterior; suas deformações não preparam por si novas áreas ocultas/vistas. Regra: conservar identidade, peças dos braços, paleta e articulação aceitas. Hipótese desta referência: sombra sob o queixo, planos do pescoço e contato da gola mais claros melhoram a leitura da ligação entre cabeça e tórax.

Arquivo: `docs/arte_vega/vega_pescoco_gola_ref_01.png`, 1536×1024 RGBA. Close-up artístico da guarda atual, sem edição raster posterior. A referência é para avaliar **essa região**, não para substituir toda a parte superior da personagem. A geração reinterpreta detalhes de rosto/cabelo/próteses e inclui brilho periférico: esses elementos não estão aprovados como substitutos das peças atuais. Não há máscara de registro, pivôs/UV calibrados, camadas ou áreas ocultas de produção prontas.

## Verificação real e limites

- Godot confirmada 4.7.2.stable.official.ed1daf0bf; sem uso de novas APIs ou execução de cena nesta etapa.
- Inspecionados o render nativo da guarda 10 e o resultado gerado. Volume do pescoço/clavículas e borda da gola ficaram mais explícitos no close-up; é julgamento localizado, ainda sem aprovação do usuário.
- Arquivo aberto e dimensões/ARGB conferidos; alfa zero nos quatro cantos. Isso não comprova recorte limpo de toda a borda ou ausência de halo.
- Nenhum código, rig, peso, clipe, shader ou asset em uso alterado. Sem testes de runtime, capturas novas da Godot ou vídeo. Prova 10/F5 e referências aceitas preservados.
- Antes de aplicação, derivar só o acabamento aprovado para uma peça/camada registrada e conferir guarda/preparo/impacto. Não transformar este close-up inteiro em outro adesivo sobre o rig.
- Exercício sem editar: comparar o desenho da gola/pescoço nesta referência com `docs/evidencias_vega_corpo_articulado_10/novo_000.png`; avaliar espessura, contato e sombra, ignorando detalhes regenerados fora da região.

## Geração e origem

Skill **imagegen**, ferramenta integrada (não CLI). Usada em modo de edição com preservação de identidade/escopo como intenção do prompt; isso não garante invariância de pixels no resultado.

Entrada: `docs/evidencias_vega_corpo_articulado_10/novo_000.png`, inspecionada antes do envio. Original gerado em `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-37419c7c-d4c5-47f2-8750-a2befa35e3a7.png`, copiado sem alteração para o arquivo de referência no projeto. Não substitui a mestre corporal aprovada.

### Prompt final utilizado

```text
Use case: precise-object-edit.
Asset type: localized comic-book character finish reference, transparent background. This is a visual reference for neck/collar painting, NOT a new character or an exploded rig sheet.
Input image 1: edit target and identity/pose/material master, the currently approved assembled Vega in guard.
Primary request: produce ONE enlarged upper-body close-up of this exact pose, from the crown of the hair to just above the waist knot. Include both shoulders and both existing fists, with the same placement and relative proportions. Preserve her face, grumpy confident expression, dark wavy hair silhouette/length, warm skin, black tank top design, and the approved graphite braided cybernetic arms, fitted plates, cyan/magenta accents and fist sizes.
Only refine the SMALL HUMAN transition from lower jaw through neck/clavicles into the tank-top neckline and upper deltoids: clearer broad under-jaw occlusion shadow, convincing but restrained neck tendon planes, continuous clavicle/trapezius construction, and a thin cloth edge/contact shadow where the collar meets skin. Natural sturdy fighter's neck, same length and width as input, no rope-like bodybuilding striations. Make skin volumes join the chest and shoulders, rather than look like stacked cutout stickers. Maintain the existing upper-left light, warm complexion and mature hand-inked HQ language, grouped flat two/three-tone shadow planes, controlled hatching and black contours. Matte charcoal cloth, no shiny or rubber skin.
Invariants: do not redesign, rotate or reposition the arms/hands; do not change hair, facial anatomy, outfit, skin color, body proportions or guard. Keep the neck human; no cybernetic neck socket, scars, jewelry, armor, new accessories or cleavage changes. Do not recolor the prostheses. This is only local art-direction refinement, not a realism upgrade.
Composition: one close-up, same three-quarter camera facing viewer-right. True transparent alpha all around; no background, floor, glow, frame, labels, text, panels, watermark, guide lines or extra body parts. Keep every visible fingertip and all hair inside the frame. No full legs or new pose.
```

