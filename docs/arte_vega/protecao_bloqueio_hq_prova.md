# Proteção — prova de bloqueio, 21/10/2026

Após aprovar a arte de Golpe, o usuário autorizou aplicá-la somente nessa carta e seguir para uma prova de Proteção com a mesma linguagem gráfica. Depois aprovou também Proteção e autorizou continuar. Esta imagem está agora integrada somente a Proteção; Pulso Debilitante e Placa Reforçada preservam a arte provisória anterior.

## Direção e arquivos

Detalhe de um antebraço protético interceptando uma pancada de cano metálico. Equipamento industrial de Vega, contornos fortes, sombras recortadas e paleta baseada no Golpe aprovado. Sem personagem inteira, escudo de energia ou efeito elétrico. É uma representação visual de defesa; não adiciona reflexão de dano nem uma regra de aparar ao combate. Proteção continua concedendo 5 de Barreira.

- Arte aprovada e ativa: `assets/ui/runtime/cartas/arte_protecao_bloqueio_hq_prova.png` (caminho original mantido).
- Arte anterior preservada: `assets/ui/runtime/cartas/arte_protecao_vega.png`.
- Referências: Golpe aprovado e Vega de corpo inteiro, usadas para estilo/equipamento, não pose.
- Evidências: `docs/evidencias_protecao_bloqueio_hq/`.
- Prévia: `tests/capturar_prova_golpe_hq.gd -- --protecao`.

Reprodução na Godot 4.7.2: `--path . --script res://tests/capturar_prova_golpe_hq.gd --rendering-method gl_compatibility -- --protecao`. O script troca somente as texturas das instâncias de Proteção nessa execução. Golpe aparece com a arte já integrada ao jogo; as demais cartas preservam seus recursos ativos.

## Verificação executada

Godot `4.7.2.stable.official.ed1daf0bf`, OpenGL Compatibility: prévia terminou com código 0, 12 capturas salvas com OK em duas resoluções, com repouso/foco e recortes da carta. Foram inspecionados os recortes de Proteção em 1920×1080 e 1024×576, a cena pequena com a prova e a cena grande antes da troca isolada. Sem erros de script/parse observados; persistiram avisos conhecidos de RID/texturas/ObjectDB/recursos no encerramento. As capturas registram o enquadramento, não aprovação artística.

Integração de Golpe: importação headless e testes `test_hud_conceito_ativo`, `test_catalogo_cartas`, `test_apresentacao_recompensas` terminaram com código 0. O teste de conceito verifica a arte nova somente em Golpe e a preservação das outras oito cartas. Nenhuma regra do catálogo foi alterada.

## Geração e prompt final

Skill `imagegen`, ferramenta integrada, sem CLI. Original preservado em `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-166f3b46-a6fb-411a-b078-d7c02a87eef1.png`, com cópia da candidata no projeto.

```text
Use case: illustration-story.
Asset type: one square artwork for PROTEÇÃO, a basic block card in a cyberpunk comic deckbuilder. Illustration only, no card border, text or UI.
Reference image 1 is the APPROVED STYLE reference: match its bold black brush outlines, angular flat shadows, restrained navy/cream/red/yellow palette, matte industrial metal and sparse coarse halftone. Do NOT copy its punching action.
Reference image 2 is an EQUIPMENT DESIGN reference only: Vega's prosthetic forearm has chunky matte gray/off-white armor, black mechanical joints, red brackets and yellow-black industrial hazard markings. Do not draw the woman.
Subject and action: extreme close-up of ONE raised armored mechanical FOREARM braced defensively across the picture, stopping an incoming heavy metal pipe against its broad outer armor plate. Forearm is angled from bottom-left toward top-center; wrist continues beyond the top edge, elbow beyond the bottom-left edge, so only the forearm armor and short wrist are seen, no fist required. A plain dark steel pipe enters from upper-right and its blunt end visibly meets the broad outer plate at center-right. The forearm remains firmly held and undamaged. The incoming pipe is clearly stopped, with two short recoil motion strokes. A SMALL warm-white angular ink-edged impact mark separates the pipe from the armor at contact. This reads as blocking, not punching or firing.
Composition: foreground forearm fills central half, broad armor face points toward the viewer, incoming pipe is smaller and subordinate. Contact, red mechanical bracket and yellow hazard mark lie in the central 75 percent for a near-square card crop. Only two objects, bold silhouettes, very little mechanical microdetail. Show a quiet navy background with one flat warm cream wedge behind the action; no environment panorama.
Medium: drawn, inked PRINT COMIC panel; thick varied brush contour, connected solid-black shadows, two flat value levels per material, single hard highlight plane on matte steel, sparse coarse halftone only in background/shadows. Readable at 85 pixels wide. Keep line weight, color blocking and contrast consistent with the approved punch artwork.
Constraints: no whole person, face, torso, skin, shoulder or anatomical pose; no second defensive arm, no floating fingers; no handheld shield, force field, translucent blue hexagons, energy bubble, lightning, gun or laser. No glossy chrome, 3D rendering, airbrushing, soft gradients, bloom, explosions, debris shower, text, lettering, logo, watermark or UI. Basic physical protection, not magical protection or reflection damage.
```
