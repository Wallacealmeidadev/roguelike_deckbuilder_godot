# Prova 13: direto distante e golpes alternados

23/10/2026 — Godot 4.7.2.stable.official.ed1daf0bf / Compatibility.

Retorno posterior do usuário: “ficou ótimo, gostei muito da nova versão”. Conjunto visual e movimento dos golpes alternados aprovado como referência a preservar. Não implica adaptação de respiração/dano/Combo ou integração F5; menções abaixo à avaliação pendente descrevem a entrega anterior a esse retorno.

## Recorte

Usuário autorizou adaptar soco do braço do fundo e alternância depois de receber bem a integração visual 12. Preservar a pintura, membros/mãos/juntas e golpe próximo aceitos. Esta prova ainda não substitui o personagem do F5, não integra cartas/Combo e não adapta aqui respiração ou reação ao dano.

Observado: o braço distante reconstruído tinha guarda/elevação, mas não ataque próprio; a alternância do combate principal pertence à montagem anterior. Regra: manter comprimentos, palma, proporções, encaixes, arte e pés apoiados. Hipótese em avaliação: direto distante com esforço de pelve/abdômen/peito e mão próxima em guarda permite fechar o ciclo de ataques nesta montagem.

## Conferir no editor

Abra `preview.tscn`, F6. Esquerda mantém o golpe próximo da prova 12. Direita começa em guarda e alterna próximo/distante. A primeira leitura é em corpo inteiro.

- **Espaço:** próximo, distante, próximo… Não é necessário esperar o golpe acabar; outro comando captura a pose atual, sem fila.
- **X:** reinicia a sequência no próximo e volta à guarda.
- **1/G, 2, 3:** guarda, preparo, impacto, pausados. **T:** troca o braço inspecionado sem consumir a ordem dos ataques. A inspeção começa pelo distante; o primeiro Espaço continua sendo próximo.
- **L:** quatro vezes mais lento, ambos os lados. **Z:** detalhe/corpo inteiro. **O:** juntas/cadeia da candidata.
- **R:** movimento reduzido; mantém guarda e indicação breve de cor, mas a sequência lógica continua alternando.

Experimento principal: X, Espaço duas vezes com intervalo suficiente para ver cada ciclo; depois L e repetir o segundo comando durante o primeiro golpe. Observar continuidade e retorno à mesma guarda, palma distante, cintura apoiada e ausência de mão cortada nas bordas. Testes de cobertura não substituem esse julgamento de gesto/peso.

Exercício pequeno: na árvore **Remota**, localizar o AnimationPlayer do Modelo da candidata e comparar `speed_scale` 0,25 com 0,20, depois restaurar 0,25. Isso muda somente a velocidade de reprodução, não tamanho, juntas ou alcance. Evitar editar a cena aceita 12 para esse exercício.

## Implementação

`vega_alternada.gd/.tscn` deriva da integração 12. Acrescenta somente `corpo_soco_distante` à biblioteca que a classe corporal já torna privada. O novo clipe nasce de uma cópia do próximo, neutraliza os gestos na guarda e acrescenta rotação/posição para o direto distante. Os clipes anteriores permanecem intactos; a referência não recebe o clipe extra.

Mesmo ciclo de **0,56 s**, chaves **0 / 0,10 / 0,20 / 0,36 / 0,56**. Interpolação linear nativa existente; recomeços/trocas usam `play_with_capture` com captura de **0,10 s**, cúbica in-out existente. Não há Tween concorrente de ossos, solver por frame, nova biblioteca externa ou atraso na regra de cartas. Um AnimationPlayer corporal coordena tudo.

Direto distante candidato:

- Ombro local 135° → 128° → 170° → 135°; cotovelo 120° → 120° → 8° → 120°. Punho tem só pequena acomodação de −2° no preparo, sem rotação extra da pintura da mão.
- Pelve prepara (−4,+6) e avança (+10,+2) pixels, com rotações distribuídas entre pelve/abdômen/peito. Cabeça compensa a inclinação, joelhos participam e botas continuam fixas.
- Clavícula/deltoide distantes participam pela ligação existente à pele. O próximo não ataca: compensa a inclinação corporal para manter a direção da mão de guarda. Correção de um grau no preparo foi feita para cumprir essa condição.
- Fontes, UVs, pesos, orientação/reflexão da palma, escala dos segmentos e posições locais de cotovelo/punho não mudam.

`socar_corpo()` alterna usando os campos de ordem existentes, sem misturar inspeção com consumo de sequência. Final de qualquer clipe retorna à guarda. Reiniciar limpa a ordem; ocultar cancela pelo adaptador herdado e golpes ocultos não avançam a sequência. Isso foi testado na prévia, não em cartas/inválidas/defesa do combate real.

O braço distante permanece atrás do corpo como na montagem aceita. A sombra de contato 12 continua seguindo o braço próximo, que está à frente; não passar a sombra distante pela frente do tronco artificialmente.

## Margem e enquadramento

Primeiro impacto mostrou a mão cortada pelo SubViewport antigo, não encurtamento anatômico. Aumentado apenas `Composicao.offset_right`, de 64 para 224: desenho nativo passa de 778×978 para **938×978** com atriz lógica 650×850. Modelo, caixa lógica e comprimentos ficam iguais; não escalar o braço para caber.

Recorte ampliado comporta o novo alcance. TextureRect recebe EXPAND_IGNORE_SIZE **antes** da textura para que o tamanho mínimo do atlas não exceda o painel 520×408; isso também é verificado no teste. Antes dessa correção a imagem nativa estava inteira, mas a ampliação ainda cortava dedos.

## Skill e propósito

Skill **animate**: feedback e continuidade espacial do personagem. Reutilizados timing/captura/interrupção nativos, com alternativa reduzida. Este é movimento de combate; os atalhos são controles de inspeção e não animações decorativas de interface. Regras de frequência/atalho de UI web não anulam a animação do personagem solicitada pelo usuário. Sem spring, curva ou sistema de animação paralelo.

## Verificação executada

- `tests/test_golpes_alternados.gd` passou **headless e OpenGL/fixed-fps 60, zero falhas/exit 0**. Total **114 poses**, 57 por golpe.
- Fontes/UV/geometria/pesos e transformações dos recortes preservados, comprimentos/centros constantes, inserções iguais às corporais e botas fixas. Nenhuma face corporal invertida, inclusive transparente.
- Clipes anteriores conferidos em chaves/tempos/valores. Golpe próximo mantém transformações de corpo/mãos e suas cinco poses-chave renderizam pixels idênticos à referência quando comparados **no mesmo tamanho de canvas**. A comparação inicialmente usava tamanhos distintos de alvo; foi corrigida para controlar essa variável, sem alterar arquivos da referência ou tolerar diferenças de pixels.
- Uma duplicação adicional desnecessária da biblioteca alterava a precisão de 32 tempos de chaves antigas; removida, aproveitando a biblioteca privada já criada. Não foi relaxada a comparação de chaves antigas.
- **2.052 amostras GPU** de cobertura central de ombro/cotovelo/punho dos dois lados ao longo das trajetórias. Não comprova toda borda/sobreposição/perspectiva da pintura.
- Zero interseções opacas amostradas das mãos **nos dois impactos**. Não é colisão 3D ou teste de toda transição interrompida. Avanço do punho distante em relação à guarda: ~151,17 px nativos, com comprimento do membro inalterado; limiar de avanço do teste deriva do antebraço, não de uma distância arbitrária de gameplay.
- Mão distante opaca amostrada permanece dentro da margem em cinco poses, sem cortar dedos. Mão próxima mantém direção de guarda em todo direto distante.
- Seis golpes completos alternam clipe/ordem e retornam à guarda; interrupções próximo→distante e distante→próximo sem salto imediato, inspeção sem consumir ordem, reset, ocultação e reduzido verificados. Handlers Espaço/T/X/1/2/3/L/Z/O/R/A exercitados por script, não teclado físico automatizado.
- Regressões integração 12 e corpo 10 passaram headless/OpenGL, zero falhas/exit 0. Integração mantém seus resultados de pintura/transparência/sombra; corpo conserva 1.254 amostras GPU/sem inversões/botas fixas. Sem suíte inteira ou combate F5.
- Captura GL final exit 0/OK: **23 PNGs** em `docs/evidencias_vega_alternancia_13/`, duas séries de cinco poses nativas/comparativas, dois detalhes de impacto e marcos distantes. Inspecionados preparo/impacto distante nativos, impacto inteiro/ampliado e marcos; mão inteira após as correções de margem/painel.
- Movie Maker gerou `alternancia.avi`: **251 quadros/60 FPS**, ~4,18 s, quatro golpes e uma troca interrompida, exit 0. Sem reprodução em player externo nesta execução; não apresentar a geração do vídeo como julgamento do ritmo.
- Logs finais de teste/captura/filme sem stderr. Importação mantém avisos conhecidos de recursos/RID/fontes/ObjectDB ao encerrar o editor. `git diff --check` passou.

## Limites

Gesto distante e ritmo da alternância ainda aguardam Wallace. Vista palmar fixa não simula rotação longitudinal 3D, dedos/placas não têm novas vistas. Reaproveitada a mesma construção de pele/roupa deformável; não reconstruir pernas/cabelo por inferência. Respiração, dano, tensão por Combo nas peças reconstruídas e integração com ataques válidos do combate real são próximos recortes, não funcionalidades concluídas por esta prova.
