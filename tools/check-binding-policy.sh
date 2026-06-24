#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Binding-policy tripwire — enforces ADR 0003
# (docs/decisions/0003-keep-bindings-thin-abi-wrappers.md):
#
#   1. Registry parity: every bindings/<lang> on disk is registered in
#      .machine_readable/BINDINGS.a2ml, and every registered language exists
#      on disk. Catches a rogue/unmanaged hand-written binding appearing, and
#      registry drift.
#   2. No logic in scaffold-tier bindings: the validator / state-machine
#      functions removed on 2026-06-24 must not reappear (logic creep).
#
# Usage: bash tools/check-binding-policy.sh    (exit 0 = ok, 1 = violation)

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
REG=".machine_readable/BINDINGS.a2ml"
FAIL=0
red(){ printf '\033[31m%s\033[0m\n' "$*"; }
grn(){ printf '\033[32m%s\033[0m\n' "$*"; }

[ -f "$REG" ] || { red "FAIL: registry $REG missing"; exit 1; }

# --- 1. registry parity ---------------------------------------------------
# Registered languages: parse the multi-line `languages = [ ... ]` array.
registered="$(awk '
  /^[[:space:]]*languages[[:space:]]*=[[:space:]]*\[/ {f=1}
  f {print}
  /\]/ {if (f) exit}
' "$REG" | grep -oE '"[a-z0-9]+"' | tr -d '"' | sort -u)"

ondisk="$(for d in bindings/*/; do [ -d "$d" ] && basename "$d"; done | sort -u)"

rogue="$(comm -23 <(printf '%s\n' "$ondisk") <(printf '%s\n' "$registered") || true)"
missing="$(comm -13 <(printf '%s\n' "$ondisk") <(printf '%s\n' "$registered") || true)"
if [ -n "$rogue" ]; then
  red "FAIL: unregistered binding(s) under bindings/ — add to $REG or remove:"
  printf '   %s\n' $rogue; FAIL=1
fi
if [ -n "$missing" ]; then
  red "FAIL: registry lists binding(s) absent from disk:"
  printf '   %s\n' $missing; FAIL=1
fi
[ -z "${rogue}${missing}" ] && grn "OK: bindings/ ($(printf '%s\n' $ondisk | wc -w | tr -d ' ')) match registry exactly"

# --- 2. scaffold-tier bindings must stay logic-free -----------------------
scaffolds="$(grep -E '^[[:space:]]*[a-z]+[[:space:]]*=[[:space:]]*\{[^}]*status[[:space:]]*=[[:space:]]*"scaffold"' "$REG" \
  | sed -E 's/^[[:space:]]*([a-z]+)[[:space:]]*=.*/\1/' | sort -u)"

for b in $scaffolds; do
  [ -d "bindings/$b" ] || continue
  # Anti-pattern = validators (`validate*`) and state-machine transition
  # validators (`*can_transition*` / `*CanTransition*`). NOT error constructors
  # like `invalid_transition`, and not test functions (test dirs excluded).
  case "$b" in
    elixir)   def='def[p]?[[:space:]]+(validate|[a-z_]*can_transition)'; inc=(--include='*.ex') ;;
    gleam)    def='(pub[[:space:]]+)?fn[[:space:]]+(validate|[a-z_]*can_transition)'; inc=(--include='*.gleam' --exclude-dir=test) ;;
    rescript) def='let[[:space:]]+(validate|[a-zA-Z]*[Cc]anTransition)'; inc=(--include='*.res' --include='*.resi' --exclude-dir=__tests__) ;;
    *)        def='(validate|can_transition|CanTransition)'; inc=() ;;
  esac
  # Source files only (not compiled .mjs); drop comment lines and the markers.
  hits="$(grep -rnE "${inc[@]+"${inc[@]}"}" "$def" "bindings/$b" 2>/dev/null \
            | grep -vE ':[[:space:]]*(#|//|--)' \
            | grep -viE 'removed: unproven' || true)"
  if [ -n "$hits" ]; then
    red "FAIL: scaffold binding '$b' reintroduced reimplemented logic (ADR 0003 forbids it):"
    printf '%s\n' "$hits" | head -8 | sed 's/^/   /'; FAIL=1
  else
    grn "OK: scaffold binding '$b' is logic-free"
  fi
done

if [ "$FAIL" -ne 0 ]; then
  red "Binding policy VIOLATED — see docs/decisions/0003-keep-bindings-thin-abi-wrappers.md"
  exit 1
fi
grn "Binding policy OK."
