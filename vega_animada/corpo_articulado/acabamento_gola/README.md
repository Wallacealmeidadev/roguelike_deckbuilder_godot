# Acabamento localizado 11: pescoço e gola

23/10/2026 — Godot 4.7.2.stable.official.ed1daf0bf / Compatibility.

## Recorte e intenção

Observado: a prova corporal 10 aceita já move abdômen, peito e cabeça independentemente, mas reutiliza a pintura corporal anterior. A referência localizada 01 recebeu o relato “parece bom”. Após esclarecer que a pergunta pelas pernas era apenas informativa, o usuário autorizou continuar a etapa em curso.

Regra: preservar identidade, rosto/cabelo, braços/mãos aprovados, parte inferior, pesos, poses e duração. Nenhuma migração ao F5. Hipótese artística: planos do pescoço, sombra sob mandíbula e contato da gola mais definidos podem unir melhor cabeça e peito. Esta é uma candidata discreta, não arte corporal final aprovada.

## Conferir no editor

Abra `preview.tscn`, execute F6. Esquerda: acabamento desligado; direita: candidato. Os dois lados executam o MESMO movimento da prova corporal 10, não versões diferentes do soco.

- 1/G: guarda; 2: preparo; 3: impacto.
- Espaço: golpe, inclusive recomeço durante a ação.
- A: alternar pintura da direita sem mudar a pose. Esquerda permanece original.
- Z: alternar detalhe ampliado/corpo inteiro. O recorte ampliado é intencional e não mostra toda a cabeleira/extensão dos braços.
- L: quatro vezes mais lento. R: movimento reduzido. O: guias das juntas na candidata.

O preparo deixa mais pescoço/gola descobertos; a mão e o braço ocluem parte da região na guarda/impacto. Conferir continuidade e ausência de emenda, não apenas comparar saturação. O efeito é localizado e discreto na escala de combate.

Exercício pequeno: abra `vega_gola.tscn`, selecione a raiz e ajuste **Intensidade Gola** de 1 para 0,5, execute a prévia e compare; depois restaure 1. Isso mistura a pintura, não altera os ossos. O atalho A alterna 0/1 durante execução.

## Como acompanha o movimento

`vega_gola.gd/.tscn` herda a prova corporal aceita sem editar sua cena/script. Só atribui um ShaderMaterial privado à Polygon2D Pele. A textura corporal original, geometria, UVs, pesos e clipes continuam iguais. Não existe nova camada rígida, Sprite2D de pescoço, bone, solver ou correção por frame.

`gola.gdshader` lê o novo atlas nas mesmas UVs do original, com máscara poligonal de dez pontos (coordenadas em `CONTORNO`) e transição interior de 3 pixels. Assim a pintura é amostrada pela mesma superfície deformada pelo Skeleton2D. Só RGB dentro do contorno pode mudar. Alfa e modulação de cor continuam originais. Face acima da mandíbula, cabelo, ombros, próteses e parte inferior permanecem com suas fontes anteriores. O acabamento já existente do ombro não foi alterado.

A imagem gerada também reinterpreta pixels FORA da região. Não usar o atlas inteiro como substituto. A preservação externa é imposta pelo material e conferida em GPU, não presumida a partir do prompt. Não há registro de aprovação visual desta aplicação ainda.

## Origem da arte

Skill imagegen, ferramenta integrada, modo de edição. Alvo: `vega_animada/combate_v2/base_e_punhos_01.png`. Referência SOMENTE para acabamento do pescoço: `docs/arte_vega/vega_pescoco_gola_ref_01.png`. Ambos inspecionados antes da chamada.

Original: `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-9d6ad786-4b6e-4274-a671-f58b396abe74.png`. Copiado sem edição raster para `atlas_gola_01.png`, 1774×887 RGBA, mesmo canvas do atlas corporal. SHA256 original/cópia: `682A50B1D60947574F36733D8BEAC4CA1D054F4D48F391C31B3CCA997F17FFAB`.

### Prompt final

```text
Use case: precise-object-edit.
Asset type: registered texture atlas edit for a 2D comic-book character rig.
Input image 1 is the EDIT TARGET: the wide transparent atlas with Vega's armless body on the left and TWO detached fist sprites on the right. Input image 2 is ONLY a shading/style reference for the HUMAN neck and tank-top neckline, NOT a new pose, framing, face, arms, or hair to copy.
Edit image 1 in place. Keep its EXACT full wide canvas, same dimensions/aspect ratio, full body, sprite positions, scale, silhouette, transparency and empty margins. Do not crop, zoom, reposition or add arms.
Only repaint the tiny existing human neck area between the bottom of the jaw and the black tank-top collar on the left-hand body: clearer broad shadow under the jaw, two restrained neck planes, subtle clavicle form and a fine dark cloth contact edge. Use image 2's hand-inked HQ shadow grouping but fit image 1's EXISTING geometry precisely. Keep the existing neck length/width and warm tan skin palette. The collar opening and straps must stay in the exact same place. Continuous human neck flowing into chest, no cybernetic neck joint.
All other pixels/subjects should remain unchanged: same face, eyes, nose, mouth, jaw contour, stern grumpy expression, hair, shoulders, metal shoulder cuffs, chest clothing, tied burgundy shirt, trousers, boots, two detached hands. No reinterpretation of face or pose. No glow, halo, labels, marks, border, scenery, extra parts, accessories, scars, jewelry, photorealism or gradients. Transparent RGBA background. This is a narrowly localized production retouch, NOT a new character illustration or concept board.
```

## Verificação executada

- `tests/test_gola_vega.gd` passou headless e OpenGL/fixed-fps 60, zero falhas/exit 0. Headless não verifica pixels.
- 57 poses mantêm transformações corporais e das mãos da base; mesma geometria/UV/faces/textura original, pesos e chaves/tempos de todos os clipes. Comparação da pintura não move o rig.
- GPU do atlas inteiro: 3.636 pixels RGB alterados DENTRO da máscara, zero fora, zero alfas alterados. Isso inclui proteção das regiões de rosto/cabelo/roupa e demais sprites fora do contorno.
- GPU nativa: guarda/preparo/impacto com efeito presente e transparência idêntica; acabamento desligado reproduz a base SEM material com zero divergências de RGB/alfa visível. Não constitui avaliação anatômica/artística de toda a personagem.
- Interrupção, retorno à guarda e reduzido preservados; handlers A/Z/1/2/3/L/O/R/Espaço exercitados por script, sem teclado físico automatizado.
- Regressão `tests/test_corpo_articulado.gd` passou headless e OpenGL: zero falhas/exit 0, 57 poses, 1.254 amostras GPU, nenhuma face invertida, botas fixas e guarda rebind com desvio máximo 0,000130 px.
- Captura OpenGL: 12 PNGs em `docs/evidencias_vega_gola_11/`, exit 0/“capturas OK”; detalhe e corpo nas três poses, nativos antes/depois. Inspecionados os três detalhes e corpo no impacto. Logs finais dos testes/capturas sem stderr. Sem vídeo novo ou playtest do combate principal.
- Importação inicial encerrou com avisos de recursos/RID/ObjectDB já registrados em etapas anteriores. Um erro inicial de declaração constante PackedVector2Array foi corrigido para Array[Vector2], convertido no envio ao shader; testes finais sem erro de parsing.
- Sem suíte inteira, mudança de regras/HUD, pernas novas, movimento novo, Combo ou F5. Validação visual com Wallace ainda pendente.

