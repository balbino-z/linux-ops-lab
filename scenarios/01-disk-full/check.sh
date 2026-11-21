#!/usr/bin/env bash
# Scenario 01 check: the data volume has room, uploads can be written, and it stays that way.
set -uo pipefail

usage() { df --output=pcent /srv/data | tail -n 1 | tr -dc '0-9'; }
fail() { echo "  ✗ $*"; exit 1; }
ok() { echo "  ✓ $*"; }

used="$(usage)"
[ "$used" -lt 80 ] || fail "/srv/data is ${used}% full"
ok "/srv/data has free space (${used}% used)"

test_file="/srv/data/uploads/.lab-check-$$"
if sudo -u www-data dd if=/dev/zero of="$test_file" bs=1M count=5 status=none 2>/dev/null; then
  rm -f "$test_file"
  ok "a 5 MB upload can be written as www-data"
else
  rm -f "$test_file"
  fail "writing a 5 MB upload as www-data failed"
fi

echo "  … waiting 15 s to see if the disk fills up again"
sleep 15
[ "$(usage)" -lt 80 ] || fail "the volume filled up again ($(usage)%) — the cause is still active"
ok "still healthy after 15 s ($(usage)% used)"
