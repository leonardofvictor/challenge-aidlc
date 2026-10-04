#!/usr/bin/env bash
# Testes de verify-workstation.sh (FR3.1, FR6.1, NFR1). Sem rede, sem token real.
set -u
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
VERIFY="$DIR/../scripts/verify-workstation.sh"
T=$(mktemp -d) || exit 1
trap 'chmod -R u+w "$T" 2>/dev/null; rm -rf "$T"' EXIT
fails=0
ok()  { echo "  ok: $1"; }
bad() { echo "  FALHA: $1"; fails=$((fails + 1)); }

mkdir -p "$T/aidlc" "$T/state" "$T/bin"
printf '#!/bin/sh\necho "copilot 0.0.0-fake"\n' > "$T/bin/copilot"
chmod +x "$T/bin/copilot"
echo "v0.0.0-fake" > "$T/state/installed"
FAKE_TOKEN="github_pat_$(printf 'X%.0s' $(seq 1 30))"

run() {  # run <env...> : roda verify com ambiente limpo de token e overrides
  env -u GH_TOKEN -u GITHUB_TOKEN COPILOT_BIN="$T/bin/copilot" WORKSPACE_DIR="$T" \
    AIDLC_DIR="${AIDLC_DIR_T:-$T/aidlc}" AIDLC_STATE_DIR="$T/state" "$@" bash "$VERIFY" 2>&1
}

# Feliz: tudo presente
out=$(run GH_TOKEN="$FAKE_TOKEN"); rc=$?
[ $rc -eq 0 ] && echo "$out" | grep -q 'RESULTADO: PASSOU' && ok "tudo presente passa" || bad "tudo presente deveria passar (rc=$rc)"
echo "$out" | grep -q 'Copilot CLI presente (copilot 0.0.0-fake)' && ok "informa a versao do Copilot" || bad "versao do Copilot nao informada"
echo "$out" | grep -qF "$FAKE_TOKEN" && bad "vazou o valor do token" || ok "nao vaza o token"

# Erro: token ausente
out=$(run); rc=$?
[ $rc -ne 0 ] && echo "$out" | grep -q 'FALHOU  token do GitHub ausente' && ok "token ausente falha com aviso" || bad "token ausente deveria falhar com aviso (rc=$rc)"

# Erro: pasta nao gravavel
if [ "$(id -u)" -ne 0 ]; then
  mkdir -p "$T/ro" && chmod 555 "$T/ro"
  AIDLC_DIR_T="$T/ro" out=$(AIDLC_DIR_T="$T/ro" run GH_TOKEN="$FAKE_TOKEN"); rc=$?
else
  : > "$T/arquivo"
  out=$(AIDLC_DIR_T="$T/arquivo/sub" run GH_TOKEN="$FAKE_TOKEN"); rc=$?
fi
[ $rc -ne 0 ] && echo "$out" | grep -q 'FALHOU  pasta de artefatos' && ok "pasta nao gravavel falha" || bad "pasta nao gravavel deveria falhar (rc=$rc)"

# Erro: regras do AI-DLC nao instaladas
rm -f "$T/state/installed"
out=$(run GH_TOKEN="$FAKE_TOKEN"); rc=$?
[ $rc -ne 0 ] && echo "$out" | grep -q 'FALHOU  regras do AI-DLC' && ok "regras ausentes falham" || bad "regras ausentes deveriam falhar"

[ $fails -eq 0 ]
