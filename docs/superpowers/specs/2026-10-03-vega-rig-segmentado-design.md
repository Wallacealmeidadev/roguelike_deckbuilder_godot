# Especificação: rig segmentado da Vega

Data: 03/10/2026  
Status: aguardando revisão do usuário  
Engine alvo: Godot 4.7.2, renderer GL Compatibility

## Contexto observado

`vega_animada/pecas.png` contém recortes isolados de cabeça, torso, duas pernas e braços completos. Os sprites filhos de `Cotovelo` estão ocultos porque os recortes disponíveis para eles também são braços completos; usá-los como antebraços duplica a silhueta.

O rig atual preserva a API de animação, mas não possui articulação visual real de cotovelo. As capturas de guarda e combate mostram uma composição frontal e compacta, enquanto a referência aprovada usa uma pose em três quartos, com ombros em profundidades diferentes, punhos fora do torso, quadril largo e base aberta.

## Objetivo

Criar uma versão segmentada e reversível da Vega com braço superior, antebraço e punho independentes, usando um rig 2D nativo da Godot. A versão deve permitir uma dobra visual convincente do cotovelo sem alterar regras, input, alvo, dano, custo, turno, run, mapa ou arena.

## Fora do escopo

- gerar uma nova personagem por prompt para cada ajuste;
- alterar a referência visual ou o design da Vega;
- alterar a escala global da personagem para compensar recortes ruins;
- modificar `main.gd` além da troca final do recurso da cena, se essa troca for aprovada;
- adicionar IK, física, ragdoll ou animação procedural nesta primeira versão;
- substituir a arte dos inimigos ou do HUD.

## Estratégia de migração

A versão atual continuará preservada como fallback. A nova composição será criada primeiro como uma cena candidata isolada, sem substituir imediatamente a instância usada por `main.tscn`.

Somente depois de a cena candidata passar nos testes estruturais, nas capturas e na inspeção manual em 1024×576 e 1920×1080 ela poderá substituir `vega_animada/vega_animada.tscn` no combate.

## Preparação da arte

O atlas atual será tratado como fonte de referência, não como solução final de articulação. Os segmentos deverão ser exportados como PNGs transparentes independentes para tornar os pivôs e a inspeção claros:

```text
vega_animada/pecas_articuladas/
  braco_superior_frente.png
  antebraco_frente.png
  punho_frente.png
  braco_superior_tras.png
  antebraco_tras.png
  punho_tras.png
```

Os arquivos podem ser derivados dos recortes existentes em um editor de imagem, com limpeza/redesenho local na região da articulação quando necessário. A divisão não deve ser simulada apenas com rotação de um sprite de braço inteiro.

Critérios para cada segmento:

- transparência fora da silhueta;
- nenhuma duplicação de braço ou torso;
- pivô localizado na articulação correspondente;
- união visual sem buraco ou sobreposição evidente na pose de guarda;
- orientação consistente entre braço frontal e traseiro;
- tamanho de textura suficiente para não perder os contornos mecânicos.

## Rig da Godot

A cena candidata usará `Skeleton2D` e `Bone2D`, com sprites filhos dos ossos:

```text
VegaAnimadaSegmentada
└── Modelo
    └── Skeleton2D
        ├── Tronco
        ├── Cabeca
        ├── BracoFrente
        │   ├── BracoSuperiorFrente
        │   ├── AntebracoFrente
        │   └── PunhoFrente
        ├── BracoTras
        │   ├── BracoSuperiorTras
        │   ├── AntebracoTras
        │   └── PunhoTras
        ├── PernaFrente
        └── PernaTras
```

Os nomes públicos necessários para o fluxo atual serão preservados por nós compatíveis ou por referências internas do script. A arte continuará com `mouse_filter` ignorado, permitindo que o botão-pai de Vega receba input.

## Animação

Um `AnimationPlayer` controlará as animações nomeadas:

- `repouso`: respiração curta do torso, cabeça e ombros;
- `guarda`: pose-base de três quartos;
- `soco`: antecipação, extensão do antebraço/punho e retorno;
- `dano`: recuo partindo da pose atual e recuperação;
- `reiniciar`: restauração determinística da pose-base.

O script continuará expondo `socar()`, `receber_dano()` e `reiniciar()`. Essas funções passarão a iniciar animações nomeadas, mantendo `estado_animacao` e as guardas atuais contra ações invisíveis fora do combate.

## Cena de preview

Será criada uma cena isolada para avaliar somente a personagem. Ela deverá permitir visualizar a pose e os pontos de articulação sem carregar a arena, o HUD ou as regras de combate.

O preview terá estados determinísticos para:

- guarda;
- repouso;
- soco;
- dano;
- interrupção de soco por dano.

A inspeção visual dessa cena será a fonte principal para propor mudanças de posição, escala local e pivô. A arena só será usada depois da aprovação da silhueta isolada.

## Contrato de compatibilidade

A nova cena deverá manter:

- o nó raiz instanciável pelo combate;
- `estado_animacao`;
- `socar()`;
- `receber_dano()`;
- `reiniciar()`;
- ignorar input próprio;
- ausência de efeitos sobre Vida, Energia, Barreira, Combo ou dano.

O código de `main.gd` não será refatorado durante a criação do rig. A integração final será uma troca controlada de cena/recurso, acompanhada de regressão da composição do combate.

## Verificações

O teste focado da Vega deverá verificar:

- existência do `Skeleton2D` e dos ossos essenciais;
- um sprite independente para braço superior, antebraço e punho em cada lado;
- pivôs em posições coerentes;
- ausência de sprites antigos de braço completo empilhados;
- separação dos punhos e abertura da base;
- cabeça deslocada em relação ao eixo do torso;
- proporção mínima do torso em relação à cabeça;
- pés alinhados ao piso e separados;
- transições `repouso → soco → repouso`;
- transições `repouso → dano → repouso`;
- interrupção de soco sem salto para uma pose incorreta;
- ausência de alteração no custo, dano, alvo ou input.

Também serão geradas capturas Compatibility do preview e do combate em 1024×576 e 1920×1080. Capturas automatizadas serão consideradas evidência de apresentação; a aprovação visual final continuará dependendo do playtest manual no editor.

## Critérios de aceitação

A implementação será considerada pronta para integração quando:

1. o cotovelo puder dobrar visivelmente sem duplicar o braço;
2. a pose de guarda tiver leitura clara em três quartos;
3. os punhos ficarem fora da massa do torso;
4. a personagem não parecer uma coluna frontal nem um corpo sobreposto;
5. soco e dano puderem ser interrompidos e recuperados a partir da pose atual;
6. a API existente e a suíte de combate permanecerem verdes;
7. o usuário aprovar a leitura em janela real nas duas resoluções.

## Riscos e decisões explícitas

- Se os braços atuais não puderem ser separados sem arte quebrada, será necessário redesenhar somente as regiões dos braços; não será permitido esconder a falha com escala ou rotação global.
- A cena candidata será mantida separada até a validação visual, evitando quebrar o combate funcional.
- IK e ferramentas externas de animação ficam adiadas porque não resolvem a segmentação da arte e aumentariam o número de variáveis.
- O renderer Compatibility será usado nas capturas para manter a evidência próxima do ambiente do usuário.
