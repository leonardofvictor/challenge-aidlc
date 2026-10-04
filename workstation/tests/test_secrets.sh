#!/usr/bin/env bash
# Testes de scan-secrets.sh (NFR1). O token falso e montado em tempo de execucao.
set -u
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCAN="$DIR/../scripts/scan-secrets.sh"
REPO=$(cd "$DIR/../.." && pwd)
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
fails=0
ok()  { echo "  ok: $1"; }
bad() { echo "  FALHA: $1"; fails=$((fails + 1)); }

# Diretorio limpo passa
echo "nada a ver" > "$T/limpo.txt"
bash "$SCAN" "$T" >/dev/null 2>&1 && ok "diretorio limpo passa" || bad "diretorio limpo deveria passar"

# Token falso (montado aqui) e detectado, sem imprimir o valor
FAKE="github_pat_$(printf 'Z%.0s' $(seq 1 30))"
echo "token=$FAKE" > "$T/vazou.txt"
out=$(bash "$SCAN" "$T" 2>&1); rc=$?
[ $rc -eq 1 ] && echo "$out" | grep -q 'vazou.txt' && ok "token falso detectado" || bad "token falso deveria ser detectado (rc=$rc)"
echo "$out" | grep -qF "$FAKE" && bad "scan imprimiu o valor do token" || ok "scan nao imprime o valor"

# Formato ghp_ tambem
rm "$T/vazou.txt"; echo "x ghp_$(printf 'W%.0s' $(seq 1 36))" > "$T/outro.txt"
bash "$SCAN" "$T" >/dev/null 2>&1; [ $? -eq 1 ] && ok "formato ghp_ detectado" || bad "formato ghp_ nao detectado"

# Erro de uso
bash "$SCAN" "$T/nao-existe" >/dev/null 2>&1; [ $? -eq 2 ] && ok "diretorio inexistente retorna 2" || bad "diretorio inexistente deveria retornar 2"

# Repositorio real esta limpo (NFR1)
out=$(bash "$SCAN" "$REPO" 2>&1) && ok "repositorio sem tokens" || { bad "repositorio contem padrao de token"; echo "$out"; }

[ $fails -eq 0 ]
