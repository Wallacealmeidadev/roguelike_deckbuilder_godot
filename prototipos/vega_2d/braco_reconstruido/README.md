# Um braço reconstruído — prova estática 01

**Para a etapa atual de movimento:** abrir `preview_movimento.tscn` e executar F6. Espaço soca; D interrompe por dano; R alterna reduzido; L ativa câmera lenta. Ver [MOVIMENTO.md](MOVIMENTO.md). As provas estáticas e sua aprovação permanecem preservadas.

Autorizada pelo usuário em 22/10/2026 após rejeição da montagem anterior. Não substitui F5, a variante `rig_nativo_v2/acabamento_proximo/preview.tscn` ou o movimento aprovado.

Etapa seguinte autorizada: `preview_corpo.tscn` avalia **um braço no corpo**, em guarda recalibrada, sem trocar esta prancha ou a arte. F6; A compara e O mostra marcos. Detalhes, limites e verificação em [ENCAIXE_CORPO.md](ENCAIXE_CORPO.md). Os resultados abaixo descrevem a etapa isolada original.

## Conferir no editor

Abrir `preview.tscn` e executar **F6**. A prancha mostra alinhamento neutro, guarda e extensão simultaneamente. **O** alterna os marcos/eixos. Conferir sobretudo a continuidade junto ao cotovelo, a raiz da mão centrada no punho e a leitura das placas sobre as fibras. As linhas são diagnóstico, não efeito do jogo.

Pequeno exercício: em `preview.gd`, mudar apenas a escala da terceira instância de `1.1` para `1.3`, executar F6, observar o punho e restaurar. Não mover a mão para compensar um recorte: o centro comum precisa continuar sendo referência das duas peças.

## Observação, regra e hipótese

- **Observado:** na montagem anterior, fibras, placas, aros e mãos tinham recortes e transformações independentes. O usuário rejeitou sua conexão visual apesar dos testes de estabilidade/cobertura.
- **Regra de design:** preservar identidade e movimento aprovados; placas assentadas na prótese, mão e antebraço compartilhando a junta. Não alterar alcance, resolução de cartas ou Combo para contornar arte.
- **Hipótese em avaliação:** partir de uma única pintura montada e derivar três segmentos por marcos comuns reduz incompatibilidades de perspectiva/registro. Esta prova estática não demonstra que o desenho funcionará em todos os instantes do soco ou encaixará na pele do ombro.

## O que existe nesta prova

Uma fonte transparente, sem edição raster posterior. Três `Polygon2D` amostram essa mesma imagem; placas, acentos e fibra pertencem à pintura de cada segmento. Não existem sprites adicionais de placa/aro ou preenchimentos independentes. Recortes e sobreposição das regiões articuladas são geometria/UV nativas da Godot.

`braco_registrado.gd` cria somente a cadeia `Skeleton2D / Ombro / Cotovelo / Punho`. Os comprimentos são os da prova nativa anterior: 128.06041074 / 133.9084538 / 100.065. Guarda (105°, −160°, 0°) e extensão (−8°, 7°, 0°) são amostras estáticas da prova anterior; o alinhamento neutro (90°, 0°, 0°) é diagnóstico, não nova pose de repouso da lutadora.

Marcos lidos visualmente na fonte real de **1024×1536** — coordenadas aproximadas, sujeitas a avaliação artística:

| Marco | Pixel da fonte |
| --- | --- |
| Inserção do ombro | 478, 135 |
| Centro da dobradiça do cotovelo | 558, 650 |
| Centro do punho | 550, 1190 |
| Ponta dos nós dos dedos | 520, 1490 |

Para cada segmento, a transformação leva sua origem ao `(0,0)` do osso e o marco distal a `(comprimento,0)`. Rotação e escala uniforme corrigem a inclinação real da imagem, sem alongamento transversal independente. A mão usa a calibração de seu próprio comprimento; não representa a mesma escala raster do antebraço. Tamanho/perspectiva continuam candidatos: coincidência matemática de centros não comprova anatomia correta.

O cotovelo pintado pertence ao segmento superior, sobre a raiz do antebraço; o colar do punho pertence ao antebraço, sobre a raiz da mão. Camadas positivas evitam esconder a mão sob o fundo da prancha. Importação com mipmaps e filtro linear com mipmaps; nenhum renderer ou filtro global alterado.

## Verificação realmente executada

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility/OpenGL, fixed-fps 60.

- `tests/test_braco_reconstruido.gd`, headless e OpenGL: zero falhas/exit 0. Três registros, três poses, comprimentos e ângulos comparados à cena anterior; escala uniforme, fonte única, alinhamento dos centros e ordem de desenho.
- Regressão `tests/test_encaixes_nativo.tscn`, headless/fixed-fps 60: zero falhas/exit 0. Não foi executada a suíte inteira ou integração da nova arte com cartas.
- OpenGL: nove pontos renderizados (cotovelo, punho e interior da mão em cada pose), alfa maior que .9. É amostragem limitada, não inspeção de todos os pixels ou prova de movimento.
- `preview.tscn -- --capturar`: exit 0, duas capturas em `docs/evidencias_vega_braco_reconstruido_01/`, ambas inspecionadas. Corrigida durante a prova uma ordem de desenho que ocultava a mão sob o fundo; teste de ancestrais reais adicionado.
- Importação headless: exit 0, mas mantém avisos preexistentes de recursos/RID/fontes/ObjectDB ao encerrar o editor. Teste isolado e captura finais OpenGL sem stderr.

No teste gráfico, uma primeira tentativa usou propriedade inexistente `own_world_2d`; corrigida para `world_2d = World2D.new()` conforme [Viewport na documentação 4.7](https://docs.godotengine.org/en/4.7/classes/class_viewport.html#class-viewport-property-world-2d), antes do resultado final acima.

Ainda **não** implementado/validado: inserção no ombro humano, segundo lado/palma, Combo/deformação com placas integradas, transições animadas, dano/interrupções da nova arte, integração com cartas ou migração de F5. A pintura tem brilho/detalhe próprios; coerência final com a referência HQ precisa de avaliação do usuário. Não confundir execução dos testes com aprovação artística.

## Fonte e geração

Ferramenta integrada de geração de imagens, fundo transparente. Referências: `docs/arte_vega/vega_guarda_unificada_01.png` (mestre aprovada) e `docs/arte_vega/vega_v2_referencia_04.png` (identidade/próteses). Original gerado em `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-061f5dd7-71af-4185-9677-91634c7403ab.png`, copiado sem alteração para `braco_montado_01.png`.

### Prompt final utilizado

```text
Use case: stylized-concept.
Asset type: production reference sprite for ONE assembled cybernetic arm, transparent background, portrait 2:3.
Input image 1: approved unified Vega, STYLE and mechanical identity reference, especially the arm on viewer-left showing the back of the closed fist. Input image 2: approved prosthesis concept, anatomy/material/design reference. Neither image is to be copied as a full character.
Primary request: draw a SINGLE fully ASSEMBLED near-side synthetic arm, straight down in neutral alignment, from shoulder insertion to closed fist. One continuous coherent object, not an exploded component sheet. All armor plates are genuinely attached flush to the braided muscle beneath them, with contact shadows. Upper arm, elbow hinge, forearm, wrist and fist share one anatomical centerline. The wrist is narrower than the forearm; the hand is centered on that wrist. The elbow is a filled rounded mechanical hinge, not an empty hollow tube. All joints are seated, with short flexible overlapping sleeves and restrained cyan/magenta seams. No visible empty sockets at elbow or wrist.
Proportions/layout: tall 1024x1536-style canvas, vertical centerline near x=512. Shoulder insertion center near (512,150), elbow center near (512,600), wrist center near (512,1070), fist ends near y=1440. Upper arm and forearm almost equal lengths; a substantial but human-proportioned closed fist, about 70% forearm length including knuckles. No foreshortening, no bend, no diagonal offset. Show outer/dorsal surface of this near arm, a small thumb tucked inward along the right edge, four closed knuckles at bottom. Shoulder insertion must be a solid rounded cap that can seat below Vega's existing human deltoid; do not draw the skin/torso.
Style: same mature comic-book ink, grouped dark graphite braided synthetic muscles, restrained broad grey highlights, thick clean contour, upper-left lighting and two/three value groups as image 1. Same sleek graphite plates and small cyan/magenta joint details, no yellow machinery or oversized industrial gauntlet. Forearm has three fitted overlapping armor panels painted as part of the forearm surface, not floating shards. Upper arm has one fitted outer armor plate. Do not add a separate plate catalog, labels, guide lines, joint markers, diagrams or multiple arms.
Constraints: ONLY this one assembled straight arm. Transparent alpha all around. No background, person, head, human shoulder, floor, cast shadow, text, watermark or extra pieces. Do not make an open hand. Do not depict disconnected/floating rings or finger parts. This image will be registered by measured joint centers before being split into THREE segments in the game; keep each hinge/wrist transition compact and rounded.
```
