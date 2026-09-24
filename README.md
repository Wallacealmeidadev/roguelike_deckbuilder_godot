# Roguelike Cyberpunk — fontes do projeto

Atualizado em 23/09/2026. Pacote documental 1.0, derivado da revisão 0.4 do design e do relato atual de progresso.

## Uso rápido

Adicione os seis arquivos Markdown deste pacote às fontes do projeto no ChatGPT. No projeto local, os cinco documentos temáticos podem ficar em docs/. O README é o índice deste pacote; não precisa substituir o README técnico existente.

Se já existirem documentos com esses nomes, compare e incorpore as alterações, preservando trabalho mais recente. Este pacote não modifica automaticamente o projeto no seu PC nem os anexos de outras conversas.

Comece novas sessões por STATUS.md e consulte o documento do assunto que será trabalhado. Não é necessário reler todas as regras para uma alteração pequena.

| Arquivo | Fonte de verdade para | Atualizar quando |
| --- | --- | --- |
| [STATUS.md](docs/STATUS.md) | Implementação relatada, evidências e próxima tarefa | Encerrar uma sessão ou verificar comportamento |
| [GAME_DESIGN.md](docs/GAME_DESIGN.md) | Direção, escopo, combate e regras propostas | Aceitar ou revisar uma regra |
| [PERSONAGENS.md](docs/PERSONAGENS.md) | História, aparência e personalidade | Confirmar uma mudança de personagem |
| [MUNDO_E_FINAIS.md](docs/MUNDO_E_FINAIS.md) | Cidade, crise, nomes propostos e finais | Confirmar elementos do mundo ou desfechos |
| [DECISOES.md](docs/DECISOES.md) | Mudanças aceitas, substituições e pendências | Fechar ou reabrir uma decisão |

## O que vale em caso de conflito

- Uma decisão explícita mais recente do usuário atualiza o documento responsável pelo assunto.
- O código atual e seu comportamento observado determinam o que está implementado. STATUS.md é o registro dessa evidência, não um substituto para inspecionar código.
- O design determina o comportamento desejado; uma diferença no código não muda automaticamente a intenção do jogo.
- Sugestões, valores experimentais e itens pendentes não são decisões aceitas nem funcionalidades prontas.
- O documento monolítico Roguelike_Cyberpunk_Regras_v0_1.md, revisão 0.4, é a base histórica desta separação. Ao adotar o pacote, evite deixá-lo como uma segunda fonte vigente. Guarde-o como histórico ou retire-o das fontes ativas.

## Continuidade e forma de trabalho

O objetivo é construir o jogo aprendendo a entender, explicar e manter o código. Trabalhar em etapas pequenas: objetivo, explicação, alteração acompanhada e verificação. Não entregar sistemas inteiros no lugar do usuário sem que ele peça isso.

Antes de mudar o projeto, ler os scripts e a árvore atuais. Não presumir caminhos, versão de engine, arquitetura ou estado de Git. Não substituir o protótipo por outro nem migrar engine sem necessidade e decisão explícita.

Ao final da sessão:

1. Registrar em STATUS.md o comportamento efetivamente observado, pendências e a próxima tarefa.
2. Se houve decisão de design, atualizar o arquivo do assunto e resumir a mudança em DECISOES.md.
3. Manter os mesmos nomes de arquivos; data e histórico registram a evolução.
4. Atualizar as fontes anexadas ao projeto com as novas versões quando necessário. Não pressupor sincronização automática entre o código local e o ChatGPT.

## Limites do pacote

Não contém scripts, arte nem arquitetura verificada. Não houve execução do jogo nesta sessão. Quantidades de cartas, números e tempos herdados são referências de teste; balanceamento e catálogo final estão adiados por decisão do usuário.

O próximo passo registrado é adicionar Vida do jogador, intenção do drone e ataque inimigo ao encerrar o turno.
