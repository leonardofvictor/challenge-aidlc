#!/usr/bin/env bash
# Roteiro de verificacao (FR6.1): resultado passou/falhou por item. Nunca imprime o token.
#
# Variaveis opcionais: COPILOT_BIN, WORKSPACE_DIR, AIDLC_DIR, AIDLC_STATE_DIR.
set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
COPILOT_BIN=${COPILOT_BIN:-copilot}
WORKSPACE_DIR=${WORKSPACE_DIR:-${PROJECT_SOURCE:-$ROOT}}
AIDLC_DIR=${AIDLC_DIR:-$WORKSPACE_DIR/aidlc}
AIDLC_STATE_DIR=${AIDLC_STATE_DIR:-${HOME:-/tmp}/.aidlc-workstation}

fails=0
pass() { printf 'PASSOU  %s\n' "$1"; }
fail() { printf 'FALHOU  %s\n' "$1"; fails=$((fails + 1)); }

# 1) Copilot CLI presente e informando a versao (FR3.1)
if command -v "$COPILOT_BIN" >/dev/null 2>&1 && ver=$("$COPILOT_BIN" --version 2>/dev/null | head -n 1) && [ -n "$ver" ]; then
  pass "Copilot CLI presente ($ver)"
else
  fail "Copilot CLI ausente ou sem resposta a --version (COPILOT_BIN=$COPILOT_BIN)"
fi

# 2) Token disponivel (apenas presenca, nunca o valor)
if [ -n "${GH_TOKEN:-}" ] || [ -n "${GITHUB_TOKEN:-}" ]; then
  pass "token do GitHub disponivel (GH_TOKEN ou GITHUB_TOKEN)"
else
  fail "token do GitHub ausente: crie o Secret copilot-token e reinicie o workspace"
fi

# 3) AI-DLC configurado para o Copilot: marcador do post-start.sh ou skills no workspace
#    (com a imagem pronta nao ha post-start; o passo e `aidlc config --harness copilot --yes`)
if [ -r "$AIDLC_STATE_DIR/installed" ] && [ -n "$(cat "$AIDLC_STATE_DIR/installed" 2>/dev/null)" ]; then
  pass "regras do AI-DLC instaladas (versao $(head -n 1 "$AIDLC_STATE_DIR/installed"))"
elif [ -d "$WORKSPACE_DIR/.github/skills/aidlc" ]; then
  pass "AI-DLC configurado para o Copilot (.github/skills/aidlc)"
else
  fail "AI-DLC nao configurado para o Copilot: rode 'aidlc config --harness copilot --yes' na raiz do workspace"
fi

# 4) Pasta de artefatos gravavel
probe="$AIDLC_DIR/.verify-write.$$"
if [ -d "$AIDLC_DIR" ] && ( : > "$probe" ) 2>/dev/null; then
  rm -f "$probe"
  pass "pasta de artefatos gravavel ($AIDLC_DIR)"
else
  fail "pasta de artefatos inexistente ou sem permissao de escrita ($AIDLC_DIR)"
fi

# 5) git
if command -v git >/dev/null 2>&1; then
  pass "git presente"
else
  fail "git ausente"
fi

if [ "$fails" -eq 0 ]; then
  echo "RESULTADO: PASSOU"
  exit 0
fi
echo "RESULTADO: FALHOU ($fails item(ns))"
exit 1
