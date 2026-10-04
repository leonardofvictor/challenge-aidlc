#!/usr/bin/env bash
# Testes de post-start.sh (FR3.3, FR4.1, NFR1, NFR2). Instalador e aidlc simulados; sem rede.
set -u
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
POST="$DIR/../scripts/post-start.sh"
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
fails=0
ok()  { echo "  ok: $1"; }
bad() { echo "  FALHA: $1"; fails=$((fails + 1)); }

mkdir -p "$T/bin" "$T/ws"
printf 'AIDLC_VERSION=v9.9.9-teste\n' > "$T/versions.env"
# Instalador falso: registra a versao recebida.
printf '#!/bin/sh\necho "$1" > "%s/installed-version"\n' "$T" > "$T/bin/fake-install"
# aidlc falso: registra os argumentos.
printf '#!/bin/sh\necho "$@" > "%s/aidlc-args"\n' "$T" > "$T/bin/aidlc"
printf '#!/bin/sh\necho 1.0.0\n' > "$T/bin/copilot"
chmod +x "$T/bin/copilot" "$T/bin/fake-install" "$T/bin/aidlc"
FAKE_TOKEN="ghp_$(printf 'Y%.0s' $(seq 1 36))"

run() {
  env -u GH_TOKEN -u GITHUB_TOKEN VERSIONS_FILE="$T/versions.env" WORKSPACE_DIR="$T/ws" \
    AIDLC_STATE_DIR="$T/state" AIDLC_INSTALL_CMD="$T/bin/fake-install" \
    AIDLC_BIN="$T/bin/aidlc" COPILOT_BIN="$T/bin/copilot" "$@" bash "$POST" 2>&1
}

# Sem token: avisa e nao aborta
out=$(run); rc=$?
[ $rc -eq 0 ] && echo "$out" | grep -q 'AVISO: token do GitHub ausente' && ok "sem token avisa e nao aborta" || bad "sem token deveria avisar com rc=0 (rc=$rc)"

# Versao fixada lida de versions.env e repassada ao instalador; aidlc configurado para copilot
[ "$(cat "$T/installed-version" 2>/dev/null)" = "v9.9.9-teste" ] && ok "versao fixada lida da configuracao" || bad "instalador nao recebeu a versao de versions.env"
grep -q -- '--harness copilot' "$T/aidlc-args" 2>/dev/null && ok "aidlc configurado com harness copilot" || bad "aidlc config --harness copilot nao chamado"
[ "$(cat "$T/state/installed" 2>/dev/null)" = "v9.9.9-teste" ] && ok "marcador gravado" || bad "marcador de instalacao ausente"

# Com token: nao vaza o valor; idempotente (nao reinstala)
rm -f "$T/installed-version"
out=$(run GH_TOKEN="$FAKE_TOKEN"); rc=$?
echo "$out" | grep -qF "$FAKE_TOKEN" && bad "vazou o valor do token" || ok "nao imprime o token"
[ ! -e "$T/installed-version" ] && ok "segunda execucao nao reinstala" || bad "reinstalou apesar do marcador"

# Erro: instalador falha -> avisa, rc=0, sem marcador
rm -rf "$T/state"; printf '#!/bin/sh\nexit 3\n' > "$T/bin/fake-install"
out=$(run GH_TOKEN="$FAKE_TOKEN"); rc=$?
[ $rc -eq 0 ] && echo "$out" | grep -q 'instalacao do AI-DLC.*falhou' && [ ! -e "$T/state/installed" ] && ok "falha do instalador avisa sem marcar instalado" || bad "falha do instalador mal tratada (rc=$rc)"

# Erro: versions.env ausente
out=$(run VERSIONS_FILE="$T/nao-existe.env"); rc=$?
[ $rc -eq 0 ] && echo "$out" | grep -q 'arquivo de versoes nao encontrado' && ok "versions.env ausente avisa" || bad "versions.env ausente mal tratado"

[ $fails -eq 0 ]
