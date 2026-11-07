# Um braço em movimento — prova 05

Usuário autorizou trazer movimento depois de aprovar a montagem estática 04. Esta etapa acrescenta uma variante; não muda `vega_encaixe.tscn`, a guarda estática, a arte ou o personagem F5.

**Retorno posterior do usuário em 22/10/2026:** “tá ótimo, funcionando bem”. Avaliação favorável do movimento desta prova de um braço. Não inclui segundo lado/Combo/F5. Esclarecimento de montagem: ombro humano e deltoide pertencem ao corpo já existente (com acabamento de pele anterior); a nova arte fornece a cap metálica e a prótese inteira. Seu Bone2D `Ombro` é um pivô próprio da prótese presa ao deltoide, não outro ombro humano redesenhado. Nada foi refeito em resposta a essa pergunta.

## Experimentar

Abrir **`preview_movimento.tscn` e executar F6**. A respiração começa automaticamente.

- **Espaço:** soco com o braço próximo reconstruído.
- **D:** reação ao dano, inclusive para interromper um soco em andamento.
- **G:** reset para a guarda aprovada.
- **R:** alternar movimento reduzido; guarda estática e feedback breve de cor, sem golpe articulado.
- **O:** mostrar centros/eixos das juntas.
- **L:** câmera lenta de diagnóstico, ¼ da velocidade (quatro vezes mais lento).

Exercício pequeno: ativar L e O, pressionar Espaço e observar ombro/cotovelo/punho no preparo, extensão e retorno. Depois pressionar D durante outro soco. Desativar L para avaliar o ritmo normal. Câmera lenta é ferramenta de inspeção, não novo tempo de combate. A repetição da tecla mantida pressionada é ignorada; novos pressionamentos podem interromper/recomeçar a ação.

Vídeo gerado: `docs/evidencias_vega_movimento_05/movimento.avi`, 187 quadros a 60 FPS (aproximadamente 3,1 s), contendo soco, interrupção por dano e novo soco. É AVI do Movie Maker nativo, sem dependência instalada. Não foi reproduzido em player externo nesta execução; foram inspecionadas capturas de fases. Sensação de velocidade/fluidez ainda depende do teste do usuário.

## Observado, regra e hipótese

- **Observado:** guarda aprovada é 75°/−120°/0°, abertura interna de 60°, mão (.76,−.76). Os clipes anteriores usavam guarda/preparo com cotovelo chegando a −170°, o que recriaria a sobreposição do antebraço com o bíceps.
- **Regra:** conservar a montagem aprovada como início/retorno, comprimentos e inserção no deltoide. Usar o movimento corporal já existente sem alongar peças, esconder interseção com z ou mudar regras de cartas.
- **Hipótese em avaliação:** redirecionar as trilhas próximas à nova cadeia, recalibrar guarda/preparo e limitar a dobra a −120° permite reutilizar corpo/soco com encaixes contínuos. Testes técnicos não são aprovação artística do movimento.

## Implementação e escolhas de movimento

`vega_movimento.tscn/.gd` estende a montagem estática. Duplica a biblioteca de animações já preparada pela apresentação anterior; só essa cópia tem os destinos próximos alterados de `Braco/...` para `BracoReconstruido/...`. Um `AnimationPlayer` continua sendo o escritor dos ossos do corpo e da prótese. Não há IK, correção de encaixe por frame, deformação nova ou tween paralelo sobre os ossos.

Clipes corporais, joelhos, apoios, outro braço, curvas e tempos mantidos. O soco continua com **0,56 s**, chaves em 0/.10/.20/.36/.56; impacto em .20. No braço próximo, guarda/retorno passam a 75°/−120°/0°. O preparo usa apenas a pequena diferença angular do clipe antigo, sem fechar mais o cotovelo; extensão mantém a chave de impacto original (7° no ombro/cotovelo). Punho mantém sua flexão de preparo anterior. Respiração mantém deltas pequenos relativos à guarda nova. Dano tem 0,26 s e retorna à mesma guarda.

Reutilizadas interpolações existentes dos clipes e a captura cúbica `EASE_IN_OUT` já usada pelo projeto: .10 s ao iniciar/reinterromper soco e .16 s ao voltar à respiração. Sem biblioteca nova ou curva de UI aplicada a uma ação de personagem. A skill **animate** orientou propósito (feedback do ataque/indicação de estado), reaproveitamento dos recursos nativos, interrupção, movimento reduzido e inspeção lenta. Os atalhos são comandos do laboratório de animação de personagem, não animações de abertura/fechamento de interface; não há animação de hover nesta etapa.

`preview_movimento.gd` reaproveita enquadramento/fonte da prancha anterior. Diagnóstico O redesenha apenas as guias; não escreve transformações dos ossos. `socar()` fica deliberadamente no braço próximo, pois o outro ainda usa a montagem anterior. Alternância de ataques fica para a adaptação do segundo lado.

## Verificação realmente executada

Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility/OpenGL, fixed-fps 60.

- `tests/test_movimento_braco_reconstruido.gd` passou headless e OpenGL: zero falhas/exit 0. **133 poses:** 57 do soco, 27 do dano e 49 da respiração. Confere recursos privados, tempos/curvas/chaves de corpo e lado distante, guarda inicial/final, comprimentos, raiz, mão, exclusão do braço antigo e apoios.
- Faixa pintada central de 45–65% do antebraço: zero sobreposições amostradas com bíceps nas 133 poses, usando o mesmo helper da regressão estática. O helper foi tornado estático para reuso, sem mudar sua lógica. Não representa inspeção de todos os pixels ou continuidade 3D.
- GPU: **3.458 leituras** (26 por pose) opacas em pontos de ombro/cotovelo/punho/mão e ponte do punho. Zero falhas de cobertura; não prova toda a borda ou todas as transições capturadas.
- Fluxos verificados: novo soco sem salto imediato para quadro zero, dano interrompendo, retorno automático, reset sem deriva, reduzido sem transformação, retomada da respiração, repetição do braço próximo e isolamento da cena estática. Mapeamento de comandos Espaço/D/R/G/L verificado por chamada do handler, não automação física de teclado.
- Regressões `test_encaixe_braco_corpo.gd`, `test_braco_reconstruido.gd` e `test_acabamento_proximo.tscn` passaram headless, zero falhas/exit 0. Não foi rodada a suíte inteira ou uma integração da candidata com cartas.
- Captura OpenGL exit 0: 18 PNGs em `docs/evidencias_vega_movimento_05/`, com soco em sete instantes, dano e respiração, cada um com prancha e detalhe. Inspecionados guarda, preparo, impacto, retorno .28, dano e respiração; quadro final mantém guarda nos testes. Extensão/dobra legíveis nessas capturas, sem aprovação do usuário ainda.
- Movie Maker gerou o AVI citado, exit 0. Testes/captura/filme finais sem stderr. A importação do editor saiu com 0, mas mantém avisos conhecidos de recursos/RID/fontes/ObjectDB ao encerrar; não foram corrigidos aqui.

## Limites

Só um braço reconstruído em movimento. Sem nova arte, palma distante, expansão de Combo sobre placas integradas, adaptação completa de alternância, cartas, arenas ou migração de F5. Dorsal e placas são pinturas fixas 2D: não simulam rotação longitudinal/foreshortening 3D. A mão mantém o tamanho e a reflexão aprovados, mesmo no impacto; se a perspectiva do soco pedir outra vista, avaliar separadamente em vez de distorcer a guarda.

Próximo recorte seguro: retorno do usuário sobre ritmo, alcance aparente e juntas durante o soco. Manter a guarda aprovada e a variante estática como comparação; não declarar a animação final ou promover ao combate apenas porque testes passaram.
