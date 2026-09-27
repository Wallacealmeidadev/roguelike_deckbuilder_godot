# UI HQ Cyberpunk — primeira versão

Kit visual do jogo, independente de distrito ou personagem. Vega e Drone continuam representados por quadrados nas referências de combate. Este pacote não altera o seu projeto nem contém a lógica da run.

## Comece aqui

1. Extraia o ZIP.
2. Abra `catalogo.html` no navegador para explorar telas e componentes.
3. Para usar os assets, copie a pasta inteira `ui_hq_v1` para a raiz do projeto Godot. O caminho deve ser `res://ui_hq_v1/`.
4. Leia `docs/GUIA_CODEX.md` antes de integrar.

## Conteúdo

- **14 referências de telas/estados**: menu, combate, recompensa, derrota, evento, descanso, pausa, configurações, conclusão da run, baralho, mapa, recompensa de elite, aprimoramento e histórico da derrota.
- **43 componentes individuais `.tres`**: 20 ícones, 8 controles, 9 peças de HUD, 3 molduras de cartas e 3 ilustrações.
- **5 atlas PNG** originais: as imagens compartilhadas pelas peças. Os arquivos `.tres` já especificam os recortes; não é necessário recortar manualmente.
- **1 fundo** sem textos, botões ou personagens.
- **1 tema base e 7 estilos** para controles da Godot.
- **Fontes** Bangers e Barlow Semi Condensed, com suas licenças OFL.
- **Manifesto** com caminhos, regiões e tamanhos sugeridos.

Os componentes são recursos separados, e não 43 PNGs independentes. Mantenha os atlas na pasta: os `.tres` dependem deles.

## O que é referência e o que é utilizável

`referencias/telas/` contém composições estáticas. Elas orientam a montagem; não são telas interativas prontas nem devem virar uma imagem única por trás de botões invisíveis.

`componentes/`, `assets/`, `fontes/`, `estilos/` e `tema_base.tres` são as peças para a integração. Textos, valores, efeitos e transições devem continuar ligados aos dados do jogo.

As quatro últimas referências demonstram a montagem com os próprios componentes e fontes. As primeiras dez são estudos ilustrados; por isso, traços, proporções e lettering não são idênticos em todos os exemplos. O catálogo de componentes é a base concreta da primeira implementação.

## Limites desta versão

- O conteúdo do evento é demonstrativo.
- `Relíquia 02` é um espaço de exemplo, não uma nova relíquia definida.
- O exemplo `Golpe 6 → 9` demonstra a comparação de aprimoramento; não determina o balanceamento. Usar os valores reais do projeto.
- O nó de chefe no mapa reserva o ponto final já decidido; a luta do chefe continua fora desta entrega.
- Não há novos sprites, animações, diálogos do chefe, sistemas de salvamento ou lógica de configurações.
- A integração e a verificação visual na versão do seu projeto ainda devem ser feitas.

## Verificação

Os 43 AtlasTextures, seus limites de recorte, o tema e as fontes foram carregados em **Godot 4.5.1**, em um projeto isolado. Isso verifica a leitura dos recursos; não substitui a integração no projeto do usuário, cuja versão e cenas atuais não foram executadas aqui.

As referências também foram verificadas como imagens completas. Veja `docs/VALIDACAO.md`.

