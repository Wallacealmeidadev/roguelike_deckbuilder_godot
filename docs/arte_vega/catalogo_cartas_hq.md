# Catálogo de cartas HQ — 21/10/2026

O usuário autorizou concluir as artes restantes com a direção conceitual estabelecida, sem pedir aprovação a cada carta. Foram integradas as nove ilustrações do catálogo atual: Golpe e Proteção já aprovados, Quebra-chassi da última prova e seis imagens novas. Isto não significa aprovação individual automática das seis novas imagens ou conclusão artística de todo o jogo.

## Linguagem e escopo

Ações, equipamentos e consequências em enquadramento fechado, sem redesenhar a personagem inteira: contorno de tinta, sombras recortadas, metal mate, paleta navy/creme/vermelho/amarelo e detalhes subordinados à leitura em miniatura. Pulso usa ondas ciano chapadas, não iluminação renderizada. Cada carta tem recurso próprio, inclusive quando compartilha efeitos ou componentes de equipamento. Nenhuma regra de custo, dano, Barreira, Combo, Exposto ou Enfraquecido mudou. O texto e os valores continuam sendo a referência mecânica.

Arquivos em `assets/ui/runtime/cartas/`:

| ID | Arquivo ativo | Leitura visual |
| --- | --- | --- |
| golpe | arte_golpe_impacto_hq_prova.png | Punho atingindo chapa; impacto localizado. |
| protecao | arte_protecao_bloqueio_hq_prova.png | Antebraço interceptando uma pancada. |
| quebra_chassi | arte_quebra_chassi_ruptura_hq_prova.png | Carcaça e estrutura interna partidas. |
| direto_hidraulico | arte_direto_hidraulico_hq.png | Pistão impulsionando o punho. |
| brecha | arte_brecha_hq.png | Junta vulnerável sob placas separadas. |
| pulso_debilitante | arte_pulso_debilitante_hq.png | Emissor e ondas gráficas de interferência. |
| golpe_ariete | arte_golpe_ariete_hq.png | Punho pesado contra uma travessa. |
| ruptura_pressao | arte_ruptura_pressao_hq.png | Conexão hidráulica rompida e pressão escapando. |
| placa_reforcada | arte_placa_reforcada_hq.png | Camadas de blindagem presas por uma trava. |

Os três arquivos com sufixo `_prova` mantêm seus caminhos originais para evitar cópias divergentes. As imagens provisórias antigas e as provas anteriores não foram apagadas; seus caminhos não são mais usados por `botao_carta.gd` ou `carta.tscn`.

## Integração e verificação

`botao_carta.gd::_obter_arte()` seleciona explicitamente uma ilustração por ID. A mesma cena de carta é usada na mão, recompensas e descanso; o token aprimorado é normalizado pelo fluxo existente e preserva a imagem da base. `carta.tscn` também referencia a versão nova de Quebra-chassi.

Godot `4.7.2.stable.official.ed1daf0bf`: importação headless terminou com código 0. Oito testes focados terminaram com código 0: `test_hud_conceito_ativo`, `test_catalogo_cartas`, `test_resolucao_cartas`, `test_apresentacao_recompensas`, `test_apresentacao_descanso`, `test_ciclo_descanso`, `test_mao_hq`, `test_hud_compacto`. A regressão de conceito verifica correspondência de ID/arquivo, nove recursos exclusivos, cobertura do catálogo e a imagem das nove cópias aprimoradas criadas pelo fluxo real da mão. A suíte completa não foi repetida.

`tests/capturar_catalogo_cartas_hq.gd` terminou com código 0 em OpenGL Compatibility e salvou 39 PNGs em `docs/evidencias_catalogo_cartas_hq/`: duas mãos de nove cartas, 18 cenas com foco, 18 recortes do quadro real e uma prancha das nove cartas renderizadas pelo componente real. Foram inspecionadas a prancha, as mãos em 1920×1080/1024×576 e os recortes das seis novas cartas em 1024. Nenhuma substituição de textura é feita por esse script. A mão com nove cartas é uma fixture visual, não uma mudança da compra ou limite de mão do jogo.

Reprodução: `--path . --script res://tests/capturar_catalogo_cartas_hq.gd --rendering-method gl_compatibility`.

Sem erros de script/parse observados nas capturas; persistem avisos conhecidos de RID/texturas/ObjectDB/recursos ao encerrar. `git diff --check` passou. Capturas e testes não substituem o playtest/avaliação artística do usuário.

## Geração

Skill `imagegen`, ferramenta integrada, uma chamada por imagem distinta; sem CLI/API externa. Referências das seis imagens: Golpe aprovado e Proteção aprovada, exclusivamente para traço, paleta e equipamentos. Originais da ferramenta preservados; cada resultado selecionado foi copiado para o projeto:

- `direto_hidraulico`: `C:\Users\Wallace\.codex\generated_images\01a15471-4a72-7593-a6ce-1852411b6994\exec-73de963f-85f7-4962-b319-eae64b184c46.png` → `assets/ui/runtime/cartas/arte_direto_hidraulico_hq.png`.
- `brecha`: `C:\Users\Wallace\.codex\generated_images\01a15471-4a72-7593-a6ce-1852411b6994\exec-0eb680ea-209d-403c-9cd1-a09ffec1d174.png` → `assets/ui/runtime/cartas/arte_brecha_hq.png`.
- `pulso_debilitante`: `C:\Users\Wallace\.codex\generated_images\01a15471-4a72-7593-a6ce-1852411b6994\exec-c6aa8ef0-e5b0-4d29-9ecf-e55b3b08cbb0.png` → `assets/ui/runtime/cartas/arte_pulso_debilitante_hq.png`.
- `golpe_ariete`: `C:\Users\Wallace\.codex\generated_images\01a15471-4a72-7593-a6ce-1852411b6994\exec-7b21aeef-b87d-44fc-8035-b610368b7a3e.png` → `assets/ui/runtime/cartas/arte_golpe_ariete_hq.png`.
- `ruptura_pressao`: `C:\Users\Wallace\.codex\generated_images\01a15471-4a72-7593-a6ce-1852411b6994\exec-061382b1-54a0-48d3-ad27-95c894f1bae2.png` → `assets/ui/runtime/cartas/arte_ruptura_pressao_hq.png`.
- `placa_reforcada`: `C:\Users\Wallace\.codex\generated_images\01a15471-4a72-7593-a6ce-1852411b6994\exec-4e8afc87-3dc3-4757-b919-be71710160c9.png` → `assets/ui/runtime/cartas/arte_placa_reforcada_hq.png`.

Golpe, Proteção e Quebra-chassi têm prompts e fontes registrados nos documentos individuais desta pasta.

## Prompts finais das seis imagens novas

O prompt completo de cada imagem é a concatenação literal da base comum abaixo com o respectivo trecho individual. Os seis foram executados com as mesmas duas referências, sem transparência.

### Base comum

```text
Use case: illustration-story. Asset type: ONE square illustration for a cyberpunk comic deckbuilder card, ART ONLY. Input images 1 and 2 are approved INKING, PALETTE AND INDUSTRIAL MATERIAL references, not compositions to copy. Match thick varied brush outlines, connected solid black shadows, angular flat matte steel, coarse halftone used sparingly, navy, warm cream, muted steel-gray, red brackets and small yellow-black hazard accents. Two flat shadow levels, no glossy chrome or airbrush gradients. Very clear silhouette and one focal action readable at 85 pixels wide. Essential subject must stay in central 75 percent for near-square crop. No complete person, face, full robot, full arm/anatomy study, extra limbs, scenery panorama, realistic render, bloom, cinematic lighting, particle shower, text, letters, logos, numbers, watermark, decorative frame or UI. 
```

### Direto Hidráulico

```text
Card DIRETO HIDRÁULICO. A tight three-quarter side view of a mechanical gauntlet's active HYDRAULIC DRIVE. One red industrial cylinder and exposed thick matte-gray piston rod extend horizontally, pushing the short closed armored knuckles at the right edge forward. A single black hydraulic hose curves under the cylinder. Forearm housing cropped at left, no elbow/shoulder. Piston and its connection are the main subject, knuckles secondary, not an enormous fist. Three crisp cream/black speed strokes show the piston extension; no impact target needed, no electrical effects. Quiet navy background with one flat cream diagonal. This is a powered straight punch, show a coherent simple mechanism, not a firearm, drill or detached collection of spare parts.
```

### Brecha

```text
Card BRECHA. Close-up of a VULNERABLE GAP in robot armor: two broad overlapping steel-blue plates have been pried slightly apart along one diagonal seam, exposing a compact RED hinge/servo underneath. One lifted plate corner reveals the weak point. The narrow cream-edged opening is large enough to read, but the armor remains mostly intact, unlike a shattered chassis. A few short black/cream strokes draw attention to the exposed joint. Only plates and hinge, no hand, tool, sight reticle or body. Strong simple diagonal design, large quiet navy shadow masses, no explosion, no electrical effects.
```

### Pulso Debilitante

```text
Card PULSO DEBILITANTE. A compact industrial wrist-mounted pulse EMITTER at lower-left projects TWO bold flat cyan concentric wave arcs toward a single small red/gray robot servo joint at upper-right. Emitter is a short round mechanical module with cream casing, red brackets and black rim, not a gun or magic staff. Servo joint looks stalled/limp, not exploded. Focus on clear circular wave silhouette, kept inside central 75 percent. Cyan is solid printed ink, NO glowing light, lightning or lens effects. Navy background and cream shape behind the emitter. No full hand/person, no handheld shield, no damage explosion. The picture communicates disruption and weakening, not a damaging laser attack.
```

### Golpe de Aríete

```text
Card GOLPE DE ARÍETE. An exceptionally heavy mechanical closed gauntlet seen from a compact steep three-quarter angle RAMS a thick reinforced industrial crossbar. Broad squared knuckle plates and a short armored wrist form one coherent large blunt mass, no character or elbow. Crossbar is visibly buckling under the weight, not shattering to pieces. One LARGE cream/black compressed impact wedge, three short force strokes. Different framing from a normal side-on punch: slightly overhead, diagonally down-right, squat crushing silhouette filling the middle of square. Matte off-white armor, black joints, red braces, small yellow hazard marks. No energy, lightning, fist-shaped projectile, extra fingers or machine gun.
```

### Ruptura de Pressão

```text
Card RUPTURA DE PRESSÃO. Macro close-up of a robot's damaged HYDRAULIC CONNECTION: a single thick red pressure hose has ruptured at its gray metal coupling, leaving two clearly separated ends near the center. A small stylized warm-cream pressure jet with black tapered edges escapes sideways from the coupling, with two large graphic dark oil droplets. Pipe runs diagonally through a simple navy/steel chassis panel. Focus on failed hose/coupling and escape of pressure, not a whole destroyed robot. A loosened yellow safety clamp remains attached. No fist, person, flame, electricity, blood, toxic cloud, magical energy or cinematic fluid simulation; draw the jet as flat comic strokes. This exposes a mechanical weakness, does not imply new game rules.
```

### Placa Reforçada

```text
Card PLACA REFORÇADA. Tight close-up of TWO thick overlapping armor layers locked together by a robust RED industrial latch and two broad rivets. A clean off-white/gray beveled front plate with small yellow-black hazard band sits over a darker steel-blue backing plate; stepped edges make the extra thickness unmistakable. Intact, secure, solid defensive equipment, NO impact or attack. One main shield-like metal silhouette, but NOT a handheld medieval shield and no floating shield icon. Calm stable triangular/diagonal composition fills center, deep black seam shadows and quiet navy background with flat cream wedge. No body, person, hands, tools, energy bubble, glowing blue hexagons, weapon or particles.
```


## Próxima verificação pequena

No jogo normal, compare Direto Hidráulico com Golpe e Placa Reforçada com Proteção, depois abra uma melhoria no descanso. As composições devem se distinguir e a imagem da carta aprimorada deve permanecer igual à base. Ajustes de arte podem ser localizados por carta; este passe não revisou arenas, personagens ou o restante da HUD.
