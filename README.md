# challenge-aidlc

Desafio **Battle Knights × AI-DLC**: equipes usam o [AI-DLC da AWS](https://github.com/awslabs/aidlc-workflows) para adicionar música e efeitos sonoros ao jogo Battle Knights, do modo mais leve ao completo. O som é só o pretexto; o objetivo é aprender o método.

- **Roteiro e passo a passo do desafio:** [docs/desafio/roteiro.md](docs/desafio/roteiro.md)
- **Regra comum (lista de eventos do jogo):** [aidlc/spaces/default/memory/project.md](aidlc/spaces/default/memory/project.md), seção `## Mandated`
- **Artefatos gerados pelo AI-DLC:** `aidlc/spaces/default/intents/<intent>/` (versionados; é o que a Fase 4 revisa)

## O que tem aqui

| Caminho | Para que serve |
| --- | --- |
| `docs/desafio/roteiro.md` | Fases 0 a 4, votação no Kahoot, pontuação, rodada interna |
| `aidlc/spaces/default/memory/` | Regras do método e a lista de eventos |
| `scripts/setup-game.sh` | Baixa o jogo (versão fixada) para `game/` |
| `workstation/scripts/` | `post-start.sh` (instala Copilot CLI e AI-DLC), `verify-workstation.sh`, `scan-secrets.sh` |
| `workstation/k8s/` | Exemplo do Secret com o token do Copilot |
| `workstation/versions.env` | Versões fixadas (AI-DLC v2.10.0, Copilot CLI 1.0.91) |
| `devfile.yaml` | Definição do workspace do Dev Spaces (adicionado separadamente pelo time) |

## Sobre o jogo

O Battle Knights é de [mdghayman/battle_knights](https://github.com/mdghayman/battle_knights). O autor não declara licença, por isso o código **não está neste repositório**: o `scripts/setup-game.sh` baixa uma versão fixada (commit `501d582`) e cria uma cópia por equipe em `game/`, já com um repositório git próprio e uma baseline commitada. `game/` está no `.gitignore`.

Se `game/` for apagado junto com o workspace, o trabalho nele se perde. Para guardar, envie `game/` a um repositório **privado** da equipe (não a este).

## Passo a passo: Dev Spaces (free trial)

Usa o [Developer Sandbox for Red Hat OpenShift](https://developers.redhat.com/developer-sandbox) (conta Red Hat gratuita). O repositório é público, então o clone não precisa de credencial.

### 1. Token do Copilot

1. No GitHub, crie um PAT fine-grained com a permissão **Copilot Requests** (a conta precisa de licença do Copilot).
2. Nunca grave o token no repositório. Confira antes de qualquer commit: `bash workstation/scripts/scan-secrets.sh`.

### 2. Secret no seu namespace

O Secret precisa existir **antes** de iniciar o workspace. No Sandbox, seu namespace é `<seu-usuario>-dev`.

1. Copie `workstation/k8s/copilot-token-secret.example.yaml` para **fora** do repositório e troque `<COLE-O-TOKEN-AQUI>` pelo token.
2. Aplique, por uma destas vias:
   - pelo `oc`: no console, **Copy login command**, faça `oc login` e rode `oc apply -n <seu-usuario>-dev -f copilot-token-secret.example.yaml`;
   - pelo console web: botão **+** (Import YAML) no namespace `<seu-usuario>-dev`, colando o YAML preenchido.

### 3. Criar o workspace

1. Abra o Dev Spaces do Sandbox (pelo painel do Developer Sandbox) e escolha **Import from Git**.
2. Informe `https://github.com/leonardofvictor/challenge-aidlc` (o repositório precisa ter o `devfile.yaml` na raiz).
3. Aguarde **Running**. O `postStart` roda `workstation/scripts/post-start.sh`, que instala o Copilot CLI e o AI-DLC e configura o harness do Copilot. Se o token faltar, ele avisa sem interromper.

### 4. Verificar o ambiente

```bash
bash workstation/scripts/verify-workstation.sh
```

Deve mostrar PASSOU para Copilot CLI, token, regras do AI-DLC, pasta `aidlc/` gravável e git. O token nunca é impresso.

### 5. Baixar o jogo e conferir que roda

```bash
bash scripts/setup-game.sh
cd game/battle_knights && python3 MVP.py
```

Deve terminar com `GAME OVER!` e o estado final dos quatro cavaleiros. Rode de dentro de `game/battle_knights/`: o jogo lê `moves.txt` do diretório atual. `python3 run.py` (mesma pasta) mostra o jogo turno a turno, com pausa de 1 s por ação.

### 6. Rodar o desafio

1. No terminal do workspace, rode `copilot`.
2. Siga o [roteiro](docs/desafio/roteiro.md) a partir da Fase 0, invocando `/aidlc` com o pedido de cada fase.
3. Faça commit e push só dos artefatos (o workspace é efêmero):
   ```bash
   git add aidlc && git commit -m "artefatos aidlc" && git push
   ```
   O push exige credencial com permissão de escrita no repositório (o token do Copilot, sozinho, não basta).

### Problemas comuns

| Sintoma | O que fazer |
| --- | --- |
| `verify` falha em "token do GitHub" | Aplique o Secret no namespace correto e reinicie o workspace |
| `verify` falha em "regras do AI-DLC" | Rode `bash workstation/scripts/post-start.sh` e leia os avisos (rede até o GitHub) |
| Copilot CLI não autentica | Token sem **Copilot Requests** ou conta sem licença |
| `setup-game.sh` diz que `game/` já existe | Já foi baixado. Para recomeçar, apague `game/` (perde alterações) |
| `python3: command not found` | A imagem do workspace não traz Python; avise o time (o devfile é do time de plataforma) |
| O estudo do jogo não encontra o código | `game/` está no `.gitignore`; diga à IA o caminho `game/battle_knights/` |

## Testes dos scripts

```bash
bash workstation/tests/run.sh
```
