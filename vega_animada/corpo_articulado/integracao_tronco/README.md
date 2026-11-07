# Integração visual 12: tronco e próteses

23/10/2026 — Godot 4.7.2.stable.official.ed1daf0bf / Compatibility.

Retorno posterior: usuário disse “muito bom” sobre a prova 12. Conjunto visual bem recebido e referência a preservar. Não equivale a personagem inteira finalizada, golpe distante/alternância/Combo adaptados ou migração F5 aprovada. Menções abaixo à avaliação pendente descrevem a entrega anterior a esse retorno.

## Objetivo e recorte

Usuário autorizou o próximo passo de integração artística após relatar pouca diferença na gola 11. Não aumentar o retoque do pescoço nem inferir aprovação da coerência geral.

**Observado:** metal/fibras têm contraste e contornos mais definidos que pele/regata; braço sobre o peito não tinha sombra de contato correspondente. Ombro próximo usa ainda uma pintura de outra fonte em uma superfície ponderada que também contribui para a cobertura final.

**Regra:** preservar identidade, roupa, mãos, próteses e suas proporções/encaixes, movimento corporal aceito, parte inferior e F5. Só apresentação nesta variante.

**Hipótese artística:** agrupar sombras/dobras da regata e planos dos ombros em leitura mais gráfica e acrescentar contato entre braço próximo/roupa melhora a unidade na escala do jogo. Isso é uma proposta aplicada para avaliação; pixels alterados/testes não demonstram aprovação artística ou resolvem todas as discrepâncias de perspectiva/contorno.

## Experimentar

Abra `preview.tscn`, F6. Começa em **corpo inteiro**, para não depender de um detalhe ampliado. Esquerda é o acabamento anterior, com a gola 11; direita é pintura + contato. As duas usam exatamente o mesmo clipe corporal.

- 1/G: guarda; 2: preparo; 3: impacto.
- Espaço: golpe; aceita recomeçar durante a ação.
- A: alternar todo o passe novo da direita, mantendo pose/gola anterior e restaurando pintura antiga do ombro. Esquerda não muda.
- S: alternar só a sombra. Ajuda a separar o efeito da pintura.
- Z: detalhe ampliado/corpo inteiro. L: quatro vezes mais lento. R: reduzido. O: juntas da candidata.

Exercício: na cena `vega_integracao.tscn`, raiz, compare **Sombra Contato** 0,32 com 0,16, execute a prévia e observe o preparo/golpe; restaure 0,32. Isso altera a força da sombra sobre a regata, não a trajetória das mãos. S alterna 0/0,32 durante execução.

## O que mudou

`atlas_tronco_01.png`: edição raster gerada do atlas original, com dobras mais agrupadas em planos escuros na regata e pintura dos ombros humanos. A geração também reinterpretou outras regiões (inclusive pernas). Não usar o arquivo inteiro como textura substituta.

`vega_integracao.gd/.tscn`: variante herdada da gola 11. Atribui material privado à mesma malha Pele, sem modificar fonte original/UV/vertices/faces/pesos/clipes/bones. A máscara UV da gola anterior continua; a pintura nova é limitada a outro polígono de dez pontos, com 4 px de transição interna, exclusão do pescoço e proteção do bordô da cintura. Anatomia, proporções e a parte inferior não são redesenhadas em produção.

`ombro.gdshader`: a superfície de acabamento do ombro continua existente, com mesmo recorte, geometria, pesos, alfa e ordem. Só seu RGB é interpolado para a pintura corporal registrada. A primeira tentativa de apagar essa superfície mudou a cobertura: foi descartada, não se relaxou a exigência de transparência idêntica. Não há novo ombro humano, soquete ou conector animado.

`integracao.gdshader`: sombra de contato aproximada por duas cápsulas (braço superior e antebraço próximos) sobre o receptor da regata. Ossos existentes fornecem os centros, raio acompanha escala e luz é sugerida pelo deslocamento (4,7) px nativos. Força padrão 0,32, raios 22/25 px, transição curta 8 px. Não sombreia rosto, pele ou as próprias próteses. Só escurece RGB; alfa continua da fonte original.

`sincronizar_sombra()` lê transformações com canvas em `RenderingServer.frame_pre_draw`, depois da avaliação do AnimationPlayer; não escreve ossos, geometria ou chaves e não usa um relógio próprio. Assim a sombra segue pausa, câmera lenta, interrupção e reduzido. Apenas o braço próximo que passa à frente do corpo projeta; o distante continua atrás.

APIs e espaços de coordenadas conferidos na [documentação oficial de CanvasItem shaders 4.7](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/canvas_item_shader.html). Posição do receptor deriva de SCREEN_UV/SCREEN_PIXEL_SIZE e é comparada com os centros no canvas do SubViewport.

## Origem da arte e prompt

Skill **imagegen**, ferramenta integrada, modo de edição. Entradas inspecionadas: `vega_animada/combate_v2/base_e_punhos_01.png` como alvo de registro e `vega_animada/braco_reconstruido/braco_montado_01.png` como referência de contraste/contorno. Sem CLI, edição Python ou repaint manual posterior.

Original: `C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-bde7eb84-87dc-4379-8a66-f6922608e5c8.png`. Cópia não destrutiva em `atlas_tronco_01.png`, 1774×887, mesmo canvas da fonte. Hash SHA256 de ambos: `4DCE208E541D8A947A818769DBD636AD67E32CA218B145F4F5138D23C8CA128C`.

### Prompt final utilizado

```text
Use case: precise-object-edit.
Asset type: registered 2D game character texture atlas, comic-book rendering integration.
Input image 1 is the edit target: a transparent 1774x887 wide atlas, armless Vega body at left and two detached fists at right. Input image 2 is the approved cybernetic arm, a STYLE REFERENCE only for decisive black ink, coherent upper-left lighting and organized contrast, NOT a part to paste or add.
Keep image 1's EXACT canvas/aspect ratio, sprite positions, scale, silhouette, anatomy and pose. Repaint ONLY BOTH EXPOSED HUMAN SHOULDERS, the armpit transitions, and the BLACK TANK TOP down to just above the burgundy waist knot. This must be a clearly visible comic-book rendering pass, not a tiny color correction. Make the black tank top feel like a solid cloth volume attached to shoulder girdle: broad angular near-black shadow groups on its far side/under armpits, a coherent middle charcoal chest plane, and a few strong directional fold shapes anchored at straps/armpits and waist. Replace the current many muddy brushed folds with fewer deliberate inked shapes readable at game-sprite size. Keep the garment matte, its exact neckline/straps/length and existing fit; do not create armor panels, ribs, seams, symbols, new clothing or cleavage. Skin on shoulders must have warm ochre light planes and clearly grouped warm-brown cel shadows around the underside deltoids/armpits, with controlled hatching matching the arm reference's ink language. Avoid soft airbrush, glossy skin and bodybuilding.
Keep all neck/head/face/hair pixels, expression and facial features unchanged. Keep the burgundy tied shirt, trousers, boots, two detached hands, original shoulder socket rims and background unchanged. Do not attach arms or draw new shoulders. No rim glow, halo, bloom, scenery, light fog, labels, text, frames or watermark.
Critical production invariant: EXACT geometry registration; repaint lighting and ink INSIDE the existing torso/shoulder silhouette only, with unchanged placement and proportions. Preserve original silhouette alpha. One full wide atlas, not a close-up or new posed character. Transparent RGBA background.
```

## Verificação real

- `tests/test_integracao_tronco.gd`: passou headless e OpenGL/fixed-fps 60, **zero falhas/exit 0**. Reaproveita verificadores da prova 11; 57 poses, mesmos pesos/UV/faces/texturas dos braços, transformações corporais/mãos, clipes/chaves/tempos; A, interrupção, retorno, reduzido e handlers verificados. Headless não verifica pixels.
- GPU atlas inteiro: **28.834 pixels RGB locais** de pintura alterados, zero fora do contorno, zero alfas. Essa contagem é da pintura corporal, não inclui a camada de ombro.
- GPU nativa guarda/preparo/impacto: desligar o passe reproduz a base 11 com **zero divergências RGB/alfa**. Pintura/contato preservam transparência final nas três poses. Sombra alterou 2.249/1.508/1.438 pixels respectivamente, só escurecendo (nenhum pixel clareado). 33 marcos de face/parte inferior/juntas protegidos nas verificações pertinentes.
- A posição da sombra acompanha os centros do braço em 57 poses; durante reprodução real, **18 quadros** conferidos no callback automático sem atraso observado e sem chamar sincronização pelo teste.
- Primeiro teste gráfico apontou transparência alterada ao apagar a pintura antiga do ombro; corrigido mantendo a cobertura antiga e trocando só RGB. A comparação de proteção das juntas para efeito de sombra foi separada da comparação de pintura: pele do ombro é alvo intencional, próteses não.
- Regressões `test_corpo_articulado.gd` e `test_gola_vega.gd` passaram headless/OpenGL, zero falhas/exit 0. Corpo: 57 poses/1.254 amostras GPU, quatro influências no máximo, zero faces invertidas, botas fixas. Gola conserva resultados de 3.636 pixels locais e zero externos/alfa.
- Capturas finais GL: **12 PNGs** em `docs/evidencias_vega_integracao_12/`, exit 0/“capturas OK”; três poses, corpo/detalhe e nativos antes/depois. Inspecionados os três detalhes finais e corpo inteiro no preparo. A regata tem planos mais agrupados e contraste maior visível nesses enquadramentos; julgamento de unidade artística ainda depende de Wallace.
- Logs finais de testes/captura sem stderr. Importação mantém os avisos conhecidos de RID/fontes/ObjectDB ao encerrar. Sem vídeo novo, suíte inteira ou playtest de combate/HUD. Provas anteriores e main_scene do F5 inalteradas.

## Limites

Sombra por cápsulas é aproximação de contato, não projeção exata das placas/dedos, iluminação física ou volumes 3D. Não resolve giro longitudinal, vistas ocultas, alteração de perspectiva de roupa ou caráter articulado de pernas/cabelo. A pintura continua deformada pela malha aprovada. Não acrescenta golpe distante, alternância, Combo, transição corporal nova ou refatoração do sistema. Esta prova não deve ser promovida ao F5 antes de avaliação.

