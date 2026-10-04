# Desafio Battle Knights × AI-DLC: roteiro e passo a passo

Fonte: [resumo para o organizador](../../Desafio%20Battle%20Knights%20×%20AI-DLC%20resumo%20para%20o%20organizador.md) e o guia final (Claude Docs). Este documento junta os dois em um roteiro executável. Para preparar o ambiente (Dev Spaces, token do Copilot, `verify-workstation.sh`), siga o [README](../../README.md) e o [guia da workstation](../workstation/guia.md).

## 1. Visão geral

- **O que é:** de 6 a 8 equipes (3 a 6 pessoas cada) usam o AI-DLC para adicionar música e efeitos sonoros ao jogo **Battle Knights** (Python, roda em texto, uma jogada por vez), usando o **Tone.js** (música no navegador).
- **Objetivo real:** aprender o método, do modo mais leve ao completo. O som é só o pretexto.
- **Duração:** 4 dias. Antes disso, uma rodada interna de 2 dias valida as regras.
- **Por que funciona:** jogo (Python) e Tone.js (navegador) não se encaixam sozinhos. A equipe precisa decidir como ligá-los, e é exatamente a etapa que os modos curtos pulam.

### Regras gerais (valem do início ao fim)

1. Cada equipe trabalha na própria cópia do jogo.
2. Ninguém edita à mão o andamento ou o histórico do método (`aidlc-state.md`, registro de auditoria). Toda mudança de caminho passa pelo próprio método.
3. Toda decisão importante passa por um ponto de aprovação (gate), não por conversa paralela com a IA.
4. Facilitadores não respondem o que a IA consegue descobrir estudando o jogo.
5. A lista de eventos é a única regra técnica imposta; a forma de construir é livre.

## 2. Preparação (antes do dia 1)

### 2.1 Checklist do organizador

- [x] Licença do jogo: o autor não declara licença, então o código **não é copiado** para este repositório; cada equipe o baixa com `scripts/setup-game.sh` (versão fixada). Para uso fora do workshop, peça licença ao autor
- [x] Pausa entre as jogadas: `run.py` (versão ASCII) pausa 1 s por ação (`sleep(1)` em `process.py`); `MVP.py` não pausa e roda tudo de uma vez
- [x] Versão do AI-DLC: v2.10.0, fixada em `workstation/versions.env` e instalada pelo `post-start.sh`
- [ ] Confirmar se o plano do Kahoot aceita 4 ou 5 respostas
- [ ] Confirmar o nome do ritual: Mob Inception ou Mob Elaboration (nome usado pela AWS)
- [x] Lista de eventos escrita como regra em `aidlc/spaces/default/memory/project.md` (seção `## Mandated`)
- [ ] Escolher o padrão da Diretoria usado na Fase 4
- [ ] Definir um facilitador por equipe
- [ ] Fazer a rodada interna (seção 4) e ajustar tempos e pontuação

### 2.2 Preparação por equipe

1. Criar o workspace no Dev Spaces a partir deste repositório (README, passos 2 e 4). Cada equipe tem o próprio workspace, portanto a própria cópia do jogo.
2. Aplicar o Secret com o token do Copilot no namespace de cada pessoa (README, passo 3) antes de iniciar o workspace.
3. Rodar `bash workstation/scripts/verify-workstation.sh` e confirmar PASSOU em todos os itens.
4. Baixar o jogo com `bash scripts/setup-game.sh` (cópia definitiva em `game/`). As fases 0 e 1 usam cópias descartáveis (seções abaixo).
5. Distribuir o número da equipe (ex.: E1 a E8), usado no Kahoot.

## 3. As cinco fases, passo a passo

Cada fase acrescenta uma ideia nova. Em todas, o ciclo é o mesmo: `/aidlc` pergunta, a equipe responde, a IA produz, a equipe aprova ou pede ajuste no ponto de aprovação.

| Fase | Dia | Modo | Pedido à IA | Regra da fase | Concluída quando |
| --- | --- | --- | --- | --- | --- |
| 0 · Primeiro som | 1 | `express` | Tocar um som quando um cavaleiro cai na água | Cópia descartável; só observar como o método trabalha | A equipe explica onde o método mostra em que etapa está |
| 1 · Mesmo pedido, caminho maior | 1 | `poc` | O mesmo pedido da Fase 0 | Pelo menos um pedido de ajuste (Request Changes) na etapa de requisitos | A equipe compara os dois caminhos e lê o que a IA aprendeu sobre o jogo |
| 2 · Mob Inception | 2 | `classic`, planejamento | Música de fundo e efeitos sonoros completos | Votar no Kahoot a forma de ligar jogo e música e registrar o resultado no ponto de aprovação | Solução dividida em pelo menos 2 partes e lista de eventos aprovada |
| 3 · Mob Construction | 3 | `classic`, construção | Continuação do mesmo projeto | Aprovar o plano antes de a IA escrever código e retomar o projeto sozinha no dia seguinte | Cada requisito pode ser seguido até um teste que o comprova |
| 4 · Revisar | 4 | nenhum pedido novo | Outra equipe reconstrói o trabalho só pelo registro de auditoria | Um padrão da Diretoria configurado de duas formas: regra e material de referência | A equipe revisora conta corretamente o que foi decidido |

> Dica: `/aidlc --status` mostra a etapa atual e `/aidlc --doctor` valida a instalação.

### Fase 0 · Primeiro som (`express`)

1. Baixe uma cópia descartável do jogo: `bash scripts/setup-game.sh game-f0` (nada desta fase vai para o trabalho final).
2. Abra o `copilot` no terminal do workspace.
3. Rode `/aidlc` pedindo o modo `express` e a descrição: *"Tocar um som quando um cavaleiro cai na água"*.
4. Acompanhe as etapas e aprove cada uma. Anote **onde o método mostra em que etapa está** (estado e registro de auditoria).
5. Ao final, a equipe explica em voz alta como localizou a etapa atual.

### Fase 1 · Mesmo pedido, caminho maior (`poc`)

1. Baixe outra cópia descartável: `bash scripts/setup-game.sh game-f1`.
2. Rode `/aidlc` no modo `poc` com **exatamente o mesmo pedido** da Fase 0.
3. Na etapa de requisitos, **faça pelo menos um pedido de ajuste** (Request Changes), explicando o que precisa mudar. Não aceite de primeira.
4. Leia o artefato do estudo do jogo (Reverse Engineering) que o modo maior incluiu.
5. Compare Fase 0 × Fase 1: quantas etapas, o que a IA aprendeu sobre o jogo, o que mudou no resultado.

### Fase 2 · Mob Inception (`classic`, planejamento)

Ritual em grupo: a equipe inteira, junto com a IA, define o que será construído e vota as decisões principais.

1. Use a cópia **definitiva** do jogo da equipe (`game/`, baixada no preparo). Rode `/aidlc` no modo `classic` com o pedido *"Música de fundo e efeitos sonoros completos"*, testes no nível mínimo.
2. Deixe a IA estudar o jogo e **descobrir a lista de eventos**. Compare com a lista inicial (seção 5) e registre as diferenças.
3. **Votação no Kahoot** (seção 6): vote a forma de ligar jogo e música (opções A a E).
4. Registre no AI-DLC, como resposta no ponto de aprovação, **a opção vencedora e a contagem de votos**. Só assim a decisão entra no registro de auditoria.
5. Aprove os requisitos, as histórias e o desenho, garantindo:
   - solução dividida em **pelo menos 2 partes**;
   - **lista de eventos aprovada**.
6. Faça commit e push dos artefatos (`git add aidlc && git commit && git push`). O workspace é efêmero.

Atenção a requisitos de tempo: se o jogo passa as jogadas sem pausa, acompanhar o ritmo é requisito, não detalhe de código.

### Fase 3 · Mob Construction (`classic`, construção)

Ritual em grupo: a equipe acompanha a IA construir e testar, aprovando etapa por etapa. Acontece no dia seguinte, então a equipe **retoma o projeto sozinha**.

1. Abra o workspace, faça `git pull` e rode `copilot`. Use `/aidlc` para retomar do último checkpoint (o método oferece retomar pelo `aidlc-state.md`). Não edite o estado à mão.
2. **Aprove o plano de código antes de a IA escrever qualquer código.**
3. Acompanhe a geração de código e os testes. Como não dá para testar som ouvindo, os testes conferem **quais sons foram disparados**, o que obriga a separar a lógica do jogo da saída de áudio.
4. Se escolheu as opções A ou B, espere o problema do navegador só tocar som após um clique da pessoa: transforme em pedido de ajuste claro.
5. Confira a rastreabilidade: cada requisito deve levar a um teste que o comprova (relatórios de rastreabilidade e de testes).
6. Confirme que os testes respeitam a lista de eventos.
7. Commit e push dos artefatos e do código.

### Fase 4 · Revisar

1. Cada equipe entrega à equipe revisora **somente o registro de auditoria** (`aidlc/spaces/default/intents/<intent>/audit/`).
2. A equipe revisora reconstrói o que foi decidido: opção votada e contagem, pedidos de ajuste, aprovações, lista de eventos.
3. A equipe dona confere a reconstrução (vale +20 pontos se estiver correta).
4. Cada equipe configura **um padrão da Diretoria de duas formas**: como **regra** (`aidlc/spaces/default/memory/`, por exemplo `project.md`) e como **material de referência** (`aidlc/spaces/default/knowledge/`). Compare o efeito das duas.
5. Feche com a conversa final: comparar as formas escolhidas por cada equipe (A a E), a lista descoberta × a inicial e as decisões reais.

## 4. Rodada interna de teste (2 dias)

Uma equipe de 4 pessoas (2 técnicas, 1 não técnica, 1 observadora que cronometra e anota onde trava) roda o desafio inteiro. O organizador conduz como no workshop e faz o papel de equipe revisora na Fase 4. Mesmo repositório, versão do AI-DLC e conta do Kahoot do workshop.

| Momento | O que roda |
| --- | --- |
| Dia 1, manhã | Fases 0 e 1 |
| Dia 1, tarde | Fase 2, Mob Inception, com votação real no Kahoot |
| (noite) | Mantida de propósito: retomar o projeto é parte do teste |
| Dia 2, manhã | Fase 3, Mob Construction, retomando o projeto da véspera |
| Dia 2, tarde | Fase 4 e retrospectiva de 45 minutos (manter, mudar, tirar) |

### Critérios para seguir

| O que validar | Como medir | Critério |
| --- | --- | --- |
| Tempo de cada fase | Observadora cronometra | Nenhuma passa mais de 20% do previsto |
| Linguagem para quem não é técnico | Pessoa não técnica explica cada fase | Explica sem ajuda em todas |
| Dificuldades previstas | Observadora marca quando surgem | Pelo menos 3 das 4 aparecem sem intervenção |
| Placar pelo registro de auditoria | Organizador calcula só pelo registro | Fechado em até 15 minutos |
| Votação no Kahoot | Pergunta real, conta do workshop | Voto por equipe no relatório exportado |
| Decisão votada no AI-DLC | Conferir auditoria após a Fase 2 | Opção e contagem aparecem no registro |

Resultado: todos atendidos, o desafio segue como está; um ou dois falham, ajuste a regra e siga; três ou mais, faça outra rodada interna.

## 5. Lista de eventos inicial

Primeira versão da lista comum, tirada do manual do jogo. A IA deve confirmá-la ao estudar o jogo; comparar as duas versões é assunto da conversa final. A coluna de som é só sugestão.

| Evento | O que acontece no jogo | Som sugerido |
| --- | --- | --- |
| Início da partida | O jogo mostra o tabuleiro e os itens | Tema de abertura |
| Movimento | Um cavaleiro anda uma casa | Passo curto |
| Queda na água | Um cavaleiro sai do tabuleiro e se afoga | Som descendente |
| Pegar item | Um cavaleiro encontra um item na casa | Notas rápidas subindo |
| Largar item | Um cavaleiro descarta o item de menor valor | Uma nota grave |
| Ataque | Um cavaleiro entra na casa de outro | Batida forte; a música muda para combate |
| Derrota | Um dos cavaleiros perde o combate | Acorde triste |
| Fim da partida | O jogo mostra o resultado final | Tema de encerramento |

Música de fundo: três climas bastam (exploração, combate e encerramento).

Esta lista já está gravada como **regra configurada** em `aidlc/spaces/default/memory/project.md` (seção `## Mandated`), com os identificadores `GAME_START`, `MOVE`, `DROWN`, `PICK_UP`, `DROP_ITEM`, `ATTACK`, `DEFEAT` e `GAME_END`. O método obriga a IA a respeitá-la e a levar qualquer diferença com o código do jogo a um ponto de aprovação.

## 6. Votação no Kahoot (Fase 2)

**Pergunta** (74 de 120 caracteres): *Mob Inception: como a sua equipe vai ligar o jogo Battle Knights à música?*

| Opção | Resposta no Kahoot (máx. 75 caracteres) | Risco principal |
| --- | --- | --- |
| A | Ligar as peças: o jogo avisa os eventos e uma página toca a música | Duas peças rodando ao mesmo tempo |
| B | Levar à web: reescrever o jogo para rodar no navegador | Refazer o jogo inteiro |
| C | Gravar antes: a música vira arquivos e o jogo só os toca | A música perde a variação |
| D | Python no navegador: rodar o jogo na página sem reescrevê-lo | Página pesada e a tela de texto precisa mudar |
| E | Música à parte: o Tone.js roda num programa separado do jogo | Uso experimental: o Tone.js foi feito para o navegador |

Conforme o plano do Kahoot:

- **5 respostas:** use as cinco opções, no tipo Enquete.
- **4 respostas:** tire a opção E.
- **Sem tipo Enquete:** use Quiz com todas as respostas marcadas como certas e sem pontos.

### Condução

1. O facilitador apresenta cada opção em 1 minuto, sempre com o risco principal.
2. Cada pessoa entra com o número da equipe antes do nome (ex.: `E3 Ana`), para o relatório mostrar o voto por equipe.
3. A votação fica aberta por 90 segundos.
4. Cada equipe registra no AI-DLC a opção vencedora e a contagem de votos como resposta no ponto de aprovação.
5. O voto é separado por equipe, não da sala inteira: preserva a comparabilidade e o contraste entre decisões.

## 7. Dificuldades previstas

| Dificuldade | Quando aparece | O que ensina |
| --- | --- | --- |
| O navegador só toca som após um clique | Testes, nas opções A ou B | Escrever um pedido de ajuste claro a partir de um problema real |
| `MVP.py` passa as jogadas sem pausa (`run.py` pausa 1 s por ação) | Requisitos de tempo e desempenho | Acompanhar o ritmo do jogo é requisito |
| Não dá para testar som ouvindo | Construção e testes | Separar a lógica do jogo da saída de áudio |
| O repositório do jogo não mostra licença | Antes da Fase 0 | Verificar a licença antes de trazer código de terceiros (por isso o jogo é baixado, não copiado) |

## 8. Pontuação

O placar sai do registro de auditoria. Premia o comportamento, não a velocidade. Valores iniciais, a ajustar na rodada interna.

| Comportamento | Pontos | Onde conferir |
| --- | --- | --- |
| Pedido de ajuste resolvido na rodada seguinte | +10 por etapa | Registro de auditoria |
| Aceitar um resultado sem aprová-lo de verdade (Accept as-is) | −15 por uso | Registro de auditoria |
| Requisito que pode ser seguido até um teste | +5 por requisito | Relatórios de rastreabilidade e de testes |
| Lista de eventos respeitada nos testes | +20 | Relatório de testes |
| Equipe revisora que reconstrói corretamente o trabalho de outra | +20 | Conferido pela equipe dona do trabalho |

## 9. Decisões do organizador

| Decisão | Recomendação | Custo |
| --- | --- | --- |
| Forma de construir | Lista de eventos fixa, construção livre | Resultados mais difíceis de comparar |
| Modo das fases 2 e 3 | `classic`, testes no nível mínimo | Nenhum relevante; o modo `workshop` só somaria etapas de publicação e operação |
| Lista de eventos | Descoberta pela IA e conferida com a lista inicial | Cerca de meia hora a mais |
| Jogo das equipes | O mesmo jogo, uma cópia por equipe | Nenhum relevante |

## 10. Pontos ainda pendentes

| Ponto | Onde aparece | Status |
| --- | --- | --- |
| Licença de uso do jogo | Antes da Fase 0 | Tratada: jogo baixado, não redistribuído |
| Pausa entre as jogadas | Fases 2 e 3 | Confirmada: `run.py` 1 s, `MVP.py` nenhuma |
| Versão do AI-DLC instalada | Todas | Confirmada: v2.10.0 |
| Limite de respostas do Kahoot (4 ou 5) | Fase 2 | Pendente |
| Nome do ritual (Mob Inception ou Mob Elaboration) | Glossário e Fase 2 | Pendente (decisão do organizador; o guia usa Mob Inception) |
| Valores da pontuação | Fase 4 | Pendente |
| Tempo de cada fase | Todas | Pendente |

## Glossário

| Termo | Significado |
| --- | --- |
| AI-DLC | Método da AWS em que uma IA conduz o desenvolvimento em etapas e uma pessoa aprova cada uma |
| Modo (scope) | Tamanho do caminho: `express` e `poc` são curtos; `classic` é completo |
| Ponto de aprovação (gate) | Fim de cada etapa, onde a equipe aprova ou pede ajustes |
| Pedido de ajuste (Request Changes) | Recusar o resultado de uma etapa explicando o que mudar |
| Estudo do jogo (Reverse Engineering) | Etapa em que a IA lê e entende o jogo antes de mexer nele |
| Registro de auditoria (audit) | Histórico automático de tudo o que foi decidido, quando e por quem |
| Regra configurada (rule) | Instrução permanente que o método obriga a IA a seguir |
| Lista de eventos | Acontecimentos do jogo que disparam um som, iguais para todas as equipes |
| Mob Inception | Planejamento em grupo com a IA; na AWS aparece como Mob Elaboration |
| Mob Construction | Construção em grupo: a equipe acompanha a IA construir e testar, aprovando etapa por etapa |
