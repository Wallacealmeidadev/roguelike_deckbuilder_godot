# Especificacao: arte de corpo inteiro da Vega e preparacao para articulacao

## Objetivo

Substituir a ilustracao provisoria cortada nas coxas por uma arte coerente de corpo inteiro da Vega, mantendo a identidade visual da parte superior que o usuario aprovou. A arte sera criada e organizada no Krita; a Godot so recebera a primeira exportacao depois que a silhueta estatica for aprovada visualmente.

O resultado de sucesso e uma Vega legivel em 1024x576 e 1920x1080, com corpo inteiro, pes apoiados no piso, pose em tres quartos e sem duplicacao de torso ou membros. A animacao articulada e uma segunda etapa, nao um requisito para aprovar a primeira exportacao.

## Estado observado e restricoes

- `vega_animada/vega_playtest.tscn` usa atualmente uma unica ilustracao coerente como desbloqueio do playtest.
- A ilustracao atual termina nas coxas e nao fornece uma base segura para separar pernas ou bracos por aproximacao.
- O rig segmentado anterior foi rejeitado visualmente por sobreposicao de pecas completas; seus pivots nao serao reutilizados como autoridade artistica.
- A caixa de alvo, o HUD, as cartas, regras, custos, dano, turnos, mapa e run estao fora deste trabalho.
- A versao de referencia do projeto e Godot `4.7.2.stable.official.ed1daf0bf`, com renderer `GL Compatibility`.

## Direcao escolhida

Preservar rosto, cabelo, jaqueta e linguagem dos bracos proteticos da ilustracao atual. O corpo inferior sera redesenhado no Krita para completar quadril, pernas e pes, corrigir a silhueta em tres quartos e alinhar o contato com o piso.

A primeira entrega sera uma imagem unica de corpo inteiro em fundo transparente. Depois da aprovacao dessa imagem, o mesmo arquivo mestre sera duplicado para a preparacao de pecas articuladas. A sombra de contato continuara sendo responsabilidade da Godot, para que a arte exportada permaneça reutilizavel em diferentes telas e escalas.

## Pipeline de producao

### 1. Arquivo mestre no Krita

Abrir `ui_hq_v1/assets/personagens/vega_combate.png` como referencia bloqueada e salvar um novo arquivo `.kra`. A referencia original nao sera sobrescrita.

O arquivo mestre tera grupos separados para referencia, corpo final, braco dianteiro, braco traseiro e guias de pivots. A pintura final usara transparencia real e mantera margem suficiente ao redor da silhueta para evitar cortes na exportacao.

### 2. Primeira exportacao: corpo inteiro estatico

Exportar uma PNG RGBA unica, mantendo a escala e a identidade da arte atual. A Godot carregara essa imagem no preview isolado e no campo de combate sem alterar regras ou a caixa de interacao.

Essa etapa sera aprovada somente se:

- o torso for lido como um unico volume;
- a cabeca, quadril e pernas tiverem proporcao coerente;
- os dois bracos forem visiveis sem parecerem duplicados;
- os pes tiverem contato claro com o piso;
- a figura permanecer legivel nas duas resolucoes;
- a sombra da Godot continuar discreta e nao parecer uma segunda base.

### 3. Preparacao das pecas

Somente depois da aprovacao estatica, duplicar o `.kra` e separar as pecas. O corpo central e as pernas permanecem estaticos inicialmente. Cada braco sera exportado com sobreposicao escondida sob a junta:

- braco dianteiro: superior, antebraco e punho;
- braco traseiro: superior, antebraco e punho.

Todas as pecas permanecerao no mesmo canvas e na mesma escala de referencia. Uma camada de guias indicara ombro, cotovelo e punho, mas nao sera exportada. As areas de sobreposicao evitarao frestas quando o cotovelo dobrar.

### 4. Preview isolado na Godot

Criar ou adaptar um preview sem `main.tscn`, HUD ou regras. Primeiro testar uma unica articulacao de cotovelo com o corpo estatico. Conferir repouso, guarda, soco e dano em 1024x576 e 1920x1080.

O segundo braco so sera integrado depois que o primeiro nao apresentar costura flutuante, torso duplicado, escala divergente ou deslocamento de pivot. A integracao final continuara usando `socar()`, `receber_dano()` e `reiniciar()`.

## Fora do escopo

- Nao reativar o rig segmentado rejeitado.
- Nao cortar o atlas antigo para fabricar segmentos.
- Nao redesenhar HUD, cartas, arena ou inimigos nesta etapa.
- Nao introduzir animacao quadro a quadro do Krita.
- Nao alterar regras, balanceamento, custos, dano, progressao ou input.

## Verificacao

Para a primeira etapa, a verificacao sera visual e estrutural:

1. abrir a PNG unica no preview isolado;
2. conferir 1024x576 e 1920x1080 em repouso;
3. conferir contato dos pes, proporcao e ausencia de duplicacao;
4. somente apos aprovacao, exportar as pecas dos bracos;
5. manter testes de composicao e de input sem relaxar expectativas para esconder problemas visuais.

Nenhuma captura automatizada sera tratada como aprovacao artistica final. A aprovacao da silhueta sera um relato manual do usuario no editor.

## Primeiro passo pratico

No Krita: abrir o PNG atual, salvar como um novo `.kra`, bloquear a camada de referencia e criar o grupo de corpo final. A primeira entrega deve ser apenas a extensao coerente do corpo ate os pes; nao iniciar a separacao dos bracos antes de essa imagem ser aprovada.
