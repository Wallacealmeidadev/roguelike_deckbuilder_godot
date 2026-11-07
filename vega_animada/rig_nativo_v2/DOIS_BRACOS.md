# Segunda prótese no rig nativo

21/10/2026 — Godot 4.7.2.stable.official.ed1daf0bf, Compatibility.

Após relatar que a ligação ombro/tronco ficou mais funcional, Wallace autorizou o próximo recorte: segundo braço na prova isolada. Não inclui Combo ou troca do personagem ativo. As duas prévias anteriores permanecem preservadas.

## Conferir no editor

Abra `preview_dois_bracos.tscn`, F6. Compare Repouso, Guarda e Extensão; reproduza o soco e clique novamente durante o movimento. A barra permite conferir os encaixes quadro a quadro. Ver ossos mostra o lado distante em lilás; o primeiro braço continua ciano e a cadeia corporal próxima, amarela. O zoom corta pernas intencionalmente, não é outro personagem incompleto.

Decisão visual: braço distante fica mais escuro e atrás do tronco; tem guarda recolhida perto do rosto enquanto o primeiro golpeia. No repouso ambos baixam. As peças são reaproveitadas e espelhadas com projeção uniforme fixa de 0.92, inclusive a mão; não há escalonamento longitudinal, IK ou aumento durante o golpe. Isso é uma aproximação 2D de profundidade, não arte nova com perspectiva tridimensional correta. A avaliação artística continua com o usuário.

## Arquivos e montagem

- `dois_bracos.tscn`: variante explícita da prova corporal, com os seis canais originais de animação intactos. Acrescenta ClaviculaDistante → DeltoideDistante sob Tronco; encaixe em (410,253). Após o retorno sobre junções, usa `braco_encaixado.tscn` no lado próximo e a variante herdada `braco_distante.tscn` no outro, compensando somente a orientação da mão, sem reconstruir ossos por código. Detalhes em [ENCAIXES.md](ENCAIXES.md).
- `dois_bracos.gd`: reutiliza a interface de poses existente e desativa também o AnimationPlayer interno da segunda prótese. Só o player externo escreve as onze rotações.
- `preview_dois_bracos.tscn/.gd`: reutilizam controles e layout da prova anterior, acrescentando apenas a identificação e o desenho de ossos do lado distante.
- `tests/test_dois_bracos_nativo.gd/.tscn` e `capturar_dois_bracos_nativo.gd`: invariantes e capturas desta etapa.

Clavícula distante em (45,−135) relativamente ao Tronco, deltoide em (45,58) relativamente a ela. Somadas à pelve (320,410) e tronco (0,−80), produzem o encaixe (410,253). A malha foi refinada para 483 vértices/440 faces, mantendo vértices existentes e interpolando seus pesos antes da ligação distante. O novo ombro redistribui apenas a influência local do tronco; pesos antigos do lado próximo, x≤350, ficam preservados. Máximo de quatro influências não nulas por vértice; cada encaixe pertence integralmente ao seu deltoide. Pernas/pés continuam exclusivamente na pelve fixa.

Cinco novos canais: clavícula, deltoide, ombro da prótese, cotovelo e punho distantes. Só rotações em floats; posições/comprimentos/escala não são animados. Chaves editáveis no mesmo AnimationPlayer, com ciclo de 0.56 s e transições capture cubic in-out de 160 ms entre poses/100 ms na reentrada do soco, como a base aprovada. Movimento reduzido interrompe e restaura o repouso. Skill `animate` orientou continuidade/interrupção e preservação dos tempos, sem biblioteca ou pulsação contínua.

O espelhamento inverte o sentido da orientação: as chaves locais do ombro distante compensam a soma das rotações de tronco/clavícula/deltoide. Por isso não se devem copiar os ângulos do primeiro braço diretamente. No repouso distante: ombro 115°, cotovelo 20°; na guarda: ombro 117°, cotovelo 168°. Não é um segundo soco simultâneo.

## Falha visual encontrada e corrigida

Primeiras capturas mostraram punho e anel soltos, apesar de o teste geométrico passar. Causa: z negativo do braço caía abaixo do ColorRect opaco de fundo; partes com z local maior ainda apareciam. Aumentar só o afastamento negativo fez o braço desaparecer completamente. Corrigido o intervalo inteiro de camadas: raiz corporal z=40, braço distante z=−25 relativo, mantendo todas as suas peças acima do fundo e abaixo da pele. Overlay de ossos em z=100. Teste agora verifica essa ordenação para cada Sprite2D, além da geometria. Guarda foi recolhida para separar a mão distante da mão que golpeia; não foram alterados comprimentos para esconder o problema.

## Verificação executada

Novo teste passou headless e OpenGL, fixed-fps 60, exit 0/zero falhas. Confere registro e pesos nativos, quatro influências, âncoras, onze trilhas float só de rotação, chaves/trajetória do primeiro braço, preservação de pesos próximos, 57 amostras sem faces invertidas ou pés deslocados, mão/projeção fixas, camadas, captura em interrupção, reduzido e enquadramento das mãos em 1024×576/1920×1080. A deformação calculada em CPU é apenas oráculo de teste; a apresentação usa skinning nativo na GPU.

Regressões `test_rig_nativo_v2` e `test_ombro_tronco_nativo` passaram headless, exit 0/zero falhas. Sem suíte completa ou playtest do combate nesta etapa. Importação inicial do editor retornou 0, sem erro de parsing, mas manteve avisos de recursos/RID/objetos em uso ao encerrar; testes e capturador encerraram limpos.

Oito screenshots OpenGL em `docs/evidencias_dois_bracos_nativo/`, três poses e intermediária com ossos em duas resoluções. Inspecionados repouso/guarda 1920 e extensão/intermediária 1024 após a correção: dois membros presentes, guarda recolhida, pés apoiados. Vídeo `ciclo_dois_bracos.avi`: log confirma 130 frames, 30 FPS, 1152×648, exit 0, stderr vazio. Vídeo gerado para avaliação do usuário; não equivale a validação artística ou biomecânica final.

Exercício opcional: em `dois_bracos.tscn`, selecione AnimationPlayer → guarda, varie somente a chave de rotação do cotovelo distante em 2° e observe o punho aproximar/afastar do rosto sem mudar de tamanho. Restaure depois. Não altere escala ou posição para corrigir o encaixe.
