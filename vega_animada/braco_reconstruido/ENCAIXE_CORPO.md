# Encaixe de um braço no corpo — guarda estática aprovada, dobra 04

**Aprovação do usuário em 22/10/2026:** “muito melhor, agora sim está aprovado”. Referência estática: ombro 75°, cotovelo −120°, punho 0°, mão (.76,−.76) e encaixe no deltoide. Preservar a montagem e as capturas 04 como base visual. A aprovação não inclui animação da cadeia nova, segundo lado, Combo ou migração ao F5. Os termos “candidata” nas etapas abaixo descrevem o histórico de avaliação; nenhuma nova implementação foi feita no registro desta aprovação.

Etapa posterior de movimento autorizada e implementada em **outra** cena: `preview_movimento.tscn`. Esta prova estática permanece preservada. Controles, testes e limites em [MOVIMENTO.md](MOVIMENTO.md); aprovação estática não é aprovação antecipada da animação.

Wallace autorizou experimentar o braço reconstruído no corpo após considerar a arte ótima e a guarda isolada estranha. Esta etapa usa exatamente `braco_montado_01.png`, sem gerar ou retocar o PNG. Após relato de mão grande e virada para o lado contrário, somente sua malha recebe redução/reflexão local na variante corporal. Não substitui F5 ou as prévias anteriores.

## Abrir e comparar

1. Abrir `preview_corpo.tscn` na Godot e pressionar **F6**.
2. **A** alterna entre a montagem anterior e a candidata, no mesmo corpo/enquadramento. A comparação anterior mantém a própria pose aceita, não recebe os novos ângulos.
3. **O** mostra os centros/eixos do braço reconstruído. Conferir a inserção sob o deltoide, a dobra do cotovelo e o punho junto ao rosto.

Exercício pequeno: abrir `vega_encaixe.tscn`, selecionar a raiz e mudar `fator_mao` de .76 para .80 no Inspector. Executar F6 e observar o tamanho em relação ao rosto e o centro do punho com O. Restaurar .76 ao terminar. A calibração fica em torno do centro registrado: não deslocar a mão para compensar a postura.

## Observação, regra e hipótese

- **Observado:** a guarda da prova anterior reaproveitava 105°/−160° sem corpo. O braço reconstruído foi bem recebido pelo usuário, a postura não. O corpo já possui deltoide e inserção de braço no rig nativo.
- **Regra:** conservar arte, comprimentos e base funcional; nenhum ajuste de alcance, dano ou Combo para corrigir apresentação. Um único braço nesta etapa, sem inferir que a vista dorsal também serve para a palma distante.
- **Hipótese testada visualmente:** prender a nova cadeia ao deltoide existente e abrir a guarda permite avaliar mão/rosto/peito e folga da dobra sem refazer o desenho. O resultado estático continua candidato, não anatomia ou animação final aprovada.

## Arquivos e responsabilidade

`vega_encaixe.tscn/.gd` deriva da apresentação de acabamento anterior. Depois de sua inicialização, cria uma instância de `BracoRegistradoV1` como filha do deltoide próximo, usando exatamente a transformação da raiz do braço anterior. Esse braço anterior inteiro fica invisível, incluindo seus aros, malhas e placas; **A** alterna a visibilidade mutuamente exclusiva, sem empilhar montagens.

A apresentação corporal é amostrada na primeira chave de `respirar` e pausada. Isso mantém o tronco, clavículas, pele, pernas e guarda distante anteriores. Apenas os ossos da prótese nova recebem a candidata local **ombro 75°, cotovelo −120°, punho 0°**. A etapa 03 usava 103°/−153° e foi corrigida após esclarecimento da sobreposição entre segmentos. A mudança está confinada à nova cena. Não altera o método `definir_pose` da prova anterior nem os clipes compartilhados.

Os comprimentos dos ossos permanecem 128.06041074 / 133.9084538 / 100.065; registros e três recortes são os mesmos da prova isolada. O ombro e sua pintura usam o acabamento já existente; não há deslocamento da raiz ou remendo novo na pele.

## Correção localizada da mão — 02

Relato do usuário: mão parece grande demais e virada para o lado contrário. Observado: o registro original calibra o desenho da mão para 100.065 unidades, produzindo escala raster aproximadamente 34% maior que a do antebraço. O polegar fica no lado contestado. Hipótese de orientação adotada: trocar o lado do polegar mantendo o dorso visível, não substituir a vista pela palma.

`vega_encaixe.gd` aplica à malha da mão `scale = Vector2(.76, -.76)`: redução uniforme de 24% e reflexão transversal em torno do eixo longitudinal local +X. A raiz continua no mesmo centro do punho e os dedos continuam para frente. Não reflete o braço inteiro nem gira a mão 180° para dentro do antebraço. Escala efetiva da fonte fica a menos de 2% da escala do antebraço. A extensão visível da mão passa a aproximadamente 76 unidades; o osso nominal continua com o comprimento anterior, sem qualquer regra de alcance nesta prova.

`fator_mao` e `inverter_lado_mao` permitem ajustar essa hipótese na variante. Geometria, UV e textura-fonte não mudam; ombro/cotovelo/guarda permanecem anteriores. Guia O agora termina na ponta da malha visível, não no fim nominal do osso. Na prova isolada original, a malha continua com transformação identidade e a guia mantém o mesmo resultado anterior.

Uma reflexão 2D não representa giro 3D nem converte dorso em palma. Se a crítica de orientação se referir à superfície visível, e não ao lado do polegar, isso ainda exigirá avaliar uma vista própria; não considerar essa interpretação aprovada por inferência.

`preview_corpo.tscn/.gd` é só uma prancha diagnóstica com teclado e captura; não é um novo menu/HUD nem integra cartas. Arquivos ativos e variantes anteriores preservados. O nome da classe não indica que a candidata está pronta para ser usada como apresentação de combate.

## Folga em relação ao peito — 03, superada após esclarecimento

Usuário relatou melhora da mão, mas braço ainda muito colado ao corpo. Observado na captura 02: antebraço e mão cobrem parte da lateral do peito. Regra: não deslocar a raiz para fora da pele ou alterar proporções para criar espaço. Hipótese testada: girar o ombro +8° e compensar no cotovelo −8°, mantendo a direção do antebraço/punho.

Candidata 103°/−153° em vez de 95°/−145°. Isso leva cotovelo e mão aproximadamente 18 unidades do rig para fora, com diferença vertical pequena; a soma dos ângulos continua −50°. Nenhum deslocamento independente de peça ou mudança na pele/raiz. A folga buscada é entre prótese e peito: a dobra do cotovelo fica 8° mais fechada, não mais aberta. Conferir também a sobreposição entre os segmentos, que ainda precisa de avaliação artística.

Usuário esclareceu em seguida que o problema era antebraço sobre o bíceps, não proximidade do peito. Essa compensação fechava a dobra e agravava exatamente a sobreposição reclamada. Não usar o exercício de fechar mais o cotovelo como correção. Os testes anteriores de centros/cobertura opaca não detectavam interseção da pintura de duas peças.

## Separação entre bíceps e antebraço — 04

Observado na imagem enviada pelo usuário: os ventres se sobrepõem. Com rotação de cotovelo −153°, a abertura interna era apenas 27°. Regra: preservar peças, comprimentos, raiz e mão, mantendo apenas a sobreposição necessária ao encaixe do cotovelo. Hipótese: abrir a dobra e reposicionar a guarda permite distinguir as duas superfícies sem recortar ou afinar o braço.

Candidata 75°/−120°/0°: abertura interna de 60°. A mão fica mais à frente do rosto; sua inclinação acompanha a nova postura, mantendo escala/reflexão e encaixe anteriores. Não se exige conservar a direção do antebraço da etapa 03, pois essa restrição mantinha a dobra excessiva. Não há troca de camadas para esconder a interseção, deslocamento de pivôs ou edição de arte.

Exercício pequeno: no Inspector de `vega_encaixe.tscn`, mudar somente `angulo_cotovelo` de −120 para −125. Executar F6/O para ver a dobra fechar 5° sem mover a raiz. Restaurar −120. A linha entre os ossos e a silhueta pintada precisam ser avaliadas juntas.

## Verificação executada — Godot 4.7.2

- `tests/test_encaixe_braco_corpo.gd` passou headless e Compatibility/OpenGL, fixed-fps 60, zero falhas/exit 0. Mantém verificações de pai/âncora, exclusão do braço antigo, três segmentos, comprimentos, mão, geometria/UV da pele, transformações do corpo/distante, comparação A e estabilidade em 12 quadros. Substituídas as exigências semânticas da etapa 03 por abertura interna de pelo menos 59° e separação entre centros dos ventres maior que 60 unidades.
- Regressão de sobreposição: amostra CPU em UV da faixa de 45–65% do antebraço, passo 6 pixels, usa alfa da fonte, transformações reais e máscara do segmento superior. **723 pontos pintados; pose anterior −153° sobrepõe 378, nova −120° sobrepõe zero**. Exclui a junta, onde sobreposição é necessária. É uma faixa amostrada em uma pose, não prova de todo contorno/movimento ou anatomia.
- OpenGL: 26 pontos opacos de mão/juntas/transição do ombro e ponte curta entre colar/mão passaram. Amostragem não cobre toda a costura ou outros ângulos; alfa não prova perspectiva correta.
- Regressões `test_braco_reconstruido.gd` e `test_acabamento_proximo.tscn` passaram headless/fixed-fps 60, zero falhas/exit 0.
- Captura OpenGL exit 0, quatro PNGs em `docs/evidencias_vega_dobra_cotovelo_04/`: guarda, anterior, marcos e detalhe do render nativo. Guarda/detalhe inspecionados: bíceps e antebraço distinguíveis, com espaço entre os ventres e ligação mantida no cotovelo. Capturas 01/02/03 preservadas, sem sobrescrever a avaliação anterior.
- Testes e capturas finais sem stderr. Importação do editor exit 0 mantém avisos conhecidos de recursos/RID/fontes/ObjectDB ao encerrar; não foi corrigido esse histórico nesta etapa.

Na guarda examinada, a cap da prótese encontra a borda inferior do deltoide sem vão transparente visível no detalhe, o punho fica junto ao rosto e a dobra está mais aberta. Essa é inspeção visual limitada. A mão nova e a distante antiga ainda diferem em tamanho/material, pois apenas um lado foi reconstruído. A arte fixa não simula giro longitudinal 3D.

Ainda não testado/implementado nesta candidata: nova cadeia animada, segundo braço/palma, Combo nas placas integradas, cartas, dano/interrupções, transições entre guardas/impacto e migração de F5. Não chamar métodos herdados de combate nesta prova para inferir que esses fluxos já estão adaptados. Próximo passo, após avaliação do encaixe: adaptar os clipes na variante isolada e examinar as juntas ao longo do movimento.
