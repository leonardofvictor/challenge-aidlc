#!/usr/bin/env bash
# Executado pelo evento postStart do devfile: instala o AI-DLC (versao fixada) para o
# Copilot CLI e avisa se o token faltar. Nunca imprime o valor do token.
#
# Variaveis opcionais (usadas pelos testes):
#   VERSIONS_FILE       caminho de versions.env
#   WORKSPACE_DIR       raiz do projeto (padrao: PROJECT_SOURCE ou a raiz do repositorio)
#   AIDLC_STATE_DIR     onde gravar o marcador de instalacao
#   AIDLC_INSTALL_CMD   executavel chamado como "<cmd> <versao>" no lugar do download
#   AIDLC_BIN           comando aidlc (padrao: aidlc)
#   COPILOT_BIN         comando copilot (padrao: copilot)
set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
VERSIONS_FILE=${VERSIONS_FILE:-$ROOT/workstation/versions.env}
WORKSPACE_DIR=${WORKSPACE_DIR:-${PROJECT_SOURCE:-$ROOT}}
AIDLC_STATE_DIR=${AIDLC_STATE_DIR:-${HOME:-/tmp}/.aidlc-workstation}
AIDLC_BIN=${AIDLC_BIN:-aidlc}
COPILOT_BIN=${COPILOT_BIN:-copilot}
PATH="${HOME:-/tmp}/.local/bin:$PATH"

log()  { printf '[post-start] %s\n' "$*"; }
warn() { printf '[post-start] AVISO: %s\n' "$*" >&2; }

read_version() {
  # Le CHAVE=valor de versions.env sem executar o arquivo.
  sed -n "s/^$1=//p" "$VERSIONS_FILE" 2>/dev/null | head -n 1
}

if [ ! -r "$VERSIONS_FILE" ]; then
  warn "arquivo de versoes nao encontrado: $VERSIONS_FILE. AI-DLC nao sera instalado."
  exit 0
fi

AIDLC_VERSION=$(read_version AIDLC_VERSION)
if [ -z "$AIDLC_VERSION" ]; then
  warn "AIDLC_VERSION nao definido em $VERSIONS_FILE. AI-DLC nao sera instalado."
  exit 0
fi

# 1) Token (FR3.3): avisar sem falhar e sem mostrar o valor.
if [ -z "${GH_TOKEN:-}" ] && [ -z "${GITHUB_TOKEN:-}" ]; then
  warn "token do GitHub ausente (GH_TOKEN/GITHUB_TOKEN). O Copilot CLI nao vai autenticar."
  warn "Crie o Secret copilot-token no seu namespace (workstation/k8s/) e reinicie o workspace."
else
  log "token do GitHub detectado (valor nao exibido)."
fi

# 1b) Copilot CLI: a imagem do devfile e generica (sem Copilot embutido), entao instala
# em ~/.local (gravavel com UID arbitrario) na versao fixada. Pula se ja existir.
if ! command -v "$COPILOT_BIN" >/dev/null 2>&1; then
  COPILOT_CLI_VERSION=$(read_version COPILOT_CLI_VERSION)
  if [ -z "$COPILOT_CLI_VERSION" ] || ! command -v npm >/dev/null 2>&1; then
    warn "Copilot CLI ausente e nao foi possivel instalar (versao ou npm indisponivel)."
  else
    log "instalando Copilot CLI $COPILOT_CLI_VERSION em ~/.local."
    npm install -g --prefix "${HOME:-/tmp}/.local" "@github/copilot@$COPILOT_CLI_VERSION" >/dev/null 2>&1 \
      || warn "instalacao do Copilot CLI falhou. Verifique a rede e rode este script de novo."
  fi
fi

# 2) AI-DLC em versao fixada (FR4.1). Idempotente via marcador.
MARKER="$AIDLC_STATE_DIR/installed"
if [ -r "$MARKER" ] && [ "$(cat "$MARKER" 2>/dev/null)" = "$AIDLC_VERSION" ]; then
  log "AI-DLC $AIDLC_VERSION ja instalado."
  exit 0
fi

log "instalando AI-DLC $AIDLC_VERSION."
if [ -n "${AIDLC_INSTALL_CMD:-}" ]; then
  "$AIDLC_INSTALL_CMD" "$AIDLC_VERSION"
  rc=$?
else
  url="https://github.com/awslabs/aidlc-workflows/releases/download/$AIDLC_VERSION/install.sh"
  tmp=$(mktemp "${TMPDIR:-/tmp}/aidlc-install.XXXXXX") || { warn "mktemp falhou."; exit 0; }
  if curl -fsSL "$url" -o "$tmp"; then
    sh "$tmp"
    rc=$?
  else
    rc=1
  fi
  rm -f "$tmp"
fi
if [ "$rc" -ne 0 ]; then
  warn "instalacao do AI-DLC $AIDLC_VERSION falhou (codigo $rc). Verifique a rede e rode este script de novo."
  exit 0
fi

if ! command -v "$AIDLC_BIN" >/dev/null 2>&1; then
  warn "comando '$AIDLC_BIN' nao encontrado apos a instalacao."
  exit 0
fi
if ! ( cd "$WORKSPACE_DIR" && "$AIDLC_BIN" config --harness copilot --yes ); then
  warn "'aidlc config --harness copilot --yes' falhou."
  exit 0
fi

if mkdir -p "$AIDLC_STATE_DIR" && printf '%s\n' "$AIDLC_VERSION" > "$MARKER"; then
  log "AI-DLC $AIDLC_VERSION instalado e configurado para o Copilot."
else
  warn "nao foi possivel gravar o marcador em $AIDLC_STATE_DIR."
fi
exit 0
