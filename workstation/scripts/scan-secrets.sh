#!/usr/bin/env bash
# Procura padroes de token do GitHub no repositorio (NFR1). Uso: scan-secrets.sh [diretorio]
# Exclui apenas .git. Imprime arquivo:linha, nunca o trecho encontrado.
# Sai com 1 se achar algo, 0 se limpo, 2 em erro de uso.
set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TARGET=${1:-$(cd "$SCRIPT_DIR/../.." && pwd)}

if [ ! -d "$TARGET" ]; then
  echo "scan-secrets: diretorio inexistente: $TARGET" >&2
  exit 2
fi

# Padroes escritos como classes de caracteres: o proprio script nao casa com eles.
PATTERN='github_pat_[A-Za-z0-9_]{20,}|gh[pousr]_[A-Za-z0-9]{30,}'

hits=$(grep -rIlE --exclude-dir=.git -e "$PATTERN" "$TARGET" 2>/dev/null)
if [ -n "$hits" ]; then
  echo "scan-secrets: possivel token do GitHub encontrado em:" >&2
  grep -rInoE --exclude-dir=.git -e "$PATTERN" "$TARGET" 2>/dev/null | cut -d: -f1,2 >&2
  exit 1
fi
echo "scan-secrets: nenhum token encontrado em $TARGET"
exit 0
