# Catálogo e seleção de inimigos comuns

Data: 24/09/2026

Escopo: quatro inimigos comuns nas Docas e seleção sem repetição durante a run atual

## Objetivo

Permitir que cada combate receba um inimigo configurado por dados, sem copiar regras para `main.gd` ou criar uma subclasse para cada oponente.

O catálogo terá o Drone de Segurança já implementado e três novos inimigos comuns. A run atual continuará com dois combates, sorteando um inimigo diferente em cada um. Essa etapa deve provar que o mesmo fluxo de cartas, estados, intenções e encontro funciona com padrões distintos.

## Estado de partida

- `Combatente` concentra Vida, Barreira, Exposto, Enfraquecido e resolução de golpes.
- `InimigoCombate` ainda contém diretamente todas as constantes e o ciclo específico do Drone.
- `EncontroCombate` já recebe um `InimigoCombate`, controla o turno e aplica os golpes da fase inimiga.
- `main.gd` ainda instancia `InimigoCombate.new(30)` e apresenta o nome `DRONE` em textos fixos.
- A run possui dois combates e reinicia ao recarregar a cena.

## Decisões aprovadas

1. O catálogo terá quatro inimigos comuns: o Drone atual e três novos.
2. Cada combate sorteará um inimigo ainda não enfrentado na mesma run.
3. As intenções serão determinísticas. A aleatoriedade decide o inimigo, nunca altera uma ação depois de anunciada.
4. Os novos inimigos usarão somente o vocabulário já existente: ataque simples ou múltiplo, Barreira e preparação de bônus para o próximo ataque.
5. Os valores são provisórios para validar estrutura e variedade; balanceamento não faz parte desta etapa.
6. A implementação será dirigida por dados, sem uma subclasse para cada inimigo e sem transformar cada intenção em um objeto próprio.

## Catálogo aprovado

| Identificador | Nome | Vida | Identidade | Ciclo anunciado |
| --- | --- | ---: | --- | --- |
| `drone_seguranca` | Drone de Segurança | 30 | Equilibrado; preserva o comportamento atual | Rajada `3 × 2` → Blindagem `6` → Rajada → Sobrecarga `+2/golpe` → Rajada → Marca `+1/golpe` → Rajada |
| `estivador_cibernetico` | Estivador Cibernético | 36 | Poucos golpes, mas pesados | Pancada `8` → Postura `7 Barreira` → Preparar `+4/golpe` → Pancada `12` |
| `torreta_contencao` | Torreta de Contenção | 24 | Baixa Vida e ataques com vários golpes | Supressão `2 × 3` → Placas `4 Barreira` → Calibrar `+1/golpe` → Supressão `3 × 3` |
| `guarda_portuario` | Guarda Portuário | 32 | Defesa frequente e dano constante | Investida `6` → Escudo `9 Barreira` → Golpe `7` → Escudo `9 Barreira` |

Ao chegar ao fim da lista, o ciclo volta à primeira intenção. No Drone, a lista armazenada termina em Marca; a Rajada final mostrada na tabela é a primeira intenção depois dessa volta. Isso preserva o comportamento atual sem criar duas Rajadas consecutivas. Os valores mostrados após uma preparação já incluem o bônus. Assim, a Pancada posterior a Preparar anuncia `12`, e a Supressão posterior a Calibrar anuncia `3 × 3`.

## Representação dos dados

Será criado `dados_inimigos.gd`, contendo um dicionário indexado pelos identificadores acima. Cada entrada terá:

```gdscript
{
	"nome": "Drone de Segurança",
	"vida": 30,
	"intencoes": []
}
```

Cada intenção terá um dos três tipos aceitos.

Ataque:

```gdscript
{
	"nome": "Rajada",
	"tipo": "ataque",
	"danos": [3, 3]
}
```

Defesa:

```gdscript
{
	"nome": "Blindagem",
	"tipo": "defesa",
	"valor": 6
}
```

Preparação:

```gdscript
{
	"nome": "Sobrecarga",
	"tipo": "preparacao",
	"bonus_por_golpe": 2
}
```

O nome da intenção é conteúdo de apresentação. O tipo e os valores determinam a execução. Dados do catálogo não serão modificados durante o combate; `InimigoCombate` copiará apenas o estado necessário para a instância atual.

## Responsabilidades

### `dados_inimigos.gd`

- declarar os quatro inimigos;
- fornecer nome, Vida e ciclo;
- permitir consultar uma configuração por identificador;
- rejeitar identificadores ausentes sem criar um inimigo parcial.

### `InimigoCombate`

Passará a receber identificador e dados de configuração. Será responsável por:

- nome e identificador do inimigo atual;
- Vida, Barreira, Exposto e Enfraquecido herdados de `Combatente`;
- índice da intenção atual;
- bônus preparado para o próximo ataque;
- texto da intenção já calculado com bônus e Enfraquecido;
- execução genérica de ataque, defesa e preparação;
- avanço circular do ciclo somente depois da execução válida;
- reinicialização do índice, bônus e estados ao iniciar um combate.

A Barreira anterior continuará expirando no início da ação do inimigo. Um bônus preparado será consumido somente depois do ataque completo. Enfraquecido continuará sendo calculado e consumido separadamente por golpe.

O Drone deixará de ser regra especial dentro dessa classe. Seu comportamento será preservado por sua entrada no catálogo.

### `SeletorInimigos`

Será um componente `RefCounted` responsável por:

- receber os identificadores disponíveis;
- manter os identificadores enfrentados na run;
- montar a lista de candidatos ainda disponíveis;
- sortear um candidato sem modificar o histórico;
- registrar separadamente um identificador depois que o inimigo for criado com sucesso;
- reiniciar seu histórico quando uma nova run começar.

O seletor retornará o identificador. A criação do `InimigoCombate` usará o catálogo e, somente se a instância for válida, o identificador será registrado como enfrentado. Isso mantém seleção, construção e confirmação separadas e diretamente testáveis.

### `EncontroCombate`

Continuará recebendo um inimigo pronto. Sua fase inimiga deixará de procurar especificamente o tipo `rajada` e passará a aplicar qualquer ação de tipo `ataque` que contenha uma lista de danos.

Cada golpe será aplicado separadamente ao jogador, respeitando Barreira e encerrando a sequência se a Vida chegar a zero. Defesa e preparação não causam dano.

### `main.gd`

Continuará orquestrando cena e run. Ele deverá:

- pedir ao seletor o próximo identificador;
- criar o inimigo pelos dados do catálogo;
- entregar o inimigo ao `EncontroCombate`;
- mostrar nome, Vida, Barreira, intenção e estados do inimigo atual;
- registrar a ação executada usando o nome real do inimigo.

Textos e métodos presos ao Drone serão generalizados. `main.gd` não decidirá ciclos, dano, defesa ou preparação de nenhum inimigo.

## Fluxo da run

1. Ao iniciar uma nova run, limpar os identificadores enfrentados.
2. Ao iniciar cada combate, solicitar ao seletor um identificador ainda disponível.
3. Consultar o catálogo e criar um `InimigoCombate` válido.
4. Registrar o identificador como enfrentado somente quando a seleção for válida.
5. Entregar o inimigo e o baralho permanente ao `EncontroCombate`.
6. Reiniciar estado temporário, comprar a mão e anunciar a primeira intenção.
7. Após a recompensa, repetir o fluxo para o segundo combate, excluindo o primeiro inimigo.

Como a run atual tem dois combates e o catálogo tem quatro inimigos, sempre haverá um candidato no fluxo normal. Recarregar a cena cria uma nova run e libera todos os identificadores.

## Falhas e dados inválidos

- Identificador inexistente não cria inimigo.
- Catálogo vazio ou ausência de candidatos retorna vazio, sem repetir silenciosamente.
- Um inimigo sem nome, Vida positiva ou ciclo não é válido.
- Uma intenção com tipo desconhecido, danos ausentes ou valor inválido produz uma ação vazia e não avança o ciclo.
- `EncontroCombate` não causa dano ao receber uma ação vazia ou quando não há inimigo.
- A interface não tenta acessar um inimigo nulo; uma falha de seleção impede o início do combate e registra uma mensagem diagnóstica.

Essas proteções servem para detectar erro de conteúdo. Elas não substituem silenciosamente dados inválidos por valores padrão.

## Interface

O botão do alvo exibirá o nome configurado, seguido por Vida e Barreira. `IntencaoLabel` continuará separado e mostrará a ação completa antes de sua execução. `EstadosInimigoLabel` continuará mostrando Exposto e Enfraquecido do alvo atual.

Não haverá seleção manual de inimigo, arte individual, animações ou alteração ampla de layout nesta etapa.

## Testes

A implementação seguirá RED → GREEN e deverá cobrir:

1. catálogo com exatamente os quatro inimigos e todos os valores aprovados;
2. rejeição de identificadores e configurações inválidas;
3. execução genérica de ataque simples, ataque múltiplo, defesa e preparação;
4. anúncio do dano após preparação e após Enfraquecido;
5. preservação completa do ciclo atual do Drone;
6. sorteio restrito ao catálogo e ausência de repetição na mesma run;
7. retorno vazio quando não houver candidatos;
8. dois combates consecutivos recebendo inimigos diferentes;
9. ataques, Finalização e aplicação de estados funcionando contra cada um dos quatro inimigos;
10. cartas voltadas ao jogador mantendo seus efeitos independentemente do inimigo atual;
11. nome e intenção do inimigo atual aparecendo na interface;
12. regressão completa dos testes existentes.

Depois dos testes, o projeto será importado em modo headless com Godot 4.7.2. A validação visual e a sensação dos números serão feitas no editor e registradas separadamente como relato do usuário.

## Fora de escopo

- balanceamento final;
- inimigos com cura, roubo de Energia, descarte forçado ou estados novos;
- múltiplos inimigos no mesmo encontro;
- subclasses específicas por inimigo;
- Resources individuais para inimigos ou intenções;
- escolha manual do encontro;
- elite, chefe e mapa das Docas.

Após validar os quatro inimigos comuns, a ordem permanece: encontro de elite, primeiro chefe e mapa das Docas.
