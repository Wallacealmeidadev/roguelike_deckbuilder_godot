# Guarda montada — prova estática 17

24/10/2026 — Godot 4.7.2.stable.official.ed1daf0bf, Compatibility. Revisão atual **em avaliação**; proporções/integração anteriores foram rejeitadas pelo usuário. F5 e provas anteriores preservados.

## Tentativa atual: só a postura do próximo

Usuário rejeitou também a recuperação do par pela prova 15. A prancha 04 volta a ser o alvo visual padrão; a 15 continua preservada/acessível por V como comparação funcional. Só o próximo mudou: cotovelo `(31,117)` e punho `(118,20)` relativos à inserção, lidos manualmente como hipótese de guarda. Raiz, ossos/UV existentes e fontes mantidos; o registro uniforme de cada segmento é recalculado para os novos pontos. Não há deformação anisotrópica. A mão acompanha a densidade do antebraço sem se deslocar do punho. Comprimentos de apresentação variam nesta candidata, não no rig aprovado ou nas regras do combate.

Os testes agora cobram esses centros e registros, não igualdade da postura próxima com a 15. Distante continua igual ao registro anterior. Headless/OpenGL passaram (150 CPU/275 GPU), incluindo fonte/mãos/cabeça e ausência de sobreposição dos ventres em 726 pontos pintados centrais. Regressões Combo/camadas headless passaram. Captura GL exit 0/OK: seis PNGs, incluindo `prancha_ampliada.png`, inspecionada; capturas anteriores em `antes_pose_proxima/`. **Corte duro do ombro e diferença do braço distante ainda pendentes.** Esta não é solução visual final nem pose aprovada. Sem geração/edição raster, importação ou movimento novo nesta tentativa. Exercício: F6 → Z → O → R para avaliar só a postura próxima antes de outra alteração. A seção seguinte documenta a tentativa anterior, insuficiente.

## Recuperação da geometria dos braços aprovados

Wallace autorizou comparar com a prova 15 antes de propor refazer a arte. `tests/inspecionar_registro_bracos.gd` mediu a guarda real, Combo zero/tempo zero: raiz próxima com −7°, distante com +2° e escala projetada .92. A montagem 17 havia descartado essas rotações, aplicado .90/.75 independentemente e escondido o bíceps próximo inteiro atrás do tronco.

Agora um registro uniforme comum pelos dois ombros preserva a geometria relativa aceita. Escalas resultantes: **.838723 / .771625**, relação **.92**, não parâmetros independentes a ajustar por tentativa. Há dois recortes contíguos da pintura superior próxima no mesmo osso: só a conexão proximal fica atrás da pele; o restante do bíceps volta à frente. Não existe nova arte, ombro ou articulação. `Geometry2D.intersect_polygons` foi conferido na [documentação oficial 4.7](https://docs.godotengine.org/en/4.7/classes/class_geometry2d.html#class-geometry2d-method-intersect-polygons).

**Comparação atual:** à esquerda, render da prova 15 real em guarda pausada, registrado nos mesmos ombros; à direita, tronco/quadril novos com os braços recuperados. **V** alterna a esquerda para a prancha 04, que continua sendo uma referência de conceito diferente. Não prometer que recuperar o conjunto aceito torna suas pinturas idênticas às da prancha.

Teste guarda passou headless/OpenGL, zero falhas/exit 0/stderr vazio. Compara matrizes e seis juntas com a instância real aceita (<.001 px para pontos), fontes/calibrações, relação de escala e união dos recortes. Os 1.536 pontos UV do superior testam cobertura/ausência de sobreposição interna; a borda comum y220 pertence aos dois contornos, como esperado. Expectativa inicial que rejeitava essa borda foi corrigida sem mudar a arte. Mantidas 150 amostras CPU/275 GPU e checagens anteriores de cabeça/visibilidade. Regressões headless Combo (156 poses) e camadas passaram; sem suíte completa, teste de movimento novo ou importação nesta revisão. Captura GL exit 0/OK: cinco PNGs gerais atualizados, incluindo `prancha.png`; guarda/ampliada/prancha inspecionadas. Capturas anteriores em `antes_registro_bracos/`. Exercício: **V → Z → O → R**, comparando braços na guarda aceita e no conceito sem editar fontes.

## Correção posterior da junção sob o queixo

Usuário rejeitou o aspecto da cabeça após a redução. Render ampliado mostrou: a sombra da fonte sob a mandíbula era exposta pelo recorte curto/encaixe alto e pela transição antiga; também havia fragmento de ombro. Não era uma cabeça recém-gerada. Revisão mantém .85 e os pixels originais, registra `(610,140)` no pescoço, preserva a aba sob a mandíbula e desloca a transição para y150..182. **Ainda em avaliação visual**, sem prometer que o rosto do atlas é idêntico ao da prancha 04 ou que a junção está aprovada para movimento.

Teste atualizado passou headless/OpenGL (zero falhas, 150 CPU/275 GPU), incluindo marco/UV, quatro pontos do rosto iguais com/sem máscara e aba sob a mandíbula opaca na cabeça isolada. Captura nativa de diagnóstico: `tests/capturar_cabeca_guarda.gd`, usar `-- --depois` para registrar a versão atual sem substituir o diagnóstico anterior. Evidências em `cabeca_antes/`, `cabeca_depois/` e `antes_encaixe_pescoco/` dentro da pasta de evidências 17. Quatro capturas gerais atualizadas; guarda/ampliada/detalhe inspecionados. Sem raster novo, importação, animação ou suíte completa nesta revisão. Exercício: Z e C para observar a ligação com o corpo; R restaura. O parágrafo de redução abaixo descreve a etapa anterior.

**Retorno posterior:** usuário apontou cabeça grande com screenshot. Revisão localizada: escala uniforme **.85**, 15% menor linearmente, mesmo marco do pescoço; não foram alterados corpo, braços, recorte ou fontes. Nova proporção em avaliação. Teste da guarda passou novamente headless/OpenGL (150 CPU/275 GPU), conferindo escala e âncora. Quatro capturas atualizadas; ampliada inspecionada, capturas em escala 1 preservadas na subpasta `escala_100/` das evidências. Sem repetir suíte completa, geração ou animação. Exercício: Z amplia, C oculta/mostra cabeça, R restaura.

## Um objetivo

**Observado:** tronco 02/quadril 01 foram aprovados, mas a bancada 16 não continha cabeça/próteses. Os dois braços reconstruídos já possuem suas próprias juntas e calibrações. **Regra:** conservar essas fontes, a cobertura da regata e o único deltoide humano; não usar uma cúpula mecânica como segundo ombro. **Hipótese:** registrar os membros na pintura nova e resolver a oclusão da guarda antes de animar permite avaliar os encaixes separadamente do movimento.

Esta prova reúne cabeça, dois braços, tronco e quadril/roupa. Não é a personagem inteira reconstruída: termina nas coxas da camada aceita. Não acrescenta pernas, ossos corporais, poses corretivas ou clipes.

## Abrir

Abra `preview.tscn` e pressione **F6**. À esquerda, prancha 04; à direita, montagem nova. V alterna a referência para a guarda real pausada da prova 15.

- **V:** alternar referência real aprovada / prancha de conceito.
- **O:** marcos corporais e juntas dos braços.
- **Z:** ampliar, mantendo a mesma comparação.
- **B:** ocultar/mostrar os dois braços.
- **C / T / P:** ocultar/mostrar cabeça, tronco ou quadril.
- **R:** restaurar visibilidade, marcos e enquadramento.

Observe pescoço, inserções sob os deltoides, dobra dos cotovelos e raiz das mãos. **T** deixa explícito o que estava escondido sob a pele; ausência de vão em pontos amostrados não certifica todo contorno, perspectiva ou anatomia. Exercício pequeno: O → T → T → R, sem editar assets.

## Arquivos e encaixes

`vega_guarda.gd/.tscn` deriva de `CamadasGuardaV1`, sem modificar a bancada aprovada. Reutiliza integralmente `tronco_02.png` e `quadril_01.png` e as mesmas transformações de registro. Não há cópia da pele antiga por baixo do tronco.

- Cabeça/cabelo: `combate_v2/base_e_punhos_01.png`, somente região UV delimitada por Polygon2D. O corpo/ombros/punhos extras do atlas não são desenhados. Marco manual `(610,140)` registrado no pescoço do tronco; escala uniforme .85 (antes 1, rejeitada pelo usuário). `pescoco.gdshader` faz uma transição curta de alfa na aba inferior do pescoço (fonte y150..182), sem regravar pixels. É uma solução de composição desta guarda, não pintura nova ou compatibilidade comprovada em rotação.
- Próximo: `BracoRegistradoV1`, mesma fonte/ossos e mão `(.76,−.76)`. Inserção `(180,400)` na fonte do tronco; cotovelo/punho definidos pelos vetores da tentativa atual. Registros dos três segmentos recalculados uniformemente; cap/bíceps continuam contíguos na UV y220 e no mesmo osso. O registro comum permanece apenas como base da referência nativa e do distante, não como imposição da pose próxima.
- Distante: `BracoDistanteRegistradoV1`, vista palmar/paleta aceitas, guarda local 135°/120°/0°, palma anterior ×1.20. Raiz aceita `(412.3492,253.8059)`, giro +2° e projeção `(-.92,.92)` antes do registro comum; inserção `(710,450)` na fonte do tronco. Marcos aceitos foram medidos em runtime e são conferidos contra a prova 15 no teste.
- Profundidade: conexão proximal próxima atrás do tronco, bíceps/antebraço/mão à frente; distante atrás; cabeça à frente da aba superior. Raiz z=10 mantém partes acima do fundo. Não existe nova peça pintada de ombro, placa ou aro independente.

`preview.gd` reaproveita a bancada com ocultação/ampliação; não muda menus/HUD. A referência 15 mantém seu AnimationPlayer **pausado** e render próprio; sua textura é registrada por `registro_bracos * modelo.transform.affine_inverse()` para não depender da margem do viewport antigo. A candidata não cria animador/Tween nem escritor por quadro; usa os dois Skeleton2D próprios em pose estática. Para animar depois será necessário vincular corpo/membros corretamente; não é rig de combate pronto.

## Verificação inicial (histórico anterior à recuperação dos braços)

- Godot 4.7.2 confirmada. `tests/test_guarda_montada.gd` passou headless e OpenGL, zero falhas/exit 0; logs finais sem stderr.
- Cinco hashes de fontes originais preservados: cabeça/base, braço próximo, braço distante, tronco 02 e quadril 01. Mesmas texturas e registro da bancada 16; mão no centro do punho, comprimentos nativos, escalas uniformes, projeção, ordem de camadas e atalhos conferidos. Doze quadros sem alteração da guarda.
- **150 amostras CPU** de juntas. GPU: **150 amostras das próteses isoladas**, sem tronco/cabeça/outro braço poderem mascarar vãos; mais **125 amostras** nas três posições centrais do pescoço e duas inserções dos ombros. Total GPU 275. Nenhuma abertura nessas amostras; não é varredura de todas as bordas.
- Duas amostras adicionais de RGB/visibilidade do rosto e punho distante sobre fundo opaco. O teste inicial exigia equivocadamente alfa composto idêntico: o fundo eleva alfa .9961/.9922 a 1, com RGB igual. Corrigida a expectativa para RGB e alfa opaco, sem alterar apresentação para satisfazer o teste.
- A primeira captura revelou partes atrás do fundo e ombro antigo vazando do recorte da cabeça. Corrigidos z da raiz, região UV e transição do pescoço; verificações específicas incluídas. Captura final GL exit 0/OK: quatro PNGs em `docs/evidencias_vega_guarda_montada_17/` — guarda, juntas, ampliada e sem_tronco. Guarda/juntas/ampliada inspecionadas; ainda depende do usuário avaliar a montagem.
- Regressões headless: `test_camadas_guarda.gd` passou (3.164 pontos de sobreposição); `test_combo_fibras.gd` passou fixed-fps 60 (156 poses, 14.520 verificações de vértices rígidos). Não executada a suíte inteira nem combate real.
- Importação exit 0, com avisos anteriores de encerramento (33 ObjectDB/13 recursos ainda em uso), não resolvidos nesta prova. `git diff --check` conferido. Sem geração/edição raster, filme ou migração F5.

Próximo passo depende do retorno sobre esta guarda. Só depois adaptar a participação corporal/respiração; uma pose estática não valida a união do pescoço, ombros ou cintura durante um golpe.
