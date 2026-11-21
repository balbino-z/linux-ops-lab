#!/usr/bin/env bash
# Harness test: for every scenario, a clean machine must PASS its check,
# and the same machine must FAIL the check after break.sh runs.
# It proves the scenarios work without containing any solution.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB="$ROOT/lab"
only="${1:-}"
failures=0

for dir in "$ROOT"/scenarios/*/; do
  id="$(basename "$dir")"
  num="${id%%-*}"
  [ -n "$only" ] && [ "$only" != "$num" ] && continue
  echo "=== $id"
  "$LAB" reset >/dev/null

  if "$LAB" check "$num" >/dev/null 2>&1; then
    echo "  ok   clean machine passes"
  else
    echo "  FAIL clean machine should pass"; failures=$((failures + 1)); continue
  fi

  "$LAB" break "$num" >/dev/null
  if "$LAB" check "$num" >/dev/null 2>&1; then
    echo "  FAIL broken machine should fail"; failures=$((failures + 1))
  else
    echo "  ok   broken machine fails"
  fi
done

"$LAB" down >/dev/null
if [ "$failures" -ne 0 ]; then
  echo "harness: $failures failure(s)"
  exit 1
fi
echo "harness: all scenarios ok"
