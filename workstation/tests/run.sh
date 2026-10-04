#!/usr/bin/env bash
# Executa todos os test_*.sh desta pasta. Uso: bash workstation/tests/run.sh
set -u
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
failed=0
total=0
for t in "$DIR"/test_*.sh; do
  [ -e "$t" ] || { echo "run.sh: nenhum test_*.sh encontrado em $DIR" >&2; exit 1; }
  total=$((total + 1))
  echo "== $(basename "$t")"
  if bash "$t"; then
    echo "-- PASSOU: $(basename "$t")"
  else
    echo "-- FALHOU: $(basename "$t")"
    failed=$((failed + 1))
  fi
done
echo "RESUMO: $((total - failed)) de $total arquivos de teste passaram"
[ "$failed" -eq 0 ]
