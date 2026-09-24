# Colaboração no projeto

## Objetivo

Ajudar Wallace a construir e compreender seu próprio jogo. Trabalhar em parceria, com etapas pequenas. A velocidade de gerar código não é a medida principal de progresso.

## Antes de propor mudanças

- Ler docs/STATUS.md e docs/DECISIONS.md.
- Ler os arquivos atuais envolvidos e a regra correspondente em docs/GAME_DESIGN.md.
- Conferir a versão da Godot registrada antes de usar APIs e documentação.
- Separar explicitamente estado observado, regra de design e hipótese.
- Se não houver acesso ao código necessário, pedir os arquivos específicos. Não inventar métodos, nós, caminhos, erros ou resultados.
- Não prometer memória perfeita entre conversas. Este arquivo só orienta ferramentas e assistentes que o tenham lido.

## Como executar

- Tratar um objetivo por vez, com resultado observável.
- Explicar o conceito, o motivo e os arquivos envolvidos antes de um trecho novo.
- Priorizar o usuário operando o editor e entendendo pequenas mudanças.
- Não gerar sistemas inteiros ou refatorações amplas enquanto o usuário está aprendendo uma peça.
- Não delegar automaticamente a subagentes: o método escolhido é acompanhado nesta conversa.
- Mostrar o que verificar e como interpretar erros. Não mudar regras de jogo silenciosamente para contornar um bug.
- Usar GDScript tipado. Manter regras, estado e apresentação com responsabilidades claras, sem arquiteturas adicionais antes de haver necessidade.
- Manter PC como foco atual. Não adicionar backend, multiplayer ou monetização sem uma necessidade discutida.
- Consultar documentação oficial compatível com a versão quando houver dúvida de API.

## Ao encerrar

- Relatar o que mudou, por que mudou e qual verificação foi realmente executada.
- Registrar os resultados em docs/STATUS.md. Um relato do usuário deve ser identificado como relato; screenshots e logs devem ser descritos.
- Registrar mudanças de direção em docs/DECISIONS.md e atualizar o design quando necessário.
- Não marcar o jogo, uma funcionalidade ou um teste como concluído apenas porque o código foi escrito.
- Sugerir uma pequena modificação que o usuário consiga realizar para exercitar o conceito.
