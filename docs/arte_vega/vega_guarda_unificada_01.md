# Vega — guarda unificada, candidata 01

22/10/2026. Usuário autorizou começar o passe artístico unificado após aprovar a base funcional e apontar efeito de corpo/adesivo com braços sobrepostos. Esta entrega é uma candidata estática para avaliar linguagem visual; não substitui a personagem ativa nem demonstra animação pronta.

Atualização posterior: usuário respondeu “parece ótima”. Referência estática aprovada como mestre visual do próximo passe. Os parágrafos de intenção/inspeção abaixo registram a entrega anterior ao retorno; aprovação não garante encaixes no rig ou resultado animado. Nenhum asset ativo foi substituído por este retorno.

## Arquivos e origem

- Arte: `docs/arte_vega/vega_guarda_unificada_01.png`, 1117×1408 RGBA, transparência conferida no canto.
- Original preservado: `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-0e5f1941-f87b-4eb8-91cf-22c6674e4840.png`.
- Skill imagegen, ferramenta embutida; sem CLI/API direta, edição local de pixels, recorte de membros ou sobrescrita de arte anterior. A imagem foi copiada integralmente ao projeto.
- Alvo de edição: captura da guarda atual `docs/evidencias_vega_alternancia_22/detalhe_repouso_combo0_1920.png`.
- Referências de apoio: identidade/figurino/próteses da `vega_v2_referencia_04.png` e vista palmar `rig_nativo_v2/mao_palmar_01.png`.

## Intenção e inspeção

Preservar a mesma adulta de cabelo preto shaggy, expressão confiante/rabugenta, regata carvão, calça escura e camisa vinho na cintura. Uma guarda completa desenhada num passe só, mãos fechadas com dorso próximo/palma distante, luz/contorno/sombras compartilhados por pele, tecido e próteses. Aproximar o acabamento sem trocar a ideia de fibras musculares artificiais, placas rígidas e conectores ciano/magenta.

Saída inspecionada: figura inteira, dois punhos altos, vista palmar distante, botas e roupa reconhecíveis; braços/ombros pintados no contexto do tronco. Ainda há detalhe/brilho concentrado nas próteses. Não foi feita comparação pixel a pixel de identidade ou encaixes. Proporções/posição dos pontos podem diferir do rig; a imagem NÃO é uma textura drop-in nem autorização para recalibrar anatomia. Avaliação de unidade artística continua com o usuário. Pintura estática não resolve rigidez, perspectiva de um golpe ou transições.

## Prova no tamanho de jogo

`tests/capturar_vega_unificada.gd` instancia o combate em processo separado e salva atual/candidata em 1920×1080 e 1024×576. A candidata é um Sprite estático temporário alinhado ao piso, com altura calculada a partir da escala atual do rig. Somente a composição original dessa instância fica oculta; nenhuma cena/main/recurso ativo é editado. Sombras existentes permanecem para comparar enquadramento, não constituem adaptação final ao novo contorno das botas.

Execução OpenGL na Godot 4.7.2: exit 0, quatro PNGs salvos OK em `docs/evidencias_vega_unificada_01/`. Alturas registradas 378.5 px/211.2 px, alfa no canto 0.0. Ambas as candidatas de contexto inspecionadas: corpo inteiro visível, pés no plano de chão e sem invadir HUD. Persistem os avisos anteriores de recursos/RID/fontes/ObjectDB ao encerrar main. `git diff --check` passou. Sem testes novos de gameplay, vídeo, movimento ou alteração da opção de acessibilidade real do usuário; o capturador usa reduzido só em sua instância.

Exercício de avaliação: abra `candidata_estatica_1920.png` e `atual_1920.png` a 100%, sem ampliar a personagem. Compare primeiro a união ombro/prótese, depois o nível de brilho dos braços em relação ao rosto/camiseta. Avaliar desenho separado da ausência de movimento, pois as duas capturas são estáticas.

Gate artístico recebido com retorno positivo do usuário. Próxima verificação proposta: derivação incremental de ombro/braço próximo, avaliada em guarda/extensão no rig preservado. Manter guarda viva, alternância e regras; não substituir por PNG inteiro no combate como solução final.

## Prompt integral

```text
Use case: identity-preserve / style-transfer.
Asset type: ONE full-body unified comic-book character illustration for a 2D fighting/deckbuilder game; visual master candidate, not a sprite sheet.
Input images: Image 1 is the EDIT TARGET, the current assembled Vega standing in fighting guard. Preserve its composition and recognizable character. Image 2 is the APPROVED identity/outfit/prosthesis-design reference, not a layout to reproduce. Image 3 is supporting reference ONLY for the palmar side of the far CLOSED fist; do not copy its enlarged detail density.

Primary request: repaint the assembled character in Image 1 as a SINGLE coherent hand-drawn HQ/comic illustration. Skin, hair, fabric, prosthetic arms and fists must look drawn by the same artist under the same light, not a static body with pasted-on separately rendered robot parts. Keep the near fist showing the armored dorsum, the far fist showing curled fingers/palmar pads toward the viewer. Both hands are closed in a natural fighting guard, one near the cheek and one in front of the upper chest. No open hands, no punching pose.

LOCK IDENTITY AND DESIGN: same adult woman, warm brown skin, the approved shaggy longer black bob, strong brows, confident grumpy protective unsmiling expression. Keep charcoal sleeveless cotton tank, loose plain graphite trousers, small plum/wine shirt tied at waist, black lace-up boots. Preserve both shoulders, natural human deltoids and the approved cybernetic arms: dark braided synthetic-muscle bundles with restrained graphite rigid plates, thin cyan connectors and small magenta accents. Do not turn them into industrial gauntlets, huge armored shoulder pads, white chrome machinery or oversized fists. Do not redesign her clothes, change her haircut, add accessories or make her glamorous/cheerful.

ART DIRECTION: strong expressive ink contours with consistent line-weight hierarchy across face, cloth and prostheses; two or three deliberate shadow-value groups; restrained hand-inked hatching; cohesive flat/cel-like comic shadows, not soft digital airbrush or photorealistic 3D. Keep the braided fibers legible as grouped shapes, not thousands of shiny engraved strands. Match graphite metal highlights to the value range of cloth/skin highlights; no sparkling chrome. ONE common soft key light from upper left and restrained cool ambient fill. Cyan rings cast only subtle local reflected color onto adjacent skin/cloth/metal, no large bloom. Paint real contact shadows at shoulder connections and where fists/arms overlap torso. The cybernetic upper arm attaches flush below the human deltoid with believable shared volume and a continuous silhouette: no floating hoop, black socket hole or pasted-on connector.

COMPOSITION/ANATOMY: full head, both fists and both boots entirely visible, isolated centered figure on genuine transparent background with clear margins. Match the three-quarter right-facing guard and grounded wide bent-knee stance of Image 1; chest, collarbones and shoulders must participate anatomically in the raised guard. Preserve believable arm/forearm/hand proportions and current overall reach; do not shorten arms into T-rex proportions or stretch fists toward knees. Preserve leg stance/boot placement approximately so this remains a visual reference for the existing rig, not a new action pose. Do not add a scene, UI, text, title, inset, separated parts, diagram, watermark, floor plane, glow aura or drop shadow. Output one crisp unified character, readable at approximately 380 pixels tall in-game.
```
