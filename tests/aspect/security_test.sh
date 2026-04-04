#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# proven-servers — Security Aspect Test Suite
#
# Tests security-specific properties of the proven-servers protocol
# implementations.  These are aspect tests — they cut across all protocols
# and verify that the security invariants established in the Idris2 ABI
# specifications are preserved in the Zig FFI implementations.
#
# Security aspects covered
# ────────────────────────
#   SA1  Protocol state machine cannot skip states (no direct CLOSED→ESTABLISHED)
#          Verifies that the FSM rejects all bypass transitions.
#
#   SA2  Buffer overflow prevention: FFI functions reject oversized inputs
#          Verifies that length-guarded functions have explicit upper-bound
#          checks before any memory operation.
#
#   SA3  Authentication spoofing: handshake cannot be completed without
#          progressing through the correct state sequence
#          Verifies that the state machine enforces connection ordering.
#
#   SA4  Invalid slot safety: out-of-bounds slot access is handled gracefully
#          Verifies that slot < 0 and slot >= MAX_SESSIONS are rejected without
#          any memory dereference.
#
#   SA5  No @panic in FFI production code (crash-safety)
#          A @panic in FFI code is exploitable as a denial-of-service vector
#          because it terminates the host process unconditionally.
#
#   SA6  No dangerous patterns (believe_me, assert_total in Idris2 ABI)
#          These patterns bypass the formal verification guarantees and could
#          allow type-unsafe operations.
#
#   SA7  Mutex protection in all global-state functions
#          Race conditions on the session pool are a TOCTOU vulnerability.
#          All exported functions that read or write global sessions must
#          acquire the mutex before use.
#
#   SA8  Maximum name/payload length constants are defined and finite
#          Unbounded name buffers are the root cause of classic buffer overflows.
#          Every protocol must declare explicit MAX_*_LEN constants.
#
#   SA9  No hardcoded credentials or secrets in FFI source
#          Credentials accidentally committed to FFI source are immediately
#          exposed on first clone of the repository.
#
#   SA10 SPDX license header present in all FFI source files
#          Missing SPDX headers can obscure license obligations and are a
#          supply-chain transparency failure.
#
# Usage
# ─────
#   bash tests/aspect/security_test.sh
#   just security-test

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_DIR"

PASS=0
FAIL=0
SKIP=0

green()  { printf '\033[32m%s\033[0m\n' "$*"; }
red()    { printf '\033[31m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
bold()   { printf '\033[1m%s\033[0m\n' "$*"; }

pass()      { green  "  PASS: $1"; PASS=$((PASS + 1)); }
fail_test() { red    "  FAIL: $1"; FAIL=$((FAIL + 1)); }
skip_test() { yellow "  SKIP: $1 ($2)"; SKIP=$((SKIP + 1)); }

echo "═══════════════════════════════════════════════════════════════"
echo "  proven-servers — Security Aspect Tests"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# SA1 — Protocol state machine cannot skip states
#
# Security invariant: an attacker must not be able to transition a protocol
# directly from CLOSED/IDLE (state 0) to an ESTABLISHED/OPERATING state by
# bypassing the handshake sequence.
#
# For each protocol we test the specific bypass scenario relevant to that
# protocol's threat model:
#   AMQP: Idle(0) → ChannelOpen(2) — skips Connected negotiation
#   MQTT: Idle(0) → Subscribed(2)  — skips Connected authentication
#   DNS:  Idle(0) → ResponseBuilding(3) — skips query parsing
# ─────────────────────────────────────────────────────────────────────────────
bold "SA1 — State machine cannot skip handshake states"

# Format: "proto  bypass_from  bypass_to  description"
declare -a SA1_CASES=(
    "amqp  0  2  Idle->ChannelOpen (skip Connected negotiation)"
    "amqp  0  3  Idle->Consuming (skip all setup)"
    "amqp  0  4  Idle->Publishing (skip all setup)"
    "mqtt  0  2  Idle->Subscribed (skip Connected authentication)"
    "mqtt  0  3  Idle->Publishing (skip authentication)"
    "dns   0  3  Idle->ResponseBuilding (skip query receipt and lookup)"
    "dns   1  3  QueryReceived->ResponseBuilding (skip Lookup)"
)

for entry in "${SA1_CASES[@]}"; do
    # shellcheck disable=SC2086
    proto=$(echo "$entry" | awk '{print $1}')
    bypass_from=$(echo "$entry" | awk '{print $2}')
    bypass_to=$(echo "$entry" | awk '{print $3}')
    description=$(echo "$entry" | cut -d' ' -f4-)

    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "SA1 proven-${proto}: ${description}" "no src file"
        continue
    fi

    # The bypass transition must NOT appear as an accepted edge (return 1).
    BYPASS_PATTERN="from == ${bypass_from} and to == ${bypass_to}"
    if grep "$BYPASS_PATTERN" "$SRC_FILE" 2>/dev/null | grep -q "return 1"; then
        fail_test "SA1 proven-${proto}: BYPASS ACCEPTED — ${description}"
    else
        pass "SA1 proven-${proto}: bypass correctly rejected — ${description}"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# SA2 — Buffer overflow prevention: explicit length bounds before memory ops
#
# Security invariant: any function that receives a pointer + length pair must
# validate the length against an upper bound BEFORE performing any array
# access or memcpy-equivalent.  We verify that every protocol's create/parse
# function contains an explicit length guard.
# ─────────────────────────────────────────────────────────────────────────────
bold "SA2 — Buffer overflow prevention: length bounds enforced"

declare -a SA2_PROTOCOLS=(
    "amqp" "dns" "mqtt" "smtp" "ftp" "cache" "ca"
    "bfd" "caldav" "coap" "agentic"
)

for proto in "${SA2_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "SA2 proven-${proto} length guard" "no src file"
        continue
    fi

    # Check for an explicit length-limit comparison before memory operations.
    # Valid patterns: `> MAX_*`, `>= MAX_*`, `== 0`, or a named max constant check.
    # These are the guard patterns the Zig FFI code must contain.
    if grep -qE "([lg][te]|==)[[:space:]]*(MAX_[A-Z_]+|0)" "$SRC_FILE"; then
        pass "SA2 proven-${proto}: explicit length/size guard present"
    else
        fail_test "SA2 proven-${proto}: NO explicit length guard found — potential overflow"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# SA3 — Authentication spoofing prevention
#
# Security invariant: for protocols with an authentication/handshake phase,
# the state machine must enforce that authentication transitions are only
# reachable from the preceding state.  An attacker must not jump to
# AUTHENTICATED from IDLE.
#
# We verify that authenticated/operating states are only reachable through
# the intermediate states by checking the transition table structure.
# ─────────────────────────────────────────────────────────────────────────────
bold "SA3 — Authentication spoofing prevention (handshake ordering)"

# Format: "proto  auth_state  must_come_from  description"
declare -a SA3_CASES=(
    "amqp  2  1  ChannelOpen reachable only from Connected"
    "mqtt  2  1  Subscribed reachable only from Connected"
    "mqtt  3  1  Publishing reachable from Connected (not Idle)"
    "dns   2  1  Lookup reachable only from QueryReceived"
    "dns   3  2  ResponseBuilding reachable only from Lookup"
)

for entry in "${SA3_CASES[@]}"; do
    proto=$(echo "$entry" | awk '{print $1}')
    auth_state=$(echo "$entry" | awk '{print $2}')
    must_come_from=$(echo "$entry" | awk '{print $3}')
    description=$(echo "$entry" | cut -d' ' -f4-)

    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "SA3 proven-${proto}: ${description}" "no src file"
        continue
    fi

    # The required transition (must_come_from → auth_state) must be accepted.
    REQUIRED="from == ${must_come_from} and to == ${auth_state}"
    if grep -q "$REQUIRED" "$SRC_FILE" && grep "$REQUIRED" "$SRC_FILE" | grep -q "return 1"; then
        pass "SA3 proven-${proto}: ${description}"
    else
        fail_test "SA3 proven-${proto}: required auth transition NOT present — ${description}"
    fi

    # Transitions to auth_state from state 0 (if different from must_come_from)
    # must NOT be accepted, unless must_come_from == 0.
    if [ "$must_come_from" != "0" ]; then
        BYPASS="from == 0 and to == ${auth_state}"
        if grep "$BYPASS" "$SRC_FILE" 2>/dev/null | grep -q "return 1"; then
            fail_test "SA3 proven-${proto}: auth state ${auth_state} reachable directly from Idle — spoofing possible"
        else
            pass "SA3 proven-${proto}: auth state ${auth_state} NOT reachable directly from Idle"
        fi
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# SA4 — Invalid slot safety
#
# Security invariant: accessing an out-of-bounds slot index must not produce
# undefined behaviour.  We verify that:
#   1. All exported FFI functions include a bounds check (slot < 0 or
#      slot >= MAX_SESSIONS or the validSlot() wrapper).
#   2. The validSlot (or equivalent) function short-circuits before indexing.
# ─────────────────────────────────────────────────────────────────────────────
bold "SA4 — Invalid slot safety (out-of-bounds access handled)"

declare -a SA4_PROTOCOLS=(
    "amqp" "dns" "mqtt" "smtp" "ftp" "cache" "ca"
    "bfd" "caldav" "coap" "ctlog" "agentic"
)

for proto in "${SA4_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "SA4 proven-${proto} slot safety" "no src file"
        continue
    fi

    # Verify the guard mechanism is present.
    # Acceptable patterns: validSlot helper, explicit slot < 0, slot >= MAX_SESSIONS.
    HAS_SLOT_GUARD=0
    if grep -q "validSlot" "$SRC_FILE"; then
        HAS_SLOT_GUARD=1
    fi
    if grep -qE "slot[[:space:]]*<[[:space:]]*0" "$SRC_FILE"; then
        HAS_SLOT_GUARD=1
    fi
    if grep -qE "slot[[:space:]]*>=[[:space:]]*MAX_SESSIONS" "$SRC_FILE"; then
        HAS_SLOT_GUARD=1
    fi

    if [ "$HAS_SLOT_GUARD" -eq 1 ]; then
        pass "SA4 proven-${proto}: slot bounds guard present"
    else
        fail_test "SA4 proven-${proto}: NO slot bounds guard — invalid indices may be dereferenced"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# SA5 — No @panic in FFI production code (crash-safety / DoS prevention)
#
# Security invariant: @panic terminates the host process unconditionally and
# is therefore exploitable as a denial-of-service vector.  All error paths
# in FFI production code must return error codes, not panic.
# ─────────────────────────────────────────────────────────────────────────────
bold "SA5 — No @panic in FFI production code (DoS prevention)"

PANIC_IN_PROD=0
PROD_FILES_CHECKED=0

for src in protocols/proven-*/ffi/zig/src/*.zig \
           connectors/proven-*/ffi/zig/src/*.zig \
           core/proven-*/ffi/zig/src/*.zig; do
    [ -f "$src" ] || continue
    PROD_FILES_CHECKED=$((PROD_FILES_CHECKED + 1))
    if grep -q "@panic" "$src"; then
        fail_test "SA5 @panic found in production FFI: $src"
        PANIC_IN_PROD=$((PANIC_IN_PROD + 1))
    fi
done

if [ "$PROD_FILES_CHECKED" -eq 0 ]; then
    skip_test "SA5 @panic check" "no production FFI source files found"
elif [ "$PANIC_IN_PROD" -eq 0 ]; then
    pass "SA5 no @panic in ${PROD_FILES_CHECKED} production FFI source files"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# SA6 — No dangerous patterns in Idris2 ABI specs
#
# Security invariant: believe_me, assert_total, and really_believe_me in
# Idris2 bypass the type checker and can introduce type-unsafe casts.  These
# patterns in the ABI specification layer undermine the formal guarantees.
# ─────────────────────────────────────────────────────────────────────────────
bold "SA6 — No dangerous Idris2 patterns in ABI specs"

DANGEROUS_COUNT=0
IDRIS_FILES_CHECKED=0

for idr in protocols/proven-*/src/**/*.idr \
            protocols/proven-*/src/*.idr \
            core/proven-*/src/**/*.idr \
            connectors/proven-*/src/**/*.idr; do
    [ -f "$idr" ] || continue
    IDRIS_FILES_CHECKED=$((IDRIS_FILES_CHECKED + 1))
    if grep -qE "believe_me|assert_total|really_believe_me" "$idr"; then
        hit=$(grep -nE "believe_me|assert_total|really_believe_me" "$idr" | head -3)
        fail_test "SA6 dangerous Idris2 pattern in: $idr
    $hit"
        DANGEROUS_COUNT=$((DANGEROUS_COUNT + 1))
    fi
done

if [ "$IDRIS_FILES_CHECKED" -eq 0 ]; then
    skip_test "SA6 Idris2 pattern check" "no .idr files found"
elif [ "$DANGEROUS_COUNT" -eq 0 ]; then
    pass "SA6 no dangerous patterns in ${IDRIS_FILES_CHECKED} Idris2 ABI spec files"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# SA7 — Mutex protection in all global-state functions
#
# Security invariant: TOCTOU (time-of-check time-of-use) vulnerabilities
# arise when multiple threads access the session pool without synchronisation.
# Every protocol that maintains global session state must acquire a mutex.
# ─────────────────────────────────────────────────────────────────────────────
bold "SA7 — Mutex protection: global session state is guarded"

declare -a SA7_PROTOCOLS=(
    "amqp" "dns" "mqtt" "smtp" "cache" "ca" "bfd"
)

for proto in "${SA7_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "SA7 proven-${proto} mutex" "no src file"
        continue
    fi

    # Check that a mutex variable is declared and that lock/unlock are called.
    HAS_MUTEX=0
    if grep -q "Thread.Mutex\|std.Thread.Mutex" "$SRC_FILE"; then
        HAS_MUTEX=1
    fi
    HAS_LOCK=0
    if grep -q "mutex.lock()\|mutex\.lock()" "$SRC_FILE"; then
        HAS_LOCK=1
    fi
    HAS_UNLOCK=0
    if grep -q "defer.*unlock\|mutex.unlock()" "$SRC_FILE"; then
        HAS_UNLOCK=1
    fi

    if [ "$HAS_MUTEX" -eq 1 ] && [ "$HAS_LOCK" -eq 1 ] && [ "$HAS_UNLOCK" -eq 1 ]; then
        pass "SA7 proven-${proto}: mutex declared, lock acquired, unlock deferred"
    elif [ "$HAS_MUTEX" -eq 0 ]; then
        fail_test "SA7 proven-${proto}: NO mutex declaration — TOCTOU vulnerability"
    elif [ "$HAS_LOCK" -eq 0 ]; then
        fail_test "SA7 proven-${proto}: mutex declared but never locked"
    else
        fail_test "SA7 proven-${proto}: mutex locked but no matching unlock/defer"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# SA8 — Maximum name/payload length constants are defined and finite
#
# Security invariant: fixed-size buffers without an explicit MAX_*_LEN constant
# are error-prone and likely to be misused.  Every protocol with name-based
# lookups or string fields must declare named maximum length constants.
# ─────────────────────────────────────────────────────────────────────────────
bold "SA8 — Maximum length constants defined (buffer overflow prevention)"

declare -a SA8_PROTOCOLS=(
    "amqp" "dns" "mqtt" "smtp" "ftp" "cache" "ca"
    "bfd" "caldav" "coap" "agentic"
)

for proto in "${SA8_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "SA8 proven-${proto} max constants" "no src file"
        continue
    fi

    # Check for at least one named MAX_* length constant.
    if grep -qE "const MAX_[A-Z_]+(:[[:space:]]*usize)?[[:space:]]*=" "$SRC_FILE"; then
        # Count the number of MAX_ constants for information.
        max_count=$(grep -cE "const MAX_[A-Z_]+" "$SRC_FILE" || echo 0)
        pass "SA8 proven-${proto}: ${max_count} MAX_* length constant(s) defined"
    else
        fail_test "SA8 proven-${proto}: NO MAX_* length constants — unbounded buffers possible"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# SA9 — No hardcoded credentials or secrets in FFI source
#
# Security invariant: credentials committed to source are immediately exposed
# on repository clone.  We scan for common patterns: hardcoded passwords,
# API keys, private key material, and base64-encoded secrets.
# ─────────────────────────────────────────────────────────────────────────────
bold "SA9 — No hardcoded credentials or secrets in FFI source"

SECRET_PATTERNS=(
    "password[[:space:]]*=[[:space:]]*\""
    "secret[[:space:]]*=[[:space:]]*\""
    "api_key[[:space:]]*=[[:space:]]*\""
    "private_key[[:space:]]*=[[:space:]]*\""
    "BEGIN RSA PRIVATE KEY"
    "BEGIN EC PRIVATE KEY"
    "BEGIN PRIVATE KEY"
    "Authorization:[[:space:]]*Bearer [A-Za-z0-9+/]"
)

SECRETS_FOUND=0
FILES_CHECKED=0

for src in protocols/proven-*/ffi/zig/src/*.zig \
           connectors/proven-*/ffi/zig/src/*.zig \
           core/proven-*/ffi/zig/src/*.zig; do
    [ -f "$src" ] || continue
    FILES_CHECKED=$((FILES_CHECKED + 1))

    for pat in "${SECRET_PATTERNS[@]}"; do
        if grep -qiE "$pat" "$src"; then
            # Exclude test/example fixture patterns (contain "test", "example", "placeholder").
            hit=$(grep -iE "$pat" "$src" | grep -viE "test|example|placeholder|dummy|mock" | head -2 || true)
            if [ -n "$hit" ]; then
                fail_test "SA9 potential hardcoded credential in $src:
    $hit"
                SECRETS_FOUND=$((SECRETS_FOUND + 1))
            fi
        fi
    done
done

if [ "$FILES_CHECKED" -eq 0 ]; then
    skip_test "SA9 credential scan" "no production FFI source files found"
elif [ "$SECRETS_FOUND" -eq 0 ]; then
    pass "SA9 no hardcoded credentials detected in ${FILES_CHECKED} production files"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# SA10 — SPDX license header present in all FFI source files
#
# Security invariant: missing SPDX headers are a supply-chain transparency
# failure — downstream consumers cannot determine the license obligations of
# the code they are incorporating.
# ─────────────────────────────────────────────────────────────────────────────
bold "SA10 — SPDX license headers present in all FFI source files"

MISSING_SPDX=0
SPDX_CHECKED=0

for src in protocols/proven-*/ffi/zig/src/*.zig \
           connectors/proven-*/ffi/zig/src/*.zig \
           core/proven-*/ffi/zig/src/*.zig; do
    [ -f "$src" ] || continue
    SPDX_CHECKED=$((SPDX_CHECKED + 1))
    if ! head -5 "$src" | grep -q "SPDX-License-Identifier"; then
        fail_test "SA10 missing SPDX header: $src"
        MISSING_SPDX=$((MISSING_SPDX + 1))
    fi
done

if [ "$SPDX_CHECKED" -eq 0 ]; then
    skip_test "SA10 SPDX check" "no production FFI source files found"
elif [ "$MISSING_SPDX" -eq 0 ]; then
    pass "SA10 SPDX headers present in all ${SPDX_CHECKED} production FFI source files"
else
    fail_test "SA10 ${MISSING_SPDX}/${SPDX_CHECKED} production FFI files missing SPDX headers"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
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
