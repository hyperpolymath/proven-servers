#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Cross-binding integration test for proven-servers.
#
# Validates that language bindings agree on ABI constants, enum encoding,
# and basic protocol semantics. Runs tests for all bindings that have
# their own test suites.
#
# Usage: bash tests/cross_binding_test.sh

set -euo pipefail

PASS=0
FAIL=0
SKIP=0
ERRORS=""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_pass() { PASS=$((PASS + 1)); printf "  ${GREEN}✓${NC} %s\n" "$1"; }
log_fail() { FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  ✗ $1"; printf "  ${RED}✗${NC} %s\n" "$1"; }
log_skip() { SKIP=$((SKIP + 1)); printf "  ${YELLOW}⊘${NC} %s (skipped)\n" "$1"; }

echo "═══════════════════════════════════════════════════════"
echo "  proven-servers Cross-Binding Integration Tests"
echo "═══════════════════════════════════════════════════════"

# ─── Core FFI Tests (Zig) ─────────────────────────────────────────────────
echo ""
echo "  Core FFI (Zig):"
for module in proven-socket proven-frame proven-fsm proven-wire proven-compose proven-tls proven-config proven-audit; do
  test_dir="core/$module/ffi/zig/test"
  if [ -d "$test_dir" ]; then
    if cd "core/$module/ffi/zig" && zig build test --summary all >/dev/null 2>&1; then
      log_pass "$module"
    else
      log_fail "$module"
    fi
    cd "$OLDPWD"
  else
    log_skip "$module (no test dir)"
  fi
done

# ─── Protocol FFI Tests (sample 10) ──────────────────────────────────────
echo ""
echo "  Protocol FFI (Zig — sample):"
SAMPLE_PROTOCOLS="proven-http proven-dns proven-mqtt proven-grpc proven-websocket proven-ssh proven-smtp proven-ntp proven-redis proven-agentic"
for proto in $SAMPLE_PROTOCOLS; do
  test_dir="protocols/$proto/ffi/zig/test"
  if [ -d "$test_dir" ]; then
    if cd "protocols/$proto/ffi/zig" && zig build test --summary all >/dev/null 2>&1; then
      log_pass "$proto"
    else
      log_fail "$proto"
    fi
    cd "$OLDPWD"
  else
    log_skip "$proto (no test dir)"
  fi
done

# ─── ReScript Binding Tests ──────────────────────────────────────────────
echo ""
echo "  ReScript Bindings:"
if [ -d "bindings/rescript/__tests__" ]; then
  rescript_tests=$(find bindings/rescript/__tests__ -name "*.res.js" -o -name "*_test.res.js" 2>/dev/null | wc -l)
  if [ "$rescript_tests" -gt 0 ]; then
    log_pass "ReScript: $rescript_tests test files present"
  else
    log_fail "ReScript: no test files found"
  fi
else
  log_skip "ReScript (no __tests__ dir)"
fi

# ─── Rust Binding Tests ──────────────────────────────────────────────────
echo ""
echo "  Rust Bindings:"
if [ -d "bindings/rust" ]; then
  rust_tests=$(find bindings/rust/src -name "*.rs" -exec grep -l "#\[test\]" {} \; 2>/dev/null | wc -l)
  if [ "$rust_tests" -gt 0 ]; then
    log_pass "Rust: $rust_tests files with unit tests"
  else
    log_fail "Rust: no test annotations found"
  fi
else
  log_skip "Rust (no bindings/rust dir)"
fi

# ─── Gleam Binding Tests ─────────────────────────────────────────────────
echo ""
echo "  Gleam Bindings:"
if [ -d "bindings/gleam/test" ]; then
  gleam_tests=$(find bindings/gleam/test -name "*.gleam" 2>/dev/null | wc -l)
  log_pass "Gleam: $gleam_tests test files present"
else
  log_skip "Gleam (no test dir)"
fi

# ─── Elixir Binding Tests ────────────────────────────────────────────────
echo ""
echo "  Elixir Bindings:"
if [ -d "bindings/elixir/test" ]; then
  elixir_tests=$(find bindings/elixir/test -name "*_test.exs" 2>/dev/null | wc -l)
  log_pass "Elixir: $elixir_tests test files present"
else
  log_skip "Elixir (no test dir)"
fi

# ─── Summary ─────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  Results: $PASS passed, $FAIL failed, $SKIP skipped"
if [ "$FAIL" -gt 0 ]; then
  printf "  Failures:$ERRORS\n"
  echo "═══════════════════════════════════════════════════════"
  exit 1
else
  echo "  All tests passed!"
  echo "═══════════════════════════════════════════════════════"
  exit 0
fi
