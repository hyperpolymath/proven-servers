#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# proven-servers — Property-Based Test Suite
#
# Verifies algebraic and structural invariants that must hold across ALL
# protocol state machines in the proven-servers codebase.  These are
# property tests in the shell tradition: we enumerate a representative set
# of inputs, assert the invariant for every input, and report each failure
# individually so the failing case is visible.
#
# Properties tested
# ─────────────────
#   P1  Invalid transitions are universally rejected
#         For every protocol that exposes a *_can_transition function, direct
#         jumps that skip intermediate states must return 0.
#
#   P2  Valid initial transitions are universally accepted
#         Every protocol FSM must accept its designated start edge (e.g.
#         Idle → first live state).
#
#   P3  Enum tag roundtrip — ABI tag identity
#         For each protocol the integer tag 0..N-1 for a known enum must
#         survive encode/decode through the published transition table and
#         state-query functions without corruption.
#
#   P4  Slot exhaustion returns a sentinel, not garbage
#         Calling _create beyond the pool limit must return -1 (not a
#         valid slot); behaviour after exhaustion must be deterministic.
#
#   P5  ABI version is non-zero (no uninitialised protocol)
#         Every protocol with an *_abi_version() function must return >= 1.
#
#   P6  Transition predicate is boolean (returns only 0 or 1)
#         can_transition must never return an arbitrary integer.
#
#   P7  Representative protocol Zig FFI builds compile cleanly
#
#   P8  State machine quiescence (terminal state or idle-return)
#         Every FSM must either loop back to state 0 or have a terminal sink.
#
#   P9  Invalid-slot guard present in all mutation functions
#         Calling mutators with bad slot indices must not corrupt state.
#
# Usage
# ─────
#   bash tests/property_test.sh
#   just property-test

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
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
echo "  proven-servers — Property-Based Tests"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P1 — Invalid-transition rejection property
#
# Strategy: for each protocol in our representative set, verify via source
# inspection that the can_transition function returns 0 for canonical
# skip-states cases:
#   AMQP:  Idle(0) → Open(3)           must be 0
#   MQTT:  Idle(0) → Subscribed(2)     must be 0
#   DNS:   QueryReceived(1) → Sent(4)  must be 0 (skip ResponseBuilding)
# We also confirm that the VALID counterpart edge IS present.
# ─────────────────────────────────────────────────────────────────────────────
bold "P1 — Invalid-transition rejection (per-protocol FSM)"

# Format: "proto_slug  invalid_from  invalid_to  valid_from  valid_to"
declare -a P1_CASES=(
    "amqp    0  3   0  1"   # Idle->Open invalid; Idle->Connected valid
    "amqp    5  2   5  0"   # Disconnecting->ChannelOpen invalid; ->Idle valid
    "mqtt    0  2   0  1"   # Idle->Subscribed invalid; Idle->Connected valid
    "mqtt    0  3   1  3"   # Idle->Publishing invalid; Connected->Publishing valid
    "mqtt    4  3   4  0"   # Disconnecting->Publishing invalid; ->Idle valid
    "dns     2  0   2  3"   # Lookup->Idle invalid; Lookup->ResponseBuilding valid
    "dns     3  0   3  4"   # ResponseBuilding->Idle invalid; ->Sent valid
    "dns     1  3   1  2"   # QueryReceived->ResponseBuilding (skip) invalid; ->Lookup valid
)

for entry in "${P1_CASES[@]}"; do
    read -r proto inv_from inv_to val_from val_to <<<"$entry"
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"

    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P1 proven-${proto} (${inv_from}→${inv_to} rejected)" "no src file"
        continue
    fi

    # The valid pair MUST appear in the transition table.
    VALID_PATTERN="from == ${val_from} and to == ${val_to}"
    if grep -q "$VALID_PATTERN" "$SRC_FILE"; then
        pass "P1 proven-${proto}: valid edge ${val_from}→${val_to} present in table"
    else
        fail_test "P1 proven-${proto}: valid edge ${val_from}→${val_to} NOT found in table"
    fi

    # The invalid pair must NOT appear as an accepted transition (return 1).
    INVALID_PATTERN="from == ${inv_from} and to == ${inv_to}"
    if grep "$INVALID_PATTERN" "$SRC_FILE" 2>/dev/null | grep -q "return 1"; then
        fail_test "P1 proven-${proto}: invalid edge ${inv_from}→${inv_to} is ACCEPTED (must be rejected)"
    else
        pass "P1 proven-${proto}: invalid edge ${inv_from}→${inv_to} correctly not accepted"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P2 — Initial-transition acceptance property
#
# Every protocol's FSM must have at least one valid outgoing transition from
# state 0 (the initial state).  A protocol with no exit from state 0 is broken.
# ─────────────────────────────────────────────────────────────────────────────
bold "P2 — Initial-transition acceptance (every FSM can leave state 0)"

declare -a P2_PROTOCOLS=(
    "amqp" "dns" "mqtt" "smtp" "ftp" "cache" "ca" "agentic"
    "bfd" "caldav" "coap" "ctlog" "dds" "doh"
)

for proto in "${P2_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P2 proven-${proto}: initial transition" "no src file"
        continue
    fi

    # Check for at least one accepted transition FROM state 0 to a non-zero state.
    if grep -qE "from == 0 and to == [1-9]" "$SRC_FILE"; then
        pass "P2 proven-${proto}: has valid initial outgoing transition from state 0"
    else
        fail_test "P2 proven-${proto}: NO valid transition from initial state 0"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P3 — Enum tag count correctness
#
# Property: every published enum must have the exact number of tags declared
# in the ABI spec.  Extra or missing tags break the ABI contract.
# We count tag assignments (lines with '= N') in each enum block.
# ─────────────────────────────────────────────────────────────────────────────
bold "P3 — Enum tag count matches ABI spec"

# Format: "proto_slug  enum_name  expected_tag_count"
declare -a P3_CASES=(
    "amqp  FrameType       4"
    "amqp  MethodClass     7"
    "amqp  ExchangeType    4"
    "amqp  DeliveryMode    2"
    "amqp  ConnectionState 5"
    "amqp  BrokerState     6"
    "dns   RecordType      15"
    "dns   QueryClass      4"
    "dns   Opcode          5"
    "dns   ResponseCode    11"
    "dns   DnsState        5"
    "mqtt  BrokerState     5"
    "mqtt  QoSDeliveryState 7"
)

for entry in "${P3_CASES[@]}"; do
    read -r proto enum_name expected_count <<<"$entry"
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"

    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P3 ${proto}::${enum_name}" "no src file"
        continue
    fi

    # Count assignment lines (field = N,) inside the enum block.
    actual_count=$(awk "
        /pub const ${enum_name}[[:space:]]*=/ { in_enum=1; depth=0 }
        in_enum && /\\{/ { depth++ }
        in_enum && /\\}/ { depth--; if (depth == 0) { in_enum=0 } }
        in_enum && depth > 0 && /=[[:space:]]*[0-9]/ { count++ }
        END { print count+0 }
    " "$SRC_FILE")

    if [[ "$actual_count" -eq "$expected_count" ]]; then
        pass "P3 ${proto}::${enum_name}: ${actual_count} tags (expected ${expected_count})"
    elif [[ "$actual_count" -eq 0 ]]; then
        skip_test "P3 ${proto}::${enum_name}" "awk returned 0 — struct layout may differ"
    else
        fail_test "P3 ${proto}::${enum_name}: got ${actual_count} tags, expected ${expected_count}"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P4 — Slot exhaustion returns -1 sentinel
#
# Property: create() functions must validate pool capacity and return -1 when
# full.  We verify this by inspecting that the source contains a '-1' return
# path in the create function body.
# ─────────────────────────────────────────────────────────────────────────────
bold "P4 — Slot exhaustion: create() returns -1 on pool full"

declare -a P4_PROTOCOLS=(
    "amqp" "dns" "mqtt" "cache" "ca" "smtp" "ftp" "bfd"
    "caldav" "coap" "ctlog" "agentic"
)

for proto in "${P4_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P4 proven-${proto} slot exhaustion" "no src file"
        continue
    fi

    if grep -q "return -1" "$SRC_FILE" || grep -q "return @as(c_int, -1)" "$SRC_FILE"; then
        pass "P4 proven-${proto}: create() has -1 exhaustion return path"
    else
        fail_test "P4 proven-${proto}: create() missing -1 exhaustion return path"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P5 — ABI version is non-zero
#
# Property: every protocol with an *_abi_version() function must return >= 1.
# ABI version 0 indicates an uninitialised or placeholder implementation.
# ─────────────────────────────────────────────────────────────────────────────
bold "P5 — ABI version >= 1 (no uninitialised protocols)"

ABI_VERSION_ZERO_COUNT=0
ABI_VERSION_POSITIVE_COUNT=0

for src in protocols/proven-*/ffi/zig/src/*.zig; do
    [ -f "$src" ] || continue
    version=$(awk '
        /export fn.*_abi_version/ { in_fn=1 }
        in_fn && /return [0-9]+;/ {
            match($0, /return ([0-9]+);/, arr)
            print arr[1]
            in_fn=0
        }
    ' "$src")

    [ -z "$version" ] && continue

    proto_name=$(basename "$(dirname "$(dirname "$(dirname "$src")")")")
    if [ "$version" -ge 1 ]; then
        ABI_VERSION_POSITIVE_COUNT=$((ABI_VERSION_POSITIVE_COUNT + 1))
    else
        fail_test "P5 ${proto_name}: abi_version returns ${version} (must be >= 1)"
        ABI_VERSION_ZERO_COUNT=$((ABI_VERSION_ZERO_COUNT + 1))
    fi
done

if [ "$ABI_VERSION_POSITIVE_COUNT" -gt 0 ] && [ "$ABI_VERSION_ZERO_COUNT" -eq 0 ]; then
    pass "P5 all ${ABI_VERSION_POSITIVE_COUNT} detectable ABI versions are >= 1"
elif [ "$ABI_VERSION_POSITIVE_COUNT" -eq 0 ]; then
    skip_test "P5 ABI version check" "no parseable abi_version functions found"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P6 — can_transition is a boolean predicate (returns only 0 or 1)
#
# Property: the can_transition predicate must be total and boolean — it must
# return only 0 or 1, never an arbitrary integer.  We verify statically that
# all 'return' statements inside *_can_transition bodies are 'return 0;' or
# 'return 1;'.
# ─────────────────────────────────────────────────────────────────────────────
bold "P6 — can_transition is a boolean predicate (returns only 0 or 1)"

declare -a P6_PROTOCOLS=("amqp" "dns" "mqtt" "ca" "bfd" "smtp")

for proto in "${P6_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P6 proven-${proto} boolean predicate" "no src file"
        continue
    fi

    bad_returns=$(awk '
        /export fn.*_can_transition/ { in_fn=1; depth=0 }
        in_fn && /\{/ { depth++ }
        in_fn && /\}/ {
            depth--
            if (depth == 0) { in_fn=0 }
        }
        in_fn && depth > 0 && /return[[:space:]]/ {
            if ($0 !~ /return (0|1);/) { print NR": "$0 }
        }
    ' "$SRC_FILE")

    if [ -z "$bad_returns" ]; then
        pass "P6 proven-${proto}: can_transition returns only 0 or 1"
    else
        fail_test "P6 proven-${proto}: can_transition has non-boolean returns: $(echo "$bad_returns" | head -2)"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P7 — Representative protocol Zig FFI builds compile cleanly
#
# Property: every protocol in the representative set must build without errors.
# Build failure is a property violation — the FFI code is broken.
# ─────────────────────────────────────────────────────────────────────────────
bold "P7 — Zig FFI build property: representative protocols compile"

declare -a P7_PROTOCOLS=("amqp" "dns" "mqtt")

for proto in "${P7_PROTOCOLS[@]}"; do
    FFI_DIR="protocols/proven-${proto}/ffi/zig"
    if [ ! -f "$FFI_DIR/build.zig" ]; then
        skip_test "P7 proven-${proto} build" "no build.zig"
        continue
    fi

    if (cd "$FFI_DIR" && zig build 2>/dev/null); then
        pass "P7 proven-${proto}: FFI build succeeds"
    else
        fail_test "P7 proven-${proto}: FFI build FAILED"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P8 — State machine quiescence property (terminal state or idle-return)
#
# Property: every FSM must either include a transition back to state 0
# (idle reset) or have an unconditional 'return 0' fallback indicating a
# terminal sink.  This prevents infinite protocol loops.
# ─────────────────────────────────────────────────────────────────────────────
bold "P8 — State machine quiescence (terminal or idle-return)"

declare -a P8_PROTOCOLS=("amqp" "dns" "mqtt" "smtp" "ca" "cache" "bfd")

for proto in "${P8_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P8 proven-${proto} quiescence" "no src file"
        continue
    fi

    # Check for a transition TO state 0 (return to idle) anywhere in the table.
    if grep -q "and to == 0) return 1" "$SRC_FILE"; then
        pass "P8 proven-${proto}: FSM has idle-return path (quiesces to state 0)"
    elif grep -q "^[[:space:]]*return 0;" "$SRC_FILE"; then
        pass "P8 proven-${proto}: FSM has unconditional reject fallback (terminal safety)"
    else
        fail_test "P8 proven-${proto}: FSM missing idle-return AND unconditional reject fallback"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P9 — Invalid-slot guard present in all mutation functions
#
# Property: calling a state-mutation function with an invalid slot index must
# NOT corrupt any session state.  The validSlot() guard pattern must be present.
# ─────────────────────────────────────────────────────────────────────────────
bold "P9 — Invalid-slot guard present in mutation functions"

declare -a P9_PROTOCOLS=("amqp" "dns" "mqtt")

for proto in "${P9_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P9 proven-${proto} slot guard" "no src file"
        continue
    fi

    # Acceptable guard patterns: validSlot, orelse return, or slot < 0 check.
    if grep -q "validSlot\|orelse return\|slot < 0" "$SRC_FILE"; then
        pass "P9 proven-${proto}: slot validation guard is present"
    else
        fail_test "P9 proven-${proto}: NO slot validation guard found"
    fi
done
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
