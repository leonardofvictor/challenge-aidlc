#!/usr/bin/env bash
# Testes de scripts/setup-game.sh. Usa um repositorio local falso como origem (sem rede).
set -u
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SETUP="$DIR/../../scripts/setup-game.sh"
T=$(mktemp -d) || exit 1
trap 'rm -rf "$T"' EXIT
fails=0
ok()  { echo "  ok: $1"; }
bad() { echo "  FALHA: $1"; fails=$((fails + 1)); }

# Origem falsa com dois commits; o script deve baixar o primeiro (o fixado).
SRC="$T/origem"
git init -q -b main "$SRC" 2>/dev/null || git init -q "$SRC"
git -C "$SRC" config user.name t && git -C "$SRC" config user.email t@t
mkdir -p "$SRC/battle_knights"
echo "print('v1')" > "$SRC/battle_knights/MVP.py"
touch "$SRC/.DS_Store"
git -C "$SRC" add -A && git -C "$SRC" commit -q -m v1
REF=$(git -C "$SRC" rev-parse HEAD)
echo "print('v2')" > "$SRC/battle_knights/MVP.py"
git -C "$SRC" commit -qam v2

# Caminho feliz: baixa a versao fixada e cria repositorio proprio sem historico do autor
out=$(GAME_REPO_URL="$SRC" GAME_REF="$REF" bash "$SETUP" "$T/game" 2>&1); rc=$?
[ $rc -eq 0 ] && ok "baixa o jogo (rc=0)" || bad "deveria baixar o jogo (rc=$rc): $out"
grep -q "v1" "$T/game/battle_knights/MVP.py" 2>/dev/null && ok "usa o commit fixado, nao o mais recente" || bad "nao usou o commit fixado"
[ ! -e "$T/game/.DS_Store" ] && ok "nao copia .DS_Store" || bad "copiou .DS_Store"
[ "$(git -C "$T/game" rev-list --count HEAD 2>/dev/null)" = "1" ] && ok "repositorio proprio com 1 commit (baseline)" || bad "repositorio proprio deveria ter 1 commit"
git -C "$T/game" remote 2>/dev/null | grep -q . && bad "nao deveria herdar remoto do autor" || ok "sem remoto do autor"
git -C "$T/game" log -1 --format=%s | grep -q "$REF" && ok "baseline registra o commit de origem" || bad "baseline sem o commit de origem"

# Destino ja existente e nao vazio: recusa sem apagar nada
echo "meu trabalho" > "$T/game/nota.txt"
GAME_REPO_URL="$SRC" GAME_REF="$REF" bash "$SETUP" "$T/game" >/dev/null 2>&1; rc=$?
[ $rc -ne 0 ] && [ -f "$T/game/nota.txt" ] && ok "recusa destino existente e preserva o trabalho" || bad "deveria recusar destino existente (rc=$rc)"

# Commit inexistente falha com erro claro e nao deixa destino parcial
GAME_REPO_URL="$SRC" GAME_REF="0000000000000000000000000000000000000000" bash "$SETUP" "$T/outro" >"$T/err.txt" 2>&1; rc=$?
[ $rc -ne 0 ] && grep -q "nao encontrado" "$T/err.txt" && [ ! -e "$T/outro" ] && ok "commit inexistente falha sem deixar destino" || bad "commit inexistente deveria falhar limpo (rc=$rc)"

# Origem invalida falha
GAME_REPO_URL="$T/nao-existe" bash "$SETUP" "$T/x" >/dev/null 2>&1; rc=$?
[ $rc -ne 0 ] && ok "origem invalida falha" || bad "origem invalida deveria falhar"

[ "$fails" -eq 0 ]
