# Quebra-chassi — prova de ruptura, 21/10/2026

Na continuidade da revisão carta a carta, após a aprovação e integração de Proteção, esta prova mostrou a consequência de um impacto pesado. Depois, o usuário autorizou concluir o restante do catálogo na direção estabelecida. A imagem está agora integrada a Quebra-chassi; o passe completo está registrado em `catalogo_cartas_hq.md`. A autorização para concluir o catálogo não é relato de aprovação individual de cada nova imagem.

## Direção e arquivos

Carcaça industrial rompida, com chapas dobradas e estrutura interna vermelha partida. Sem personagem ou inimigo inteiro. A ruptura grande distingue a finalização do pequeno amassado de Golpe, preservando o traço e a paleta das duas artes aprovadas. A ilustração não garante morte, remoção de Barreira ou dano elétrico; Quebra-chassi continua consumindo todo o Combo e causando 5 + 3 por ponto consumido.

- Arte ativa: `assets/ui/runtime/cartas/arte_quebra_chassi_ruptura_hq_prova.png` (caminho original mantido).
- Arte anterior preservada: `assets/ui/runtime/cartas/arte_quebra_chassi_vega.png`.
- Referências de estilo: Golpe e Proteção aprovados.
- Capturas: `docs/evidencias_quebra_chassi_ruptura_hq/`.
- Prévia: `tests/capturar_prova_golpe_hq.gd`, com `-- --quebra-chassi`.

Reprodução na Godot 4.7.2: `--path . --script res://tests/capturar_prova_golpe_hq.gd --rendering-method gl_compatibility -- --quebra-chassi`. O script troca somente a textura das instâncias de Quebra-chassi naquela execução. Golpe e Proteção mostram as artes já integradas. As capturas anteriores ficam em pastas próprias e foram preservadas.

## Verificação executada

Godot `4.7.2.stable.official.ed1daf0bf`, OpenGL Compatibility: prévia terminou com código 0 e salvou 12 PNGs com OK. Comparação atual/prova em 1920×1080 e 1024×576, repouso/foco e quatro recortes das cartas. Foram inspecionados os recortes da candidata nas duas resoluções, a cena pequena com a prova e a cena grande anterior à troca isolada. Sem erros de script/parse observados; persistiram os avisos conhecidos de RID/texturas/ObjectDB/recursos no encerramento. Capturas não equivalem à aprovação artística.

Integração de Proteção: importação headless e testes `test_hud_conceito_ativo`, `test_catalogo_cartas`, `test_apresentacao_recompensas` terminaram com código 0. O teste de conceito verifica a nova arte somente em Golpe/Proteção e preserva a expectativa das outras sete cartas. Suíte completa não repetida.

## Geração e prompt final

Skill `imagegen`, ferramenta integrada, sem CLI. Original preservado em `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-7fe1a943-0f7d-411f-9748-4bf377c13e84.png`, com cópia da candidata no projeto.

```text
Use case: illustration-story.
Asset type: one square illustration for QUEBRA-CHASSI (Chassis Breaker), a heavy physical finishing attack card in a cyberpunk comic deckbuilder. Art only, no frame, text, letters or UI.
Input images 1 and 2 are APPROVED STYLE REFERENCES ONLY. Match their brush-ink contours, bold connected black shadows, flat matte metal, restrained navy/cream/red/yellow palette and sparse coarse halftone. Do not repeat the fist, arm, pipe, person or poses.
Scene: an extreme close-up of the RESULT of a crushing mechanical blow: a thick robot chassis armor panel, folded violently inward and split across its main bolted seam. One central jagged rupture with three large angular metal flaps clearly attached to the surrounding panel, their bent thickness visible; behind the rupture one heavy red structural rib is snapped in two. Black interior void. Outer panel is muted steel-blue with off-white raw torn edges and a small yellow-black caution stripe at one corner, existing red fastener brackets. No intact robot, face, limbs or attacker.
Composition: the large broken opening fills the middle half of the square, a strong diagonal split across the panel, broad folded metal masses rather than countless tiny cracks. Keep the rupture and the broken red rib inside central 75 percent, readable in an 85-pixel-wide near-square crop. Panel surface continues beyond image edges. A few short cream/black comic impact strokes and at most two loose rivets reinforce the heavy damage. Simplify secondary textures aggressively.
Medium: genuinely DRAWN PRINT COMIC panel; heavy varied brush outlines; only two flat value levels per material; solid black shadow pockets, clean hard planes on dull steel. Coarse halftone restricted to secondary shadow regions. Strong graphic silhouette and deliberate large shapes. This card should immediately say broken chassis, visibly more severe than the small dent of the approved basic punch card.
Constraints: physical crushed metal, not an explosion, bullet hole, magical portal, glowing reactor or lightning strike. No hand/fist/whole character or full robot, no fire, energy, smoke clouds, particles or debris shower; no glossy chrome, airbrush gradients, cinematic/photoreal/3D rendering, dense mechanical wiring, typography, symbols, lettering, watermark or card border.
```
