# Prova 15: tensão das fibras por Combo

23/10/2026 — Godot 4.7.2.stable.official.ed1daf0bf / Compatibility.

## Aprovação posterior

Wallace respondeu “tá funcionando bem, gostei” em 23/10/2026. A tensão visual da prova 15 passa a integrar a referência aprovada. Preservar intensidade, peças, juntas e movimentos aceitos. Descrições abaixo de avaliação pendente registram a entrega anterior a esse retorno. Este registro não inclui novo teste de execução ou integração com cartas reais/F5.

## Recorte e intenção

Usuário autorizou seguir após aprovar respiração/dano da prova 14. Esta candidata adapta somente a tensão visual por Combo aos braços reconstruídos. Não muda arte, anatomia, golpes, regra de dano/custo ou a apresentação principal no F5.

Observado: os braços atuais têm fibras e placas pintadas na mesma superfície; as malhas de Combo anteriores pertencem às peças antigas, agora ocultas. Regra de design: cada ponto ocupa 10 pontos percentuais da tensão adicional; 10 ou mais chega ao máximo visual, sem limitar o contador mecânico. Mãos, juntas, placas e comprimentos não crescem. Hipótese em avaliação: deformar transversalmente o ventre das fibras comunica carga sem desmontar a montagem aprovada.

## Conferir no editor

Abra `preview.tscn` e execute F6. Esquerda é a prova 14 em Combo zero; direita é a candidata. Mesmos gestos nos dois lados, para comparar só a tensão.

- **↑ / ↓:** acrescentar/remover um ponto visual.
- **0:** simular consumo e retornar à tensão zero.
- **6 / 7 / 8:** Combo 5 / 10 / 20. O último conserva o mesmo máximo de 10.
- **Espaço:** golpes alternados. **D:** reação ao dano. **G:** retomar guarda.
- **B:** respiro ligado/desligado nos dois lados. **Z:** ampliar/corpo.
- **L:** articulação corporal lenta; a tensão continua com a transição de 0,2 s.
- **R:** movimento reduzido, tensão aplicada imediatamente sem transição de volume.
- **1/2/3 + T:** poses/lado dos golpes. **4/5:** inspiração/dano pausados.
- **O:** marcos das juntas. **X:** reiniciar sequência e limpar Combo.

Comparação sugerida: Z, B para guarda estática, depois 0/6/7/8. Volte a G/B, aumente um ponto por vez e use Espaço/D enquanto alterna 7 e 0. A tensão não deve alongar membros, aumentar a mão ou cancelar o gesto em curso. Avaliar manualmente se a intensidade é legível sem parecer inflada; testes técnicos não aprovam o efeito artístico.

Exercício opcional: na raiz de `vega_combo.tscn`, mude **Amplitude Biceps** de 0,18 para 0,14 antes de F6, compare em Combo 10 e restaure 0,18. Esse parâmetro é lido na construção da malha; não muda os dez passos ou as regras do jogo.

## Arquivos e mecanismo

- `vega_combo.gd/.tscn`: deriva da prova 14 e coordena quatro superfícies de fibras. `definir_combo_visual()` é uma entrada de apresentação da prévia, ainda não ligada ao Combo real das cartas.
- `malha_fibra.gd`: gera uma malha privada por bíceps/antebraço usando exatamente as texturas e os registros existentes. Mantém as mãos originais. Palette/material da vista distante são preservados.
- `preview.gd/.tscn`: comparação, controles, captura e gravação opcionais.
- `tests/test_combo_fibras.gd`: geometria, estado, renderização e interrupções.

As células de 16 px UV existem somente no trecho central deformável. Contornos dos aros são preservados em tampas não subdivididas. Vértices compartilhados; deslocamento apenas no eixo transversal, com perfil preso nos extremos e máscaras conservadoras para as placas de cada fonte. Margem rígida de 28 px, maior que a diagonal da célula; toda face que cruza uma máscara fica completamente imóvel. Amplitudes máximas 0,18/0,14 reaproveitadas do experimento anterior, não aumentos percentuais do braço inteiro. Os máximos locais calculados incluem vértices transparentes e não medem volume visível.

Em Combo zero, a malha adicional é oculta e o recorte aprovado original reaparece exatamente. Em carga, só a malha deformável correspondente é desenhada; não há duas pinturas empilhadas. Um AnimationPlayer continua dono dos ossos. Um Tween independente escreve apenas os vértices dessas quatro superfícies, usando `tensao_por_combo`, `DURACAO_COMBO` de **0,2 s** e `curva_transformacao` já existentes (cubic-bezier 0.77/0/0.175/1).

Retarget parte da tensão atual, cancela o Tween anterior e não reinicia se o alvo visual for igual, inclusive 10→20. Dano/golpe não consomem Combo, e Combo não cancela os clipes ou muda a ordem dos braços. Reset/ocultação zeram e cancelam a transição. Reduzido preserva o estado final sem animação de volume. Nada bloqueia resolução de cartas.

Skill **animate** usada para indicação de estado, continuidade e interrupção. É resposta de personagem solicitada, não decoração de atalho de UI web. Reutilizados tempos/curva nativos; sem bibliotecas, solver ou outro sistema escrevendo ossos. Não há hover neste recorte.

## Verificação realmente executada

- Teste novo passou **headless e OpenGL/fixed-fps 60**, zero falhas/exit 0. **156 poses**: quatro gestos, 13 instantes cada, Combo 0/5/10.
- Ossos/mãos/comprimentos e deformação do corpo/botas idênticos à prova 14 nas poses comparadas. Fontes, UVs e transformações das peças originais preservados; clipes anteriores sem alterações.
- Onze níveis 0→10 conferidos: deslocamento linear, sem expansão axial, faces invertidas ou colapsadas. **14.520 verificações** de vértices rígidos; triângulos que cruzam as máscaras inteiramente presos. Máscaras são aproximações 2D das fontes, não validação anatômica/3D de toda a pintura.
- **2.808 amostras GPU** nas juntas dos dois braços, sem falhas de cobertura. **52 poses Combo zero idênticas em pixels** à prova 14.
- Comparação da guarda: 6.672 pixels alterados em Combo 5 e 7.148 no máximo; Combo 20 idêntico a 10 em pixels. Contagens incluem diferenças pequenas de filtragem/alfa, não apenas fibras opacas.
- Primeiro teste encontrou um pixel divergente no recorte neutro subdividido junto ao punho (delta máximo 0,4). Deduplicar vértices não bastou; corrigido preservando contornos rígidos inteiros e subdividindo só o centro. Render neutro final: zero pixels com delta >0,02; maior diferença ~0,00784. Combo zero continua usando o original e é exatamente igual, sem essa diferença de triangulação.
- Ganho com valores intermediários, ganho→consumo sem salto imediato, consumo durante dano, troca durante golpe, alvo repetido/10→20, retorno, reduzido, ocultação/reset e handlers da prévia conferidos. Não equivale a teclado físico automatizado ou teste de cartas reais.
- Regressão `test_presenca_combate.gd` passou headless/OpenGL: 148 poses, 2.664 amostras GPU e dez poses-chave dos golpes sem divergência. `test_combo_nativo.tscn` passou headless, zero falhas. Sem suíte inteira.
- Captura GL exit 0/OK: **23 PNGs de comparação** mais **dois diagnósticos nativos**, em `docs/evidencias_vega_combo_15/`. Inspecionados guarda ampliada, impacto distante e reação; captura final de corpo inteiro também conferida após separar textos dos pés.
- Movie Maker gerou `combo.avi`, **277 quadros/60 FPS**, ~4,62 s, exit 0; sem reprodução externa. Geração não valida ritmo ou intensidade artisticamente.
- Logs finais de teste/captura/filme sem stderr. Logs de diagnóstico com falha inicial foram preservados como histórico. Importação exit 0 conserva avisos de recursos/RID/fontes/ObjectDB ao encerrar; não corrigidos aqui. `git diff --check` passou.

## Limites

Não é uma expansão de ombro inteiro, nem mudança de pose por Combo. A sombra de contato continua a aproximação anterior, sem recalcular o volume das fibras. Sem nova arte, expressão, animação de cabelo/pernas ou câmera. A prova 15 tem aprovação visual do usuário; as provas 13/14 permanecem intactas. Cartas reais, consumo por Finalização, fim de turno e migração F5 ainda precisam de integração e verificação próprias.
