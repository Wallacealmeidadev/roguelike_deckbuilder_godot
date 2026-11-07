# Vega — primeiro figurino 3D

Abra `vega_figurino_04.blend` no Blender. Esta revisão veste o corpo 03 aprovado; é uma primeira passagem de volumes, não o acabamento HQ final.

## O que avaliar

- Regata carvão fechada, com alças largas e barriga coberta.
- Calça grafite com folga e afunilamento nas botas, sem bolsos de carga.
- Camisa vinho amarrada na cintura, com painel traseiro e duas mangas pendentes.
- Botas foscas com sola e cadarços simplificados.

O corpo permanece um manequim: o rosto não é a identidade final da Vega; cabelo e próteses ainda não foram modelados. A referência de figurino é `docs/arte_vega/vega_v2_referencia_04.png`, e a identidade continua sendo a referência A/03.

## Como olhar

1. Abra o arquivo. A visão inicia em três quartos, sem os controles cobrindo a roupa.
2. Arraste com o botão do meio do mouse para girar a vista. A roda aproxima/afasta.
3. Pressione **Espaço** para reproduzir/parar o mesmo exercício de cotovelo dos arquivos anteriores. Quadros 1 e 30 mostram repouso/flexão.
4. **F12** renderiza a câmera preparada; **F11** alterna a visualização da renderização.

As peças estão na coleção `04_FIGURINO | pecas editaveis` no Outliner (lista de objetos à direita). Os prefixos 01/02/03/04 agrupam regata/calça/camisa/botas. Os cadarços são objetos separados nesta fase, para ajuste simples.

### Pequeno exercício

Na lista de objetos, localize `03_CAMISA | costas e abas`. Clique no **olho** ao lado dela para ocultar só o painel traseiro, observe como muda a silhueta e clique novamente para restaurar. Se o olho não aparecer, habilite a coluna de visibilidade no filtro do Outliner. Não é preciso apagar ou editar vértices.

Salve suas experiências com **Salvar como**, usando outro nome, para conservar esta revisão.

## Imagens locais

- `comparacao.png`: corpo 03 à esquerda, figurino à direita, mesma câmera.
- `figurino_frente.png`, `figurino_tres_quartos.png`, `figurino_costas.png`: vistas de revisão.
- `figurino_flexao.png`: exercício de cotovelo.
- `teste_perna.png`: pequeno deslocamento do pé, executado apenas na verificação; não é uma animação nova salva.

## Limites e preservação

As roupas têm espessura, suavização e pesos vinculados ao Rigify existente. Ainda precisam de acabamento de costuras/dobras e revisão em guarda e golpes. A camisa acompanha os ossos por pesos; não há simulação de tecido ou movimento secundário final.

A geometria e todas as shape keys do corpo 03 foram preservadas e comparadas na reabertura. Nesta cópia vestida, um modificador de máscara oculta a pele coberta pela calça; nenhum vértice foi apagado. A fonte 03 e as revisões anteriores permanecem intactas. A pasta `arte_3d` continua isolada da importação Godot; nada mudou no F5.

`montar_figurino.py` registra a construção nativa. `conferir.py` abre fonte e resultado, compara a anatomia, confere pesos e verifica cotovelo/um pequeno movimento de perna. Esses testes não equivalem a aprovação artística nem certificam poses extremas. Não execute o gerador sobre uma revisão que você editou; ele recusa sobrescrita por padrão.
