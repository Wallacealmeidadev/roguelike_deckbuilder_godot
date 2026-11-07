# Palma e golpes alternados — 22/10/2026

## Conferir em F5

Guarda viva preservada. Mão próxima mostra dorso; distante usa arte palmar própria de punho fechado. Ataques válidos alternam próximo → distante → próximo. Cartas defensivas/inválidas não avançam a sequência; dano não escolhe o próximo braço. Reinício/mapa limpam a sequência. Modo reduzido registra o lado sem articular o corpo. Não há fila, bloqueio de input ou alteração de dano/custo/Combo.

Exercício pequeno: jogue ataque, Proteção e outro ataque. A Proteção não deve consumir a vez do braço distante. Depois de um golpe, espere e observe o retorno à mesma guarda, com respiro.

## Implementação e limites

- `vega_combate.gd`: alternância e seleção de clipe, captura existente de 100 ms; ambos os golpes voltam à guarda de 160 ms. Contador apenas visual, não baseado em Combo. Biblioteca privada por instância.
- `soco_distante.tres`: catorze trilhas nativas, ciclo de 560 ms; posições inferiores iguais às do golpe próximo. Rotações do lado distante compensam sua base espelhada. Outro braço permanece protegendo rosto/peito; sem alongar segmentos ou girar personagem inteiro.
- `mao_palmar_01.png`: nova vista para não tentar revelar a palma por espelhamento do dorso. Copiada sem editar pixels de saída do gerador; 1254×1254, RGBA, alfa do canto zero. Mesmo shader tonal existente. Sprite distante orientado em +X pelo giro π/2, escala uniforme 0.12, offset (−632,−1100), assentamento (−8,0); dimensões da textura diferem do atlas anterior. Miolo antigo oculto só nessa mão, não reutilizado fora do seu recorte.

Braço próximo e cenas de prévia não mudam. Nenhuma imagem anterior sobrescrita. F6 das provas continua histórico; a troca de vista e alternância estão em F5. Não há rotação 3D de palma para dorso durante o golpe; a vista palmar acompanha o osso. Naturalidade/perspectiva da arte nova aguardam avaliação do usuário, não são aprovadas automaticamente.

## Verificação

Godot 4.7.2. Integração passou headless/OpenGL: quatro golpes alternados, retorno, interrupção cruzada, dano, cartas reais, defesa/inválida, reduzido/reset, transparência/vista específica, proporções de ossos e apoios em 57 amostras por golpe. Regressões apoio_corporal, encaixes_nativo e polimento_combate passaram headless. Combo_nativo falhou duas vezes sem passo fixo em “ganho percorre valores intermediarios” (timer de 80 ms); passou com `--fixed-fps 60`. Não alterado o teste nem a regra para contornar a falha. Suíte completa não executada. Avisos anteriores de recursos/RID/fontes/ObjectDB continuam no encerramento de main; importação retornou 0 com esses avisos.

32 capturas e `alternancia.avi` em `docs/evidencias_vega_alternancia_22/`, sem sobrescrever evidências antigas. PNGs de guarda e impacto distante 1920/detalhe e impacto 1024 inspecionados; versão final da mão também inspecionada. Vídeo gerado: 133 frames/30 FPS/1152×648, exit 0; não assistido integralmente.

## Proveniência da arte

Skill `imagegen`, ferramenta embutida (não CLI/API direta). Referências: atlas `combate_v2/base_e_punhos_01.png` e captura `evidencias_vega_guarda_viva_22/detalhe_guarda_respiro_000_1920.png`. Arquivo final: `vega_animada/rig_nativo_v2/mao_palmar_01.png`. Skill `animate` orientou separação dos clipes, captura da pose atual, retorno e alternativa reduzida; sem nova biblioteca ou solver.

Prompt usado, integral:

```text
Use case: precise-object-edit. Asset type: isolated game sprite for Vega's FAR cybernetic clenched fist, PALMAR VIEW. Image 1 is material/design reference, especially the two detached fists; image 2 is the in-game style/scale reference. Output ONLY ONE isolated closed cybernetic fist and wrist cuff, genuinely transparent background. Show the PALM SIDE of a tightly closed fist to the camera: four curled segmented fingers clearly overlap the palm, thumb folds across them, flexible dark graphite palm pad visible, NOT a broad silver dorsal armor plate. It is the reverse/inside surface of the reference gauntlet. Keep the same fine inked comic-book drawing, charcoal synthetic-muscle cables, small graphite armor segments, restrained cyan wrist ring and tiny magenta latch. Match reference muted graphite, avoid bright white metal. No skin, no forearm, no arm, no body, no words, no multiple views. Sprite upright: cuff at bottom, fist knuckles at top, anatomical thumb on LEFT side of image, almost frontal palm-facing-camera with subtle three-quarter volume. Wrist center and knuckle center aligned vertically. On a square canvas with generous clear margins, approximate visible shape from x=250 to770 and y=180 to850, cuff attachment center around (512,830) and closed knuckles around (512,210) on a 1024px canvas. The hand must remain a CLOSED fighting fist, not an open stop gesture. Preserve crisp contours with no drop shadow/background or halo. This is a matching replacement view, not a redesign.
```
