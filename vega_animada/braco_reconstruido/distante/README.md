# Braço distante: guarda estática — prova 07

Autorização do usuário para seguir, com cuidado explícito com coerência e juntas. Esta prova não altera o braço próximo aprovado na etapa 06, o F5 ou suas cenas de referência.

Retorno posterior à etapa 09, em 22/10/2026: “agora sim temos algo”. Feedback favorável ao conjunto visual; preservar a guarda, calibração da palma e paleta como base. Não implica aprovação de movimento distante, alternância, Combo ou F5. As referências a avaliação pendente abaixo descrevem o estado da entrega antes deste retorno. Nenhum movimento adicional foi implementado apenas por esse comentário.

## Ajuste posterior: harmonia da paleta — etapa 09

Usuário confirmou melhora do tamanho (“agora sim”), mas apontou diferença de cores. Aprovada a calibração local das mãos, não presumir aprovação final da montagem. Observado nas fontes: cinzas da vista interna têm menos azul, com médios/claros ligeiramente mais quentes que os próximos. Exemplos de RGB médio em três faixas neutras: médios próximos (.406,.397,.438), distantes (.420,.404,.416). Comparação condicionada à luminância/croma, não prova de equivalência de iluminação ou dos materiais em todos os pontos.

`paleta_distante.gdshader` aplica ganhos RGB suaves por luminância nos tons neutros. Protege acentos saturados (croma ≥ .20), pretos muito escuros e reflexos quase brancos. Não altera alfa, UV, geometria ou arquivo PNG. Os ganhos não usam `source_color`: são multiplicadores numéricos, não cores a converter de sRGB. Mesmo material privado nas três malhas distantes; nenhuma atribuição ao braço próximo/corpo. Os médios distantes tratados passam aproximadamente a (.407,.398,.437) na amostragem CPU.

**C** na prévia compara original/corrigida na mesma pose. No Inspector, `harmonizacao_cor` entre 0 e 1 regula intensidade; padrão 1. Exercício reversível: experimentar .5 e restaurar 1, sem tocar no tamanho da mão ou posição do punho. A continua comparando a montagem distante antiga; O mostra juntas. Esta correção de cor não exige gerar outra pintura ou mudar encaixes.

Godot 4.7.2/fixed-fps 60, teste `test_paleta_distante.gd` headless/OpenGL: zero falhas/exit 0. Médias dos cinzas aproximam-se da referência nas três faixas amostradas. 16 amostras GPU sintéticas conferem ganho, intensidade zero, ciano/magenta saturados, preto e alfa parcial/zero; não representam todos os materiais. Comparação do render nativo completo: 10.655 pixels RGB alterados e os 760.884 pixels alfa idênticos. Handler C exercitado sem teclado físico. Teste distante passou headless/OpenGL com 175 pontos CPU/175 GPU de juntas e mesma proporção das mãos; regressão ombro aprovado passou headless (133 poses), zero falhas/exit 0. Testes/captura sem stderr. Sem suíte inteira, integração com cartas ou movimento distante.

Seis capturas OpenGL, exit 0, em `docs/evidencias_vega_distante_paleta_09/`: original/harmonizada na mesma pose, prancha/visual nativo, marcos e detalhe de juntas. Inspecionados os dois visuais nativos e as juntas. Correção discreta de temperatura; não unifica toda diferença de desenho/sombreado entre as fontes. Evidências 07/08 preservadas; paleta ainda aguarda avaliação do usuário. Não executada nova importação do editor nesta etapa.

## Ajuste posterior: tamanho da palma — etapa 08

Relato do usuário: mãos parecem de tamanhos diferentes, mas montagem está indo bem. Não é aprovação final da guarda. Medida da tinta opaca nos eixos de cada punho, incluindo projeção distante .92 (não o bbox da mão girada na tela): próxima 78,358×65,357; distante anterior 60,141×52,771. Comprimento distante era 76,75% e largura 80,74% dos próximos. A densidade raster comum não bastou para calibrar duas pinturas diferentes.

`vega_distante.gd` agora expõe `ajuste_mao_distante = 1.20`: amplia uniformemente só a malha palmar em torno do zero do punho. Dimensões resultantes 72,169×63,326, aproximadamente 92,10% do comprimento e 96,89% da largura próximos. Mantida pequena diferença de projeção; a escolha visual ainda depende do usuário. Ossos, inserção, sentido do polegar, braço próximo, guarda, PNG/UV e demais peças não mudam. Não gera nova imagem ou corrige tamanho deslocando a mão.

Godot 4.7.2/fixed-fps 60: teste distante passou headless/OpenGL, zero falhas/exit 0. Agora mede proporção das mãos e confere 175 pontos CPU e 175 GPU, incluindo 70 pontos adicionais na ponte punho–palma. Raiz centrada, escala uniforme, orientação e isolamento do próximo continuam verificados; zero sobreposição entre 695 pontos centrais do antebraço. Sem suíte completa, integração de cartas ou teste de movimento distante. Captura GL exit 0, seis PNGs em `docs/evidencias_vega_distante_mao_08/`; inspecionados corpo e detalhe das juntas, sem vão observado na região mostrada. Testes/captura sem stderr. Evidências 07 preservadas. Os resultados originais abaixo descrevem a entrega anterior à calibração.

Exercício reversível: na cena `vega_distante.tscn`, testar `ajuste_mao_distante` em 1.15 e restaurar 1.20 no Inspector. O deve mostrar que o centro do punho continua no mesmo lugar. F5 intacto; não adaptar animação antes de avaliar esta guarda.

## Ver no editor

Abrir `preview.tscn` desta pasta e executar **F6**. **A** compara apenas o braço do fundo antigo/novo; **O** mostra os centros das juntas. Não há soco ou respiração nesta prova: primeiro avaliar a guarda.

Exercício pequeno: usar A e O para comparar a inserção na pele, o cotovelo preenchido e a raiz da palma. Para experimentar uma mudança reversível, alterar somente `cotovelo_distante_guarda` de 120 para 118 no Inspector da cena `vega_distante.tscn`, executar F6 e restaurar 120. Não compensar mudando a posição da mão; o centro do punho é compartilhado.

## Observado, regra e hipótese

Observado: o braço distante ainda era a montagem anterior, com peças/placas independentes e palma própria. Reutilizar a nova arte dorsal próxima como espelho não produziria a face interna ou a palma corretas.

Regra: preservar o próximo aprovado, os comprimentos e a inserção da cadeia distante no corpo. Tratar materiais, sentido do polegar e continuidade das juntas como parte do mesmo desenho. Nenhuma mudança em cartas, alcance, Combo ou F5 para contornar a arte.

Hipótese desta prova: gerar a vista interna montada, registrar seus centros e separar apenas três segmentos reduz incompatibilidade entre fibras, placas, junta e mão. Guarda 135°/120°/0° abre 60° internos para não repetir a sobreposição dos ventres. É candidata estática, ainda sem aprovação visual do usuário ou validação de movimento.

## Arquivos e registro

- `braco_interno_01.png`: fonte própria inteira, com face palmar, gerada com transparência. Sem edição raster posterior.
- `braco_distante.gd`: usa os helpers de registro uniforme e criação de ossos da montagem próxima, sem modificar o arquivo aprovado. Cada uma das três malhas amostra a nova fonte. Não acrescenta placas ou aros independentes.
- `vega_distante.gd/.tscn`: herda o corpo/ombro próximo da prova 06, pausa a guarda e instala a nova cadeia no deltoide distante. Mesma raiz, reflexão de projeção (−.92,.92) e profundidade do lado distante anterior. Esconde o braço distante antigo inteiro.
- `preview.gd/.tscn`: reutiliza o enquadramento e fonte da prancha de diagnóstico; comparação e guias apenas. Sem alterar HUD do jogo.

Marcos lidos visualmente na fonte real 1024×1536, aproximados e passíveis de revisão artística:

| Marco | Pixel |
| --- | --- |
| Inserção do ombro | 535,135 |
| Dobradiça do cotovelo | 500,650 |
| Centro do punho | 500,1200 |
| Fim dos dedos fechados | 510,1460 |

Comprimentos nativos 128.06041074 / 133.9084538 / 100.065 preservados. Registro uniforme por segmento, sem alongar apenas um eixo. A escala da malha palmar é calculada para manter a densidade raster do antebraço (aproximadamente .633); o osso nominal não muda. A palma é intrinsecamente mais compacta que o dorso da outra fonte; percepção de tamanho ainda exige avaliação. Raiz da mão permanece no zero do punho.

A reflexão transversal da **malha palmar** orienta o polegar para dentro na base já refletida do rig distante. Não é um truque para converter dorso em palma: a nova fonte já desenha a palma. Não reflete o braço próximo nem toda a pintura distante. Ombro/cotovelo/colar do punho pertencem à pintura dos segmentos, com sobreposição curta junto aos centros. Mipmaps e filtro linear com mipmaps mantêm o tratamento de redução usado no braço aprovado.

## Verificação executada

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility/OpenGL, fixed-fps 60.

- `tests/test_guarda_distante.gd` passou headless e OpenGL: zero falhas/exit 0.
- Registros, escala uniforme, raízes compartilhadas, projeção/camada, nova fonte palmar e posição do polegar conferidos. Arte, geometria, UV/pesos e transformações do próximo aprovado preservados; clipes existentes não redirecionados para o novo distante.
- 105 pontos CPU dentro da própria pintura das três peças cobrem as pequenas faixas de ombro/cotovelo/punho. Corpo não participa dessa união: não pode esconder um vão no teste.
- 105 pontos GPU correspondentes opacos na montagem renderizada, zero falhas. São pontos amostrados, não inspeção de toda a borda ou garantia anatômica.
- Faixa central pintada do antebraço: zero sobreposições com bíceps entre 695 pontos, usando o helper existente. Exclui região da junta, onde sobreposição é necessária.
- Comparação antiga/nova e estabilidade por 12 quadros verificadas. Métodos exercitados, sem automação física de teclado.
- Regressões headless de ombro integrado e movimento 05: zero falhas/exit 0, 133 poses cada. Sem suíte completa ou integração com cartas.
- Captura OpenGL exit 0: seis PNGs em `docs/evidencias_vega_distante_guarda_07/`. Inspecionados guarda corporal, comparação anterior, guias e recorte nativo `juntas_detalhe.png`. No recorte, palma se assenta no colar e dobradiça ocupa a dobra; avaliação visual limitada, ainda aguardando usuário.
- Testes e captura finais sem stderr. Importações exit 0, conservando avisos conhecidos de recursos/RID/fontes/ObjectDB do editor ao encerrar. Sem vídeo, novos clipes ou teste de fluidez.

## Limites

Não adaptar soco, respiração, alternância ou expansão de Combo antes de validar a guarda. A pele distante continua anterior; não foi repesada/reconstruída nesta etapa. Pintura 2D não simula rotação longitudinal/perspectiva 3D em todas as fases. Nem alfa preenchido nem centros coincidentes garantem coerência artística. A versão aprovada permanece disponível sem esta candidata.

## Fonte e geração

Skill **imagegen**, ferramenta integrada (não CLI). Orientou criar uma vista interna montada com identidade da prótese aprovada, transparência real e preservação não destrutiva. Referências: `../braco_montado_01.png` (design/material da prótese aprovada) e `docs/arte_vega/vega_guarda_unificada_01.png` (estilo e palma distante).

Original: `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-4c5de033-e4c9-4645-8ef3-e15186f986eb.png`. Copiado sem alteração para `vega_animada/braco_reconstruido/distante/braco_interno_01.png`.

### Prompt final

```text
Use case: precise-object-edit.
Asset type: ONE assembled opposite-side cybernetic arm sprite for a 2D comic-book game, portrait 2:3, true transparent background.
Image 1 is the approved outer/dorsal near arm: preserve its mechanical identity, materials, proportions and ink rendering. Image 2 is the approved character style reference: use the INNER surface and closed PALM-facing fist of her farther arm, visible on viewer-right, to establish correct opposite-arm anatomy. Do not redraw the character.
Primary request: derive a companion arm to image 1, shown from the OTHER, INNER/PALMAR side, fully assembled and straight vertically down, shoulder at top, fist at bottom. Not a horizontal mirror of image 1. Same braided graphite synthetic muscles, compact silver-grey armor, small cyan seams and magenta locking tabs; restrained broad highlights and black ink outlines. The inside forearm should expose tendons/braided fibers, with outer armor only wrapping around the edges, NOT the same three large exterior armor plates facing the viewer. The closed fist must show the curled segmented fingers and PALM pads, not a large back-of-hand armor plate. Exactly four folded fingers with one short thumb tucked ACROSS the curled fingers. No thumb protruding upward out of the wrist.
Assembly: shoulder insertion rounded solid cap; upper arm to compact rounded elbow centered on same axis; forearm to narrow wrist, fist root precisely centered in the wrist cuff. All three joints solidly seated with short flexible sleeves, no empty holes or detached plates. No gaps between arm parts. This will be divided at the elbow and wrist for a native skeleton, so draw those transitions rounded and compact. Upper arm and forearm roughly equal lengths; the closed fist from wrist to end should be about 50% of forearm length, matching a human fighter, not an enormous gauntlet.
Layout: same tall centered straight arm layout as image 1, no bent guard pose, no foreshortening or diagonal spread. Neutral source image only. Shoulder near top y=140; elbow near y=660; wrist near y=1200; fist ends near y=1470 on a 1024x1536-style canvas. Keep centerline close to x=512 at all three joints, adequate transparent padding. Small natural thickness changes, no exaggerated muscles.
Constraints: change the view/laterality, NOT the design family or material style. Only ONE arm, no additional hands, no exploded parts, no annotations, no markers, no skin, no head, no full character, no floor, no shadow/background glow or opaque background. Preserve alpha transparency. No text, logos or watermark. Maintain mature drawn comic-book ink, not 3D render or glossy generic robot illustration.
```

