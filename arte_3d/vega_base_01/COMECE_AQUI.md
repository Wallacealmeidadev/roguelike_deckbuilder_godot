# Primeiro contato com a base 3D

Abra `vega_base_treino_01.blend` pelo Blender: File → Open (Arquivo → Abrir). Não precisa executar o script Python. Se houver outro trabalho aberto e não salvo, salve-o primeiro.

Este é um manequim feminino adulto de estudo anatômico, sem roupa, cabelo ou identidade facial da Vega. Cor cinza de inspeção, não material de pele final. Referência de identidade continua A: `docs/arte_vega/vega_v2_referencia_03.png`. Não avaliar o rosto genérico como nova proposta artística.

## Primeiro exercício — só observar

1. Coloque o mouse sobre a área do modelo e pressione **Espaço**. Um cotovelo dobra e retorna num ciclo de dois segundos.
2. Pressione **Espaço** novamente para parar.
3. Arraste a linha do tempo entre os quadros **1** e **30** para ver o braço aberto e dobrado.
4. Gire a rodinha para aproximar. Segure o botão do meio e mova o mouse para girar a vista. Shift + botão do meio desloca a vista.

Os desenhos coloridos sobre o corpo são controles do rig. Não precisa mover nenhum deles neste primeiro exercício. O objetivo é entender que o corpo é uma malha contínua deformada por um esqueleto, e observar o cotovelo por mais de um ângulo.

Se preferir testar uma mudança simples, altere o quadro final da linha do tempo de 60 para 30: o ciclo passa a cortar o retorno. Depois restaure 60. Use Salvar Como para guardar experiências com outro nome.

## Limites deste teste

- Base MPFB com parâmetros femininos e musculatura moderada, não proporções finais da Vega.
- Rigify humano completo, com metarig conservado e oculto; a geração inclui controles faciais/dedos, ainda não validados individualmente.
- Exercício de flexão de um cotovelo, não guarda, soco, animação final ou prova de todos os pesos.
- Braços humanos temporários; próteses aprovadas ainda não foram modeladas em 3D.
- Arquivo separado do jogo. `.gdignore` impede importação automática desta pasta pela Godot.
- Blender pode indicar que o script de interface do Rigify foi bloqueado. A reprodução do teste foi verificada sem executar esse script; não é necessário liberar scripts globalmente para observar a animação.

## Produção e verificação

Blender local 5.2.3 LTS, MPFB 2.0.18 já instalado, Rigify incluído no Blender. Nenhum download/instalação ou gravação de preferências do usuário. Criado em processo separado com `--background --factory-startup`, por `preparar_base.py`; o script se recusa a sobrescrever o BLEND existente. Não executar em sessão com trabalho aberto.

Geração final exit 0, stderr vazio; rig com 930 ossos totais (mecanismos e deformação incluídos), pesos ligados à malha. Comparação dos quadros 1/30 encontrou 1.956 vértices avaliados deslocados mais de 1 mm. Render `flexao_teste.png` inspecionado visualmente. Reabertura independente exit 0 confirma rotação animada do antebraço 0→65 graus, com script de UI bloqueado. Isso confirma funcionamento básico, não certifica qualidade de toda a anatomia. Primeiro ensaio corrigiu ativação dos complementos no processo isolado; segundo corrigiu API de seleção de ossos nesta versão. Arquivo final foi salvo só após essas correções.

Documentação: [MPFB](https://extensions.blender.org/add-ons/mpfb/), [Rigify no MPFB](https://www.makehumancommunity.org/mpfb/docs/rigging_posing/rigify.html), [licenças MakeHuman](https://www.makehumancommunity.org/about/license.html). Base dos assets centrais CC0; software MPFB GPL. Não foram adicionados assets de terceiros.
