# Vega v2 — prova estática de três poses de soco

21/10/2026. Candidatas para avaliação, não poses aprovadas, rig, sprites prontos ou animação.

## Objetivo e escopo

O usuário manifestou preocupação com anatomia ao passar da expansão muscular para um soco. Foi proposta validação estática de guarda, preparação e extensão antes de mexer na articulação; o usuário autorizou tentar. A montagem da Vega aprovada, seus encaixes e Combo linear ficam preservados.

Observado: a montagem atual reutiliza uma vista do braço, uma instância espelhada e mãos relaxadas; não há flexão de cotovelo validada. Regra preservada: apresentação não altera custo, dano, Combo ou resolução. Hipótese artística desta prova: um soco reto de trás para a direita, com preparo curto, guarda do outro braço e participação de tronco/quadril, permite avaliar continuidade do membro antes de criar peças e pivôs.

Escolha explicitada antes da geração: mesma câmera e volume de combate nas três poses, para não confundir a mudança de postura com expansão por Combo. O soco escolhido não introduz uma carta nova nem fixa animação exclusiva para todas as cartas.

## Arquivos e revisão

- `vega_v2_soco_poses_01.png`: primeira prancha, preservada como histórico. A preparação levantou o cotovelo do braço de ataque para trás, acima do pretendido, com antecipação exagerada para esta proposta.
- `vega_v2_soco_poses_02.png`: candidata atual, edição localizada solicitando baixar esse cotovelo e manter punho próximo da face. As poses laterais foram tratadas como invariantes.
- Ambas 1774×887, verificadas por leitura das dimensões. O prompt solicitou 3072×1536 se possível; a ferramenta entregou outro tamanho. Não afirmar geração em 3K.

Skill `imagegen`, ferramenta integrada, sem CLI/API externa. Entrada 01: referência local inspecionada `docs/arte_vega/vega_v2_referencia_04.png`, papel de mestre de identidade/equipamento. A captura da montagem aprovada também foi inspecionada para comparação, mas não enviada à geração. Entrada 02: prancha 01 local inspecionada, papel de alvo de edição. Fundo opaco solicitado; esta prancha não é atlas transparente.

Fontes preservadas:

- `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-0c12c72b-be9b-4ab2-ae8f-d48a3633d713.png`.
- `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-d71aeaad-8268-4f86-9573-daee115c4934.png`.

## Inspeção realizada e limites

Inspecionadas as duas saídas visuais, alvo antes da edição e dimensões dos arquivos copiados. A revisão 02 mostra preparação compacta, com cotovelo mais baixo e punho junto do rosto. Guarda e extensão mantêm visualmente a composição anterior; sem comparação pixel a pixel. Três corpos inteiros, mãos fechadas, roupa/cabelo/expressão reconhecíveis e extensão para a direita aparecem na prancha.

Isso não é comprovação biomecânica. Pequenas diferenças de perspectiva, apoio dos pés, comprimento aparente e detalhes das placas continuam a conferir. A rotação do apoio traseiro na extensão não está muito explícita. A proximidade entre guarda e preparação é intencional para reduzir o exagero, mas o ritmo dessa diferença ainda não foi testado. Não prometer interpolação correta ou preservação exata de componentes só pela imagem.

Nenhum código, cena, asset ativo, regra ou animação alterado; nenhum teste de gameplay/rig executado. `git diff --check` passou. As três imagens desenhadas dentro da prancha NÃO constituem três poses de uma malha compatível. Não reproduzir o soco girando o recorte inteiro atual nem considerar anatomia aprovada sem avaliação do usuário.

Próxima verificação pequena: olhar a extensão e seguir visualmente ombro→cotovelo→punho; depois comparar guarda/preparação sem considerar brilho ou acabamento. Exercício visual opcional: traçar por cima numa cópia uma linha do ombro ao cotovelo e outra ao punho nas três poses, identificando o que gira e o que aparenta mudar de tamanho. A prancha original fica intacta.

Se a candidata for aprovada, próximo recorte é preparar peças/pivôs para essas poses e conferir a ligação ombro/cotovelo/punho; não avançar automaticamente para animação, arena ou novo catálogo. Materiais de retorno/intermediários ainda não foram produzidos.

## Prompt 01 — geração da prancha

```text
Use case: stylized-concept / identity-preserve.
Asset type: ONE character animation key-pose study sheet, NOT final animation, NOT a sprite atlas. Landscape 3072x1536 if possible, THREE equally wide vertical panels. Each panel must contain the SAME character at the SAME full-body scale and SAME fixed camera, feet on the SAME baseline. Generous margins, no cropped hair, feet, elbows or extended fist, panels must not overlap.
Input image 1 is the APPROVED CHARACTER DESIGN MASTER. Use the woman's identity, outfit and cybernetic arm design. Do NOT copy the reference layout, background portrait, open-hand pose or text.

Draw a controlled three-pose study for ONE ordinary REAR-HAND STRAIGHT PUNCH toward screen RIGHT (a right cross from left-lead stance). This is a comparison for anatomy and cutout-animation feasibility, not an action poster. Keep a readable near-side three-quarter SIDE view, looking toward screen right, approximately 20 degrees toward camera from strict profile; use that EXACT camera in all panels. No extreme foreshortening, fist toward camera, changing camera, or action perspective.

Identity invariants across all three drawings: adult woman from reference, medium brown skin, SAME longer shaggy black wavy bob to jaw/upper neck, asymmetric fringe, SAME grumpy confident expression, dark eyes, broad nose and strong brow. SAME plain charcoal tank top, loose graphite street trousers without cargo pockets, muted plum/wine shirt tied around waist, heavy black lace-up boots. Human torso and legs, both arms prosthetic from natural deltoid attachment below shoulder. Maintain the reference's braided black synthetic muscle, compact graphite plates, cyan joint seams and small magenta latch. Proportional articulated mechanical hands, not boxing gloves or giant gauntlets, no white industrial armor or yellow warning stripes.
Both arms remain at the SAME moderate COMBAT VOLUME in every panel: do not change muscle size, plate count, hand size or limb lengths between poses. Keep upper arm, elbow collar, forearm plates and wrist recognizable as the same connected components. Shoulder belongs to torso, elbow connects the two arm segments, hand attaches to forearm with a continuous locked wrist. No floating joints, duplicate elbows, rubber limbs, backward hands or fingers through armor.

LEFT PANEL, small label below feet: "01 GUARDA".
Left foot leads toward screen right, right foot behind toward screen left, feet separated for balance and fully visible. Soft knees, torso upright with athletic readiness. Both mechanical hands CLOSED into natural fists, thumbs folded outside the curled fingers. Lead left fist guards in front of cheek/upper chest, rear right fist near right cheek, elbows bent and lowered. Shoulder joints remain seated in deltoid sockets.

CENTER PANEL, small label below feet: "02 PREPARAÇÃO".
SAME foot positions and body scale. A SMALL believable coil, not a huge theatrical wind-up: load the rear hip and rotate torso/rear shoulder slightly back. Rear right fist stays close to cheek/jaw, elbow flexed roughly 90 degrees and pointing down rather than flaring behind the back. Lead left hand maintains guard. No wrist bend, no detached arm, no fist drawn behind the spine. Show connected movement of hips, torso, shoulder and arm while head remains oriented toward target.

RIGHT PANEL, small label below feet: "03 EXTENSÃO".
Deliver the SAME right rear fist in a straight horizontal line to screen RIGHT at shoulder/upper-chest height. Rear hip and shoulder rotate forward together; rear heel may pivot while toe contact stays at the same location. Lead knee stays soft, torso supported between feet, no airborne leap or deep lunge. Rear right upper arm and forearm extend through the visible elbow with a very small remaining bend, not hyperextension. Closed fist, knuckles and forearm align with a straight locked wrist; correct thumb outside the fist. Shoulder slightly protracts without dislocating from the socket. Left hand stays guarding the chin, elbow tucked. SAME arm lengths and fist size as panels 1 and 2. No magic stretch, no giant hand and no forced straightening of a curved cutout.

Style: match the approved reference's HQ comic drawing: crisp weighted ink outlines, angular black shadow planes, flat color, restrained hatch marks. Drawn metal, not glossy 3D or photographic machinery. Plain muted blue-gray paper-like flat background, no scenery. Simple consistent tiny contact shadow under each stance. Static drawings only: no speed lines, motion blur, energy trails, impacts, arrows or additional opponents. Sparse labels exactly as specified, no title, explanatory paragraphs, logos or watermark.
Purpose: reveal whether the THREE ANATOMICALLY CONNECTED KEY POSES are coherent before any rig code is written. Do not hide joints behind effects. Keep full bodies large and clear, with hands, shoulders and elbows readable.
```

## Prompt 02 — revisão localizada da preparação

```text
Use case: precise-object-edit / identity-preserve.
Edit target: input image 1, the THREE-PANEL VEGA punching key-pose sheet.
CHANGE ONLY THE CENTER PANEL'S PUNCHING RIGHT ARM (the arm on the LEFT SIDE of the center character, currently raised sideways beside her ear). The current elbow flares outward behind the torso; correct this into a compact straight-punch preparation. This is one surgical pose correction, not a new sheet or style.

In the CENTER "02 PREPARAÇÃO" panel: lower the right elbow so the upper arm slopes DOWN along the side of the ribcage, elbow below shoulder height and close to the lower ribs. Upper arm is NOT horizontal and does not point backward. Bend the elbow so the forearm rises toward the face. Keep the right closed fist just in front of the jaw/cheek, BELOW the ear and near chin height, a compact loaded guard with a very small shoulder/torso coil. No fist tucked behind head and no shoulder overextension. There must be a continuous, readable anatomical chain from the natural shoulder cap into the synthetic biceps, cyan elbow collar, plated forearm, cyan wrist and CLOSED mechanical fist. Preserve the SAME upper arm/forearm lengths, muscle thickness, plate count, hand size and design. The arm can look similar to the guard panel: anticipation should be subtle, NOT an exaggerated wind-up.

Keep the center character's opposite guarding arm (on screen right), head, face, hair, body, shirt, legs, feet, position, clothing, camera and scale unchanged. Preserve all three labels and the floor exactly. Preserve the ENTIRE LEFT GUARD PANEL and ENTIRE RIGHT EXTENSION PANEL unchanged. Same blue background, comic ink lines, graphite/cyan/magenta prosthetics, skin and outfit. Do not add new limbs, props, arrows, highlights, effects, opponent or text.
Output the full three-panel sheet with ONLY that center-arm pose correction. No cropped panels. No transparency.
```

