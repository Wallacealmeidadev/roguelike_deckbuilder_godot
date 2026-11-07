# Vega nativa no combate

## Palma e alternância — 22/10/2026

Ataques agora alternam próximo/distante, com o braço que não golpeia em guarda. A mão distante usa uma nova vista palmar própria; prévias históricas ficam preservadas. Regras/guarda viva continuam como abaixo. Detalhes, testes, limites, exercício e prompt integral da arte em [PALMA_E_ALTERNANCIA.md](PALMA_E_ALTERNANCIA.md).

## Guarda viva — direção vigente, 22/10/2026

Usuário rejeitou braços baixos e pediu espera em postura de lutadora com respiração. A primeira chave de `respirar.tres` agora reproduz as onze rotações da guarda nativa existente, não uma nova calibração de proporções. Pelve/joelhos ficam na base apoiada. Ciclo de 2.4 s com cinco chaves cúbicas; tronco oscila de 1° a 2.5°, ombros e braços acompanham poucos pixels. Sem translação/escala do personagem inteiro. AnimationPlayer continua sendo o único escritor da pose.

O adaptador copia as onze rotações superiores aos extremos dos clipes privados: ataque/dano partem e retornam à guarda. Tempos/chaves de preparo/impacto/guarda e deslocamentos inferiores do soco não mudam. Reduzido preserva guarda estática e feedback cromático; Combo não controla a postura. Nome interno `repouso` significa espera entre ações, não braços baixos. Acabamento tonal das mãos permanece inalterado nesta revisão.

Integração passou headless/OpenGL na Godot 4.7.2; protege mãos altas em 49 amostras, ciclo contínuo, apoio fixo, movimentos abaixo de 9 px locais e preservação dos clipes intermediários. Quatro regressões headless passaram. Capturas `--guarda-viva`: 34 PNGs e vídeo `guarda_e_cartas.avi` de 317 frames/30 FPS/1152×648 em `docs/evidencias_vega_guarda_viva_22/`. Capturas inspecionadas; vídeo não assistido integralmente. Avisos anteriores de recursos no encerramento persistem; sem suíte completa ou aprovação artística automática.

Exercício pequeno: em F5 compare MOVIMENTO SUAVE e REDUZIDO, esperando um ciclo antes de atacar. Mãos devem continuar altas nas duas opções; apenas o respiro corporal para no reduzido. Volte à sua preferência. Proposta anterior abaixo é histórica e foi rejeitada.

## Histórico: ajuste de repouso rejeitado — 22/10/2026

Após ressalva do usuário, postura relaxada passa a vir das primeiras chaves de `respirar.tres`: ombro/cotovelo próximo 115°/−30°, distante 130°/−5°, punhos sem nova torção. Braços ficam baixos, com flexão menor; comprimento/escala/encaixes permanecem. Ângulo distante deixa o punho fora da coxa, preservando leitura da mão. O adaptador copia somente essas quatro rotações aos extremos de repouso/RESET/soco/dano na biblioteca privada; demais chaves/tempos do soco são comparados com a prévia no teste. Reduzido e reset não voltam à postura antiga.

`metal_maos.gdshader` atenua claros neutros das duas luvas; não recolore as fibras do miolo. Máscara por saturação/luminância mantém escuros e acentos neon, sem alterar alfa/UV. É acabamento tonal, não redesenho nem solução completa de perspectiva/traço. As mãos ainda vêm de outro atlas. Shader só existe na instância ativa; provas originais mantêm material e poses anteriores.

Exercício opcional pequeno: no shader, compare o vetor `metal` atual (0.68, 0.72, 0.80) com (1.0, 1.0, 1.0). Rode F5 e observe apenas o brilho das placas das luvas; o segundo vetor neutraliza a correção. Depois restaure o atual. Não altere escala para compensar o contraste.

Verificação desta revisão: integração headless/OpenGL e quatro regressões headless passaram na Godot 4.7.2. Capturador com `--ajuste-repouso` salva 22 PNGs em `docs/evidencias_vega_repouso_22/`, incluindo quatro detalhes renderizados pelo viewport nativo. Inspecionados repouso/impacto 1920 e repouso 1024; sem novo vídeo ou suíte completa. Avisos de recursos no encerramento de main persistem. Conferir retorno ao repouso e leitura das mãos em F5; ajuste ainda aguarda avaliação artística.

## Conferir

F5 abre o fluxo normal. Inicie uma run e entre em combate: a montagem de `apoio_corporal.tscn` é agora o personagem ativo, não apenas uma prova F6. Ataques alternam dois clipes; Combo real contrai as fibras sem alongar ossos. Após o golpe volta à guarda com respiro. Dano na Vida provoca recuo/flash; dano absorvido não inventa perda de Vida. Mapa/nova run interrompem e zeram a apresentação. Movimento reduzido usa confirmação cromática sem soco amplo.

Exercício pequeno: ative MOVIMENTO REDUZIDO nas configurações, jogue um ataque e compare com MOVIMENTO SUAVE. Energia, dano e Combo devem mudar da mesma forma; só o feedback corporal muda. Depois restaure sua preferência.

## Arquivos e responsabilidades

- `main.gd`: cena exportada de apresentação e chamadas existentes; não aguarda o personagem.
- `vega_combate.tscn/.gd`: adaptador tipado; compõe personagem/sombras, liga estado e escolhe clipes. Não resolve cartas nem inimigos.
- `apoio_corporal.tscn`: rig/pele/poses aprovadas nas provas, sem alteração nesta integração.
- `respirar.tres`: guarda viva num ciclo de 2.4 s com excursão angular de tronco de 1.5° e participação pequena dos ombros/braços, sem transladar/reescalar personagem inteiro.
- `dano.tres`: 260 ms, pequeno recuo do quadril/tronco, guarda e retorno; apoio das botas fixo.

Biblioteca duplicada na instância antes de acrescentar clipes. AnimationPlayer é dono da pose; ComboNativo mantém seu Tween de fibras, sem dois sistemas escrevendo ossos. Captura nativa cubic in-out mantém interrupções; callbacks cromáticos anteriores são cancelados. Sem `_process` para reescrever pele ou resolver IK. A skill `animate` orientou esses limites e o feedback reduzido.

## Composição

As peças usam índices internos altos para sobreposição entre os dois braços e o corpo. CanvasGroup não isolou esses índices no teste real; baixar o índice da raiz ocultou corpo atrás da arena. A solução adotada desenha o rig num SubViewport transparente próprio, dimensionado pelo SubViewportContainer, sem input, com margem transparente de 64 px. A arena recebe um desenho composto, não as camadas internas. Sombra permanece no piso, fora desse desenho, em dois ColorRect com o shader de contato existente; Panel produzia bordas retangulares por seus UVs.

Referência de API consultada: [SubViewportContainer — Godot 4.7](https://docs.godotengine.org/en/4.7/classes/class_subviewportcontainer.html). Viewport local recebe escala/posição do modelo; coordenadas de verificação devem ser convertidas pelo transform do container, não tratadas como globais da arena.

## Evidência e limites

`tests/test_vega_nativa_combate.tscn` verifica a cena padrão, estado real de cartas/Combo/dano, interrupção, reduzido/reset, apoio e recursos isolados. OpenGL acrescenta leitura de pixels: corpo visível e UI z=2 cobrindo-o nas duas resoluções. Headless/OpenGL passaram na Godot 4.7.2. Oito regressões headless passaram; testes específicos do modelo anterior injetam a cena antiga explicitamente e preservam suas asserções. Não executada suíte completa.

`tests/capturar_vega_nativa_combate.gd` gera 18 PNGs ou, com `--filmar`, um ciclo com duas Direto Hidráulico, Quebra-chassi e reação. Evidências em `docs/evidencias_vega_nativa_combate/`; vídeo de 133 frames/30 FPS. Capturas inspecionadas, vídeo não assistido integralmente. Persistem avisos anteriores de recursos/RID/objetos no encerramento de main; não confundir exit 0 com log limpo.

Naturalidade, leitura dos braços e Combo integrado aguardam avaliação manual. Sem nova perspectiva da mão, locomoção, substituição de retrato/cartas/arenas ou aprovação artística automática. Provas anteriores seguem acessíveis e não foram alteradas.
