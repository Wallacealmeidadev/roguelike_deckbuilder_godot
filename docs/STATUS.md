# Estado do projeto

## Organização do projeto e commits — 07/11/2026

Pedido do usuário: separar o que o jogo usa do que é protótipo e commitar o que já funciona. Rastreamento estático a partir de `jogo.tscn` (caminhos `res://`, uids, `class_name` e `load()` dinâmicos de `hud_neon/`) encontrou 277 arquivos carregados pelo jogo. Da Vega, o combate usa só `vega_animada/rig_nativo_v2/` (mais `braco_v2/braco_prova.gd`, `braco_v2/camadas.png` e `combate_v2/base_e_punhos_01.png`). A guarda montada com braços HQ aprovada em 24–25/10 **não está no jogo**; ficou em `prototipos/vega_2d/corpo_articulado/`.

Feito: trabalho pendente desde 19/10 commitado em blocos (lógica da run das Docas, interface/HUD neon, Vega animada, base 3D, docs). Depois, 403 arquivos não usados pelo jogo movidos com `git mv` para `prototipos/` (`vega_2d/`, `hud_antiga/`, `assets_antigos/`), com os `res://` corrigidos em 177 arquivos; testes que só exercitam protótipos foram para `prototipos/vega_2d/tests/`. Reanálise após a mudança: o conjunto de arquivos carregados pelo jogo continua idêntico (277, mesmos caminhos) e não há `res://` apontando para arquivo inexistente fora de `docs/`. Evidências (`docs/evidencias*/`, zip, `.kra~`, logs) ficam fora do Git via `.gitignore`, sem apagar nada. Checkpoint interno do Codex (`refs/codex/...`) removido e `git gc` executado: `.git` caiu de 2,45 GB para 283 MB; `git fsck --connectivity-only` OK.

Não verificado: a suíte na Godot não foi executada nesta sessão (o shell disponível é Linux, sem a Godot do Windows). Criado `tests/rodar_testes.ps1` para rodar `tests/test_*.tscn` headless. Ao abrir o editor, a Godot vai reimportar as imagens movidas. Push da `dev` não foi feito daqui (rede bloqueada); fazer pelo Windows.

Próximo passo: rodar `tests/rodar_testes.ps1`, abrir `jogo.tscn` e jogar um combate para confirmar; depois fazer push da `dev`.

## Vega: primeiro figurino 3D — 02/11/2026

Relato do usuário: revisão 03 parece ótima. Após discutir alcance da produção 3D, autorizou começar pelo figurino em formas simples. Criado `arte_3d/vega_figurino_04/vega_figurino_04.blend`, com regata carvão, calça solta grafite, botas e camisa vinho amarrada, seguindo a referência 04 de roupa. São 31 peças (incluindo cadarços), 5.297 vértices de roupa antes dos modificadores, materiais básicos e vínculo ao mesmo Rigify. A aparência é uma primeira passagem de volumes; rosto/cabelo/próteses e acabamento HQ continuam pendentes.

Inspeção nativa de frente, costas, três quartos e flexão identificou interferências de roupa/anatomia e corte das alças; a revisão corrigiu folga da calça, sobreposição do painel traseiro e continuidade das alças. A pele sob a calça é ocultada por máscara reversível nesta cópia; anatomia não foi apagada. Comparação lado a lado e vistas renderizadas em Blender, sem geração de imagem. Arquivo ~2,51 MiB, base 03 preservada por SHA256 `c2e4004b6baab7296629bdf37b1a1dc84bc2857da70d2bb80925b6487eaac0d9`.

Blender 5.2.3 LTS. Geração e reabertura final exit 0, stderr vazio. Comparação de coordenadas de todas as shape keys, valores e topologia confirma corpo idêntico ao 03; 930 ossos e ação original mantidos. Pesos de todas as peças normalizados; superfícies avaliadas finitas nos quadros 1/30. Exercício de cotovelo desloca 1.956 vértices do corpo >1 mm. Teste adicional em memória com pequeno deslocamento do controle de pé move 5.487 vértices avaliados da calça e 2.720 da bota; captura `teste_perna.png` inspecionada. A pose de perna não foi salva no arquivo. Não testadas guarda, socos, poses extremas ou física de tecido. Primeira tentativa encontrou configuração de viewport incompatível, corrigida antes da entrega. Resultado visual aguarda avaliação; F5 e fontes anteriores preservados, nenhuma limpeza de arquivos do projeto. Guia inclui exercício de alternar visibilidade de uma peça.

## Vega: cintura/abdômen 03 — 02/11/2026

Usuário pediu cintura mais fina e mais abdômen. Interpretação comunicada: firmeza/definição muscular, sem aumentar barriga. Revisão `arte_3d/vega_base_03/vega_cintura_abdomen_03.blend` deriva da 02 preservada por hash, com dois alvos MPFB (.40 redução de cintura, .85 tônus abdominal). Demais alvos 02 conservados; rig reajustado com ação/slot/FK restaurados. Inspeção de comparação, flexão e detalhe: cintura mais estreita, definição suave; não descrita como escultura abdominal final. Rosto genérico, próteses/roupas/cabelo continuam pendentes.

Blender 5.2.3 LTS confirmado. Geração/reabertura exit 0/stderr vazio. Topologia 19.158/ossos 930/grupos e ação preservados; 609 vértices alterados >1 mm, cabeça com desvio numérico máximo ~0,48 micrômetro. Largura amostrada na cintura .262635→.255915 m (~2,6%, não circunferência); altura preservada. Flexão mantém 1.956 vértices >1 mm; reabertura confere alvos novos, costas .35 e rotação 0→65°. Sem teste de poses extremas ou integração Godot. Guia inclui exercício da chave abdominal 0/.85. Resultado aguarda retorno visual; nenhum arquivo anterior excluído.

## Vega: revisão corporal 02 no Blender — 02/11/2026

Relato do usuário: conferiu arquivo 01, parece bom e autorizou continuar. Próximo recorte executado: proporções corporais moderadas em `arte_3d/vega_base_02/vega_proporcoes_02.blend`, preservando fonte 01 por hash. Oito alvos MPFB locais para tronco/costas/deltoides/coxas/panturrilhas, sem geração de imagem ou rosto novo. Pesos são parâmetros candidatos, não medidas exatas da referência. Metarig reajustado pelo MPFB/Rigify; ação/slot e modo FK restaurados após regeneração para conservar exercício. Comparação frontal antes/depois e flexão renderizadas e inspecionadas. Rosto genérico, roupa/cabelo/próteses/guarda continuam pendentes; identidade A preservada como alvo.

Blender 5.2.3 LTS confirmado. Geração final e reabertura exit 0/stderr vazio. Topologia 19.158 vértices, 930 ossos, grupos e ação preservados; 5.658 vértices avaliados alterados >1 mm. Altura mantida, desvio máximo na região superior da cabeça ~1,1 micrômetro. Flexão: 1.956 vértices >1 mm, coordenadas finitas; reabertura confirma modificador, chave de costas e rotação 0→65°. Primeiro ensaio detectou ação desacoplada pela regeneração e foi corrigido antes de salvar. Sem certificação de poses extremas ou integração Godot. Guia `COMECE_AQUI.md` inclui Espaço/quadros 1 e 30 e exercício opcional da chave de costas. Proporções ainda aguardam retorno visual. Nenhum arquivo anterior apagado, F5 intacto.

## Vega: primeiro arquivo Blender de treino — 25/10/2026

Usuário autorizou base humana + Rigify e informou não conhecer Blender. Instalação localizada na Steam: Blender 5.2.3 LTS, Rigify incluído e MPFB 2.0.18 já instalado. Criado `arte_3d/vega_base_01/vega_base_treino_01.blend` em processo separado factory-startup, sem instalar complementos, salvar preferências ou tocar sessão do usuário. `.gdignore` isola da importação Godot. Base feminina adulta cinza, sem roupa/cabelo, rosto genérico explícito como manequim técnico; A continua identidade. Rig completo, metarig oculto preservado, ciclo de flexão de um cotovelo (1–60 quadros). Não é guarda/soco nem Vega final; próteses/roupas/rosto A ainda pendentes.

Script reprodutível e guia curto em `arte_3d/vega_base_01/`. APIs conferidas no código instalado. Após corrigir ativação dos addons em memória e seleção de ossos Blender 5.2, geração final exit 0/stderr vazio; 930 ossos totais, armature ligada à malha e 1.956 vértices avaliados deslocados >1 mm entre quadros 1/30. Render de flexão inspecionado. Reabertura independente exit 0/stderr vazio confirma rotação 0→65° com script de UI Rigify bloqueado; reprodução básica não depende de liberar scripts globalmente. Não testados individualmente todos os controles/poses, nem integração Godot. Primeiro exercício: abrir arquivo, Espaço para reproduzir/parar e comparar quadros 1/30. Nada excluído, F5 preservado.

## Vega: identidade A confirmada; consulta sobre base 3D — 25/10/2026

Usuário escolheu A (referência 03) e perguntou se podemos usar modelo feminino para personalizar cabelo/corpo e rig. Consulta às fontes oficiais MakeHuman e Blender confirma base exportável/licença dos assets centrais CC0 e ferramenta de auto-rig Rigify. Recomendação em discussão: prova 3D pequena de identidade e movimento, com acabamento HQ; não confundir modelo-base com Vega pronta. Sem downloads, instalação, código visual ou testes novos. Rig/montagem atuais e arquivos preservados; limpeza posterior não iniciada.

## Vega: comparação de identidade pronta — 25/10/2026

Levantadas fontes anteriores; MDs das referências 02/03 confirmam expressão aprovada na 02 e cabelo longo aprovado na 03; 04 alterava figurino. Comparação A=03, B=04, C=fonte atual da cabeça em `docs/arte_vega/comparacao_identidade_2026_10_25.png`, renderizada por `tests/comparar_identidade_vega.gd`. Não usa geração/repintura. Godot 4.7.2 OpenGL exit 0/OK/stderr vazio; captura inspecionada. Ângulos/resolução distintos explicitados. A recomendada como identidade a recuperar, aguardando escolha atual do usuário; nenhuma fonte ou montagem alterada e nenhum teste de gameplay novo.

Inventário inicial read-only: docs 1866,9 MiB, .git 2481,1 MiB, .godot 868,9 MiB, vega_animada 19,7 MiB. Detalhes/limites no MD da comparação. Tamanho lógico não equivale a espaço recuperável; nenhuma exclusão. Limpeza segue posterior às etapas acordadas. Exercício visual: comparar boca, nariz e silhueta das mechas A/B/C separadamente das diferenças de pose.

## Vega: montagem HQ bem recebida; identidade do rosto/cabelo em revisão — 25/10/2026

Usuário relatou “ficou ótimo” após aplicação HQ, mas apontou perda de identidade do rosto e cabelo estranho, percebido como aproximação indesejada de Studio Ghibli após reprocessagens. Aprovação dos braços não aprova rosto/cabelo atuais. Conferência read-only: `guarda_montada/vega_guarda.gd` ainda usa `combate_v2/base_e_punhos_01.png` para cabeça, escala .85; SHA256 C7A326BB5D511024B428D18DFCE285ADD8D7B886030B1C5FE77F2D8F30733606 coincide com registro anterior. Material HQ aplica-se somente aos braços. Portanto a última integração não substituiu a cabeça; isso não demonstra que a fonte antiga represente a identidade desejada. Estudos sobre imagens inteiras sofreram ressíntese, não devem redefinir rosto/cabelo.

Próximo recorte recomendado: comparar versões originais de rosto/cabelo já aprovadas e fixar fonte canônica antes de retomar movimento. Depois preparar peças HQ no rig, validar guarda/respiração/golpes/juntas, e só então integrar F5. Nesta resposta apenas inspeção de código/hash e registro do retorno, sem geração, alteração visual ou testes novos. Exercício de avaliação: comparar expressão e silhueta do cabelo com a versão anterior preferida, separadamente do acabamento dos braços.

## Vega: acabamento HQ aplicado na prévia Godot — 24/10/2026

Usuário aprovou ambos os braços do estudo 03 e autorizou seguir. Skill imagegen/ferramenta integrada gerou `bracos_prancha/bracos_hq_01.png` no canvas 1774×887 da prancha original, usando estudo 03 como referência de acabamento. Prompt/hash/proveniência e limites em `bracos_prancha/pintura_hq_01.md`. `vega_fiel.gd` aplica material `pintura_hq.gdshader` apenas nos braços e conexão próxima. H alterna material, R restaura HQ, mesma F6. UV, proporções, centros e registros preservados na troca; corpo/cabeça/fontes anteriores e F5 intactos.

Observado na primeira captura: bordas ressintetizadas traziam fundo/pele. Material preserva faixa original de 3 pixels e transição até 7 pixels, consumindo pintura HQ no interior. Conserva alguns detalhes originais de borda; não é reprodução integral do estudo. Captura isolada também revelou resíduo branco antigo sob bíceps distante; oito vértices da máscara recolhidos 3–7 pixels para excluir fundo, sem mover juntas. Captura final ampliada/isolados inspecionada, acabamento mais chapado e faixa branca removida nesta vista. Resultado aplicado aguarda avaliação visual.

Godot 4.7.2 confirmada. Importação exit 0 com avisos conhecidos 33 ObjectDB/13 recursos, não considerada limpa. Captura GL exit 0/OK/stderr vazio; nove PNGs em `docs/evidencias_vega_bracos_prancha_18/hq/`, anteriores preservados fora dessa pasta. Teste GL da prova: zero falhas/stderr vazio; 20.529 pixels internos alterados por H, zero diferenças de alfa/exterior, UV/transformações preservadas, reset HQ e pontos de limpeza conferidos. Sem teste animado, benchmark ou suíte completa. Exercício: abrir mesma preview.tscn com F6 → Z → H → H, comparando acabamento na mesma pose.

## Vega: próximo HQ aprovado e estudo do distante — 24/10/2026

Relato do usuário sobre estudo 02: “ótimo, agora sim está coerente com o desenho”; aprovação do acabamento próximo. Autorizou continuar no distante. Skill imagegen/ferramenta integrada produziu `docs/arte_vega/vega_bracos_hq_estudo_03.png`, com prompt/proveniência no MD homônimo. Inspeção visual: fibras distantes mais chapadas, dedos menos brilhantes, mantendo visualmente orientação da palma e pose geral. Reflexos ainda presentes nas placas/palma. Estudo 03 em avaliação, sem garantia de preservação pixel a pixel de contornos/encaixes. É pintura gerada, não captura nova Godot; textos de interface pertencem à imagem. Nenhuma textura de runtime, rig, código ou F5 alterado; sem testes de execução novos. Exercício de inspeção: comparar as massas escuras dos dois braços com as sombras da regata em tamanho normal. Preparação das texturas para montagem permanece pendente.

## Vega: estudo HQ 02, mão e placas — 24/10/2026

Relato do usuário: estudo 01 muito melhor, menos aparência de objeto estranho. Autorizou levar acabamento à mão e placas próximas. Skill imagegen/ferramenta integrada produziu `docs/arte_vega/vega_braco_proximo_hq_estudo_02.png`; prompt/proveniência/limitações no MD homônimo. Inspeção visual: dedos próximos mais escuros, menos pontos de brilho, faces das placas simplificadas e sombra do cotovelo chapada. Distante continua com acabamento anterior para comparação; fidelidade externa não certificada pixel a pixel. Continua pintura gerada de estudo, não captura Godot ou arte integrada. Nenhum código, fonte de runtime, rig ou F5 alterado; nenhum teste de execução novo. Exercício de avaliação: comparar dedos próximos e distantes em tamanho normal, além do zoom, para julgar a leitura do metal. Revisão 02 ainda aguarda retorno visual.

## Vega: estudo de acabamento HQ no próximo — 24/10/2026

Relato: proporções melhoraram, mas acabamento dos braços parece 3D e diverge da personagem. Usuário autorizou teste de linguagem HQ no próximo. Skill imagegen/ferramenta integrada gerou estudo sobre screenshot: `docs/arte_vega/vega_braco_proximo_hq_estudo_01.png`, prompt e limitações no MD homônimo. Primeira tentativa descartada por brilho/ombro; segunda inspecionada, com fibras chapadas e escuras, placas/mão ainda mais brilhantes. É imagem de estudo, não captura de execução nova: textos da interface também foram gerados. Contornos/enquadramento sofreram ressíntese; não é prova de preservação anatômica. Nenhuma textura de runtime ou código alterado, nenhum teste Godot novo. Avaliação pendente. Comparar integração das sombras do braço com a regata, mantendo a geometria já existente como referência de implementação.

## Vega: antebraço e mão próximos — 24/10/2026

Relato do usuário: antebraço ainda fino e mão menor que a distante. Observado no código: ganho anterior limitado ao ventre (.20) e mão explicitamente fixa. Revisão na mesma prévia 18: antebraço com ganho transversal máximo .45 numa faixa maior, suavizado perto das juntas; mão +14% a partir do punho, com transição de 15–32 pixels da fonte. Bíceps, aro, centros das juntas, distante e fontes preservados. Hipótese de proporção em avaliação, sem nova pintura, animação ou alteração F5.

Godot 4.7.2 confirmada. Teste OpenGL da prova passou com zero falhas/exit 0/stderr vazio; verifica crescimento da mão, centros fixos, máscara distante e preservação do tronco fora da edição. A expectativa anterior de mão imutável foi substituída para refletir o novo pedido. Captura OpenGL exit 0/OK/stderr vazio, ampliada inspecionada: antebraço e mão maiores, conexão visível contínua nesta pose. Logs `test_mao_gl` e `capture_mao` na pasta de evidências 18. Sem novo teste animado ou suíte completa. F6 → Z → V compara proporções; valores ainda dependem de avaliação visual do usuário.

## Vega: distante bem recebido, limpeza de fundo e volume próximo — 24/10/2026

Relato do usuário com screenshot: braço distante “ótimo”, pedindo retirar a parte branca; próximo fino em comparação. Preservar desenho/pose/registro do distante, limpando somente a margem que trazia pixels do fundo opaco da prancha. Observado por captura ampliada e amostragem RGB da fonte: mão/punho tinham vértices sobre cinzas próximos de 220/255, além do contorno preto. Máscara próxima à borda foi ajustada em 1–4 pixels, sem filtro global que apague reflexos metálicos. Geometria interna, fonte, material e transformação do distante preservados; aparência da limpeza ainda depende do retorno visual.

Hipótese para espessura: ganho transversal localizado no próximo, candidato máximo de 24% no ventre do bíceps e 20% no antebraço, não no membro inteiro. `deslocamento_volume()` em `bracos_prancha/vega_fiel.gd` usa eixos da fonte e transições nas extremidades; mantém aro, eixo longitudinal, centros das juntas, regiões de cotovelo/punho e mão. A conexão anterior e a curvatura do aro não recebem volume. UV de origem preservadas com borda subdividida; não é nova pintura nem autorização de animação. `V` alterna só volume, `A` mantém comparação do encaixe anterior, `R` restaura candidata completa. Arquivos PNG/fontes, tronco/cabeça/distante, rig e F5 intactos. Sem geração de arte ou skill de imagem nesta etapa, apenas geometria/recorte nativos.

Verificação Godot 4.7.2: teste da prova headless/OpenGL e regressão headless da guarda 17 passaram, exit 0/zero falhas/stderr vazio. Conferidas imobilidade de juntas/aro/mão, ganho transversal e restauração V/R. Comparação GL de 1.982 pixels da região da mão: diferença máxima 1/255, sem ganho de tamanho nessa área; 7.746 pixels fora dela mudaram com volume. Cinco pontos que antes traziam fundo branco distante agora transparentes; cores internas anteriores conferidas. Regressão do material mantém 45.572 pontos externos à edição do ombro idênticos. Expectativa inicial do teste de volume tratava todo y≤280 como ombro e incluía antebraço; corrigida para a região proximal x≤225. Tentativa intermediária com vértices internos gerou faixa branca na UV próxima e foi removida; resultado final usa somente borda subdividida, sem esses vértices. Não há certificação de todo o contorno ou movimento pelos pontos testados.

Captura GL final exit 0/OK/stderr vazio: oito imagens, com `sem_volume` na mesma câmera e `distante` ampliado; ambas e `ampliada` inspecionadas. Estado anterior guardado em `antes_volume/`. Logs `*_volume*` na pasta de evidências 18. Sem nova importação, suíte completa ou teste animado. `git diff --check` conferido. Exercício: F6 na mesma prévia → Z → V → V → R, observando espessura sem confundir mudança da mão com ganho de braço. Nova proporção próxima ainda em avaliação pelo usuário.

## Vega: revisão localizada do encaixe próximo, após autorização — 24/10/2026

Usuário autorizou “vamos ajustar então” após rejeitar a 18. Observado: terminação triangular no tronco e registro por um ponto deixavam o deltoide/aro descontínuos; a axila também pode sobrepor o bíceps conforme a profundidade. Regra: um deltoide humano, preservar tronco 02/quadril 01, distante, cabeça, rig aceito e F5. Hipótese aplicada nesta mesma prévia: reparar apenas a terminação do ombro, registrar o membro inteiro pelos dois lados do aro e adaptar seu contorno, com a prótese cobrindo a axila. Nova revisão **em avaliação**, não aprovação da guarda inteira ou de movimento.

Skill `imagegen`, ferramenta integrada sem CLI, produziu `bracos_prancha/tronco_encaixe_01.png` RGBA 1774×887; prompt/origem/hash em `manifesto_ombro.json`. Material `ombro_local.gdshader` usa somente ombro/axila próximos da edição; restante do tronco vem da fonte 02 intacta, não da saída inteira do gerador. `vega_fiel.gd` aplica um registro uniforme ao membro completo pelos dois extremos do aro, sem ajustar mão isoladamente. Aro/início do bíceps em região própria da mesma UV, curva local subdividida a cada 2 pixels e borda y280 fixa ao restante. Parte mecânica à frente da axila, sem aba/ombro duplicado; proporção do aro local não é invariável sob essa adaptação. Distante/cabeça/registros do corpo e todas as fontes anteriores preservados. `A` antes/depois na mesma câmera, Z amplia, B sincroniza conexão/membro, R restaura candidata. Capturas iniciais anteriores em `antes_encaixe/`.

Godot 4.7.2 confirmada. Inspeção das capturas identificou e corrigiu escurecimento por multiplicação dupla de cor no material, aro totalmente oculto e faixa da axila cortando o bíceps. Captura de ombro a 3,2× expôs essa última falha; revisada profundidade e removida aba duplicada de uma tentativa intermediária. Curva de poucas arestas deixava quina no aro; subdivisão suaviza a borda. Capturas finais GL exit 0/OK/stderr vazio: guarda/ampliada/ombro inspecionados; seis PNGs com `antes` na mesma câmera. Não afirmar equivalência anatômica com a prancha ou solução em movimento.

Teste da prova passou headless/OpenGL, exit 0/zero falhas/stderr vazio. Conserva verificações anteriores no modo antes e acrescenta dois marcos do aro, registro uniforme comum às peças, curvatura/borda fixa/triangulação, A/B/R, hash e alfa/mipmaps. Tronco isolado antes/depois no GL: 45.572 pontos fora da região editada idênticos, zero externos diferentes, 5.096 internos alterados; é uma área amostrada da apresentação, não toda a arte. Erro inicial de tipagem de array aninhado do novo teste foi corrigido antes da execução final. Regressões headless guarda 17 e camadas 16 passaram; sem suíte completa ou novo teste animado. Importação/reimportação exit 0 conservam avisos conhecidos de 33 ObjectDB/13 recursos. Logs `*_ombro*` nesta pasta de evidências. `git diff --check` conferido. Exercício: F6 na mesma prévia → Z → A → A → B → B → R; avaliar a ligação antes de segmentar/animar.

## Vega: prova 18 rejeitada; recortes não resolveram a montagem — 24/10/2026

Relato do usuário: “tá uma merda”, acompanhado de screenshot ampliado. Observado na imagem: corte/entalhe duro sob o deltoide próximo e descontinuidade entre pele, prótese e tronco. Conferência de `bracos_prancha/vega_fiel.gd`: braços inteiros recebem apenas translação por uma inserção manual cada, enquanto o tronco mantém registro próprio da camada 02. Preservar pixels do braço não preservou a junção com esse corpo. A prova 18 está **rejeitada**, não é base aprovada para segmentar/animar ou promover a F5. A assistência entregou a comparação antes de resolver defeitos visíveis; os testes de cor/UV anteriores não demonstram qualidade dessa montagem.

Nesta resposta apenas inspeção do screenshot/código e registro da rejeição, incluindo aviso no README da candidata. Sem novos ajustes de parâmetros/contornos, geração de arte, alteração de rig ou F5; nenhum teste de execução novo. Regra preservada: referência 04 e tronco/quadril aprovados não foram revogados; manter prova animada anterior. Hipótese de próximo método, ainda não executada: conferir corpo e braços em registro conjunto de uma mesma pose, incluindo o contorno inteiro do encaixe e suas oclusões, antes de separar camadas; alinhamento por um ponto não basta. Exercício opcional sem editar: comparar apenas a linha entre deltoide e aro na referência e no screenshot, sem usar execução de teste como evidência visual.

## Vega: comparar a arte dos braços diretamente com a prancha — prova 18, 24/10/2026

Relato do usuário com screenshot: diferença “absurda” entre braços da montagem e da referência. Observado: as tentativas de recuperar pose/registro da prova 15 e recalibrar o próximo na 17 continuam usando fontes com outro desenho de fibras, placas e silhueta. A última tentativa não foi aprovada; testes geométricos não demonstraram coerência artística. Regra preservada: prancha 04 e tronco 02/quadril 01 aprovados, um único deltoide humano, rig animado anterior conservado. Hipótese desta etapa: uma comparação estática usando os próprios pixels da prancha isola a diferença de arte antes de adaptar qualquer movimento.

Nova bancada isolada `vega_animada/corpo_articulado/bracos_prancha/preview.tscn` (F6). Dois `Polygon2D` delimitam manualmente os braços inteiros da guarda na prancha 04 opaca; UV iguais aos vértices, escala 1, sem giro/paleta, somente translação inteira por inserção no tronco. Mesma cabeça/corpo da 17, membros antigos ocultos nesta variante; nenhuma fonte raster, prova 15/17 ou F5 alterados. Z amplia, B alterna recortes, C/T/P alternam camadas, O mostra marcos/inserções (não ossos antigos), R restaura. README descreve limites. Não são novas peças segmentadas, superfícies ocultas reconstruídas ou braços animados; registro/contornos e aparência conjunta ainda aguardam avaliação do usuário.

Godot 4.7.2 confirmada. Capturas nativas ampliadas com grade permitiram corrigir contornos iniciais que incluíam fundo cinzento e cortavam nós dos dedos; guarda/ampliada/isolados finais inspecionadas. `tests/test_bracos_prancha.gd` passou headless e OpenGL, exit 0/zero falhas/stderr vazio: fonte, UV, ausência de deformação, triangulação, translação/inserções, profundidade, hashes preservados, atalhos; GL confere 20 cores internas e quatro amostras externas transparentes. Não certifica todo contorno/anatomia/juntas ou movimento. Regressão headless da guarda 17 passou, sem suíte completa. Logs e capturas em `docs/evidencias_vega_bracos_prancha_18/`. Inicialização corrigida após erro de constante PackedVector2Array; teste corrigido após hash distante transcrito sem uma letra, fonte original intacta. Um processo de captura criado nesta tarefa foi encerrado após conferir seu comando, por falha de inicialização; capturas finais exit 0/OK. Exercício: F6 → Z → B → B → O → R, avaliando fibras/placas/silhueta primeiro. Não retomar animação só por estes testes.

Importação inicial terminou com código 0, mas conservou os avisos de saída conhecidos (33 instâncias ObjectDB e 13 recursos em uso), registrados em `importacao.stderr.log`; não considerada execução limpa. Capturas/testes finais da prova têm stderr vazio. `git diff --check` passou.

## Vega: revisão localizada da postura do braço próximo — 24/10/2026

Usuário rejeitou novamente a montagem com três screenshots. Observado: recuperar a guarda da prova 15 não reproduziu a postura/massa da prancha; cotovelo próximo alto, antebraço em outro ângulo e conexão humana com corte duro. A hipótese do registro comum para ambos os braços foi insuficiente. Regra: preservar peças/fontes, tronco/quadril/cabeça e a prova animada; não refazer braços nem tratar teste geométrico como qualidade artística.

Tentativa limitada ao próximo em `guarda_montada/vega_guarda.gd`: vetores manuais da guarda, cotovelo `(31,117)` e punho `(118,20)` relativos à inserção; registros uniformes próprios por segmento, mão acompanha densidade do antebraço no mesmo centro. Comprimentos de apresentação passam a depender desses pontos, sem alterar cartas/alcance/regras ou o rig 15. Não há esticamento só transversal ou PNG novo. Distante/cabeça/corpo preservados. A prancha 04 voltou a ser referência padrão, V acessa a prova 15, R restaura a prancha. Há mudança visual de postura/volume próximo, mas corte duro do ombro e diferença do distante **continuam pendentes**; revisão não aprovada pelo usuário nem considerada solução completa.

Teste guarda headless/OpenGL passou, exit 0/zero falhas/stderr vazio: novos centros/comprimentos explicitamente verificados, registros uniformes, fontes/mãos e distante preservados, 150 amostras CPU/275 GPU mais verificações de cabeça/UV. Teste adicional de ventres próximos: zero sobreposições entre 726 pontos pintados na faixa central; não varredura de toda a arte. Regressões headless Combo (156 poses) e camadas (3.164 pontos) passaram; sem suíte completa ou movimento novo. Captura GL exit 0/OK: seis PNGs gerais, incluindo `prancha_ampliada.png`; comparação ampliada inspecionada. Anteriores em `antes_pose_proxima/`. Sem geração raster, importação ou mudança F5. `git diff --check` conferido. Exercício: F6 → Z (prancha já selecionada) → O → R; avaliar primeiro a postura do braço próximo, sem confundir com aprovação do ombro ou do conjunto inteiro.

## Vega: recuperar registro dos braços da prova 15 na guarda 17 — 24/10/2026

Usuário autorizou conferir integração existente. `tests/inspecionar_registro_bracos.gd` mediu a guarda real da prova 15 (Combo zero/tempo zero): raízes com −7°/+2° e projeção distante .92. A 17 usava .90/.75 independentes, descartava giros herdados e escondia o superior próximo inteiro. Nova implementação em `guarda_montada/vega_guarda.gd` usa um único registro uniforme pelos dois ombros para preservar raízes/juntas relativas aceitas. Escalas resultantes .838723/.771625, relação .92. Superior próximo repartido nativamente em duas regiões contíguas na UV y220: só conexão sob pele, restante do bíceps à frente; mesmos PNGs, osso e registro. Não se refez arte nem se alteraram a prova 15, tronco/quadril aceitos, cabeça ou F5. Revisão visual ainda depende do usuário, sem equivalência automática com a prancha 04.

Prévia F6 agora mostra à esquerda a prova 15 real pausada e registrada nos mesmos ombros; V alterna para prancha 04, O juntas, Z amplia, R restaura. Godot 4.7.2 confirmada; API de interseção consultada na documentação oficial 4.7. Teste guarda headless/GL passou, exit 0/zero falhas/stderr vazio: raízes e seis juntas comparadas à instância aceita, fontes/mãos, relação .92, 1.536 pontos UV de partição, V/reset, mais 150 amostras CPU/275 GPU e verificações anteriores. Expectativa inicial rejeitava os 32 pontos na borda compartilhada y220; corrigida para permitir borda comum sem área interna sobreposta. Regressões headless Combo fixed-fps 60 (156 poses) e camadas (3.164 pontos) passaram. Captura GL exit 0/OK: cinco PNGs gerais atualizados, guarda/ampliada/prancha inspecionadas; anteriores em `antes_registro_bracos/`. Logs de medidas/testes/capturas na pasta de evidências 17. Sem suíte completa, importação, novo filme ou teste animado destas camadas. `git diff --check` conferido. Exercício: V → Z → O → R para separar referência mecânica aceita do desenho de conceito.

## Vega: braços já produzidos; recomendação de refazer foi prematura — 24/10/2026

Usuário perguntou se os braços já não estavam feitos. Conferência confirma: existem próximo/distante com arte própria, três segmentos registrados, juntas/mãos calibradas e conjunto de movimento/respiração/Combo aprovado na prova 15. Os mesmos scripts/fontes foram reutilizados na 17; não faltam braços produzidos. A 17 introduziu escalas .90/.75, novos encaixes e oclusão de todo o segmento superior próximo. A divergência com a prancha permanece observável, mas isso não prova necessidade de produzir os braços novamente. A recomendação anterior da assistência foi prematura e não deve iniciar retrabalho.

Primeiro recorte recomendado: comparar a montagem aceita da prova 15 à 17, recuperar uma relação consistente de proporções/pose/camadas para o tronco novo e identificar o que ainda difere por desenho. Preservar braços/rig aceitos; não prometer que apenas escala resolve toda diferença artística. Nesta resposta somente esclarecimento e registros corrigidos; sem alteração de assets/código/F5, geração ou testes de execução novos. `git diff --check` conferido. Exercício sem editar: abrir a prévia 15 e comparar a guarda com a 17, antes de alterar parâmetros.

## Vega: montagem 17 diverge dos braços da referência aprovada — 24/10/2026

Usuário apresentou a montagem e a prancha 04 lado a lado, apontando a diferença do braço. Inspeção dos fontes/scripts confirma: `guarda_montada` reutiliza `braco_montado_01.png`/`distante/braco_interno_01.png` da construção anterior, não peças derivadas dos braços desenhados na prancha 04. Distribuição de placas, volume e silhueta diferem. Escalas candidatas .90/.75 e oclusão do segmento superior próximo agravam a diferença de leitura; não atribuir tudo à perspectiva ou corrigir apenas a espessura por esticamento. Aprovação antiga das próteses não tornava essas fontes equivalentes à referência corporal mais recente. A decisão de combiná-las assim foi da assistência; a montagem 17 não está visualmente aprovada.

Regra vigente: tronco 02/quadril 01 e conceito da prancha 04 continuam aprovados; preservar o único deltoide humano, sem cúpula duplicada. Próxima recomendação, ainda não executada/autorizada como novo recorte: preparar primeiro um braço próximo fiel à guarda da prancha 04, com volume/placas e encaixe conferidos antes de segmentá-lo para o rig; preservar a prova animada antiga como referência mecânica, não como substituta da nova arte. Nesta resposta somente diagnóstico/registro; sem retocar escalas, substituir imagens, gerar arte, modificar rig ou F5. Godot 4.7.2 confirmada; nenhum teste de execução novo, `git diff --check` conferido. Exercício de inspeção: comparar a quantidade/posição das placas e a largura das fibras entre as duas imagens; não mudar parâmetros para tentar fazer fontes diferentes parecerem iguais.

## Vega: corrigir recorte/registro do pescoço, não gerar outro rosto — 24/10/2026

Relato do usuário com screenshot: cabeça parece defeituosa e há mancha preta sob o queixo. Diagnóstico por render nativo ampliado da montagem, cabeça isolada, sem material e tronco isolado: a fonte existente contém sombra desenhada sob a mandíbula; registro alto `(600,125)`, recorte curto e desvanecimento iniciando em y132 deixavam essa região desconectada/mesclada ao coto do pescoço. Havia ainda fragmento solto do ombro antigo. Não houve nova geração de cabeça nem deformação dos pixels do rosto. Escala isoladamente não corrigia esse erro de montagem.

Alterados `guarda_montada/vega_guarda.gd` e `pescoco.gdshader`: marco manual `(610,140)`, recorte preserva aba sob a mandíbula/exclui fragmento e transição em y150..182, abaixo dos pontos testados do rosto. Escala .85 e todos os PNGs/corpo/braços/F5 preservados. Sombra da ilustração não foi pintada/apagada; não afirmar equivalência exata à cabeça da prancha 04 ou aprovação artística da junção. Nova montagem em avaliação.

Godot 4.7.2 confirmada; teste guarda passou headless/OpenGL, exit 0/zero falhas/stderr vazio, mantendo 150 amostras CPU/275 GPU. Acrescentadas regressões de marco, preservação da aba, exclusão do fragmento, quatro pontos do rosto iguais com/sem máscara e um ponto opaco sob a mandíbula com cabeça isolada. Amostras não certificam todo contorno. Captura GL final exit 0/OK, quatro PNGs da bancada atualizados; guarda/ampliada inspecionadas. `tests/capturar_cabeca_guarda.gd` produziu evidências nativas de diagnóstico: `cabeca_antes/` e `cabeca_depois/` (esta também inclui região do atlas), exit 0/OK. Guardada montagem anterior em `antes_encaixe_pescoco/`. Sem edição raster, importação, animação ou suíte completa. `git diff --check` passou. Exercício: F6 → Z → C → C → R, observando a união pescoço/mandíbula, não só a dimensão da cabeça.

## Vega: redução localizada da cabeça na guarda 17 — 24/10/2026

Relato do usuário com screenshot: cabeça “enorme” em relação ao corpo da montagem. Observado no código: recorte do atlas estava em escala uniforme 1, enquanto corpo e membros receberam registros próprios. Regra: corrigir somente a proporção da cabeça, sem ampliar o corpo aprovado para compensar. Hipótese aplicada: escala .85 (redução linear de 15%) em torno do mesmo marco do pescoço. Alterado somente o padrão `escala_cabeca` em `guarda_montada/vega_guarda.gd`; PNGs, recorte/material, braços, tronco/quadril e F5 preservados. Nova proporção ainda depende da avaliação visual do usuário.

Godot 4.7.2 confirmada. Teste da guarda atualizado para conferir escala uniforme .85 e âncora anterior; passou headless/OpenGL, exit 0/zero falhas/stderr vazio, 150 amostras CPU e 275 GPU. Captura GL exit 0/OK; quatro PNGs atualizados e ampliada inspecionada. Capturas anteriores preservadas em `docs/evidencias_vega_guarda_montada_17/escala_100/`; logs novos com sufixo 085. Sem geração raster, nova animação, importação de assets ou suíte completa nesta correção. `git diff --check` passou. Exercício: F6 e Z para observar cabeça em relação a ombros/peito; C oculta/mostra apenas a cabeça, R restaura.

## Vega: cabeça e dois braços na guarda por camadas — prova 17, 24/10/2026

Usuário autorizou a próxima etapa após aprovar tronco 02/quadril 01. Nova candidata isolada `vega_animada/corpo_articulado/guarda_montada/preview.tscn`, F6: reúne cabeça do atlas existente e os dois braços reconstruídos às camadas aprovadas. Mesmas fontes/registro do corpo, sem repintura ou geração raster. Membros registrados por pontos manuais na fonte do tronco, escalas uniformes .90/.75, guardas/calibrações de mão anteriores; cabeça por UV, escala 1 e transição curta de alfa na aba do pescoço. Corpo antigo não fica sob o novo. Cap próxima sob o único deltoide humano, antebraço/mão à frente, distante atrás. Sem pernas novas: montagem vai até as coxas da camada aceita. Sem animação corporal nova ou alteração F5; avaliação visual do usuário pendente. Conceito/fontes/pontos/limites no README da nova pasta.

Primeira captura revelou z relativo atrás do fundo e pedaço do ombro antigo no recorte da cabeça; corrigidos profundidade, UV e composição do pescoço antes da entrega. Godot 4.7.2 confirmada. Teste novo headless/GL passou, exit 0/zero falhas/stderr vazio: hashes de cinco fontes, registro/camadas, mãos centradas, comprimentos, escalas, estabilidade de 12 quadros e atalhos; 150 amostras CPU de juntas, 275 GPU (próteses isoladas e transições centrais). Duas verificações de visibilidade com fundo incluídas; expectativa inicial errada de alfa composto idêntico corrigida após RGB mostrar-se igual e alfa elevar-se a 1 sobre fundo opaco. Pontos cobertos não validam toda costura/anatomia ou movimento. Regressões headless camadas/Combo passaram (3.164 pontos/156 poses); sem suíte completa ou teste de combate. Captura GL exit 0/OK, quatro PNGs em `docs/evidencias_vega_guarda_montada_17/`; guarda/juntas/ampliada inspecionadas. Importação exit 0 conserva avisos conhecidos de 33 ObjectDB/13 recursos. `git diff --check` executado. Exercício: O → T → T → R para observar as inserções sem editar a base. Só depois do retorno visual, recomendar participação corporal/respiração destas camadas.

## Vega: revisão do tronco 02 aprovada — 24/10/2026

Relato do usuário após a entrega: “perfeito, melhorou”. Registrar `camadas_guarda/tronco_02.png` com `quadril_01.png` como base visual estática aprovada; preservar volume, regata/cobertura, ombros e registro sem novos retoques por hipótese. Aprovação não equivale a camadas animadas, guarda completa com membros ou integração F5. As notas anteriores de avaliação pendente são históricas.

Nesta resposta apenas documentação/manifesto atualizados; nenhuma geração, edição de arte, código, rig ou F5. JSON validado e `git diff --check` executado; testes Godot não repetidos. Próximo recorte recomendado, ainda não iniciado: reunir cabeça/braços aprovados às camadas numa guarda completa isolada e validar encaixes antes de animar. Exercício opcional na bancada existente: P oculta/mostra quadril; R restaura, para observar a sobreposição sem editar a base.

## Vega: camadas aprovadas; ajuste discreto do busto sob a regata — 24/10/2026

Relato do usuário: aprovou a montagem tronco/quadril 01, comentou que o ombro parece maior na referência (possivelmente perspectiva) e pediu apenas mais volume nos seios sem roupa reveladora. A hipótese de perspectiva não foi confirmada; não se reabriu o desenho dos ombros. Skill imagegen/ferramenta integrada editou somente a fonte de tronco em nova candidata `camadas_guarda/tronco_02.png`, mantendo regata opaca, gola/cobertura e direção HQ. Aumento visual discreto, não medição anatômica de percentual. Original 01/quadril/prancha preservados com hashes; prompt integral e fonte no manifesto. Nova 02 ainda depende do retorno visual do usuário.

`camadas_guarda.gd` usa a 02 na mesma bancada F6, sem alterar transformações/marcos, quadril, rig, animação ou F5. `tests/test_camadas_guarda.gd` verifica a textura ativa e os três hashes/fontes. Godot 4.7.2 confirmada; testes headless e OpenGL passaram, exit 0/zero falhas/stderr vazio: 3.164 pontos opacos de sobreposição, 372 amostras GPU cobertas, mesmas checagens de registro/atalhos. Isso não garante invariância pixel a pixel ou encaixes animados. Importação/reimportação exit 0, com os avisos anteriores de 33 ObjectDB/13 recursos ainda em uso; não resolvidos aqui. Captura GL exit 0/OK, cinco PNGs atualizados em `docs/evidencias_vega_camadas_guarda_16/`; montadas/registro inspecionados, sem abertura observada na cintura da guarda. Capturas anteriores preservadas na subpasta `base_01/`. Sem suíte completa, novo filme ou teste de combate. Exercício: abrir a prévia F6, usar P para ocultar/mostrar o quadril e observar o volume sob a mesma regata; R restaura.

## Vega: duas camadas candidatas da guarda, com bancada F6 — 24/10/2026

Usuário autorizou preparar tronco/quadril após aprovar a prancha 04. Skill imagegen/ferramenta integrada produziu `vega_animada/corpo_articulado/camadas_guarda/tronco_01.png` e `quadril_01.png`, ambas 1774×887 RGBA, com peito/tecido sob os braços e sobreposição na cintura. Fonte completa/prompt/hash no `manifesto.json`; cópias integrais sem edição raster local ou alteração da prancha. Geração não preservou escala/posição solicitadas; registro explícito uniforme por pescoço/cintura e nó da camisa, sem deformação de anatomia. Aba superior do quadril contém tecido carvão semelhante à regata, não anatomia oculta completa. Duas peças ainda sem avaliação visual do usuário.

Nova bancada `camadas_guarda/preview.tscn`, F6: referência aprovada à esquerda e montagem parcial à direita. E separar, T/P ocultar peças, F referência translúcida, O marcos manuais, R restaurar. Sem cabeça/braços/pernas novos ou animação. Ordem de desenho separa a extensão superior atrás do tronco e camisa à frente. Primeiro registro pelos ombros deixou cintura deslocada; registro central melhorou a montagem. Fontes têm alfa residual 1/255 fora das peças: material descarta só esse piso, sem regravar PNGs; mipmaps/filtro linear configurados. Conceito/arquivos/exercício/limites no README da pasta.

Godot confirmada 4.7.2. Teste novo passou headless/OpenGL, zero falhas/exit 0, logs finais sem stderr: alfa/hashes/ordem/registro/uniformidade, 3.147 pontos opacos de sobreposição na janela da cintura, 372 amostras GPU centrais cobertas, independência das peças, guias e handlers. Ombros manuais independentes a 5,23/4,14 px dos marcos, tolerância candidata 12 px; não são encaixes de rig aprovados. API inicial de teste `Image.has_alpha` inexistente foi corrigida para `detect_alpha` após consulta oficial 4.7; leitura PNG via buffer. Regressão Combo 15 passou headless/fixed-fps 60 (156 poses), sem suíte completa. Captura GL exit 0/OK: cinco PNGs em `docs/evidencias_vega_camadas_guarda_16/`, montagem/separação/peças/registro inspecionados. Importação exit 0 mantém avisos conhecidos de ObjectDB/recursos. `git diff --check` passou. Sem novo filme, pesos/animação destas peças, combate real ou alteração F5. Exercício: Ajuste Tronco `(0,0)→(5,0)→(0,0)` na cena candidata, antes de F6, comparando O/F.

## Vega: prancha corporal 04 e ligação próxima aprovadas — 24/10/2026

Relato do usuário após a revisão 04: “perfeito, agora sim está aprovado”. Adotar `docs/arte_vega/vega_corpo_volume_poses_04.png` como referência visual aceita do conceito corporal e da ligação do braço próximo: deltoide humano único, conexão metálica discreta, sem outra cúpula de ombro. Preservar também o distante explicitamente bem recebido. Não reabrir esses desenhos por hipótese nem estender aprovação estática a peças registradas, articulação/animação nova ou integração F5.

Nesta conversa somente registro documental, sem nova geração de imagem, alteração de código/asset ativo/rig ou teste de execução/captura. `git diff --check` passou. Próximo recorte recomendado, não iniciado: preparar tronco/quadril da guarda com regiões ocultas e marcos de pescoço/cintura/ombros, validar encaixes antes de derivar outras vistas do gesto. Exercício opcional sem editar: usar a prancha 04 como comparação fixa ao observar os encaixes da prévia 15; distinguir referência visual aprovada de material já registrado para animação.

## Vega: corrigir identificação — ombro duplicado é o da frente — 24/10/2026

Usuário esclareceu explicitamente: o distante está “extremamente bom”; o problema é o braço próximo/da frente, cuja cúpula protética repete o deltoide humano existente. A assistência identificou o lado errado na resposta anterior; análise/revisão 03 do distante não representam o pedido correto. Preservar o distante aprovado e a direção corporal bem recebida. Alvo correto é só remover o volume de ombro metálico redundante no próximo, mantendo pele/ombro humano e conexão discreta ao bíceps mecânico.

Skill imagegen/ferramenta integrada, edição localizada da 03 gerou `docs/arte_vega/vega_corpo_volume_poses_04.png`. Inspeção: faixa fina substitui cúpula próxima na guarda/preparo; impacto tem região mais encoberta pelo antebraço, ainda a avaliar. 1774×887 RGB opaco, fonte e cópia com hash igual. Comparação RGB em três retângulos do distante mostrou diferenças; não afirmar preservação exata de pixels ou substituir automaticamente o material aprovado. Retângulos/contagens/prompts/fontes/limites no documento `vega_corpo_volume_poses.md`. Sem código/rig/clipes/arte ativa/F5 alterados, sem execução Godot. `git diff --check` passou. Exercício visual: conferir transição pele→fibras do próximo na guarda/preparo, sem reabrir o distante por hipótese.

## Vega: conceito corporal bem recebido, ressalva do ombro duplicado — 24/10/2026

Usuário gostou do conceito, mas apontou por duas ampliações que um braço repete o problema de “ombro integrado ao ombro”. Aprovação é da direção corporal, não dos encaixes. Observado na prancha 02, sobretudo no impacto: trecho humano antes de outra cadeia mecânica superior. Skill imagegen/ferramenta integrada usada para edição localizada do distante nas três poses; candidata `docs/arte_vega/vega_corpo_volume_poses_03.png`. Preservar conceito/identidade, uma única inserção sob o deltoide humano; não tentar compensar a arte acrescentando ombro ou deslocando o rig.

Saída inspecionada: pele antes da prótese reduzida e cotovelo mais legível no impacto; distante de guarda também redesenhado. Espessura/segmentação mudaram e precisam de avaliação, sem equivalência automática com peças do rig. 1774×887 RGB opaco, dimensões/formato conferidos e hash da cópia igual à fonte. Prompt completo/fonte/limites no documento `docs/arte_vega/vega_corpo_volume_poses.md`. Sem comparação pixel a pixel de invariância, execução Godot, nova animação ou mudança em assets ativos/F5. `git diff --check` passou. Exercício sem editar: comparar ombro→bíceps→cotovelo na guarda e no impacto, verificando um único segmento superior.

## Vega: estudo desenhado de volume corporal em três poses — 24/10/2026

Usuário autorizou testar a prancha de guarda/preparo/impacto com foco em tronco/quadril. Skill imagegen/ferramenta integrada, referência primária da prova 15 e mestre da guarda unificada. Duas gerações não destrutivas em `docs/arte_vega/vega_corpo_volume_poses_01.png` e `_02.png`, ambas 1774×887 RGB opaco. A 01 levantou cotovelo/armou braço incoerente com o golpe seguinte; revisão localizada 02 abaixou cotovelos e manteve guarda compacta. Candidata ainda sem avaliação do usuário. Processo/prompts/fontes/limites em `docs/arte_vega/vega_corpo_volume_poses.md`.

Inspeção visual: três figuras inteiras, roupa/identidade reconhecíveis, mudanças de contorno de ombro/axila e dobras no impacto. Guarda/preparo revisados ainda próximos e torção de quadril limitada; não declarar efeito de adesivo resolvido ou anatomia validada. Não comparados pixels dos painéis laterais para afirmar preservação exata. Dimensões/formato conferidos, hash da cópia 02 igual à fonte; cópias integrais sem edição raster local. Nenhum código, asset ativo, rig/clipe, regra ou F5 alterado; sem teste de execução/capturas na Godot ou importação nesta etapa. `git diff --check` passou. Exercício sem editar: cobrir braços na prancha e comparar gola/ombros/lateral da regata/nó da camisa para avaliar se o corpo muda volume antes de montar peças.

## Vega: explicar produção de arte corporal para movimento — 24/10/2026

Usuário quer futuramente mudar a arte para superar a leitura de adesivo e perguntou como fazer. Inspeção de `vega_corpo.gd`, README corporal e integração de tronco confirma: já há ossos/pesos próprios para abdômen/cabeça e participação de pelve/joelhos, mas a superfície corporal reutiliza uma pintura integral. Portanto não propor adicionar os mesmos ossos novamente nem tratar mais recortes como solução de perspectiva. Recomendação em discussão: manter identidade/próteses e provar guarda/preparo/impacto com desenhos corporais que mudem silhueta, volume e sobreposição; combinar deformação suave com vistas desenhadas onde necessário. Primeiro recorte seria tronco/quadril de um golpe, registrando pescoço/cintura/ombros para preservar encaixes; ainda sem geração de arte, alteração de rig/animação, autorização de reconstrução integral ou mudança F5. Nesta conversa somente inspeção/explicação e registro, sem testes de execução/capturas; `git diff --check` passou. Exercício sem editar: comparar as poses 1/2/3 da prova 15, observando se as linhas de ombros e cintura mudam perspectiva ou apenas giram no plano.

## Vega: conferência do estado do F5 — 23/10/2026

Usuário perguntou se a versão aprovada já estava pronta para testar no F5. Inspeção dos arquivos confirma: `project.godot` abre `jogo.tscn`, `jogo.gd` carrega `main.tscn`, e `main.gd` ainda instancia `rig_nativo_v2/vega_combate.tscn`. A prova 15 continua isolada; seu `definir_combo_visual()` ainda não está ligado à atualização de Combo real de `main.gd`. Visual/movimentos foram aprovados na prévia, mas falta adaptar as entradas do combate, conferir ganho/Finalização/zeragem e promover a cena. Nesta conversa apenas inspeção e registro, sem alteração de código/cena/animação ou novo teste de execução. `git diff --check` passou. Verificação opcional no editor: conferir o campo Cena Apresentacao Vega na raiz de `main.tscn`, sem mudar o recurso.

## Vega: tensão por Combo da prova 15 aprovada pelo usuário — 23/10/2026

Relato do usuário: “tá funcionando bem, gostei”. Registrar aprovação da tensão visual por Combo nos braços reconstruídos, junto aos golpes/alternância/respiração/dano já aceitos. Preservar intensidade, pintura, proporções e juntas desta referência. Não equivale a teste de Combo real das cartas, Finalização, fim de turno ou migração F5. Nesta conversa somente registro documental; sem código/arte/animação alterados e sem novos testes de execução/captura. `git diff --check` passou. Próximo recorte recomendado, não iniciado: ligar a apresentação aprovada ao estado real de combate em uma cena de teste isolada, conferindo ganho/consumo/zeragem antes de substituir o F5. Exercício opcional sem alterar a referência: trocar Amplitude Biceps 0,18→0,14→0,18 na prévia e comparar a amplitude, restaurando o valor aprovado.

## Vega: tensão por Combo nas fibras reconstruídas, prova 15 — 23/10/2026

Usuário autorizou o próximo recorte após aprovar respiração/dano. Nova prévia F6 `vega_animada/corpo_articulado/combo_fibras/preview.tscn`: referência 14 em Combo zero à esquerda, candidata à direita. ↑/↓ um ponto, 0 consumo, 6/7/8 Combo 5/10/20; golpes/dano/respiro/reduzido e inspeção preservados. Observado: placas e fibras novas compartilham a pintura; hipótese aplicada é deformar só o ventre macio, sem mover ossos/mãos/juntas. Regra linear 10 pontos percentuais por Combo, máximo visual em 10 sem teto mecânico. Ainda sem aprovação artística da candidata.

`vega_combo.gd/.tscn` e `malha_fibra.gd` acrescentam quatro malhas privadas, mesmas fontes/registro/paleta. Máscaras de metal com margem rígida; tampas dos aros sem subdivisão. Combo zero desenha o original exato. AnimationPlayer continua escrevendo ossos; Tween só de vértices reutiliza regra/curva/0,2 s existentes, interrompível da tensão atual, reduzido imediato, ocultação/reset cancelam e limpam. Skill animate orientou indicação de estado/continuidade. Primeiro teste GPU achou um pixel neutro divergente no punho; compartilhar vértices não bastou, corrigido mantendo contorno rígido inteiro e subdividindo só centro. Não se afrouxou a tolerância para ocultar a falha. Conceito/arquivos/controles/exercício em `combo_fibras/README.md`.

Godot confirmada 4.7.2. Teste novo passou headless/OpenGL, zero falhas/exit 0: 156 poses, 2.808 amostras GPU de juntas, 52 poses Combo zero idênticas em pixels à 14; corpo/botas/mãos/clipes/comprimentos preservados. Onze níveis sem inversão/expansão axial, 14.520 verificações de vértices rígidos; faces sobre máscaras inteiramente presas. Guarda 5/10 altera 6.672/7.148 pixels; 20 idêntico a 10. Neutro da malha subdividida: nenhum pixel com delta >0,02, máximo ~0,00784; zero usa original exato. Transições/retarget/consumo no dano/ganho no ataque, ordem, reduzido, reset/ocultação e handlers passaram. Regressão presença passou headless/GL (148 poses/2.664 amostras/dez poses-chave dos golpes idênticas); Combo nativo passou headless. Captura GL exit 0/OK: 23 comparações + dois diagnósticos PNG em `docs/evidencias_vega_combo_15/`; guarda ampliada/impacto distante/dano e corpo final inspecionados. AVI gerado, 277 quadros/60 FPS (~4,62 s), exit 0, sem reprodução externa. Logs finais sem stderr; diagnósticos iniciais com falha preservados. Importação exit 0 mantém avisos conhecidos de recursos/RID/fontes/ObjectDB. `git diff --check` passou. Sem suíte inteira, cartas/Combo reais ou migração F5. Exercício opcional: Amplitude Biceps 0,18→0,14→0,18 antes de F6, sem mudar a regra linear.

## Vega: respiração e reação ao dano aprovadas pelo usuário — 23/10/2026

Relato do usuário sobre a prova 14: “boa, ficou ótimo também”. Respiração em guarda e reação ao dano passam a integrar a referência aprovada, junto aos dois golpes/alternância da prova 13. Preservar pintura, juntas, proporções e movimentos aceitos. Aprovação não abrange Combo ainda não adaptado nem integração ao combate principal. Nesta conversa somente registro documental; sem código, arte ou animação alterados e sem novos testes de execução/captura. Verificação: `git diff --check`. Próximo recorte recomendado, não iniciado: adaptar a tensão visual por Combo à montagem reconstruída, preservando os encaixes, antes da migração F5. Exercício opcional já disponível: comparar Amplitude Respiro 1→0,7→1 na cena da prova 14 e restaurar o valor aprovado.

## Vega: respiração em guarda e reação ao dano sobre a prova 13 — 23/10/2026

Usuário autorizou respiração/dano após aprovar a nova versão. Variante `vega_animada/corpo_articulado/presenca_combate/preview.tscn`, F6: referência 13 à esquerda e candidata respirando à direita. D simula dano, B compara respiro/estática, G retoma, Espaço alterna golpes; L/R/Z/O/X e poses dos golpes preservados, 4/5 pausam inspiração/pico de dano. Observado: versão aceita voltava à guarda estática; hipótese aplicada é ciclo discreto de peito/ombros/mãos com pés apoiados e recuo curto ao impacto. Pintura/juntas/proporções/golpes aceitos não alterados. Candidata ainda sem aprovação artística do usuário.

Skill animate orientou prontidão/feedback/continuidade e reduzido; AnimationPlayer nativo único. Dois clipes privados novos, respiro 2,4 s cúbico e reação .26 s linear, tempos do projeto; captura .10 para dano/golpes e .16 para retorno. Dano não consome ordem, transições partem da pose atual, ataque/dano retornam ao respiro ou guarda estática se desabilitado/reduzido. Cor de impacto reutiliza Tween .10/.16, cancelável; reduzido sem articulação/loop, feedback termina sem Tween pendente. Ocultar pausa/ignora eventos e mostrar retoma. Sem novo rig, arte, regras, Combo ou F5. Conceito/limites/exercício em `presenca_combate/README.md`.

Godot confirmada 4.7.2. Teste novo passou headless/OpenGL, zero falhas/exit 0: 148 poses/2.664 amostras GPU, pesos/fontes/UV/centros/comprimentos preservados, botas fixas, rosto sem esticar nos marcos conferidos, nenhuma face invertida. Dez poses-chave dos golpes idênticas à 13 em pixels e clipes anteriores sem alterações. Punho próximo move ~4,54 px na inspiração e ~24,45 px na reação; medidas não substituem percepção. Interrupção de mãos/tronco, dano repetido, ordem, retorno, preferência de respiro durante ataque, reduzido/flash, ocultação e handlers verificados. Regressões alternância/integração passaram headless/OpenGL. Captura GL exit 0/OK: 19 PNGs em `docs/evidencias_vega_presenca_14/`; corpo na inspiração, detalhe da reação e marcos inspecionados. AVI gerado (329 quadros/60 FPS, ~5,48 s), exit 0, sem reprodução externa. Logs finais sem stderr; importação mantém avisos conhecidos RID/fontes/ObjectDB. Sem suíte inteira ou playtest principal. `git diff --check` passou. Exercício: Amplitude Respiro 1→0,7→1 na raiz da cena candidata, antes de F6, sem alterar duração/golpes.

## Vega: nova versão com golpes alternados aprovada pelo usuário — 23/10/2026

Relato do usuário após a prova 13: “ficou ótimo, gostei muito da nova versão”. Adotar o conjunto visual/movimento dessa prévia como referência aprovada: golpe próximo, direto distante, guarda/retorno e alternância. Preservar pintura, mãos, proporções, juntas e esforço corporal. Não extrapolar a aprovação para respiração/dano/Combo ainda não adaptados, novas vistas/parte inferior ou migração F5. Nesta conversa apenas registro documental; nenhum código, asset ou animação alterado e nenhum teste de execução/captura novo. `git diff --check` passou. Próximo recorte recomendado, ainda não iniciado: respiração em guarda e reação ao dano sobre a base aprovada, antes de Combo e integração final ao combate. Exercício opcional sem editar: L/Espaço na prova 13 para guardar referência do ritmo aceito.

## Vega: direto distante e alternância na montagem aprovada — 23/10/2026

Usuário autorizou o próximo recorte. Variante `vega_animada/corpo_articulado/golpes_alternados/preview.tscn`, F6: esquerda golpe próximo de referência 12, direita alterna próximo/distante por Espaço. X reinicia, T troca lado inspecionado, 1/2/3 pausam poses, L lento, Z detalhe, O juntas, R reduzido. Observado: distante reconstruído só tinha guarda; hipótese aplicada é direto com esforço corporal e mão próxima protegendo. Mesma arte/palma/proporções/pesos/encaixes; um AnimationPlayer e novo clipe privado `corpo_soco_distante`, .56 s/chaves existentes, captura .10 s cúbica in-out. Skill animate orientou feedback/continuidade/interrupção/reduzido, sem sistema paralelo de UI. Nenhuma aprovação artística do novo gesto inferida.

Primeira captura cortou a mão na margem antiga; ampliado somente offset direito do SubViewport (+160 px, nativo 938×978), sem encurtar membro/mudar caixa lógica. Ampliação do painel também corrigida: expandir ignorando tamanho mínimo antes de atribuir atlas. Biblioteca corporal já era privada; removida duplicação redundante que alterava precisão dos tempos antigos. Compensação de um grau no preparo mantém direção da mão próxima. Comparação de pixels usa canvas de mesmo tamanho para controlar a renderização. Detalhes/limites/exercício em `golpes_alternados/README.md`.

Godot confirmada 4.7.2. `test_golpes_alternados.gd` passou headless/OpenGL, zero falhas/exit 0: 114 poses/2.052 amostras GPU nas juntas; mesmas chaves antigas, comprimentos/centros/fontes/UV/pesos, botas fixas, zero faces invertidas, mãos distintas nos dois impactos. Próximo idêntico nas cinco poses-chave em canvas igual; punho distante avança ~151,17 px sem alongamento. Seis golpes alternados completos, interrupção nas duas direções sem salto imediato, retorno/inspeção/reset/oculto/reduzido/handlers verificados. Regressões integração/corpo passaram headless/OpenGL. Capturas GL finais exit 0/OK, 23 PNGs em `docs/evidencias_vega_alternancia_13/`; preparo/impacto, corpo/detalhe e marcos inspecionados, mão inteira após correções. AVI gerado (251 quadros/60 FPS, ~4,18 s), exit 0, sem reprodução externa; geração não valida ritmo. Logs finais sem stderr; importação conserva avisos conhecidos RID/fontes/ObjectDB. Sem suíte inteira, gameplay/Combo/respiração/dano adaptados ou migração F5. `git diff --check` passou. Exercício: Remota/AnimationPlayer, speed_scale .25→.20→.25 para avaliar continuidade; depois restaurar.

## Vega: integração 12 bem recebida; próximo recorte em discussão — 23/10/2026

Relato do usuário sobre a integração de tronco/próteses: “muito bom e agora?”. Registrar retorno favorável ao conjunto da prova 12 e preservá-lo como referência visual. Não estender a conclusão artística da personagem inteira, golpe distante, Combo ou migração F5. Inspeção confirma que a prova atual reproduz `corpo_soco` próximo; a cadeia distante reconstruída recebe guarda/elevação, não um soco próprio adaptado. `main.gd` ainda usa a cena nativa anterior, cujo adaptador tem alternância/respiração/dano/Combo; essas capacidades não devem ser presumidas equivalentes na montagem reconstruída.

Recomendação apresentada: próximo objetivo observável é adaptar soco do braço distante e conferir alternância com retorno à guarda, preservando pintura, mão/palma, juntas e esforço corporal aceitos. Respiração/reação/Combo e integração ao combate vêm depois de fechar essa lacuna, sem começar novo passe artístico ou pernas por inferência. Só inspeção e registro nesta conversa; nenhum código/asset/animação/F5 alterado e nenhum teste de execução/captura novo. `git diff --check` passou. Exercício sem editar: observar Espaço/1/2/3 na prova 12 para distinguir golpe próximo de guarda distante.

## Vega: prova 12 de integração entre tronco e próteses — 23/10/2026

Usuário autorizou trabalhar a integração do tronco com os braços após perceber pouco impacto na gola. Observado: pintura de pele/regata mais suave que metal/fibras e ausência de contato sob braço dianteiro. Hipótese aplicada em candidata isolada: sombras/dobras mais agrupadas na regata, pintura dos ombros na mesma superfície aceita e sombra de contato aproximada do braço próximo sobre tecido. `vega_animada/corpo_articulado/integracao_tronco/preview.tscn`, F6, comparação do MESMO movimento em corpo inteiro por padrão; A antes/depois, S só sombra, Z ampliar, 1/2/3 poses, Espaço golpe, L lento, R reduzido, O juntas. Ainda sem retorno artístico do usuário; não declarar coerência concluída.

Skill imagegen/ferramenta integrada editou atlas original usando braço aprovado como referência de contraste/contorno. Fonte gerada 1774×887 copiada sem edição raster, hash idêntico; prompt/origem/limites em `integracao_tronco/README.md`. Shader limita uso ao tronco/ombros: alterações geradas em pernas/rosto/partes externas não substituem arte em uso. Malha/UV/pesos/clipes/ossos e mãos preservados; gola 11 continua. Primeiro teste detectou transparência alterada ao remover camada antiga do ombro; corrigido mantendo seu recorte/alfa e trocando só RGB. Sombra usa duas cápsulas aproximadas sobre regata, lê ossos antes da renderização, sem mover juntas ou criar animação/relógio novo. Não é luz física/sombra exata de placas ou mão.

Godot confirmada 4.7.2. `test_integracao_tronco.gd` passou headless/OpenGL, zero falhas/exit 0: 57 poses, geometria/pesos/clipes/mãos, interrupção/retorno/reduzido/handlers. GPU atlas: 28.834 pixels RGB locais, zero externos/alfa; nativos guarda/preparo/impacto com A reproduzindo base 11 sem divergências e transparência final idêntica. Sombra escurece 2.249/1.508/1.438 pixels respectivamente; 33 marcos protegidos e 18 quadros de seguimento automático conferidos. Regressões corpo/gola passaram headless/OpenGL, zero falhas; corpo 1.254 amostras GPU/sem faces invertidas/botas fixas. Captura final GL exit 0/OK, 12 PNGs em `docs/evidencias_vega_integracao_12/`; três detalhes e corpo no preparo inspecionados. Contraste/dobras da regata mais definidos nesses enquadramentos; relevância artística ainda a avaliar. Logs finais sem stderr; importação conserva avisos conhecidos RID/fontes/ObjectDB. Sem vídeo, suíte inteira, playtest F5, pernas novas, regras/HUD/Combo ou migração. `git diff --check` passou. Exercício: Sombra Contato 0,32→0,16→0,32 na cena candidata, observando braço/tecido no preparo.

## Vega: retorno de baixo impacto visual no acabamento da gola — 23/10/2026

Relato do usuário sobre a candidata 11: “não senti tanta diferença assim, mas ok”. Registrar pouca diferença percebida e aceitação com ressalva; não tratar como aprovação entusiasmada, ganho artístico expressivo ou resolução da coerência entre corpo e próteses. Testes técnicos anteriores continuam válidos nos seus limites, mas não demonstram relevância perceptiva do retoque. Nesta conversa somente registro documental; nenhum código, asset, rig, movimento ou F5 alterado e nenhum novo teste de execução/captura. `git diff --check` passou. Nenhuma nova rodada de geração ou ampliação de escopo iniciada por esse retorno.

## Vega: acabamento localizado de pescoço/gola na malha aceita — 23/10/2026

Usuário esclareceu que a pergunta pela parte inferior era apenas informativa e autorizou seguir. Retomado o acabamento de pescoço/gola, sem reconstruir pernas. Observado: prova corporal 10 aceita usa pintura anterior; regra é preservar rosto, braços, pesos e movimento. Hipótese artística aplicada em candidata isolada: definir planos do pescoço/sombra sob mandíbula e contato da gola. Nova prévia `vega_animada/corpo_articulado/acabamento_gola/preview.tscn`, F6, dois lados com o MESMO movimento. 1/2/3 poses, Espaço golpe, A antes/depois, Z detalhe/corpo, L lento, R reduzido, O juntas. Não é aprovação visual nova nem integração F5.

Skill imagegen/ferramenta integrada gerou edição do atlas 1774×887; original copiado sem edição raster, hash igual, prompt/origem em `acabamento_gola/README.md`. Geração altera também pixels fora da área solicitada; material privado em Pele usa somente RGB dentro de máscara UV do pescoço/gola, transição interior 3 px, conservando textura base/alfa/modulação. Mesma malha e pesos acompanham cabeça/peito por skinning; não é outra peça rígida. Sem novo rig, animação, rosto, mãos, pernas, HUD, regras, Combo ou troca do F5.

Godot confirmada 4.7.2. Teste novo `tests/test_gola_vega.gd` passou headless/OpenGL, zero falhas/exit 0: 57 poses, pesos/clipes/mãos preservados, interrupção/retorno/reduzido/handlers. GPU atlas completo: 3.636 pixels RGB locais alterados, zero externos/alfas; guarda/preparo/impacto renderizam o efeito e desligar material reproduz base sem divergência visível RGB/alfa. Regressão corporal passou headless/OpenGL: zero falhas, 57 poses/1.254 amostras GPU, sem faces invertidas, botas fixas. Captura GL exit 0/OK, 12 PNGs em `docs/evidencias_vega_gola_11/`; inspecionados detalhes nas três poses e corpo no impacto. Efeito discreto, mais exposto no preparo; avaliação artística pendente. Logs finais sem stderr; importação conserva avisos conhecidos de recursos/RID/ObjectDB. Sem vídeo novo, suíte inteira ou playtest F5. `git diff --check` passou. Exercício: Intensidade Gola 1→0,5→1 na cena candidata, comparando acabamento sem mover ossos.

## Vega: esclarecer o trabalho pendente na parte inferior — 22/10/2026

Usuário perguntou pela parte de baixo após a referência de pescoço/gola. Inspecionados documentação de apoio, ossos do rig inferior e trilhas da prova corporal atual. Observado: calça/tecido amarrado/botas continuam na pintura anterior; pelve gira/translada, joelhos são controles independentes de posição para deformação suave e botas ficam no apoio fixo. Não existe ainda cadeia completa de coxa/canela/tornozelo/pé nem acabamento inferior novo. A participação corporal aceita não equivale a reconstrução das pernas.

Recomendação em discussão: incluir parte inferior no recorte de coerência e priorizar uma perna, começando pela da frente, antes de aprofundar acabamento fino do pescoço. Conferir articulação quadril–joelho–tornozelo, volume/dobras da calça e apoio da bota em guarda/preparo/impacto, com roupa deformável e sem emendas rígidas aparentes. Preservar tronco/braços aceitos e postura de referência; não inferir autorização para implementação, nova arte ou troca F5 apenas pela pergunta. Nesta conversa só inspeção e registro; sem novos testes/capturas, arte ou alteração de código. `git diff --check` passou. Exercício sem editar: comparar joelho da frente e sola nas poses 1/2/3 da prova corporal para distinguir deformação atual de articulação completa.

## Vega: retorno favorável à referência de pescoço/gola — 22/10/2026

Relato do usuário sobre a referência localizada 01: “parece bom”. Registrar retorno favorável à direção de acabamento do pescoço/clavículas/gola, sem estender a rosto, cabelo, próteses, brilho periférico ou todo o close-up regenerado. Não é validação de registro, camada de produção ou movimento da nova arte. Somente registro documental nesta conversa; nenhum asset em uso, rig, peso, clipe ou F5 alterado. Sem novos testes/capturas; `git diff --check` passou.

Próximo recorte recomendado, ainda não iniciado: derivar somente a região pertinente em uma variante registrada e conferir guarda/preparo/impacto sobre a articulação corporal aceita, preservando face/braços atuais. Exercício sem editar: comparar a borda da gola e a sombra sob o queixo entre referência 01 e guarda nativa 10; não usar mudanças fora dessa região como alvo.

## Vega: referência localizada de pescoço/gola, ainda não aplicada — 22/10/2026

Após concordância do usuário com acabamento artístico incremental, iniciado somente um close-up de referência para transição mandíbula/pescoço/clavículas/gola/ombro humano. Skill imagegen/ferramenta integrada, entrada guarda nativa da prova 10. Candidata em `docs/arte_vega/vega_pescoco_gola_ref_01.png`, 1536×1024 RGBA; fonte, prompt integral, escopo e limites no MD irmão. Observado: prova usa pintura anterior; hipótese artística é melhorar planos de pele, sombra sob queixo e contato da gola. Inspeção do resultado mostra esses volumes mais definidos, mas geração também reinterpreta detalhes fora da região e tem brilho periférico. Não adotar rosto/cabelo/braços gerados como substitutos dos aceitos. Referência aguarda avaliação do usuário, não é camada de produção ou arte final aprovada.

Godot confirmada 4.7.2; arquivo aberto/dimensões conferidas e quatro cantos com alfa zero. Não auditada toda a borda/transparência ou fidelidade por pixel. Original copiado sem edição raster. Nenhum código, rig, clipe, pesos, shader, peça em uso ou F5 alterados; sem novos testes de execução, captura Godot ou vídeo. `git diff --check` passou. Próximo recorte condicionado à avaliação: derivar apenas acabamento da região para peça/camada registrada e conferir três poses, sem sobrepor o close-up inteiro ao rig. Exercício sem editar: comparar gola/pescoço com guarda 10, não os detalhes regenerados fora da região.

## Vega: participação corporal da prova 10 bem recebida — 22/10/2026

Relato do usuário após experimentar a prova corporal: “participam, gostei como ficou”, em resposta à avaliação do esforço conjunto de peito, cabeça e quadril. Registrar aprovação dessa participação corporal e preservar a prova 10 como referência de movimento. Não extrapolar para arte corporal definitiva, aprovação isolada de cada gesto da guarda, soco distante, alternância, Combo ou migração F5. Nesta conversa somente registro documental; nenhuma alteração em arte, rig, cena, animação ou gameplay. Sem novos testes de execução/capturas; verificações técnicas permanecem as da etapa anterior. `git diff --check` passou.

Próximo recorte recomendado, ainda não iniciado: avaliar uma única região artística do tronco/pescoço sobre esse movimento, preservando os controles e braços aceitos, antes de reconstrução integral ou ampliação de golpes. Exercício opcional sem editar: F6/2/3/O para observar como as inserções acompanham o corpo na referência aprovada.

## Vega: primeira prova mecânica de abdômen e cabeça — 22/10/2026

Usuário autorizou experimentar o recorte corporal. Nova variante `vega_animada/corpo_articulado/preview.tscn` (F6), comparação lado a lado com a base 09 amostrada no clipe anterior. 1/2/3 guarda/preparo/impacto, Espaço ciclo .56 s, L lento, O juntas/cadeia corporal, R reduzido. Observado: corpo tinha rig mas cabeça seguia peito. Hipótese aplicada: inserir Abdomen entre Pelve/Tronco e Cabeca na base do pescoço, preservando rest global/guarda por rebind; redistribuir pesos de cintura/pescoço, normalizados e limitados a quatro influências. Mesmo acabamento/pele, UV/face/textura, braços/mãos/paleta. Biblioteca privada com caminhos atualizados; um AnimationPlayer, sem IK ou ajuste de produção por frame. Skill animate orientou continuidade espacial, timing/captura nativos e reduzido.

Novo clipe corporal mantém .56 s/chaves .00/.10/.20/.36/.56, acrescenta giros distribuídos e maior transferência de peso com botas fixas; cabeça compensa a inclinação do peito. Braço próximo compensa giros adicionais para manter direção, mas sua origem acompanha o corpo. Guarda distante sobe no impacto (ombro 135→185°), preservando cotovelo 120°/punho 0° e peças/centros, para liberar a mão atacante. Gesto ainda experimental, não novo soco distante. Primeira tentativa mostrou seis vértices com cinco influências, 84 faces transparentes invertidas e mãos sobrepostas; corrigidos pesos/rampas laterais da cabeça e guarda elevada, sem enfraquecer testes.

Godot confirmada 4.7.2/fixed-fps 60. `test_corpo_articulado.gd` passou headless/OpenGL: zero falhas/exit 0, 57 poses, 1.254 amostras GPU nas juntas/rosto/pescoço/peito/cintura. Guarda: desvio máximo 0,000130 px; nenhuma face invertida, incluindo transparências; botas/vértices fixos, distância entre dois marcos faciais preservada, inserções/direção do golpe conferidas e zero interseções opacas amostradas das mãos no impacto. Recomeço sem salto imediato, retorno, reduzido e handlers verificados. Amostragem não prova toda borda/perspectiva/anatomia ou trajetória de ambas as mãos. Regressões guarda distante, ombro 06 e paleta 09 passaram headless, zero falhas/exit 0; sem suíte inteira ou cartas.

Captura GL exit 0, 16 PNGs em `docs/evidencias_vega_corpo_articulado_10/`; guarda/preparo/impacto nativos, comparação e marcos finais inspecionados. Movie Maker gerou `corpo.avi`, 137 quadros/60 FPS (~2,28 s), exit 0; sem reprodução externa. Testes/captura/filme finais sem stderr. Importação exit 0 conserva avisos conhecidos de RID/fontes/ObjectDB/recursos ao encerrar; `git diff --check` passou. Conceito, limites, APIs, testes e exercício Remota/Abdomen 3→4→3° em `corpo_articulado/README.md`.

É prova mecânica com a pintura anterior, não construção 2D híbrida/arte corporal final. Sem novas vistas/áreas ocultas/cabelo articulado/pernas completas, dano/idle novos, alternância/Combo ou migração F5. Provas aceitas intactas. Próximo resultado necessário: avaliação do usuário do corpo e guarda elevada antes de preparar novas camadas/arte corretiva.

## Vega: avaliar construção corporal antes de ampliar os golpes — 22/10/2026

Usuário autorizou seguir e levantou necessidade de uma Vega que não pareça “um adesivo que se mexe”, para sustentar complexidade e coerência visual. Avaliação focada com skill improve-animations, sem implementar novo rig. Godot confirmada 4.7.2. Inspecionados scripts/estrutura dos rigs, docs de apoio/ombro, clipes e capturas existentes de impacto 05 e guarda/paleta 09. Observado: já há Polygon2D/Skeleton2D deformável, pelve/tronco/clavículas/deltoides/joelhos/apoio fixo e um AnimationPlayer corporal. Portanto não é tecnicamente um sprite corporal sem rig. Porém a camada Pele ainda reúne cabeça, tórax, roupa e pernas de uma mesma pintura; há um controle de tronco e nenhum controle próprio de cabeça/pescoço. O apoio inferior atual é pequena deformação com joelhos transladados e botas fixas, não pernas articuladas completas. A prova distante permanece intencionalmente estática.

Regra: preservar identidade HQ, materiais, braços/mãos/encaixes aceitos e provas anteriores. Limite de representação, não bug novo de easing: deformação da pintura não fornece automaticamente novas vistas/volumes ou áreas ocultas para torções amplas. Hipótese/recomendação, ainda sem método aprovado: construção 2D híbrida, separando controles/camadas corporais onde necessário, pele/roupa deformáveis, metal rígido e desenhos corretivos para mudanças de perspectiva. Não resolver com mais oscilação do conjunto ou apenas dividir a pintura em peças rígidas. Para a câmera atual, primeiro avaliar tronco/quadril em guarda/preparo/impacto, usando os braços atuais e mantendo continuidade das inserções/volume e contato dos pés. Isso precederia adaptação de golpe distante/alternância; não inferir autorização para redesenho completo, migração 3D ou troca F5.

Somente inspeção e registros documentais nesta conversa. Nenhuma arte, rig, pose, animação, regra ou F5 alterados. Sem novos testes de execução, benchmark, capturas ou vídeo; imagens examinadas são anteriores e não demonstram a solução proposta. `git diff --check` passou. Próximo passo depende de alinhar o recorte da prova corporal. Exercício opcional sem editar: comparar guarda 09 e impacto 05, observando relação entre cabeça/peito/cintura e encaixes, não apenas o deslocamento das mãos.

## Vega: retorno positivo à paleta e à base visual distante — 22/10/2026

Relato do usuário após a harmonização 09: “agora sim temos algo”. Registrar retorno favorável ao conjunto visual atual, preservando guarda, tamanho da palma (multiplicador 1.20), paleta corrigida e encaixes como base para a próxima avaliação. Não extrapolar para aprovação de movimento distante, alternância, Combo ou migração F5. Nesta conversa apenas registro documental; nenhuma alteração em arte/código/cenas, novos testes ou capturas. Verificações técnicas continuam as da etapa 09; `git diff --check` passou.

Próximo recorte recomendado, ainda não iniciado/autorizado por este registro: validar um soco do braço distante na variante, primeiro inspecionando guarda/preparo/extensão/retorno e suas juntas, antes de alternar ataques. Exercício opcional sem editar a base: F6/O para localizar os três centros que deverão continuar conectados durante esse movimento.

## Vega: harmonização dos cinzas da vista distante — 22/10/2026

Relato do usuário: tamanho das mãos agora bom (“agora sim”), mas cores diferentes. Registrar aprovação da calibração local do tamanho, não conclusão artística do braço distante. Observado por inspeção/fontes/amostragem: cinzas distantes menos azulados e médios/claros um pouco mais quentes que os próximos. Regra: manter o braço próximo como referência de material e preservar mão/encaixes aprovados. Hipótese aplicada: shader `distante/paleta_distante.gdshader` aproxima tons neutros via ganhos RGB suaves por luminância, protegendo saturados, pretos profundos, quase brancos e alfa. Mesmo material privado nas três peças distantes; PNG/UV/geometria/ossos/escala anteriores. `harmonizacao_cor` regula 0–1; C compara original/corrigida na mesma pose. F5/Combo/movimento distante anteriores.

Godot confirmada 4.7.2/fixed-fps 60. `test_paleta_distante.gd` passou headless/OpenGL, zero falhas/exit 0: médias neutras mais próximas em três faixas condicionadas e 16 amostras GPU sintéticas de cinzas/acentos/preto/alfa/intensidade zero. No render nativo completo, 10.655 pixels RGB mudam e 760.884 pixels alfa permanecem idênticos. Handler C, material só no distante e punho imóvel verificados. Teste guarda distante passou headless/OpenGL, 175 pontos CPU/175 GPU nas juntas, mesma proporção das mãos e zero sobreposição na faixa central amostrada (695 pontos). Ombro 06 passou headless, 133 poses; zero falhas/exit 0. Sem suíte inteira, cartas ou novo movimento.

Captura GL exit 0: seis PNGs em `docs/evidencias_vega_distante_paleta_09/`; inspecionados original/harmonizada nativos e detalhe das juntas. Correção discreta de temperatura, não equivalência completa de desenho/iluminação. Paleta ainda aguarda avaliação do usuário. Testes/captura sem stderr; sem nova importação do editor nesta etapa. Evidências 07/08 preservadas; `git diff --check` passou. Conceito/limites e exercício de intensidade .5→1 no Inspector em `braco_reconstruido/distante/README.md`.

## Vega: calibrar tamanho da palma distante sem mover o punho — 22/10/2026

Relato do usuário com screenshot: tamanho das mãos parece diferente, mas resultado está indo bem; não registrar aprovação final da guarda. Observado na medição da tinta nos eixos do punho com projeção herdada: próxima 78,358×65,357; distante 60,141×52,771, cerca de 77% do comprimento próximo. Regra: preservar lado próximo aprovado, juntas centradas, orientação/guarda e proporções dos braços. Hipótese visual aplicada: multiplicador uniforme 1.20 só da malha palmar em `vega_distante.gd`, sem translação. Resulta 72,169×63,326, 92,10% do comprimento/96,89% da largura próximos. Pequena diferença de projeção mantida; calibração ainda aguarda avaliação do usuário. Sem novos PNGs de arte, alteração de UV, ossos, guarda, demais peças ou F5.

Godot confirmada 4.7.2/fixed-fps 60. Teste distante passou headless/OpenGL, zero falhas/exit 0: proporções medidas, centro da mão no punho, escala uniforme, polegar, preservação do próximo, 12 quadros estáveis e comparação. 175 pontos CPU e 175 GPU de cobertura, incluindo ponte punho–palma ampliada; zero sobreposição entre 695 pontos centrais do antebraço. Não prova todos os pixels/anatomia/movimento. Sem nova suíte inteira, cartas ou movimento distante. Captura GL exit 0: seis PNGs em `docs/evidencias_vega_distante_mao_08/`, originais 07 preservados; corpo/detalhe das juntas inspecionados, sem vão observado nesse enquadramento. Testes/captura sem stderr; `git diff --check` passou. Exercício 1.15→1.20 no parâmetro do Inspector e limites em `braco_reconstruido/distante/README.md`.

## Vega: guarda distante com vista interna própria, candidata estática — 22/10/2026

Usuário autorizou seguir, pedindo muito cuidado com coerência e juntas. Novo recorte somente da guarda distante em `braco_reconstruido/distante/preview.tscn` (F6), A compara o fundo e O mostra centros. Braço próximo aprovado/corpo preservados. Observado: lado distante ainda usava montagem anterior; espelhar a fonte dorsal próxima não forneceria palma/face interna. Skill imagegen usada para derivar uma vista interna inteira dos materiais aprovados, com palma desenhada, transparente e sem edição raster posterior. Hipótese aplicada: três segmentos registrados por centros da mesma pintura, com placas integradas, reduzem incongruência de peças independentes. Herda raiz/projeção/camada do rig distante; guarda candidata 135°/120°/0° abre 60° internos. Mão mantém densidade raster do antebraço, sem deslocar raiz; reflexão transversal só da malha palmar orienta polegar para dentro na base distante refletida. Não converter dorso em palma por espelho.

Godot 4.7.2/fixed-fps 60: `test_guarda_distante.gd` passou headless/OpenGL, zero falhas/exit 0. 105 pontos CPU de cobertura só das peças novas e 105 GPU nas juntas; zero sobreposições entre 695 pontos na faixa central pintada do antebraço. Verificados registros uniformes, raiz/ossos, fonte própria, orientação do polegar, preservação de arte/UV/pesos/transformações do próximo, clipes intactos, comparação e 12 quadros estáticos. Amostragem não prova toda a borda, perspectiva ou aprovação artística. Regressões ombro 06/movimento 05 passaram headless, 133 poses cada, zero falhas/exit 0. Sem suíte completa ou cartas.

Captura OpenGL exit 0: seis PNGs em `docs/evidencias_vega_distante_guarda_07/`; inspecionados guarda, anterior, guias e recorte `juntas_detalhe.png`. Palma assentada no colar e dobradiça preenchida no enquadramento; proporções aparentes/perspectiva ainda dependem do usuário. Importação com mipmaps; testes/captura finais sem stderr. Editor conserva avisos conhecidos de recursos/RID/fontes/ObjectDB ao encerrar; exit 0. `git diff --check` passou.

F5 e provas aprovadas intactos. Sem movimento do novo distante, alternância, Combo ou pele distante repesada; não marcar braço concluído só por testes da guarda. Fonte, prompt integral, marcos, limites e exercício reversível 120→118→120 no cotovelo estão em `braco_reconstruido/distante/README.md`. Avaliar guarda/juntas antes de adaptar movimento.

## Vega: braço próximo com ombro integrado aprovado pelo usuário — 22/10/2026

Relato explícito sobre a prova 06: “perfeito, tá otimo esse braço”. Registrar aprovação deste braço próximo em movimento, incluindo a junção do ombro apresentada em `braco_reconstruido/ombro_integrado/preview.tscn`. Esta passa a ser a referência aprovada a preservar: guarda, mão, proporções, encaixe e movimento. Não estender aprovação ao braço distante, expansão por Combo, alternância adaptada ou migração F5.

Nesta conversa somente registro documental da aprovação; nenhum ajuste de arte, rig, cena, animação ou gameplay. Sem novos testes de execução ou capturas; verificações técnicas permanecem as da etapa anterior. `git diff --check` passou. Próximo recorte recomendado, ainda não iniciado: adaptar o braço distante, primeiro em guarda estática, respeitando sua vista e lateralidade em vez de apenas espelhar o braço próximo. Exercício opcional sem editar a referência: F6/O para observar a inserção aprovada e distinguir os centros do ombro/cotovelo/punho.

## Vega: primeira deformação localizada do ombro próximo — 22/10/2026

Usuário autorizou seguir a proposta da junção. Nova variante F6 `vega_animada/braco_reconstruido/ombro_integrado/preview.tscn`, preservando a prova 05 bem recebida e F5. Observado: pele/acabamento tinham pesos antigos; cap metálica é parte da prótese rígida. Hipótese aplicada: partilhar 28% do giro pelo deltoide, compensando no osso filho para manter a trajetória da prótese, e transferir até .30 de peso clavícula→deltoide somente na máscara local. Rebind na guarda conserva a silhueta. Pele e acabamento recebem a mesma geometria/pesos; arte/UV/faces e metal permanecem anteriores. Sem novo desenho de ombro, IK, preenchimentos adicionais ou escritor por frame. Um AnimationPlayer e biblioteca privada; tempos/curvas/apoios/mão aprovados preservados. Skill animate orientou preservação de timing, interrupção e reduzido. A compara variantes na mesma fase do clipe; L/O/Espaço/D/G/R anteriores reutilizados.

Godot 4.7.2/fixed-fps 60: `test_ombro_integrado.gd` passou headless/OpenGL, zero falhas/exit 0; 133 poses e 3.458 amostras GPU opacas nas juntas/mão. Desvio máximo da trajetória da prótese 0,000069 px; guarda ponderada 0,000062 px. Pesos normalizados/localizados, recursos isolados, acabamento alinhado, mesmas curvas/tempos, dano/interrupção, retorno, reduzido/retomada e A pausado/reproduzindo verificados. Resposta máxima da malha no impacto 24,487 px nativos, não medida de todos os pixels visíveis. Amostragem não comprova anatomia ou toda a borda. Regressões de movimento 05 e encaixe estático passaram headless, zero falhas/exit 0. Sem suíte inteira ou integração com cartas.

14 PNGs antes/depois em `docs/evidencias_vega_ombro_integrado_06/`, captura OpenGL exit 0. Inspecionados guarda/.10/.15/.20/.28/.36 e impacto anterior: pele acompanha mais o esforço, enquanto prótese e guarda preservam a posição. Avaliação visual limitada, não aprovação do usuário. Movie Maker gerou `ombro.avi`, 187 quadros/60 FPS (~3,1 s), exit 0; sem reprodução externa. Testes/captura/filme sem stderr. Importação exit 0 conserva avisos conhecidos de recursos/RID/fontes/ObjectDB ao encerrar. `git diff --check` passou.

Não redesenhada a transição pictórica, nem separado o cap do segmento superior. Segundo lado, Combo e F5 intactos. Instruções, limites e exercício L/A para comparar a pele no impacto em `braco_reconstruido/ombro_integrado/README.md`. Próximo resultado necessário é avaliação do usuário da junção em movimento; não declarar acabamento final por estabilidade geométrica.

## Vega: proposta localizada para a transição ombro–prótese — 22/10/2026

Usuário perguntou o que podemos fazer para arrumar a junção após esclarecimento de que o ombro humano foi reaproveitado. Inspecionados código e capturas existentes de guarda/impacto. Observado: acabamento da pele duplica geometria/pesos antigos e aplica pintura mascarada; cap metálica pertence ao segmento superior rígido da prótese nova. A ligação hierárquica ao deltoide não é por si um defeito. Hipótese a avaliar: transição visual/desenho e deformação local não foram concebidos juntos para a prótese atual. Proposta: trabalhar somente a região do ombro próximo como conjunto coerente de pele e encaixe metálico, com pele deformável e metal rígido, ajustar participação/pesos de clavícula/deltoide e conferir guarda/extensão/retorno sem alterar braço/mão/proporções aprovados. Não criar novo sistema de rig ou refazer corpo inteiro por inferência.

Somente inspeção e recomendação, sem nova arte, implementação, testes ou capturas. Godot confirmada 4.7.2; `git diff --check` passou. Nova intervenção ainda depende de direção do usuário. Verificação manual sugerida: F6/L/O na prévia de movimento e observar a borda pele–metal durante preparo/impacto, sem editar a pose aprovada.

## Vega: movimento bem recebido; esclarecer o ombro reaproveitado — 22/10/2026

Relato do usuário após testar a prova 05: “tá ótimo, funcionando bem”. Retorno favorável ao movimento atual de um braço; não estender a segundo lado, Combo ou migração F5. Usuário perguntou se criamos ombro novo ou acoplamos braço ao existente. Inspeção confirma: pele/geometria/pesos e ossos de clavícula/deltoide vêm do corpo anterior, inclusive acabamento local de pele da etapa `acabamento_proximo`. Arte nova inclui cap metálica de inserção, braço superior, antebraço e mão. A prótese cria seu próprio pivô Bone2D chamado Ombro, mas a raiz é filha do deltoide já existente, com a transformação da inserção anterior (`vega_encaixe.gd`). Um AnimationPlayer coordena as trilhas corporais e as da nova cadeia (`vega_movimento.gd`). Não houve reconstrução anatômica do ombro humano nesta etapa.

Conversa de explicação: só inspeção/registro documental, nenhum ajuste de arte/rig/pose/animação e nenhum novo teste/captura. `git diff --check` passou. Para explorar sem alterar parâmetros aprovados, F6/O mostra os pivôs; na árvore Remota, expandir Deltoide para ver a prótese como filha.

## Vega: primeiro braço reconstruído em movimento na variante isolada — 22/10/2026

Usuário autorizou trazer movimento após aprovar a guarda estática. Nova cena F6 `vega_animada/braco_reconstruido/preview_movimento.tscn`, com respiração automática, Espaço para soco próximo, D dano/interrupção, G reset, R reduzido, O juntas e L câmera lenta 4x. `vega_movimento.gd/.tscn` deriva da montagem aprovada e copia biblioteca privada: trilhas próximas apontam para a nova cadeia; corpo/pernas/ombros/distante/tempos/curvas anteriores preservados. Um AnimationPlayer, sem IK ou escritor paralelo dos ossos. Guarda/retorno 75°/−120°/0°, mão (.76,−.76), comprimentos e raiz preservados. Preparo antigo −170° não reutilizado: dobra limitada à guarda −120° para não sobrepor ventres. Soco .56 s/impacto .20, dano .26 s, captura cúbica existente na interrupção/retorno. Skill animate orientou feedback, reuso de tokens nativos, interrupção/reduzido e inspeção lenta.

Godot confirmada 4.7.2/fixed-fps 60. `test_movimento_braco_reconstruido.gd` passou headless/OpenGL, zero falhas/exit 0: 133 poses (57 soco/27 dano/49 respiração), recursos privados/guarda inicial-final/ossos/raiz/mão/apoios e zero sobreposições na faixa central pintada amostrada. GPU: 3.458 pontos opacos em ombro/cotovelo/punho/mão, zero falhas, sem provar todos os pixels/instantes. Verificados reinício sem salto imediato, dano interrompendo, retorno automático, reset, reduzido/retomada, prova só do braço próximo e isolamento estático. Handler Espaço/D/R/G/L exercitado sem teclado físico. Regressões corpo/braco_reconstruido/acabamento_proximo passaram headless, zero falhas/exit 0. Helper de sobreposição virou estático para reuso; lógica e prova estática preservadas.

Captura OpenGL exit 0, 18 PNGs em `docs/evidencias_vega_movimento_05/`; inspecionados guarda/preparo/impacto/retorno .28/dano/respiração. Juntas ocupadas e segmentos distinguíveis nessas fases, avaliação limitada. Movie Maker gerou `movimento.avi`, 187 quadros a 60 FPS (~3,1 s), exit 0; sem reprodução em player externo nesta execução. Testes/captura/filme sem stderr; importação exit 0 mantém avisos conhecidos de recursos/RID/fontes/ObjectDB ao encerrar. Sem benchmark ou suíte inteira.

F5 e cenas estáticas intactos; sem nova arte, segundo lado, expansão de Combo nas placas ou integração com cartas. Movimento ainda aguarda avaliação do usuário; não promover aprovação estática à animação por testes. Instruções/limites e exercício L/O/D em `braco_reconstruido/MOVIMENTO.md`.

## Vega: guarda estática e encaixe do braço próximo aprovados pelo usuário — 22/10/2026

Relato explícito do usuário após o detalhe da etapa 04: “muito melhor, agora sim está aprovado”. Registrar aprovação visual desta montagem estática: um braço próximo reconstruído no corpo, guarda 75°/−120°/0°, abertura interna 60°, mão (.76,−.76) e raiz no deltoide. Referência em `vega_animada/braco_reconstruido/preview_corpo.tscn` e capturas `docs/evidencias_vega_dobra_cotovelo_04/`. Não estender aprovação ao segundo lado, animação da cadeia nova, Combo ou integração F5.

Nesta conversa, somente registro da aprovação e atualização documental. Nenhuma arte, pose, script ou cena alterada; sem novos testes/capturas. Verificações técnicas continuam as da etapa anterior; `git diff --check` passou. Próximo recorte proposto, não iniciado: adaptar movimento de um braço na variante isolada, usando esta guarda como referência e conferindo as juntas ao longo do soco antes de segundo lado/migração. Exercício sem mudar a pose aprovada: F6/O para relacionar os centros à separação visível dos segmentos.

## Vega: corrigir a dobra entre antebraço e bíceps, não a distância do peito — 22/10/2026

Usuário esclareceu com screenshot: antebraço está tão próximo do bíceps que uma peça cobre a outra. A interpretação anterior como folga do tronco estava errada; compensação 103°/−153° fechava mais a dobra e agravava o problema. Testes anteriores de cobertura/centros não verificavam interseção de pintura opaca. Na mesma prova F6, candidata passa a ombro 75°/cotovelo −120°/punho 0°, abrindo o ângulo interno de 27° para 60°. Preservados raiz no deltoide, comprimentos, recortes/UV/camadas, PNG e mão (.76,−.76), pele e outro lado. Direção global do antebraço acompanha a postura nova; não conservar a restrição equivocada da etapa 03.

Godot confirmada 4.7.2/fixed-fps 60. Teste corporal passou headless/OpenGL, zero falhas/exit 0. Nova regressão usa alfa/recortes/transformações reais na faixa central 45–65% do antebraço: 723 pontos pintados, 378 sobrepostos na dobra antiga e zero na candidata. Não prova todos os pixels, anatomia ou movimento; junta é excluída porque requer sobreposição. Também verifica abertura interna >=59°, separação dos centros dos ventres >60 unidades, mão/raiz/corpo preservados e estabilidade de 12 quadros. GPU: 26 amostras de ombro/juntas/mão passaram. Regressões braco_reconstruido e acabamento_proximo passaram headless, zero falhas/exit 0.

Captura OpenGL exit 0, quatro PNGs em `docs/evidencias_vega_dobra_cotovelo_04/`; guarda/detalhe inspecionados, segmentos separados nos ventres e ligação mantida no cotovelo. Testes/captura sem stderr; evidências anteriores preservadas; `git diff --check` passou. Sem novas imagens raster, animação, cartas ou suíte inteira; F5 intacto. Ajuste ainda candidato. Exercício de mudar somente cotovelo −120→−125 e restaurar em `braco_reconstruido/ENCAIXE_CORPO.md`.

## Vega: afastar guarda do peito sem deslocar a raiz — 22/10/2026

Relato do usuário: mão melhorou, mas conjunto continua muito colado ao corpo; não registrar aprovação final da guarda. Na mesma prova F6, ajuste postural pequeno: ombro 95°→103°, cotovelo −145°→−153°, punho 0°. Giro compensado conserva soma −50°/direção do antebraço e desloca cotovelo/mão cerca de 18 unidades do rig para fora, com pequena diferença vertical. Mantidos centro na pele, corpo/clavículas, comprimentos, fonte, mão (.76,−.76) e outro braço. Sem translação independente ou nova arte. A dobra entre segmentos fica 8° mais fechada: conferir sobreposição, não chamar de abertura do cotovelo.

Godot confirmada 4.7.2/fixed-fps 60. Teste corporal passou headless/OpenGL, zero falhas/exit 0, incluindo deslocamento lateral >15, vertical <4, direção preservada e estabilidade de 12 quadros. GPU: mesmas 26 amostras de cobertura passaram, sem provar toda a silhueta ou anatomia. Regressões braco_reconstruido e acabamento_proximo passaram headless, zero falhas/exit 0. Captura OpenGL exit 0, quatro PNGs em `docs/evidencias_vega_guarda_folga_03/`; guarda/detalhe inspecionados, mais espaço aparente na lateral do peito. Testes/captura sem stderr; evidências anteriores preservadas; `git diff --check` passou. Sem animação nova, cartas ou suíte inteira; F5 intacto. Ajuste ainda candidato. Exercício de +2°/−2° no par ombro/cotovelo em `braco_reconstruido/ENCAIXE_CORPO.md`.

## Vega: reduzir mão e testar inversão do polegar na prova corporal — 22/10/2026

Usuário apontou mão grande demais e virada para o lado contrário. Observado no código: calibração da mão para 100.065 unidades gerava escala raster aproximadamente 34% maior que a do antebraço. Na mesma prova F6 corporal, somente a malha da mão recebe escala (.76,−.76): redução uniforme de 24% e reflexão transversal pelo centro do punho. Osso nominal, raiz, comprimento do braço, ombro/cotovelo/guarda, pele e lado distante preservados. Interpretada a orientação como lado do polegar, mantendo dorso visível; reflexão 2D não converte dorso em palma e essa interpretação ainda aguarda retorno do usuário. Sem nova arte, edição de PNG ou migração do F5. Guia O termina agora na extensão real da malha; prova isolada sem escala mantém visual anterior.

Godot 4.7.2/fixed-fps 60: teste corporal passou headless/OpenGL, zero falhas/exit 0, incluindo escala uniforme/reflexão/raiz/direção dos dedos, resto do braço inalterado e estabilidade por 12 quadros. GPU: 26 amostras opacas do ombro/juntas/mão e ponte do punho; não prova todos os pixels ou anatomia. Regressões braco_reconstruido e acabamento_proximo passaram headless, zero falhas/exit 0. Captura OpenGL exit 0, quatro PNGs novos em `docs/evidencias_vega_mao_corpo_02/`; guarda/detalhe inspecionados, mão visivelmente menor e polegar do outro lado, sem vão central aparente na junção examinada. Testes/captura finais sem stderr; evidências corporais 01 preservadas. Sem novos testes animados, cartas ou suíte inteira. Detalhes/limites e exercício do fator de escala no Inspector em `braco_reconstruido/ENCAIXE_CORPO.md`.

## Vega: um braço reconstruído no corpo, guarda estática candidata — 22/10/2026

Usuário autorizou experimentar a prótese no corpo. Nova cena F6 `vega_animada/braco_reconstruido/preview_corpo.tscn`, derivada da variante de acabamento anterior. Uma instância do braço novo é presa ao deltoide próximo, com a transformação exata da raiz anterior; braço próximo antigo inteiro oculto, sem sobrepor duas montagens. Fonte PNG, registros e comprimentos preservados. Nenhuma geração/edição raster nesta etapa. Corpo amostrado na primeira chave de respirar e pausado; nova guarda local 95°/−145°/0°, em vez de 105°/−160°/0° da prova isolada. Apenas a candidata muda: outros clipes, personagem F5 e provas anteriores intactos. A alterna montagem antiga/nova; O mostra centros.

Observado nas capturas: a cap da prótese encontra a borda inferior da pele do deltoide sem vão transparente visível no detalhe desta guarda; punho próximo ao rosto e dobra mais aberta. Avaliação visual limitada, ainda sem retorno do usuário. Mão próxima e distante diferem em tamanho/material, pois o outro lado continua anterior. Não afirmar anatomia/perspectiva de todos os ângulos ou movimento resolvido.

Godot 4.7.2/fixed-fps 60: `test_encaixe_braco_corpo.gd` passou headless/OpenGL, zero falhas/exit 0; mesma âncora/pai, exclusão da montagem anterior, comprimentos, nova guarda, geometria/UV da pele, transformações do corpo/distante, comparação A e 12 quadros estáveis. OpenGL: 14 amostras opacas do ombro/juntas/mão, não todos os pixels. Regressões braco_reconstruido e acabamento_proximo passaram headless, zero falhas/exit 0. Captura OpenGL exit 0, quatro PNGs em `docs/evidencias_vega_braco_corpo_01/`; guarda/detalhe finais inspecionados, anterior/marcos também inspecionados antes do ajuste de enquadramento que separou botas e rodapé. Testes/captura finais sem stderr; importação exit 0 mantém avisos conhecidos de recursos/RID/fontes/ObjectDB do editor ao encerrar.

Sem novo movimento, segundo lado, expansão por Combo nas novas peças, integração com cartas ou suíte completa. `git diff --check` passou. Arquivos, hipótese/limites e exercício de mudar o ângulo em 5° no Inspector em `braco_reconstruido/ENCAIXE_CORPO.md`. Avaliar encaixe antes de adaptar animações; aprovação da arte anterior não é aprovação automática desta guarda corporal.

## Vega: retorno favorável ao braço; guarda ainda estranha — 22/10/2026

Relato do usuário sobre a reconstrução 01: “a guarda parece estar esquisita, mas esse braço parece ótimo”. Preservar a nova arte como direção visual bem recebida; não registrar aprovação da guarda, integração corporal ou animação. Inspecionados `montagem.png` da prova e a mestre `vega_guarda_unificada_01.png`; lidos script de registro, prévia e ângulos anteriores. Godot confirmada 4.7.2.stable.official.ed1daf0bf. Observado: guarda estática usa ombro 105°, cotovelo −160° e punho 0°, herdados da prova anterior; o novo volume deixa os segmentos visualmente muito próximos/sobrepostos na dobra. Hipótese: reutilizar esses ângulos sem calibração corporal comprime a silhueta. A prancha isolada também não mostra a relação entre mão, rosto, peito e ombro; não atribuir todo o problema somente ao ângulo.

Nesta conversa, apenas inspeção e registro do retorno. Sem alterações em arte, ossos, poses, scripts, F5 ou novas execuções de testes/capturas. Próximo recorte recomendado: avaliar e calibrar a guarda com o braço no contexto do corpo, preservando desenho/comprimentos e movimento aprovado, antes de animar a nova montagem. Exercício disponível sem editar: F6/O na prova atual para comparar a dobra dos eixos com o volume pintado.

## Vega: primeira reconstrução de um braço, estática e isolada — 22/10/2026

Usuário autorizou seguir a reconstrução proposta. Nova prova `vega_animada/braco_reconstruido/preview.tscn` (F6), sem trocar F5 ou a variante anterior. Skill imagegen usada para gerar uma única pintura montada a partir das referências aprovadas; três segmentos Polygon2D derivados dessa mesma fonte com placas integradas à pintura. Centros aproximados de ombro/cotovelo/punho registrados por transformação uniforme nos comprimentos do rig anterior. Não reutiliza placas soltas, aros independentes ou preenchimentos da montagem rejeitada. Prancha mostra alinhamento neutro diagnóstico, guarda e extensão; O alterna eixos/marcos.

Observado nas duas capturas finais: placas acompanham a fibra e mão visível centrada no marco do punho; a leitura parece mais contínua nesses três enquadramentos, avaliação visual limitada, ainda sem aprovação do usuário. Mão calibrada uniformemente por seu próprio comprimento, não pela escala raster do antebraço. Novo brilho/material, proporção aparente e encaixe na pele do ombro ainda exigem avaliação. Não afirmar coerência completa com a Vega ou compatibilidade de todas as fases da animação.

Godot 4.7.2/fixed-fps 60: `test_braco_reconstruido.gd` passou headless e OpenGL, zero falhas/exit 0; compara três registros, centros em três poses, comprimentos/ângulos com a prova anterior e ordem de desenho. Nove amostras GPU de cotovelo/punho/interior da mão passaram, sem validar todos os pixels. Captura OpenGL exit 0, duas imagens inspecionadas em `docs/evidencias_vega_braco_reconstruido_01/`; teste/captura finais sem stderr. Corrigido durante a montagem z negativo que escondia mão sob fundo, com teste de ancestrais reais; corrigida propriedade inválida do mundo 2D no teste gráfico consultando documentação 4.7. Importação exit 0 mantém avisos conhecidos de recursos/RID/fontes/ObjectDB do editor ao encerrar.

Regressão `test_encaixes_nativo.tscn` headless/fixed-fps 60 também passou, zero falhas/exit 0. `git diff --check` passou. Sem suíte inteira, novo movimento, alteração de gameplay/Combo, segundo braço ou migração. Fonte, prompt integral, marcos, limites e exercício de escala no README da nova prova. Próximo recorte: avaliar esta montagem antes de assentar no ombro corporal e reutilizar os clipes aprovados; testes geométricos não equivalem a aprovação artística.

## Vega: montagem visual rejeitada; parar correções de cobertura — 22/10/2026

Usuário primeiro apontou mão recuada em relação ao centro do punho e depois ampliou o diagnóstico: juntas desalinhadas e placas espalhadas, conjunto não parece conectado. Não tratar como aprovação do acabamento ou apenas um vão restante. Observado: o rig tem hierarquia nativa, mas fibras, aros e três placas por antebraço usam recortes/transformações independentes. Os passes recentes preservavam essas posições e testavam estabilidade/cobertura, não demonstravam coerência anatômica/perspectiva da montagem. A cobertura de alfa aprovada não comprova encaixe artístico correto.

Antes do segundo relato foi experimentado registro da mão pelo centro opaco da ponta da fibra. Leitura dos quatro últimos pixels de altura encontrou centros próximos (762.46,445.22) e (760.61,445.30) nos atlas; mão tinha âncora (-8,0), enquanto marcos transformados indicavam aproximadamente (7.71,-14.15)/(8.81,-12.71) no espaço do punho na guarda. Candidato de deslocamento gerou 14 PNGs em `docs/evidencias_vega_maos_centradas_01/`, Godot 4.7.2/OpenGL exit 0, sem stderr. Não houve aprovação ou validação artística dessa tentativa.

Com o diagnóstico ampliado, removida somente essa tentativa de deslocamento ainda não entregue, restaurando scripts da prévia/diagnóstico ao estado anterior verificado; artes/evidências preservadas. Não empilhar mais preenchimentos ou promover o ajuste isolado como solução da montagem inteira. `test_acabamento_proximo` headless/fixed-fps 60 passou após restauração, zero falhas/exit 0; sem nova suíte/OpenGL do estado restaurado nesta conversa. `git diff --check` passou. Nenhum redesenho, alteração do rig/movimento aprovado ou troca de F5 realizado.

Próxima abordagem recomendada, ainda sem autorização específica: reconstruir um único braço como conjunto coerente por segmentos anatômicos, com placas pertencendo à superfície e centros de ombro/cotovelo/punho registrados no mesmo espaço. Validar montado na guarda e extensão antes de animar/adaptar o segundo lado, preservando a base funcional aceita. Definir com o usuário essa mudança de método antes de nova geração/implementação ampla; não alegar que mover a mão basta.

## Vega: recorte dos conectores e miolos das juntas — 22/10/2026

Usuário autorizou melhorar as juntas após diagnóstico da saliência. Na mesma variante F6: mangas dos punhos mais curtas, núcleo antigo oculto para não duplicar volume e máscara `interior_aro.gdshader` restringindo fibra à região escura do soquete, preservando borda/alfa/metal claro/acentos. Nos dois cotovelos, remendo retangular oculto e miolo oval mais contido sob o aro. Sem editar PNGs, redesenhar ombros, mover ossos/mãos/placas ou alterar clipes/tempos/Combo/reduzido. F5 e cenas-base anteriores; flag `refinar_juntas` permite comparar.

Verificação Godot 4.7.2/fixed-fps 60: montagem passou headless/OpenGL, integração com cartas/variante passou OpenGL, regressões combo/encaixes/apoio passaram headless, zero falhas/exit 0. GPU: 928 pontos dos punhos e 464 dos cotovelos, quatro clipes/29 instantes/Combo 0 e 10, zero falhas de cobertura. Máscara isolada: 55 pixels pintados, zero sobre transparência, acentos saturados ou metal claro no enquadramento testado. Isso não prova todos os pixels/instantes ou perspectiva 3D. Ombro/pele permanecem corretos nos testes anteriores. GL isolado sem avisos; main/capturas mantêm avisos conhecidos de recursos/RID/fontes/ObjectDB ao encerrar. Sem suíte completa, integração headless nova, benchmark ou vídeo.

54 PNGs em `docs/evidencias_vega_juntas_01/`; inspecionados fases distante .10/.28 e próximo .36, dois cotovelos, guarda ampliada 0, impacto distante 10 e guarda integrada 1920. Inspeção de 57 instantes por golpe preserva origem mão/miolo (desvio máximo 0.001043 px do atlas). Diagnóstico agora separa `--juntas`/linha de base sem refinamento em pastas distintas. Causas, limites/testes e exercício de alternar `refinar_juntas` em `acabamento_proximo/JUNTAS.md`. Avaliação artística ainda pendente; `git diff --check` passou.

## Vega: inspeção da saliência dos soquetes, sem nova correção — 22/10/2026

Usuário relatou melhora, mas não consegue dizer se alguma peça ainda sai do encaixe. Não registrar como aprovação final. Inspeção diagnóstica isolada `tests/inspecionar_soquetes.gd`, Godot 4.7.2/OpenGL/fixed-fps 60: 57 instantes por golpe, ambos os lados, Combo 10; origem do miolo relativa à mão variou no máximo 0.001043 px no espaço do atlas (erro numérico desprezível, não deslocamento visível). Gerados 14 PNGs ampliados em `docs/evidencias_vega_soquetes_inspecao_01/`, exit 0, sem mensagens no stderr; examinados preparo distante .10, retorno distante .28/.46 e próximo .36. Não observada separação temporal da mão nessas capturas, mas ainda há pequena saliência/volume aparente do conector sob o aro e trecho lateral exposto. Isso pode sustentar a sensação de peça solta mesmo com vínculo estável ao osso; é avaliação visual, não classificação automática de todos os pixels.

Nenhum ajuste em arte, apresentação ativa, clipes, geometria, filtros ou regras nesta inspeção. Só script diagnóstico/capturas e registro. Não executada nova suíte ou revisão de vídeo; não extrapolar a origem relativa estável para encaixe/perspectiva perfeita. Próximo ajuste sugerido, ainda não executado: limitar acabamento do conector ao contorno interno do aro e manter somente a sobreposição necessária ao antebraço, sem reabrir animação aprovada. Para comparar, abrir o PNG `soco_distante_028.png` da pasta nova e o de guarda .000. `git diff --check` passou.

## Vega: movimento aprovado; continuidade dos soquetes — 22/10/2026

Relato do usuário: movimentação “legitimamente muito boa”, mas peças não se conectam bem e há buraco no punho, pior no distante. Capturas mostram a boca do aro. Registrada aprovação do movimento atual, não da arte completa. Observado no atlas: cavidade escura é pintura opaca; núcleo antigo atrás do sprite não a fecha. Hipótese de união por conector sob o aro/miolo na abertura aplicada na mesma variante F6, sem mover mãos/ossos, mudar escala, clipes/tempos, proporções ou Combo. F5 e provas anteriores preservados.

`vega_prova.gd` acrescenta dois Polygon2D estáticos por punho com fibras dos atlas existentes; flag `fechar_punhos` permite comparar. Sem novos PNGs/shaders, animação adicional ou compensação por frame. Primeira manga exposta foi corrigida na sobreposição. Teste encontrou duas amostras UV em área transparente; corrigido o mapeamento para dentro do feixe, mantendo a asserção.

Verificação real Godot 4.7.2/fixed-fps 60: montagem e integração de cartas passaram headless/OpenGL, zero falhas/exit 0; combo/encaixes/apoio nativos passaram headless. Teste GPU acrescentado: 928 leituras em dois pontos por punho durante quatro clipes, 29 instantes, Combo 0/10; zero falhas de cobertura. Amostragem alfa não prova todo acabamento (a cavidade pintada já era opaca); capturas/avaliação visual continuam necessárias. Ombro mantém 933 pixels/zero fora; punho/pele zero nos cinco instantes de guarda. Teste isolado GL final sem avisos; main/capturas mantêm avisos anteriores de recursos/RID/fontes/ObjectDB ao encerrar. Sem vídeo ou suíte completa.

40 PNGs em `docs/evidencias_vega_soquetes_01/`; inspecionados guarda, impactos dos dois lados, zooms dos aros e detalhe integrado 1920. Detalhes/limites e exercício de alternar `fechar_punhos` em `acabamento_proximo/SOQUETES.md`. Avaliação artística da nova união ainda pendente. `git diff --check` passou.

## Vega: pose aprovada; recorte do bíceps e redução das texturas — 22/10/2026

Relato do usuário: “agora sim ela está uma pose boa”, com ressalvas de bíceps distante cortado e serrilhado. Registrada aprovação da pose, não conclusão da arte/animação inteira. Observado: novo atlas ultrapassava o retângulo antigo do bíceps (106 pixels opacos na borda direita); texturas da personagem sem mipmaps e filtros lineares simples. Não encontrada redução extra do SubViewport; sem auditoria de toda a arena/HUD.

Na mesma prévia F6, ampliada apenas a borda da malha/UV distante (12 px horizontal/8 vertical), preservando interior/pivôs/ossos/pose/deltas. Recorte agora tem margem transparente, zero pixels opacos nas bordas. Importação dos cinco PNGs usados passa a gerar mipmaps; modelo e ambas raízes dos braços usam linear com mipmaps, flag `suavizar_texturas` para comparar. Sem editar PNGs, regenerar arte, mudar renderer ou aplicar desfoque global. F5 mantém filtros anteriores. MSAA 2D foi testado, runtime GL informou falta de suporte e a tentativa foi removida; não é parte da correção final.

Verificação Godot 4.7.2/fixed-fps 60: montagem passou headless/OpenGL, integração de cartas com variante passou headless/OpenGL, combo/encaixes/apoio nativos passaram headless, zero falhas/exit 0. GPU ombro 933 pixels após filtragem, zero fora da pele; punho distante sem sobreposição nos cinco instantes da guarda. Importação/capturas exit 0. Teste isolado GL final sem avisos; main/editor/capturas continuam com avisos anteriores de recursos/RID/fontes/ObjectDB ao encerrar. Sem suíte completa, benchmark ou vídeo.

40 PNGs em `docs/evidencias_vega_recorte_filtro_01/`; inspecionados A/B da filtragem no mesmo enquadramento, guarda/impacto distante ampliados e guarda integrada 1024. Menos granulação, aparência mais suave; nitidez final e leitura do bíceps ainda a avaliar pelo usuário. Causas, limites, fontes oficiais e exercício de alternar a flag em `acabamento_proximo/RECORTE_E_FILTRO.md`. `git diff --check` passou.

## Vega: dedão recolhido no dorso da mão próxima — 22/10/2026

Relato adicional durante o passe: um dedão saltava para cima quando deveria ficar para dentro. Adotada/comunicada a leitura de que se trata da mão próxima com placa dorsal, ainda sem confirmação explícita do lado pelo usuário. Imagegen embutido gerou `punhos_pareados_02.png`; só o recorte dorsal novo é aplicado. Polegar antes exposto agora fica oculto pelo fechamento dos dedos nessa vista. Palma distante continua exatamente na textura 01; nada muda em ossos, soquetes, escala ou clipes. F6 da mesma prévia atualizado, F5 anterior. Arte/arquivo original preservados; prompt e proveniência em `acabamento_proximo/DEDAO.md`.

Verificação após a edição: importação exit 0; montagem `test_acabamento_proximo` OpenGL/fixed-fps 60 passou sem falhas/avisos no teste isolado, integração de cartas `test_vega_nativa_combate -- --acabamento` headless passou. Permanecem avisos de recursos ao encerrar main. Seis PNGs ampliados novos em `docs/evidencias_vega_face_interna_02/`; inspecionados guarda Combo 0 e impacto próximo Combo 10. Integração OpenGL completa executada antes desta correção de textura, não repetida depois. Sem revisão de vídeo, aprovação artística ou confirmação do lado por teste. Exercício de comparação de contorno descrito na nota do dedão.

## Vega: coerência do braço distante e folga do punho — 22/10/2026

Relato do usuário: mãos diferentes, punho distante entrando no ombro e suspeita de peças voltadas ao contrário. Observado no código/capturas: só a mão possuía vista palmar; demais peças distantes repetiam atlas externo espelhado, acabamento e escurecimento diferentes. Não confirmado que todos os ossos estivessem invertidos. Corrigida a mesma variante F6 em `rig_nativo_v2/acabamento_proximo/preview.tscn`; F5/main e provas anteriores preservados.

Gerados por imagegen embutido `camadas_internas_01.png` e `punhos_pareados_01.png`, ambos 1774×887 RGBA, originais preservados. Face interna em malhas/placas/juntas/núcleos distantes, punhos dorso/palma com escala/acabamento comuns e soquetes registrados; sem refletir novamente os eixos. Cotovelo distante abre 23° na guarda, preparo/retorno e reação; extensão do soco, demais ossos/comprimentos, tempos, apoio e Combo não mudam. Respiração duplicada antes da edição privada. Tom distante menos escurecido. Hipótese de melhora da leitura sustentada por capturas, ainda sem aprovação artística; vistas fixas não equivalem a giro 3D. A ressalva do usuário mostra que os testes anteriores de preservação matemática não bastavam para provar perspectiva/folga.

Verificação real Godot 4.7.2: `test_acabamento_proximo` headless/OpenGL fixed-fps 60, zero falhas/exit 0; agora compara poses com exceção explícita somente da dobra distante e verifica os dois atlas, encaixes, recursos, expansão, alternância/reduzido/reset. GPU: 922 pixels de pintura no ombro, zero fora do corpo; punho distante isolado com zero pixels sobrepostos à pele nas cinco posições amostradas da respiração. Distância ao ombro também amostrada em 57 pontos por ação. Integração `test_vega_nativa_combate -- --acabamento` passou headless/OpenGL; padrão e combo/encaixes/apoio nativos passaram headless. Importação exit 0. Teste isolado OpenGL sem avisos; main/editor/capturas mantêm avisos de recursos/RID/fontes/ObjectDB ao encerrar, não corrigidos. Sem suíte completa nem revisão de vídeo.

38 PNGs em `docs/evidencias_vega_face_interna_01/`: 32 capturas integradas em duas resoluções e seis ampliadas guarda/impactos Combo 0/10. Inspecionadas guarda e dois impactos 1920, guarda 1024, ampliadas guarda 0 e impacto distante 10. Aplicação, limites, proveniência/prompts integrais e exercício de comparação pela flag `corrigir_braco_distante` em `acabamento_proximo/FACE_INTERNA.md`. Avaliar manualmente os dois lados na mesma prévia F6 antes de migrar ao F5.

## Vega: primeira derivação de acabamento no rig — 22/10/2026

Usuário autorizou adaptar primeiro ombro/braço próximo após aprovação da guarda unificada. Criada variante separada `rig_nativo_v2/acabamento_proximo/vega_prova.tscn/.gd` e preview F6 que abre cópia do combate com essa apresentação; F5/main permanecem anteriores. `camadas_01.png` (1774×887 RGBA/alfa conferido) foi gerado por imagegen embutido, atlas antigo como alvo e mestre aprovada como referência, copiado sem editar pixels. Prompt integral/proveniência/limites e exercício no README da nova pasta.

Variante troca atlas/UV das duas malhas do braço próximo, placas/junta e núcleos; geometria/bases/deltas de Combo, ossos, poses e recursos originais preservados. Pintura local do ombro usa faces da mesma pele com pesos nativos e máscara de alfa/cor original, sem atualizador por frame. Primeira captura ampliava indevidamente o deltoide; corrigida a aplicação para manter contorno existente, sem alterar anatomia. Braço distante, corpo-base e texturas das mãos não foram repintados; só fibras de fechamento da mão próxima acompanham atlas. É passe localizado, não personagem inteiro já coerente ou cópia pixel a pixel da mestre. Aprovação visual dessa derivação ainda pendente.

Verificação real Godot 4.7.2: novo `test_acabamento_proximo` passou headless/OpenGL fixed-fps 60, zero falhas/exit 0, sem avisos no teste isolado. Compara ossos/poses/comprimentos em 57 amostras de respiração/dois golpes/dano e Combo 0/10, preservação de malhas/perfis, pesos, mãos e recursos; alternância/reduzido/reset. Checagem GPU: 922 pixels de pintura, zero fora da silhueta corporal original. Integração `test_vega_nativa_combate -- --acabamento` passou headless/OpenGL; integração padrão e combo_nativo/encaixes_nativo/apoio_corporal passaram headless fixed-fps 60. Preview lançado por cinco frames iniciou combate/exit 0. Importação exit 0; sem suíte completa. Main/editor/capturas ainda emitem avisos anteriores de recursos/RID/fontes/ObjectDB ao encerrar. `git diff --check` passou.

32 PNGs em `docs/evidencias_vega_acabamento_proximo_01/`; inspecionados detalhes guarda/impacto/dois lados 1920 e guarda 1024. Vídeo `ciclo_proximo.avi` gerado com cartas reais, 133 frames/30 FPS/1152×648, exit 0, não assistido integralmente. Conferir F6 em `acabamento_proximo/preview.tscn`, observando ombro e fibras na guarda/extensão. Só depois decidir aplicação ativa e adaptação do restante; nenhuma troca global realizada.

## Vega: candidata de guarda unificada aprovada — 22/10/2026

Relato do usuário após apresentação da candidata 01 e prova no cenário: “parece ótima”. Registrada aprovação artística dessa referência estática. Preservar `docs/arte_vega/vega_guarda_unificada_01.png` como mestre visual do próximo passe; não implica aprovação de animação, compatibilidade com âncoras ou troca já realizada na personagem ativa.

Neste retorno foram atualizados somente os registros; nenhuma arte, código ou cena alterada e nenhum novo teste de runtime executado. `git diff --check` dos documentos passou. Próximo recorte recomendado: derivar e conferir primeiro o conjunto ombro/braço próximo sob esse acabamento, preservando o rig funcional e avaliando guarda/extensão antes de replicar o processo. Não tentar recortar a figura inteira e prometer encaixe automático.

## Vega: primeira candidata de guarda com acabamento unificado — 22/10/2026

Usuário autorizou começar o passe visual proposto; isso aprova o método inicial, não a imagem produzida. Gerada `docs/arte_vega/vega_guarda_unificada_01.png`, 1117×1408 RGBA, ferramenta embutida/skill imagegen, com alvo na guarda montada atual e referências de identidade 04/vista palmar. Uma figura completa em guarda para avaliar corpo, próteses, mãos e ombros como um único desenho, preservando identidade/figurino/conceito. Original e todas as artes anteriores preservados; prompt integral e limites em `docs/arte_vega/vega_guarda_unificada_01.md`.

Inspeção visual: mantém cabelo/expressão geral, roupa, duas mãos altas, palma distante e botas; pintura dos ombros/próteses ocorre no contexto do torso. Ainda há concentração de detalhe/brilho nos braços. Não aferida equivalência de âncoras/proporções com o rig, nem identidade pixel a pixel; não é textura pronta para substituir peças. A candidata não está aplicada no jogo e ainda aguarda aprovação artística. Rig, clipes, shaders, HUD, main e regras não foram alterados.

Verificação executada: novo capturador estático isolado `tests/capturar_vega_unificada.gd` na Godot 4.7.2/OpenGL, exit 0, quatro PNGs salvos OK em `docs/evidencias_vega_unificada_01/` (atual/candidata em duas resoluções). Alturas registradas 378.5 px em 1920×1080 e 211.2 px em 1024×576; alfa do canto zero. Candidatas de contexto inspecionadas, figura inteira no plano de chão/sem sobrepor HUD. Capturador troca apenas a apresentação da sua instância para foto, sem persistir substituição ou configuração do usuário. Sem testes de gameplay, vídeo ou validação de movimento; persistem avisos anteriores de recursos/RID/fontes/ObjectDB ao encerrar main. `git diff --check` passou.

Próximo passo depende do retorno artístico: comparar ombro/pele/prótese e níveis de detalhe/luz no tamanho real. Só depois derivar acabamento para peças do rig, sem converter o PNG inteiro em personagem animado final. Exercício de comparação a 100% descrito na nota da candidata.

## Vega: base funcional aceita, coerência artística como próximo foco — 22/10/2026

Relato do usuário após alternância/vista palmar: “agora tá funcional”; braços ainda parados/estranhos, mas fazem sentido. Problema prioritário apontado: corpo parece adesivo com braços animados e não combina artisticamente com as próteses. Aceitação funcional não equivale a aprovação visual final.

Inspeção nesta conversa: scripts/cenas atuais, captura de guarda integrada, atlas ativo `combate_v2/base_e_punhos_01.png`, atlas das próteses `braco_v2/camadas.png` e referência aprovada 04. Corpo-base anterior `corpo_v2/corpo_base_01.png` também visto para comparação, mas não é a textura corporal ativa. Corpo atual já tem skinning por Skeleton2D; não é literalmente PNG imóvel. Captura/fontes mostram corpo com sombras amplas/mates e próteses com detalhe/brilho mais concentrados; ombros/rings separados enfatizam recorte. Anatomia/ombros participam com amplitudes pequenas, e a textura pintada conserva sua iluminação/perspectiva durante a deformação. Hipótese: diferença de acabamento, transição do ombro e pequena participação corporal somam-se ao efeito de colagem; não foi medido peso relativo de cada fator.

Recomendação ainda não executada: passe visual unificado da Vega inteira em guarda, preservando identidade/figurino e linguagem aprovada das próteses, com mesma luz/contorno/sombras e integração ombro-pele-tecido. Validar estático no tamanho real antes de derivar texturas compatíveis com âncoras/rig existente; movimento secundário de tronco/roupa/cabelo em etapa posterior. Sem nova imagem, mudança de código/cenas/material ou teste de runtime neste retorno; somente leitura/inspeção e registros. Não afirmar que pintura/shader sozinho resolve perspectiva ou movimento. Rig e alternância atuais preservados.

## Vega: vista palmar distante e alternância de golpes — 22/10/2026

Relato do usuário: apresentação ficou jogável; as duas mãos mostram a mesma face e a mão do fundo deve apresentar a palma. Pedido adicional: intercalar braços ao atacar. Observado: ambos os Sprites usavam a mesma vista do atlas e só o braço próximo tinha golpe de extensão. Recorte: arte palmar específica + segundo clipe de ataque, preservando guarda viva/apoio e gameplay.

`rig_nativo_v2/vega_combate.gd` escolhe próximo/distante por ataque válido, com reset no mapa/nova run; defesa/inválida não consomem sequência. `soco_distante.tres` usa mesmo ciclo 560 ms e posições inferiores, rotações compensadas para a prótese espelhada, braço próximo protegendo o rosto. Captura 100 ms da pose atual, retorno à guarda viva e reduzido mantidos. API externa de soco não mudou; nenhuma regra/main alterada. Arte `mao_palmar_01.png` gerada com ferramenta embutida/skill imagegen e copiada sem edição de pixels, 1254×1254 RGBA/transparência conferida. Mão distante usa essa vista, ajuste uniforme de escala/offset por ter outro tamanho de textura, mesmo acabamento tonal; mão próxima e provas históricas intactas. Não é espelhar o dorso nem rotação 3D da mão. Naturalidade da arte/segundo golpe ainda depende do usuário. Prompt integral, proveniência e exercício em `rig_nativo_v2/PALMA_E_ALTERNANCIA.md`; skill animate orientou interrupção/retorno/reduzido.

Verificação Godot 4.7.2: integração passou headless/OpenGL, zero falhas/exit 0, incluindo quatro golpes alternados, defesa/inválida, cartas reais/custo/dano/Combo, interrupção entre braços e por dano, retorno, reduzido/reset, transparência, dois layouts, proporções/apoios em 57 amostras por golpe. Primeira execução falhou só na asserção antiga que exigia a transformação da mão espelhada anterior; substituída pela verificação da vista palmar pedida, sem remover proteções de tamanho/assentamento do lado próximo ou de recursos isolados. Regressões apoio_corporal, encaixes_nativo e polimento_combate passaram headless. Combo_nativo falhou duas vezes sem FPS fixo em “ganho percorre valores intermediarios”, timer 80 ms; passou com `--fixed-fps 60`. Nenhum teste/regra de Combo alterado para contornar. Sem suíte completa. Importação retornou 0. Persistem avisos de recursos/RID/fontes/ObjectDB ao encerrar main/editor. `git diff --check` passou.

32 PNGs em `docs/evidencias_vega_alternancia_22/`, inspecionados guarda/detalhe e impacto distante 1920 e impacto 1024. Mão inicialmente ficou pequena, ajustada à leitura da mão próxima e recapturada. Vídeo `alternancia.avi` gerado com cartas reais, 133 frames/30 FPS/1152×648, exit 0; não assistido integralmente. Evidências anteriores preservadas. Avaliação pendente em F5: observar face palmar na guarda e jogar ataque → defesa → ataque; último deve usar o outro braço. “Jogável” é relato do usuário sobre a etapa anterior, não aprovação automática da entrega nova.

## Vega: guarda de luta com respiração entre ações — 22/10/2026

Relato do usuário: braços baixos pioraram muito; quer postura de golpeadora durante a espera, com respiro para não ficar travada. Direção anterior de relaxamento foi rejeitada, não aprovada. Regra vigente: espera em guarda, independentemente de Combo. Escolha de apresentação: reaproveitar as onze rotações da guarda nativa já existente, sem recalibrar comprimentos ou inventar outra anatomia. Prévia continua preservada; só a apresentação ativa muda.

`respirar.tres` agora mantém mãos altas num ciclo de 2.4 s, cinco chaves com interpolação cúbica: tronco vai de 1° a 2.5°, pequenas rotações coordenadas de clavículas/deltoides/braços dão respiro sem oscilar o personagem inteiro. Pelve/joelhos/apoios permanecem fixos na espera. `vega_combate.gd` aplica as onze rotações superiores de base aos extremos dos clipes privados; preparo/impacto/guarda, tempos e trilhas inferiores do soco permanecem intactos. Golpe/dano retornam à guarda; reduzido mantém guarda estática e feedback cromático. Nomes internos “repouso” continuam significando espera, não braços baixos. Shader das mãos, proporções e regras não mudaram neste turno. Skill `animate` orientou ciclo contínuo, finalidade de prontidão e captura existente de 160 ms sem segundo escritor de ossos.

Verificação real Godot 4.7.2: integração headless/OpenGL passou, zero falhas/exit 0. Testes antigos primeiro falharam em 14 asserções da postura rejeitada; substituídos explicitamente pelos requisitos novos, mantendo proteção das chaves intermediárias/tempos, materiais, recursos isolados, cartas/Combo, interrupção/reduzido/reset e camadas. Novas verificações: base igual à guarda nativa, mãos altas em 49 amostras, deslocamento perceptível e inferior a 9 px locais, apoio fixo, ciclo fechando sem salto. Quatro regressões headless passaram/exit 0: apoio_corporal, combo_nativo, encaixes_nativo e polimento_combate. Sem suíte completa. `git diff --check` passou. Persistem avisos anteriores de RID/texturas/fontes/ObjectDB/recursos ao encerrar main.

Capturador `--guarda-viva`: 34 PNGs em `docs/evidencias_vega_guarda_viva_22/`, sem sobrescrever evidências da proposta rejeitada; exit 0. Inspecionados detalhes da guarda no início/pico, impacto 1920 e espera/retorno 1024: mãos altas, corpo visível e pés apoiados. Vídeo `guarda_e_cartas.avi` gerado em 1152×648, 317 frames/30 FPS, exit 0, incluindo espera de um ciclo antes/depois das cartas; não assistido integralmente. Avaliação artística/manual continua com o usuário no F5. Exercício opcional: comparar MOVIMENTO SUAVE/REDUZIDO; guarda deve permanecer igual e só o respiro parar. Não tratada a diferença de traço/perspectiva das mãos nesta etapa.

## Vega: repouso relaxado e acabamento tonal das mãos — 22/10/2026

Relato do usuário sobre o combate integrado: animação em geral “decente” e “bem melhor”, porém repouso bizarro e contraste evidenciando mãos como peças distintas. Observado na captura anterior: antebraço próximo cruzava cintura, punhos projetados para frente; atlas das mãos tem metal mais claro que as fibras. Regra preservada: relaxar entre ações, sem alongar membros/mudar mãos, nem vincular postura ao Combo. Hipótese artística: reduzir flexão e orientar os punhos para baixo melhora repouso; escurecer seletivamente os claros neutros aproxima os materiais. Não é aprovação final da anatomia/arte.

Mudança limitada à apresentação ativa: `respirar.tres` define ombro/cotovelo próximo 115°/−30° e distante 130°/−5°. `vega_combate.gd` propaga essas quatro rotações somente às extremidades de repouso/RESET/soco/dano em biblioteca duplicada. Preparação, impacto, guarda, tempos e demais chaves permanecem iguais; prévias continuam intactas. Reduzido/reset usam a mesma postura; sem segundo escritor de ossos. Skill `animate` orientou continuidade do retorno com captura cubic in-out existente (160 ms), sem novo balanço ou duração. Primeira captura ocultava a mão distante atrás da coxa; ângulo do braço distante corrigido e conferido novamente.

`metal_maos.gdshader`, aplicado somente aos dois Sprites de mão da instância de combate, reduz claros neutros com matiz grafite fria (0.68/0.72/0.80). Alfa e acentos saturados preservados pela máscara; fibras/miolo não são tingidos. Não altera textura, UVs, escala, orientação/assentamento ou o desenho. Correção tonal não resolve diferenças de perspectiva, traço e recorte entre os atlases; eventual redesenho segue fora deste ajuste. Nenhuma nova arte raster, mudança de HUD/gameplay ou plugin instalado.

Verificação real na Godot 4.7.2: `test_vega_nativa_combate` passou headless e OpenGL, zero falhas/exit 0. Novas asserções protegem coerência dos extremos, preservação de todas as outras chaves/tempos do soco, faixa dos punhos, material isolado, orientação/tamanho das mãos e prévia intacta; existentes cobrem Combo/cartas/dano/reduzido/reset/camadas. Regressões headless `test_apoio_corporal`, `test_combo_nativo`, `test_encaixes_nativo`, `test_polimento_combate` passaram, zero falhas/exit 0. Capturador passou/exit 0: 22 PNGs em `docs/evidencias_vega_repouso_22/`, sem sobrescrever evidências anteriores. Inspecionados detalhe de repouso e impacto em 1920 e repouso no jogo em 1024: mãos visíveis, repouso mais vertical e claros menos destacados. Não criado/assistido novo vídeo, nem executada suíte completa. Persistem avisos de recursos/RID/fontes/ObjectDB no encerramento de main; não foram resolvidos. `git diff --check` passou.

Avaliação manual pendente: F5, observar postura antes/depois do ataque e no modo reduzido. O relato aprovou a melhora geral da animação, não a correção agora entregue. Exercício opcional e limites em `rig_nativo_v2/COMBATE.md`.

## Vega nativa no combate real — 21/10/2026

Relato do usuário sobre o apoio corporal: “ótimo, podemos continuar agora, ficou interessante”. Continuação adotada e anunciada nesta conversa: ligar essa montagem ao combate, preservando as prévias. Isso não é aprovação artística final do Combo ou de todas as poses.

`main.gd` agora instancia por padrão `rig_nativo_v2/vega_combate.tscn`. Adaptador tipado mantém a API de apresentação, recebe Combo real, dispara o soco nativo e reação ao dano, interrompe pela pose atual e para/resetta no mapa/nova run. Regras continuam imediatas, sem aguardar animações. Biblioteca de animações é duplicada por instância para não contaminar as provas. Novos recursos editáveis `respirar.tres` (tronco ± postura base, excursão de 0.25°, botas/pelve fixas) e `dano.tres` (recuo curto de 260 ms); reduzido usa confirmação cromática, sem articulação ampla. Skill `animate` orientou captura/interrupções, retorno ao repouso e redução de movimento; não foi introduzido solver ou nova biblioteca externa.

Teste OpenGL encontrou falha de profundidade com CanvasGroup: índices internos ultrapassavam UI. Tentativa de baixar o índice passou no teste de oclusão, mas a captura mostrou corpo oculto; descartada. Solução vigente: SubViewport transparente, dimensionado pelo container, isolando os índices do rig, sem input e com margem de 64 px. Teste agora exige também corpo visível, além de UI acima. Contatos usam ColorRect com UV integral no shader existente, eliminando retângulos da sombra herdada de Panel. Sem alteração de proporções, raster, HUD, regras ou arenas.

Verificação real Godot 4.7.2: `test_vega_nativa_combate` passou headless e OpenGL, zero falhas/exit 0; checa padrão ativo, recursos não compartilhados, Combo 0/1/5/10/11/100, interrupção, dano, reduzido, mapa/reset, cartas reais (duas Direto Hidráulico e Quebra-chassi), custos/dano/consumo inalterados e composição em 1920×1080/1024×576. Oito regressões headless passaram/exit 0: apoio_corporal, combo_nativo, encaixes_nativo, vega_combate_v2, vega_playtest, polimento_combate, composicao_combate e jogo_fluxo. Os dois testes específicos do modelo anterior agora injetam explicitamente a cena antiga, sem remover suas asserções; não provam a integração nova. Capturador/verificador antigos também explicitam essa fixture. Não executada suíte completa.

Dezoito PNGs salvos OK em `docs/evidencias_vega_nativa_combate/`; inspecionados repouso/soco 1920, dano/configurações 1024. Personagem inteiro visível, botas no piso e overlay acima. Vídeo `ciclo_combate.avi` gerado com cartas reais, 133 frames/30 FPS, exit 0; gerado para avaliação, não assistido integralmente. Testes de main/capturas ainda emitem avisos de texturas/RID/fontes/ObjectDB/recursos ao encerrar, como antes; não são execução limpa nem problema resolvido nesta etapa. `git diff --check` passou. Falha intermediária no teste: conversão com `to_global` de Control inválida, corrigida para `get_global_transform() * ponto`.

Conferência manual pendente: F5, iniciar run/combate, jogar ataque, acumular e consumir Combo, receber dano e repetir no modo reduzido. Retrato/cartas/arenas continuam no estado anterior; não se afirma consistência artística final. Detalhes e exercício pequeno em `rig_nativo_v2/COMBATE.md`.

## Rig nativo: transferência de peso com botas apoiadas — 21/10/2026

Relato do usuário: parte inferior não ajuda o movimento e talvez precise participar. Observado: na prova anterior, toda a região abaixo da cintura pertencia à pelve fixa. Recorte adotado: nova `rig_nativo_v2/preview_apoio.tscn`, preservando as provas aprovadas e a de Combo. Hipótese artística em avaliação: recuo/flexão no preparo, avanço curto de quadril no impacto e recuperação dão apoio ao golpe sem precisar de passo ou calcanhar levantado.

`apoio_corporal.tscn/.gd` mantém as onze trilhas anteriores e acrescenta três de posição para Pelve/JoelhoTras/JoelhoFrente, no mesmo AnimationPlayer. Nove ossos corporais/pesos; Apoios é fixo e independente da pelve. Pele refinada para 1520 vértices/1443 faces, pesos normalizados com até quatro influências, botas y≥680 exclusivamente no apoio fixo. Quadril desloca (−4,+5) no preparo, (+8,+2) no impacto e volta ao repouso; joelhos participam poucos pixels. Tronco/braços seguem a pelve, sem alterar proporções/encaixes ou chaves locais das mãos. Não é solver IK nem reconstrução anatômica 3D das pernas: malha de roupa recebe deslocamentos pequenos pelos pesos nativos.

Mudança deliberada da restrição anterior: nesta variante a pelve pode mover; solas/botas continuam presas ao chão. Não enfraquecidos os testes que protegem a prova anterior com pelve fixa. Combo continua independente da pose/apoio. Movimento reduzido restaura a postura e interrupção captura a posição corporal atual. Skill `animate` orientou continuidade física/feedback, preservando ciclo 100/100/160/200 ms e captura cubic in-out nativa; sem balanço infinito em repouso ou novo efeito baseado no contador.

Verificação real Godot 4.7.2: `test_apoio_corporal` passou headless/OpenGL fixed-fps 60, zero falhas/exit 0. Confere nove pesos/registro, botas fixas em 57 amostras de skinning (não só marcadores), faces sem inversão, encaixes, alcance relativo/transform das mãos preservados, deslocamento limitado, independência de Combo, interrupção/reduzido e enquadramento dos apoios. Regressões `test_combo_nativo`, `test_dois_bracos_nativo` e `test_encaixes_nativo` passaram headless, zero falhas/exit 0; todos esses testes e capturador encerraram sem avisos. Importação inicial e lançamento curto retornaram 0 sem erro de parsing; editor manteve avisos anteriores de recursos/RID/objetos ao encerrar. Sem suíte completa ou execução do combate.

Doze capturas OpenGL em `docs/evidencias_apoio_corporal/`, repouso/preparo/impacto/retorno/guarda e impacto com apoios em duas resoluções. Inspecionadas repouso/preparo/impacto 1920 e apoios 1024: movimento discreto de quadril/calça com botas visualmente estáveis. Direita é detalhe inferior com enquadramento fixo, corta tronco/braços intencionalmente; esquerda mostra corpo inteiro. Vídeo `ciclo_apoio.avi`: log confirma 128 frames/30 FPS/1152×648, exit 0/stderr vazio, para avaliação do usuário. Sem arte raster, alteração de gameplay/HUD/main ou migração ao personagem ativo. A prova de Combo anterior ainda não recebeu aprovação artística explícita. Conferir com F6 em `preview_apoio.tscn`; exercício opcional e detalhes em `rig_nativo_v2/APOIO_CORPORAL.md`.

## Rig nativo: prova de tensão por Combo sem alongar os braços — 21/10/2026

Relato/autorização: usuário aceitou experimentar Combo, com receio explícito de desproporção. Criadas `rig_nativo_v2/combo_nativo.tscn/.gd` e `preview_combo.tscn/.gd`, separadas da montagem aprovada. Observado: mesma cadeia de ossos, mãos orientadas/assentadas e encaixes; quatro superfícies visuais recebem deformação transversal local. Regra preservada: 1 carga = 10 pontos percentuais do percurso de tensão, máximo visual em 10; contador não recebe teto mecânico. Não significa 10% de aumento do braço inteiro.

Reaproveitados da prova original `tensao_por_combo`, curva cubic-bezier(0.77,0,0.175,1), duração de 200 ms e amplitudes de 0.18/0.14 para bíceps/antebraço. Malhas reproduzem recortes existentes em zero, mantendo UVs. Comprimento/posição/escala de ossos não mudam; perfil termina em zero nas juntas, com placa superior e margem de 16 pixels no atlas presas, maior que a diagonal das células (~12 px). Placas do antebraço, mãos e núcleos não recebem deformação. Somente Tween de tensão escreve essas malhas; AnimationPlayer continua dono da pose. Reduzido resolve destino imediatamente, consumo interrompe do estado atual. Skill `animate` orientou indicação de estado, interrupção e reutilização dos tempos, sem pulsação ou nova biblioteca.

Primeira execução revelou erro de parsing: PackedVector2Array construído como constante não era expressão constante aceita; trocado por Array[Vector2] literal. Execução seguinte sem erro. Importação inicial do editor retornou 0, mantendo avisos anteriores de recursos/RID/objetos ao encerrar; não bastou para revelar esse erro, que foi encontrado ao executar a cena.

Verificação real Godot 4.7.2: `test_combo_nativo` passou headless e OpenGL fixed-fps 60, zero falhas/exit 0. Confere dez passos e saturação inclusive int máximo, quatro malhas, extremos e placa presos, deslocamento só transversal/limitado, faces sem inversão, rigidez de mãos/juntas/placas, 57 amostras de pose comparadas à montagem anterior, zeragem exata, interrupção/reduzido e controles nas duas resoluções. Regressões `test_encaixes_nativo`, `test_dois_bracos_nativo` e `test_braco_v2_combo` passaram headless, zero falhas/exit 0, sem avisos de recursos nesses testes. Sem suíte completa ou execução do combate.

Dezesseis capturas OpenGL salvas OK em `docs/evidencias_combo_nativo/`, guarda/extensão em 0/1/5/10 e 1920×1080/1024×576. Inspecionadas guarda 0/10 em 1920 e extensão 10 em 1024: variação discreta, sem mudança observada de mãos/alcance; não equivale à aprovação artística do usuário. Vídeo `ciclo_combo.avi`: log confirma 134 frames/30 FPS/1152×648, exit 0/stderr vazio, mostrando ganho, soco no máximo e consumo. Conferir com F6 na nova `preview_combo.tscn`, botões 0/5/10 e slider; prévias aprovadas/F5 continuam anteriores. Hipótese artística em avaliação: volume local limitado comunica tensão sem desproporção. Nenhuma regra, HUD, imagem raster ou personagem ativo alterado. Exercício opcional: reduzir `contracao_biceps` de 0.18 para 0.12 na cena ComboNativo e reexecutar a prova; comparar máximo, depois restaurar. Detalhes em `rig_nativo_v2/COMBO.md`.

## Rig nativo: orientação da mão aprovada pelo usuário — 21/10/2026

Relato após a correção: “perfeito, agora sim”. Registrada aprovação visual da orientação da mão distante nesta prévia; preservar a montagem atual. Não equivale a migração para o combate ou validação final de todas as animações.

Neste retorno foram atualizados apenas os registros, sem alterar código/cenas ou executar novos testes de runtime. Próximo recorte recomendado, ainda não implementado/autorizado neste retorno: expansão por Combo no rig nativo, mantendo encaixes e a regra já aprovada de 10 pontos percentuais por carga, máximo visual em 10, sem limitar o recurso ou alongar os ossos.

## Rig nativo: orientação da mão distante — 21/10/2026

Relato do usuário: junções melhoraram, mas a mão continua “de ponta cabeça”. Observado: os dois lados usavam a mesma orientação local da luva, embora a prótese distante seja espelhada. Corrigida apenas a orientação da mão distante com variante herdada `rig_nativo_v2/braco_distante.tscn`: reflexão transversal no espaço do punho, expressa como rotação −0.92951087 e escala (0.3696,−0.3696) no Sprite2D Mao. Mantidos assentamento (−8,0), tamanho absoluto, dedos voltados no eixo do antebraço, miolo filho, ossos, poses e tempos. A mão próxima não muda. Não é giro de 180° do osso nem aprovação anatômica final.

`dois_bracos.tscn` passa a instanciar essa variante só no lado distante. `test_encaixes_nativo` agora exige a reflexão correta, preservação do tamanho/encaixe e marcos dos dedos/polegar, em vez de obrigar os dois lados a terem a mesma orientação. Passou headless e OpenGL na Godot 4.7.2, exit 0/zero falhas; `test_dois_bracos_nativo`, `test_ombro_tronco_nativo` e `test_rig_nativo_v2` passaram headless, exit 0/zero falhas. Sem suíte completa ou execução do combate. `git diff --check` passou.

Doze capturas OpenGL salvas OK em `docs/evidencias_mao_distante_orientada/`, preservando evidências anteriores. Inspecionadas guarda 1920 e repouso/preparo 1024: lado da mão alterado, cuff permanece assentado. Detalhe ampliado mantém recorte intencional do corpo inferior/mão em repouso; contexto mostra o conjunto inteiro. Hipótese visual de orientação corrigida aguarda avaliação do usuário. Sem novo vídeo, arte raster, movimento, Combo ou alteração do personagem ativo. Conferir com F6 na mesma `preview_dois_bracos.tscn`. Exercício opcional: comparar com a captura anterior de guarda e observar a troca do lado da trava magenta/polegar sem mudar o sentido dos dedos.

## Rig nativo: fechamento das junções e assentamento das mãos — 21/10/2026

Relato do usuário: conjunto “tá ficando ótima”, mas junções e mão do novo braço parecem problemáticas. Screenshot enviado mostra pose intermediária com ossos visíveis, cotovelos com leitura vazada e mão distante parecendo separada do antebraço. Não é aprovação final das junções. Recorte: corrigir a continuidade da arte na prévia existente, sem recalibrar anatomia ou ampliar membros.

Observado nos arquivos e amostras RGBA: o atlas do anel de cotovelo tem centro transparente; a abertura da luva é majoritariamente opaca/pintada. Ossos coincidirem não garante continuidade dos recortes. Criada variante `rig_nativo_v2/braco_encaixado.tscn` para ambos os lados de `dois_bracos.tscn`: quatro Polygon2D de fibra com UV da textura existente, cobrindo ombro, cotovelo, punho e interior da luva; anel metálico do cotovelo continua acima do miolo. Mão assentada em (−8,0) no osso Punho, sem alterar tamanho, giro ou offset da textura. Nenhum PNG gerado/editado. A versão original do braço e as duas provas anteriores permanecem intactas.

Primeira captura mostrou reforço de ombro saliente e preenchimento por trás insuficiente para a abertura pintada da mão. Reduzido o reforço do ombro e acrescentado miolo próprio dentro da abertura da luva, acompanhando sua transformação. Hipótese visual: continuidade de fibra e sobreposição local removem a leitura de peças soltas; perspectiva espelhada ainda tem limites e aguarda avaliação. Skill `animate` orientou continuidade física sem acrescentar movimento: mesmas chaves, tempos, comprimentos, captura/interrupção e reduzido. Sem alteração de corpo/pesos, Combo, HUD, gameplay ou personagem ativo.

Verificação real Godot 4.7.2: `test_encaixes_nativo` passou headless e OpenGL fixed-fps 60, exit 0/zero falhas. Confere polígonos/UV opacos, cobertura das âncoras em 57 amostras, camadas e inserção fixa da mão, preservando dimensões. Regressões `test_dois_bracos_nativo`, `test_ombro_tronco_nativo` e `test_rig_nativo_v2` passaram headless, exit 0/zero falhas. Testes e capturador encerraram sem avisos de recursos; suíte completa e gameplay não executados. Os testes verificam continuidade geométrica/material, não anatomia ou aprovação artística.

Doze capturas OpenGL salvas OK em `docs/evidencias_encaixes_nativo/`: repouso/guarda/extensão/preparo 0.12/retorno 0.28/intermediária com ossos, em 1920×1080 e 1024×576. Inspecionadas guarda/extensão/preparo 1920 e retorno/intermediária 1024 após ajustes. Vídeo `ciclo_encaixes.avi` gerado: log confirma 130 frames/30 FPS/1152×648, exit 0 e stderr vazio, para conferência do usuário. F6 continua em `preview_dois_bracos.tscn`; F5 permanece anterior. Exercício opcional: variar a posição X do Sprite2D Mao entre −8 e 0, observar a sobreposição no cuff e restaurar −8, sem tocar no osso. Detalhes em `rig_nativo_v2/ENCAIXES.md`.

## Rig nativo: segunda prótese e guarda assimétrica na prévia — 21/10/2026

Relato/autorização do usuário: após considerar a ligação corporal mais funcional, respondeu “perfeito, vamos nessa” ao recorte de completar o segundo braço antes de Combo/integração. Implementada `vega_animada/rig_nativo_v2/preview_dois_bracos.tscn`, preservando as duas provas anteriores e o personagem ativo. Estado observado: braço distante instanciado sob clavícula/deltoide próprios, pele vinculada aos dois encaixes e guarda recolhida enquanto o primeiro golpeia. Hipótese artística em avaliação: assimetria, sobreposição e tonalidade mais baixa dão profundidade às peças reaproveitadas. Não é perspectiva final redesenhada.

`dois_bracos.tscn/.gd` preservam as seis trilhas do primeiro braço/corpo, acrescentam cinco rotações coordenadas e desativam ambos os players internos. Pele refinada para 483 vértices/440 faces/seis conjuntos de pesos, máximo de quatro influências por vértice; pesos próximos preservados e pernas/pés exclusivos da pelve fixa. Projeção espelhada uniforme fixa de 0.92 em toda a segunda prótese, mão incluída. Não se animam escala/comprimento/posição dos ossos. Skill `animate` orientou continuidade, captura/interrupção e alternativa reduzida, mantendo tempos existentes. Sem nova arte raster, solver, Combo, alteração de main/HUD/regras ou migração.

Falha visual inicial: z negativo escondia partes do braço abaixo do fundo opaco, enquanto punho/anel com z maior apareciam soltos; reduzir mais o z apagou todo o braço. Corrigida ordenação global do conjunto, com todas as peças distantes acima do fundo e atrás da pele. Incluída proteção no teste por Sprite2D. Guarda recolhida para separar punhos durante extensão; preservadas proporções. Detalhes e exercício em `rig_nativo_v2/DOIS_BRACOS.md`.

Verificação real na Godot 4.7.2: `test_dois_bracos_nativo` passou headless e OpenGL fixed-fps 60, exit 0/zero falhas; regressões `test_rig_nativo_v2` e `test_ombro_tronco_nativo` passaram headless, exit 0/zero falhas. Novo teste protege âncoras/pesos, onze trilhas float, trajetória anterior, comprimentos/mão, 57 amostras com pés fixos e faces sem inversão, camadas, interrupção/reduzido e enquadramento em duas resoluções. Sem suíte completa ou teste do combate. Importação inicial retornou 0 sem parse errors, mantendo avisos anteriores de recursos/RID/objetos ao encerrar; testes/capturador encerraram limpos.

Oito capturas OpenGL refeitas após correções em `docs/evidencias_dois_bracos_nativo/`. Inspecionados repouso/guarda 1920 e extensão/intermediária com ossos 1024. Log do vídeo `ciclo_dois_bracos.avi` confirma 130 frames/30 FPS/1152×648, exit 0, stderr vazio; arquivo gerado para avaliação, não aprovação artística final. Conferência: F6 na nova prévia, comparar repouso/guarda/retorno e interromper o soco. F5 continua anterior. Só depois da avaliação decidir Combo e integração.

## Rig nativo: retorno positivo da ligação corporal — 21/10/2026

Relato do usuário após a entrega da prova de ombro/tronco: “ótimo, agora tá mais funcional”. Registrada melhora funcional percebida nessa etapa; não equivale a aprovação anatômica/artística final ou autorização para migrar o personagem ativo. Preservar a montagem atual como base para a próxima avaliação.

Este registro altera apenas documentação; nenhum código, cena ou asset modificado, nem novo teste de execução realizado. Próximo recorte recomendado, ainda não executado: montar a segunda prótese no mesmo método, conferindo perspectiva e guarda antes de conectar Combo ou integrar ao combate.

## Rig nativo: pele do ombro e tronco articulados na prova — 21/10/2026

Relato do usuário: autorizou seguir após aprovar a prova de braço com ressalva do ombro humano rígido. Recorte adotado: ligar pele/ombro/tronco ao braço nativo, preservando proporções e pés. Não autoriza migração automática ao jogo ou novo passe de segundo braço/Combo.

Criados `rig_nativo_v2/ombro_tronco.tscn`, `ombro_tronco.gd` e `preview_ombro.tscn`. Pele é Polygon2D com 352 vértices/315 faces e quatro conjuntos de pesos para Pelve/Tronco/Clavicula/Deltoide. Pernas/pés recebem só peso da pelve fixa; peito/ombro transicionam suavemente, encaixe humano (201,225) segue 100% o deltoide. Braço aprovado instanciado sob esse osso, sem alterar peças/comprimentos/mão. Um AnimationPlayer externo coordena seis trilhas de rotação; o interno é desativado para não disputar escrita. O skinning é nativo na GPU, sem reescrever vértices em código a cada frame. Nenhuma imagem raster gerada/editada.

`braco_nativo.gd` ganhou caminhos de ossos exportados, mantendo os anteriores como padrão; `preview.gd` comporta a nova montagem, corpo em cor integral e painel de detalhe de ombro/tronco, cortando pernas no zoom de propósito. A prova original continua disponível. Skill `animate` orientou continuidade física, captura/interrupção e movimento reduzido, preservando ciclo 100/100/160/200 ms e easing nativo existente. Poses locais corporais coordenadas com o primeiro osso da prótese para manter a orientação global aprovada. Hipótese visual em avaliação: participação do ombro/torso remove a leitura de prótese girando em corpo congelado. Não é simulação 3D da cintura escapular nem soco final.

Verificação real na Godot 4.7.2: `test_ombro_tronco_nativo` passou headless e OpenGL fixed-fps 60, exit 0. Âncora deslocou aproximadamente (15.75,−2.33) px no espaço do modelo entre repouso/extensão, acompanhando a pele. Teste confere pesos/registro nativo, ponto de encaixe, seis trilhas float, comprimentos/mão/escala preservados, 57 amostras com pés imóveis e faces sem inversão, captura/reduzido e enquadramento. Oráculo de skinning no teste não é usado para animar a prévia. Regressões `test_rig_nativo_v2`, `test_vega_combate_v2` e `test_vega_playtest` passaram, zero falhas/exit 0. Sem suíte completa; testes do combate mantêm avisos anteriores de recursos/RID/objetos em uso. Crash headless intermitente anterior continua não resolvido; nova prova/capturador encerraram limpos.

Falhas encontradas antes do resultado: chaves zero como int faziam o corpo não mover (duas asserções falharam); convertidas para float e acrescentada proteção de tipo. Captura pendente contaminava pose imediata/reduzido; cache nativo limpo antes desses saltos. Depois, teste de faces encontrou 19 inversões em região transparente à esquerda por pesos do deltoide se estenderem fora da vizinhança do ombro; restringido o campo lateral, sem reduzir amplitudes ou remover verificação. Teste final exige orientação positiva nas duas metades de todas as faces. Detalhes em `rig_nativo_v2/OMBRO_TRONCO.md`.

Oito screenshots OpenGL salvos OK em `docs/evidencias_ombro_tronco_nativo/`, poses/intermediária nas duas resoluções; capturas refeitas após correções. Inspecionados repouso/extensão 1920 e guarda/intermediária 1024: pele participa, pés fixos e detalhe visível. Vídeo `ciclo_ombro.avi`: 130 frames/30 FPS/1152×648, gravação terminada normalmente/log de erro vazio, exit code do processo não capturado pelo wrapper. Resultado ainda aguarda avaliação do usuário. Sem alteração de main, cena ativa, HUD, cartas ou regras.

Importação final headless retornou 0, sem erro de parsing; `git diff --check` passou. Próxima conferência: F6 em `preview_ombro.tscn`, comparar com `preview.tscn`, sobretudo pele/encaixe durante o preparo e retorno. F5 continua anterior. Exercício opcional: variar só uma chave da clavícula em 2°, observar pele e braço acompanharem juntos e restaurar, sem mover posições ou escalar ossos. Cabeça ainda acompanha tronco sem pescoço próprio, perspectiva dos recortes continua limitada e falta a segunda prótese; não iniciar essas etapas antes dessa avaliação.

## Rig nativo: prova aprovada, ombro humano ainda rígido — 21/10/2026

Relato do usuário: a prova melhorou “20000%”; considerou-a bem melhor como teste, mas observou ombro duro e movimento parcial. Registrada aprovação da direção/prova de braço nativo, com ressalva explícita do ombro. Não equivale a aprovação de animação final ou autorização para migrar o combate.

Revisão somente de leitura, orientada por `review-animations`, na Godot 4.7.2 registrada. Observado em `rig_nativo_v2/preview.tscn`: pele do ombro/tronco permanece no Sprite2D Corpo, fora do Skeleton2D. A cena do braço anima apenas rotação dos três ossos; a origem da prótese fica presa ao contexto. Logo, girar o osso chamado Ombro não articula automaticamente o ombro humano desenhado no corpo.

| Antes / observado | Próximo ajuste proposto, não implementado | Motivo |
| --- | --- | --- |
| Prótese gira em relação a uma imagem corporal estática | Preparar ombro humano ligado ao tronco por peça ou malha articulada, depois coordenar pequeno movimento do conjunto com o braço | Corrigir a continuidade física, não mascarar rigidez mudando velocidade ou aumentando o braço |

Veredito da revisão: aprovar como prova de articulação; bloquear promoção a animação final enquanto a ligação ombro/tronco estiver rígida. Hipótese de próximo recorte: participação da cintura escapular/torso sem mover os pés, preservando comprimentos, mão e poses aprovadas como direção. Só acrescentar outro osso não basta se a pele continuar no PNG estático; pode ser preciso adaptar recorte/malha. Não implementar automaticamente segundo braço, Combo ou migração nesta avaliação.

Nenhum código, cena ou asset foi alterado neste passe; nenhuma execução de gameplay, captura ou teste de rig novo. Apenas inspeção dos arquivos e atualização documental. Conferência pequena: F6, Ver ossos, arrastar a barra e observar a origem da prótese fixa enquanto o restante articula. Exercício opcional: variar uma chave do osso Ombro em 5° e comparar a pele imóvel no contexto, depois restaurar; isso evidencia por que a ligação corporal precisa de trabalho próprio.

## Vega v2: prova isolada com Skeleton2D/Bone2D/AnimationPlayer — 21/10/2026

Relato do usuário: perguntou por um rig estabelecido que evitasse tantas revisões e autorizou tentar a recomendação de um braço isolado antes de trocar a Vega do jogo. Não autorizou compra de Spine ou migração total; aprovação visual continua pendente.

Observado: controlador ativo usa Node2D e solver IK próprio, com calibrações já rejeitadas. Criada `vega_animada/rig_nativo_v2/braco_nativo.tscn`: Skeleton2D com três Bone2D, sprites/atlases e animações guardados na cena e visíveis no editor. `braco_nativo.gd` seleciona clips/inspeção/reduzido, sem calcular pose ou usar IK. Repouso, guarda, extensão, RESET e ciclo de soco por três trilhas de rotação, sem animar escala/comprimentos. Captura nativa retoma o estado atual em transições/interrupções. Skill `animate` usada para movimento finito substituível e alternativa reduzida. Chaves internas lineares para inspeção, captura cubic in-out da Godot; não é um passe final de suavização ou a curva bézier do rig anterior.

`preview.tscn`/`preview.gd`: F6, contexto corporal atenuado com só um braço intencionalmente, mesma cena ampliada, três botões de pose, soco, barra de inspeção e ossos/reduzido. Arte existente reutilizada, sem geração/edição raster. Hipótese a avaliar: poses e proporção fixas em rig editável tornam o ajuste previsível. Perspectiva das juntas/cuff ainda vem de recortes antigos, não é corrigida automaticamente pelo esqueleto. Regra de Combo/Finalização, expansão aprovada, main/cena ativa/retrato/cartas/HUD permanecem intactos. Sem segundo braço, deformação por Combo ou movimento de tronco nesta prova.

Verificação real na Godot 4.7.2: `test_rig_nativo_v2`, `test_vega_combate_v2`, `test_vega_playtest` passaram headless fixed-fps 60, zero falhas/exit 0. Novo teste exige três ossos registrados/nenhum solver IK, clips somente com rotação, 57 amostras de comprimentos/encaixes/mão fixa, captura sem teleporte, fim sem loop, reduzido, controles das duas instâncias e enquadramento da mão completa nas duas resoluções. Prova isolada encerrou limpa; regressões do jogo mantêm avisos anteriores de recursos/RID/objetos em uso. Sem suíte completa; crash headless intermitente anterior não foi investigado/corrigido neste recorte.

Falha inicial de carregamento dos testes: literais sem zero inicial em `.tscn`; corrigidos e repetidos. Importação anterior retornara 0, mas não validava aquele carregamento. Processos presos do teste/capturador foram encerrados por identificação específica; nenhum editor do usuário foi encerrado. Capturas iniciais revelaram corte do zoom e ossos desenhados atrás do fundo; corrigidos e capturas refeitas. Oito screenshots OpenGL salvos OK em `docs/evidencias_rig_nativo_v2/`, três poses/intermediária por resolução. Inspecionados repouso/guarda/extensão 1920 e guarda/intermediária 1024, mão completa e overlay visível. Vídeo `ciclo_nativo.avi`: 82 frames/30 FPS/1152×648, encerramento normal da gravação/log de erro vazio, sem exit code capturado pelo wrapper. Não é aprovação do movimento pelo usuário.

F5 permanece com o personagem anterior. Próxima conferência: F6 em `rig_nativo_v2/preview.tscn`, comparar as três poses e inspecionar cotovelo/punho com a barra. Exercício pequeno: selecionar a animação guarda e variar 5° numa chave de Cotovelo, sem mover sua posição ou escalar ossos; restaurar depois. Detalhes/fontes/limitações no README da pasta. Só após avaliação decidir adaptação das peças, segundo braço e integração.

## Vega v2: reduzir membros e corrigir mãos minúsculas — 21/10/2026

Relato do usuário, acompanhado de screenshot: braços ficaram grandes demais, mãos minúsculas e próximas dos joelhos, com aparência alienígena. A calibração anterior foi novamente rejeitada; a captura confirma o desequilíbrio. Não tratar os testes aprovados anteriores como validação artística.

Observado: escalas .80/.77 alongavam toda a cadeia, mãos em .34 diminuíam a relação com o antebraço e alvos de repouso (155,505)/(520,520) mantinham punhos baixos demais. Corrigidos `modelo.gd` e `braco_articulado.gd`: braços .66/.64, mãos .56, repouso (170,420)/(475,445), alvo de soco (250,-32). Em tela, mãos aumentam aproximadamente 36%/37% apesar da redução dos braços; cadeia encurta cerca de 17% em ambos. Mantido bíceps sem compressão longitudinal e relação entre segmentos. Hipótese visual: cotovelos soltos e punhos na região superior das coxas corrigem silhueta sem regressar à guarda permanente. Capturas mostram maior distância dos joelhos; resultado ainda depende do usuário.

Regra preservada: Combo, custos, dano e resolução não mudam. Ativação/feixes aprovados, prontidão separada do volume, Tween, tempos, interrupções e alternativa reduzida mantidos. Skill `animate` usada para preservar a transição já existente durante a recalibração, sem criar efeitos novos. Nenhum asset raster foi gerado ou editado.

Corrigido o critério de regressão que protegia a montagem rejeitada: removida exigência de cadeia 35–42% da altura e alcance absoluto >300 px. Novo teste confere pulso em y=400–470, envelope conservador da mão terminando até y=550 (joelho mais alto aproximadamente y=600 no corpo-base), relação cuff/punho fechado com antebraço .65–.85 e extensão >94% do alcance calibrado, sem esticar. Limites artísticos da montagem, não leis anatômicas nem novas regras. Mantidas verificações de comprimentos constantes, encaixes, cartas reais, Combo/reduzido/interrupção/reset. Nenhuma falha foi ocultada removendo cobertura funcional.

Verificação real na Godot 4.7.2: seis verificações com exit 0, cinco cenas headless fixed-fps 60 (`test_vega_combate_v2`, `test_vega_playtest`, `test_braco_v2_combo`, `test_interacao_hud_combate`, `test_resolucao_cartas`) e `verificar_vega_animada` OpenGL. Zero falhas onde há resumo. Sem suíte completa, sem repetição do funcional headless: crash intermitente de encerramento registrado no passe anterior continua não resolvido. Persistem mensagens de RID/texturas/fontes/recursos em uso ao encerrar alguns processos.

Evidência nova preserva a anterior: 16 capturas da arena em `docs/evidencias_vega_combate_v2_maos/`, oito estados em cada resolução 1920×1080/1024×576, todos salvos OK; quatro imagens isoladas ampliadas. Inspecionados repouso/guarda/extensão ampliados, repouso Combo 0 em 1920 e Combo 10 em 1024. Mãos visivelmente maiores e mais altas; perspectiva das juntas continua limitação do rig reaproveitado. Não foi gravado vídeo novo nesta revisão. Próxima conferência: F5, esperar, olhar mão/coxa e depois jogar um ataque. Exercício opcional: comparar apenas y do repouso em ±5 px no modelo, sem mudar escala ou tempos junto.

## Vega v2: corrigir braços curtos e guarda permanente — 21/10/2026

Relato do usuário: a integração ficou feia, com braços comicamente curtos e sempre em pose de combate, parecendo um T-rex. A versão integrada anterior não foi aprovada visualmente. Testes de comprimento constante não garantiam proporção adequada.

Observado no código/capturas: bíceps comprimido verticalmente a 70%, braços em escala .73/.64 e punhos sempre junto ao rosto mesmo em `estado_animacao = repouso`. Corrigida a projeção superior de (.85,.70) para (.85,1.0), escalas para .80/.77 e alvo de extensão de (237,-42) para (323,-40), limitado pelo alcance real. Cadeia sem mão passa de cerca de 29%/25% para 37%/35% da altura-base de 860 px. Punho recalibrado de .45 para .34 para não crescer desproporcionalmente com os membros. Bíceps distante deixa de ficar oculto enquanto só sua placa aparecia na frente. Imagens/identidade/feixes originais preservados; não foi gerado asset novo.

Hipótese visual em avaliação: braços baixos, punhos abaixo do quadril e cotovelos levemente flexionados entre ações comunicam melhor a personalidade/peso. `prontidao` separa postura de volume: entra em guarda no preparo de 100 ms, estende em 100 ms, recolhe em 160 ms e baixa os braços em 200 ms. Movimento total de 560 ms não bloqueia cartas. Skill `animate` usada para transições locais substituíveis do estado atual, preservando curva existente e movimento reduzido. Ataque rápido retoma altura atual, dano interrompe e também retorna ao repouso. Combo muda tensão dos feixes, não obriga guarda alta; regras de recurso/dano/custo intactas. Arquivos: `modelo.gd`, `braco_articulado.gd`, `vega_combate.gd` e testes/capturadores na pasta existente.

Verificação real na Godot 4.7.2: nove testes de cena passaram, exit 0, com fixed-fps 60: `test_vega_combate_v2`, `test_vega_playtest`, `test_braco_v2`, `test_braco_v2_combo`, `test_hud_conceito_ativo`, `test_interacao_hud_combate`, `test_jogador_combate`, `test_resolucao_cartas`, `test_layout_combate`. Teste novo ampliado exige proporção candidata 35–42% (sem mão), relação bíceps/antebraço >.9, punhos baixos, Combo sem elevar guarda, alcance >300 px, guarda antes de baixar, retomada durante relaxamento, reset/reduzido; mantém cartas reais e verificações anteriores. Primeira calibração distante .76 ficou abaixo de 35% e falhou uma asserção; ajustada para .77 e repetido com 0 falhas. Intervalos são proteção da montagem candidata, não leis anatômicas ou regras de gameplay.

Ressalva de execução: `verificar_vega_animada` imprimiu 0 falhas em todas as cinco execuções, mas duas headless encerraram com -1073741819 depois desse resumo. Terceira headless, headless verbose e OpenGL encerraram com 0. Não considerar este teste estável nem declarar corrigida a falha nativa intermitente. Log verbose mantém recursos/objetos em uso ao encerrar; causa do crash não isolada. Não se mudou código de gameplay ou teste para esconder o problema. Sem suíte completa.

16 capturas OpenGL reais salvas OK em `docs/evidencias_vega_combate_v2_proporcao/`, preservando evidências anteriores: repouso Combo 0/5/10, preparo, extensão, recolhimento, repouso após soco e dano em 1920×1080 e 1024×576. Inspecionados repouso nas duas resoluções, extensão 1920 e modelo ampliado. Ajuste intermediário exagerou tamanho das mãos e foi recalibrado antes das capturas finais. Quatro imagens isoladas adicionais conferem repouso/guarda/meio/extensão. Vídeo `ciclo_corrigido.avi`: gravação terminada normalmente, 154 frames/30 FPS/1152×648, três cartas reais seguidas de reação visual chamada diretamente; wrapper não capturou exit code do processo. Persistem avisos de RID/texturas/fontes/objetos/recursos ao encerrar. Resultado visual ainda depende de avaliação do usuário, especialmente perspectiva das peças e peso da transição.

Importação final headless retornou 0, sem erros de parsing; `git diff --check` passou. Próxima conferência pequena: F5, esperar sem jogar, atacar e esperar novamente; braços devem baixar mesmo com Combo acumulado. Exercício opcional: variar apenas os 200 ms de baixar a guarda para 250 ms em `socar()`, comparar e restaurar; não alterar escala/alcance ou regras junto.

## Vega v2 integrada ao combate real — 21/10/2026

Relato do usuário: considerou boa a referência de poses e pediu vê-la refletida no jogo. Autoriza a integração; não declara aprovado o novo movimento produzido.

Observado: `main.gd` ainda instanciava a Vega industrial em PNG único. Agora instancia `vega_animada/combate_v2/vega_combate.tscn`, sem sobrepor o personagem anterior. Corpo-base/punho fechado derivados das referências 04/poses 02 via skill `imagegen`; prompt, fonte, recortes e limites no README da pasta. Região inferior do atlas gerado trouxe antebraço não solicitado e não foi usada. Provas anteriores preservadas. Retrato da HUD, cartas, arenas e composição geral permanecem anteriores.

Regra preservada: Combo real sem teto; cada carga vale 10 pontos percentuais da tensão adicional, máximo visual em 10. Ganho/Finalização/zeragem chegam aos dois braços. Dano/custos/resolução e input não esperam animação. Apresentação agora tem pivôs ombro/cotovelo/punho, IK com comprimentos projetados constantes, guarda, respiração local, preparo/extensão/retorno e reação ao dano. Skill `animate` orientou Tween nativo, movimento substituível e alternativa reduzida. Mapa/nova run limpam o movimento. Hipótese a avaliar: este soco compacto funciona com os feixes aprovados; não é validação biomecânica ou reprodução exata da prancha. Punho e braço distante reaproveitados/espelhados e inclinação 2D do tronco ainda limitam perspectiva.

Verificação real na Godot 4.7.2: 13 verificações focadas passaram com exit 0, sem suíte completa: `test_vega_combate_v2`, `test_vega_playtest`, `verificar_vega_animada`, `test_hud_conceito_ativo`, `test_composicao_suave`, `test_layout_combate`, `test_polimento_combate`, `test_interacao_hud_combate`, `test_jogador_combate`, `test_resolucao_cartas`, `test_braco_v2`, `test_braco_v2_combo`, `test_vega_corpo_v2`. Headless, fixed-fps 60. Novo teste exige encaixes/comprimentos em cinco poses, pernas exatamente imóveis, Combo real 0/1/5/10/11/100, placas rígidas, ataques rápidos, interrupção por dano, movimento reduzido e limpeza. Direto→Direto→Quebra-chassi reais causaram 19 de dano por 3 Energias, Combo final zero. Testes antigos atualizados para o contrato visual novo, sem remover cobertura funcional.

Falha inicial do teste novo: comparação exata usando round-trip UV (erro medido 0.00003052 px), 360 falhas. Corrigida referência para pontos originais da malha, mantendo comparação exata; vértices com peso zero retornam sem transformação. Reexecução passou; não houve mudança de regra para contornar teste. Importação sem erro de parsing, exit 0. Ainda há mensagens de RID/texturas/fontes/objetos/recursos em uso ao encerrar alguns testes/capturas, não resolvidas aqui.

14 capturas reais OpenGL em `docs/evidencias_vega_combate_v2/`, salvamento OK, guarda 0/5/10 e fases de ataque/dano em 1920×1080 e 1024×576. Inspeção de guarda/extensão/compacto revelou braço distante oculto, punho pequeno e pé atrás de Barreira; corrigidos e capturas repetidas. Inspeção final compacta mostra o pé livre. Vídeo `ciclo_real.avi` com 154 frames, 30 FPS, 1152×648, gravado normalmente: três cartas reais e reação visual ao dano chamada diretamente no final, não uma fase inimiga. Wrapper não retornou exit code do processo de gravação; não confundir fim normal registrado com código capturado. Detalhes reproduzíveis no README. Avaliação manual do usuário pendente.

Próxima verificação pequena: F5 e combate, observar Direto/Combo e consumo em Quebra-chassi, especialmente encaixe e retorno. Exercício opcional: comparar apenas retorno do soco `.16`/`.20` em `vega_combate.gd`, depois restaurar, sem alterar regras. Antes de propagar arte ao retrato/cartas, avaliar o movimento ativo.

## Vega v2: três poses estáticas de soco em avaliação — 21/10/2026

Relato do usuário: receou problemas de anatomia ao animar o soco e autorizou tentar a prova estática de guarda/preparação/extensão. Esta autorização não aprova as poses produzidas nem pede integração ao jogo.

Observado: o corpo montado usa uma vista reutilizada/espelhada e mãos relaxadas, sem articulação de cotovelo validada. Hipótese explicitada: soco reto de trás para a direita, câmera/volume constantes nas três poses, avaliando punho fechado e cadeia ombro/cotovelo/punho antes de código de rig. Regra de Combo/Finalização e montagem aprovada preservadas.

Skill `imagegen` e ferramenta integrada usadas com referência 04 local inspecionada. Primeira prancha em `docs/arte_vega/vega_v2_soco_poses_01.png`; a preparação trouxe cotovelo elevado para trás, além do pretendido. Feita uma edição localizada, preservando o alvo: `vega_v2_soco_poses_02.png`, candidata atual com preparo curto e cotovelo baixo. Guarda e extensão visualmente mantidas; não houve comparação pixel a pixel. Ambas 1774×887; resolução solicitada maior não foi a resolução entregue. Fontes e dois prompts integrais em `docs/arte_vega/vega_v2_soco_poses.md`.

Verificação real: inspeção do mestre, captura da montagem e alvo 01 antes da edição; inspeção das duas saídas e leitura de dimensões. Corpos inteiros/legendas/mãos fechadas visíveis, identidade reconhecível e preparação corrigida em relação ao pedido. Ainda a conferir continuidade dos membros, detalhes das placas, proporções aparentes e apoio traseiro pouco explícito na extensão. Não constitui validação biomecânica nem demonstração de rig. Nenhum código, cena, asset ativo ou regra alterado; nenhum teste de gameplay/rig executado. `git diff --check` passou.

Próxima avaliação pequena: seguir ombro→cotovelo→punho na terceira pose e comparar guarda/preparação. Exercício visual opcional: marcar as duas linhas dos segmentos em uma cópia para observar rotação e comprimento aparente; preservar originais. Só após avaliar as poses decidir peças/pivôs; não girar recortes atuais para contornar incoerência da referência.

## Vega v2: aprovação da montagem com ajuste dos soquetes — 21/10/2026

Relato do usuário: considerou a montagem perfeita, com ressalva de braço um pouco fora do soquete, pediu ajuste e perguntou os próximos passos. Registrada aprovação geral com essa ressalva, não aprovação de rig de ação ainda inexistente.

Observado: a calibração (-30,20) usava o topo do retângulo do braço, não o ponto visível de acoplamento. Ajustada `JUNTA_LOCAL` em `vega_animada/corpo_v2/corpo_prova.gd` para (-40,45). Os dois braços são recolhidos para dentro dos conectores; não mudam ombros-alvo, escalas, ângulos, imagens, malhas ou regra linear de Combo. `test_vega_corpo_v2.gd` ganhou verificação de calibração visual independente. Capturador grava em nova pasta, preservando a montagem anterior.

Verificação real: 14 capturas OpenGL Compatibility em `docs/evidencias_vega_corpo_v2_encaixe/`, salvas OK; inspecionadas Combo 10 em 1920×1080 e repouso em 1024×576. Novo vídeo com 177 frames/30 FPS/1152×648, encerramento normal. Na execução headless normal, corpo e braço-base passaram, mas o teste de Combo falhou uma vez na asserção de estado intermediário após timer de 80 ms. Repetidos os três com `--fixed-fps 60`: 0 falhas/exit 0; Combo repetido novamente e passou. Não se mudou animação/regra para contornar a falha temporal. Suíte completa não repetida. `git diff --check` passou.

Somente ajuste de encaixe implementado; personagem ativo/HUD/cartas permanecem intactos. Próximo objetivo recomendado, não executado: preparar articulação e validar um único soco com antecipação/impacto/retorno, preservando expansão e âncoras. Depois guarda/respiração/defesa/reação, integração ao combate real com Combo e feedbacks existentes, e unificação do retrato/cartas. Conferência pequena agora: F6 na prévia, alternar repouso/combate e Combo 0/10 olhando só os ombros. Exercício opcional de calibração: variar um único componente da âncora local em 2 px e observar o deslocamento, depois restaurar; não alterar amplitudes para esconder desalinhamento.

## Vega v2: Combo linear aprovado e montagem corporal em prova — 21/10/2026

Relato do usuário: “tá otimo, podemos continuar agora”, após a revisão linear. Registrada aprovação da resposta do braço em dez passos; não se estende automaticamente ao novo corpo-base ou montagem.

Observado: os recortes corporais anteriores e o personagem ativo ainda usam a Vega industrial. A referência 04 aprovada não fornece um corpo-base transparente sem braços. Próximo objetivo adotado e explicitado: uma montagem corporal isolada em postura neutra, sem implementar soco/flexão ou substituir a Vega do combate.

Skill `imagegen` e ferramenta integrada usadas para derivar `vega_animada/corpo_v2/corpo_base_01.png` da referência 04: rosto/cabelo/roupa tratados como invariantes, ombros humanos preservados, próteses retiradas para montagem. Alfa real verificado; fonte e prompt no README da pasta. Criados `corpo_prova.gd`, `preview.gd` e `preview.tscn`, com duas instâncias do braço aprovado, uma espelhada. Corpo/pés fixos, ombros ancorados, controles de combate/Combo/reduzido. Skill `animate` orientou reutilizar os movimentos aprovados e não adicionar animação corporal antes de validar encaixes. O segundo braço é reaproveitamento técnico, não perspectiva final; conectores, postura e proporções novas ainda precisam de avaliação. Ajustadas escala/abertura após a primeira captura mostrar braços pequenos e mão traseira encoberta.

Verificação real na Godot 4.7.2: importação exit 0, com mensagens de RID/objetos/recursos ao encerrar. Primeira captura falhou por sintaxe de literais Color da cena; corrigida e repetida. Resultado final: 14 capturas OpenGL Compatibility, salvamento OK, em `docs/evidencias_vega_corpo_v2/`. Inspecionados repouso/Combo 10 em 1920×1080 e Combo 5 em 1024×576, com nova captura após ajuste. Vídeo `ciclo_corpo.avi`: 177 frames, 30 FPS, 1152×648, repouso/combate/5/10/11/0/repouso, encerramento normal. Cinco testes com 0 falhas e exit 0: `test_vega_corpo_v2`, `test_braco_v2_combo`, `test_braco_v2`, `test_vega_playtest`, `test_hud_conceito_ativo`. O teste novo confere encaixes, corpo/mãos estáveis, sincronização durante movimento, interrupção, consumo/reduzido e controles nas duas resoluções. Os dois últimos continuam com objetos/recursos em uso ao encerrar. `git diff --check` passou; suíte completa não repetida.

Nenhuma regra, HUD, carta, retrato ou personagem ativo substituído. Não é rig completo nem montagem aprovada. Próxima avaliação pequena: F6 em `vega_animada/corpo_v2/preview.tscn`, olhar ombros/proporção das mãos nos estados 0/5/10; consumir durante ganho. Exercício opcional: comparar somente amplitude de antebraço 0.14/0.10 sem alterar progressão.

## Vega v2: progressão linear de tensão, máximo visual em 10 Combo — 21/10/2026

Pedido do usuário: testar incrementos iguais de 10 por carga, chegando ao máximo em 10 Combo. Interpretado e explicitado como 10 pontos percentuais da amplitude adicional de tensão por carga, não 10% de escala do braço inteiro. Substituída a curva assintótica por `clamp(Combo, 0, 10) / 10.0`. Estado observado anterior: primeira carga valia 25% e a curva se aproximava do máximo sem alcançá-lo. Regra preservada: recurso real sem teto. Hipótese em avaliação: progressão linear comunica melhor a contribuição de cada carga.

Alterados `braco_prova.gd` (mapeamento), `preview.gd`/`preview.tscn` (botão 10 e contador com porcentagem-alvo), testes e capturador. Mantidos amplitudes, ativação básica, 200 ms, curva temporal suave, interrupção e alternativa reduzida, seguindo a skill `animate`. Nenhum asset, estado ou regra ativa do jogo alterado; continua prova isolada.

Verificação real na Godot 4.7.2: `test_braco_v2_combo`, `test_braco_v2` e `test_jogador_combate` passaram com exit 0; os dois primeiros reportaram 0 falhas, sem mensagens de erro. Exigidos os passos 0–12 e extremos, deslocamento geométrico proporcional, pose igual em 10/100, contador crescente e não reinício da transição 10→11, preservando verificações anteriores de âncoras/UVs/interrupção/movimento reduzido. Prévia testada em 1024×576 e 1920×1080. Dezoito capturas OpenGL Compatibility em `docs/evidencias_braco_v2_combo_linear/`, todas salvas OK; inspecionados Combo 5 pequeno e Combo 10/11 grande. Vídeo `ciclo_linear.avi`: 179 frames/30 FPS/1152×648, sequência 0/1/2/5/9/10/11/0/repouso. Fontes/evidências anteriores preservadas. `git diff --check` passou; suíte completa não repetida.

Próxima verificação pequena: F6, botão 10 e depois +1 — contador deve mostrar 11/100%, sem crescer ou reiniciar o movimento. Consumir deve retornar à base de combate. Exercício opcional: comparar somente a amplitude visual `contracao_combo_antebraco` 0.14/0.10, sem alterar os dez passos. A avaliação artística desta revisão ainda depende do usuário.

## Vega v2: resposta ao Combo na prévia isolada — 21/10/2026

Relato do usuário: autorizou continuar após aprovar a base e sugerir flexão com stacks. Implementada apenas a tensão dos feixes na cena de prova, não dobra do cotovelo nem integração da nova Vega ao jogo.

Observado antes da mudança: o braço tinha ativação de combate normalizada, sem Combo. Regra preservada: Combo real sem teto, consumido por Finalização e zerado ao encerrar turno/combate. Hipótese implementada para avaliação: base aprovada mais tensão visual saturante `Combo / (Combo + 3)`, amplitude adicional máxima 0.18/0.14 nos feixes e abertura rígida adicional de até 8/8/4 px nas placas. Tensão de 200 ms e ativação de 500 ms são independentes e compõem a mesma geometria. Ganhos rápidos substituem o destino atual; consumir retorna à base de combate, sair retorna ao repouso e limpa a tensão. Movimento reduzido resolve ambos imediatamente.

Arquivos envolvidos: `vega_animada/braco_v2/braco_prova.gd`, `preview.gd` e `preview.tscn`; a prévia ganhou +1/+3/100/Consumir. Skill `animate` orientou resposta contida, curva existente, interrupção e alternativa reduzida. Nenhuma imagem gerada/editada, nenhum estado/regra/HUD/asset ativo do combate substituído. Documentação técnica e limites no README da prova.

Verificação real na Godot 4.7.2.stable.official.ed1daf0bf: `test_braco_v2_combo` e `test_braco_v2` com 0 falhas, exit 0. Cobertos extremos até int64 máximo, saturação, UVs/âncoras, faces válidas, placas rígidas, retorno exato, interrupção/consumo durante ganho, repetição, animação simultânea, movimento reduzido e controles nas duas resoluções. Regressões `test_vega_playtest`, `test_hud_conceito_ativo`, `test_jogador_combate` e `test_resolucao_cartas` também passaram. Os dois primeiros continuam reportando objetos/recursos em uso ao encerrar. Suíte completa não repetida. Doze capturas OpenGL Compatibility em `docs/evidencias_braco_v2_combo/`, salvamento OK; inspecionadas base/100 em 1920×1080 e Combo 3 em 1024×576. Vídeo `ciclo_combo.avi`: 122 frames, 30 FPS, 1152×648, sequência 0/1/3/100/0/repouso. Evidências anteriores preservadas. `git diff --check` passou.

A extensão ainda aguarda avaliação do usuário; os testes não garantem estabilidade de um futuro rig corporal. Próxima verificação pequena: F6 na prévia, ganhar cargas e consumir durante o movimento; avaliar borracha/placas soltas. Exercício opcional: comparar somente `contracao_combo_antebraco` 0.14 versus 0.10.

## Vega v2: prova do braço aprovada; resposta ao Combo sugerida — 21/10/2026

Relato do usuário: gostou da prova animada e a aprovou explicitamente; pediu cuidado para a animação não quebrar e sugeriu flexionar os braços conforme os stacks de Combo. A aprovação se refere à prova isolada apresentada, não a um rig corporal ou à integração que ainda não existe.

Observado no código: `braco_prova.gd` tem um único controle normalizado de transformação e não recebe Combo. `jogador_combate.gd` incrementa Combo sem teto e o zera no encerramento do turno. O design confirma consumo de todo o Combo em Finalização. Hipótese proposta para uma próxima prova pequena: manter volume básico de combate e acrescentar contração/tensão visual limitada dos feixes conforme o Combo; consumo/zeragem retornam à base de combate, e sair do combate retorna ao repouso. Não multiplicar escala ou amplitude indefinidamente por stack. Não implementar flexão do cotovelo como se já houvesse um rig articulado validado.

Nesta etapa foram atualizados apenas os registros de aprovação e a proposta de direção. Nenhum script, cena, asset ou regra alterado; nenhum teste de execução repetido. Verificações: leitura dos scripts atuais, regra de Combo/Finalização, versão registrada da Godot e `git diff --check`. Os resultados técnicos anteriores permanecem históricos. Próxima verificação sugerida: na futura prova de Combo, comparar 0 → 1 → 3 → um valor alto → 0, incluindo inversões rápidas e movimento reduzido, observando âncoras e placas. Não há promessa de ausência de quebra antes desse teste.

## Vega v2: figurino aprovado e prova de um braço — 21/10/2026

Relato do usuário: “perfeito, tá bem melhor, agora sim podemos seguir”, após a referência 04. Registrada aprovação do figurino junto de cabelo, expressão e braços já aprovados. Isso não aprova automaticamente a reconstrução técnica derivada.

Implementada prova isolada em `vega_animada/braco_v2/preview.tscn` (F6): feixes com expansão localizada, placas rígidas, mão/pulso e cotovelo ancorados, transformação reversível, slider de pose e movimento reduzido. Skills `animate` e `imagegen` orientaram respectivamente a transição e a preparação do atlas transparente. Camadas derivadas da referência 04, não dos assets industriais anteriores; processo/prompt e limites em `vega_animada/braco_v2/README.md`. Não é rig completo nem recorte idêntico da prancha; perspectiva, textura e volumes ainda dependem de avaliação.

Verificação executada na Godot 4.7.2: `test_braco_v2` com 0 falhas (inclui inversão em andamento, âncoras, UVs, placas, controle manual, interrupção do ciclo, movimento reduzido e layout em duas resoluções). `test_vega_playtest` e `test_hud_conceito_ativo` também com 0 falhas e exit 0; ambos ainda emitiram avisos de objetos/recursos em uso ao encerrar. Suíte completa não repetida. Dez capturas reais OpenGL Compatibility salvas em `docs/evidencias_braco_v2/`; inspeção de repouso/combate em 1920×1080 e composição em 1024×576. A primeira montagem mostrou margens incorretas e ondulação; recortes explícitos, malha mais fina e remoção da compressão longitudinal corrigiram esses problemas de montagem. Capturas refeitas. Gravado `ciclo.avi`, 90 frames/3 s, 30 FPS, viewport 1152×648, sem erros de gravação. Não houve avaliação do movimento pelo usuário nem validação de produção.

Importação final headless retornou 0, sem erro de parsing, mas com mensagens de RID/recursos em uso ao encerrar. Novo teste repetido após a importação: 0 falhas, incluindo término do ciclo completo sem timer residual. `git diff --check` passou.

Nenhuma regra, HUD, carta ou personagem ativo do combate substituído. Próxima verificação pequena: executar o ciclo no F6 e avaliar se o engrossamento comunica força sem borracha/placas soltas; comparar slider em 25/50/75%. Exercício opcional: reduzir somente `expansao_antebraco` de 0.38 para 0.30 e comparar.

## Vega v2: cabelo aprovado e figurino de rua em prova — 21/10/2026

Relato do usuário: aprovou o cabelo da referência 03, reafirmou os braços e a leitura confiante/rabugenta, mas considerou a roupa de mecânica. Demonstrou entusiasmo pela possibilidade de animar a transformação repouso/combate; esse comentário não é resultado de teste ou animação pronta.

Usada a skill `imagegen` com a ferramenta integrada para editar somente figurino: regata carvão, calça urbana sem bolsos de carga e camisa vinho/plum na cintura, substituindo a gola/fechamento de uniforme. Referência em `docs/arte_vega/vega_v2_referencia_04.png`, prompt/processo no documento homônimo. Prancha 03 e original da ferramenta preservados. Cabeça e braços foram tratados como partes aprovadas a preservar; o figurino novo ainda aguarda avaliação.

Verificação realizada: inspeção visual do alvo local e saída integrada; roupa atualizada no corpo/retrato e identidade, expressão, cabelo e braços visualmente mantidos. Sem comparação pixel a pixel. Nenhum asset ativo, código, regra ou animação do jogo alterado; nenhum teste de gameplay executado. `git diff --check` passou. Hipótese técnica posterior: prova reversível de um braço, deformando feixes e movendo placas sem alterar mãos/juntas ou bloquear o combate. A prancha não é rig pronto. Próxima verificação pequena: avaliar se a roupa deixa de ler como uniforme, mantendo reconhecível a mesma personagem.

## Vega v2: expressão aprovada e cabelo mais longo em prova — 21/10/2026

Relato do usuário: aprovou a referência 02, com ressalva somente ao cabelo. Escolheu explorar um corte mais longo. Braços e expressão devem permanecer estabilizados durante esta revisão.

Usada a skill `imagegen` com a ferramenta integrada para editar somente o cabelo nas duas vistas, partindo da prancha 02. A interpretação proposta tem comprimento até o queixo/início do pescoço, camadas desalinhadas e franja lateral. Resultado em `docs/arte_vega/vega_v2_referencia_03.png`; prompt/processo no documento homônimo. Pranchas anteriores e original da ferramenta preservados. O novo corte ainda depende de avaliação do usuário, sem alteração definitiva do cânone ou integração ao jogo.

Verificação realizada: inspeção do alvo local antes da edição e da saída integrada; cabelo mais longo no corpo inteiro e no retrato, mantendo visualmente a expressão sem sorriso, identidade, roupa, pose e desenhos dos braços. Sem comparação pixel a pixel. Nenhum asset ativo, código ou regra alterado; nenhum teste de gameplay executado. `git diff --check` passou. Próxima verificação visual pequena: comparar somente o contorno da cabeça entre 02/03 em tamanho de retrato.

## Vega v2: braços aprovados, expressão revisada — 21/10/2026

Relato do usuário: gostou muito dos braços da referência 01, mas considerou a expressão alegre/carismática, distante da rabugenta protetora pretendida. Essa é aprovação dos braços, não aprovação automática do resto da prancha ou de um rig.

Usada a skill `imagegen` com a ferramenta integrada para editar a prancha existente, solicitando alterar somente as expressões do rosto no corpo inteiro e no retrato: retirar sorriso, tensionar sobrancelhas e produzir olhar desconfiado, impaciente e levemente cansado, sem vilania caricata. Braços aprovados, roupa, cabelo, pose e estudos foram tratados como partes a preservar. Resultado salvo em `docs/arte_vega/vega_v2_referencia_02.png`; alvo 01 e fonte da ferramenta preservados. Prompt/processo em `docs/arte_vega/vega_v2_referencia_02.md`.

Verificação realizada: inspeção visual do alvo local antes da edição e da saída integrada. Ambos os rostos perderam o sorriso; braços e estudos mantêm visualmente os componentes e a disposição anteriores. Não foi feita comparação pixel a pixel. A nova expressão ainda depende da avaliação do usuário. Nenhum asset ativo, código ou regra alterado; nenhum teste de gameplay executado. `git diff --check` passou. Próxima verificação visual pequena: comparar apenas os dois rostos das referências 01/02, mantendo os braços como referência aprovada.

## Vega v2: primeira referência de identidade — 21/10/2026

Relato do usuário: autorizou gerar a referência seguindo a proposta v2 e pediu “menos Vi do LoL e mais personagem única”. Usada a skill `imagegen` com a ferramenta integrada para uma prancha de corpo inteiro, retrato e estudos de repouso/combate. Arquivo: `docs/arte_vega/vega_v2_referencia_01.png`; prompt e processo em `docs/arte_vega/vega_v2_referencia_01.md`. Original gerado preservado.

Não foram fornecidas à geração a imagem placeholder de Vega, as cartas industriais ou imagens de Vi. Duas peças sem personagens da HUD serviram como referências de formas/materiais/paleta. Hipóteses exploradas: cabelo preto curto texturizado, roupa de trabalho assimétrica cobrindo o tronco, braços de fibras sintéticas com placas menores e mãos proporcionais; potência nos volumes do braço em vez de luvas gigantes. Rosto, pele, roupa e geometria são propostas, ainda não aparência aprovada.

Verificação realizada: inspeção visual da saída integrada, com figura inteira/pés visíveis, retrato e dois estudos rotulados. A prancha é candidata de direção, não turnaround completo, sprite, rig ou comprovação de repetibilidade técnica/animação. O volume de combate e os componentes ainda dependem da avaliação do usuário. Nenhum asset ativo, código ou regra alterado; não foram executados testes de gameplay. `git diff --check` passou. Próximo passo: avaliar a identidade antes de derivar retratos, recortes ou cartas. Exercício visual opcional: olhar a silhueta em tamanho pequeno e identificar o que torna Vega reconhecível sem os detalhes luminosos.

## Reavaliar Vega antes de outra revisão das cartas — 21/10/2026

Relato do usuário: as cartas industriais contradizem as molduras e herdaram a Vega placeholder como base; pediu repensar a personagem para evitar nova inconsistência. A conclusão técnica anterior do catálogo não representa aprovação de sua coerência artística. Não houve reversão nem substituição de assets nesta etapa.

Observado nos documentos: `PERSONAGENS.md` confirma origem em equipamentos de carga adaptados, corpo humano, cabelo curto, personalidade briguenta/protetora e braços protéticos extremamente musculosos em combate. Não exige placas claras, faixas amarelas, pistões expostos ou a roupa/corte exatos da imagem provisória. A referência de HUD foi inspecionada: linguagem de recortes escuros e acentos neon. A origem portuária não foi removida para acomodar o visual.

Registrada hipótese em `docs/arte_vega/direcao_vega_v2.md`: volumes de musculatura artificial, poucas placas articuladas escuras, detalhes tecnológicos controlados, leitura humana e tratamento HQ. Cores, materiais e roupa propostos ainda não são aparência aprovada. Próximo passo: validar a direção e produzir uma referência mestre de Vega antes de refazer as cartas; retrato, corpo e braços devem derivar da mesma base. Nenhuma imagem gerada, código ou regra alterada; não foram executados testes de gameplay. Verificação realizada foi leitura documental e inspeção da referência visual.

## Nove cartas com artes HQ próprias integradas — 21/10/2026

Relato do usuário: autorizou “terminar o restante das cartas”, considerando a direção conceitual estabelecida. O escopo passou de aprovar uma prova por vez para concluir o catálogo atual, preservando a linguagem de Golpe/Proteção. Essa autorização não equivale à aprovação individual posterior das seis imagens novas nem à conclusão artística do jogo inteiro.

Observado: faltavam seis ilustrações próprias e Quebra-chassi ainda usava a arte anterior. Criadas com a skill `imagegen` e a ferramenta integrada as artes de Direto Hidráulico, Brecha, Pulso Debilitante, Golpe de Aríete, Ruptura de Pressão e Placa Reforçada. Referências: Golpe/Proteção aprovados, mantendo enquadramento de ações/equipamentos, tinta forte, sombras recortadas e cor chapada. Hipótese visual: pistão, junta vulnerável, ondas, impacto pesado, vazamento e blindagem em camadas distinguem as cartas sem redesenhar a personagem inteira. Quebra-chassi recebeu a imagem de ruptura da prova anterior.

`botao_carta.gd` agora resolve explicitamente nove ilustrações exclusivas; não há fallback visual compartilhado entre cartas diferentes. `carta.tscn` também referencia a nova arte de Quebra-chassi. Os mesmos componentes atendem mão, recompensas e descanso; aprimoradas mantêm a imagem base. Preservadas imagens antigas e provas anteriores. Nenhum custo, valor, dano, Barreira, Combo, Exposto, Enfraquecido, compra ou limite de mão foi alterado; arenas/personagens/HUD não foram redesenhados neste passe.

Verificação real na Godot `4.7.2.stable.official.ed1daf0bf`: importação headless retornou 0. Oito testes focados retornaram 0: `test_hud_conceito_ativo`, `test_catalogo_cartas`, `test_resolucao_cartas`, `test_apresentacao_recompensas`, `test_apresentacao_descanso`, `test_ciclo_descanso`, `test_mao_hq`, `test_hud_compacto`. O teste de conceito exige ID/arquivo correto, nove caminhos distintos, cobertura do catálogo e a imagem das nove cópias aprimoradas criadas pelo fluxo real da mão. Suíte completa não repetida.

`tests/capturar_catalogo_cartas_hq.gd` executou com código 0 em OpenGL Compatibility, sem substituir texturas, e gerou 39 PNGs com OK em `docs/evidencias_catalogo_cartas_hq/`: duas mãos de nove cartas em 1920×1080/1024×576, foco de cada carta nas duas resoluções, 18 recortes reais e uma prancha do componente real. Foram inspecionadas a prancha, as duas mãos e os seis recortes novos em 1024. Sem erros de script/parse observados; persistem avisos conhecidos de RID/texturas/ObjectDB/recursos ao encerrar. `git diff --check` passou. Capturas não equivalem à avaliação artística/playtest do usuário.

Arquivos, mapeamento, prompts finais, fontes e reprodução em `docs/arte_vega/catalogo_cartas_hq.md`. Próxima verificação pequena: comparar Golpe/Direto e Proteção/Placa no jogo e abrir uma carta aprimorada no descanso para observar que sua imagem base é preservada.

## Proteção integrada e prova de Quebra-chassi — 21/10/2026

Relato do usuário: aprovou também Proteção (“parece ótimo também”) e autorizou continuar. Aplicada a arte aprovada somente a essa carta; a prova de Quebra-chassi apresentada nesta etapa ainda aguarda avaliação artística.

Observado: Proteção compartilhava textura com Pulso Debilitante e Placa Reforçada. `botao_carta.gd` agora separa a arte aprovada de Proteção da arte provisória dessas outras habilidades; `carta.tscn` referencia o novo arquivo para Proteção. Golpe mantém a arte aprovada anteriormente. Arquivos antigos preservados; nenhuma regra de dano, custo, Barreira, Combo ou finalização mudou.

Após verificar a integração, criada `assets/ui/runtime/cartas/arte_quebra_chassi_ruptura_hq_prova.png` com a skill `imagegen` e a ferramenta integrada. Hipótese visual: mostrar a consequência do ataque — carcaça dobrada/rompida e estrutura interna partida — distingue a finalização do impacto simples de Golpe, sem desenhar a personagem inteira. A imagem não acrescenta remoção de Barreira, morte garantida ou dano elétrico. A arte ativa de Quebra-chassi permanece a anterior até aprovação.

Verificação real na Godot `4.7.2.stable.official.ed1daf0bf`: importação headless terminou com código 0. `test_hud_conceito_ativo`, `test_catalogo_cartas` e `test_apresentacao_recompensas` passaram com código 0; a expectativa de textura verifica Golpe/Proteção aprovados e preserva as outras sete cartas. A prévia `tests/capturar_prova_golpe_hq.gd -- --quebra-chassi` terminou com código 0 e salvou 12 capturas com OK em `docs/evidencias_quebra_chassi_ruptura_hq/`, nas duas resoluções, com repouso/foco e recortes. Foram inspecionados os recortes da candidata em 1920×1080 e 1024×576, a cena pequena com a prova e a cena grande com as artes ativas antes da troca isolada. Não foram observados erros de script/parse; persistiram avisos conhecidos de RID/texturas/ObjectDB/recursos ao encerrar. `git diff --check` passou. Suíte completa não repetida; capturas não aprovam arte pelo usuário.

Prompt/caminhos/reprodução em `docs/arte_vega/quebra_chassi_ruptura_hq_prova.md`. Próximo passo: avaliar a prova de Quebra-chassi antes de aplicá-la. Exercício opcional: no combate normal, comparar Proteção com Golpe; bloqueio e ataque devem ser distinguíveis pela composição sem depender do título.

## Golpe integrado e primeira prova de Proteção — 21/10/2026

Relato do usuário: “agora sim temos uma arte boa”, aprovando a prova de impacto de Golpe. Na sequência autorizou aplicar somente a Golpe e seguir para a prova de Proteção. A nova candidata de Proteção ainda não foi aprovada.

Observado: `botao_carta.gd` compartilhava a arte de Golpe com quatro outros ataques. Para não substituir imagens não autorizadas, `_obter_arte()` agora separa `golpe` dos demais. A arte aprovada em `arte_golpe_impacto_hq_prova.png` é usada por Golpe; Direto Hidráulico, Brecha, Golpe de Aríete e Ruptura de Pressão mantêm a arte provisória anterior. `carta.tscn` aponta a referência de Golpe para o arquivo aprovado. Texturas antigas e primeiras provas preservadas; custo, dano, Barreira e fluxo não mudaram.

Após verificar essa integração, criada `assets/ui/runtime/cartas/arte_protecao_bloqueio_hq_prova.png` com a skill `imagegen` e a ferramenta integrada. Hipótese visual: o detalhe de um antebraço blindado interceptando uma pancada comunica defesa sem repetir o corpo da personagem. Mantém os equipamentos e a linguagem gráfica de Golpe, sem escudo de energia ou efeito elétrico. A imagem é usada somente na prévia; a arte de Proteção no jogo normal e nas outras habilidades permanece intacta.

Verificação real na Godot `4.7.2.stable.official.ed1daf0bf`: importação headless terminou com código 0. `test_hud_conceito_ativo`, `test_catalogo_cartas` e `test_apresentacao_recompensas` passaram com código 0. O teste de conceito verifica a nova arte de Golpe e a preservação dos recursos das outras oito cartas. `tests/capturar_prova_golpe_hq.gd` aceita `-- --protecao`, mantendo os argumentos antigos; gerou 12 capturas com OK e execução 0 em `docs/evidencias_protecao_bloqueio_hq/`, com 1920×1080/1024×576, repouso/foco e recortes da carta. Foram inspecionados os recortes da candidata nas duas escalas, a cena pequena com a prova e a cena grande com as artes ativas antes da troca isolada. Sem erros de script/parse observados; avisos conhecidos de RID/texturas/ObjectDB/recursos permanecem ao encerrar. `git diff --check` passou. Suíte completa não repetida; captura não equivale à aprovação da nova arte.

Prompt e reprodução em `docs/arte_vega/protecao_bloqueio_hq_prova.md`. Próximo passo: avaliar a prova de Proteção antes de aplicá-la. Exercício opcional: iniciar um combate normal e comparar Golpe com Direto Hidráulico; somente Golpe deve ter a arte de impacto aprovada.

## Golpe por detalhe de impacto, sem personagem — 21/10/2026

Relato do usuário: a primeira prova parece boa, mas o braço está estranho; representar a ação sem redesenhar a personagem pode ser uma direção melhor. Autorizou a composição de punho mecânico e pulso curto contra uma chapa. Isso não é aprovação automática da nova imagem.

Regra mantida: Golpe continua sendo ataque básico, sem dano elétrico, destruição especial ou mudança de efeito. Hipótese artística: o detalhe do contato comunica a ação com menos dependência de anatomia e preserva a identidade pelo equipamento, materiais e cores. Criada `assets/ui/runtime/cartas/arte_golpe_impacto_hq_prova.png` usando `imagegen` integrado, com referências de traço e equipamento. Primeira prova e arte ativa preservadas. Não houve troca de arte no jogo normal nem expansão às outras cartas/arenas.

`tests/capturar_prova_golpe_hq.gd` aceita agora `-- --impacto`, mantendo o comportamento anterior sem argumento. A prévia altera somente as texturas das instâncias de Golpe e salva em pasta separada. Execução real na Godot `4.7.2.stable.official.ed1daf0bf` terminou com código 0 e gerou 12 capturas com OK em `docs/evidencias_golpe_impacto_hq/`. Foram inspecionados os recortes da candidata em 1920×1080 e 1024×576 e a cena pequena completa: punho/contato permanecem no enquadramento. Sem erros de script/parse observados; avisos conhecidos de RID/texturas/ObjectDB/recursos persistem ao encerrar. `git diff --check` passou. Suíte de regras não repetida; candidata ainda depende da avaliação artística do usuário.

Prompt completo, caminhos e reprodução em `docs/arte_vega/golpe_impacto_hq_prova.md`. Próximo passo: avaliar esta composição antes de ativar a arte ou estender a linguagem. Exercício opcional: rodar a prévia com e sem `--impacto` e comparar as imagens em escala real.

## Prova gráfica de Golpe — 21/10/2026

Relato do usuário: gostou do polimento geral, mas rejeitou artisticamente as arenas novas e as ilustrações das cartas por parecerem genéricas e pouco HQ. Autorizou uma única prova de Golpe antes de expandir a nova linguagem. A composição da HUD continua aprovada; a candidata abaixo ainda não foi aprovada pelo usuário.

Observado ao comparar os arquivos: a arte anterior concentra reflexos, faíscas e um punho em primeiro plano; as arenas novas usam renderização mais cinematográfica que gráfica. Proteção também diverge da identidade de Vega. Regra mantida: braços protéticos reconhecíveis e leitura dos efeitos independente da ilustração. Hipótese desta prova: contornos fortes, sombras recortadas, fundo simplificado e rosto separado do punho favorecem leitura e unidade com o desenho atual de Vega.

Criada `assets/ui/runtime/cartas/arte_golpe_vega_hq_prova.png` com a skill `imagegen` e a ferramenta integrada, usando a Vega de corpo inteiro como referência de identidade. Original gerado e arte anterior preservados. Não houve troca da arte no jogo normal, alteração das outras cartas, arenas, HUD ou regras. Prompt completo, caminhos e reprodução em `docs/arte_vega/golpe_hq_prova.md`.

Verificação executada: `tests/capturar_prova_golpe_hq.gd` instancia a cena real e altera somente as texturas das instâncias de Golpe daquela prévia. Gerou 12 PNGs em `docs/evidencias_golpe_hq/`: comparação atual/prova, mão/foco, em 1920×1080 e 1024×576, mais quatro recortes das cartas focadas. As capturas da candidata nas duas escalas, a anterior em escala pequena e a cena pequena foram inspecionadas visualmente. A área local da ilustração mede cerca de 123×114 px e 86×79 px antes da ampliação de foco. Não apareceram erros de script, parse ou shader nessa execução; persistiram avisos de recursos/RID/ObjectDB ao encerrar. Não foi executada a suíte de regras; esta verificação de apresentação não equivale à aprovação artística.

Próximo passo: o usuário avaliar a candidata dentro da moldura antes de substituir Golpe ou gerar outras artes. Exercício opcional: executar a prévia e comparar o rosto e o punho na captura de 1024 px, sem ampliar a imagem.

## Polimento de interação, arenas e presença dos combatentes - 20/10/2026

Relato do usuário: satisfeito com a composição da HUD. Autorizou avançar no polimento geral: animações, tooltips antigas, retirada dos quadrados de hover, botão de turno, Energia, novas arenas e personagens integrados ao espaço, incluindo movimento do robô. Essa aprovação é da composição anterior; o resultado deste passe ainda depende do playtest do usuário.

Observado no código e nas capturas: tooltips de cartas ainda usavam a textura clara do tema HQ e uma ponta de balão; controles tinham bordas de hover sobre suas caixas de layout; o núcleo ilustrado disputava contraste com a Energia; havia um único cenário; a respiração de Vega levantava toda a ilustração e os drones dos encontros duplos ficavam acima de suas placas, longe da linha de piso. Regra mantida: animação é apresentação, não autoridade sobre dano, custo, turno ou alvo. Hipótese visual aplicada: superfície estável atrás dos números, luz seguindo os recortes, sombras de apoio e suspensão motorizada tornam o conjunto mais legível e menos destacado do mundo.

Implementado sem redesenhar os módulos da HUD:

- `hud_neon/tooltip.svg`/`tooltip.tres` substituem o balão claro nas cartas e na inspeção. Texto claro, margens e frisos discretos; inspeções separam título ciano do corpo. A ponta antiga fica desativada. Entrada por mouse usa fade cúbico de 0,125 s; foco de teclado exibe diretamente. O texto de ataque básico explica resolução contra Barreira em vez do aviso solto “Sem ganho de Combo”. Tooltips protegem também a arte das cartas vizinhas. A busca de encaixe da inspeção considera as bordas dos bloqueios: a grade anterior saltava um espaço válido estreito em 1024×576 quando o painel ficou mais alto.
- `hud_neon/realce.gd` usa luz nos recortes e friso nas placas inimigas, em vez de retângulos de layout. O realce do turno usa a área efetivamente desenhada do PNG, não a caixa mais alta do Button. Mouse pressiona em 0,10 s e retorna em 0,16 s; confirmar produz feedback local breve. Ao zerar Energia, um friso discreto sinaliza Encerrar turno. Teclado mantém indicação de foco e não recebe a compressão de hover; movimento reduzido elimina a varredura. A lógica continua resolvendo no clique, sem await de animação.
- `hud_neon/placa.gd` acrescenta disco escuro e arco proporcional no núcleo da Energia; números maiores e estáveis, inclusive em zero. Os preenchimentos aprovados de Barreira/Combo e a Vida integrada permanecem.
- Duas ilustrações inéditas em `assets/arenas/`: pátio de contêineres e estação de bombeamento, geradas com a ferramenta integrada `imagegen`. Arquivos e prompts finais estão em `assets/arenas/README.md`. O cais anterior permanece. `arena_chao.gd` escolhe a arte por identificador do encontro sem consumir RNG e faz crossfade de 0,25 s; no modo reduzido, troca diretamente. Não são distritos novos nem alterações das regras das Docas.
- `hud_neon/drone_animado.gd` anima uma ilustração existente com suspensão, inclinação, impulso do motor, investida, recuo e reação de suporte. A caixa de clique fica imóvel; a placa de dados não acompanha o corpo. Sombras suaves ficam no piso compartilhado com Vega; nos duplos, placas ficam acima dos corpos. É animação do recorte completo, não um rig articulado novo ou poses desenhadas por golpe.
- `vega_animada/vega_playtest.gd` respira por escala mínima com pivô no piso, sem levantar os pés. Duas sombras de contato acompanham as botas e uma sombra difusa dá apoio. Tintura fria suave aproxima os recortes da luz das Docas; dano continua com feedback magenta. Movimento reduzido interrompe respiração, suspensão e deslocamentos, mantendo leitura/feedback de cor.

As skills `animate` e `impeccable` orientaram feedback breve, interrompível, preservação da composição e duas rodadas visuais limitadas; `imagegen` produziu os dois fundos raster, copiados para o projeto sem apagar os originais. Não foi instalado plugin ou biblioteca de animação. Todo o movimento implementado usa recursos nativos da Godot.

Verificação real na Godot `4.7.2.stable.official.ed1daf0bf`: 18 cenas focadas tiveram execução final com código 0 — `test_polimento_combate`, `test_vega_playtest`, `test_hud_compacto`, `test_layout_combate`, `test_mao_hq`, `test_hud_neon_shell`, `test_hud_neon_combate`, `test_hud_conceito_ativo`, `test_hud_r2`, `test_hud_r3`, `test_composicao_combate`, `test_composicao_suave`, `test_interacao_hud_combate`, `test_bestiario_visual`, `test_catalogo_cartas`, `test_apresentacao_recompensas`, `test_apresentacao_recompensa_elite` e `test_apresentacao_descanso`. O teste novo verifica arenas, sombra no piso, caixas de clique imóveis, substituição de movimento, foco, resolução imediata do turno, ataque inimigo real e modo reduzido nas duas resoluções. O teste de Vega agora exige respiração sem translação; o de recompensa protege ilustrações e contrasta o novo tooltip. Uma falha inicial mostrou que instalar o script do drone num nó já pronto não ativava seu processamento; `preparar()` passou a ativá-lo explicitamente e o teste passou.

`tests/capturar_polimento.gd` gerou 18 capturas GL reais em `docs/evidencias_polimento/`, com 1024×576 e 1920×1080: três arenas, dupla, inspeção, Energia zero/foco, confirmação do turno, quadro da investida e tooltip de recompensa. Quadros representativos de ambas as rodadas foram inspecionados; capturas estáticas e testes não aprovam a sensação do movimento pelo usuário. Capturas de ação usam fixture explícita de apresentação; o ataque real é exercitado no teste automatizado.

Ressalva de estabilidade: a primeira importação headless e uma execução paralela de `test_hud_neon_shell` encerraram com violação de acesso nativa (`-1073741819`), esta última após imprimir OK. Repetições isoladas do teste e da importação retornaram 0; a causa não foi determinada e não é declarada corrigida. Permanecem avisos conhecidos de RID/ObjectDB/recursos no encerramento. `git diff --check` retornou 0. A suíte completa não foi repetida, e a falha nativa anterior de descanso continua registrada.

Próximo teste manual curto: passar o mouse numa recompensa, consumir Energia até zero e encerrar o turno de ataque de um drone; comparar também Movimento reduzido. Exercício opcional: reduzir de 4,0 para 2,0 o multiplicador vertical da suspensão em `drone_animado.gd` e observar como a sombra mantém o apoio sem alterar o alvo do clique.

## HUD compacta, intenção agrupada e relíquias identificadas - 20/10/2026

Relato do usuário: o jogo está melhorando, mas intenções, relíquias e textos ainda pareciam elementos soltos; o cais de cartas cobria Energia e Encerrar turno. A solicitação foi melhorar composição e tipografia preservando a linguagem visual já encaminhada.

Estado observado: a moldura ocupava quase toda a largura, sem reservar as colunas dos controles; o nome da ação estava separado do ícone/valor; textos das cartas compartilhavam profundidade com as molduras vizinhas. Também havia dois indicadores de Marcado e de estado especial sendo criados na raiz, um por alvo múltiplo. Regra de design: dados e efeitos não mudam; a HUD deve agrupar informação por dono, manter os números reais e preservar mouse/teclado. Hipótese visual implementada para avaliação: três colunas inferiores e resumos curtos reduzem sobreposição e esforço de leitura.

Implementado em `main.gd`, `hud_neon/apresentacao_combate.gd`, `hud_neon/cais_cartas.gd`, `mao_combate.gd`, `botao_carta.gd`, `carta.tscn` e `hud_inspecao.gd`:

- Energia/pilhas e medidores na coluna esquerda, cartas no centro, ação de turno na direita. A moldura usa NinePatchRect com os cantos ilustrados preservados; sua largura depende dos controles laterais, não da viewport inteira. A mão reserva margem para a ampliação das cartas das pontas. O aviso de mão cheia tem placa própria acima de Encerrar turno.
- Intenção reúne tipo, ícone e valor no selo direito: ATACA, DEFENDE, PROTEGE, PREPARA etc. Preparação mostra bônus por golpe; multiplicidade de ataque permanece explícita. Nome completo, alvo do suporte e condições continuam na inspeção. Estados comuns e efeitos especiais ficam dentro da placa inimiga; Marcado usa a faixa superior da Vega. Os indicadores especiais são únicos.
- Relíquias usam ícone e nome curto nos encaixes, com nome/efeito completos por hover ou foco. A inspeção procura espaço livre sem cobrir personagens, placas ou controles nos cenários testados, em vez de impor uma posição fixa no campo. O fallback para uma tela totalmente ocupada continua limitado à viewport; não há promessa de ausência universal de colisões.
- Barlow condensada em títulos, números e corpo; peso forte distingue títulos/valores. Títulos de cartas ajustam tamanho sem quebrar em duas linhas. Cada carta mantém sua própria pilha de arte/texto, evitando que letras atravessem a moldura seguinte. Energia recebeu profundidade e contorno corretos sobre o núcleo luminoso. Mira, recolhimento local, animações de recursos e Vida integrada foram preservados, sem plugin novo.

A comparação com as capturas também corrigiu a medição dos títulos: `Font.get_string_size` recebe largura antes de tamanho da fonte; chamadas de ajuste e seus testes passaram a informar `-1` e o tamanho real na quarta posição, conforme a [referência oficial da Godot 4.7](https://docs.godotengine.org/en/4.7/classes/class_font.html#class-font-method-get-string-size). Os testes de HUD compacta, layout e recompensas foram repetidos com código 0 após essa correção.

Verificação executada na Godot `4.7.2.stable.official.ed1daf0bf`: 15 cenas de teste focadas terminaram com código 0 (`test_hud_compacto`, `test_mao_hq`, `test_layout_combate`, `test_hud_conceito_ativo`, `test_composicao_combate`, `test_bestiario_visual`, `test_hud_r2`, `test_hud_r3`, `test_composicao_suave`, `test_interacao_hud_combate`, `test_hud_neon_shell`, `test_hud_neon_combate`, `test_apresentacao_recompensas`, `test_apresentacao_recompensa_elite`, `test_apresentacao_descanso`). As variantes Sentinela e Guindaste de `test_bestiario_visual` também retornaram 0 após corrigir a duplicação. O teste da mão agora confere os cantos transformados da primeira, central e última carta focada com 6/10 cartas em 1024×576 e 1920×1080, colisões com controles/medidores, input real e ordem das camadas. O teste novo cobre tipos de intenção do catálogo comum/elite/Docas, relíquias e inspeções. Contratos antigos que exigiam nome longo fora do selo, estados fora da placa e medidores não inspecionáveis foram atualizados para a composição vigente.

Capturas GL reais geradas por `tests/capturar_hud_compacto.gd` em `docs/evidencias_hud_compacto/`: 20 imagens em 1024×576 e 1920×1080, incluindo 6/10 cartas em repouso/foco, três relíquias, inspeção, três estados, preparação, dupla, marca e recalibração. Foram inspecionadas visualmente; não equivalem à aprovação do usuário. Importação headless e `git diff --check` retornaram 0. Permanecem avisos conhecidos de recursos/RID/ObjectDB ao encerrar. A suíte completa não foi repetida; sua falha nativa anterior permanece registrada.

Exercício opcional: variar `intervalo_cais` em `_layout_hud_combate()` de 12 para 16 e observar a folga lateral em janela pequena, sem alterar a escala das cartas ou regras do combate.

## Vida de Vega encaixada e transição de dano corrigida - 20/10/2026

Relato do usuário: aprovou o resultado dos medidores de Barreira/Combo e pediu corrigir a Vida de Vega, ainda percebida como bugada, antes de avaliar as próximas melhorias da HUD. A aprovação dos medidores não é aprovação automática desta correção da Vida.

Estado observado em `hud_neon/barra_vida.gd` e `main.gd`: a peça nativa tinha altura maior que o encaixe e invadia a área de Relíquias; o preenchimento máximo terminava em 70% da largura do controle, sem uma separação clara de leitura; e `definir_valor()` cancelava a transição mesmo ao receber repetidamente o mesmo valor. A direção do design continua sendo coração/trilho integrados, números imediatos e animações sem autoridade sobre o estado do combate. Hipótese visual implementada: a peça menor no encaixe, o trilho proporcional completo e um rastro breve tornam o dano legível sem cobrir as relíquias.

Implementado: coração com lobos arredondados e contorno ligado ao trilho; posição e altura ajustadas ao espaço da arte; número centralizado no lado direito, com fonte de HUD e contorno escuro. O preenchimento percorre todo o intervalo útil, inclusive atrás dos números, e não é encoberto por uma placa opaca nessa região. A animação existente é preservada quando o destino não muda. Dano interpola em 0,20 s, com rastro claro que começa a recolher depois de 0,06 s e termina em mais 0,20 s; recuperação interpola em 0,24 s e substitui a perda anterior. O contorno recebe feedback curto magenta no dano e ciano na recuperação. Movimento reduzido atualiza preenchimento/rastro diretamente. A skill `animate` orientou feedback breve e interrompível, com leitura numérica imediata. As regras de Vida, derrota, dano e recuperação não foram alteradas.

Na primeira captura GL surgiu um erro de triangulação quando o preenchimento quase vazio colapsava numa linha antes de chegar a zero. O recorte agora descarta larguras menores que 0,01 px, e a captura final não apresentou erro de desenho nem de script. Essa correção afeta somente geometria subpixel, não o valor de Vida.

Verificação real na Godot `4.7.2.stable.official.ed1daf0bf`: seis cenas focadas passaram com código 0 — `test_composicao_suave`, `test_hud_r3`, `test_layout_combate`, `test_hud_neon_shell`, `test_hud_conceito_ativo` e `test_bestiario_visual`. A regressão de composição verifica separação da Vida/Relíquias em 1024×576 e 1920×1080, número contido na peça, rastro de dano, atualizações repetidas, 1 HP/zero, recuperação e inversão de dano para recuperação durante a transição. Importação headless e `git diff --check` retornaram 0. Permanecem avisos conhecidos de recursos/RID/ObjectDB ao encerrar; a suíte completa não foi repetida e sua falha nativa anterior continua registrada.

Foram geradas 12 capturas anteriores em `docs/evidencias_vida_vega_antes/` e 12 capturas finais em `docs/evidencias_vida_vega/` por `tests/capturar_vida_vega.gd`. As finais incluem dano pela intenção real do Drone de Segurança nas duas resoluções, além de valores de fixture para Vida cheia, 20/40, 1/40, 0/40 e 32/40. A volta de zero para 32 é exclusivamente fixture de apresentação, sem implicar uma mecânica de reanimação. Quadros de Vida cheia, dano, meia Vida e zero foram inspecionados; captura não equivale a playtest humano da sensação.

Sugestões seguintes, ainda não implementadas: prévia do dano ao mirar, distinguindo Barreira e perda de Vida; estados compactos junto da placa inimiga; tooltips que evitem cobrir a Vega em 1024×576. A prévia é a recomendação de maior valor para a decisão do jogador e deve compartilhar as regras reais de resolução. Exercício curto opcional: em `barra_vida.gd`, testar `tween_interval(0.04)` no rastro em vez de `0.06`, comparar dois golpes e voltar se o rastro ficar rápido demais.

## Medidores de Barreira e Combo com carga e descarga - 20/10/2026

O usuário autorizou seguir a recomendação da revisão anterior. Regra mantida: Barreira absorve dano e Combo é consumido por Finalização; os recursos não recebem teto mecânico pela quantidade de células desenhadas. Este passe trata da apresentação desses medidores, sem alterar cartas, dano, custos, turnos ou a mira aprovada.

Estado observado: as posições antigas usavam centros diferentes dos encaixes reais dos PNGs; o preenchimento de Combo era retangular, e parte do feedback mirava ícones ocultos. Hipótese visual implementada para avaliação do usuário: escudo/número centralizados e preenchimento seguindo as peças da arte tornam ganho e consumo mais claros que rótulos soltos e um pulso sobre toda a placa.

Implementado em `main.gd` e `hud_neon/`: Barreira mostra escudo e número, com explicação por hover/foco no módulo; o rótulo permanente BARREIRA foi removido. COMBO fica dentro do hexágono, junto do número. `placa.gd` considera o tamanho real da arte proporcional: as células de Barreira carregam de baixo para cima e os sete segmentos de Combo recebem polígonos inclinados, gradiente e uma borda clara na frente da carga. Cada célula de Barreira segue representando visualmente até cinco pontos; os contadores reais continuam sem teto. Atualizações repetidas com o mesmo destino preservam o Tween em andamento, em vez de reiniciá-lo.

Os valores visuais usam Tween cúbico com saída rápida: ganho em 0,24 s e esvaziamento em 0,16 s. A biblioteca `hud_neon/animacoes_recursos.tres` e os nós `AnimacaoComboHUD`/`AnimacaoBarreiraHUD` em `main.tscn` permitem editar os pulsos no AnimationPlayer: ganho destaca os segmentos recebidos; Finalização percorre os segmentos consumidos; dano na Barreira ilumina o hexágono e a quebra solta pequenos traços locais. As sequências duram de 0,20 a 0,26 s e são substituíveis por novos eventos. Movimento reduzido usa valores finais imediatos e apenas um fade de cor de 0,12 s, sem varredura ou fragmentos. A skill `animate` orientou feedback breve, interrompível e reduzido; não foi instalado plugin novo.

Verificação real na Godot `4.7.2.stable.official.ed1daf0bf`: os oito testes focados `test_hud_neon_shell`, `test_composicao_suave`, `test_hud_r2`, `test_hud_conceito_ativo`, `test_layout_combate`, `test_interacao_hud_combate`, `test_composicao_combate` e `test_mao_hq` terminaram com código 0. O contrato de input do teste do conceito foi atualizado: módulos de recursos agora aceitam inspeção; peças decorativas continuam ignorando mouse. O teste de feedback cobre ganho simultâneo, substituição pela descarga, retorno ao repouso, inspeção no módulo visível, modo reduzido e recursos acima da capacidade desenhada. Importação headless e `git diff --check` retornaram 0. Permanecem os avisos de recursos/RID/ObjectDB no encerramento; a suíte completa não foi repetida neste passe, e sua falha nativa registrada antes continua pendente.

Doze capturas reais GL Compatibility foram geradas por `tests/capturar_medidores.gd` em `docs/evidencias_medidores/`, cobrindo vazio, carga, carregado, descarga, quebra e inspeção nas resoluções 1024×576 e 1920×1080. Foram inspecionados os encaixes e quadros de transição. O script usa valores de fixture para mostrar vários segmentos/células; o uso real de cartas é exercitado nos testes. Capturas estáticas e verificações numéricas não equivalem à aprovação da sensação do movimento pelo usuário.

Próximo teste curto: jogar Direto Hidráulico, ganhar Barreira com Proteção e consumir o Combo com Quebra-chassi; comparar o modo normal ao reduzido. Exercício opcional no editor: abrir `main.tscn`, selecionar `AnimacaoComboHUD`, escolher `combo_ganho` e mover o pico de brilho de 0,08 s para 0,12 s, mantendo o fim em 0,24 s; comparar e desfazer se preferir o original.

## Revisão dos medidores e consulta sobre plugins - 20/10/2026

Relato do usuário: a seta ficou ótima; os textos de Barreira/Combo ainda parecem fora dos encaixes e pouco úteis, e o preenchimento de Combo continua fraco. A aprovação da seta não abrange os medidores. O usuário perguntou sobre plugins que ajudem a melhorar essas animações.

Inspeção somente de código e documentação: `hud_neon/placa.gd::animar_valores()` interpola os três recursos com a mesma curva quadrática e duração de 0,22 s. O Combo desenha retângulos baixos dentro da arte inclinada e usa um pulso sobre a área geral. `hud_neon/feedback_combate.gd` tenta realçar `BarreiraIcone` e `ComboIcone`, que a apresentação ativa mantém ocultos; isso não produz o realce esperado no módulo visível. O posicionamento dos rótulos segue proporcional ao retângulo externo, sem um encaixe dedicado na arte. A avaliação de sensação/posição desta revisão é relato do usuário e hipótese a partir do código; não houve novo playtest ou captura.

A consulta ao catálogo de plugins por Godot/animação retornou ferramentas de vídeo e Figma, sem um resultado especializado em animar a HUD nativa da Godot. Isso não demonstra ausência em todo o diretório. Foram consultadas as referências oficiais de Tween/AnimationPlayer: Tween atende a valores dinâmicos; AnimationPlayer permite compor e ajustar sequências no editor. As skills `plugin-management` e `review-animations` orientaram esta consulta e revisão. Nenhum plugin foi instalado, nenhuma regra ou animação foi alterada e nenhum teste foi executado neste passe.

Recomendação para o próximo ajuste: preencher o formato inclinado dos segmentos de Combo, realçar o segmento recém-carregado e distinguir ganho de consumo; direcionar o feedback de Barreira ao módulo visível. Rever os rótulos permanentes e a leitura numérica sem sugerir tetos mecânicos, pois Combo não possui teto e as células de Barreira são somente representação. Essa proposta ainda não foi implementada nem aprovada visualmente. Pequeno exercício de inspeção no editor: selecionar `BarreiraIcone` e conferir sua propriedade Visible para reconhecer por que uma animação nesse nó não aparece.

## Mira de cartas e encaixe dos textos - 20/10/2026

Relato do usuário: a HUD está bem encaminhada, mas ainda havia textos soltos e o voo da carta parecia entregá-la ao inimigo; pediu uma seta de direcionamento. Esse relato substitui a aprovação presumida do voo descrito no registro anterior.

Estado observado: `botao_carta.gd` levava a carta até o alvo e o foco recebido pelo mouse podia encerrar a transição de seleção instantaneamente. Os títulos de Relíquias/Cartas e as legendas de recursos ficavam fora dos encaixes; o número de Vida inimiga ficava abaixo da barra. A inspeção de capturas revelou ainda que `Alvo` conservava um mínimo de 150 px em `main.tscn`, deslocando a arte proporcional em 1024×576 sem deslocar os textos. Nos alvos duplos, intenção e multiplicidade dividiam um rótulo que invadia a Vida.

Regra mantida: custos, dano, descarte e alvos válidos continuam determinados pelo estado de combate, conforme `GAME_DESIGN.md` §10. Hipótese de apresentação a validar pelo usuário: manter a carta na mão e mostrar uma seta com retículo distingue seleção de ataque e elimina a leitura de “entregar a carta”.

Implementado: `hud_neon/mira_carta.gd` desenha a seta curva e o retículo sem capturar input. `main.gd` identifica o alvo sob o mouse ou focado pelo teclado; inimigo/Vega recebem mira magenta/ciano, e alvo inválido ou Energia insuficiente deixa a seta neutra. Botão direito e Esc cancelam sem custo. A confirmação recolhe a carta junto do cais por 0,16 s, sem atravessar o campo; o impacto e os valores reais acontecem no clique. As outras cartas deslizam para ocupar o espaço. O modo reduzido mantém somente o fade de consumo. A skill `animate` orientou o movimento breve de feedback, interrompível e separado das regras.

`hud_neon/apresentacao_combate.gd` e `main.gd` removem os títulos redundantes de Cartas/Relíquias, centralizam o ícone de relíquia no encaixe e acomodam Barreira/Combo dentro dos medidores. Vida inimiga fica dentro do trilho; intenção e valor ficam em regiões separadas também nos combates duplos. Estes sobem para não disputar espaço com a carta selecionada em 1024×576. Estados longos são contidos na placa e permanecem completos na inspeção. Foi removido apenas o mínimo vertical legado do botão `Alvo`; nenhuma regra de carta, compra ou inimigo foi alterada.

Verificação executada na Godot `4.7.2.stable.official.ed1daf0bf`: importação headless retornou **0**, sem erro de script. A passagem completa terminou **72/73 processos com código 0**; `test_apresentacao_descanso_resultado_neon.tscn` imprimiu “OK: descanso e resultados com apresentacao neon”, mas encerrou com violação de acesso nativa (`-1073741819`). A mesma saída ocorreu em uma execução isolada; a causa não foi determinada neste passe. Não se declara a suíte completamente verde. Permanecem avisos de recursos/RID/ObjectDB no encerramento.

Depois dos ajustes finais, `test_composicao_suave` e `test_hud_r3` passaram isolados. `test_bestiario_visual` expôs uma dependência da mão inicial aleatória; a fixture passou a fornecer explicitamente Golpe, sem mudar o embaralhamento do jogo, e passou em **1024×576 e 1920×1080**. As verificações cobrem alvo válido/inválido, Energia insuficiente, troca mouse/teclado, cancelamento, consumo local, dano imediato e separação de intenção/Vida. Seis capturas reais GL Compatibility foram geradas em `docs/evidencias_mira_carta/`; mira ofensiva, Proteção, confirmação e combate duplo foram inspecionados visualmente. Capturas não validam sozinhas a sensação do movimento nem substituem playtest humano.

Próximo teste curto: selecionar Golpe, apontar para cada inimigo e cancelar com botão direito; depois usar Proteção em Vega. Verificar se a mira comunica a escolha e se o recolhimento parece uma confirmação. Exercício opcional: em `botao_carta.gd::animar_consumo`, trocar o deslocamento vertical de `12.0` para `8.0`, comparar a sensação e voltar se preferir, sem tocar no custo ou no dano.

## Composição e movimento da HUD de combate - 20/10/2026

Relato do usuário: a troca de arte melhorou bastante, mas a seleção/uso de cartas continuava dura; os botões de Baralho, Rota e Configurações dividiam a região central superior com a Vida inimiga; o coração não formava uma peça com a barra de Vida do esboço; medidores e caixas sobrepostas precisavam de movimento e composição mais claros. Esse relato é avaliação de jogo do usuário, não um resultado automatizado.

Estado observado: em `main.gd`, os botões utilitários ficavam entre as placas de Vega e do inimigo; `TopoCoracao` era separado da `ProgressBar`; Energia, Barreira, Combo e Vida saltavam direto entre preenchimentos. `botao_carta.gd` destacava pouco a seleção e a carta sumia no clique do alvo. A inspeção genérica “RECURSOS” podia cobrir o cais apenas ao passar o mouse pelo painel. Uma captura intermediária revelou ainda que o número do dano surgia antes da chegada da carta e que o valor `40/40` encostava no preenchimento. A lista de controles de combate também reexibia `DanoFeedbackLabel` ao iniciar um encontro, mesmo sem golpe.

Regra de design: `GAME_DESIGN.md` §10 mantém números e estado de combate como fonte de verdade; movimento comunica a consequência, sem atrasar custo, dano, compra ou turnos. Hipótese visual ainda sujeita à avaliação do usuário: coração/trilho integrados, medidores interpolados e a placa inimiga abaixo dos utilitários melhoram a leitura nas duas resoluções testadas.

Implementado: `main.gd` reserva o topo direito para os três botões, coloca a placa inimiga abaixo deles e posiciona a inspeção da rota em área livre. `hud_neon/barra_vida.gd` desenha o coração ligado ao trilho de Vega e interpola o preenchimento da Vida de Vega e do inimigo por 0,22 s; os números reais continuam imediatos. `hud_neon/placa.gd` interpola Energia, Barreira e Combo; cada célula de Barreira indica visualmente até cinco pontos, mas o número não recebe teto. A carta em `botao_carta.gd` cresce para leitura ao selecionar, cruza o campo após ser jogada e conserva a opacidade até perto do alvo; número e flash de dano surgem ao final do voo. `main.tscn` inclui a opção “Movimento” para reduzir deslocamentos de carta e transições dos medidores. A caixa genérica de “RECURSOS” não abre mais por hover sobre o painel inteiro; o rótulo de dano é ocultado entre encontros. Nenhuma regra de carta foi alterada neste passe.

Verificação real na Godot `4.7.2.stable.official.ed1daf0bf`: o teste novo `tests/test_composicao_suave.tscn` fez RED antes da implementação e terminou com 0 falhas; cobre layout 1024×576/1920×1080, seleção/voo/impacto, barras de Vida e recursos, e modo reduzido. `test_hud_neon_shell.tscn` e `test_hud_r3.tscn` foram alinhados à nova ordem e posição do impacto e passaram isolados. Uma passagem completa da suíte terminou **73/73 cenas com código 0**. Após a última proteção contra impacto visual fora do combate, a repetição terminou **72/73**: `test_fluxo_flags_docas.tscn` imprimiu “OK: fluxo de flags no evento” e o processo fechou com violação de acesso no teardown; isolado, terminou com código 0 em 2 de 3 execuções. Portanto a suíte não é consistentemente verde. Importação headless do editor, `git diff --check` e o teste novo após a proteção terminaram com código 0. Permanecem avisos conhecidos de recursos/RID/texturas no encerramento.

Seis capturas reais GL Compatibility em `docs/evidencias_composicao_suave/` foram geradas e inspecionadas: recursos e carta selecionada em 1920×1080, carta em voo, após impacto, composição e inspeção de rota em 1024×576. O resultado não equivale a playthrough manual nem à aprovação estética do usuário. Próximo teste curto no editor: abrir um combate, alternar “Movimento” nas Configurações e jogar um Golpe em cada modo; conferir se a carta fica legível antes do clique, se chega ao drone antes do número de dano e se os valores reais de Vida/Energia seguem iguais.

## HUD ilustrada do conceito integrada ao combate - 20/10/2026

Relato do usuário: a HUD anterior não se parecia com `assets/ui/references/`; a versão antiga ainda aparecia sob a nova e as artes provisórias faziam a troca parecer superficial. Esse relato é avaliação visual do usuário, não resultado de teste automatizado.

Estado observado: a captura GL Compatibility anterior ainda mostrava cenário diurno azulado, cartas com explosões amarelas/vermelhas e vários módulos construídos como placas planas. Os arquivos `raw/` contêm quadriculado incorporado ao RGB e não podiam simplesmente ser usados como texturas transparentes. O código ativo já preservava regras de Energia, Barreira, Combo, alvos e pilhas; o descompasso principal deste passe era de apresentação.

Regra de design: `GAME_DESIGN.md` §10 agora explicita que a HUD usa a linguagem ilustrada das referências e que os braços protéticos da Vega devem aparecer na arte das cartas. A apresentação lê o estado do combate e não altera custos, dano, compra, intenções ou progressão. Hipótese visual ainda não aprovada pelo usuário: a combinação de módulos extraídos, arena escurecida e cartas novas aproxima o combate do conceito sem sacrificar a leitura em 1024×576.

Implementado: módulos com alpha real para jogador, inimigo, Combo, Barreira, Energia, botão de encerrar e cais longo em `assets/ui/runtime/conceito/`; o combate ativo os usa em `hud_neon/apresentacao_combate.gd`. São imagens derivadas dos estudos `raw/` e da prancha principal por edição com gerador de imagem, não recortes determinísticos dos arquivos originais. `main.gd` reorganiza o layout em 1024×576 e 1920×1080, inclusive alvos múltiplos, esconde ícones provisórios que reapareciam após a atualização e mantém a Vega de campo abaixo da moldura superior em 1024×576. A arena usa `hud_neon/arena_noite.gdshader`. As nove cartas atuais usam três artes-base novas geradas para punho, proteção e ruptura de Vega/Docas em `assets/ui/runtime/cartas/`, com molduras escuras ciano/magenta; as antigas ilustrações amarelas/vermelhas deixaram de ser usadas no runtime. Testes antigos de aparência foram atualizados para verificar a nova composição, mantendo as verificações de estado.

Verificação executada na Godot `4.7.2.stable.official.ed1daf0bf`: `tests/test_hud_conceito_ativo.tscn` falhou antes da troca das cartas e passou depois; importação headless do editor retornou código 0; a suíte inteira terminou **72/72 cenas com código 0**. Quatro capturas reais GL Compatibility foram geradas em `docs/evidencias_hud_conceito/` (combate simples/duplo, 1024×576/1920×1080) e inspecionadas visualmente. A captura em 1024×576 ainda merece revisão manual de legibilidade de textos pequenos e da relação da Vega com a moldura superior. Permanecem avisos de encerramento de recursos, RID e texturas na Godot, mesmo com código 0. Não houve playthrough humano completo nem aprovação estética desta versão pelo usuário.

Próximo passo curto para validar no editor: abrir `jogo.tscn`, iniciar uma run e comparar o primeiro combate em 1024×576 com `assets/ui/references/ElevenLabs_image_gpt-image-2-5-sunburst_Game UI asset s_2026-10-17T19_23_59.png`; registrar quais módulos e textos ainda destoam antes de alterar o restante das telas.

## Shell único e feedback de ação no combate - 19/10/2026

Relato do usuário: a melhora visual anterior ainda deixava o shell antigo no jogo; animações e funções da HUD não pareciam pertencer à mesma apresentação. Este incremento concentrou-se no combate, sem mudar custos, dano, compra, intenções, turnos ou progressão.

Estado observado: `main.gd` chamava em sequência os compositores básico, HQ e neon. Energia, Barreira e Combo pulsavam em `MolduraHQ` mesmo quando ela estava escondida pela placa neon. `TopoCombate`, Energia e recursos ainda desenhavam painéis-base por baixo; Baralho, Configurações e inspeção conservavam molduras HQ. A captura real após a remoção inicial mostrou Energia e pilhas ilegíveis atrás das novas placas: faltava elevar os rótulos/ícones ao `z_index` correto. Também se confirmou que `_jogar_carta()` não chamava o feedback transitório de dano usado pelo caminho legado, e o dano recebido aparecia na posição do inimigo.

Regra de design mantida: as animações representam resultados já resolvidos e não controlam o estado do combate, conforme `GAME_DESIGN.md` §10. O estado real continua em `JogadorCombate`, `EncontroCombate` e `ResolucaoCartas`; a apresentação só lê e responde a ele. Os compositores básico/HQ permanecem como arquivos históricos, mas não são instanciados no combate ativo.

Implementado: `hud_neon/apresentacao_combate.gd` agora deixa vazios os painéis-base dos módulos que têm placa neon; também estiliza a faixa de turno, inspeção, Baralho, Configurações, alvos múltiplos e relíquias dinâmicas, preservando seus botões e ações. `hud_neon/realce.gd` dá foco/hover curto e cancelável aos controles da nova HUD. `hud_neon/feedback_combate.gd` aciona pulsos de Energia, Barreira e Combo diretamente em `hud_neon/placa.gd`, inclusive consumo de Combo e quebra de Barreira. Valores e ícones externos às placas foram trazidos para frente delas. Ataques jogados por carta agora mostram número e flash no alvo correto; danos recebidos mostram o número junto da Vega, com cor e tipografia neon. O feedback de dano da arte estática da Vega foi alinhado ao magenta da HUD.

Verificação real na Godot `4.7.2.stable.official.ed1daf0bf`: `tests/test_hud_neon_shell.tscn` fez RED por shell duplicado/feedback ausente e GREEN após as mudanças; uma segunda rodada RED/GREEN cobriu a ordem de desenho, outra cobriu o acerto por carta e o posicionamento do dano, e `test_vega_playtest.tscn` fez RED/GREEN para a cor do dano. A suíte final terminou **71/71 cenas com código 0**. As três verificações avulsas de HUD básica/HQ/hover foram atualizadas para o contrato neon e terminaram com código 0. A importação headless do editor e `git diff --check` retornaram código 0. Houve avisos de teardown já conhecidos em 28 cenas da suíte, além de recursos/RID/texturas ainda vivos na captura gráfica; não foram tratados como falhas de regra nem ocultados.

Seis capturas GL Compatibility em `docs/evidencias_shell_neon/` mostram combate em 1024×576 e 1920×1080, ataque com valores reais, Baralho, Configurações e dois inimigos. Foram inspecionadas visualmente: os números antes ocultos estão legíveis, os modais usam a mesma moldura e o ataque mostra `-4` junto do alvo. As capturas não substituem um playthrough manual por mouse/teclado nem aprovação estética. Ainda há trabalho de direção artística nas cartas, no cenário e nos ícones de relíquias; Lastro definitivo segue pendente.

Exercício pequeno no editor: em `hud_neon/realce.gd`, mudar somente `0.14` para `0.20` em `atualizar()`, focar **Encerrar turno** com teclado e observar a duração do realce. Energia, dano e turno devem continuar iguais; se mudarem, a alteração escapou da camada de apresentação.

## Percurso visual neon da run - 19/10/2026

Relato do usuário: continuar a transformação da base jogável após a nova HUD de combate, sem encerrar o trabalho nos menus. Este incremento cobriu o mapa, a recompensa comum, eventos, a oferta de elite, o descanso e o resultado da run. Não alterou custo, dano, cura, sorteio, progressão ou requisitos de rota.

Estado observado: o mapa ainda tinha cabeçalho branco e ícones de nós com pouco contraste; a recompensa comum usava ações brancas, e em 1920×1080 as três cartas cobriam os botões inferiores. Eventos e descanso conservavam painéis claros do kit anterior; a elite não tinha enquadramento compartilhado; o botão de reinício também era branco. Um texto legado de sucesso dizia “Três combates vencidos!” embora a rota vigente tenha 11 pontos.

Regra de design preservada: `MapaRun` continua definindo quantidade, tipos, estados e conexões dos nós. As escolhas de recompensa, evento, elite e descanso continuam nos sistemas existentes. A apresentação só lê o estado real; a grade recebe `mapa_run.total_pontos()`. A vitória do último nó ainda é explicitamente provisória, sem fingir que Lastro definitivo foi implementado.

Implementado: `hud_neon/apresentacao_run.gd` aplica molduras, cores, ícones e botões neon aos overlays existentes; `hud_neon/grade_rota.gd` desenha a rota sem capturar input. Seis SVGs novos substituem somente os ícones de tipo do mapa, mantendo os IDs e botões reais. As ofertas comum e elite ganharam placas escuras; evento e descanso ficaram com narrativa e efeitos em alto contraste; derrota ganhou título magenta e reinício neon. A escala das cartas de recompensa, também usada pelas raras, passou a respeitar a área disponível e o ganho de escala já aplicado pelo canvas. O texto legado de sucesso foi trocado por “A rota das Docas foi concluída.” A tela do Boss provisório agora usa um título curto que cabe na moldura e uma nota separada que explicita a ausência do Lastro definitivo.

Verificação real na Godot `4.7.2.stable.official.ed1daf0bf`: os três novos testes de apresentação fizeram RED antes das mudanças e GREEN depois, incluindo clique no nó, recompensa/pulo, consequência de evento, cura de 8 Vida, título final do Boss e ausência de colisão entre cartas e ações em 1024×576 e 1920×1080. A última suíte completa terminou **70/70 cenas com código 0**; importação headless do editor terminou com código 0. `git diff --check` terminou com código 0 na checagem final. Permanecem os avisos conhecidos de ObjectDB/resources/RID no encerramento headless/GL.

As 16 capturas GL Compatibility em `docs/evidencias_run_neon/` cobrem mapa, recompensa, evento, oferta elite (relíquia e carta rara), descanso, derrota e Boss provisório nas duas resoluções; foram inspecionadas visualmente. O evento da captura foi alcançado pela sequência mapa → combate → pular recompensa → evento. As capturas de elite, descanso, derrota e Boss usam chamadas de estado do script de captura para inspecionar a composição, não provam uma partida completa por input humano. Falta playthrough manual até o Boss provisório e aprovação estética do usuário. As quatro capturas de preview provisório da elite, criadas nesta rodada e que mostravam o mapa por trás, foram removidas; as capturas finais permanecem.

Exercício pequeno no editor: em `hud_neon/apresentacao_run.gd`, mudar apenas a cor `CIANO`, abrir o mapa e confirmar que os nós, a Vida e os destinos reais não mudam com o tema.

## HUD de combate ligada ao conceito neon - 19/10/2026

Relato do usuário: a entrega anterior ficou restrita a dois menus, mas a intenção era transformar a base jogável de fato, incluindo a nova HUD. Este incremento atuou na tela de combate existente, sem mudar custos, dano, turnos, sorteios ou progressão.

Estado observado: `main.tscn` já apresentava valores reais de Vida, Energia, Barreira, Combo e intenção, porém com faixa superior única, caixas de recursos soltas e mão sem a moldura do conceito novo. Os seis PNGs em `assets/ui/references/raw/` têm o quadriculado incorporado à imagem. A Godot registrada e usada foi `4.7.2.stable.official.ed1daf0bf`.

Implementado: `hud_neon/placa.gd` desenha os módulos chanfrados do jogador, inimigo, Barreira/Combo, Energia e cais de cartas. `hud_neon/apresentacao_combate.gd` aplica esses componentes aos nós de `main.tscn`, atualiza apenas a camada visual a partir dos valores recebidos de `main.gd` e estiliza barras, intenção, botões utilitários, fim de turno e anúncio transitório do turno. O alvo continua clicável; molduras e arte ignoram mouse. A barra segmentada de Combo mostra até seis segmentos e mantém o número real sem teto. Os novos SVGs ficam em `hud_neon/`.

O núcleo de Energia fornecido foi processado como um recorte novo em `assets/ui/runtime/energia_nucleo_recortado.png`: a imagem original permaneceu intacta, a saída tem alpha real nos cantos e seu miolo é exibido sem deformação com `AtlasTexture`. As cinco luzes estáticas da referência ficaram fora do recorte; os pontos ativos são desenhados conforme a Energia da partida. Os demais estudos `raw/` continuam sendo referência de forma, não texturas de runtime.

Verificação real: o teste novo `tests/test_hud_neon_combate.tscn` falhou primeiro pela ausência das molduras e depois pela ausência da arte integrada; ao final passou verificando ligação dos valores reais, alpha e área clicável. `test_composicao_combate.tscn` detectou perda do estilo de foco do alvo; o estado foi corrigido e o teste passou. A última passagem completa terminou em **67/67 cenas com código 0** e sem erros não relacionados ao encerramento. `git diff --check` terminou com código 0. A primeira importação final concorrente terminou com código 1 sem diagnóstico de recurso; a repetição isolada de `--headless --editor --import --quit` terminou com código 0. Persistem os avisos já conhecidos de ObjectDB, resources e RID ao fechar a Godot headless.

Capturas reais GL Compatibility em `docs/evidencias_hud_neon/combate_1024.png` e `combate_1920.png` foram inspecionadas: molduras, cartas, alvo e fim de turno cabem nas duas resoluções; a faixa transitória aparece na captura menor. Isso não substitui a avaliação manual do usuário no editor. A integração visual dos demais overlays da run e o chefe Lastro definitivo continuam pendentes.

Exercício pequeno no editor: alterar só a cor `ROSA` em `hud_neon/placa.gd`, executar um combate e conferir que vida, custos e Combo permanecem iguais apesar da nova cor.

## Entrada Menu -> Vega -> Mapa - 19/10/2026

Relato do usuário: seguir o incremento recomendado para o fluxo inicial e usar `assets/ui/references/` como direção visual, com o conceito da raiz e os estudos `raw/` apenas como referência. A especificação aprovada está em `docs/superpowers/specs/2026-10-19-fluxo-inicial-vega-design.md`.

Implementado: `project.godot` agora abre `jogo.tscn`. O controlador `jogo.gd` apresenta `menu_principal.tscn`, depois `selecao_personagem.tscn` com Vega selecionada, e só após `CONFIRMAR VEGA` instancia uma cópia de `main.tscn`. `VOLTAR` retorna ao menu sem run; `SAIR` envia `quit()`; um id diferente de `vega` é recusado; cliques repetidos não duplicam a run. A run antiga e as regras de gameplay não foram alteradas por este incremento. O `reload_current_scene()` existente foi testado e retorna ao menu.

Visual implementado com controles nativos: moldura chanfrada, estados de botão, fontes existentes, cenário das Docas e arte estática aprovada da Vega. Nenhum PNG de `assets/ui/references/raw/` entrou no runtime. A primeira captura expôs que a moldura da arte cobria a personagem; o preenchimento dessa moldura foi removido, as capturas foram refeitas e inspecionadas. Arquivos: `docs/evidencias_entrada_vega/menu_1024x576.png`, `selecao_1024x576.png`, `menu_1920x1080.png` e `selecao_1920x1080.png`. Nas quatro imagens, os painéis e botões permanecem dentro da tela; Vega aparece inteira e sem estiramento perceptível. Isso é inspeção das capturas, não aprovação manual do usuário no editor.

Verificação real na Godot `4.7.2.stable.official.ed1daf0bf`: quatro testes novos de menu, seleção, fluxo e layout passaram; o teste separado de reinício passou; a importação headless e a abertura da cena principal headless retornaram código 0. A primeira passagem da suíte completa ficou em `65/66`: `test_layout_evento_opcao.tscn`, que carrega `main.tscn` diretamente, falhou uma vez na posição do destaque após foco. Três execuções isoladas desse teste passaram e a segunda passagem da suíte terminou `66/66`. Não houve correção especulativa no teste ou no evento. Os avisos conhecidos de recursos/ObjectDB/RID no encerramento headless continuam presentes.

Após a revisão, foi acrescentada a microanimação dos botões (foco/hover e contração ao pressionar), com RED -> GREEN no teste do menu. As quatro cenas de teste do incremento e o reinício passaram novamente; importação e abertura headless continuaram com código 0, e as quatro capturas foram refeitas a partir de `jogo.tscn`. Duas passagens completas adicionais ficaram em `65/66` por falhas diferentes em testes que instanciam `main.tscn` diretamente: `test_ciclo_run.tscn` sofreu violação de acesso **depois** de imprimir sucesso lógico (cinco repetições isoladas passaram); `test_bestiario_visual.tscn` não encontrou `Golpe` na mão sorteada (três repetições isoladas passaram). A suíte, portanto, não está consistentemente verde. Esses testes e suas regras não foram alterados para mascarar o problema. A captura gráfica também emitiu avisos de textura/RID ainda vivos ao encerrar, apesar de salvar as quatro PNGs com código 0.

Pendente: executar `Menu -> Vega -> Mapa` manualmente no editor, por mouse e teclado, em 1024x576 e 1920x1080 e aprovar ou apontar ajustes visuais. Uma modificação pequena para exercitar a separação entre apresentação e lógica é alterar apenas o texto de `Subtitulo` em `ui_entrada/menu_principal.tscn` e confirmar que o fluxo da run permanece igual.

## Auditoria do vertical slice e nova referencia visual - 19/10/2026

Relato do usuario: a direcao visual mais recente esta em `assets/ui/references/`. A imagem na raiz e o conceito principal; os seis arquivos em `assets/ui/references/raw/` oferecem elementos e estudos para usar tambem como referencia. O kit anterior em `ui_hq_v1/referencias/` nao foi tratado como a fonte visual mais recente nesta auditoria.

Estado observado: o projeto usa Godot `4.7.2.stable.official.ed1daf0bf`, abre `main.tscn` diretamente e inicia uma nova run no mapa, sem menu principal nem selecao de Vega. A infraestrutura jogavel existente ja cobre combate, mao, compra/descarte, Energia, Vida, Barreira, Combo, intencoes, recompensas, eventos, REST, Desmanche e um mapa de 11 pontos. O ponto final ainda se chama `Boss provisorio` e reutiliza a `Unidade de Contencao Portuaria`; Lastro definitivo nao esta implementado. A Vega estatica aprovada continua no runtime, enquanto o rig segmentado permanece isolado e sem aprovacao visual para integracao.

Verificacao executada com a Godot registrada: importacao headless `EXIT=0`; carregamento headless de todas as 12 cenas de producao/preview `12/12`; cena principal `EXIT=0`; segunda passagem completa da suite `62/62` cenas com codigo 0. Na primeira passagem, `test_integracao_run_docas.tscn` imprimiu o sucesso logico e depois sofreu uma violacao de acesso transitoria; ela nao se repetiu em tres execucoes isoladas nem na segunda suite completa. Vinte e duas cenas que carregam a composicao principal emitiram os avisos conhecidos de `ObjectDB`, resources e RID ainda vivos durante o encerramento headless; isso permanece como divida tecnica de teardown e nao foi tratado como teste verde silenciosamente.

Inspecao dos sete PNGs novos: o conceito mede `1280x720`; os seis estudos medem entre `2048x1360` e `2880x960` ou `2048x2048`. Amostragem do canal alfa encontrou `alpha=255` em todos eles, inclusive nos cantos: o quadriculado dos arquivos `raw` esta incorporado na imagem e nao representa transparencia real. Eles ainda nao foram integrados ou processados. A abordagem proposta e conservar o conceito como direcao, reconstruir componentes responsivos com `Control`, `Container`, `StyleBox` e `NinePatchRect`, e extrair somente elementos selecionados depois de validar bordas e recortes.

Proximo incremento proposto, ainda sem aprovacao: criar a entrada observavel `menu principal -> selecao de Vega -> mapa da run`, aplicando a nova linguagem visual sem reescrever o combate ja testado. Nenhum arquivo de gameplay, cena ou asset foi alterado nesta auditoria.

## Pose neutra assimetrica da Vega em preview isolado - 06/10/2026

Implementado o passe visual solicitado somente em `vega_animada/vega_corpo_inteiro_articulada.tscn` e seu preview. O torso permanece na transformacao de referencia; os pivots dos ombros foram afastados, receberam pequena diferenca de altura e rotacao oposta. Cotovelos, antebracos e punhos agora usam flexoes e rotacoes leves, com sobreposicao preservada pelas pecas circulares de cotovelo. As pernas receberam apoio assimetrico: a perna B ficou ligeiramente recuada/mais alta no modelo.

O idle foi desligado temporariamente por `idle_habilitado = false`. A pose neutra esta registrada tambem nos transforms `rest` dos `Bone2D`; as trilhas do idle foram preparadas para oscilar em torno dessa nova pose, mas nao sao reproduzidas durante esta validacao. O preview agora identifica o estado como `POSE NEUTRA`. Texturas, PNGs, runtime de combate, regras, HUD, turnos, mapa e run nao foram alterados.

O teste `tests/test_vega_corpo_inteiro_articulada.tscn` recebeu RED para idle desligado, torso fixo, ombros externos/desnivelados, flexao dos membros superiores, punhos distintos e apoio assimetrico. Antes da implementacao terminou com `VEGA ARTICULADA: 9 falhas`; depois terminou com `VEGA ARTICULADA: 0 falhas` em Godot `4.7.2.stable.official.ed1daf0bf`. A suite completa terminou com `TESTES=62 PASSOU=62 FALHAS=0`.

Capturas reais GL Compatibility foram geradas e inspecionadas em `docs/evidencias_vega_corpo_inteiro/neutra_1024x576.png` e `neutra_1920x1080.png`. A leitura mostra uma unica Vega, dois bracos com cotovelos encaixados, pernas separadas e um pe recuado; nao foi observada costura aberta evidente. A importacao headless terminou com `IMPORT_EXIT=0`, `tests/verificar_vega_animada.gd` terminou com `VEGA PLAYTEST FUNCIONAL: 0 falhas` e `git diff --check` terminou com `DIFF_CHECK=0`. Permanecem os avisos conhecidos de ObjectDB, resources e RID no encerramento do renderer dummy.

A aprovacao visual manual ainda falta no editor. O proximo passo curto e abrir `vega_animada/preview_vega_corpo_inteiro.tscn` em 1024x576 e 1920x1080, confirmar as costuras, o contato dos dois pes e a assimetria da pose; somente depois disso reativar o idle.

## Rig-ready separado da Vega em preview isolado - 06/10/2026

Relato e instrucao do usuario: a Task 3 mudou de estrategia. O ZIP `C:\Users\Wallace\Downloads\vega_rig_parts.zip` fornece PNGs transparentes separados e `vega_referencia_corpo_inteiro.png`; a referencia serve somente para proporcao. A exigencia anterior de manter todas as pecas em canvas `1024x1536` foi suspensa.

Os arquivos originais foram preservados em `docs/arte_vega/vega_animada/pecas_rig/` e as copias de runtime em `vega_animada/pecas_rig/`. O teste `tests/test_vega_corpo_inteiro_pecas.tscn` foi ajustado para aceitar dimensoes individuais, confirmar textura carregavel, alpha transparente e amostra opaca. Antes da copia ele retornou RED; depois terminou com `VEGA PECAS: 0 falhas` em Godot `4.7.2.stable.official.ed1daf0bf`.

Foi criada a candidata `vega_animada/vega_corpo_inteiro_articulada.tscn` com `Skeleton2D`, `Bone2D`, `Sprite2D` e `AnimationPlayer`. A/B continuam sendo apenas os nomes dos assets; o preview faz o mapeamento visual sem renomear os PNGs. As pecas de cotovelo ficam sobre as juntas como cobertura. O teste estrutural terminou com `VEGA ARTICULADA: 0 falhas`, incluindo separacao real das pernas (`A=(479.3184, 311.5642)`, `B=(546.8604, 311.5642)`).

Uma captura inicial mostrou somente uma perna porque `PernaB` estava abaixo da arvore visual. O ajuste restrito foi explicitar `PernaA.z_index = 1`, `PernaB.z_index = 3` e `Torso.z_index = 2`; nenhuma regra, HUD, cena de combate ou API de runtime foi alterada. Capturas reais GL Compatibility de `tests/capturar_vega_corpo_inteiro.gd` foram regeneradas em `docs/evidencias_vega_corpo_inteiro/idle_1024x576.png` e `idle_1920x1080.png` e inspecionadas: as duas mostram uma unica Vega coerente, com dois bracos, duas pernas, duas botas e sombra de contato.

O `AnimationPlayer` contem somente o idle curto nesta etapa. `socar()` e `receber_dano()` continuam reservados e retornam ao repouso; a candidata nao e carregada pelo combate. A aprovacao visual manual ainda falta no editor em 1024x576 e 1920x1080. O proximo passo curto e abrir `vega_animada/preview_vega_corpo_inteiro.tscn`, observar alguns segundos de idle e conferir costuras, proporcao e contato dos dois pes antes de criar ataque ou dano.

## Inspecao da captura do rig-ready - 06/10/2026

A captura enviada pelo usuario mostra que a composicao tecnica esta correta: torso unico, dois bracos, duas pernas, duas botas e nenhuma transparencia acidental visivel nas juntas principais. Isso confirma o objetivo estrutural do primeiro preview.

A captura ainda nao deve ser tratada como aprovacao visual final. A pose le quase frontal e simetrica, enquanto a referencia pede uma leitura mais em tres quartos, com ombros, bracos e pernas em profundidades diferentes. Um frame estatico tambem nao comprova que o idle e perceptivel. Nenhum arquivo de runtime foi alterado nesta inspeccao.

Correcao visual sugerida para o proximo passe isolado: ajustar somente as transformacoes dos `Bone2D` de ombro, cotovelo, quadril e joelho, criando assimetria moderada entre A/B; manter as texturas e a ordem de desenho aprovadas. Depois, capturar repouso em 1024x576 e 1920x1080 antes de criar soco ou dano.

## Preparacao da copia de articulacao da Vega - 04/10/2026

Task 3 do plano `docs/superpowers/plans/2026-10-04-vega-krita-asset-pipeline.md` foi iniciada em escopo isolado. O teste estrutural novo `tests/test_vega_corpo_inteiro_pecas.tscn` foi executado antes dos recursos e retornou RED esperado: `VEGA PECAS: 7 falhas`, porque as sete PNGs ainda nao existem.

Foi criada uma copia reversivel da fonte em `docs/arte_vega/vega_corpo_inteiro_articulacao.kra` e aberta no Krita. A inspeccao do arquivo `.kra` mostra uma unica camada raster; portanto ele nao fornece grupos separados para corpo e bracos. Nenhum recorte automatico foi inventado a partir do atlas antigo ou da silhueta aprovada, para nao repetir o defeito visual de sobreposicao/duplicacao.

O runtime continua inalterado: `main.gd`, `vega_animada/vega_playtest.tscn`, regras, HUD, turnos, mapa e run nao foram modificados. O proximo passo manual e separar no Krita `corpo_base` e os seis segmentos verdadeiros no mesmo canvas `1024x1536`, mantendo transparencias e pequenas sobreposicoes nas juntas; depois o teste sera executado novamente.

## Plano aprovado para arte de corpo inteiro da Vega - 04/10/2026

O usuario aprovou a especificacao `docs/superpowers/specs/2026-10-04-vega-krita-asset-pipeline-design.md`, que preserva a ilustracao superior atual, redireciona o corpo inteiro para o Krita e suspende a articulacao ate a aprovacao visual da silhueta estatica.

Foi criado o plano executavel `docs/superpowers/plans/2026-10-04-vega-krita-asset-pipeline.md`. O primeiro gate pratico continua sendo aprovar manualmente a imagem unica em 1024x576 e 1920x1080 antes de preparar pecas de braco. A arte original `ui_hq_v1/assets/personagens/vega_combate.png` permanece intacta.

Execucao Native iniciada: o baseline focado de `tests/test_vega_playtest.tscn` em Godot `4.7.2.stable.official.ed1daf0bf` retornou `EXIT=0`, com os avisos conhecidos de encerramento sobre ObjectDB, resources e RID/textures. A primeira candidata foi criada com geracao de imagem usando a arte atual como referencia, copiada para `docs/arte_vega/vega_corpo_inteiro_candidata_v1.png` e refinada para `docs/arte_vega/vega_corpo_inteiro_candidata_v2.png`. A v2 mede `1024x1536` e as quatro amostras dos cantos possuem alpha `0`; ela mostra uma unica Vega de corpo inteiro, com ambos os pes visiveis. O Krita foi aberto com a candidata.

## Aprovacao e integracao da Vega de corpo inteiro - 04/10/2026

Relato manual do usuario: a candidata estatica de corpo inteiro foi aprovada. A imagem aprovada foi copiada para `ui_hq_v1/assets/personagens/vega_combate_corpo_inteiro.png`; a arte original `vega_combate.png` permaneceu intacta. `vega_animada/vega_playtest.tscn` agora aponta `Visual/Arte` para a nova PNG, preservando `Visual`, `Sombra`, `mouse_filter`, movimento de repouso e a API `socar()`, `receber_dano()` e `reiniciar()`. Nenhuma regra, custo, dano, turno, HUD, mapa ou run foi alterado.

Capturas reais GL Compatibility de `tests/capturar_vega_playtest.gd` foram geradas e inspecionadas em `docs/evidencias_vega/playtest_estatico_1024.png` e `playtest_estatico_1920.png`. Em ambas, a Vega aparece como uma unica figura coerente, com corpo completo, ambos os pes no piso e sombra discreta. `tests/test_vega_playtest.tscn` terminou com `VEGA PLAYTEST: 0 falhas`; `tests/verificar_vega_animada.gd` terminou com `VEGA PLAYTEST FUNCIONAL: 0 falhas`; a importacao headless terminou com `IMPORT_EXIT=0`; `git diff --check` terminou com `0`. Persistem os avisos conhecidos de recursos/ObjectDB/RID/textures no encerramento dos renderers. A PNG de runtime foi aprovada para o playtest estatico; a preparacao de segmentos de braco continua suspensa ate a proxima tarefa do plano.

## Diagnostico da filtragem visual da Vega - 04/10/2026

Relato manual do usuario: a Vega esta mais viva e integrada ao cenario, mas o jogo ainda parece feio e pode estar sem anti-aliasing. A captura real Compatibility de `docs/evidencias_vega/playtest_estatico_1024.png` reproduz a leitura em todas as execucoes: a figura esta correta, porem suas bordas ficam duras quando a PNG de `1024x1536` e reduzida para aproximadamente `160x240` px no campo.

Inspecao do projeto: `project.godot` nao declara filtro de textura 2D, portanto o valor padrao de Godot 4.7 e herdado; esse padrao e `NEAREST` (`1`). `vega_animada/vega_playtest.tscn` tambem nao sobrescreve `texture_filter`. A importacao de `ui_hq_v1/assets/personagens/vega_combate_corpo_inteiro.png` esta com `mipmaps/generate=false`. Para esta arte nao pixelada e exibida em escala reduzida, a causa primaria e filtragem sem mipmaps, nao ausencia de MSAA 3D.

Hipotese secundaria preservada: o contorno preto e o contraste alto da ilustracao aprovada criam uma aparencia de adesivo contra o fundo; trocar o filtro pode suavizar a borda, mas nao muda essa direcao artistica. Nenhum arquivo de runtime, regra, HUD ou projeto foi alterado neste diagnostico. O proximo passe pequeno deve comparar uma variante com filtro `LINEAR_WITH_MIPMAPS` (`4`) somente em `Visual/Arte`, gerar novamente as capturas 1024/1920 e decidir visualmente antes de tornar a mudanca global.

## Filtragem linear da arte de corpo inteiro - 04/10/2026

Implementado o passe visual aprovado: `vega_animada/vega_playtest.tscn` agora define `texture_filter = 4` (`LINEAR_WITH_MIPMAPS`) somente em `Visual/Arte`, e `ui_hq_v1/assets/personagens/vega_combate_corpo_inteiro.png.import` habilita `mipmaps/generate=true`. O filtro global do projeto, o HUD, a escala, a sombra, a pose e a API de feedback permaneceram inalterados.

O teste RED foi acrescentado em `tests/test_vega_playtest.gd` e falhou antes da implementacao com `Arte de campo nao usa filtragem linear com mipmaps`; depois passou com `VEGA PLAYTEST: 0 falhas`. `tests/verificar_vega_animada.gd` terminou com `VEGA PLAYTEST FUNCIONAL: 0 falhas`, a suite completa terminou com `TESTES=60 PASSOU=60 FALHAS=0` e a importacao do editor reimportou a PNG com codigo 0. Capturas reais GL Compatibility foram regeneradas em `docs/evidencias_vega/playtest_estatico_1024.png` e `playtest_estatico_1920.png`; a inspecao mostra bordas mais suaves nas duas resolucoes. Permanecem os avisos conhecidos de ObjectDB, resources, RID e texturas no encerramento dos renderers.

Esta melhora e uma validacao tecnica/visual automatizada, nao a aprovacao final do usuario. O proximo passo curto e abrir `main.tscn` em 1024x576 e 1920x1080, conferir se a suavizacao nao deixou a Vega borrada e observar repouso, ataque e dano antes de voltar a discutir articulacao.

## Aprovacao manual da filtragem e retorno a articulacao - 04/10/2026

Relato manual do usuario: apos testar a cena, a Vega nao ficou borrada e a filtragem linear com mipmaps deixou a personagem um pouco mais adequada ao cenario. O passe visual foi aprovado em conjunto com a arte estatica de corpo inteiro.

Nenhuma regra, HUD, escala ou animacao foi alterada neste relato. A articulacao pode voltar a ser investigada a partir da PNG aprovada, mas o proximo incremento deve ser um preview isolado de segmentos verdadeiros de braco; a ilustracao estatica integrada permanece como fallback ate a aprovacao manual da costura e da silhueta.

## Ancoragem e repouso da Vega provisoria - 04/10/2026

Depois da troca para a ilustracao unica, foi feito um passe visual pequeno sem reabrir o rig segmentado. `vega_animada/vega_playtest.tscn` agora separa a arte em `Visual/Arte` e adiciona `Sombra`, uma camada discreta que ancora a figura no piso. `vega_animada/vega_playtest.gd` aplica um movimento de repouso muito curto no conjunto visual e direciona o feedback de soco/dano para esse contenedor; a sombra e a caixa de alvo continuam ignorando input.

O teste RED registrou as tres lacunas anteriores: ausencia do contenedor, ausencia de contato visual com o piso e repouso imovel. Depois da correcao, `tests/test_vega_playtest.tscn` terminou com `VEGA PLAYTEST: 0 falhas`, `tests/verificar_vega_animada.gd` com `VEGA PLAYTEST FUNCIONAL: 0 falhas` e a suite completa de `60` cenas com `TOTAL=60 FALHAS=0`, em Godot `4.7.2.stable.official.ed1daf0bf`. Capturas reais GL Compatibility foram regeneradas em `docs/evidencias_vega/playtest_estatico_1024.png` e `playtest_estatico_1920.png` e inspecionadas; elas mostram uma unica Vega coerente, com contato visual mais claro e movimento sutil. Permanecem os avisos conhecidos de recursos/RID no encerramento dos renderers.

Limitacao preservada: a ilustracao continua terminando nas coxas e nao e arte final de corpo inteiro. O proximo passo pequeno e o playtest manual do usuario em 1024x576 e 1920x1080, conferindo se a sombra nao parece uma segunda base, se o repouso e discreto e se o ataque/dano continuam legiveis.

## Vega provisoria para destravar o playtest - 04/10/2026

Relato manual do usuario, acompanhado de screenshot: a candidata segmentada integrada parecia ter dois torsos e tornou o playtest visualmente inviavel. A inspecao da cena e do atlas confirmou um unico sprite de torso; o volume duplicado era a sobreposicao de ombreiras e recortes de bracos originalmente desenhados como pecas completas. A previsualizacao isolada reproduzia o defeito, portanto a causa nao era o HUD nem uma segunda instancia da Vega. A avaliacao visual positiva anterior foi incorreta; testes estruturais verdes nao validavam a silhueta.

`main.gd` agora instancia `vega_animada/vega_playtest.tscn` no mesmo alvo `Jogador/VegaAnimada`. A cena usa uma unica ilustracao existente, `ui_hq_v1/assets/personagens/vega_combate.png`, que ignora input e preserva `socar()`, `receber_dano()` e `reiniciar()`. Ataque e dano deslocam brevemente a imagem inteira; nenhuma parte do corpo e articulada. O rig segmentado e o fallback anterior permanecem preservados no projeto, mas nao sao carregados no combate. Regras, custos, dano, turnos, mapa e run nao foram alterados.

Capturas reais GL Compatibility em `docs/evidencias_vega/playtest_estatico_1024.png` e `playtest_estatico_1920.png` foram inspecionadas: ha uma unica figura coerente no campo, sem a massa de bracos duplicados. Limitacao explicita: a ilustracao termina nas coxas e nao substitui a arte final de corpo inteiro. Godot `4.7.2.stable.official.ed1daf0bf`: teste RED de `test_vega_playtest.tscn` falhou por ainda carregar o rig; apos a troca passou com `VEGA PLAYTEST: 0 falhas`. `verificar_vega_animada.gd` foi atualizado para o contrato provisorio e passou com `VEGA PLAYTEST FUNCIONAL: 0 falhas`. A suite completa terminou com `TOTAL=60 FALHAS=0`. Permanecem avisos conhecidos de recursos/RID no encerramento. Falta a aprovacao manual do usuario no editor; as capturas nao a substituem.

Proximo passo pequeno: abrir `main.tscn` e conferir se a Vega provisoria permite retomar o playtest. Para animacao de corpo inteiro, sera necessaria arte nova coerente, preparada para articulacao; nao reabrir ajustes de pivots nos recortes atuais como solucao final.

## Rig nativo segmentado da Vega integrado - 04/10/2026

Implementada a candidata nativa `vega_animada/vega_animada_segmentada.tscn` com `Skeleton2D`, `Bone2D` e `AnimationPlayer`. Os dois lados dos bracos usam seis recortes transparentes independentes em `vega_animada/pecas_articuladas/`: braco superior, antebraco e punho para frente e tras. A API publica permanece `socar()`, `receber_dano()` e `reiniciar()`, com as poses nomeadas `repouso`, `guarda`, `soco`, `dano` e `reiniciar`.

`main.gd` agora instancia essa candidata no campo de combate, mantendo o alvo `Jogador/VegaAnimada`, o `mouse_filter` ignorado e as chamadas de ataque/dano existentes. O script `tests/verificar_vega_animada.gd` foi adaptado para a nova hierarquia e continua verificando custo, dano, Barreira, alvo invalido, mapa oculto e reinicio do combate. O rig anterior permanece no projeto como fallback em `vega_animada/vega_animada.tscn`; ele nao foi apagado nem substituido por uma mudanca de regra.

Foi criado o preview isolado `vega_animada/preview_vega_segmentada.tscn`, sem `main.tscn`, HUD ou regras. As capturas Compatibility da candidata em repouso, guarda, soco e interrupcao foram geradas em 1024x576 e 1920x1080 em `docs/evidencias_vega_segmentada/`. Capturas integradas do combate foram regeneradas em `docs/evidencias_vega/`, incluindo `repouso_1024.png`, `repouso_1920.png`, `soco_1920.png` e `dano_1920.png`. A inspeção dessas imagens mostra uma unica Vega no campo, com os dois lados dos bracos presentes; a silhueta continua aguardando aprovacao manual de proporcao e costura dos segmentos.

Verificacao executada com Godot `4.7.2.stable.official.ed1daf0bf`: `VEGA SEGMENTADA: 0 falhas`, `VEGA COMPATIBILIDADE: 0 falhas`, `VEGA ANIMADA: 0 falhas`, suite completa de `59` cenas com `TOTAL=59 FALHAS=0`, capturas Compatibility com codigo 0, importacao do editor com `IMPORT_EXIT=0` e `git diff --check` sem saida. Permanecem os avisos conhecidos de `ObjectDB`, resources e RID/textures no encerramento dos renderers. Falta o playtest manual em janela real, em 1024x576 e 1920x1080, para aprovar ou rejeitar visualmente a candidata antes de remover o fallback.

Proximo passo pequeno no editor: abrir `main.tscn`, observar 5 segundos de repouso, jogar um `Golpe`, receber um dano sem Barreira e confirmar que a Vega nao mostra duplicacao, que o cotovelo dobra visualmente e que a guarda retorna. Se a costura ainda parecer flutuante, registrar o frame e voltar a usar o fallback enquanto os pivots sao ajustados.

## Comparacao manual com a referencia da Vega - 03/10/2026

O usuario enviou uma referencia de corpo inteiro e pediu a comparacao com a personagem animada aberta na Godot. A referencia tem pose em tres quartos, cabeca deslocada para a direita, ombros em profundidades diferentes, um braco baixo e projetado para a esquerda, outro braco alto e projetado para a direita, punhos fora do torso, quadril largo e pernas em base aberta.

A captura Compatibility atual de `main.tscn` e a previsualizacao de guarda mostram uma Vega funcionalmente unica, mas visualmente frontal e compactada: cabeca e torso ficam quase no mesmo eixo, os dois ombros ocupam a mesma faixa horizontal, os bracos terminam perto do peito, as pernas ficam quase paralelas e os pes se aproximam. A referencia usa uma silhueta diagonal e larga; a cena atual usa uma coluna central com placas mecanicas sobrepostas.

O rig tambem nao reproduz uma articulacao real de cotovelo. `vega_animada/vega_animada.tscn` usa um recorte completo por braco e deixa ocultos os sprites filhos de `Cotovelo`; portanto a animacao pode girar o braco pelo ombro, mas nao dobra visualmente uma peca de antebraco independente. `vega_animada/vega_animada.gd` aplica respiracao de aproximadamente 1.7 px depois da escala global de `0.44`, o que explica a leitura quase estatica no campo. A escala geral nao e a causa principal: aumentar a personagem apenas ampliaria essa montagem incorreta.

Esta e uma inspeção manual baseada na referencia enviada e nas capturas Compatibility abertas com Godot `4.7.2.stable.official.ed1daf0bf`; nenhum arquivo de jogo foi alterado nesta comparacao. Proximo passo visual: reconstruir os recortes dos bracos em segmentos verdadeiros ou aceitar uma pose de braco inteiro por lado e reposicionar ombros, quadril, cabeca e pes para uma silhueta em tres quartos antes de ajustar a respiracao.

## Correcao dos recortes de braco duplicados da Vega - 03/10/2026

O usuario relatou, com screenshot, que a Vega parecia ter dois corpos no mesmo espaco e uma leitura de centauro. A inspecao de `vega_animada/pecas.png` mostrou a causa: os recortes da linha do meio do atlas sao bracos completos, mas estavam sendo usados como se fossem antebracos filhos dos dois bracos principais. Isso empilhava quatro bracos inteiros sobre o mesmo torso.

`vega_animada/vega_animada.tscn` agora deixa visivel somente um recorte de braco por lado. Os nos `Cotovelo` permanecem como pivots da API de animacao, mas os dois sprites filhos de antebraco ficam ocultos para nao duplicar a silhueta. `tests/verificar_vega_animada.gd` passou a exigir essa composicao e a validar que os recortes dos bracos principais pertencem ao conjunto de bracos completos do atlas. Regras, input, custos, dano, turnos, run, mapa e arena nao foram alterados.

A captura Compatibility de guarda e `docs/evidencias_vega/repouso_1920.png` foram regeneradas e inspecionadas; a silhueta agora mostra um torso, dois bracos e duas pernas, sem o segundo par de bracos sobreposto. Godot `4.7.2.stable.official.ed1daf0bf`: `VEGA ANIMADA: 0 falhas`, suite completa de `57` cenas com `TOTAL=57 FALHAS=0`, capturas Compatibility com codigo 0 e `git diff --check` sem saida. Permanecem os avisos conhecidos de recursos/RID no encerramento dos renderers. A aprovacao final ainda depende do playtest manual no editor.

## Remocao da camada estatica duplicada da Vega - 03/10/2026

O usuario relatou que a Vega parecia conter dois corpos sobrepostos. A inspeção da arvore confirmou duas fontes de arte no mesmo alvo: `VegaAnimada`, criada em `main.gd`, e os nos legados `Jogador/VegaCampoRetrato` e `Jogador/VegaCampoNome`, definidos em `main.tscn`. Embora o codigo escondesse o retrato no `_ready()`, manter a camada na cena permitia que ela aparecesse durante estados de inicializacao/transicao e tornava a composicao ambigua.

`main.tscn` agora nao carrega mais o recurso estatico `vega_combate.png` nem cria `VegaCampoRetrato`/`VegaCampoNome`. `main.gd` mantem somente a instancia de `vega_animada/vega_animada.tscn` como arte da personagem no campo. `tests/test_composicao_combate.gd` foi endurecido para exigir a existencia da Vega animada e a ausencia das duas camadas antigas. Regras, input, custos, dano, turnos, run, mapa e arena nao foram alterados.

A captura Compatibility regenerada em `docs/evidencias_vega/repouso_1920.png` mostra uma unica Vega sobre o piso. `test_composicao_combate.tscn` e `tests/verificar_vega_animada.gd` passaram; a suite completa terminou com `TOTAL=57 FALHAS=0`. Permanecem os avisos conhecidos de recursos/RID no encerramento do renderer dummy. A validacao manual no editor continua sendo necessaria para confirmar a leitura em 1024x576 e 1920x1080.

## Passe de silhueta da Vega - 03/10/2026

O screenshot manual anterior foi tratado como RED para a composicao do corpo, embora a escala global ja estivesse adequada. O ajuste foi restrito a `vega_animada/vega_animada.tscn`: torso com escala `0.60 x 0.58`, pernas com escala `0.46`, ombros/cotovelos mais afastados e recortes dos antebracos deslocados para fora. A escala global continua limitada a `0.44`; regras, input, custos, dano, turnos, run, mapa e arena nao foram alterados.

`tests/verificar_vega_animada.gd` passou a verificar tambem a presenca vertical minima do torso, a reducao relativa das pernas, a separacao dos cotovelos e a distancia dos recortes dos punhos. A previsualizacao isolada de guarda foi regenerada depois do ajuste, assim como as capturas de combate em `docs/evidencias_vega/`. A inspecao dos frames confirma uma guarda mais aberta e a extensao do soco; isso continua sendo evidencia automatizada de apresentacao, nao substituto do playtest manual.

Verificacao executada com Godot `4.7.2.stable.official.ed1daf0bf`: `VEGA ANIMADA: 0 falhas`, suite completa de `57` cenas com `TOTAL=57 FALHAS=0`, importacao do editor com codigo 0, captura Compatibility com codigo 0 e `git diff --check` sem saida. Permanecem os avisos conhecidos de recursos/RID no encerramento dos renderers.

Proximo passo: abrir `main.tscn` no editor em 1024x576 e 1920x1080 e decidir se a silhueta agora esta proporcional ao piso; conferir respiracao, guarda, soco, dano e hover de Protecao antes de considerar a arte aprovada.

## Relato manual da Vega compacta - 03/10/2026

Screenshot enviado pelo usuario apos a reconstrução do rig: a escala da Vega agora cabe no piso e nao domina o cenario nem o HUD. A mesma imagem revela uma pendencia visual restante: o torso ainda le como curto/estreito, as pernas ocupam peso excessivo da silhueta e os dois bracos se aproximam demais na frente do peito. Esse relato nao altera regras nem codigo nesta observacao.

Decisao de trabalho: manter a escala global atual como baseline e revisar somente a composicao dos recortes do corpo no proximo passe. A proxima alteracao deve aumentar a presenca vertical do torso, reduzir levemente a dominancia das pernas e abrir os bracos lateralmente, sem aumentar a personagem inteira.

## Vega compacta e rig refeito - 03/10/2026

O usuario rejeitou a revisao ampliada da Vega: ela parecia um boneco de mola, estava grande em relacao ao cenario e a animacao de repouso nao era perceptivel. O problema foi tratado como falha de direcao visual, nao como mais um ajuste isolado de cotovelo.

O rig anterior foi arquivado de forma reversivel em `C:\Users\Wallace\Downloads\rogue-cyberpunk-patches-archive-2026-10-03\vega-animada-rig-2026-10-03`. `vega_animada/vega_animada.tscn` voltou a uma composicao compacta dos recortes originais: torso e cabeca foram recalibrados, as pernas mantem `scale.x = 1`, os ombros e cotovelos abrem a guarda e os dois bracos recebem `z_index` proprio. `vega_animada/vega_animada.gd` limita a escala global a `0.44`, centraliza a personagem na caixa do jogador e aumenta discretamente a respiracao, sem alterar a API de animacao ou qualquer regra do jogo.

`tests/verificar_vega_animada.gd` foi refeito para verificar o contrato visual atual: escala entre limites, pernas nao espelhadas, ombros/cotovelos separados, camadas visiveis, torso/cabeca proporcionais e respiracao; tambem conserva as verificacoes de soco, dano, input, custo, dano e barreira. A cena focada terminou com `VEGA ANIMADA: 0 falhas` em Godot `4.7.2.stable.official.ed1daf0bf`.

As capturas Compatibility foram regeneradas em `docs/evidencias_guarda/frames/` e `docs/evidencias_vega/`. A inspecao dos frames de guarda e do combate em 1920x1080 confirma que a Vega deixou de dominar a arena e que o soco desloca a guarda. A captura ainda e evidencia automatizada de apresentacao, nao substitui o playtest manual.

Proximo passo: abrir `main.tscn` no editor em 1024x576 e 1920x1080, conferir a escala sobre o piso, observar respiracao, soco e dano, e confirmar hover/Protecao sem moldura ciano sobre a personagem.

## Proporcoes e visibilidade dos dois bracos da Vega - 03/10/2026

O usuario relatou que a correcao anterior escondia o segundo braco e mantinha o torso desproporcional. A revisao ampliada confirmou a limitacao: afastar os pontos aproximados dos punhos nao comprovava visibilidade da arte. O antebraco traseiro ficava atras do torso; a cabeca tinha escala 0.28, o torso 0.4 e as pernas 0.5, com membros superiores comprimidos de forma desigual.

A cena da Vega foi realinhada pelos centros das articulacoes do atlas. Torso usa escala uniforme 0.45, cabeca 0.20, pernas 0.64 e segmentos dos bracos 0.30/0.32. Quadril, pescoco e ombros foram reposicionados; as pernas entram sob o quadril, com os pes no piso. O antebraco traseiro usa camada acima do torso e o punho permanece adiante da silhueta. Ambos os bracos apontam para o inimigo. O script compartilha constantes da guarda entre respiracao, soco e recuperacao, e ajusta a escala global pela altura reconstruida de 510 unidades.

O teste agora mede separacao no espaco do modelo, proporcao torso/cabeca e punho traseiro fora da silhueta do torso. Substitui as expectativas anteriores de punhos em lados opostos e distancia fixa em pixels de tela. Godot 4.7.2: VEGA ANIMADA: 0 falhas; composicao, layout e interacao do HUD passaram com codigo 0. Capturas Compatibility ampliadas de guarda, soco e dano e capturas do combate 1024/1920 terminaram com codigo 0. Foram inspecionados os frames 000, 023 e 049 de docs/evidencias_guarda/frames e o repouso de combate 1920, com os dois bracos visiveis e torso alongado. A suite completa de 57 cenas nao foi repetida nesta rodada; os resultados anteriores pertencem ao estado anterior. Avisos conhecidos de recursos retidos persistem no encerramento das capturas de combate e do teste focado.

Proximo passo: conferir a leitura do movimento no editor; a aprovacao visual anterior da guarda foi insuficiente e foi substituida por esta revisao ampliada.

## Correcao do rig de guarda da Vega - 03/10/2026

A captura do combate mostrou dois defeitos reais na pose articulada: a `PernaFrente` estava espelhada horizontalmente (`scale.x = -1`) e os dois punhos terminavam no mesmo corredor central do torso. A origem nao era a textura da arena nem o HUD; era a transformacao da cena da Vega.

`vega_animada/vega_animada.tscn` agora mantem as duas pernas sem espelhamento. O cotovelo traseiro foi aberto para `-3.80` na guarda, com `-3.95` durante a reacao a dano, e `vega_animada/vega_animada.gd` usa esses mesmos valores no repouso, soco, dano e retorno. A animacao continua partindo da pose atual e recuperando a guarda; cartas, custos, dano, estados, turnos, run, mapa e arena nao foram alterados.

`tests/verificar_vega_animada.gd` agora verifica separacao minima de 50 px entre os punhos, orientacao oposta em relacao aos cotovelos e ausencia de espelhamento horizontal das pernas. A captura Compatibility foi regenerada em `docs/evidencias_vega/repouso_1024.png`, `repouso_1920.png` e `soco_1920.png`; a inspecao confirmou a guarda mais aberta e as pernas sem inversao.

Verificacao executada com Godot `4.7.2.stable.official.ed1daf0bf`: `verificar_vega_animada.gd` terminou com `VEGA ANIMADA: 0 falhas`; a suite completa de 57 cenas terminou com `TOTAL=57 FALHAS=0`; importacao do editor headless terminou com codigo 0; a captura Compatibility terminou com codigo 0; `git diff --check` passou. Permanecem apenas os avisos conhecidos de recursos/RID no encerramento dos renderers.

Proximo passo: conferir manualmente a nova guarda em janela real, em 1024x576 e 1920x1080, e observar um soco e um dano sem Barreira.

## Correcao da moldura e tooltip da Vega articulada - 03/10/2026

A captura manual mostrou que a arte da Vega nao era a causa da composicao ruim: o botao-pai `Jogador` estava usando `ui_hq_v1/estilos/opcao_evento_interacao.tres` nos estados de hover, foco e pressao. Como esse botao ocupa toda a caixa reservada ao combatente, a interacao desenhava um retangulo ciano grande sobre o piso. O mesmo botao tambem abria `HudInspecao` ao passar o mouse, colocando o painel de Vida/Barreira sobre a arena.

`main.tscn` agora deixa os estados visuais do botao `Jogador` transparentes. O destaque da Vega permanece em `Jogador/Interacao`, com borda transparente separada, insets menores e cor ciano; `main.gd` so o mostra quando uma carta valida pode alvejar a jogadora. A inspeccao automatica foi retirada do botao-pai; Barreira, Combo e recursos continuam inspecionaveis pelos paineis proprios. Nenhuma regra de carta, alvo, custo, dano, turno, run ou animacao foi alterada.

`tests/test_composicao_combate.gd` ganhou regressao para estilo transparente, destaque separado e ausencia de tooltip sobre a Vega. A captura Compatibility em `docs/evidencias_vega/repouso_1024.png` foi regenerada e inspecionada: a Vega aparece sem a caixa ciano gigante e sem tooltip na arena.

Verificacao executada com Godot `4.7.2.stable.official.ed1daf0bf`: teste de composicao passou; `tests/verificar_vega_animada.gd` terminou com `VEGA ANIMADA: 0 falhas`; suite completa de 57 cenas terminou com `TOTAL=57 FALHAS=0`; importacao do editor, `verificar_hud_hq.gd` e `verificar_hover_hq.gd` terminaram com codigo 0; `git diff --check` passou. Permanecem os avisos conhecidos de encerramento do renderer dummy sobre recursos retidos e os avisos de textura do encerramento da captura OpenGL, sem falha funcional.

Proximo passo: abrir `main.tscn` no editor em 1024x576 e 1920x1080, passar o mouse sobre a Vega, selecionar Protecao e confirmar que o destaque aparece somente como alvo valido; depois testar um ataque e um dano sem Barreira.

## Vega articulada e correcao da guarda aplicadas - 03/10/2026

O `Vega-Guarda-Correcao-Patch` foi auditado antes da aplicacao e combinado seletivamente com o `Vega-Animada-Patch`. O `main.gd` candidato nao substituiu o arquivo vigente: o ajuste atual da faixa de turno em `+40` foi preservado. A integracao adiciona `vega_animada/pecas.png`, `vega_animada/vega_animada.gd` e `vega_animada/vega_animada.tscn`; o retrato estatico e o nome no campo sao ocultados somente durante o combate, enquanto a Vida, o shell e a faixa superior continuam os mesmos.

A correcao remove o espelhamento indevido do braco traseiro, abre a orientacao da perna dianteira, coloca os dois punhos acima e a frente dos cotovelos, executa soco com antecipacao/extensao/retorno e recupera a guarda apos dano. Interrupcoes partem da pose atual. A arte ignora input; ataques validos chamam `socar()`, e somente dano que chega a Vida chama `receber_dano()`. Cartas, custos, dano, estados, turnos, run, mapa e arena nao foram alterados.

Foram adicionados `tests/verificar_vega_animada.gd`, `tests/capturar_vega_animada.gd` e `tests/capturar_guarda_vega.gd`. A expectativa de `tests/test_composicao_combate.gd` foi atualizada para exigir `VegaAnimada` visivel e o retrato estatico oculto, sem relaxar verificacoes de regra ou de layout.

Verificacao executada com Godot `4.7.2.stable.official.ed1daf0bf`: importacao do editor com codigo 0; `tests/verificar_vega_animada.gd` terminou com `VEGA ANIMADA: 0 falhas`; a suite completa de 57 cenas terminou com `TOTAL=57 FALHAS=0`; `verificar_hud_basico.gd`, `verificar_hud_hq.gd` e `verificar_hover_hq.gd` terminaram com 0 falhas; `git diff --check` foi executado apos a documentacao. Capturas reais Compatibility terminaram com codigo 0: guarda em `docs/evidencias_guarda/frames/`, e combate em `docs/evidencias_vega/` para 1024 e 1920, incluindo soco.

As duas pastas de origem foram movidas de forma reversivel para `C:\Users\Wallace\Downloads\rogue-cyberpunk-patches-archive-2026-10-03`: `Vega-Animada-Patch` e `Vega-Guarda-Correcao-Patch`. Permanecem no projeto somente os arquivos integrados, testes e evidencias. Os avisos de encerramento do renderer dummy sobre recursos retidos continuam conhecidos; nao produziram falha funcional.

Proximo passo: abrir `main.tscn` em janela real, conferir o tamanho da Vega sobre o piso em 1024x576 e 1920x1080, testar hover fisico dos controles e jogar um ataque, uma Protecao e um dano sem Barreira para confirmar a leitura visual manual.

## Arena visual das Docas aplicada e patches antigos arquivados - 03/10/2026

O `Arena-Docas-Patch` foi integrado seletivamente sobre o HUD HQ vigente. `arena_chao.gd` agora carrega `hud_hq/cenarios/docas_dia.png` em uma camada `TextureRect` que preserva proporcao, preenche a janela e ignora input. `hud_hq/apresentacao_tela.gd` deixa `MaoDock` transparente sobre o piso e adiciona contorno aos textos soltos de Vega e do limite da mao. Foi criado `tests/capturar_arena_docas.gd`; `main.tscn`, `project.godot`, regras, dados e fluxo nao foram substituidos.

A captura Compatibility real com Godot `4.7.2.stable.official.ed1daf0bf` terminou com codigo 0 e gerou oito imagens em `docs/evidencias_arena_docas/`: combate 1024/1920, hover de Energia, hover de reliquia, consulta do baralho, hover do fim de turno, combate duplo e mapa. A imagem foi inspecionada; o cenario aparece no combate, os controles permanecem legiveis e a arena fica oculta ao retornar ao mapa. A suite completa de 57 cenas passou em tres lotes com `FALHAS=0`; `git diff --check` passou; HUD basico, HUD HQ e hover HQ continuaram verdes.

As cinco pastas de origem de patch foram removidas da raiz por movimento reversivel para `C:\Users\Wallace\Downloads\rogue-cyberpunk-patches-archive-2026-10-03`: `Arena-Docas-Patch`, `HUD-Godot-Basico`, `HUD-Godot-HQ-Recursos`, `HUD-HQ-Tela-Patch` e `Implementacao_Recursos_R2`. Permanecem no projeto somente os arquivos integrados, testes, documentacao e evidencias. Os avisos de encerramento do renderer dummy continuam conhecidos; a captura Compatibility real nao apresentou falha funcional.

Proximo passo: abrir `main.tscn` em 1024x576 e 1920x1080, conferir contraste sobre o piso, hover fisico, consulta do baralho e configuracoes, e jogar Direto Hidraulico, Quebra-chassi e defesa com Barreira.

## Merge aplicado do patch HUD HQ de tela e hover - 03/10/2026

O patch `HUD-HQ-Tela-Patch` foi integrado por selecao de arquivos sobre o estado atual do projeto. Nao foram copiados `project.godot`, `main.tscn` nem os documentos da pasta candidata. Foram aplicados os trechos visuais de `main.gd` e `hud_inspecao.gd`, criados `hud_hq/apresentacao_tela.gd` e `hud_hq/hover_hq.gd`, adicionados os SVGs de icones/molduras e incluidos `tests/verificar_hover_hq.gd` e `tests/capturar_hud_tela.gd`.

A HUD agora estiliza shell, alvo, overlays, navegacao, fim de turno e alvos multiplos com molduras HQ; usa icones HQ para intencao, compra, descarte, rota, baralho, configuracoes, Vida e reliquias; abre tooltips claros para recursos, pilhas, navegacao e configuracoes; atualiza a inspecao durante mudancas reais de Energia; e exibe realce animado de hover/foco sem interceptar input. Reliquias existentes sao preservadas quando a lista nao muda. Regras de cartas, custos, dano, estados, turnos, run, mapa e eventos nao foram alteradas.

Durante a integracao, o teste RED revelou que a faixa do turno sobrepunha o titulo por causa do tamanho minimo real da fonte; `main.gd` manteve `AcaoLabel` fora da geometria e posicionou o numero em `+40` para respeitar o titulo de 35 px. As expectativas de apresentacao de `test_hud_r2.gd` e `test_hud_r3.gd` foram atualizadas para os icones/molduras HQ e para os marcadores dinamicos de Energia; nenhuma expectativa de regra foi alterada.

Verificacao executada com Godot `4.7.2.stable.official.ed1daf0bf`: importacao headless com codigo 0; `tests/verificar_hover_hq.gd` terminou com `HOVER HQ: 0 falhas`; `tests/verificar_hud_hq.gd` terminou com `HUD HQ: 0 falhas`; `tests/verificar_hud_basico.gd` terminou com `HUD BASICO OK`; a suite completa de 57 cenas terminou com `TOTAL=57 FALHAS=0`; `git diff --check` passou. Permanecem os avisos conhecidos do renderer dummy sobre recursos retidos (`18 ObjectDB`, `8 resources`, `2 RID`). Ainda falta playtest manual em janela real, especialmente hover fisico, contraste, velocidade do realce, consulta de baralho/configuracoes e o capture script em 1024x576 e 1920x1080.

Proximo passo: abrir `main.tscn` no editor, testar Tab e mouse sobre Energia, Barreira, Combo, compra, descarte, reliquias, rota, baralho, configuracoes e fim de turno; depois jogar Direto Hidraulico, Quebra-chassi e uma defesa com Barreira.

## Merge aplicado do HUD HQ de recursos - 02/10/2026

O pacote `HUD-Godot-HQ-Recursos` foi auditado e integrado por selecao de arquivos. A diferenca funcional estava em `hud_hq/` e em pontos pequenos de `main.gd`; `main.tscn` era identico ao arquivo da raiz. A copia candidata nao foi usada como projeto substituto porque faltavam PNGs e fontes do `ui_hq_v1`; os recursos existentes da raiz foram preservados.

`hud_hq/painel_recursos.gd` desenha molduras vetoriais com reticula, tinta e efeitos para Energia, Barreira e Combo. `hud_hq/feedback_recursos.gd` observa mudancas reais, cancela tweens anteriores do mesmo efeito, anima gasto/recuperacao de Energia, ganho/absorcao de Barreira e ganho/consumo de Combo, e reinicia o feedback ao sair do combate. `main.gd` apenas notifica esses eventos nos pontos existentes de resolucao; cartas, custos, dano, estados, turnos, run, mapa e eventos nao foram alterados.

Durante o merge, a moldura HQ foi mantida sobre um `StyleBoxFlat` transparente para preservar o contrato visual da HUD basica, o preenchimento proporcional da Energia foi mantido para a regressao R2 e a geometria maior da faixa de turno foi preservada para nao reintroduzir sobreposicao em 1920x1080. Foi adicionado `tests/verificar_hud_hq.gd` como teste funcional local.

Verificacao executada com Godot `4.7.2.stable.official.ed1daf0bf`: importacao do editor headless com codigo 0; `verificar_hud_hq.gd` terminou com `HUD HQ: 0 falhas`; `verificar_hud_basico.gd` terminou com `HUD BASICO OK`; os 57 testes `tests/test_*.tscn` passaram em lotes com `FALHAS=0`; `git diff --check` passou. Os testes focados continuam registrando os avisos conhecidos do renderer dummy sobre 18 ObjectDB, 8 resources e 2 RID. Ainda falta playtest manual em janela real, especialmente a intensidade dos pulsos e fragmentos.

Proximo passo: abrir `main.tscn` em 1024x576 e 1920x1080, jogar Direto Hidraulico, usar Quebra-chassi, absorver dano com Barreira e encerrar um turno com Combo restante.

## Merge aplicado do HUD basico - 02/10/2026

O usuario aprovou testar a direcao alternativa de `HUD-Godot-Basico`. O merge foi aplicado na raiz por selecao de arquivos, preservando o restante do projeto: a pasta `hud_basico/` foi adicionada, `main.gd` e `main.tscn` receberam as diferencas pequenas do pacote, e `tests/verificar_hud_basico.gd` tornou-se uma regressao local. A copia candidata, seus documentos e seu `project.godot` nao foram usados como substitutos do projeto principal.

O HUD de combate agora usa os estilos simples do pacote em shell, alvo, estatisticas, overlays, turno e intencao; adiciona marcadores circulares de Energia e legendas para Energia, Compra, Descarte, Barreira e Combo; usa barras nativas de Vida; oculta o preenchimento HQ da Vida no topo; mantem Barreira legivel durante o combate; e reposiciona a faixa de turno, recursos inferiores e controles. Regras, dados, cartas, selecao, resolucao, run, mapa e eventos permaneceram inalterados. O `AcaoLabel` legado continua oculto e recebeu area minima fora do HUD para nao participar da geometria.

Conflitos da suite foram resolvidos nas expectativas de apresentacao: molduras simples em vez de `StyleBoxTexture`, Vida nativa em vez do preenchimento HQ no topo, Barreira zerada visivel, icones efetivamente usados apos atualizacao em runtime e titulo do turno com tipografia condensada. A alteracao nao foi usada para esconder falhas de regra.

Verificacao executada com Godot `4.7.2.stable.official.ed1daf0bf`: importacao do editor headless com codigo 0; `tests/verificar_hud_basico.gd` terminou com `HUD BASICO OK`; suite `tests/test_*.tscn` terminou com `TOTAL=57 FALHAS=0`; `git diff --check` terminou com `DIFF_CHECK=0`. O teste focado ainda registra os avisos conhecidos do renderer dummy (`18 ObjectDB`, `8 resources`, `2 RID`) apesar do codigo 0. Nao houve ainda playtest manual com mouse/teclado ou nova captura OpenGL da raiz apos o merge.

Proximo passo: abrir `main.tscn` em janela real, conferir 1024x576 e 1920x1080, especialmente o turno, as legendas dos recursos, a consulta de cartas e a mao cheia; depois decidir se a direcao simples permanece ou se volta a usar a familia HQ.

## Auditoria da pasta `HUD-Godot-Basico` — 02/10/2026

Estado observado: `HUD-Godot-Basico` não é um módulo autônomo nem uma cópia independente pronta para abrir. Ela contém uma cópia quase completa do projeto, mas os arquivos compartilhados estão idênticos ao workspace atual; a diferença funcional fica concentrada em `main.gd`, `main.tscn`, `project.godot`, `hud_basico/` e `tests/verificar_hud_basico.gd`. A pasta também não traz todos os binários-base de `ui_hq_v1` necessários para abrir sozinha; o teste isolado só pode ser executado depois de completar temporariamente PNGs/fontes do projeto atual.

O conteúdo novo é uma direção alternativa de HUD: `hud_basico/apresentacao_hud.gd` injeta estilos `StyleBoxFlat` simples, legendas persistentes para Barreira/Combo/Compra/Descarte, marcadores circulares de Energia e estilos nativos de barras de Vida. `main.tscn` troca molduras HQ por esses estilos em shell, alvo, estatísticas, overlays, turno e intenção, além de trocar parte dos ícones por SVGs R2. `main.gd` oculta o preenchimento HQ da Vida no topo, reposiciona o anúncio de turno e mantém Barreira visível durante o combate. Isso conflita com a decisão vigente do HUD 2.0: molduras `ui_hq_v1`, Vida fina dentro do shell, recursos sem placas/legendas persistentes e Barreira inativa oculta.

Verificação em Godot `4.7.2.stable.official.ed1daf0bf`: o teste incluído `tests/verificar_hud_basico.gd` passou em uma cópia temporária completada com os binários-base: `HUD BASICO OK`, cobrindo combate, Energia/fim de turno, consultas, configurações, limites em 1024×576/1920×1080 e encontro duplo. A cópia candidata não contém a suíte histórica; ao acrescentar temporariamente os testes atuais, a regressão terminou com `TOTAL=57 FALHAS=5`: `test_composicao_combate` (moldura-base HQ), `test_consulta_pilhas` (preenchimento da Vida no topo), `test_hud_r2` (Barreira inativa), `test_hud_r3` (caixa HQ de Energia) e `test_layout_combate` (sobreposição do título/número de turno). Os avisos de recursos retidos do teste HUD foram `18 ObjectDB`, `8 resources` e `2 RID`; não foram tratados como falha funcional isolada.

Conclusão da auditoria: não copiar a pasta inteira. Se a direção visual simples for aprovada, a integração mecânica é pequena e pode usar `hud_basico/`, um merge direcionado de `main.gd`/`main.tscn` e o teste; `project.godot` só mudaria opcionalmente de UID para caminho textual. Não há decisão de substituir o HUD HQ nesta auditoria; o pacote permanece como proposta comparada ao estado vigente. Nenhum arquivo do projeto foi alterado nesta investigação além deste registro.

## HUD 2.0 do combate — 29/09/2026

Observado no código antes da mudança: o combate já tinha seleção de cartas/alvos, mão em leque, intenções, Vida, Energia, Barreira, Combo e controles de deck/rota/configurações. Compra e descarte exibiam contagem, mas não abriam consulta. O deck usava uma lista textual. A referência de design desta rodada é o HUD kit anexado pelo usuário; a imagem de combate anexada serve somente para composição. A hipótese de que uma simples escala de 1024×576 bastaria foi rejeitada pelas capturas: o viewport precisava acompanhar o tamanho real da janela.

Implementação: `main.tscn`/`main.gd` reorganizam shell, campo, intenção, mão e controles; `mao_combate.gd` ajusta as margens do leque, `botao_carta.gd` preserva um tamanho mínimo de texto nas cartas menores e `hud_inspecao.gd` reposiciona o tooltip após o layout. O reflow usa o tamanho real da janela somente no combate; as demais telas mantêm o viewport virtual anterior. O shell mostra retrato, nome e Vida da Vega, relíquias individuais, deck com contagem, rota e configurações. Dois recortes transparentes criados a partir da linguagem do kit foram salvos em `ui_hq_v1/assets/personagens/`; a Vega aparece no campo sem repetir Vida, e os drones aparecem acima dos painéis compactos com Vida fina e intenção por unidade. Derrotados são ocultados do grupo de alvos. Energia, compra, descarte e fim de turno ficam ao redor da mão. Os três overlays de cartas usam `carta.tscn`; compra e descarte consultam apenas suas pilhas, deck consulta a run completa, e a área rolável suporta deck grande. Não houve alteração deliberada em valores ou regras de jogo.

Verificação executada em Godot `4.7.2.stable.official.ed1daf0bf`: após o último ajuste de viewport, a suíte de 57 cenas `tests/test_*.tscn` terminou novamente em `TOTAL=57 FALHAS=0` e `git diff --check` passou. `test_consulta_pilhas.tscn` confirmou pilhas corretas, fechamento, turno estável, deck de 30 cartas rolável e descarte vazio. `test_layout_combate.tscn`, `test_composicao_combate.tscn`, `test_hud_r2.tscn`, `test_hud_r3.tscn`, `test_bestiario_visual.tscn` e `test_interacao_hud_combate.tscn` passaram. Capturas reais OpenGL/Compatibility em 1024×576 e 1920×1080, incluindo solo, dupla, hover, seleção, mão cheia e overlays, foram geradas em `docs/evidencias/hud2_2026-09-29/`; a saída dos previews de combate confirmou viewport real em cada resolução. As capturas laterais de mapa e evento em 1920×1080 confirmaram base virtual de 1152×648. As capturas foram inspecionadas para cortes e sobreposições. O teste automatizado não substitui playtest manual no editor.

Limitação observada nas capturas: a arte provisória do drone é compartilhada pelos tipos de inimigo e ainda falta uma silhueta individual por ficha do bestiário. Na mão de dez cartas em 1024×576, os títulos se sobrepõem em repouso; foco/hover traz a carta à frente para leitura. A importação headless do editor reimportou os PNGs, mas duas execuções encerraram com `-1073741819` após carregar o layout do editor; os testes e previews do jogo continuaram executando. Uma captura lateral do preview de evento em 1920×1080 mostrou cabeçalhos sobrepostos; esta rodada não redesenhou mapa, eventos, descanso ou Desmanche.

## HUD 2.0 — passe de fidelidade visual — 30/09/2026

Implementação observada após aprovação do passe visual: o shell superior usa o recorte angular `energia_caixa` do atlas HUD; Vida da Vega usa preenchimento fino dentro do shell; painéis inimigos usam caixa escura do kit com intenção cyan interna, Vida e estados no mesmo bloco; Energia, Barreira, Combo, Compra, Descarte e Relíquia usam os ícones de `ui_hq_v1/componentes/icones/`; overlays usam container escuro com borda cyan do kit; o fim de turno usa botão cyan escuro e tipografia condensada. A estrutura funcional foi preservada: mão, seleção, hover, intenções, compras, descarte, overlays e navegação não foram redesenhados.

Comparação visual executada nas capturas finais: [solo 1920×1080](evidencias/hud2_2026-09-29/hud2_solo_1920.png), [solo 1024×576](evidencias/hud2_2026-09-29/hud2_solo_1024.png), [dupla](evidencias/hud2_2026-09-29/hud2_dupla_1920.png), [mão cheia](evidencias/hud2_2026-09-29/hud2_mao_cheia_1024.png) e [overlay de compra](evidencias/hud2_2026-09-29/hud2_compra_1920.png). O shell, os painéis de inimigo, os recursos e os overlays pertencem à família do kit; o botão de turno não usa amarelo industrial; não há fonte Bangers em informação cotidiana visível. As 57 cenas de teste terminaram com `EXIT=0` e `git diff --check` terminou em `DIFF_CHECK=0`.

Componentes antigos eliminados: faixa superior plana, barra de Vida grossa solta, caixas provisórias de Energia/Compra/Descarte, botão branco/preto de fim de turno, moldura branca antiga do overlay e uso de ícones SVG do HUD R2 nesses componentes. Componentes convertidos: shell, Vida, painéis de inimigo, intenção, estados, recursos do jogador, fim de turno, overlays e tipografia cotidiana. Limitações restantes: a arte do drone continua compartilhada entre tipos diferentes; a mão cheia em 1024×576 mantém sobreposição de títulos porque sua posição e comportamento foram preservados; o cenário de combate ainda é provisório. Nenhum mapa ou evento foi alterado nesta rodada.

## Oito eventos reais das Docas — 29/09/2026

Os eventos placeholder foram substituídos por `ponto_da_queda`, `turno_encerrado`, `carga_descartada`, `caixa_preta`, `agua_morta`, `sobrevivente`, `posto_inspecao` e `ninho_sob_cais`. Cada entrada em `dados_eventos.gd` declara família, texto curto, opções, condições, custo, flags, recompensa, ação de deck e/ou combate. A UI continua apenas apresentando os dados; não há comportamento narrativo hardcoded nos botões.

`RunState` agora registra eventos resolvidos, evitando repetição e dupla concessão quando uma tela é tentada novamente. Condições aceitam flags obrigatórias e “qualquer uma”; `viu_relatorios_ataques` libera “Eles já sabiam”, e `viu_relatorios_ataques` ou `extraiu_caixa_preta` libera “Apresentar registros”. Eventos de custo aplicam Vida antes de flags/recompensas; morte encerra a tentativa sem concluir o nó.

Turno Encerrado, Caixa-Preta e O Sobrevivente reutilizam `DesmancheOverlay`/`DesmancheRun` para remoção e recalibração. O overlay mantém cópias já recalibradas visíveis e usa metadados `personagem`/`exclusiva` de `dados_cartas.gd` para filtrar cartas da Vega. Combates de Posto de Inspeção e Ninho sob o Cais preservam o evento pendente e só aplicam flags/recompensa após vitória; derrota usa o encerramento normal da tentativa. Relíquias globais reutilizam o catálogo; Água Morta usa `reliquia_evento_agua_morta_provisorio`, explicitamente provisória. A futura relíquia específica da Vega permanece apenas preparada por dados, sem regra inventada.

Verificação funcional: `tests/test_eventos_reais_docas.tscn` exercita catálogo, seed, família em eventos adjacentes, flags condicionais, caminho Ponto da Queda → Sobrevivente, remoção/recalibração no overlay, custo sobrevivido e letal, recompensa sem duplicação e combate especial com vitória/derrota. A suíte completa de 56 cenas `tests/test_*.tscn` terminou com `TOTAL=56 FALHAS=0` em Godot `4.7.2.stable.official.ed1daf0bf`; `git diff --check` passou e a importação headless do editor passou. O playtest de UI foi executado pelos sinais reais dos botões e pela árvore criada do overlay; não houve redesign nem captura artística nesta tarefa. A saída do preview em renderer dummy não produz PNG, portanto não foi registrada como captura visual.

## Ajustes de Combo e Vida por inimigo — 29/09/2026

O Combo agora é alterado somente por cartas que declaram `ganha_combo` nos dados. `Golpe` continua causando 6 de dano e não gera Combo; `Direto Hidráulico` declara e concede 1; Finalização permanece consumindo todo o valor. A descrição da carta, a recompensa e o tooltip usam a mesma declaração, sem regra implícita por tipo de ataque.

Encontros múltiplos passaram a mostrar, dentro de cada botão de alvo, uma barra de Vida proporcional com `atual/máximo` no interior. A Barreira aparece em uma leitura separada somente quando ativa; nome, intenção, foco/hover, seleção, morte e interação com cartas foram preservados. A atualização limita visualmente a Vida ao intervalo `0..máximo`, inclusive para valores altos e negativos, sem alterar o estado real de combate.

Capturas OpenGL/Compatibility desta rodada: [dois alvos em 1024×576](evidencias/bestiario_docas_r2_2026-09-29/dupla_1024x576.png) e [dois alvos em 1920×1080](evidencias/bestiario_docas_r2_2026-09-29/dupla_1920x1080.png). A captura mostra um alvo em 26/26 e outro após dano em 12/18; `Direto Hidráulico` mantém `+1 Combo` e `Golpe` não o exibe.

Verificações executadas em Godot 4.7.2: `test_resolucao_cartas.tscn`, `test_catalogo_cartas.tscn` e `test_bestiario_visual.tscn` passaram; o teste visual também cobriu dano, recuperação, Barreira, morte, valores acima do máximo e valores negativos. A suíte completa de 55 cenas `test_*.tscn` foi executada em dois lotes e terminou com `TOTAL=55 FALHAS=0`; `test_interacao_hud_combate.tscn` também passou na repetição isolada. A importação headless do editor passou e `git diff --check` terminou com `DIFF_CHECK=0`. A rodada final direta também passou em catálogo, resolução, bestiário visual, interação e HUD R2.

## Primeiro bestiário comum das Docas — 29/09/2026

Implementados seis inimigos comuns com Vida, Barreira e intenção próprias: Drone de Carga, Estivador Aumentado, Drone Reparador, Sentinela de Inspeção, Caranguejo de Sucata e Guindaste Autônomo. Nove encontros são sorteados de pools de abertura, meio e fim do distrito; os dois primeiros combates usam apenas o pool de inimigos únicos, e a seed preserva as escolhas. A estrutura de 11 nós, o ramo Elite/Desmanche, Boss provisório, recompensas, REST, eventos e estado persistente da run não foram alterados.

`EncontroCombate` executa todos os inimigos vivos e só encerra o combate após a derrota de todos. Encontros de dois alvos exibem botões individuais com Vida, Barreira ativa e próxima intenção; cada carta atinge o botão escolhido. O alvo único existente continua para Elite/Boss e testes legados. O Reparador escolhe outro inimigo vivo de menor porcentagem de Vida e usa ataque solo de 5 quando perde os aliados. Marcado pertence à próxima ofensiva da própria Sentinela, cujo dano anunciado já inclui +6. Frenesi do Estivador é permanente a partir de 17 de Vida. Recalibrando do Guindaste usa condição própria e expira na próxima ação, sem criar Exposto. Barreira inimiga expira no início da próxima ação de seu dono. Aliados são referenciados fracamente para não reter combatentes após o encontro.

Valores ainda provisórios: o Ombro de Carga prepara +2 no próximo golpe normal, e a janela de +50% do Guindaste arredonda dano fracionário para cima. Não há carta multi-hit da Vega no catálogo atual; os três golpes das Garras foram testados individualmente contra Barreira. Os novos alvos usam placeholders existentes, sem arte final. A validação foi visual por captura OpenGL e teste programático da árvore/interação; não houve playtest manual prolongado com mouse e teclado nesta rodada.

Capturas inspecionadas: [dupla 1024×576](evidencias/bestiario_docas_2026-09-29/dupla_1024x576.png), [dupla 1920×1080](evidencias/bestiario_docas_2026-09-29/dupla_1920x1080.png), [Sentinela/Marcado](evidencias/bestiario_docas_2026-09-29/sentinela_1024x576.png) e [Guindaste/Recalibrando](evidencias/bestiario_docas_2026-09-29/guindaste_1024x576.png). A cena visual confirmou dois alvos visíveis e clicáveis, ambos dentro da viewport, intenção por alvo e Golpe aplicado apenas ao segundo. O mesmo teste derrotou os alvos em sequência: a primeira morte não abriu recompensa, a segunda abriu. Em Godot 4.7.2, a última execução da suíte `tests/test_*.tscn` terminou com `TOTAL=55 FALHAS=0`; a importação headless do editor e `git diff --check` passaram. Uma execução anterior teve saída 1 intermitente do processo do teste Desmanche, embora ele imprimisse `OK`; a repetição isolada e a suíte posterior saíram com código 0. Avisos de recursos residuais na saída da Godot persistem nos testes de cena, sem falha de execução na passagem final.

## Correção da tela vazia do Desmanche — 28/09/2026

Relato reproduzido: o mapa entrava no nó `desmanche_docas`, o título era exibido, mas nenhuma carta ou ação aparecia. O `RunState` estava correto: o deck chegava preenchido com as 12 cartas iniciais. A causa exata era de layout da UI dinâmica: `DesmancheOverlay` recebia somente seu tamanho mínimo (`627×81` no teste), então o `ScrollContainer` filho ficava com altura `0`; as 12 linhas eram criadas (`Lista` com aproximadamente `563×802`), porém fora da área visível.

Correção: o overlay usa preset de âncoras e offsets para preencher o pai, o scroll tem uma área mínima funcional e a lista mantém rolagem para decks grandes. A interação agora é seleção de carta → `REMOVER`/`RECALIBRAR` → confirmação; `CANCELAR SELEÇÃO` limpa a seleção sem abandonar o nó. Cartas já recalibradas continuam na lista e deixam `RECALIBRAR` desabilitado quando selecionadas. Se o deck não tiver nenhuma ação possível, a tela explica o motivo e oferece uma conclusão segura do nó; esse caso é registrado no console.

Verificação da árvore de controles: deck persistente de 12 cartas produz 12 linhas visíveis, controles de seleção e scroll com área positiva. Um deck de 30 cartas mantém a última cópia acessível por rolagem. Cópias duplicadas e tokens `#aprimorado` foram testados. A validação headless focada passou com `OK: fluxo do Desmanche`; a suíte completa terminou com `TOTAL=53 FALHAS=0`, a importação do editor headless terminou com código 0 e `git diff --check` passou.

## Primeira infraestrutura da run das Docas — 28/09/2026

Estado observado: `MapaRun` usa um template de 11 nós percorridos por rota (12 nós no grafo), três blocos e Boss. O ponto 6 bifurca em Elite ou Desmanche e reconverge no ponto 7. A estrutura é definida antes do conteúdo; a seed preenche quatro inimigos comuns distintos e três eventos distintos retirados de um catálogo maior. Repetir a seed repete estrutura e conteúdo. Famílias de eventos podem se repetir quando os eventos estão separados por outros tipos de nó; a restrição aprovada vale apenas para eventos diretamente consecutivos.

`RunState` é a autoridade da tentativa para seed, mapa, Vida, deck (incluindo recalibrações), relíquias, flags, posição, nó em andamento e concluídos. A cena principal conserva pontes para os controles e testes legados. Reabrir o mapa preserva a instância gerada. Combate, evento, REST e Desmanche só concluem o nó depois da resolução; derrota em combate ou por custo letal de evento encerra a tentativa sem concluir o nó. Energia, Barreira, Combo e demais recursos temporários não entram no estado da run.

Combates comuns oferecem três cartas comuns/incomuns; Elite oferece uma rara e duas comuns/incomuns, com escolha de uma ou `Pular`. O Desmanche permite remover uma cópia ou recalibrar uma cópia de carta por visita; a lista tem rolagem para decks maiores. REST cura até 8 de Vida (valor de teste) e permite prosseguir com Vida cheia. Eventos são orientados a dados, podem conceder flags e habilitar opções condicionais. O Boss provisório usa o encontro existente da Unidade de Contenção Portuária e encerra a run ao ser vencido; não é o Lastro definitivo.

Verificação executada na Godot 4.7.2: as duas rotas de 11 nós foram percorridas em teste até a vitória do Boss; também foram cobertos seed repetida, famílias, persistência, recompensa/skip, flags, combate especial, REST, Desmanche e derrota. A suíte headless `tests/test_*.tscn` terminou com `TOTAL=53 FALHAS=0`; a importação do editor headless terminou com código 0 e `git diff --check` sem saída. Não houve validação manual com mouse/teclado nesta rodada nem captura visual nova; o resultado de integração visual ainda deve ser confirmado no editor. Os testes antigos do fluxo de sete pontos foram atualizados para o recorte vigente; as telas de prêmio duplo permanecem no projeto como compatibilidade de testes/previews, mas não são usadas na run nova.

Próxima verificação curta no editor: iniciar uma run, anotar a seed no console, escolher o ramo Desmanche e recalibrar uma cópia; conferir se o token melhorado aparece no Baralho ao voltar ao mapa.

## Leque e foco da mão de combate — 28/09/2026

A mão apresenta seis ou dez cartas com pequena inclinação, curva e sobreposição. Cada carta conserva uma faixa exposta para mouse; o layout reserva espaço à esquerda para a Energia. Hover, foco de teclado e seleção levantam e endireitam a carta, que passa à frente das vizinhas. A seleção mantém o destaque até ser jogada, desmarcada ou cancelada com Escape. O alvo compatível com a carta selecionada recebe o destaque de interação existente. A troca de foco por teclado é imediata; o movimento de mouse usa tween curto de 0,12 s. A arte, textos, custos, ordem, limite de dez, faixa R3 e resolução de combate permanecem.

Capturas GL Compatibility inspecionadas: [repouso 1024×576](evidencias/mao_hq_r3_2026-09-28/repouso_1024x576.png), [hover 1024×576](evidencias/mao_hq_r3_2026-09-28/hover_1024x576.png), [foco 1024×576](evidencias/mao_hq_r3_2026-09-28/foco_1024x576.png), [seleção 1024×576](evidencias/mao_hq_r3_2026-09-28/selecao_1024x576.png), [mão cheia 1024×576](evidencias/mao_hq_r3_2026-09-28/cheia_1024x576.png), [repouso 1920×1080](evidencias/mao_hq_r3_2026-09-28/repouso_1920x1080.png), [hover 1920×1080](evidencias/mao_hq_r3_2026-09-28/hover_1920x1080.png), [foco 1920×1080](evidencias/mao_hq_r3_2026-09-28/foco_1920x1080.png), [seleção 1920×1080](evidencias/mao_hq_r3_2026-09-28/selecao_1920x1080.png) e [mão cheia 1920×1080](evidencias/mao_hq_r3_2026-09-28/cheia_1920x1080.png). Os PNGs têm as dimensões nominais; o viewport lógico do preview ficou em 1152×648 por escala de conteúdo do projeto. O preview usa estados determinísticos e posicionamento programático do cursor/foco.

Verificações: `test_mao_hq.tscn` falhou antes da implementação para carta reta em mão cheia e ausência de subida/foco; depois passou. Simula mouse em cada uma das dez cartas, clique, Tab, Enter, Escape, seleção persistente, destaque de alvo e jogada real. `test_layout_combate.tscn` passou após proteger Energia e os limites da faixa; a suíte completa terminou com `TOTAL=43 FALHAS=0` em Godot 4.7.2.

## Relíquias individuais na faixa R3 — 28/09/2026

`TopoReliquias` deixou de ser uma lista de nomes e passou a ser uma sequência de botões de ícone, criada a partir de `jogador_combate.reliquias_run`. Cada item preserva o SVG aprovado de relíquia, possui foco/hover próprio e abre uma inspeção somente com o nome e o efeito daquela relíquia. A inspeção conjunta e o painel persistente de nomes foram removidos da faixa.

O contêiner fica limitado à área esquerda da faixa, antes de Baralho, Rota e Configurações. Foram exercitados os estados de uma, duas e três relíquias no teste funcional; o preview também cobre uma, três e todas as relíquias disponíveis no catálogo atual. As capturas foram geradas em 1024×576 e 1920×1080; a área útil reportada pelo renderer permanece 1152×648 neste ambiente escalado.

Evidências: [uma 1024×576](evidencias/hud_r3_reliquias_2026-09-28/reliquia_1_1024x576.png), [três 1024×576](evidencias/hud_r3_reliquias_2026-09-28/reliquia_3_1024x576.png), [várias 1024×576](evidencias/hud_r3_reliquias_2026-09-28/reliquia_varias_1024x576.png), [uma janela grande](evidencias/hud_r3_reliquias_2026-09-28/reliquia_1_1920x1080.png), [três janela grande](evidencias/hud_r3_reliquias_2026-09-28/reliquia_3_1920x1080.png) e [várias janela grande](evidencias/hud_r3_reliquias_2026-09-28/reliquia_varias_1920x1080.png).

Verificações: `test_hud_r3.tscn` passou com inspeção exclusiva, foco/hover, quantidades e não sobreposição dos controles. A suíte completa `tests/test_*.tscn` foi executada novamente e terminou com `TOTAL=42 FALHAS=0`; importação headless do editor passou com código 0 e `git diff --check` não produziu saída.

## Navegação superior R3 do combate — 28/09/2026

O bloco persistente `COMBATE / PONTO / BARALHO` foi ocultado e substituído por uma faixa superior compacta em `main.tscn`, com retrato provisório de Vega, Vida atual/máxima real, relíquias obtidas e acessos a Baralho, Rota e Configurações. A barra de Vida no campo, os símbolos R2, as cartas, a mão e as regras foram preservados. Os novos SVGs R3 são apenas retrato provisório e símbolo de configurações; não substituem os ícones R2 aprovados.

O Baralho da faixa reutiliza a consulta funcional da run. Durante um combate, Rota oferece inspeção contextual do ponto e do combate atuais, pois a tela de mapa existente não permite sair de um nó em andamento; não foi simulada navegação. Configurações abre um painel de Som (mute do barramento Master) e Tela (alternância de tela cheia), com fechamento por botão ou Esc. `Mão n/10` fica oculta no repouso e só aparece com a mão cheia. A inspeção das relíquias mostra nomes e descrições reais, junto à faixa; por ser contextual, pode se sobrepor temporariamente à área central do campo.

Capturas reais em GL Compatibility, inspecionadas visualmente: [repouso 1024×576](evidencias/hud_r3_2026-09-28/repouso_1024x576.png), [rota 1024×576](evidencias/hud_r3_2026-09-28/rota_1024x576.png), [relíquias 1024×576](evidencias/hud_r3_2026-09-28/reliquias_1024x576.png), [menu 1024×576](evidencias/hud_r3_2026-09-28/menu_1024x576.png), [Baralho 1024×576](evidencias/hud_r3_2026-09-28/baralho_1024x576.png), [mão cheia 1024×576](evidencias/hud_r3_2026-09-28/mao_cheia_1024x576.png), [repouso na janela grande](evidencias/hud_r3_2026-09-28/repouso_1920x1080.png), [rota na janela grande](evidencias/hud_r3_2026-09-28/rota_1920x1080.png), [relíquias na janela grande](evidencias/hud_r3_2026-09-28/reliquias_1920x1080.png) e [menu na janela grande](evidencias/hud_r3_2026-09-28/menu_1920x1080.png). A janela grande foi solicitada como 1920×1080 e produziu imagem útil de 1920×1061 neste ambiente. O preview injeta relíquias reais do catálogo para a captura e aciona foco/botões programaticamente; não comprova movimento físico do cursor.

Verificações: teste R3 escrito antes da alteração falhou para o bloco antigo; depois passou para Vida, relíquias, rota contextual, Baralho real, menu e aviso de mão cheia. A suíte `tests/test_*.tscn` foi executada com cenas posicionais (não apenas carregadas) e terminou com `TOTAL=42 FALHAS=0` na Godot `4.7.2.stable.official.ed1daf0bf`. Importação headless do editor: código 0; `git diff --check`: sem saída. As capturas foram avaliadas separadamente dos testes automatizados.

## Revisão de recursos R2 — 28/09/2026

Implementada a especificação aprovada em `Implementação_Recursos_R2/IMPLEMENTACAO_RECURSOS_R2.md`, usando `acabamento_hud_r2_estudo.svg` como referência de escala e hierarquia. Energia mantém o SVG aprovado e agora mostra carga proporcional no interior da célula, com `atual/máximo` sobreposto e legível em `4/4`, `2/4` e `0/4`. Combo mostra apenas o acumulado abaixo do símbolo, incluindo três dígitos. Compra e Descarte exibem suas contagens dentro dos respectivos SVGs, sem alterar suas áreas de hover/foco nem as interações. A mão e as cartas não foram alteradas.

O teto mecânico de 5 Combo foi removido tanto de `JogadorCombate` quanto de `ResolucaoCartas`, assim como o denominador no HUD e na inspeção. Ganho, consumo por Finalização, reset por turno/combate e `5 + 3 × Combo` de Quebra-chassi permanecem. O crescimento de dano pode desequilibrar o protótipo e será avaliado depois da experimentação, sem rebalanceamento nesta revisão. `docs/GAME_DESIGN.md` e `docs/DECISOES.md` registram a regra experimental.

Capturas reais em GL Compatibility, inspecionadas visualmente: [repouso 1024×576](evidencias/hud_r2_recursos_2026-09-28/repouso_1024x576.png), [energia parcial 1024×576](evidencias/hud_r2_recursos_2026-09-28/parcial_1024x576.png), [energia zero 1024×576](evidencias/hud_r2_recursos_2026-09-28/zero_1024x576.png), [Combo 100 e pilhas 12 1024×576](evidencias/hud_r2_recursos_2026-09-28/altos_1024x576.png), [inspeção de Compra 1024×576](evidencias/hud_r2_recursos_2026-09-28/inspecao_1024x576.png), [repouso na janela grande](evidencias/hud_r2_recursos_2026-09-28/repouso_1920x1080.png), [contagens altas na janela grande](evidencias/hud_r2_recursos_2026-09-28/altos_1920x1080.png) e [inspeção na janela grande](evidencias/hud_r2_recursos_2026-09-28/inspecao_1920x1080.png). A janela grande solicitada como 1920×1080 produziu imagem útil de 1920×1061 neste ambiente. O preview injeta estados determinísticos para leitura; não demonstra acúmulo de 100 Combo em uma partida natural.

Verificações: testes novos falharam antes da mudança exatamente para o teto e o posicionamento dos números; depois, `test_jogador_combate.tscn`, `test_resolucao_cartas.tscn` e `test_hud_r2.tscn` passaram. A suíte completa terminou com `TESTES=41 FALHAS=0`; cobre novo turno, consumo de Combo, energia cheia/parcial/vazia, contagens de pilha zero e 12 e apresentação de Combo 100. Importação headless da Godot `4.7.2.stable.official.ed1daf0bf` com código 0; `git diff --check` sem erros. A leitura visual foi verificada nas capturas, separadamente dos testes automatizados.

## Correção da saída da inspeção em Panels — 28/09/2026

Corrigido o erro `Invalid call. Nonexistent function 'is_hovered' in base 'Panel'` em `main.gd`. A causa era `_ao_sair_inspecao_hud()` tratar todo `Control` como se fosse um botão com `is_hovered()`, embora a inspeção também seja ligada a `Panel` (Intenção, Energia e recursos). A saída agora verifica apenas `has_focus()` antes de esconder o painel; não houve mudança visual, de regra ou de dados.

Foi adicionada uma regressão a `test_hud_r2.tscn` que exercita a entrada e saída da inspeção em `IntencaoPainel`. O teste isolado e a suíte completa passaram: `TESTES=41 FALHAS=0`. A importação headless da Godot `4.7.2.stable.official.ed1daf0bf` terminou com código 0 e `git diff --check` passou.

## Legibilidade e agrupamento da intenção R2 — 28/09/2026

Corrigida a leitura do valor da intenção sem alterar a direção R2. A causa do texto escuro era a cor explícita antiga de `IntencaoValorVisualLabel` (`#1e2a2e`), não uma modulação herdada. O valor agora usa texto claro, sombra escura discreta e alinhamento à esquerda junto do símbolo. Símbolo e valor formam um grupo compacto centralizado acima do inimigo, sem placa, moldura ou título permanente.

`_atualizar_icone_intencao()` e `_atualizar_intencao_visual()` continuam fornecendo os SVGs e os valores reais. A regressão também alterna para a intenção de defesa: `barreira.svg` permanece correto e `+6` continua sendo exibido. Cartas, regras, inspeção por hover/foco e comportamento da mão não foram alterados.

Capturas GL Compatibility geradas e inspecionadas: [repouso 1024×576](evidencias/hud_r2_intencao_2026-09-28/repouso_1024x576.png), [inspeção 1024×576](evidencias/hud_r2_intencao_2026-09-28/inspecao_1024x576.png), [repouso na janela grande](evidencias/hud_r2_intencao_2026-09-28/repouso_1920x1080.png), [inspeção na janela grande](evidencias/hud_r2_intencao_2026-09-28/inspecao_1920x1080.png) e [intenção de defesa 1024×576](evidencias/hud_r2_intencao_2026-09-28/defesa_1024x576.png). A janela grande foi solicitada como 1920×1080 e resultou em área útil `1920×1061` neste ambiente.

Verificações executadas com Godot `4.7.2.stable.official.ed1daf0bf`: `TESTES=41 FALHAS=0`, `test_hud_r2.tscn` passou isoladamente com as verificações de ataque/defesa e agrupamento, importação headless do editor com código 0 e `git diff --check` sem saída.

## Rodada de fidelidade visual do HUD R2 — 28/09/2026

Usando as capturas R2 anteriores como evidência, removidas as estruturas que ainda apareciam na apresentação normal. O `HudInspecao` não é mais reexibido pela rotina geral de visibilidade: sem conteúdo ele permanece oculto e limpa o controle ativo. Isso elimina o painel branco vazio no canto superior esquerdo sem retirar a inspeção contextual.

Vida agora usa somente trilho e preenchimento `StyleBoxFlat` plano, proporcional ao estado lógico; as molduras, ícones e rótulos persistentes de Vida ficaram ocultos. Os painéis de pilhas, Energia, Relíquia, Compra, Descarte, Intenção e estados receberam grupos transparentes, preservando seus SVGs, áreas de foco e contadores. Os símbolos foram ampliados e espaçados para a leitura em 1024×576.

Barreira do jogador e demais estados zerados ficam ocultos; Combo continua persistente. O anúncio `SEU TURNO`/`TURNO N` é mostrado apenas na entrada do turno e desaparece após a transição. `AcaoLabel` deixou de participar da apresentação normal. A inspeção usa caixa mínima maior, candidatos adjacentes e margem de 12 px da viewport; dano continua sendo apenas feedback transitório do resultado lógico.

Capturas reais GL Compatibility, geradas pelo preview determinístico e inspecionadas: [repouso 1024×576](evidencias/hud_r2_fidelidade_2026-09-28/repouso_1024x576.png), [inspeção 1024×576](evidencias/hud_r2_fidelidade_2026-09-28/inspecao_1024x576.png) e [resposta ao dano 1024×576](evidencias/hud_r2_fidelidade_2026-09-28/dano_1024x576.png). O repouso não mostra o anúncio transitório; a inspeção fica acima e próxima da intenção; a captura de dano mostra `-4` sobre o inimigo e o preenchimento reduzido. A automação usa foco/método para a inspeção, não movimento físico do cursor.

Verificações executadas com Godot `4.7.2.stable.official.ed1daf0bf`: `TESTES=41 FALHAS=0` em `tests/test_*.tscn`, `test_hud_r2.tscn` e `test_composicao_combate.tscn` passaram isoladamente, importação headless do editor com código 0 e `git diff --check` sem saída. A suíte cobre regras e apresentação; as capturas foram avaliadas separadamente por inspeção visual.

## Integração visual do HUD de combate R2 — 28/09/2026

Integrada a revisão R2 a partir dos SVGs aprovados em `hud_r2_codex/icones/`. `main.tscn` agora usa os símbolos R2 de rota, intenção/ataque, barreira, combo, energia, compra, descarte e relíquia. Vida permanece como barra proporcional sem placa, ícone ou valor persistente; Energia, Combo, Compra e Descarte mostram apenas seus valores junto aos símbolos. O nome e a regra da intenção, Vida/Barreira do combatente, relíquia e significado das pilhas ficam disponíveis no painel de inspeção por hover/foco.

Foi adicionado `hud_inspecao.gd` para dimensionar e posicionar o contexto dentro da viewport, evitando a mão, as barras e os alvos. Foi adicionado feedback transitório de dano em `DanoFeedbackLabel`; ele acompanha o resultado lógico já calculado e não altera Vida, Barreira, custo, energia, turnos ou resolução de múltiplos golpes. A seleção, foco, escala, ordem de desenho e dimensionamento da mão foram preservados.

Capturas reais GL Compatibility, geradas no preview do jogo e inspecionadas: [repouso 1024×576](evidencias/hud_r2_2026-09-28/repouso_1024x576.png), [inspeção 1024×576](evidencias/hud_r2_2026-09-28/inspecao_1024x576.png), [resposta ao dano 1024×576](evidencias/hud_r2_2026-09-28/dano_1024x576.png) e [repouso na janela grande](evidencias/hud_r2_2026-09-28/repouso_1920x1080.png). A janela foi solicitada como 1920×1080 e a área útil capturada foi `1920×1061`; esse valor não foi tratado como 1920×1080. O preview usa estado determinístico e foco/método para inspeção; não é evidência de movimento físico do cursor.

Verificações executadas com Godot `4.7.2.stable.official.ed1daf0bf`: `TESTES=41 FALHAS=0` em `tests/test_*.tscn`, teste isolado `test_hud_r2.tscn` após a integração, importação headless do editor com código 0 e `git diff --check` sem saída. A importação registrou apenas o aviso de encerramento `Scan thread aborted`, sem código de falha. Pequenos refinamentos artísticos de escala/padding dos símbolos e acabamento dos painéis permanecem para a próxima rodada.

## Acabamento visual dos painéis restantes do HUD de combate — 27/09/2026

Aplicada a identidade HQ aos painéis que ainda usavam módulos locais: intenção do inimigo, Vida, Barreira/estados, Combo, relíquia, Energia e pilhas de compra/descarte. `main.tscn` passou a reutilizar molduras `StyleBoxTexture` do kit por meio de `hud_energia.tres`, `hud_estado.tres` e `hud_vida_preenchimento.tres`; a moldura de Vida existente também foi reaproveitada. A intenção usa o painel claro do kit, texto escuro legível, nome separado do valor e altura suficiente para nomes longos e multiplicidade. Foi incluído o ícone real de relíquia em uma área própria, sem alterar os dados ou as regras.

O caminho da mão, seus tamanhos efetivos, foco, seleção, ordem de desenho, animações e o botão `Encerrar turno` foram preservados. Os dados continuam vindo do estado real: intenção e modificadores de `InimigoCombate`, Vida/Barreira/estados/Combo/Energia, relíquias e pilhas da run. A contagem da mão cheia foi preparada pelo baralho real no preview; a captura mostra `Mão 10/10`, não apenas um texto substituído.

Capturas reais GL Compatibility, após as animações: [pasta do HUD](evidencias/hud_combate_acabamento_2026-09-27/). Foram inspecionados o combate inicial em 1024×576 e na janela solicitada como 1920×1080, estados ativos com defesa em 1024×576 e na janela grande, foco de carta em 1024×576 e mão cheia com foco em 1024×576. Neste ambiente a janela grande resulta em área útil `1920×1061`; isso foi mantido explícito, sem redimensionar a imagem para simular 1080 px.

Verificações funcionais: `test_composicao_combate.tscn`, `test_layout_combate.tscn`, `test_apresentacao_combate.tscn`, `test_interacao_hud_combate.tscn` e `test_apresentacao_recompensas.tscn` passaram; as 41 cenas em `tests/*.tscn` passaram; a importação headless do editor terminou com código 0; `git diff --check` passou. A inspeção visual foi mantida separada dos testes headless. As capturas automatizadas usam o foco de teclado para a carta destacada; não são evidência de movimento físico do cursor.

Pendências preservadas: Vega e os inimigos continuam representações quadradas provisórias, sem sprites definitivos; chefe, novas mecânicas e balanceamento permanecem fora do escopo. Não foram alteradas regras de combate, custos, dano, intenções, seleção de alvo, recompensas, eventos, descanso ou progressão do mapa.

## Limpeza do workspace — 27/09/2026

O workspace foi reorganizado para manter na raiz somente os arquivos do jogo, os testes e a configuração/documentação necessária. Capturas e artefatos de validação foram movidos para `docs/evidencias/`, com `.gdignore` para não participarem da importação do jogo. Os previews determinísticos que não eram carregados pelo runtime nem pelos testes foram removidos. O auxiliar compartilhado `preview_fluxo.gd` foi movido para `tests/preview_fluxo.gd`, e os dois testes que o utilizam foram atualizados.

`node_modules`, os arquivos npm e o cache local `.godot` foram retirados da raiz por movimento reversível para a pasta de Downloads; não são dependências do jogo e podem ser regenerados. `ui_hq_v1`, cenas, scripts, dados, testes e documentação foram preservados. A suíte foi executada após a reorganização, com `TESTES=40 FALHAS=0`; `test_apresentacao_combate.tscn` também passou isoladamente. A importação da Godot 4.7.2 foi necessária para reconstruir temporariamente o cache de classes/importações antes da suíte; o cache foi retirado novamente ao final.

## Dimensionamento efetivo das cartas da mão de combate — 27/09/2026

Reproduzida a divergência na sequência real de resolução `1024x576 -> 1920x1080 -> 1024x576`. Antes da correção, `botao_carta.gd::configurar_escala()` atualizava apenas `custom_minimum_size`: a carta retornava a 1024 com `size=(225,360)` e mínimo `(120,192)`, enquanto uma carta criada diretamente em 1024 também conservava o tamanho efetivo da cena. A mão, que posiciona os filhos pelo `size`, calculava a geometria com esse valor stale.

Corrigido em `botao_carta.gd`: quando `permitir_reducao` identifica o caminho da mão de combate, `size` recebe explicitamente `custom_minimum_size`; recompensa e descanso continuam usando somente o dimensionamento aprovado pelos containers. `_atualizar_transformacao(false)` agora cancela o Tween vigente antes de aplicar a escala imediata, evitando que a animação antiga sobrescreva o resultado. A ordem de desenho não foi alterada: o foco continua elevando a carta pelo `z_index` existente.

`SelecaoLabel` não é mais exibido no combate: a seleção persistente continua sendo mostrada pela camada `Foco`, e o rótulo externo que ficava fora da raiz não aparece na mão. A identidade visual no descanso foi preservada.

Medições reais após a correção: carta inicial em 1024 `120x192`, em 1920 `225x360`, retorno a 1024 `120x192`, e carta criada diretamente em 1024 `120x192`. Durante o redimensionamento com foco, a carta permaneceu em `225x360` com escala `1.08`; a captura após a estabilização manteve a mesma geometria.

Capturas GL Compatibility em pasta nova: [mao_dimensionamento_2026-09-27](evidencias/mao_dimensionamento_2026-09-27/), incluindo início e retorno em 1024, 1920, entrada, foco durante redimensionamento e foco estabilizado. As imagens foram inspecionadas; a execução headless foi usada apenas para medidas/testes porque o renderer dummy não expõe textura de viewport.

Verificação executada: `tests/test_layout_combate.tscn` passou; a suíte completa terminou com `TESTES=40 FALHAS=0`; importação do editor headless terminou com código 0 e `git diff --check` passou. O warning `Scan thread aborted` ocorreu no encerramento da importação, sem código de falha.

## Investigação e correção das divergências da mão de combate — 27/09/2026

A reprodução foi feita com Godot 4.7.2 GL Compatibility no fluxo de `main.tscn` e no preview `preview_combate_estados.tscn`. A causa da borda inferior apertada era estrutural: `mao_combate.gd` posicionava a carta pelo tamanho lógico e pela margem fixa, mas não reservava a extensão dos cantos após rotação. Em 1024×576, a carta normal de seis cartas tinha limite transformado inferior com margem de aproximadamente 12,16 px; depois do cálculo estrutural, a margem passou para aproximadamente 14,64 px. O foco da mesma carta ficou com margem aproximada de 14,58 px. A mão de dez cartas não usa rotação e manteve sua sobreposição controlada.

A causa da Proteção ampliada em `combate_hud_estados_defesa_1024x576.png` era do preview, não do combate: `preview_combate_estados.gd` mantinha `button_pressed = true` da captura de carta selecionada antes de salvar os estados. O preview agora limpa seleção, foco, escala e camada de seleção antes das capturas de estados e aguarda a maior animação de entrada. A causa dos fragmentos aparentes foi separada: a ordem efetiva de desenho já colocava a carta focada em `z_index=20` e seus filhos entre 20 e 23, acima dos vizinhos em 0 a 3; os títulos laterais restantes pertencem às cartas sobrepostas atrás, não cobrem o conteúdo da carta focada.

Alterados `mao_combate.gd`, `botao_carta.gd`, `preview_combate_estados.gd` e `tests/test_layout_combate.gd`. O layout calcula a extensão inferior transformada usando a inclinação e o mesmo fator de foco de combate (`1.08`), sem reduzir as cartas nem criar offsets por resolução. O teste passou a verificar os cantos transformados na viewport, a ordem efetiva de desenho e a estabilidade após as animações.

Capturas reais regeneradas e inspecionadas: início em 1024×576, 1280×720 e 1920×1080; estados neutros em 1024×576 e 1920×1080; mão cheia e foco nas posições 0, 5 e 9 em 10 cartas, foco 0, foco 5 e foco 9; mão de seis cartas com foco 0, foco 3 e foco 5. As imagens foram capturadas após a estabilização das animações.

Verificação executada: `tests/test_layout_combate.tscn` passou; a suíte completa terminou com `TESTES=40 FALHAS=0`; a importação do editor headless terminou com código 0 e `git diff --check` passou. A inspeção visual confirma cartas inteiras, foco elevado sem cobrir Energia ou `Encerrar turno`, estados legíveis e ausência da seleção herdada na captura de defesa. A automação continua usando foco de teclado; movimento físico do cursor não foi usado como evidência.

## Ajuste final de geometria e leitura do HUD de combate - 27/09/2026

Reproduzidas no fluxo real as duas causas restantes: a mao de seis cartas usava passos completos mesmo quando a faixa disponivel terminava junto de `EncerrarTurno`; a mao de dez ja usava sobreposicao. O foco das cartas de combate escalava apenas 1,025 e a primeira carta encostava no painel de Energia. A faixa de estados reservava espaco para o titulo redundante `ESTADOS`, comprimindo icones e valores.

Corrigidos `mao_combate.gd`, `botao_carta.gd`, `main.tscn`, `main.gd`, `preview_combate_estados.gd` e `tests/test_layout_combate.gd`. A mao agora calcula um passo limitado pela largura util para qualquer quantidade, usa margem inferior que inclui a rotacao e termina antes do botao de turno. O foco/hover de combate usa escala 1,08, elevacao e pivot inferior; a selecao persistente continua separada. Recompensa e descanso preservam o fator anterior para nao alterar seus tooltips. Energia foi deslocada para uma faixa propria acima da mao. A faixa de estados ficou mais alta, sem o titulo redundante, com icones e valores alinhados; pilhas continuam separadas.

Capturas reais GL Compatibility geradas depois das animacoes: inicio 1024, inicio 1280, inicio 1920, mao cheia 10/10, foco primeira, foco central, foco ultima, estados 1024 e estados 1920. A inspeção confirma a mão curta contida, a mão cheia sobreposta dentro da faixa, foco ampliado sem invadir Energia/Encerrar turno e estados legíveis nas duas resoluções.

Verificação: o teste RED cobriu colisao da mao curta, faixa de estados comprimida, titulo redundante, foco 1,025 e foco sobre Energia. Depois, `test_layout_combate.tscn`, `test_composicao_combate.tscn`, `test_interacao_hud_combate.tscn` e `test_apresentacao_recompensas.tscn` passaram; a suíte completa terminou com `TESTES=40 FALHAS=0`, a importação headless do editor terminou com código 0 e `git diff --check` passou. As capturas automatizadas usam foco de teclado e aguardam a animação; não foram tratadas como prova de movimento físico do cursor.

## Acabamento e contencao do HUD de combate - 27/09/2026

Reproduzidos os problemas do HUD real e do preview. A causa de `BARALHO 12` escapar do painel era o `RunStatusLabel` com tres linhas em altura fixa. A causa da area de reliquia colidir com Barreira/Combo era a ausencia de um painel proprio. Em 1024, os estados do inimigo e as pilhas ocupavam faixas vizinhas sem separacao vertical; o painel vazio tambem exibia `SEM ESTADOS`. A mao cheia ainda era preparada diretamente no preview e, por isso, mostrava `Mao 6/10` apesar de conter dez cartas. O `HBoxContainer` expandia a faixa pela soma das larguras minimas e empurrava as ultimas cartas para fora da viewport. O foco de teclado nao entrava no mesmo destaque visual do hover em combate.

Corrigidos `main.tscn`, `main.gd`, `mao_combate.gd`, `botao_carta.gd`, `preview_combate_estados.gd` e as regressões de HUD. O status superior agora tem altura estrutural para tres linhas; `RelíquiaPainel` ocupa uma faixa separada; os estados ficam abaixo da Vida inimiga e sao ocultados quando vazios; compra/descarte ficam abaixo dessa faixa; Energia continua mostrando `atual/maxima`, inclusive `0/4`, com `SEM ENERGIA` como complemento. A mao passou a ser uma faixa `Control` com layout manual: ate seis cartas mantem a curva, e acima disso as cartas conservam tamanho visual e sobreposicao controlada dentro da viewport. Hover/foco traz a carta para frente sem ativar selecao; selecao de combate continua sendo o estado persistente.

Capturas reais GL Compatibility geradas e inspecionadas por `preview_combate_estados.tscn`: inicio 1024, inicio 1280, inicio 1920, mao cheia pelo baralho real, foco primeira carta, foco carta central, foco ultima carta, defesa e estados e energia zerada. A mao cheia mostra `10/10` e `Compra 2`; as capturas de foco mostram a carta ativa ampliada e legivel sem deslocar vizinhas nem invadir `Encerrar turno`.

Verificacao executada com Godot 4.7.2 GL Compatibility: RED inicial registrado para painel de reliquia, estados vazios, mao de dez cartas pequena e foco sem elevacao; depois, as 40 cenas em `tests/*.tscn` passaram, incluindo `test_composicao_combate.tscn` e `test_layout_combate.tscn` em viewport reduzido. A importacao headless do editor e `git diff --check` passaram. A interacao por sinais, clique e foco permanece coberta pelos testes existentes; uma sessao adicional com cursor fisico em cada resolucao continua sendo validacao manual separada da captura automatizada.

Pendencias preservadas: representacoes de Vega/inimigos continuam quadrados provisiorios; sprites definitivos, chefe e balanceamento seguem fora do escopo.

## HUD de combate com kit HQ — 27/09/2026

Aplicada a apresentação do combate a partir de `02_combate.png`, preservando regras, seleção de alvo, cartas, custos, dano, Combo, intenções, recompensas, eventos, descanso e progressão do mapa. `main.tscn` e `main.gd` reorganizam o HUD em jogador à esquerda, inimigo à direita, turno no topo, recursos acima da mão e `Encerrar turno` separado no canto inferior. Vida usa barras proporcionais; Barreira, Exposto e Enfraquecido usam ícones e valores reais. A intenção agora separa nome em Bangers e valor/multiplicidade em Barlow, ambos derivados de `InimigoCombate.texto_intencao()`; o rótulo legado permanece oculto para não duplicar a apresentação.

`botao_carta.gd` mantém a escala aprovada das recompensas e do descanso, mas aceita redução somente quando chamada pelo modo mão de combate. Para dez cartas, `mao_combate.gd` abandona o leque e a animação de entrada quando necessário, mantendo todas as cartas dentro da faixa e sem cobrir Energia ou `Encerrar turno`. A moldura-base e a camada ciano transparente de foco foram preservadas nos alvos e no botão de turno; nenhum fade foi reintroduzido no nó-raiz das cartas.

Capturas reais GL Compatibility geradas por `preview_combate_estados.tscn` e inspecionadas: início 1024, início 1280, início 1920, foco no alvo, carta selecionada, defesa e estados, sem Energia e mão com dez cartas. A captura inicial de 1024 mostra a mão completa e o botão de turno fora da área das cartas; a captura de 1920 mostra a defesa `+6` e os estados `6`, `2` e `1` com ícones.

Verificação executada com Godot 4.7.2 GL Compatibility: 40 cenas em `tests/*.tscn`, incluindo `test_composicao_combate.tscn`, `test_layout_combate.tscn`, `test_apresentacao_combate.tscn` e a interação do HUD, passaram em modo headless; a importação headless do editor terminou com código 0; `git diff --check` passou. As capturas reais foram inspecionadas separadamente da suíte headless.

Pendências preservadas: Vega e os inimigos continuam representações quadradas provisórias; sprites definitivos, chefe e novas mecânicas permanecem fora do escopo. As capturas automatizadas validam foco e sinais de interação; não substituem uma sessão manual com cursor físico em todas as resoluções.

## Acabamento visual do mapa e do pré-chefe — 27/09/2026

A apresentação dos nós foi unificada em `main.gd`: todos os estados usam a mesma moldura HQ de `botao_normal.tres`; hover, foco e pressão preservam essa base e ativam somente a camada `Interacao` transparente com destaque ciano. Os estados de progressão continuam diferenciados por modulação, ícone, marcador e conexões. A moldura arredondada anterior não é mais aplicada ao hover/foco dos nós.

Os rótulos de etapa foram retirados dos nós individuais e passaram para `MapaRotulosPontos`, uma camada única abaixo do grafo que exibe P1 a P7 uma vez por coluna. O painel de detalhes e as conexões permanecem separados dessa linha. `Reiniciar` recebeu a faixa HQ, fonte Bangers, altura mínima de 72 px, margens internas de 28/16 px e foco ciano transparente; a ação `Jogar novamente` e a tela provisória de pré-chefe permanecem as mesmas.

Capturas reais GL Compatibility inspecionadas: [normal 1024](evidencias/mapa_initial_1024x576.png), [hover 1024](evidencias/mapa_hover_1024x576.png), [foco 1024](evidencias/mapa_focus_1024x576.png), [bifurcação 1280](evidencias/mapa_branch_1280x720.png), [pré-chefe 1024](evidencias/mapa_preboss_1024x576.png) e [foco 1920](evidencias/mapa_focus_1920x1061.png). A captura solicitada como 1920×1080 resulta em área útil 1920×1061 neste ambiente. A prévia de hover emite o sinal real `mouse_entered` do botão sem usar `warp_mouse`; a interação física pelo cursor continua distinta dessa captura determinística.

Verificação executada com Godot 4.7.2 Compatibility: `test_apresentacao_mapa.tscn`, `test_navegacao_mapa.tscn` e `test_fluxo_mapa_principal.tscn` passaram em 1024×576; as 40 cenas de `tests/*.tscn`, a importação headless do editor e `git diff --check` terminaram com código 0. Progressão, conexões, encontros, recompensas e bloqueio de Lastro não foram alterados. A arte específica de Lastro continua pendente; a tela segue provisória.

## Apresentação visual do mapa ramificado — 27/09/2026

Aplicada a apresentação do mapa integrado como fluxo principal em `main.tscn`, `main.gd` e `mapa_conexoes.gd`, usando `11_mapa.png` como referência de composição. O cabeçalho agora usa a faixa HQ com `DOCAS`, `MAPA DAS DOCAS`, Vida e tamanho do baralho. O grafo mostra todos os nós reais do modelo, em sete colunas, com ramificações acima/abaixo, ícones de combate, evento, elite, descanso e chefe, linhas derivadas de `mapa_run.conexoes` e estados visuais de atual, disponível, concluído, futuro e reservado.

Os nomes longos ficam na área de detalhes ao receber foco ou hover; os ícones e marcadores permanecem dentro dos nós e não interceptam o mouse. A informação de variante foi removida da interface. O painel de detalhes foi estruturado com um único conteúdo interno e margem explícita para impedir que a tipografia Bangers toque a tinta superior da moldura. A progressão, os encontros, recompensas, descansos, bloqueios e pré-chefe não foram alterados.

Verificação executada com Godot 4.7.2 Compatibility: `test_apresentacao_mapa.tscn`, `test_navegacao_mapa.tscn` e `test_fluxo_mapa_principal.tscn` passaram após a correção do painel. As 40 cenas de `tests/*.tscn`, a importação headless do editor e `git diff --check` terminaram com código 0. O teste visual confirma também as duas variantes, a presença das conexões reais, a árvore única do painel de detalhes e os filtros de mouse dos ícones. A cena legada `test_apresentacao_recompensas.tscn` ainda emite aviso de recursos em uso no teardown, apesar de concluir suas asserções e retornar código 0; isso não é causado pelo mapa.

Capturas reais geradas pelo fluxo de preview com viewport 1152×648: [mapa inicial 1024](evidencias/mapa_initial_1024x576.png), [bifurcação 1280](evidencias/mapa_branch_1280x720.png), [retorno após descanso 1024](evidencias/mapa_rest_1024x576.png), [foco 1920](evidencias/mapa_focus_1920x1061.png) e [pré-chefe 1280](evidencias/mapa_preboss_1280x720.png). A janela solicitada como 1920×1080 foi capturada com área útil 1920×1061 neste ambiente. A validação de mouse físico continua separada da navegação acionada por sinais e do foco de teclado; a automação anterior com `warp_mouse` não é tratada como evidência de hover físico.

Pendências preservadas: `Lastro` ainda não possui combate; a arte dos nós e do quadro de detalhes é composta com recursos existentes/provisórios do kit, sem ilustrações específicas adicionais.

## Mapa ramificado como fluxo principal da run — 27/09/2026

A run normal agora começa em `main.gd::_iniciar_nova_run()` com o mapa gerado uma única vez. O primeiro ponto disponível é o combate P1; depois de cada consequência concluída, o mapa retorna mostrando somente os destinos conectados ainda não resolvidos. O estado distingue nó atual, nó em andamento e nós concluídos, bloqueando seleção inválida, reentrada e sinais repetidos.

Integrado no fluxo jogável: combate comum com recompensa ou pulo, eventos diretos, eventos que iniciam combate especial, elite com relíquia e carta rara em sequência, descansos nas duas variantes e reencontro antes do ponto final. Vida, baralho, cópias aprimoradas e relíquias permanecem na mesma instância da run. Os contadores de combate mostram o ponto real percorrido, sem depender do tamanho do roteiro linear.

`roteiro_run.gd` e seus chamadores legados foram preservados para testes e previews isolados, mas não conduzem mais a run iniciada por `main.tscn`. `mapa_run.gd` continua definindo as variantes e conexões. O botão de retorno legado do mapa fica oculto na tela principal, pois não existe uma saída válida que abandone um nó obrigatório sem resolver suas consequências.

Ao alcançar `Lastro`, a tentativa mostra `RUN PRE-CHEFE` e não libera o chefe, não marca o ponto como concluído e não afirma vitória. Derrota encerra a tentativa e não libera destinos.

Verificação executada com Godot 4.7.2 Compatibility: 39 cenas em `tests/*.tscn`, incluindo `test_fluxo_mapa_principal.tscn`, passaram em modo headless; a importação do editor headless e `git diff --check` também passaram. Capturas reais do fluxo foram geradas pela cena principal em 1024×576, 1280×720 e 1920×1061: [mapa inicial 1024](evidencias/mapa_initial_1024x576.png), [bifurcação 1280](evidencias/mapa_branch_1280x720.png), [retorno após descanso 1024](evidencias/mapa_rest_1024x576.png) e [retorno após descanso 1920](evidencias/mapa_rest_1920x1061.png). A janela de 1920×1080 produziu área útil de 1920×1061 no preview do Windows.

Pendências: o combate de `Lastro` ainda não foi implementado; a arte específica do mapa continua sendo a composição provisória de nós, tipografia e estados do kit. A validação de mouse físico permanece separada das capturas determinísticas de fluxo.

## Acabamento visual do descanso e inspeção do mapa — 26/09/2026

Na comparação do aprimoramento, `botao_carta.gd` agora mantém a descrição normal em texto escuro e usa uma camada `RichTextLabel` somente para marcar a linha cujo valor mudou. Em `GOLPE`, apenas `9 de dano.` recebe o marcador; a carta não possui ganho de Combo declarado. O marcador usa fundo discreto e texto escuro sobre branco, sem ciano claro.

`descanso_overlay.gd` dimensiona a lista de cartas para ocupar a área disponível e centraliza o grupo quando o conteúdo cabe. Quando o mínimo combinado excede a área, o container mantém largura de conteúdo e a rolagem horizontal. A seleção continua preservando identificação de cópias e foco. `descanso_overlay.tscn` separa a instrução da faixa do cabeçalho e aumentou a área mínima das descrições de `RECUPERAR` e `APRIMORAR` para 72 px, sem reduzir fontes.

Capturas GL Compatibility inspecionadas: [início 1024](evidencias/descanso_inicio_1024x576.png), [seleção 1024](evidencias/descanso_selecao_1024x576.png), [comparação 1024](evidencias/descanso_comparacao_1024x576.png), [início 1280](evidencias/descanso_inicio_1280x720.png), [comparação 1280](evidencias/descanso_comparacao_1280x720.png) e [rolagem 1280](evidencias/descanso_rolagem_1280x720.png). A comparação confirma o destaque localizado; a rolagem confirma que o grupo maior excede a área sem perder as cópias.

Verificação executada com Godot 4.7.2 Compatibility: 38 cenas de `tests/*.tscn`, `test_apresentacao_descanso.tscn` em 1024×576 e 1280×720, importação headless do editor e `git diff --check` terminaram com código 0.

Inspeção da integração do mapa, sem alteração de progressão: `main.gd::_ready()` inicia `roteiro_run` e chama `_iniciar_etapa_atual()`, que consome apenas `RoteiroRun.ETAPAS_PRE_CHEFE` (`combate_comum`, `evento`, `elite`) e inicia a primeira luta. Após recompensas/eventos, `_avancar_roteiro()` chama `roteiro_run.avancar()`; quando o roteiro termina, `_mostrar_pre_chefe()` exibe `MapaAbrir`. O mapa só é criado em `_abrir_mapa()`, que chama `mapa_run.gerar()` e fixa o nó inicial.

Os nós de descanso já existem em `mapa_run.gd`: `descanso_estrutura` na variante 0, ponto 5, e `descanso_inicial` na variante 1, ponto 2. Eles só são alcançados depois de `RUN PRE-CHEFE` → `Abrir mapa` → seleção de destinos conectados em `_ao_selecionar_no_mapa()`, que chama `_mostrar_descanso()`. O fluxo do descanso retorna ao mesmo mapa e não é concedido novamente.

Para usar o mapa ramificado desde o início, seria necessário substituir a inicialização linear em `_ready()` por uma inicialização única do mapa, fazer o primeiro destino partir do nó P1 e impedir que `_avancar_roteiro()` volte a consumir `roteiro_run`. Também seria necessário revisar a numeração de combates, a entrada das recompensas em `_resolver_vitoria()`, o retorno de eventos/descanso e a conclusão no nó `chefe`, preservando `mapa_no_atual`, os flags de espera e as guardas contra resolução duplicada. Essa integração não foi feita nesta entrega.

## Acabamento do descanso e resultado de aprimoramento — 26/09/2026

Corrigidos somente os três pontos visuais solicitados em `descanso_overlay.tscn`, `descanso_overlay.gd` e `main.gd`. O título `RESPIRO` agora é filho da própria `FaixaTitulo` (`PanelContainer`), usando a área interna real da moldura e alinhamento vertical centralizado para os glifos Bangers. A seleção de carta não reutiliza mais o `Subtitulo` global, evitando a duplicação de instruções abaixo do cabeçalho.

O resultado de aprimoramento agora deriva o nome e a mudança dos dados antes/depois: por exemplo, `GOLPE APRIMORADO` e `Dano: 6 → 9`. O estado de contagem de baralho fica oculto quando não há resumo a mostrar. A descrição é genérica para efeitos numéricos diferentes de dano, preservando a regra atual de aprimoramento sem assumir que toda carta altera dano.

Capturas reais GL Compatibility foram regeneradas e inspecionadas em 1024×576 e 1280×720: [início 1024](evidencias/descanso_inicio_1024x576.png), [seleção 1024](evidencias/descanso_selecao_1024x576.png), [comparação 1024](evidencias/descanso_comparacao_1024x576.png), [resultado 1024](evidencias/descanso_resultado_aprimorar_1024x576.png), [início 1280](evidencias/descanso_inicio_1280x720.png) e [resultado 1280](evidencias/descanso_resultado_aprimorar_1280x720.png). A comparação 1280 também foi gerada em `artifacts/descanso_comparacao_1280x720.png`.

Verificação executada com Godot 4.7.2 Compatibility: 38 cenas em `tests/*.tscn`, `test_apresentacao_descanso.tscn` em 1024×576 e 1280×720, além de `git diff --check`, terminaram com código 0. As regressões novas conferem a árvore do título, a ausência do subtítulo duplicado e o resultado dinâmico do aprimoramento, incluindo confirmação única e preservação da cópia escolhida.

Limitação de fluxo confirmada: o descanso está implementado e jogável ao selecionar um nó `descanso` no mapa. A rota linear atual só exibe `Abrir mapa` em `RUN PRE-CHEFE`; portanto o descanso não é oferecido como etapa adicional dentro da sequência linear de combates/eventos. Essa integração mudaria a progressão e não foi alterada nesta rodada, que ficou restrita ao acabamento pedido.

## Implementacao de descanso e aprimoramento — 26/09/2026

Implementado o descanso jogavel a partir dos nos `descanso` do mapa. `descanso_run.gd` concentra a cura de +8 limitada a Vida maxima, a elegibilidade de copias ainda nao aprimoradas e a transformacao provisoria de +3 no primeiro efeito numerico principal. O token interno `id#aprimorado` preserva a copia escolhida no `baralho_run`; `main.gd` resolve seus dados efetivos na mao, na consulta do baralho e ao jogar a carta.

Criados `descanso_overlay.tscn/.gd` e `preview_descanso.gd`, com os estados iniciais, selecao, comparacao antes/depois, resultado e retorno ao mapa. A selecao reutiliza `carta.tscn` em modo de descanso, mostra a ocorrencia de copias iguais, preserva tooltip/foco sem `SELECIONADA` de combate e nao muta o baralho antes de `CONFIRMAR`. A cura e a melhoria sao protegidas contra clique repetido; Vida cheia e ausencia de cartas elegiveis ficam indisponiveis.

Verificacao executada com Godot 4.7.2 Compatibility: `tests/test_descanso_run.tscn`, `tests/test_persistencia_aprimoramento.tscn`, `tests/test_ciclo_descanso.tscn` e `tests/test_apresentacao_descanso.tscn` passaram. A apresentacao passou em 1024x576, 1280x720 e 1920x1080; as 38 cenas de `tests/*.tscn`, a importacao do editor headless e `git diff --check` terminaram com codigo 0. O fluxo real foi capturado e inspecionado em [inicio 1024x576](evidencias/descanso_inicio_1024x576.png), [selecao 1280x720](evidencias/descanso_selecao_1280x720.png), [comparacao 1920](evidencias/descanso_comparacao_1920x1061.png) e [resultado 1280x720](evidencias/descanso_resultado_1280x720.png); existem capturas equivalentes nas quatro etapas para as tres resolucoes.

A referencia `06_descanso.png` e `13_aprimoramento.png` foi usada para hierarquia, dois paineis, selecao e comparacao. Como o kit nao fornece ilustracoes especificas de banco/descanso, os paineis usam os simbolos existentes de Vida e Forca como substitutos consistentes; a arte dedicada do descanso continua pendente. A captura rotulada como 1920x1080 possui area util 1920x1061 no Windows por causa da janela do preview; essa diferenca de decoracao foi registrada, sem alterar a resolucao do jogo.

## Acabamento da experiencia de descanso — 26/09/2026

Aplicado o acabamento visual no `descanso_overlay.tscn/.gd`: a faixa HQ e os icones reais de Vida/baralho permanecem dinamicos; os paineis de RECUPERAR e APRIMORAR ganharam simbolos maiores, informacao essencial em area clara e contraste legivel. A selecao preserva copias iguais fora da moldura da carta, usa rolagem horizontal para baralhos maiores e continua sem o estado `SELECIONADA` do combate. Tooltips continuam reservados a palavras-chave reais, sem repetir `COPIA`.

A comparacao agora identifica `ATUAL` e `MELHORADA`, usa a seta grafica do kit e destaca o efeito alterado na propria carta. O resultado foi reduzido a simbolo, titulo, efeito e estado resumido; `Escolha uma acao` desaparece depois da resolucao. Os botoes `VOLTAR`, `CONFIRMAR` e `CONTINUAR` usam a moldura normal tambem no foco, com `Interacao` ciano transparente separado; isso removeu a caixa escura maior sem alterar foco, clique ou bloqueio contra confirmacao duplicada.

`botao_carta.gd` separa o modo de descanso do modo de selecao de combate; `main.gd` passa tooltip derivado do catalogo e dados reais da cura/vida/baralho; `preview_descanso.gd` e as cenas `preview_descanso_resultado_aprimorar.tscn` e `preview_descanso_rolagem.tscn` cobrem os dois resultados, duplicatas e rolagem. Testes de apresentacao verificam a arvore, a seta, os overlays de foco, a moldura preservada e o resultado; o ciclo verifica cura unica, copia sem mutacao previa, retorno e confirmacao unica.

Verificacao executada com Godot 4.7.2 Compatibility: 38 cenas de `tests/*.tscn` passaram em 1280x720; `test_descanso_run`, `test_persistencia_aprimoramento`, `test_ciclo_descanso` e `test_apresentacao_descanso` passaram novamente, incluindo as novas assercoes. A importacao do editor headless e `git diff --check` terminaram com codigo 0. Capturas reais GL Compatibility foram geradas e inspecionadas em 1024x576, 1280x720 e 1920x1061: inicio, selecao, comparacao, resultado de cura, resultado de melhoria e rolagem estao em `artifacts/descanso_*.png`. As capturas maiores registram 1920x1061 porque a area util da janela Windows nao e 1920x1080.

Pendencias explicitas: os simbolos atuais de Vida e Forca sao substitutos consistentes, pois o kit nao fornece arte propria de banco/descanso; a arte dedicada permanece pendente. O hover fisico do mouse nao foi usado como evidencia automatizada nesta rodada; o foco de teclado, a camada transparente, a estabilidade geometrica e os cliques do fluxo foram verificados pelo renderer/testes, enquanto a limitacao anterior de `warp_mouse` permanece registrada.

## Validação manual relatada da opção de evento — 26/09/2026

O usuário confirmou que a opção de evento está funcional: hover, clique, navegação e transições foram validados manualmente no fluxo jogável. Essa confirmação é um relato manual do usuário, não uma execução automatizada adicional feita nesta sessão.

As verificações automatizadas permanecem as registradas abaixo: layout e regressões passaram conforme os testes relatados. A limitação do preview automatizado também permanece explícita: `warp_mouse` não ativa `is_hovered()` de forma determinística, portanto não é usado como evidência de hover físico.

## Ajuste final do espaçamento vertical da opção de evento — 26/09/2026

Após comparar as capturas, o conjunto com título e detalhe recebeu altura mínima de 100 px. A área interna agora usa 19 px de margem superior/inferior; o título Bangers reserva 34 px para acentos, o detalhe 22 px e o espaçamento entre linhas é 4 px. O mínimo combinado do `VBoxContainer` passou a 60 px. A opção sem detalhe continua no mesmo `VBoxContainer` centralizado.

`EventoOpcoes` usa `anchor_top=0.515`, `anchor_bottom=0.995` e separação de 5 px; o espaço resultante acomoda três opções de 100 px sem reduzir a fonte ou cortar glifos. A moldura-base, a camada ciano, a área clicável, a tela de resultado e a Brecha não foram alteradas.

Capturas reais GL Compatibility inspecionadas: [normal 1024×576](evidencias/evento_valvula_normal_1024x576.png), [foco 1024×576](evidencias/evento_valvula_foco_1024x576.png), [normal 1920×1080](evidencias/evento_valvula_normal_1920x1080.png) e [foco 1920×1080](evidencias/evento_valvula_foco_1920x1080.png). A inspeção confirmou espaço visível entre `DESLIGAR A VÁLVULA`, `Combate` e a tinta branca.

Verificação executada com Godot 4.7.2 Compatibility: a regressão completa de 34 cenas passou em 1280×720; `test_layout_evento_opcao.tscn` passou em 1024×576, 1280×720 e 1920×1080; importação do editor headless e `git diff --check` passaram. O hover físico continua com a limitação já registrada: o preview automatizado não ativa `is_hovered()` de forma determinística, portanto não foi declarado validado por captura.

## Ajuste de altura e área segura da opção de evento — 26/09/2026

Reproduzido o evento `valvula_vapor_contaminado`. As medidas reais em GL Compatibility mostraram que a opção de 88 px oferecia 52 px de área interna, enquanto o `VBoxContainer` de ação + detalhe exigia 50 px antes da folga visual da moldura. A opção passou para altura mínima de 92 px, com insets verticais de 20 px; `EventoOpcoes` passou a ocupar `0.52..0.98` para acomodar três opções sem invadir o painel narrativo.

`Interacao` deixou de cobrir o Button inteiro e usa offsets de 14 px em cada lado, alinhando o destaque ciano ao quadro visível da textura. O Button continua sendo a área clicável e a geometria não muda no foco. A ação isolada de `Contornar a tubulação` ficou centralizada no `VBoxContainer`; `Desligar a válvula` e `Combate` ficaram com espaço visual até as bordas.

Capturas reais limpas foram geradas para `valvula_vapor_contaminado` em normal e foco nas resoluções 1024×576, 1280×720 e 1920×1080, nos arquivos `artifacts/evento_valvula_{normal|foco}_{resolução}.png`. A inspeção visual de 1024×576 confirmou a melhora. O preview automatizado de hover ainda não registra `is_hovered()` no alvo após warp; essa validação específica continua pendente e não foi substituída por foco.

Verificação executada com Godot 4.7.2 Compatibility: `test_layout_evento_opcao.tscn`, `test_apresentacao_eventos.tscn` e `test_regressoes_ui_evento_brecha.tscn` passaram em 1024×576, 1280×720 e 1920×1080; 34 cenas passaram em 1280×720; importação do editor headless terminou com código 0; `git diff --check` passou. Brecha, resultado de evento e regras permaneceram verdes.

## Correção estrutural da opção de evento — 26/09/2026

Implementada a correção baseada no diagnóstico: `evento_opcao.tscn` agora mantém o `Button` como raiz e usa `Conteudo` (`MarginContainer`) → `Linha` (`HBoxContainer`) → `Textos` (`VBoxContainer`), com espaços próprios para `TipoIcone` e `Seta`. Os Labels deixaram de usar âncoras/offsets individuais; a área segura usa insets maiores que os antigos para respeitar a tinta real da moldura do atlas. A ação fica centralizada quando `Detalhe` está oculto; com duas linhas, ambas permanecem na mesma coluna.

`evento_opcao.gd` foi atualizado para os novos caminhos. A moldura-base continua a mesma em normal, hover, foco, pressed e hover_pressed; `Interacao` continua sendo somente a camada ciano transparente e não intercepta o mouse. `EventoOpcoes` recebeu apenas espaço vertical adicional para acomodar a altura mínima de 88 px nas três opções.

Foi acrescentada `tests/test_layout_evento_opcao.tscn`, que verifica a árvore interna, a contenção da área segura, título/detalhe/seta dentro dela e estabilidade de tamanho no foco. `tests/test_apresentacao_eventos.gd` e `tests/test_regressoes_ui_evento_brecha.gd` foram ajustados aos novos caminhos, preservando a regressão da Brecha.

`git diff --check` passou. A execução Godot 4.7.2, as capturas reais nas três resoluções e a inspeção visual ainda estão pendentes nesta máquina: o executável não foi encontrado em `C:\Users\Wallace\Downloads\Godot\_v4.7.2-stable\_win64.exe`. A correção não deve ser considerada visualmente concluída até essa execução.

## Coleta diagnóstica da opção de evento — 26/09/2026

O problema visual relatado continua pendente: em 1024×576, o título e o detalhe de `Confrontar a fiscalização` podem tocar a tinta da moldura, e `Combate` aparece junto da borda inferior. Foi feita somente uma coleta, sem nova alteração visual de produção. O relatório [DIAGNOSTICO_EVENTO_OPCAO_2026-09-26.md](DIAGNOSTICO_EVENTO_OPCAO_2026-09-26.md) registra a cena e o script completos, a cadeia StyleBox/AtlasTexture, a camada `Interacao`, o código externo de layout, retângulos globais e a lacuna dos testes.

As capturas diagnósticas mostram que normal, hover, foco, pressed e hover_pressed usam a mesma moldura-base; o foco acrescenta apenas a camada ciano. A causa provável é a diferença entre a tinta visível da região do atlas e os `Label`s filhos diretos, que não recebem automaticamente as margens de conteúdo do `StyleBoxTexture`. O teste geométrico atual verifica apenas contenção no retângulo lógico do botão, não colisão com os pixels da moldura. A captura de hover da mesma opção não foi considerada evidência: o warp do preview não ativou o alvo de forma determinística, e isso está registrado sem fabricar uma captura.

## Correção da moldura e geometria das opções de evento — 26/09/2026

Investigada a divergência entre `evento_opcao.tscn` nos estados normal e focado. O controle e os Labels tinham a mesma geometria, mas `normal` usava `painel_escuro.tres` como `StyleBoxTexture`, com margens de conteúdo `24/16/24/16`, enquanto `hover` e `focus` substituíam essa moldura por `opcao_evento_interacao.tres` como caixa inteira. Essa caixa começava no retângulo externo do controle e não preservava a tinta interna da moldura HQ; por isso o texto parecia caber no foco, mas invadia a área útil da moldura normal.

Corrigido sem deslocar somente o foco: `evento_opcao.tscn` mantém `painel_escuro.tres` em normal, hover, focus, pressed e hover_pressed. `opcao_evento_interacao.tres` agora é uma camada transparente, filha `Interacao`, com apenas borda ciano e `mouse_filter` decorativo; `evento_opcao.gd` alterna sua visibilidade para hover/foco. A área e a posição dos Labels permanecem iguais em todos os estados. Em 1024×576, o controle medido ficou em aproximadamente `506.9×79.8`, com `Acao` em `27.1` px, `Detalhe` em `25.5` px e a camada ciano usando exatamente o retângulo do controle. O título longo e `Combate` ficaram dentro da margem útil.

Criado o preview `preview_evento_hover.tscn`; as capturas reais GL Compatibility do mesmo evento e da mesma opção foram inspecionadas: [normal 1024](evidencias/evento_opcao_normal_1024x576.png), [hover 1024](evidencias/evento_opcao_hover_1024x576.png) e [foco de teclado 1024](evidencias/evento_opcao_foco_1024x576.png). A comparação com `ui_hq_v1/referencias/telas/05_evento.png` preserva a moldura HQ, a coluna de texto e a seta; o foco não cria uma caixa externa.

`tests/test_apresentacao_eventos.tscn` e `tests/test_regressoes_ui_evento_brecha.tscn` passaram em 1024×576, 1280×720 e 1920×1080. A suíte completa de 33 cenas passou em 1280×720, a importação do editor headless terminou com código 0 e `git diff --check` passou. A correção da Brecha foi preservada.

## Regressões de Brecha e opções de evento — 26/09/2026

Investigação reproduzida pelo fluxo de jogo: após escolher Brecha na recompensa, avançar pelo evento `valvula_vapor_contaminado` e iniciar o combate, a carta era criada com o identificador `brecha`, custo 1 e `disabled = false`, mas aparecia escurecida durante a entrada. A causa foi `botao_carta.gd::animar_entrada()`, que aplicava `modulate.a = 0` no próprio botão e fazia um tween de 0,18 s; a captura ocorria enquanto a animação ainda estava entre 0,45 e 0,73 de alpha. `self_modulate`, material, arte, catálogo e recurso compartilhado não eram a origem. A entrada agora preserva `modulate = Color.WHITE` e anima somente a escala, mantendo indisponibilidade legítima sob controle de `disabled` e do tema.

Também foi comparada uma Brecha adquirida pelo fluxo com uma Brecha criada diretamente por `_criar_carta_na_mao()`: ambas usam o mesmo identificador, custo e apresentação. O teste reproduzido confirma a compra com 4 de Energia, o uso contra a Torreta de Contenção, dano de 4 e consumo para 3 de Energia.

Nas opções de evento, a origem da moldura sobreposta era local: `evento_opcao.tscn` substituía o `focus` transparente do tema e o estado `hover` por `ui_hq_v1/estilos/botao_foco.tres`, uma textura HQ completa. O componente agora usa `ui_hq_v1/estilos/opcao_evento_interacao.tres`, um único `StyleBoxFlat` de corpo escuro e borda ciano para hover/foco; `pressed` continua usando o estado próprio de pressão. Não há texto nativo duplicado no Button nem controles legados visíveis. Os Labels `Acao` e `Detalhe` usam áreas proporcionais internas, mantendo título, informação secundária, ícone e seta dentro da moldura quando a VBox comprime em 1024×576.

Criado `tests/test_regressoes_ui_evento_brecha.tscn`, que verifica estilos normal/hover/foco, margens das duas linhas, identidade da Brecha, disponibilidade, modulate, comparação com criação direta e resolução com gasto de Energia. `preview_fluxo.gd` recebeu os modos `brecha_mao` e `brecha_jogada`; as capturas reais GL Compatibility foram geradas e inspecionadas em [Brecha na mão](evidencias/brecha_mao_1280x720.png), [Brecha após uso](evidencias/brecha_jogada_1280x720.png), [evento normal 1024](evidencias/evento_normal_1024x576_final.png) e [evento foco 1024](evidencias/evento_foco_1024x576_final.png). A captura da mão mostra `4/4` de Energia e a carta clara; a captura após o uso mostra `3/4`, dano aplicado e descarte.

Verificação executada com Godot 4.7.2: as regressões de eventos, Brecha e recompensa comum passaram em 1024×576, 1280×720 e 1920×1080; a suíte completa de 33 cenas passou em 1280×720; importação do editor headless terminou com código 0; `git diff --check` passou. A arte do evento continua sendo o símbolo genérico `evento.tres`; não há arte específica por evento.

## Acabamento visual da tela de eventos — 26/09/2026

Comparada diretamente com `ui_hq_v1/referencias/telas/05_evento.png`, a tela de eventos recebeu uma rodada restrita de apresentação. O símbolo provisório agora usa `STRETCH_KEEP_ASPECT_CENTERED` em uma área interna menor do quadro, preservando proporção e margens nas resoluções testadas; a faixa do nome permanece independente. O cabeçalho recebeu uma faixa HQ clara para `ENCONTRO`, mantendo Vida e baralho derivados do estado real.

`evento_opcao.tscn` deixou de usar `StyleBoxFlat` local fino e passou a reutilizar os estilos HQ de painel escuro, foco, pressão e tipografia do kit. A ação e o detalhe ficam em uma coluna alinhada à esquerda; a seta é um elemento separado com `mouse_filter` decorativo, e o ícone de combate aparece somente nas opções que iniciam combate especial. A altura mínima e os offsets internos foram ajustados para manter textos e molduras dentro do componente, sem deslocar opções vizinhas.

`main.gd` agora resume uma opção de combate como `Combate` e remove frases genéricas de continuação; custos de Vida continuam visíveis quando existem. Regras, textos narrativos do catálogo, handlers, proteção contra clique duplicado, resultado e transições não foram alterados. `Continuar` permanece abaixo do resultado, dentro do overlay e com margens internas do kit.

Capturas reais GL Compatibility do mesmo evento `fiscalizacao_corporativa`, geradas pelo fluxo de preview que chama `_mostrar_evento()` e `_ao_escolher_evento()`: [inicial 1024](evidencias/evento_inicial_1024x576.png), [foco 1024](evidencias/evento_foco_1024x576.png), [resultado 1024](evidencias/evento_resultado_1024x576.png), [inicial 1280](evidencias/evento_inicial_1280x720.png), [foco 1280](evidencias/evento_foco_1280x720.png), [resultado 1280](evidencias/evento_resultado_1280x720.png), [inicial 1920](evidencias/evento_inicial_1920x1080.png), [foco 1920](evidencias/evento_foco_1920x1080.png) e [resultado 1920](evidencias/evento_resultado_1920x1080.png). A captura de 1920×1080 foi feita com tela cheia; a escala interna do projeto permanece proporcional.

Verificação executada com Godot 4.7.2 GL Compatibility: `tests/test_apresentacao_eventos.tscn` e `tests/test_ciclo_encontros.tscn` passaram em 1024×576, 1280×720 e 1920×1080; as 32 cenas de `tests/*.tscn` passaram em 1280×720; a importação do editor headless terminou com código 0; e `git diff --check` passou. A inspeção visual das capturas confirmou o símbolo contido, molduras HQ, textos auxiliares reduzidos e botão de continuação sem achatamento. Recompensas comum e elite permaneceram fora do escopo e verdes.

Pendente: o quadro ainda usa o símbolo genérico `evento.tres`; não existem ilustrações específicas dos cinco eventos no kit.

## Apresentação visual dos eventos — 26/09/2026

A tela de eventos foi reconstruída usando `ui_hq_v1/referencias/telas/05_evento.png` como referência de composição, sem copiar seus textos ou números. O fluxo atual de `DadosEventos`, `ResolucaoEventos` e os handlers de escolha/continuação foi preservado: opções continuam sendo determinadas pelo catálogo, custos existentes continuam aplicados, combate especial continua encaminhando para o encontro e o resultado só avança pelo botão `Continuar`.

`EventoOverlay` agora usa cabeçalho HQ com identidade `ENCONTRO`, Vida e tamanho real do baralho; quadro escuro à esquerda com ícone de evento e faixa do nome; painel narrativo claro à direita; e escolhas empilhadas com moldura HQ, títulos Bangers, resumo secundário em Barlow e foco ciano. O componente `evento_opcao.tscn` mantém o `Button` como raiz, deixa a opção inteira clicável e marca os rótulos como decoração que não intercepta o mouse. Opções ausentes são ocultadas sem deixar espaços visuais. O resultado reutiliza o painel narrativo e mantém `Continuar` separado.

O resultado não reapresenta a narrativa antiga por baixo da consequência. Escolhas diretas são desabilitadas e marcadas como resolvidas antes de mostrar o resultado; cliques tardios não reaplicam Vida nem avançam para `Continuar`. `_mostrar_evento()` também sincroniza `etapa_evento_atual` com o identificador exibido, mantendo chamadas de fluxo e previews determinísticos consistentes. Eventos ainda usam o símbolo genérico `evento.tres`; não há ilustrações específicas por evento no kit, pendência registrada para arte futura.

Capturas reais GL Compatibility do mesmo evento `fiscalizacao_corporativa`, em estado inicial, foco na segunda opção e resultado após escolher a primeira: [inicial 1024](evidencias/evento_inicial_1024x576.png), [foco 1024](evidencias/evento_foco_1024x576.png), [resultado 1024](evidencias/evento_resultado_1024x576.png), [inicial 1280](evidencias/evento_inicial_1280x720.png), [foco 1280](evidencias/evento_foco_1280x720.png), [resultado 1280](evidencias/evento_resultado_1280x720.png), [inicial 1920](evidencias/evento_inicial_1920x1080.png), [foco 1920](evidencias/evento_foco_1920x1080.png) e [resultado 1920](evidencias/evento_resultado_1920x1080.png). A resolução 1920×1080 foi capturada em tela cheia para manter o tamanho real do viewport.

Arquivos principais desta etapa: `main.tscn`, `main.gd`, `evento_opcao.tscn`, `evento_opcao.gd`, `preview_fluxo.gd`, `preview_evento_foco.tscn`, `preview_evento_resultado.tscn` e `tests/test_apresentacao_eventos.gd`. Verificação com Godot 4.7.2: apresentação e ciclo de encontros passaram em 1024×576, 1280×720 e 1920×1080; as 32 cenas de `tests/*.tscn`, a importação do editor headless e `git diff --check` terminaram com código 0. Recompensas comum e elite foram preservadas.

## Acabamento de composição da recompensa elite — 26/09/2026

Preservado o fluxo obrigatório `relíquia -> carta rara`, as quantidades, a consulta do baralho, o foco entre etapas e a aquisição existente. A moldura horizontal compartilhada agora fica oculta somente durante a recompensa elite; o fundo HQ permanece. Os grupos de duas relíquias e três cartas raras usam `alignment = 1` e compartilham o eixo central do título e de `Ver baralho`.

`recompensa_reliquia.tscn` passou a usar corpo escuro, moldura branca quadrada e detalhe magenta; `recompensa_reliquia.gd` mantém ciano apenas no foco/hover e não escala mais o painel, evitando alterar o espaço reservado às opções. A raridade das cartas raras foi movida para `RaridadePill`, um `PanelContainer` com fundo, moldura magenta e margens próprias na faixa entre arte e descrição. O custo, tipo, nome e efeitos reais continuam derivados do catálogo.

Criados os previews neutros `preview_recompensa_elite_neutro.tscn` e `preview_recompensa_elite_cartas_neutro.tscn`; eles somente liberam foco e afastam o cursor para produzir a captura sem destaque. Capturas reais GL Compatibility foram geradas e inspecionadas nas três resoluções, em estado neutro e com foco: [relíquias neutro 1024](evidencias/recompensa_elite_reliquias_neutro_1024x576.png), [relíquias foco 1024](evidencias/recompensa_elite_reliquias_foco_1024x576.png), [cartas neutro 1024](evidencias/recompensa_elite_cartas_neutro_1024x576.png), [cartas foco 1024](evidencias/recompensa_elite_cartas_foco_1024x576.png), [relíquias neutro 1280](evidencias/recompensa_elite_reliquias_neutro_1280x720.png), [relíquias foco 1280](evidencias/recompensa_elite_reliquias_foco_1280x720.png), [cartas neutro 1280](evidencias/recompensa_elite_cartas_neutro_1280x720.png), [cartas foco 1280](evidencias/recompensa_elite_cartas_foco_1280x720.png), [relíquias neutro 1920](evidencias/recompensa_elite_reliquias_neutro_1920x1080.png), [relíquias foco 1920](evidencias/recompensa_elite_reliquias_foco_1920x1080.png), [cartas neutro 1920](evidencias/recompensa_elite_cartas_neutro_1920x1080.png) e [cartas foco 1920](evidencias/recompensa_elite_cartas_foco_1920x1080.png). A captura de 1920×1080 foi feita em tela cheia para manter o viewport real nessa resolução.

Verificação executada com Godot 4.7.2: `test_apresentacao_recompensa_elite.tscn`, `test_recompensa_elite.tscn` e `test_ciclo_encontros.tscn` passaram em 1024×576, 1280×720 e 1920×1080; as 32 cenas de `tests/*.tscn`, a importação do editor headless e `git diff --check` terminaram com código 0. A inspeção visual confirmou ausência da moldura residual, centralização, estabilidade do espaço no foco e marcador `RARA` legível. O símbolo das relíquias continua sendo o ícone genérico provisório `reliquia.tres`.

## Acabamento visual e integracao da recompensa elite — 26/09/2026

A recompensa elite foi reconstruida usando os componentes corrigidos da recompensa comum, sem alterar a quantidade de opcoes, a ausencia de skip ou a sequencia obrigatoria reliquia -> carta rara. A tela agora mostra identidade magenta de elite, estados ciano de interacao e um indicador explicito `1/2` ou `2/2`.

As reliquias usam um componente proprio clicavel e acessivel por teclado, com painel HQ, icone generico, nome Bangers e efeito essencial em Barlow derivados de `DadosReliquias`. O icone especifico de cada reliquia ainda nao existe no kit; a entrega usa `reliquia.tres` como simbolo provisório e essa pendencia permanece registrada.

As cartas raras agora sao instancias de `carta.tscn`, com custo, tipo, nome, arte, raridade e efeitos reais do catalogo. O tooltip unico continua sendo o `PanelContainer` corrigido. A consulta do baralho funciona durante as duas etapas elite, bloqueia a etapa atual e restaura o foco anterior ao fechar. A escolha da reliquia transfere o foco para a primeira carta rara; cliques tardios nao atravessam a troca de etapa.

Criados `recompensa_reliquia.gd`, `recompensa_reliquia.tscn`, `tests/test_apresentacao_recompensa_elite.gd`, `tests/test_apresentacao_recompensa_elite.tscn` e `preview_recompensa_elite_cartas.tscn`. Capturas reais GL Compatibility foram geradas e inspecionadas em 1024x576, 1280x720 e 1920x1080: [reliquias 1024](evidencias/recompensa_elite_reliquias_1024x576.png), [reliquias 1280](evidencias/recompensa_elite_reliquias_1280x720.png), [cartas raras 1024](evidencias/recompensa_elite_cartas_1024x576.png), [cartas raras 1280](evidencias/recompensa_elite_cartas_1280x720.png) e [cartas raras 1920](evidencias/recompensa_elite_cartas_1920x1080.png). As capturas incluem foco/hover ativo e tooltip complementar; a validação de duas palavras-chave permanece coberta pelo Pulso na recompensa comum.

Verificacao executada com Godot 4.7.2: 32 cenas de teste passaram nas tres resolucoes, incluindo o ciclo intercalado, aquisicao dupla, foco entre etapas, consulta do baralho e clique duplo; a importacao do editor headless terminou com codigo 0 e `git diff --check` passou. A recompensa comum foi preservada.

## Tooltip de recompensa com dimensionamento pelo layout — 26/09/2026

Substituido o dimensionamento manual do tooltip de recompensa por `PanelContainer` com `Label`, uma unica definicao de margens no `StyleBox` e largura definida antes da quebra de texto. A altura agora vem do layout final; a ponta decorativa foi separada do corpo em `Polygon2D` e `Line2D`, sem participar da area de conteudo.

O posicionamento tenta larguras decrescentes e candidatos acima, abaixo e nas laterais, validando viewport e areas protegidas antes de aplicar a posicao. Quando a carta muda de escala durante o hover, `_process()` reposiciona o balão. O preview sincroniza `oferta_recompensa.opcoes` com as cartas deterministicas, preservando a recompensa concedida pelo clique.

Brecha e Pulso Debilitante foram conferidos nas tres posicoes da oferta em mouse e teclado, em 1024x576 e 1280x720. As capturas reais `artifacts/recompensa_brecha_panelcontainer_1024x576.png`, `artifacts/recompensa_brecha_panelcontainer_1280x720.png`, `artifacts/recompensa_pulso_panelcontainer_1024x576.png` e `artifacts/recompensa_pulso_panelcontainer_1280x720.png` foram inspecionadas; texto, margens e ponta permanecem dentro do painel e da viewport.

Verificacao: `tests/test_apresentacao_recompensas.tscn` passou, as 31 cenas em `tests/*.tscn` passaram, a importacao do editor headless terminou com codigo 0 e `git diff --check` passou. Nenhuma regra de combate, selecao ou recompensa foi alterada.

## Correção do dimensionamento e posicionamento dos tooltips de recompensa — 26/09/2026

Investigada a divergência observada nas capturas de Brecha e Pulso Debilitante. O balão compartilhado agora mede a altura a partir do texto já quebrado, da quantidade de linhas, da altura tipográfica e das margens; o texto fica no topo e acima da textura de fundo. A busca de posição ocorre somente depois do dimensionamento final, protege título, custo e descrição das cartas, título da recompensa e ações inferiores, e usa posições laterais ou sobre a arte quando o espaço acima não comporta todas as linhas. O comportamento de seleção do combate e a escolha da recompensa não foram alterados.

Criados previews determinísticos `preview_recompensa_brecha.tscn` e `preview_recompensa_pulso.tscn`, ambos passando por `_resolver_vitoria()` e usando os dados reais do catálogo. Capturas reais foram geradas e inspecionadas em 1280×720 e 1024×576: Brecha mostra sua explicação completa; Pulso Debilitante mostra as duas palavras-chave completas, sem cobrir título, custo ou descrição essencial das cartas e dentro da viewport.

Alterados `botao_carta.gd`, `preview_fluxo.gd` e `tests/test_apresentacao_recompensas.gd`. A regressão também confere que duas palavras-chave aumentam a altura do tooltip, que o texto permanece dentro do fundo e que o balão fica dentro da viewport. A suíte de 31 cenas em Godot 4.7.2, a importação do editor headless e `git diff --check` terminaram com código 0. Capturas verificadas: `artifacts/recompensa_brecha_tooltip_1280x720.png`, `artifacts/recompensa_brecha_tooltip_1024x576.png`, `artifacts/recompensa_pulso_tooltip_1280x720.png` e `artifacts/recompensa_pulso_tooltip_1024x576.png`.

## Correção do hover das cartas de recompensa — 25/09/2026

Reproduzido pelo fluxo real de vitória comum (`_resolver_vitoria()`): as cartas compartilhavam `toggle_mode` e a apresentação de seleção do combate, então uma interação podia deixar `button_pressed`, `Foco` e `SELECIONADA` visíveis na recompensa. O modo recompensa agora neutraliza a seleção visual, mantendo o `Button` clicável e preservando o sinal que escolhe a carta. Hover eleva somente a carta sob o mouse; foco de teclado eleva a carta focada quando não há hover. Ao trocar ou sair, escala, foco visual e tooltip são restaurados.

O componente mantém um único tooltip customizado ativo. O balão anterior fecha ao mover o ponteiro para outra carta; o tooltip da carta focada pode ser restaurado quando o mouse sai. O tamanho recebeu margem interna maior, quebra de linha e cálculo de posição que evita as cartas vizinhas e respeita o viewport. `tooltip_text` nativo permanece vazio, evitando duas explicações simultâneas.

Foram acrescentadas regressões para as três cartas: hover sem `SELECIONADA`, tooltip único, ausência de colisão com a vizinha, retorno ao estado normal, seleção visual do combate preservada fora do modo recompensa e clique de recompensa intacto. As prévias agora percorrem `_resolver_vitoria()` e incluem hover real por ponteiro, foco, pressão e saída do grupo. Capturas: [hover da carta](evidencias/hover_carta_real_1280x720.png), [foco de carta](evidencias/foco_carta_final_1280x720.png) e [após retirar o mouse](evidencias/saida_carta_real_1280x720.png).

Verificação executada com Godot 4.7.2 GL Compatibility: `git diff --check`, 31 cenas de teste e importação do editor terminaram com código 0. A captura real mostra a carta sob o cursor ampliada suavemente, sem `SELECIONADA`, e a captura após retirar o mouse retorna todas as cartas à apresentação normal. A tela de recompensa permanece a única tela alterada nesta correção.

## Correção dos estados de tooltip e Pular recompensa — 25/09/2026

Reproduzido pela cena principal e pelo caminho real `_resolver_vitoria()`: o tooltip customizado da carta podia permanecer visível quando outra carta recebia hover, permitindo dois balões simultâneos. `botao_carta.gd` agora mantém apenas um tooltip customizado ativo, fecha o anterior ao mover o ponteiro e restaura o tooltip da carta que conserva o foco quando o ponteiro sai. O `tooltip_text` nativo também é limpo no `_ready` e na atualização da carta, deixando uma única fonte de explicação.

A origem da moldura ciana desproporcional do `Pular recompensa` estava no tema: o estado `hover` usava a textura completa de foco, sobrepondo a moldura normal, enquanto `focus` acrescentava outra camada. O tema agora usa o estilo normal no hover e mantém o foco de teclado como uma marca `StyleBoxFlat` transparente, com borda e sombra reduzidas; `pressed` e `hover_pressed` continuam explícitos. O texto do botão permanece legível em foco e pressão, sem override local que substitua o tema corrigido.

O teste de apresentação recebeu apenas a regressão necessária: hover entre cartas deixa somente um tooltip, a carta vizinha não se move, `Pular` conserva o texto, hover não sobrepõe a moldura normal e foco continua transparente. As cenas de preview passaram a chamar `_resolver_vitoria()` e geraram capturas reais GL Compatibility de hover, foco e pressão do `Pular`, além da consulta do baralho em 1024×576: [hover](evidencias/hover_pular_real_1280x720.png), [foco](evidencias/foco_pular_real_1280x720.png), [pressão](evidencias/pressed_pular_real_1280x720.png) e [baralho](evidencias/baralho_real_1024x576.png).

Verificação executada com Godot 4.7.2: `git diff --check`, 31 cenas de teste e importação do editor terminaram com código 0. A inspeção visual real confirmou a navegação por foco, o estado destacado do `Pular`, o caminho de vitória comum e o modal preservado. Nenhuma outra tela foi redesenhada.

## Acabamento verificável da recompensa comum — 25/09/2026

A rodada de acabamento preservou as regras e corrigiu a composição final: as três cartas ficam em um `HBoxContainer` centralizado no eixo do título, com intervalos constantes; `Ver baralho` e `Pular recompensa` ocupam a mesma faixa inferior nas extremidades; e os botões receberam margens internas maiores. O script passou a instanciar as cartas no container compartilhado correto, alinhando a árvore da cena ao fluxo real.

O custo foi removido da descrição visível e permanece no selo. Os efeitos agora são derivados do catálogo e quebrados em linhas, incluindo Finalização, Exposto, Enfraquecido, Barreira e Combo. O tooltip mostra somente explicações complementares de palavras-chave. A consulta do baralho ganhou scrim escuro, bloqueia as ações da recompensa enquanto aberta, mantém `Fechar` dentro do modal e restaura o foco anterior ao fechar.

O posicionamento do tooltip foi corrigido em `botao_carta.gd` para permanecer dentro do viewport em resoluções menores sem cobrir o cabeçalho. A investigação do tema confirmou que o foco original era uma textura de botão completo sobreposta; o tema vigente usa contorno transparente com foco ciano e `hover_pressed` explícito. Hover e foco elevam a carta sem reposicionar as vizinhas.

Arquivos alterados nesta rodada: `main.gd`, `main.tscn`, `botao_carta.gd`, os testes de apresentação/ciclo/recompensa, `preview_fluxo.gd` e as cenas de pré-visualização. Capturas reais foram geradas com Godot 4.7.2 GL Compatibility em 1280×720, 1920×1080 e 1024×576; exemplos: [sem foco](evidencias/recompensa_sem_foco_1280x720.png), [foco](evidencias/recompensa_foco_1280x720.png) e [baralho na menor resolução](evidencias/recompensa_baralho_1024x576.png).

Verificação executada: `git diff --check`, 31 cenas de `tests/*.tscn` e importação do editor headless terminaram com código 0. O teste focado confirma custo não duplicado, tooltip complementar, foco transparente, hover sem reposicionamento, scrim, bloqueio/restauração da oferta e botão de fechamento dentro do modal. As demais telas continuam fora desta rodada.

## Reconstrucao verificavel da recompensa comum — 26/09/2026

Lido `docs/CORRECAO_UI_EXPERIENCIA.md` e comparada a referencia `ui_hq_v1/referencias/telas/03_recompensa.png` com a captura real do fluxo. A recompensa comum deixou de exibir tres botoes textuais: no inicio da tela, as tres opcoes sao instancias do componente compartilhado de carta, recebem dados reais do catalogo, exibem custo e efeito na propria carta e usam um unico balao complementar no hover ou foco de teclado. O painel gigante anterior foi retirado da composicao da recompensa.

Investigado o tema original: `Button/styles/focus` usava `botao_foco.tres`, uma textura de botao inteiro sobreposta ao estado base. O foco agora usa contorno `StyleBoxFlat` transparente, e `hover_pressed` foi definido explicitamente. O componente de carta deixou de recortar o balao fora dos seus limites, manteve os textos acima do foco e recebeu arte para Habilidades que antes apareciam vazias, incluindo Pulso Debilitante.

Alterados `main.tscn`, `main.gd`, `carta.tscn`, `botao_carta.gd`, `ui_hq_v1/tema_base.tres`, `tests/test_apresentacao_recompensas.gd` e `preview_fluxo.gd`. A carta de recompensa usa escala maior que a carta da mao, com ajuste pelo viewport; a regra de adicionar, pular e avancar a run permaneceu a mesma.

Verificacao executada com Godot 4.7.2 GL Compatibility: `tests/test_apresentacao_recompensas.tscn` cobre cartas compartilhadas, custo/efeito, arte, foco transparente, foco de teclado, hover, tooltip unico, ausencia de desaparecimento e viewport reduzido em 1024x576. A suite completa de 31 cenas terminou com `FALHAS=0`; a importacao do editor terminou com codigo 0; `git diff --check` passou.

Capturas reais geradas e inspecionadas em 1280x720, 1920x1080 e 1024x576. A comparacao confirmou a hierarquia da referencia: titulo no alto, tres cartas protagonistas centralizadas, foco ciano, informacao basica na carta e acoes secundarias separadas. A recompensa agora tambem oferece `VER BARALHO`; a consulta mostra somente a composicao do baralho, fecha sem avancar a oferta e nao expoe a ordem oculta de compra. A captura de 1920x1080 confirmou tooltip legivel para texto maior. Esta entrega estabiliza a recompensa comum e os componentes compartilhados; o redesenho das demais telas continua pendente.

## Integracao jogavel das telas de recompensa e evento — 25/09/2026

O fluxo jogavel recebeu a aplicacao dos componentes do kit que ainda estavam somente importados: selecao de carta nao cobre mais nome, custo ou descricao; a recompensa comum usa painel, botoes de carta e balao de efeito no hover; a recompensa de elite usa o mesmo componente para reliquias e cartas raras; o evento usa painel escuro, titulo Bangers e botoes com area suficiente para texto longo. A entrada de combate para recompensa/evento agora usa uma transicao curta de opacidade e escala.

Alterados `carta.tscn`, `main.tscn`, `main.gd`, `recompensa_opcao.gd`, `ui_hq_v1/estilos/tooltip.tres`, `tests/test_composicao_combate.gd`, `tests/test_apresentacao_eventos.gd` e criado `tests/test_apresentacao_recompensas.gd`. Os arquivos `preview_fluxo.gd`, `preview_recompensa.tscn`, `preview_recompensa_elite.tscn` e `preview_evento.tscn` permitem inspecionar as tres telas com dados reais da partida.

Verificacao executada com Godot 4.7.2 GL Compatibility: os testes focados de composicao, evento e recompensa passaram; a suite de 31 cenas em `tests/*.tscn` terminou com `FALHAS=0`; `git diff --check` passou. Capturas reais em 1280x720 de recompensa comum, recompensa elite e evento foram geradas e inspecionadas. A captura de recompensa mostrou o balao de descricao no hover sem fazer o item desaparecer; a captura de evento mostrou o painel e as tres opcoes estilizadas.

Regra de jogo, sinais de escolha, baralho, transicoes de roteiro e efeitos de eventos nao foram alterados. O teste headless do preview nao produz textura de viewport no renderer dummy; por isso, a evidencia visual foi obtida com janela real GL Compatibility.

## Passe tipográfico e de recursos do HUD de combate — 25/09/2026

Após a captura real da reconstrução, o usuário apontou que alguns textos ainda não pertenciam à tipografia do jogo, Energia continuava parecendo texto simples, os recursos inferiores tinham pouca identidade e Vida precisava de tratamento cyberpunk mais forte.

Alterados `main.tscn`, `main.gd` e `tests/test_composicao_combate.gd`: títulos de turno, combatentes e intenção usam Bangers; valores e informações usam Barlow; Energia mostra ícone e valor compacto; Compra e Descarte ganharam módulos próprios com ícone e moldura; Vida agora usa ícone integrado, valor sem o rótulo solto `Vida:` e preenchimento/moldura neon com sombra. Regras, sinais, alvos, cartas e transições não foram alterados.

Verificação executada com Godot 4.7.2 GL Compatibility: o teste RED confirmou as expectativas tipográficas e de Vida antes da implementação; depois, as 30 cenas em `tests/*.tscn` terminaram com código 0. `tests/test_layout_combate.tscn`, `tests/test_composicao_combate.tscn` e `tests/test_interacao_hud_combate.tscn` passaram. Capturas reais em 1280×720 e 1920×1080 foram geradas por `preview_combate.tscn` e inspecionadas; a composição ficou legível sem o botão invadir a mão, com os módulos de recursos acima das cartas.

Pendência visual: Vega e os inimigos ainda usam quadrados provisórios. A próxima melhoria pode substituir esses placeholders por arte dos combatentes, sem reabrir a composição estrutural.

## Correção verificável da composição do combate — 25/09/2026

As capturas enviadas pelo usuário mostraram que a primeira adaptação do kit ainda tinha texto duplicado, painéis sobrepostos e cartas esticadas. A inspeção posterior no renderer real confirmou mais dois problemas: títulos de Habilidade sem contraste e descrições de cartas invadindo a arte. O teste anterior com `--headless --resolution` não havia mudado o viewport para os tamanhos alegados; por isso, aquela aprovação de layout não era evidência suficiente.

Corrigidos em `main.gd`, `main.tscn`, `carta.tscn` e `botao_carta.gd`: os rótulos legados permanecem ocultos ao retornar ao combate; turno, intenção, estados, alvos, Vida, mão e botão de turno ocupam áreas distintas; cartas mantêm proporção e centralização mesmo quando restam duas na mão; a tipografia cresce com a resolução; títulos de cartas têm contraste e nomes longos usam tamanho menor; descrições foram compactadas preservando valores e efeitos derivados do catálogo. As barras de Vida usam preenchimento proporcional com contorno separado. Recompensa e evento ocultam também as caixas decorativas do HUD, sem redesenhar essas telas.

Verificação executada com Godot 4.7.2 GL Compatibility: capturas reais em 1280×720 e 1920×1080 foram inspecionadas; capturas de recompensa e evento em 1280×720 confirmaram ausência do HUD de combate. `tests/test_layout_combate.tscn` confere viewport real, colisões de áreas, proporção da mão, contraste e espaço de texto para as nove cartas. `tests/test_interacao_hud_combate.tscn` aciona sinais dos botões de alvo e fim de turno e confirma seleção, custo, dano, vitória e derrota. A suíte de 29 cenas e a importação headless do editor terminaram com código 0. A validação visual no editor do usuário ainda não foi relatada para esta correção. A tipografia dos botões de recompensa/evento continua apertada; seu redesenho fica fora desta etapa de combate.

## Ajuste estrutural da tela de combate — 25/09/2026

Após a inspeção dos screenshots enviados pelo usuário, a adaptação visual recebeu um primeiro ajuste estrutural. O turno passou a separar título e número em linhas próprias; o resumo de combate, a intenção, os estados do inimigo e os dados do alvo ganharam áreas visuais independentes dos nós legados usados pelo código. Capturas posteriores ainda revelaram falhas corrigidas na seção acima.

O HUD de combate agora é ocultado integralmente ao entrar em recompensa, evento, resultado ou `RUN PRE-CHEFE`. Isso remove Vida, Energia, Barreira, Combo, relíquias, compra, descarte, mão e `Encerrar turno` dessas telas. A mão foi ampliada para acomodar seis cartas na composição de 1280×720, e o tooltip redundante das cartas foi removido para não cobrir a seleção.

Arquivos alterados nesta correção: `main.tscn`, `main.gd`, `carta.tscn`, `botao_carta.gd`, `tests/test_apresentacao_combate.gd` e este arquivo. As regras, sinais, alvos, gasto de Energia, fim de turno, vitória, derrota e transições não foram modificados.

Verificação executada com Godot 4.7.2: `git diff --check`, importação do editor headless e 27 cenas de `tests/*.tscn` passaram. `tests/test_apresentacao_combate.tscn` passou em 1280×720 e 1920×1080; também verificou que a recompensa não conserva o HUD de combate. A inspeção visual final em uma janela real do editor ainda é necessária, especialmente para recompensa, evento e pré-chefe.

Próximo passo: abrir `main.tscn` no editor em 1280×720 e 1920×1080, conferir a composição limpa nos quatro estados e relatar qualquer sobreposição residual antes de mexer em mapa ou menu.

## Snapshot vigente — 24/09/2026

O fluxo intercalado foi implementado: cinco combates e quatro eventos antes do chefe, na ordem `combate comum -> evento -> combate comum -> evento -> elite -> evento -> combate comum -> evento -> combate comum`. O catalogo contem dez encontros possiveis; o roteiro usa nove posicoes antes do chefe.

Implementados nesta sessao: `dados_encontros.gd`, `seletor_encontros.gd`, `roteiro_run.gd`, `dados_eventos.gd`, `resolucao_eventos.gd`, o `EventoOverlay` em `main.tscn` e a integracao do fluxo em `main.gd`. O painel de evento bloqueia cartas e alvos, e recompensas/resultado nao ficam visiveis junto do combate.

O elite continua sendo a Unidade de Contencao Portuaria no terceiro combate da run linear atual e sua recompensa dupla agora leva ao evento seguinte. Eventos podem iniciar combate especial sem recompensa comum automatica; a vitoria retorna ao resultado do evento e a derrota encerra a run sem avancar o roteiro. O chefe ainda nao foi implementado; o mapa agora possui uma tela de navegacao isolada aberta a partir de `RUN PRE-CHEFE`.

Verificacao automatizada desta sessao: 25 cenas de teste passaram com Godot 4.7.2 em modo headless. A validacao visual da run intercalada foi confirmada pelo usuario no editor.

Direcao atual: no mapa, a elite sera o terceiro ponto e concedera uma reliquia e uma carta rara quando a run for integrada. A sequencia linear atual permanece preservada ate a validacao do mapa. As Docas serao tratadas como distrito misto de trabalho portuario, infraestrutura industrial e moradia. A integracao visual inicial abre o mapa somente na tela pre-chefe.

Atualização: 24/09/2026 — ritmo intercalado, catálogo de encontros, eventos estruturados, painel de eventos e combate especial implementados; validação visual da run confirmada pelo usuário; balanceamento adiado.

## Validação manual da run intercalada — 24/09/2026

Relato do usuário acompanhado de screenshot: a run foi executada no editor até a posição `Combate: 5/5` e chegou corretamente à tela `RUN PRE-CHEFE`.

O screenshot mostrou `Baralho: 16`, `Vida: 25`, `Energia: 3/4`, `Barreira: 2` e as relíquias `Juntas de Retorno` e `Reservatório Auxiliar` preservadas. A tela final também manteve visíveis a última ação e os recursos do jogador.

Validação visual confirmada: o fluxo terminou sem sobreposição entre combate, recompensas, eventos e resultado. A mensagem indica que a rota até o chefe foi concluída, sem afirmar que o chefe foi derrotado.

Esta confirmação é uma validação manual no editor, separada da regressão headless de 25 testes já registrada acima.

## Integração da primeira etapa do kit visual de combate — 25/09/2026

Aplicado o kit em `res://ui_hq_v1/` somente à interface de combate. `main.tscn` agora usa `tema_base.tres`, o fundo compartilhado e os componentes de faixa de turno, ícones de Energia/Barreira/Combo/compra/descarte/mão, barras de Vida e painéis separados para intenção e estados do inimigo. Vega e Drone continuam quadrados provisórios, com molduras locais ciano e vermelha.

`carta.tscn` foi convertido em um componente compartilhado em camadas, ainda com raiz `Button`: moldura de Ataque/Habilidade, ilustração disponível, selo de custo, nome, descrição e foco de seleção. `botao_carta.gd` mantém o toggle, o `ButtonGroup`, o texto derivado e o clique da carta; a apresentação visual é atualizada com o identificador e o tipo reais da carta.

`main.gd` passou a atualizar barras, contadores separados, turno, intenção, estados e texto visual de Energia a partir do estado atual. Os nós antigos usados pelo fluxo e pelos testes foram preservados; regras, sinais, alvos, gasto de Energia, fim de turno, vitória, derrota e transições não foram alterados.

Verificação executada com Godot 4.7.2: `git diff --check`, importação do editor headless e 27 cenas em `tests/*.tscn` terminaram com código 0. `tests/test_apresentacao_combate.tscn` passou com `--resolution 1280x720` e `--resolution 1920x1080`, verificando tema, recursos, camadas da carta e limites da mão/botão de turno. A captura de pixels headless não foi válida porque o renderer dummy não expôs uma textura de viewport; portanto a inspeção visual final em janela real ainda precisa ser feita no editor.

Arquivos alterados nesta etapa: `main.tscn`, `main.gd`, `carta.tscn`, `botao_carta.gd` e `tests/test_apresentacao_combate.gd`. O menu, mapa, eventos e telas de recompensa não foram redesenhados.

Próximo passo: validar no editor a abertura do mapa, o bloqueio dos destinos desconectados e o retorno apos combate/evento; depois conferir visualmente a variante com descanso em outra posicao.

## Auditoria inicial para mapa e chefe — 24/09/2026

Inspeção estática do repositório atual: a cena jogável é `main.tscn`, com `main.gd` como orquestrador da interface, combate, recompensas, eventos e roteiro. `roteiro_run.gd` contém uma sequência linear de nove etapas pré-chefe; `dados_encontros.gd` e `seletor_encontros.gd` catalogam e sorteiam encontros; `dados_eventos.gd` e `resolucao_eventos.gd` controlam eventos; `dados_inimigos.gd`, `inimigo_combate.gd` e `encontro_combate.gd` controlam intenções e execução do combate.

Não foram encontrados cena, script ou dados de mapa, nós conectados, caminhos ramificados, descansos, melhoria de carta, chefe ou arena final. O chefe também não existe no catálogo atual. Os pontos narrativos do briefing para Lastro, sala de controle, exoesqueleto e escolhas após a luta permanecem design, não comportamento implementado.

Conflito identificado antes de qualquer alteração: o código e `DECISOES.md` fixam a Unidade de Contenção como terceiro combate, na quinta posição do roteiro atual; o briefing mais recente define o elite como terceiro ponto do mapa. Essa diferença precisa ser confirmada antes de alterar o roteiro.

Verificação executada nesta auditoria: `git diff --check`, conferência dos arquivos e referências de cena, e leitura estática dos scripts envolvidos. A Godot 4.7.2 não estava disponível no PATH nem nas localizações usuais deste ambiente; nenhum teste headless novo foi executado. Os relatos anteriores de testes continuam sendo histórico, não verificação desta auditoria.

O usuário confirmou a regra mais recente: o elite deve ser o terceiro ponto do mapa, não necessariamente o terceiro combate. Nenhum código de jogo foi alterado durante esta auditoria. A implementação seguinte registra essa decisão em `DECISOES.md` e `GAME_DESIGN.md`.

## Modelo isolado do mapa das Docas — 24/09/2026

Criado `mapa_run.gd` como objeto de dados independente. O modelo gera sete pontos: combate inicial, bifurcação, elite no terceiro ponto, duas bifurcações intermediárias, reencontro no sexto ponto e chefe `Lastro` no sétimo. Foram incluídas duas variantes estruturais, com o descanso no segundo ou no quinto ponto.

Criados `tests/test_mapa_run.gd` e `tests/test_mapa_run.tscn`. O teste verifica pontos fixos, ramificações, reencontro, chegada de todos os caminhos ao chefe e variação da posição do descanso. O mapa ainda não está conectado a `main.gd`; combate, eventos e recompensas não foram alterados.

Verificação executada: `git diff --check` passou. A execução RED/GREEN da cena não foi possível porque o executável da Godot não está disponível neste ambiente; portanto a compilação e o teste headless do novo script ainda precisam ser executados no editor ou em um terminal com Godot 4.7.2.

Validação relatada pelo usuário: `tests/test_mapa_run.tscn` exibiu `OK: estrutura do mapa`. Como o teste percorre os pontos fixos, as ramificações, o reencontro, a chegada ao chefe e as duas variantes de descanso, esses comportamentos foram observados como aprovados no ambiente do usuário. Esta é uma validação externa relatada, não uma execução feita neste terminal.

Relato posterior do usuário acompanhado de saída do editor: a variante 0 foi impressa com P1 combate, ramificações em P2 e P4, elite em P3, descanso/evento em P5, reencontro-evento em P6 e `Lastro` em P7. A saída terminou com `OK: estrutura do mapa`. O editor exibiu também um aviso de UID inválido para o recurso de `tests/test_mapa_run.gd`, mas carregou o script pelo caminho textual; não houve falha do teste.

Próximo passo: inspecionar visualmente as duas variantes ou gerar uma representação no editor antes de integrar o mapa à run.

## Navegacao visual isolada do mapa — 24/09/2026

Iniciada a integracao gradual do mapa em `main.gd` e `main.tscn`. A tela `RUN PRE-CHEFE` agora oferece `Abrir mapa`; o painel mostra os sete pontos e cria um botao para cada no da variante escolhida.

O mapa mantem um ponto atual e habilita somente os destinos conectados por `mapa_run.destinos_de`. Nos fora da rota ficam bloqueados. Ao selecionar um no, a integracao encaminha para o sistema existente: combate comum ou elite usa `_iniciar_combate_por_id`, evento usa `EventoOverlay` e descanso volta ao mapa com uma mensagem provisoria, sem alterar Vida ou baralho. O chefe `Lastro` aparece no mapa, mas continua reservado porque seu combate ainda nao existe.

O fluxo linear anterior continua sendo iniciado normalmente; o mapa pode ser aberto depois da tela pre-chefe para validar a navegacao sem alterar a luta, os eventos ou as recompensas existentes. Recompensas e continuacao de eventos iniciados pelo mapa retornam ao mapa atual.

Criado `tests/test_navegacao_mapa.gd` com `tests/test_navegacao_mapa.tscn`. O teste verifica a abertura do painel, o inicio em P1, dois destinos habilitados, bloqueio de nos desconectados e movimentacao somente apos selecionar um destino valido. A Godot nao esta disponivel no PATH deste terminal, portanto a execucao RED/GREEN ainda precisa ser feita no editor pelo usuario.

A variante permanece deterministica em `mapa_variante = 0` nesta etapa. O modelo ja aceita a variante 1 e o teste estrutural anterior confirmou a mudanca da posicao do descanso; ainda falta validar essa variante visualmente na tela integrada.

## Refino visual da tela do mapa — 24/09/2026

Relato do usuario acompanhado de screenshot: a primeira tela integrada do mapa deixava indicadores de combate, ultima acao e recursos visiveis por baixo do mapa. Os botoes tambem estavam concentrados no canto esquerdo, com pouca diferenciacao entre ponto atual, destino e no bloqueado.

Alteracao feita em `main.tscn` e `main.gd`: o mapa agora usa um fundo opaco em tela cheia, oculta os indicadores do combate enquanto esta aberto, centraliza as linhas dos sete pontos, aumenta a area clicavel dos nos, permite quebra de texto nos nomes e aplica estados visuais distintos para atual, destino disponivel e caminho bloqueado. A legenda explica esses estados dentro da propria tela.

O teste `tests/test_navegacao_mapa.gd` agora tambem verifica que o fundo aparece e que `PilhasLabel` e `AcaoLabel` ficam ocultos durante a navegacao. `git diff --check` passou. A Godot 4.7.2 nao esta disponivel no terminal, entao a compilacao, o teste headless e a aparencia final continuam pendentes de execucao no editor.

## Implementacao mais recente — 24/09/2026

Implementados os componentes de conteudo e fluxo desta sessao:

- `dados_encontros.gd`: dez entradas, com quatro combates comuns, um elite e cinco eventos narrativos.
- `seletor_encontros.gd`: sorteio de eventos sem repeticao, registro validado e reinicio.
- `roteiro_run.gd`: nove posicoes fixas antes do chefe, mantendo a Unidade de Contencao como terceiro combate.
- `dados_eventos.gd` e `resolucao_eventos.gd`: opcoes e consequencias estruturadas fora da cena e sem mutacao direta do jogador pelo resolvedor.
- `main.tscn`: `EventoOverlay` com titulo, contexto, ate tres opcoes, resultado e continuar.
- `main.gd`: transicoes de combate, evento, recompensa, elite, pre-chefe e combate especial.

O fluxo preserva Vida e baralho entre etapas. Recompensas comuns avancam para evento; skip tambem avanca sem alterar o baralho; a recompensa dupla do elite avanca para o evento seguinte. Ao terminar as nove posicoes, a interface mostra `RUN PRE-CHEFE` e nao afirma que o chefe foi derrotado.

Consequencias provisoriamente implementadas: ajudar o operario custa 10 de Vida; desligar a valvula inicia uma Torreta de Contencao; enfrentar o ladrao ou confrontar a fiscalizacao inicia um Guarda Portuario. As ideias de recompensa da carga e remocao real de carta pelo ladrao continuam sem efeito de jogo nesta etapa, para nao inventar regras ainda nao aprovadas.

Testes RED -> GREEN e regressao: foram adicionados `test_catalogo_encontros.tscn`, `test_seletor_encontros.tscn`, `test_roteiro_run.tscn`, `test_resolucao_eventos.tscn`, `test_apresentacao_eventos.tscn` e `test_ciclo_encontros.tscn`; a suite completa de 25 testes terminou com codigo 0. A importacao headless do editor tambem foi executada durante a implementacao.

Validação manual confirmada pelo usuário: a run chegou a `RUN PRE-CHEFE` no editor, com a tela organizada e sem sobreposição visual entre as etapas.

Próximo passo: definir os efeitos finais dos eventos, então preparar o primeiro chefe e o mapa das Docas. Balanceamento definitivo continua adiado.

## Confirmado

- Primeira entrega: Vega como personagem jogável e Docas como distrito inicial.
- Expansão planejada: Luvto e Cais, cada um com seu distrito inicial.
- Vega é humana com braços protéticos e usa Combo/Finalização.
- Tipos de carta: Ataque, Habilidade e Aprimoramento.
- Desenvolvimento acompanhado, gradual e com GDScript tipado.
- O projeto declara Godot 4.7 e `GL Compatibility`; screenshot do usuário mostrou o editor 4.7.2 stable.
- Foco inicial em PC, com intenção futura de celular.
- Marco v0.1: o ciclo fundamental de deckbuilder roguelike foi validado, sem significar que todos os sistemas do design estejam implementados.

## Estado implementado

- Cena principal em `res://main.tscn`, executada no editor segundo relato do usuário.
- Carta reutilizável em `res://carta.tscn`, com nome, custo, descrição e seleção.
- Dados de Golpe, Proteção, Direto Hidráulico, Quebra-chassi, Brecha, Pulso Debilitante e três cartas raras estão em `res://dados_cartas.gd`; `main.gd` continua usando a mesma interface de `CARTAS`.
- Compra de 6 cartas, mão, descarte e reembaralhamento.
- Baralho da run iniciado com 12 cartas: 4 Golpes, 4 Proteções, 2 Diretos Hidráulicos e 2 Quebra-chassis; recompensas comuns e a carta rara do elite podem aumentar o baralho durante a run.
- Energia, Vida, Barreira, fase inimiga, resultado e reinício do combate de teste.
- Combo de Vega até 5 e Quebra-chassi consumindo todo o Combo para causar `5 + 3 × Combo`.
- Relíquia inicial Juntas de Retorno: ao alcançar 2 Combo no turno, concede 3 de Barreira uma vez; voltar a 2 no mesmo turno não ativa novamente.
- Catálogo de relíquias em `res://dados_reliquias.gd`: Juntas de Retorno, Reservatório Auxiliar e Mecanismo de Recuo; a run começa com Juntas e o elite oferece duas opções restantes.
- Cartas raras: Golpe de Aríete, Ruptura de Pressão e Placa Reforçada; o elite oferece três opções distintas e a jogadora escolhe uma.
- Exposto e Enfraquecido funcionam como cargas contadas por golpe nos inimigos; Brecha e Pulso Debilitante estão disponíveis como recompensas, mas não entram no baralho inicial.
- Drone atual com 30 de Vida e ciclo visível `Rajada → Blindagem → Rajada → Sobrecarga → Rajada → Marca → Rajada`; Sobrecarga e Marca são consumidas na Rajada seguinte.
- Catálogo comum em `res://dados_inimigos.gd`: Drone de Segurança (30 de Vida), Estivador Cibernético (36), Torreta de Contenção (24) e Guarda Portuário (32), cada um com ciclo determinístico próprio de ataque, defesa e preparação.
- `res://seletor_inimigos.gd` sorteia inimigos comuns sem repetição entre as posições de combate; a terceira ocorrência de combate usa o elite fixo e não entra no histórico comum.
- `res://inimigo_combate.gd` interpreta os ciclos dirigidos por dados, e a interface mostra dinamicamente nome, Vida, Barreira, intenção e estados do inimigo ativo.
- Run intercalada implementada: cinco combates e quatro eventos antes do chefe, com recompensa comum entre combates e recompensa dupla obrigatória no elite.
- Primeiro componente genérico criado em `res://combatente.gd`: Vida atual e máxima, Barreira, Exposto, Enfraquecido, cálculo de dano por golpe, recebimento de golpes e reinicialização.
- `res://jogador_combate.gd` concentra o estado do jogador, Energia, Combo e ativação por turno de Juntas de Retorno.
- `res://encontro_combate.gd` concentra inimigo ativo, baralho temporário, turno, condição de encerramento e execução da fase inimiga.
- Oferta comum sorteia três cartas distintas entre as seis cartas comuns disponíveis; a jogadora pode adicionar uma ao baralho ou pular. A oferta do elite sorteia duas relíquias e três cartas raras em etapas separadas, sem skip.
- A recompensa do elite alterna visualmente entre uma única etapa de relíquias e uma única etapa de cartas raras; os controles da etapa anterior são escondidos antes da próxima aparecer.
- Apresentação do combate reorganizada: intenção e estados do inimigo têm áreas próprias, a última ação fica visível, Energia mostra o limite e `SEM ENERGIA`, e a mão mostra seu limite e `MÃO CHEIA`.
- Layout da tela refinado: o bloco de pilhas tem espaço para as duas linhas, `VEGA` fica separado abaixo dele e os indicadores de Energia, Barreira, Combo, Relíquia e Vida ficam alinhados em uma coluna legível.

## Atividade atual

Core vertical v0.1 encerrado. A consolidação técnica inclui `Combatente`, `JogadorCombate`, `EncontroCombate`, `BaralhoCombate`, `InimigoCombate` e `ResolucaoCartas`. O catálogo de quatro inimigos comuns, o elite, as cartas raras, as relíquias, o catálogo de encontros, o roteiro e os eventos foram implementados. `main.gd` delega estado do jogador, recursos temporários, inimigo ativo, baralho do combate, turno e fase inimiga; continua responsável por sinais da cena, cartas visuais, interface, recompensas e fluxo da run. A run intercalada e o combate especial passaram nos testes headless; falta a confirmação visual final no editor.

O plano `superpowers/plans/2026-09-23-primeira-cena.md` é histórico e não representa a atividade atual.

## Evidência disponível

- Relato do usuário: o ciclo básico funciona para jogar cartas, gastar Energia, defender, descartar, comprar e vencer.
- Relato do usuário: a apresentação das cartas ficou adequada.
- Relato do usuário: prints mostraram Combo 3/5 preservado após jogar Proteção.
- Inspeção dos arquivos confirmou as estruturas registradas nas seções cronológicas abaixo.
- Teste automatizado executado com Godot 4.7.2 em modo headless confirmou o ciclo Rajada/Blindagem; a experiência visual ainda deve ser conferida no editor.
- Teste automatizado da run confirmou Vida persistente, recompensa no baralho, reinicialização do estado temporário e conclusão após o segundo combate.
- Relato do usuário, com base nas telas: compra, seleção, uso, descarte, reembaralhamento, recursos, Combo/Finalização, intenções, vitória/derrota, persistência de Vida e conclusão da run funcionaram no editor.
- Teste automatizado do catálogo confirmou as seis cartas e seus valores; os testes de intenções e run permaneceram verdes após a extração, a inclusão de Direto e os estados.
- Teste automatizado de Juntas de Retorno confirmou ativação ao alcançar 2 Combo, concessão de 3 de Barreira, ausência de repetição no mesmo turno e nova ativação no turno seguinte.
- Regressão headless com Godot 4.7.2: catálogo, Juntas de Retorno, intenções do Drone e ciclo de run terminaram com código 0; a importação do projeto no editor headless também terminou com código 0.
- Teste automatizado de estados confirmou Exposto `2 → 1 → 0`, Enfraquecido reduzindo cada golpe da Rajada, consumo contra Barreira, aplicação por Brecha/Pulso e exibição dos estados no Drone.
- Relato do usuário: Brecha e Pulso Debilitante foram utilizados no editor e funcionaram bem.
- Relato do usuário: as ofertas aleatórias e o botão `Pular recompensa` funcionaram corretamente no editor.
- Regressão após a integração de `Combatente`: `test_combatente.tscn`, `test_catalogo_cartas.tscn`, `test_estados.tscn`, `test_juntas_retorno.tscn`, `test_intencoes_drone.tscn` e `test_ciclo_run.tscn` terminaram com código 0; a importação do editor headless também terminou com código 0.
- Screenshot do usuário identificou sobreposição visual entre `PilhasLabel` e o botão `VEGA`, além de desalinhamento dos indicadores do jogador; o ajuste foi feito em `main.tscn` sem alterar regras ou conteúdo do combate.
- Teste focado `tests/test_apresentacao_combate.tscn` passou após o ajuste e confirmou largura/altura do bloco de pilhas, separação vertical de `VEGA` e ausência de invasão dos indicadores de recurso.
- Regressão headless com Godot 4.7.2: os 12 testes em `tests/*.tscn` terminaram com código 0; a importação do projeto no editor headless também terminou com código 0.
- Regressão após `JogadorCombate` e `EncontroCombate`: os 14 testes em `tests/*.tscn` terminaram com código 0; a importação do projeto no editor headless também terminou com código 0.
- Testes do catálogo confirmaram os quatro inimigos, suas Vidas e ciclos; o seletor confirmou sorteio sem repetição, rejeição de duplicatas e esgotamento seguro.
- `tests/test_cartas_multiplos_inimigos.tscn` confirmou as seis cartas atuais contra os quatro inimigos configurados.
- Regressão após a integração do catálogo: os 17 testes em `tests/*.tscn` terminaram sem `SCRIPT ERROR`, `ERROR:` ou `FALHA:`; a importação do projeto no editor headless também terminou limpa.
- Relato do usuário: os quatro inimigos comuns foram enfrentados no editor; nomes, intenções e variação dos encontros ficaram mais dinâmicos.
- Teste do catálogo confirmou a Unidade de Contenção Portuária com 44 de Vida, quatro intenções e Rajada fortalecida para `7 × 2` depois de Pressurizar.
- Testes confirmaram nove cartas catalogadas, três raras e resolução de Golpe de Aríete, Ruptura de Pressão e Placa Reforçada pelo mesmo `ResolucaoCartas`.
- Testes confirmaram três relíquias catalogadas, rejeição de duplicatas e os gatilhos de Reservatório Auxiliar e Mecanismo de Recuo em `JogadorCombate`.
- Teste do ciclo de run confirmou dois inimigos comuns sem repetição, elite fixo no terceiro combate, duas opções de relíquia, três cartas raras e conclusão somente após os dois prêmios.
- Regressão headless com Godot 4.7.2: 19 cenas em `tests/*.tscn` terminaram com código 0; a importação do editor headless também terminou com código 0.
- Relato do usuário acompanhado de screenshot: a run intercalada chegou a `Combate: 5/5` e `RUN PRE-CHEFE`, com Vida, Energia, Barreira e as relíquias visíveis na tela.
- Relato do usuário: após vencer o elite, a tela mostrava simultaneamente títulos/opções de relíquia e carta rara; o problema foi reproduzido no teste de ciclo e corrigido separando a visibilidade das duas etapas.
- Teste de regressão após a correção: 19 cenas em `tests/*.tscn` e a importação do editor headless terminaram com código 0.

## Próximo passo vigente

Definir os efeitos finais dos eventos e preparar o primeiro chefe. Depois, iniciar o mapa das Docas.

## Como atualizar este arquivo

Substitua os itens não verificados por fatos específicos após observar o resultado. Informe versão, caminho, arquivos criados, comportamento visto, erros existentes e próximo passo. Preserve a distinção entre proposta e funcionamento observado.

## Nota sobre o histórico

O resumo inicial e a última seção cronológica descrevem o estado vigente. As seções cronológicas anteriores preservam decisões e marcos históricos; quando um item antigo divergir do resumo atual, ele deve ser lido como registro do estado daquela etapa, não como requisito ou pendência atual.

Último avanço: elite fixo no terceiro combate, recompensa obrigatória de relíquia e carta rara, com testes automatizados verdes.

Validado automaticamente:
- 19 cenas de teste headless com Godot 4.7.2.
- Importação do projeto em modo editor headless.

Validado manualmente:
- Os quatro inimigos comuns foram enfrentados no editor.

Pendente de validação manual:
- Unidade de Contenção, recompensa dupla e efeitos das novas relíquias.

Histórico manual anterior:
- Novo turno restaura a energia para 4.
- Contador de turnos avança.
- Encerrar turno após derrotar o drone é bloqueado.

Próximo passo:
- Executar novamente a run de três combates no editor e confirmar que apenas uma etapa da recompensa do elite aparece por vez.

## Atualização da preparação de `carta.tscn` — 23/09/2026

Estado observado no projeto: `carta.tscn` existia, mas sua raiz era um `Control` sem script, texto ou tamanho mínimo. `main.tscn` ainda mantém as duas cartas manuais dentro de `Mao`, como pedido para esta etapa.

Alteração feita: `carta.tscn` agora tem uma raiz `Button` chamada `Carta`, usa `botao_carta.gd`, define tamanho mínimo de 180 x 240 e começa com o texto `CARTA`. `main.tscn` e `main.gd` não foram alterados.

Verificação executada: inspeção estática dos arquivos e conferência da versão declarada no projeto (`Godot 4.7`, `GL Compatibility`). Não houve execução de F6 neste ambiente, portanto a resposta visual do botão ainda precisa ser confirmada no editor.

Próximo passo: abrir `carta.tscn` na Godot, executar com F6 e confirmar o texto `GOLPE` e a alternância entre selecionada e desmarcada ao clicar.

## Incidente e restauração de `main.tscn` — 23/09/2026

Relato do usuário: a Godot exibiu `Parse Error` em `res://main.tscn:5` e falhou ao carregar a cena.

Diagnóstico observado: `main.tscn` havia sido sobrescrito como uma cena que referenciava `res://main.tscn` como `PackedScene` e instanciava a si mesma. Isso criava uma dependência circular. A causa não estava em `carta.tscn`.

Restauração feita: `main.tscn` voltou à estrutura anterior com raiz `Main` (`Control`), `main.gd`, `Mao` (`HBoxContainer`), `BotaoCarta` e `BotaoProtecao`. A cena `carta.tscn` foi preservada.

Verificação executada: inspeção estrutural confirmou que `main.tscn` não instancia a si mesma e contém as referências e nós esperados. Ainda falta abrir a cena na Godot e executar F6 para confirmar o carregamento no editor.

## Implementação provisória de compra, mão e descarte — 23/09/2026

Alteração solicitada: testar o ciclo de combate com um baralho provisório de 5 Golpes e 5 Proteções, comprando 6 cartas por turno.

Arquivos alterados:

- `main.gd`: pilha de compra, pilha de descarte, criação de cartas por `carta.tscn`, metadata `id_carta`, descarte ao jogar e ao encerrar, ataque do drone e reembaralhamento quando a compra esvazia.
- `main.tscn`: remoção dos dois botões fixos de `Mao`, criação de `PilhasLabel` e separação 12; o `Mao` foi preservado.
- `carta.tscn`: tamanho mínimo alterado para 140 x 200; raiz `Button` e `botao_carta.gd` preservados.

Verificação executada: inspeção estrutural confirmou as referências, nós e constantes principais. A Godot 4.7 não está disponível no `PATH` deste terminal, portanto ainda não há execução de F6 nem validação manual do ciclo.

Próximo passo: executar `main.tscn` na Godot e conferir as contagens iniciais (`Compra: 4 | Descarte: 0 | Mão: 6`), depois jogar uma carta e encerrar o turno observando as contagens e a Energia.

## Apresentação das cartas — 23/09/2026

Relato do usuário: o ciclo básico de combate está funcionando, incluindo jogar cartas, gastar Energia, defender, descartar, comprar e vencer.

Alteração feita: `botao_carta.gd` agora mostra nome, custo em Energia, descrição do efeito e o marcador `SELECIONADA` sem esconder as demais informações. `main.gd` preenche esses campos a partir do dicionário `CARTAS`; Golpe mostra o dano e Proteção mostra a Barreira usando os valores atuais do dicionário.

Regras preservadas: compra, mão, descarte, reembaralhamento, Energia, dano, defesa, turnos e condição de vitória não foram alterados nesta etapa.

Verificação executada: inspeção estrutural confirmou os campos exportados, o preenchimento derivado de `CARTAS` e a permanência das funções de compra e descarte. A Godot não está disponível no `PATH` deste terminal; a aparência final ainda precisa ser conferida executando `main.tscn` no editor.

Próximo passo: validar visualmente as cartas e então iniciar a etapa de resultado e reinício do combate.

## Resultado e reinício do combate — 23/09/2026

Relato do usuário: a apresentação das cartas ficou adequada e o ciclo básico continua funcionando.

Alteração feita: `main.tscn` recebeu os filhos diretos `ResultadoLabel` e `Reiniciar`, posicionados no centro e abaixo dele, longe da mão. Ambos começam ocultos durante o combate.

`main.gd` agora mostra `VITÓRIA` quando o drone é derrotado, mostra `DERROTA` quando Vega fica sem Vida e conecta `Jogar novamente` a `reload_current_scene()`, reiniciando o combate de teste com um novo baralho embaralhado.

Regras preservadas: compra, mão, descarte, Energia, dano, Barreira, turnos e bloqueio dos controles continuam no fluxo anterior.

Verificação executada: inspeção estrutural confirmou os nós, referências, mensagens e chamadas nos dois caminhos de encerramento. A Godot não está disponível no `PATH` deste terminal; ainda falta validar visualmente vitória, derrota e reinício executando `main.tscn`.

Próximo passo: executar o combate até vencer e até perder, verificando a mensagem correspondente e o botão `Jogar novamente`.

## Contador de Combo da Vega — 23/09/2026

Alteração feita: `main.tscn` recebeu o `ComboLabel` como filho direto de `Main`, próximo ao indicador de Barreira. `main.gd` recebeu `COMBO_MAXIMO = 5`, o estado `combo` e a atualização `Combo: atual/máximo`.

Regra implementada: Golpe concede 1 Combo até 5; Proteção preserva o valor; encerrar o turno zera o Combo; derrotar o drone também zera o Combo antes da atualização final da interface. A descrição de Golpe agora informa que ele concede 1 Combo.

Regras preservadas: compra, mão, descarte, Energia, dano, Barreira, resultado e reinício continuam no fluxo anterior. Nenhuma carta consumidora de Combo foi adicionada.

Verificação executada: inspeção estrutural confirmou o nó, a constante, a variável, os pontos de incremento/reset e a descrição atualizada. A Godot não está disponível no `PATH` deste terminal; ainda falta executar o combate no editor para conferir `0/5`, `1/5`, manutenção com Proteção, `2/5` e reset para `0/5`.

Próximo passo: testar o contador em um combate novo antes de adicionar Quebra-chassi.

## Quebra-chassi e Finalização — 23/09/2026

Relato do usuário: os prints confirmaram Combo 3/5 preservado após jogar Proteção.

Alteração feita: `main.gd` agora cadastra Quebra-chassi como uma Finalização de custo 1, dano base 5 e bônus de 3 por ponto de Combo. O baralho provisório passou a ter 4 Golpes, 4 Proteções e 2 Quebra-chassis.

Regra implementada: ao jogar Quebra-chassi contra o inimigo, o dano é calculado como `5 + 3 × Combo`, todo o Combo é consumido e a carta não gera Combo. Golpe continua gerando 1 Combo; Proteção continua preservando o valor. O alvo e o custo são validados antes da resolução, então usar Quebra-chassi em Vega não deve gastar Energia nem consumir Combo.

Apresentação atualizada: a descrição da Finalização mostra que ela consome o Combo e exibe a fórmula do dano.

Verificação executada: inspeção estrutural confirmou cadastro, composição 4 + 4 + 2, fórmula, consumo, ausência de ganho de Combo e validações anteriores à resolução. A Godot não está disponível no `PATH` deste terminal; ainda falta validar no editor o caso Combo 1 produzindo 8 de dano e Combo 3 produzindo 14.

Próximo passo: testar Golpe → Quebra-chassi → Golpe e confirmar os valores 24 → 16 → 10 de Vida do drone, com Combo 1 → 0 → 1.

## Revisão de fontes e especificação — 23/09/2026

Problema confirmado: `GAME_DESIGN.md`, o topo de `STATUS.md` e a especificação de intenções ainda continham informações substituídas ou desatualizadas, incluindo o nome anterior de Luvto, Vega como robô e o antigo escopo de três personagens na primeira entrega.

Correções feitas:

- `GAME_DESIGN.md`: alinhado a Luvto, Vega humana com braços protéticos e primeira entrega focada em Vega/Docas; a precedência de `DECISOES.md`, `PERSONAGENS.md`, código e `STATUS.md` ficou explícita.
- `DECISOES.md`: esclarece que Luvto já está confirmado e que testes de balanceamento do protótipo podem começar, mantendo valores como hipóteses até aceitação.
- `STATUS.md`: resumo inicial consolidado com o estado implementado atual; o plano M0 permanece apenas como histórico.
- Especificação de intenções e recompensas: corrigida para três tipos de carta, Luvto e valores atuais observados do Drone. As hipóteses não aprovadas de 40 de Vida e ataques 6/10 foram removidas.

Nenhum script ou cena foi alterado naquela revisão. A direção posterior substituiu o ataque fixo pelo ciclo de intenções registrado abaixo.

## Rajada e Blindagem do Drone — 23/09/2026

Direção aprovada: intenção é a ação completa anunciada pelo inimigo, podendo representar ataque, defesa, buff ou debuff. O Drone de segurança das Docas terá o ciclo completo `Rajada → Blindagem → Rajada → Sobrecarga → Rajada → Marcar alvo → repetir`, implementado em partes.

Primeiro incremento implementado em `main.gd`: Rajada causa dois golpes separados de 3; Blindagem concede 6 de Barreira; as duas intenções alternam e são mostradas no botão do Drone. A Barreira anterior do Drone expira no início do turno dele, e ataques de Vega agora descontam primeiro essa Barreira.

Teste automatizado adicionado em `tests/test_intencoes_drone.gd`. Evidência headless com Godot 4.7.2: o teste falhou antes da implementação por ausência da execução, da Barreira inimiga e do texto da intenção; após a implementação, terminou com `OK: ciclo Rajada e Blindagem` e código 0. Foram confirmados Vega `40 → 34`, Blindagem 6, dano 6 totalmente absorvido sem reduzir a Vida 30 do Drone e nova Rajada levando Vega `34 → 28`. Jogar a carta Golpe nesse ponto, incluindo ganho de Combo, permanece na validação manual.

Validação manual posterior relatada no marco v0.1: a apresentação das intenções foi observada funcionando no editor. Sobrecarga e Marca ainda não fazem parte do estado implementado. O sorteio inicialmente considerado foi substituído, neste protótipo, pelo ciclo determinístico aprovado.

## Primeiro ciclo de run — 23/09/2026

Implementado o fluxo `combate 1 → recompensa → combate 2 → conclusão`. O baralho da run começa com 10 cartas e a escolha entre Golpe, Proteção ou Quebra-chassi adiciona uma cópia permanente para o segundo combate. A opção de pular recompensa permanece adiada.

A Vida atual de Vega atravessa a transição. Energia, mão, compra, descarte, Combo, Barreiras, turno, Vida do Drone e intenção do Drone são reiniciados. O segundo combate usa o baralho de 11 cartas e, após sua vitória, mostra `RUN CONCLUÍDA` e o botão de reinício.

Teste automatizado `tests/test_ciclo_run.gd`: primeiro falhou pela ausência dos nós e operações da recompensa; depois passou com Godot 4.7.2 em modo headless. Foram observados Vida 31 preservada, baralho `10 → 11`, Drone restaurado para 30, mão 6, compra 5, descarte vazio e conclusão após a segunda vitória. O teste anterior de Rajada/Blindagem também permaneceu verde.

Validação manual posterior relatada no marco v0.1: a recompensa e o ciclo completo foram observados funcionando no editor.

## Marco: core vertical v0.1 — 23/09/2026

Validação relatada pelo usuário com base nas telas do jogo:

- cartas são compradas, selecionadas, usadas e descartadas;
- compra, descarte e reembaralhamento funcionam;
- Energia, Vida e Barreira funcionam;
- Combo e Finalização da Vega produzem decisões relevantes;
- o Drone anuncia e executa intenções;
- vitória e derrota encerram corretamente o combate;
- a Vida persiste entre combates;
- a recompensa aumenta o baralho de 10 para 11 cartas;
- a run de dois combates chega à conclusão.

Conclusão aceita: a hipótese central foi validada e o protótipo já constitui um pequeno deckbuilder roguelike funcional. Este marco conclui o core vertical, não o projeto inteiro.

Continuam fora do estado implementado: catálogo de estados, relíquias, Aprimoramentos, múltiplos inimigos, mapa, eventos e chefe. Esses sistemas passam a ser expansão do core.

Ordem aprovada para a próxima fase:

1. consolidar tecnicamente o código, começando somente pela extração dos dados das cartas de `main.gd`;
2. implementar Direto Hidráulico;
3. implementar a relíquia inicial Juntas de Retorno;
4. implementar Exposto e Enfraquecido;
5. avançar depois para encontros diferentes, mapa das Docas e chefe.

Nenhum código ou cena foi alterado ao registrar este marco.

## Consolidação dos dados de cartas — 23/09/2026

Criado `dados_cartas.gd` como componente próprio de dados. `main.gd` mantém a constante local `CARTAS`, mas agora a recebe do catálogo; isso preserva as chamadas existentes enquanto remove o dicionário de regras do arquivo principal.

Nenhum valor anterior foi alterado. O catálogo agora contém também Direto Hidráulico, com custo 1, dano 4, alvo inimigo, geração de 2 de Barreira e ganho de 1 Combo.

Teste RED→GREEN: `tests/test_catalogo_cartas.gd` falhou antes da extração porque o recurso não existia e passou depois com `OK: catálogo de cartas preserva os dados do combate`. Em seguida, os testes de Rajada/Blindagem e da run de dois combates passaram novamente; a importação headless da Godot 4.7.2 também terminou com código 0.

Próximo incremento: implementar a relíquia inicial Juntas de Retorno, ativada ao alcançar pelo menos 2 Combo no turno.

## Direto Hidráulico — 23/09/2026

Implementado no catálogo, no baralho inicial da Vega e nas recompensas. O baralho passa a conter 12 cartas: 4 Golpes, 4 Proteções, 2 Diretos Hidráulicos e 2 Quebra-chassis. A área de recompensa passou a oferecer quatro opções fixas.

Ao jogar Direto contra o Drone, a carta causa 4 de dano, gera 2 de Barreira para Vega e concede 1 Combo. A descrição da carta é derivada dos mesmos dados usados na resolução.

Teste RED→GREEN: a suíte falhou antes da implementação pela ausência do identificador, do efeito e do botão de recompensa; após a implementação, catálogo, run e intenções terminaram com código 0. O teste do catálogo confirmou Vida do Drone `30 → 26`, Barreira `0 → 2` e Combo `0 → 1`. A recompensa confirmou o baralho `12 → 13`.

## Juntas de Retorno — 23/09/2026

Implementada a primeira relíquia da Vega em `main.gd`, com indicador permanente em `main.tscn`.

Regra implementada: quando um ataque não-finalização faz o Combo alcançar pelo menos 2 no turno, Juntas de Retorno concede 3 de Barreira. A relíquia ativa uma única vez por turno; consumir o Combo e alcançar 2 novamente no mesmo turno não concede outra Barreira. O estado de ativação é reiniciado no início de cada combate e no início de cada novo turno.

Teste RED→GREEN: `tests/test_juntas_retorno.gd` confirmou a primeira ativação, a ausência de repetição no mesmo turno e uma nova ativação no turno seguinte. A suíte também confirmou que Golpe continua gerando Combo e que a relíquia não altera o custo ou o efeito das cartas.

Verificação executada com Godot 4.7.2 em modo headless: teste do catálogo, teste de Juntas de Retorno, teste de intenções e teste do ciclo de run terminaram com código 0. A importação do projeto no editor headless também terminou com código 0.

Próximo passo: validar manualmente Brecha e Pulso Debilitante quando forem disponibilizados no fluxo de recompensas; depois decidir a entrada dessas cartas no baralho de teste e avançar para Sobrecarga e Marca do Drone.

## Exposto e Enfraquecido — 23/09/2026

Implementada a infraestrutura inicial de estados no `main.gd`. O Drone agora mantém cargas de Exposto e Enfraquecido, contadas por golpe e reiniciadas no início de cada combate.

Regra implementada: Exposto acrescenta 2 ao dano dos próximos golpes recebidos pelo Drone; Enfraquecido reduz em 2 o dano dos próximos golpes realizados pelo Drone, até zero. Cada carga é consumida mesmo quando a Barreira absorve o dano. A Rajada aplica o cálculo separadamente nos dois golpes.

Cartas adicionadas ao catálogo de teste em `dados_cartas.gd`:

- Brecha: Ataque de 4 de dano que aplica Exposto 2 se o Drone sobreviver.
- Pulso Debilitante: aplica Enfraquecido 2 ao Drone e concede 3 de Barreira a Vega.

Essas cartas não foram adicionadas ao baralho inicial, mas agora aparecem nas recompensas junto das quatro cartas anteriores. Isso preserva o baralho inicial enquanto permite validar os estados em jogo.

Apresentação: o botão do Drone mostra `Exposto: N` e `Enfraquecido: N` quando houver cargas ativas.

Teste RED→GREEN: `tests/test_estados.gd` confirmou catálogo, cálculo por golpe, consumo das cargas contra Barreira, aplicação de Brecha/Pulso, leitura na interface e reinicialização entre combates.

Verificação executada com Godot 4.7.2 em modo headless: catálogo, estados, Juntas de Retorno, intenções do Drone e ciclo de run terminaram com código 0. A importação do projeto no editor headless também terminou com código 0.

## Brecha, Pulso, Sobrecarga e Marca — 23/09/2026

Brecha e Pulso Debilitante foram adicionados à grade de recompensas em `main.tscn` e conectados ao fluxo de recompensa de `main.gd`. A grade passou a ter seis opções: Golpe, Proteção, Direto Hidráulico, Quebra-chassi, Brecha e Pulso Debilitante.

O Drone agora segue o ciclo determinístico `Rajada → Blindagem → Rajada → Sobrecarga → Rajada → Marca → Rajada`. Sobrecarga prepara +2 por golpe para a próxima Rajada; Marca prepara +1 por golpe para a próxima Rajada. O valor anunciado da Rajada já inclui esses modificadores e cada bônus é consumido depois do ataque completo.

O ciclo também respeita Enfraquecido: cada golpe passa pelos modificadores do Drone separadamente, e as cargas continuam sendo consumidas por golpe.

Teste RED→GREEN: `tests/test_intencoes_drone.gd` confirmou as quatro intenções novas/anteriores, os valores anunciados, o dano `5 × 2` de Sobrecarga, o dano `4 × 2` de Marca e o consumo dos bônus. `tests/test_ciclo_run.gd` confirmou que Brecha pode ser escolhida e adicionada ao baralho permanente.

Verificação executada com Godot 4.7.2 em modo headless: catálogo, estados, Juntas de Retorno, intenções completas e ciclo de run terminaram com código 0. A importação do projeto no editor headless também terminou com código 0. Validação manual posterior relatada pelo usuário confirmou o uso de Brecha e Pulso Debilitante no editor.

## Arquitetura genérica de combatentes — Task 1 e Task 2 — 23/09/2026

Criado `combatente.gd` como modelo `RefCounted` genérico para qualquer jogador ou inimigo. Ele concentra Vida atual e máxima, Barreira, Exposto, Enfraquecido, cálculo de dano por golpe, recebimento de golpes e reinicialização.

`main.gd` agora mantém `estado_jogador` e `estado_inimigo` como fontes únicas desse estado comum. As propriedades legadas `vida_jogador`, `vida_inimigo`, `barreira`, `barreira_inimigo`, `exposto_inimigo` e `enfraquecido_inimigo` continuam disponíveis, mas delegam aos objetos para preservar as interfaces existentes durante a migração.

A inicialização de um novo combate reinicia Barreira e estados temporários dos dois combatentes, preservando a Vida atual do jogador entre combates. Nenhuma regra de carta, intenção, recompensa ou layout foi alterada.

Teste RED→GREEN: a integração primeiro falhou porque `main.gd` não expunha os dois `Combatente`. Depois da implementação, `tests/test_estados.gd` confirmou os objetos e a sincronização entre o estado genérico e a interface legada. A regressão completa e a importação headless da Godot 4.7.2 terminaram com código 0.

Próximo passo: extrair a compra, o descarte e o reembaralhamento para `BaralhoCombate`, mantendo as pilhas temporárias do combate separadas do baralho permanente da run.

## Baralho de combate genérico — Task 3 — 23/09/2026

Criado `baralho_combate.gd` como componente `RefCounted` responsável somente pelas pilhas temporárias do combate. Ele copia o baralho permanente para a compra, compra identificadores, envia cartas ao descarte e reembaralha o descarte somente quando uma compra exige.

`main.gd` agora usa `baralho_combate` para preparar as pilhas, comprar identificadores e descartar cartas. As propriedades legadas `pilha_compra` e `pilha_descarte` continuam delegando ao componente para preservar a interface da tela e os testes existentes. O baralho permanente `baralho_run` continua separado e não é modificado pela compra.

Teste RED→GREEN: `tests/test_baralho_combate.tscn` primeiro falhou porque `BaralhoCombate` não existia. Depois da implementação, confirmou cópia do baralho, compra completa, reembaralhamento do descarte, descarte e retorno vazio quando ambas as pilhas acabam. `tests/test_ciclo_run.tscn` também terminou com código 0 após a integração.

Próximo passo: extrair o ciclo de intenções para um papel genérico `InimigoCombate`, mantendo a resolução de dano e a interface em `main.gd` durante a transição.

## Inimigo de combate genérico — Task 4 — 23/09/2026

Criado `inimigo_combate.gd` como extensão de `Combatente`. O componente concentra o ciclo determinístico de Rajada, Blindagem, Sobrecarga e Marca, os bônus preparados, o texto da intenção e a lista de danos de uma ação de ataque.

`main.gd` agora recebe a ação de `InimigoCombate.executar_intencao()` e aplica os golpes ao jogador, interrompendo a Rajada quando a Vida chega a zero. O texto visível também vem de `InimigoCombate.texto_intencao()`. Os nomes `intencao_drone`, `bonus_sobrecarga_inimigo` e `_executar_intencao_drone()` permanecem temporariamente como pontes de compatibilidade com o fluxo existente; eles não são a fonte do ciclo.

Teste RED→GREEN: `tests/test_inimigo_combate.tscn` primeiro falhou porque a classe não existia. Depois da implementação, confirmou o ciclo, os valores `3 × 2`, `5 × 2` e `4 × 2`, a preparação e o consumo dos bônus. A regressão dos oito testes e a importação headless da Godot 4.7.2 terminaram com código 0.

Próximo passo: criar a fronteira `ResolucaoCartas`, mantendo Combo e Juntas de Retorno explicitamente no contexto do jogador/personagem.

## Resolução de cartas — Task 5 — 23/09/2026

Criado `resolucao_cartas.gd` sem dependência de `Button`, `Label` ou cena. O componente valida identificador, alvo e Energia; resolve dano, Barreira, Exposto e Enfraquecido sobre `Combatente`; calcula o dano de Quebra-chassi; e retorna os dados do efeito, incluindo custo, dano, Barreira, Combo e estados aplicados.

`main.gd` usa essa fronteira para resolver as cartas e continua responsável pela carta visual, descarte, atualização da interface, Combo como recurso da personagem e ativação de Juntas de Retorno. Nenhuma regra, número, layout ou composição de baralho foi alterado nesta consolidação.

Teste RED→GREEN: `tests/test_resolucao_cartas.tscn` primeiro falhou porque `ResolucaoCartas` não existia. Depois confirmou Golpe, Direto Hidráulico, Brecha, Pulso Debilitante, Quebra-chassi e rejeição de alvo inválido sem criar nós visuais. A regressão final dos nove testes e a importação headless da Godot 4.7.2 terminaram com código 0.

Resultado da etapa: as cinco tarefas do plano de arquitetura foram executadas e verificadas. Isso não encerra a arquitetura completa do projeto: novas extrações só devem ser feitas quando uma responsabilidade concreta justificar a mudança.

## Ofertas de recompensa aleatórias — 23/09/2026

Criado `oferta_recompensa.gd` como objeto `RefCounted` com `opcoes: Array[String]`. A oferta copia e embaralha o pool atual de seis cartas, seleciona três identificadores distintos e não modifica o pool original.

`main.tscn` agora exibe três botões genéricos de recompensa e um botão `Pular`. `main.gd` preenche os três botões a cada vitória que oferece recompensa; escolher uma opção adiciona somente aquela carta ao `baralho_run`, enquanto pular inicia o combate seguinte sem alterar o baralho.

Teste RED→GREEN: `tests/test_oferta_recompensa.tscn` confirmou três opções distintas pertencentes ao pool e preservação do pool original. `tests/test_recompensa_pular.tscn` confirmou que o skip preserva o baralho e a Vida entre combates. A regressão completa dos onze testes e a importação headless da Godot 4.7.2 terminaram com código 0.

Validação manual no editor ainda pendente; o comportamento visual da oferta deve ser conferido pelo usuário.

## Organização inicial da apresentação do combate — 23/09/2026

Adicionados `IntencaoLabel`, `EstadosInimigoLabel`, `AcaoLabel` e `MaoStatusLabel` em `main.tscn`. O botão do inimigo continua sendo o alvo clicável, mas agora mostra somente Vida e Barreira; intenção e estados ficam separados.

`main.gd` registra ações válidas e bloqueadas, incluindo carta jogada, alvo inválido, `SEM ENERGIA`, encerramento de turno e ação executada pelo Drone. A Energia mostra `atual/máxima`, e a mão mostra `atual/limite` com `MÃO CHEIA` quando chega ao limite.

Teste RED→GREEN: `tests/test_apresentacao_combate.tscn` primeiro falhou pela ausência dos quatro elementos visuais. Depois confirmou intenção, estados, última ação, aviso de Energia e limite da mão. A regressão dos doze testes e a importação headless da Godot 4.7.2 terminaram com código 0.

Validação visual final no editor ainda deve ser feita pelo usuário. Próxima frente aprovada: expandir inimigos em geral e incluir um chefe.

## Ajuste de layout da tela — 23/09/2026

Relato do usuário: o screenshot da tela mostrou que o conteúdo do `PilhasLabel` ficava visualmente próximo demais do botão `VEGA`, enquanto os indicadores do jogador começavam desalinhados em relação ao botão.

Alteração feita em `main.tscn`: o bloco de pilhas foi ampliado para acomodar suas duas linhas; o botão `Jogador` foi movido para baixo e recebeu uma área própria; Energia, Barreira, Combo, Relíquia e Vida foram alinhados em uma coluna. Nenhuma regra de combate, carta, intenção, recompensa ou run foi alterada.

Verificação executada com Godot 4.7.2: o teste de apresentação primeiro falhou nas quatro verificações de layout e passou após a alteração. A regressão completa dos 12 testes em `tests/*.tscn` terminou com código 0, assim como a importação do projeto no editor headless.

Validação visual no editor ainda deve ser feita pelo usuário. Próxima frente aprovada: expandir os inimigos usando a fronteira genérica e preparar um chefe.

## Orquestração de jogador e encontro — 24/09/2026

Criados `jogador_combate.gd` e `encontro_combate.gd`. O primeiro concentra Vida/Barreira do jogador, Energia, Combo e ativação por turno de Juntas de Retorno. O segundo concentra inimigo ativo, baralho temporário, turno, condição de encerramento e resolução da fase inimiga.

`main.gd` passou a delegar esses estados e continua responsável por sinais, cartas visuais, atualização da interface, recompensas e fluxo da run. As propriedades legadas permanecem temporariamente como pontes para os testes e serão removidas quando não houver consumidores.

Teste RED→GREEN: `tests/test_jogador_combate.tscn` confirmou persistência limitada da Vida, Energia, Combo máximo, encerramento de turno e ativação única de Juntas. `tests/test_encontro_combate.tscn` confirmou cópia do baralho, reinício do inimigo, condição de encerramento, aplicação da Rajada e interrupção após golpe letal.

Verificação executada com Godot 4.7.2: os 14 testes headless e a importação do editor terminaram com código 0. A validação manual da cena principal permanece necessária.

Próximo passo: especificar o catálogo de três inimigos e a escolha do encontro antes de criar elite, chefe e mapa.

## Catálogo e sorteio de inimigos comuns — 24/09/2026

Criados `dados_inimigos.gd` e `seletor_inimigos.gd`. O catálogo contém Drone de Segurança (30 de Vida), Estivador Cibernético (36), Torreta de Contenção (24) e Guarda Portuário (32). Seus ciclos usam somente ataque, defesa e preparação; as intenções são determinísticas e não mudam depois de anunciadas.

`inimigo_combate.gd` passou a interpretar qualquer ciclo válido do catálogo. `main.gd` sorteia um inimigo ainda não enfrentado antes de iniciar cada combate, registra somente configurações válidas e apresenta nome, Vida, Barreira, intenção e estados a partir do inimigo ativo. Na run atual de dois combates, o segundo inimigo é sempre diferente do primeiro.

As seis cartas atuais foram exercitadas contra os quatro inimigos por `tests/test_cartas_multiplos_inimigos.tscn`. A regressão completa executou 17 cenas de teste com Godot 4.7.2 em modo headless, sem mensagens de erro, e a importação do editor headless também terminou limpa.

Validação manual pendente: executar `main.tscn` mais de uma vez e conferir visualmente os quatro nomes, os ciclos anunciados e executados e a ausência de repetição dentro de cada run. O próximo sistema a implementar depois dessa conferência é o encontro de elite.

## Validação manual do catálogo comum — 24/09/2026

Relato do usuário: os quatro inimigos comuns foram enfrentados no editor. A variedade dos padrões tornou os combates mais dinâmicos. O próximo recorte aprovado para definição é o encontro de elite.

## Elite e recompensas da terceira batalha — 24/09/2026

Implementada a Unidade de Contenção Portuária como elite fixo do terceiro combate. Ela possui 44 de Vida e o ciclo dirigido por dados `Pressurizar → Rajada de contenção → Blindagem pesada → Golpe de pistão`. A Rajada usa danos-base `5 × 2` e, depois de Pressurizar, anuncia e executa `7 × 2`; a Blindagem concede 8 e o Golpe de pistão causa 8.

A run passou de dois para três combates. Os dois primeiros continuam usando o seletor de inimigos comuns sem repetição; o terceiro instancia o elite diretamente e não registra seu identificador no histórico de comuns.

Criado `dados_reliquias.gd` com Juntas de Retorno, Reservatório Auxiliar e Mecanismo de Recuo. `JogadorCombate` agora mantém `reliquias_run`, rejeita duplicatas, aplica Reservatório no início do turno e Mecanismo após uma Finalização, preservando o comportamento da relíquia inicial.

O catálogo de cartas passou a ter nove cartas, com três raras: Golpe de Aríete, Ruptura de Pressão e Placa Reforçada. A recompensa do elite sorteia duas relíquias distintas e três cartas raras distintas. A jogadora escolhe uma relíquia e, em seguida, uma carta rara; não há skip nessa tela e a run só conclui após as duas escolhas.

Arquivos principais alterados: `main.gd`, `main.tscn`, `dados_inimigos.gd`, `dados_cartas.gd`, `dados_reliquias.gd`, `jogador_combate.gd` e os testes de catálogo, resolução, ciclo e apresentação. A nova área de recompensa fica oculta durante o combate e separa visualmente as duas etapas.

Verificação automatizada executada com Godot 4.7.2: 19 cenas em `tests/*.tscn` terminaram com código 0, incluindo a run completa, o catálogo do elite, o catálogo de relíquias, as cartas raras e a interface da recompensa. A importação do projeto em modo editor headless também terminou com código 0.

Validação visual ainda pendente: executar `main.tscn` no editor, vencer os dois combates comuns, conferir as intenções do elite, escolher as duas recompensas e verificar a exibição das relíquias equipadas. Os valores permanecem provisórios; balanceamento não foi realizado.

Próximo passo: validar manualmente este fluxo e, depois, desenhar os encontros não-combate das Docas com base na narrativa aprovada.

## Ritmo intercalado de combates e eventos — 24/09/2026

Direção aprovada pelo usuário: a run expandida terá cinco combates antes do chefe, contando o elite, e quatro eventos intercalados na sequência `combate comum → evento → combate comum → evento → elite → evento → combate comum → evento → combate comum`.

O catálogo inicial terá dez encontros possíveis: quatro combates comuns, o elite atual e cinco eventos narrativos. O catálogo fornece variedade; um roteiro separado define as posições da run. O chefe será uma etapa especial final e não participará do sorteio comum.

Naquele registro, a implementação ainda não havia iniciado. O plano técnico foi criado depois e o estado vigente está resumido no snapshot do topo deste arquivo.

## Correção da troca entre recompensas do elite — 24/09/2026

Relato do usuário acompanhado de screenshot: após escolher a relíquia, o título e os botões de relíquia continuavam visíveis junto das cartas raras. O título de cartas raras também podia aparecer na primeira etapa, fazendo os menus parecerem sobrepostos e invadirem visualmente a mão.

Correção feita: `main.gd` agora controla separadamente o título e o container de cada etapa. A primeira etapa mostra somente relíquias; a segunda esconde completamente relíquias e mostra somente cartas raras; ao concluir, todo o painel é ocultado. `main.tscn` também inicia o título de cartas raras oculto.

Teste RED→GREEN: `tests/test_ciclo_run.tscn` primeiro falhou nos estados de visibilidade esperados e passou após a correção. A regressão dos 19 testes e a importação headless do editor terminaram com código 0.

Pendente: executar novamente a run no editor e confirmar visualmente as duas etapas sem sobreposição.
