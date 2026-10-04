#!/usr/bin/env bash
# Baixa o jogo Battle Knights para game/ numa versao fixa. O codigo do jogo nao tem licenca
# declarada pelo autor, entao ele NAO e copiado para este repositorio: cada equipe baixa a
# propria copia (game/ esta no .gitignore).
#
# Uso: bash scripts/setup-game.sh [diretorio-destino]   (padrao: game/ na raiz do repositorio)
#
# Variaveis opcionais (usadas pelos testes):
#   GAME_REPO_URL  repositorio de origem (padrao: o do autor no GitHub)
#   GAME_REF       commit fixado a baixar
set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
GAME_REPO_URL=${GAME_REPO_URL:-https://github.com/mdghayman/battle_knights}
GAME_REF=${GAME_REF:-501d5820cc98858fc5a637938f18d5503d5ee0bc}
DEST=${1:-$ROOT/game}

log()  { printf '[setup-game] %s\n' "$*"; }
fail() { printf '[setup-game] ERRO: %s\n' "$*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || fail "git nao encontrado."
command -v python3 >/dev/null 2>&1 || log "AVISO: python3 nao encontrado; o jogo nao vai rodar sem ele."

if [ -e "$DEST" ] && [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
  fail "$DEST ja existe e nao esta vazio. Apague-o para baixar de novo (cuidado: perde alteracoes)."
fi

TMP=$(mktemp -d "${TMPDIR:-/tmp}/setup-game.XXXXXX") || fail "mktemp falhou."
trap 'rm -rf "$TMP"' EXIT

log "baixando $GAME_REPO_URL @ ${GAME_REF:0:7}"
git clone --quiet "$GAME_REPO_URL" "$TMP/src" || fail "clone falhou. Verifique a rede e a URL."
git -C "$TMP/src" checkout --quiet "$GAME_REF" || fail "commit $GAME_REF nao encontrado no repositorio."

mkdir -p "$DEST" || fail "nao foi possivel criar $DEST."
# Copia sem o historico do autor (e sem .DS_Store) e abre um repositorio proprio da equipe.
( cd "$TMP/src" && tar --exclude=.git --exclude=.DS_Store -cf - . ) | ( cd "$DEST" && tar -xf - ) \
  || fail "copia para $DEST falhou."

(
  cd "$DEST" || exit 1
  git init --quiet -b main 2>/dev/null || git init --quiet
  git add -A
  git -c user.name="${GIT_AUTHOR_NAME:-challenge}" -c user.email="${GIT_AUTHOR_EMAIL:-challenge@localhost}" \
    commit --quiet -m "baseline: battle_knights @ $GAME_REF (origem: $GAME_REPO_URL)"
) || fail "nao foi possivel iniciar o repositorio em $DEST."

log "pronto: $DEST (repositorio git proprio, baseline commitada)."
log "para rodar: python3 $DEST/battle_knights/MVP.py   |   python3 $DEST/battle_knights/run.py"
