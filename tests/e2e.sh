#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# proven-servers — End-to-End Test Suite
#
# Tests the ABI/FFI round-trip across protocols and connectors:
#   1. Zig FFI builds for core primitives
#   2. Per-connector lifecycle tests (dbconn, authconn, cacheconn, etc.)
#   3. Per-protocol FFI tests (sample of 84)
#   4. Cross-binding consistency
#   5. Safety aspect: no dangerous patterns
#
# Usage:
#   bash tests/e2e.sh
#   just e2e

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

PASS=0
FAIL=0
SKIP=0

green() { printf '\033[32m%s\033[0m\n' "$*"; }
red()   { printf '\033[31m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

pass() { green "  PASS: $1"; PASS=$((PASS + 1)); }
fail_test() { red "  FAIL: $1"; FAIL=$((FAIL + 1)); }
skip_test() { yellow "  SKIP: $1 ($2)"; SKIP=$((SKIP + 1)); }

echo "═══════════════════════════════════════════════════════════════"
echo "  proven-servers — End-to-End Tests"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ─── Preflight ───────────────────────────────────────────────────────
bold "Preflight"
if command -v zig >/dev/null 2>&1; then
    green "  Zig available: $(zig version)"
else
    red "FATAL: zig not found"
    exit 1
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Section 1: Connector FFI Build + Test
# ═══════════════════════════════════════════════════════════════════════
bold "Section 1: Connector FFI build + integration tests"

CONNECTORS_TESTED=0
for conn in dbconn authconn cacheconn queueconn resolverconn storageconn; do
    CONN_DIR="connectors/proven-$conn/ffi/zig"
    if [ -f "$CONN_DIR/build.zig" ]; then
        if (cd "$CONN_DIR" && zig build 2>/dev/null); then
            pass "build proven-$conn FFI"
        else
            fail_test "build proven-$conn FFI"
            continue
        fi

        if (cd "$CONN_DIR" && zig build test 2>/dev/null); then
            pass "test proven-$conn FFI"
            CONNECTORS_TESTED=$((CONNECTORS_TESTED + 1))
        else
            fail_test "test proven-$conn FFI"
        fi
    else
        skip_test "proven-$conn" "no build.zig"
    fi
done
echo "  Connectors tested: $CONNECTORS_TESTED/6"
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Section 2: Protocol FFI Build + Test (sample)
# ═══════════════════════════════════════════════════════════════════════
bold "Section 2: Protocol FFI tests (sample of 84)"

PROTOCOLS_TESTED=0
PROTOCOLS_TOTAL=0

for proto_dir in protocols/proven-*/ffi/zig; do
    [ -f "$proto_dir/build.zig" ] || continue
    PROTOCOLS_TOTAL=$((PROTOCOLS_TOTAL + 1))

    proto_name=$(echo "$proto_dir" | sed 's|protocols/proven-\(.*\)/ffi/zig|\1|')

    if (cd "$proto_dir" && zig build test 2>/dev/null); then
        pass "test proven-$proto_name"
        PROTOCOLS_TESTED=$((PROTOCOLS_TESTED + 1))
    else
        fail_test "test proven-$proto_name"
    fi

    # Limit to first 20 to keep CI time reasonable
    if [ "$PROTOCOLS_TOTAL" -ge 20 ]; then
        REMAINING=$(($(find protocols/proven-*/ffi/zig -name "build.zig" 2>/dev/null | wc -l) - PROTOCOLS_TOTAL))
        if [ "$REMAINING" -gt 0 ]; then
            skip_test "$REMAINING more protocols" "sampled first 20"
        fi
        break
    fi
done
echo "  Protocols tested: $PROTOCOLS_TESTED/$PROTOCOLS_TOTAL (of $(find protocols/proven-*/ffi/zig -name 'build.zig' 2>/dev/null | wc -l) total)"
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Section 3: Core Primitives FFI
# ═══════════════════════════════════════════════════════════════════════
bold "Section 3: Core primitives"

for prim in socket frame fsm wire compose tls config audit; do
    PRIM_DIR="core/proven-$prim/ffi/zig"
    if [ -f "$PRIM_DIR/build.zig" ]; then
        if (cd "$PRIM_DIR" && zig build test 2>/dev/null); then
            pass "test core/proven-$prim"
        else
            fail_test "test core/proven-$prim"
        fi
    else
        skip_test "core/proven-$prim" "no build.zig"
    fi
done
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Section 4: Cross-Binding Test
# ═══════════════════════════════════════════════════════════════════════
bold "Section 4: Cross-binding consistency"

if [ -f "tests/cross_binding_test.sh" ]; then
    if bash tests/cross_binding_test.sh 2>/dev/null; then
        pass "cross-binding test suite"
    else
        fail_test "cross-binding test suite"
    fi
else
    skip_test "cross-binding" "tests/cross_binding_test.sh not found"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Section 5: Safety Aspects
# ═══════════════════════════════════════════════════════════════════════
bold "Section 5: Safety aspects"

# No believe_me/assert_total in Idris2 ABI
DANGEROUS_IDRIS=$(grep -rn 'believe_me\|assert_total\|really_believe_me' src/ connectors/*/src/ protocols/*/src/ core/*/src/ 2>/dev/null | grep -v test || true)
if [ -n "$DANGEROUS_IDRIS" ]; then
    fail_test "Dangerous Idris2 patterns ($(echo "$DANGEROUS_IDRIS" | wc -l) occurrences)"
    echo "$DANGEROUS_IDRIS" | head -5
else
    pass "No dangerous Idris2 patterns"
fi

# No @panic in Zig FFI production code
ZIG_PANIC=$(grep -rn '@panic' connectors/*/ffi/zig/src/ protocols/*/ffi/zig/src/ core/*/ffi/zig/src/ 2>/dev/null | grep -v test || true)
if [ -n "$ZIG_PANIC" ]; then
    fail_test "Zig @panic in FFI production code ($(echo "$ZIG_PANIC" | wc -l) occurrences)"
else
    pass "No @panic in Zig FFI production code"
fi

# SPDX headers
MISSING_SPDX=0
for f in $(find connectors/*/ffi/zig/src/ protocols/*/ffi/zig/src/ -name "*.zig" 2>/dev/null | head -30); do
    if ! head -3 "$f" | grep -q "SPDX"; then
        MISSING_SPDX=$((MISSING_SPDX + 1))
    fi
done
if [ "$MISSING_SPDX" -eq 0 ]; then
    pass "SPDX headers present (sampled 30 files)"
else
    fail_test "$MISSING_SPDX files missing SPDX headers"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════"
printf "  Results: "
green "PASS=$PASS" | tr -d '\n'
echo -n "  "
if [ "$FAIL" -gt 0 ]; then red "FAIL=$FAIL" | tr -d '\n'; else echo -n "FAIL=0"; fi
echo -n "  "
if [ "$SKIP" -gt 0 ]; then yellow "SKIP=$SKIP"; else echo "SKIP=0"; fi
echo ""
echo "═══════════════════════════════════════════════════════════════"

exit "$FAIL"
