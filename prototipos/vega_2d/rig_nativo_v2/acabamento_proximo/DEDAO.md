# Correção localizada do dedão — 22/10/2026

Relato adicional do usuário durante o passe: um dedão aparecia por cima da mão quando deveria ficar para dentro nessa vista. Identificação adotada e comunicada: mão próxima, a que mostra a placa dorsal; usuário ainda não confirmou explicitamente o lado.

Skill imagegen, edição embutida de `punhos_pareados_01.png`, arquivo previamente visto. Gerada revisão `punhos_pareados_02.png`, 1774×887 RGBA. Inspeção: remove a peça de polegar exposta sobre o lado externo do dorso; fechamento o deixa oculto atrás dos dedos, sem quinto nó saliente. Não houve giro/espelhamento da mão inteira nem alteração de ossos/poses/soquete/escala.

Somente o recorte DORSAL da revisão 02 é consumido por `vega_prova.gd`. A mão palmar distante continua lendo a revisão 01: ainda que o gerador tenha redesenhado pixels da metade direita, eles não são usados. Assim a palma e sua orientação permanecem exatamente anteriores. Arquivos 01 e original gerado preservados.

Verificação após a correção: importação exit 0; `test_acabamento_proximo` OpenGL/fixed-fps 60 passou com zero falhas/exit 0, sem avisos no teste isolado. Mantém 922 pixels do ombro/zero fora, e zero sobreposição punho distante/pele nos cinco instantes da respiração. `test_vega_nativa_combate -- --acabamento` passou headless/fixed-fps 60, zero falhas/exit 0; continuam os avisos de recursos ao encerrar main. Não repetida integração OpenGL após esta edição de textura. Seis novas capturas ampliadas guarda/impactos Combo 0/10 em `docs/evidencias_vega_face_interna_02/`; inspecionadas guarda Combo 0 e impacto próximo Combo 10. Sem revisão de vídeo ou validação anatômica 3D. F6 da mesma prévia inclui a correção; F5 permanece anterior.

Exercício: comparar os PNGs `ampliado_respirar_combo0.png` das pastas 01 e 02 a 100%, olhando apenas o contorno da mão próxima. A mudança deve ficar na leitura do polegar, não no alcance.

## Proveniência / prompt integral

Original: `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-1353a765-3496-445b-aa82-1d8a366fb275.png`.
Destino no projeto: `vega_animada/rig_nativo_v2/acabamento_proximo/punhos_pareados_02.png`.
Cópia integral do PNG, sem edição externa de pixels.

```text
Use case: precise-object-edit.
Edit target: the supplied transparent 1774x887 paired-fist atlas. Make ONE localized anatomy correction in the LEFT/dorsal fist only. Keep the right/palmar fist completely unchanged.
Problem: the left fist shows an incorrectly exposed plated thumb on the upper-left/front of the back-of-hand view. In this near-fist camera view the thumb should curl INWARD, mostly occluded behind the clenched fingers, on the INNER RIGHT edge of the fist, not stick up over its back.
Remove that conspicuous thumb assembly from the left fist's upper-left side (the small horizontal layered silver thumb plates crossing in front of the first knuckle). Reconstruct that left edge as a clean, narrow outside/pinky edge with dark braid and graphite armor. Keep exactly FOUR knuckles across the top. The thumb should be mostly hidden on the RIGHT INNER edge behind the folded fingers; at most a short narrow tucked dark segment visible along that right edge below the knuckle line. No fifth top knuckle, no raised thumb, no thumb resting on top of the dorsal plate, no open fingers.
Preserve the entire large back-of-hand graphite plate, four knuckle sizes/positions, wrist cuff design and registration, wrist socket centers, lighting, ink, palette, scale, canvas dimensions, transparent margins and the entire right fist as closely as possible. Do NOT mirror or rotate either fist or change the rig axes. Keep actual alpha transparency, no background/labels/text. Same comic rendering, no new details outside the localized correction.
```

